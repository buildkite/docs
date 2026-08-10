---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs in this research preview of the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

> 📘 Research preview
> Running GitHub Actions workflows in Buildkite is currently in research preview. To provide feedback or report issues, contact Buildkite's Support team at [support@buildkite.com](mailto:support@buildkite.com).

The [GitHub Actions Buildkite plugin](https://buildkite.com/resources/plugins/) lets you run supported GitHub Actions workflows as jobs in a Buildkite Pipelines build. Use the plugin to move workflows to Buildkite Pipelines incrementally, before [translating them to native pipeline steps](/docs/pipelines/migration/from-githubactions).

The compatibility runtime runs supported Linux x86-64 workflows hosted on `github.com`. The current profile is built for public code that runs without general credentials. It also supports a private event-repository checkout and short-lived job tokens in limited cases, when Buildkite supplies and authorizes the credentials. Review the [supported functionality and limitations](#supported-functionality-and-limitations) before adding a workflow.

## Add a GitHub Actions workflow to a pipeline

Add a keyed command step to your [pipeline configuration](/docs/pipelines/configure/defining-steps). Configure the plugin with the path to the workflow:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#v0.6.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.6.1"
```
{: codeblock-file=".buildkite/pipeline.yml"}

The `key` attribute is required. The plugin uploads the workflow jobs as a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines), and each generated job depends on the plugin step.

The plugin accepts the following configuration:

| Property | Required | Description |
| --- | --- | --- |
| `workflow` | Yes | Path to the GitHub Actions workflow in the repository. |
| `version` | No | Exact `buildkite-gha` runtime version to run. When omitted, the plugin uses its default runtime version. |
{: class="responsive-table"}

The plugin release and the `buildkite-gha` runtime version are independent. The `v0.6.1` plugin runs `buildkite-gha` `0.6.0` by default. To run a specific runtime release, set `version`:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#v0.6.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.6.1"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Buildkite Pipelines controls when builds run. Configure source control triggers and schedules in Buildkite, and start manual builds with **New Build** or the REST API. The workflow's `on` key does not configure Buildkite Pipelines build triggers.

The plugin resolves a symbolic Buildkite commit, such as `HEAD` on a manual or scheduled build, to a full commit SHA after checkout. No extra configuration is required.

The plugin provides `pull_request` context for pull request builds. Branch, tag, scheduled, and manual builds receive `push` context. The plugin does not provide `schedule`, `workflow_dispatch`, or dispatch inputs, so a scheduled or manual build is compatible only when the workflow expects push semantics.

## Migrate incrementally

Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. A native step that depends on the plugin step waits for all generated workflow jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    plugins:
      - github-actions#v0.6.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.6.1"

  - label: "Deploy"
    key: "deploy"
    depends_on: "github-actions-tests"
    command: ".buildkite/deploy.sh"
```
{: codeblock-file=".buildkite/pipeline.yml"}

This approach lets you keep supported workflows running while replacing jobs with native Buildkite Pipelines steps. To translate a workflow rather than run it through the compatibility runtime, use the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions).

## How the plugin and runtime work

The keyed command step that runs the plugin is the _importer step_. The workflow jobs it uploads are the _generated jobs_. The plugin and the `buildkite-gha` runtime have separate responsibilities:

- **GitHub Actions Buildkite plugin:** Reads the plugin configuration, downloads and verifies the configured `buildkite-gha` release, then runs its `upload` command.
- **`buildkite-gha`:** Validates and compiles the workflow, translates its jobs into Buildkite Pipelines command jobs, uploads the generated pipeline, and provides the compatibility runtime that executes each generated job.

You do not need to download or install `buildkite-gha` when using the plugin. The plugin downloads the Linux x86-64 runtime binary and verifies its checksum and archive contents before running it.

The runtime manages its own language tooling. When a generated job runs JavaScript actions, it prepares a verified, managed `mise` installation to supply the supported Node.js versions. Shell-only jobs, and jobs that use only native adapters or Docker, do not require or install `mise`. The importer step, and the `validate` and `compile` commands, do not require `mise` either.

The importer and generated jobs exchange the runtime and compiled execution plans using [Buildkite Pipelines artifacts](/docs/pipelines/configure/artifacts). Generated jobs verify these files before execution. No corresponding workflow run is created in GitHub. Buildkite Pipelines controls scheduling, logs, retries, cancellation, and build status.

GitHub Actions concepts map to Buildkite Pipelines as follows:

| GitHub Actions concept | Buildkite Pipelines behavior |
| --- | --- |
| Workflow run | The current Buildkite Pipelines build. |
| Job | A generated Buildkite Pipelines command job. |
| Static matrix entry | A separate generated command job. |
| `needs` | Buildkite Pipelines step dependencies. |
| Steps within a job | Steps run together in one compatibility runtime and share a workspace and lifecycle. |
{: class="responsive-table"}

## Requirements

The plugin importer step requires:

- A Linux x86-64 agent.
- Buildkite agent v3.34.1 or later in the v3 release series. Agent v4 is not supported because the runtime calls `buildkite-agent pipeline upload` with `--reject-secrets`, which Agent v4 does not provide.
- Bash, `curl`, `tar`, `sha256sum`, `awk`, `grep`, `find`, `sed`, `sort`, `mktemp`, and `cp`.
- Outbound HTTPS access to public GitHub release and action sources.

Generated jobs do not set an agent queue by default, so they run on the pipeline or organization default agents. To send generated jobs to a specific queue, set the `BUILDKITE_GHA_TARGET_QUEUE` environment variable on the importer step. The runtime maps every accepted Ubuntu runner label to that queue. The named queue admits untrusted workflow code, so it must provide suitable per-job isolation and no ambient credentials.

JavaScript actions run on managed Node 20 or Node 24 runtimes, according to the action's runtime declaration, and require glibc 2.28 or newer. These jobs need outbound HTTPS access to the managed Node.js and `mise` downloads. Shell-only workflows do not have the glibc requirement. Step summaries and warning or error annotations require Buildkite Agent v3.112.0 or later.

## Supported functionality and limitations

The compatibility runtime supports a defined subset of GitHub Actions. The supported functionality includes:

- Linux x86-64 jobs using `ubuntu-latest`, `ubuntu-24.04`, or `ubuntu-22.04`. Accepted labels validate the runner; they do not promise GitHub's installed tools or image layout.
- Bash and `sh` run steps.
- Static job dependencies and matrices, including `include` and `exclude`, up to 256 expanded instances per job.
- Supported job and step conditions, outputs, and timeouts, plus step-level `continue-on-error` behavior.
- Public JavaScript, composite, local, and compiler-verified Dockerfile actions.
- Local reusable workflows with statically resolvable inputs.
- `actions/checkout` for the event repository at the exact event SHA. The checkout runs anonymously for a public repository, and uses Buildkite's repository-provider Git credentials for a private repository when the job has those credentials enabled and the Buildkite backend authorizes the repository URL.
- Statically resolvable workflow- and job-level `concurrency`, mapped to repository-scoped Buildkite Pipelines concurrency groups.
- Native-backed `actions/upload-artifact` and `actions/download-artifact`, for the audited action revisions only.
- `actions/cache` for the audited revision, using the Buildkite Results service by default. The Buildkite organization must have GitHub Actions cache token minting enabled. Jobs must be able to reach the Results service and the Agent API.

The compatibility profile rejects many unsupported or privileged features before uploading generated jobs. Some limitations, including ignored settings, do not fail validation. Current limitations include:

- GitHub Enterprise Server repositories, non-GitHub repository providers, private actions, and private reusable workflows.
- General workflow secrets, ambient `GITHUB_TOKEN`, alternate-repository or alternate-ref checkout, and GitHub-compatible OIDC, including `id-token`.
- Windows and macOS jobs, and Linux arm64.
- Job containers, service containers, and `docker://` actions. Container images are implemented and proven, but the production upload policy rejects their provenance.
- Dynamic matrices and remote reusable workflows.
- The matrix `strategy.fail-fast` setting. The runtime accepts it but does not enforce it. Every expanded matrix job is uploaded, and a failure in one matrix job does not cancel its siblings. This differs from the GitHub Actions default, where `fail-fast: true` cancels the remaining matrix jobs after one fails. An expression-valued `fail-fast` fails compilation.
- `cancel-in-progress`. A workflow-level literal `true` emits a warning but does not cancel an older build. Job-level and expression-valued cancellation fail compilation. See the concurrency details below.
- Arbitrary action revisions for actions that receive native support, including checkout, artifacts, and cache.
- The complete `github.event` payload and GitHub-specific event behavior.

### Known preview gaps

The research preview has the following gaps that may require workflow changes:

- **Actions that use Node 16:** The runtime supports action metadata that declares `node20` or `node24`, but rejects `node16`. Update older action revisions to a release that uses a supported runtime. For example, update `actions/checkout@v3` to `actions/checkout@v4`.
- `actions/setup-node@v7`: The default `token` expression uses operators that the runtime expression subset does not support. Set `token: ""` explicitly when authenticated Node.js distribution downloads are not required.
- `actions/upload-artifact@v4`: The `retention-days` input is not supported. The `path` input accepts at most 32 clean, workspace-relative literal files or directories. The input does not accept globs, exclusions, expressions, `./` prefixes, trailing slashes, symlinks, or non-regular files. An upload can contain at most 10,000 files and 1 GiB of source or archive data. For example, use `path: playwright-report`, not `path: playwright-report/` or `path: ./playwright-report/`.

See the [`buildkite-gha` v0.6.1 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.6.1/docs/compatibility.md) for the full compatibility matrix, audited action revisions, event behavior, and detailed limits.

> 🚧 Treat workflow code as build code
> Steps in an imported GitHub Actions job share a workspace and process lifecycle. Docker actions are an execution backend, not a security boundary between steps. Use disposable per-job machines when workflow code must be isolated from other jobs or from the agent host.

### Concurrency

Statically resolvable `concurrency` groups become repository-scoped, case-insensitive Buildkite Pipelines concurrency groups. A workflow-level group emits an ordered opening and closing gate, and a job-level group uses a concurrency limit of one. Workflow-level groups can use supported `github` fields and `vars`. Job-level groups can also use concrete `matrix` values and statically substituted inputs from local reusable workflows. Workflow-level concurrency in a called reusable workflow is not supported. Groups that cannot be resolved fail closed.

This is queue compatibility, not cancellation parity. Buildkite Pipelines keeps all waiting entries in order, while GitHub's default concurrency mode replaces an existing pending entry. To approximate GitHub cancellation, configure **Cancel Intermediate Builds** and **Skip Intermediate Builds** in the pipeline's build settings. Those same-branch controls match a workflow's concurrency group only when the branch scope lines up.

### Credentials and tokens

A private event repository can be checked out when the job has Buildkite repository-provider Git credentials enabled and the Buildkite backend authorizes the repository URL. The checkout is anonymous otherwise. This path does not populate `GITHUB_TOKEN` or `github.token`, and does not enable private actions or alternate repositories.

A job that statically references `secrets.GITHUB_TOKEN`, or uses an action whose effective metadata input default references `github.token`, receives one short-lived token for the exact event repository. This requires a non-empty, explicit `permissions` map on the job or workflow, and the organization must enable the job-bound token service. The runtime does not add the token to the initial job environment. An action can export it to later steps through `GITHUB_ENV`, as on the GitHub runner. General workflow secrets and ambient `GITHUB_TOKEN` are not provided.

> 🚧 Protect tokens from untrusted workflow changes
> The job-bound token service does not establish fork or actor trust. If a pull request can change imported workflow files, that code can request any repository permission enabled by the service and use the resulting token. Prevent untrusted workflow changes from receiving write permissions.

## Use the buildkite-gha CLI directly

The plugin is the recommended way to run workflows. The [`buildkite-gha` releases](https://github.com/buildkite/buildkite-gha/releases) also provide a separately downloadable binary for validation, diagnostics, and advanced direct use.

After downloading the release archive and verifying it against the published checksums, use the CLI to validate a workflow's syntax and static compatibility:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

The CLI also provides `compile` and `upload` commands. The `validate` and `compile` commands do not require `mise` and do not execute workflow code. Run `upload` from a keyed Buildkite Pipelines command step: it requires the `BUILDKITE` and `BUILDKITE_STEP_KEY` environment variables. Direct `upload` requires Buildkite agent v3.34.1 or later in the v3 release series. Agent v4 is not supported. Generated jobs manage their own `mise` installation when a workflow uses actions that need it. Direct `upload` does not set an agent queue by default, so generated jobs run on the pipeline or organization default agents. To select one queue, set `BUILDKITE_GHA_TARGET_QUEUE`. The plugin automates these steps, so use the CLI directly only when you need more control or diagnostics.

## Next steps

- Learn how to [migrate from GitHub Actions](/docs/pipelines/migration/from-githubactions).
- [Translate a GitHub Actions workflow](/docs/pipelines/converter/github-actions) to native Buildkite Pipelines configuration.
- Learn more about [using plugins](/docs/pipelines/integrations/plugins/using).
