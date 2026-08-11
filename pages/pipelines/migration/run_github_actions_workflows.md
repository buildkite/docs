---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs in this public preview of the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

> 📘 Public preview
> Running GitHub Actions workflows in Buildkite is currently in public preview. To report issues with the preview, [open an issue in the `buildkite-gha` repository](https://github.com/buildkite/buildkite-gha/issues). For help migrating to native Buildkite Pipelines steps, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).
> The plugin and runtime are under active development. Review the [`buildkite-gha` v0.7.2 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.7.2/docs/compatibility.md) before adding a workflow.

The [GitHub Actions Buildkite plugin](https://buildkite.com/resources/plugins/) gives you a quick way to get a supported GitHub Actions workflow running in Buildkite with minimal changes, without first rewriting it as a native Buildkite pipeline. Once the workflow is up and running, you can [convert it into native Buildkite Pipelines steps](/docs/pipelines/migration/from-githubactions) to take full advantage of Buildkite Pipelines features.

During the preview, the quickest way to get started is with a Linux x86-64 workflow in a public `github.com` repository that doesn't need secrets. Private repository checkout and temporary GitHub tokens are also available in limited cases, but require extra setup, so [check what the preview supports and its current limitations](#supported-functionality-and-limitations) before you begin.

## Add a GitHub Actions workflow to a pipeline

### Create a new pipeline from the template

To create a pipeline for a GitHub Actions workflow:

1. From the Buildkite dashboard, select **New Pipeline**.
1. Select the GitHub repository that contains your workflow.
1. In the **YAML Steps editor**, open the **Template** dropdown and select **GitHub Actions**.
1. In the generated YAML, set `workflow` to the path of the workflow file in your repository.
1. Select **Create and run**.

### Configure the plugin manually

To configure the plugin without using the template, add the following step to your [pipeline configuration](/docs/pipelines/configure/defining-steps). Set `workflow` to the path of the workflow file in your repository. Give the step a unique `key` so Buildkite can connect it to the jobs created by the plugin:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#v0.7.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.7.2"
```
{: codeblock-file=".buildkite/pipeline.yml"}

When this step runs, the plugin turns the workflow jobs into a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines). Each generated job depends on the plugin step, so Buildkite waits for the plugin to finish before running them.

For a released runtime, use the following configuration:

| Property | Required | Description |
| --- | --- | --- |
| `workflow` | Yes | Path to the GitHub Actions workflow in the repository. |
| `version` | No | Exact `buildkite-gha` runtime version to run. When omitted, the plugin uses its default runtime version. |
{: class="responsive-table"}

> 📘 Runtime versions
> The `v0.7.1` plugin uses runtime `0.7.1` by default. The examples on this page set `version` to `0.7.2` to use the newer runtime release. If you update the runtime version, use its matching compatibility guide.

Buildkite decides when the pipeline runs, so the workflow's `on` key doesn't create build triggers. Set up GitHub triggers and schedules in Buildkite, or start a build yourself by selecting **New Build** or using the REST API.

For manual and scheduled builds, the plugin automatically finds the exact commit after checkout.

The plugin also gives the workflow a GitHub event type based on how the Buildkite build started:

- Pull request builds receive `pull_request`.
- Branch, tag, scheduled, and manual builds receive `push`.

Scheduled and manual builds receive `push` rather than `schedule` or `workflow_dispatch`. The plugin doesn't provide dispatch inputs, so these builds work only with workflows that can run with `push` event data.

## Migrate incrementally

You don't have to convert the whole workflow at once. Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. In this example, the native `Deploy` step waits for all the imported test jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    plugins:
      - github-actions#v0.7.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.7.2"

  - label: "Deploy"
    key: "deploy"
    depends_on: "github-actions-tests"
    command: ".buildkite/deploy.sh"
```
{: codeblock-file=".buildkite/pipeline.yml"}

As you replace jobs with native Buildkite Pipelines steps, the remaining supported workflow jobs can keep running through the plugin. If you want to convert a whole workflow instead, use the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions).

## How the plugin and runtime work

The plugin and the `buildkite-gha` runtime work together to run the workflow. This page calls the keyed command step that runs the plugin the _importer step_, and the jobs it creates the _generated jobs_.

Each part has a different job:

- **GitHub Actions Buildkite plugin:** Reads your configuration, downloads and verifies the selected `buildkite-gha` release, then starts the upload.
- **`buildkite-gha`:** Checks that the workflow is supported, turns its jobs into Buildkite Pipelines command jobs, uploads them, and runs each generated job.

You don't need to install `buildkite-gha` yourself. The plugin downloads the Linux x86-64 runtime binary and checks its checksum and archive contents before running it.

For jobs that use JavaScript actions, the runtime prepares a verified, managed `mise` installation that provides the supported Node.js versions. It doesn't install `mise` for shell-only jobs or jobs that use only native adapters or Docker. The importer step and the `validate` and `compile` commands don't need `mise` either.

The importer passes the runtime and compiled execution plans to the generated jobs using [Buildkite Pipelines artifacts](/docs/pipelines/configure/artifacts). Each job verifies these files before using them. This process doesn't create a corresponding workflow run in GitHub. Buildkite handles the schedule, logs, retries, cancellations, and build status.

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

Before it can download the runtime and create the workflow jobs, the importer step needs:

- A Linux x86-64 agent.
- Buildkite agent v3.34.1 or later in the v3 release series. Agent v4 isn't supported because the runtime uses the `--reject-secrets` option, which Agent v4 doesn't provide.
- Bash, `curl`, `tar`, `sha256sum`, `awk`, `grep`, `find`, `sed`, `sort`, `mktemp`, and `cp`.
- Git when `BUILDKITE_COMMIT` isn't already a full commit SHA.
- Outbound HTTPS access to public GitHub release and action sources.

Generated jobs need Buildkite agent v3.130.0 or later. The runtime tells the agent to skip its usual repository checkout so that it can prepare the workflow's workspace instead.

Generated jobs use the pipeline or organization's default agents unless you choose a queue. To send every generated job to a specific queue, set `BUILDKITE_GHA_TARGET_QUEUE` on the importer step. The runtime sends all accepted Ubuntu runner labels to that queue.

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    env:
      BUILDKITE_GHA_TARGET_QUEUE: "gha-preview"
    plugins:
      - github-actions#v0.7.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.7.2"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Because the queue can run untrusted workflow code, use agents that isolate each job and don't provide ambient credentials.

The generated jobs also need network access for anything they download at runtime:

- Jobs that use public GitHub Actions need outbound HTTPS access to `codeload.github.com`, where the runtime downloads each action's source archive.
- Jobs that use JavaScript actions need outbound HTTPS access to the managed Node.js and `mise` downloads. Actions that declare `node20` or `node24` run on managed Node 24 and require glibc 2.28 or newer. Shell-only workflows don't have this glibc requirement.

When resolving a mutable tag or branch for a public action, the importer uses an available job-scoped GitHub token only for the GitHub API request. If it can't obtain or register the token, it reports a warning and retries anonymously. A lowercase, full 40-character commit SHA doesn't require an API request. The importer and generated jobs download the resolved action archive anonymously from `codeload.github.com`.

On [Buildkite hosted agents](/docs/agent/buildkite-hosted) or the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s), you can use a toolchain-enabled image for every generated job. Set `BUILDKITE_GHA_RUNTIME_IMAGE` on the importer step to an immutable image digest. The runtime rejects tags and other mutable image references. Generated jobs use the image and its `/opt/hostedtoolcache` tools. Don't set this variable for other self-hosted agent environments. These environments don't provision the image or `/opt/hostedtoolcache`, so generated jobs fail before the workflow starts.

### Cache the runtime download

On Buildkite hosted agents, attach the plugin cache volume to speed up the importer:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    cache: "/cache/bkcache/github-actions-buildkite-plugin"
    plugins:
      - github-actions#v0.7.1:
          workflow: ".github/workflows/ci.yml"
          version: "0.7.2"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Without this volume, the plugin uses an agent or user cache when one is available, then falls back to a temporary directory. The plugin verifies cached archives before using them. This importer cache is separate from generated-job runtime caching and the workflow's `actions/cache` behavior.

## Supported functionality and limitations

The preview supports an evolving subset of GitHub Actions. The following lists summarize common supported features and limitations:

- Linux x86-64 jobs using `ubuntu-latest`, `ubuntu-24.04`, or `ubuntu-22.04`. These labels identify a compatible runner, but don't give the agent the same tools or image layout as a GitHub-hosted runner.
- Bash and `sh` run steps.
- Static job dependencies and matrices, including `include` and `exclude`, up to 256 expanded instances per job.
- Supported job and step conditions, outputs, and timeouts, plus step-level `continue-on-error` behavior.
- Public JavaScript, composite, local, and compiler-verified Dockerfile actions.
- Local reusable workflows with statically resolvable inputs.
- `actions/checkout` for the repository and exact commit that triggered the build. Checkout is anonymous for a public repository. For a private repository, it uses Buildkite's repository-provider Git credentials when they are enabled for the job and Buildkite authorizes the repository URL.
- Statically resolvable workflow- and job-level `concurrency`, mapped to repository-scoped Buildkite Pipelines concurrency groups.
- Native-backed `actions/upload-artifact` and `actions/download-artifact`, for the audited action revisions only.
- `actions/cache` for the audited revision, using the Buildkite Results service by default. The Buildkite organization must have GitHub Actions cache token minting enabled. Jobs must be able to reach the Results service and the Agent API.

The runtime rejects many unsupported or privileged features before it uploads any jobs. However, some unsupported settings are ignored rather than rejected. Important limitations include:

- GitHub Enterprise Server repositories, non-GitHub repository providers, private actions, and private reusable workflows.
- General workflow secrets, ambient `GITHUB_TOKEN`, alternate-repository or alternate-ref checkout, and GitHub-compatible OIDC, including `id-token`.
- Windows and macOS jobs, and Linux arm64.
- Job and service containers. The runtime can run them, but the current production upload policy doesn't admit them.
- `docker://` actions, which the runtime rejects during validation.
- Dynamic matrices and remote reusable workflows.
- The matrix `strategy.fail-fast` setting. The runtime accepts this setting but doesn't enforce it, so a failed matrix job won't cancel the others. This differs from the GitHub Actions default. If `fail-fast` contains an expression, the workflow doesn't compile.
- `cancel-in-progress`. Setting this to a literal `true` at the workflow level produces a warning but doesn't cancel an older build. Job-level settings and expressions don't compile. See [Concurrency](#supported-functionality-and-limitations-concurrency) for more detail.
- Unaudited revisions of actions with native support, including checkout, artifacts, and cache.
- The complete `github.event` payload and GitHub-specific event behavior.

### Known preview gaps

You may need to update a workflow before you can run it during the preview:

- **Update actions that use Node 16.** The runtime supports actions that declare `node20` or `node24`, but rejects `node16`. Choose a newer action release that uses a supported runtime. For example, update `actions/checkout@v3` to `actions/checkout@v4`.
- **Check `actions/upload-artifact@v4` inputs.** The `retention-days` input isn't supported. The `path` input accepts up to 32 literal files or directories, and each path must be clean and relative to the workspace. It doesn't accept globs, exclusions, expressions, `./` prefixes, trailing slashes, symlinks, or non-regular files. For example, use `path: playwright-report`, not `path: playwright-report/` or `path: ./playwright-report/`. Each upload can contain up to 10,000 files and 1 GiB of source or archive data.

See the [`buildkite-gha` v0.7.2 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.7.2/docs/compatibility.md) for the supported functionality and limitations of the runtime selected in this page's examples.

> 🚧 Treat workflow code as build code
> All steps in an imported job share a workspace and process lifecycle. Docker actions don't provide a security boundary between steps. If the workflow code must be isolated from other jobs or the agent host, run each job on a disposable machine.

### Concurrency

The runtime turns each static `concurrency` group into a case-insensitive Buildkite Pipelines concurrency group scoped to the repository. Workflow-level groups use ordered opening and closing gates, while job-level groups use a concurrency limit of one.

Workflow-level groups can use supported `github` fields and `vars`. Job-level groups can also use concrete `matrix` values and inputs from local reusable workflows when their values are known before the job runs. The workflow won't compile if a group can't be resolved, and workflow-level concurrency isn't supported inside a called reusable workflow.

Buildkite queues every waiting entry, unlike GitHub's default behavior of replacing an existing pending entry. If you want similar cancellation behavior, turn on **Cancel Intermediate Builds** and **Skip Intermediate Builds** in the pipeline's build settings. These settings work by branch, so they match a workflow concurrency group only when its scope follows the same branch boundaries.

### Credentials and tokens

To check out the private repository that triggered the build, enable Buildkite's repository-provider Git credentials for the job. Buildkite must also authorize the repository URL. Without both, checkout is anonymous. This access doesn't provide `GITHUB_TOKEN` or `github.token`, and it can't be used for private actions or other repositories.

Buildkite can provide a short-lived token for the repository that triggered the build. The organization must first enable the job-bound token service, and the job must either reference `secrets.GITHUB_TOKEN` directly or use an action whose default input references `github.token`.

If the workflow doesn't include a `permissions` map, the token receives `contents: read`. A non-empty `permissions` map replaces that default, while an empty map or a map containing only `none` doesn't produce a token. The runtime doesn't add the token to the job's initial environment, although an action can make it available to later steps through `GITHUB_ENV`, as it can on a GitHub runner. General workflow secrets and an ambient `GITHUB_TOKEN` aren't available.

> 🚧 Protect tokens from untrusted workflow changes
> The job-bound token service doesn't decide whether a fork or actor is trusted. If a pull request can change an imported workflow, that workflow can request and use any repository permission enabled by the service. Make sure untrusted workflow changes can't receive write permissions.

## Use the buildkite-gha CLI directly

For most workflows, use the plugin. If you need more control or want to diagnose a problem, you can download the `buildkite-gha` binary from the [`buildkite-gha` releases](https://github.com/buildkite/buildkite-gha/releases).

After downloading the release archive, verify it against the published checksums. You can then check a workflow's syntax and compatibility without running it:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

The CLI also provides `compile` and `upload` commands. The `validate` and `compile` commands don't need `mise` and don't run workflow code.

Run `upload` from a keyed Buildkite Pipelines command step so that the `BUILDKITE` and `BUILDKITE_STEP_KEY` environment variables are available. The step must use Buildkite agent v3.34.1 or later in the v3 release series; Agent v4 isn't supported.

As with the plugin, generated jobs manage their own `mise` setup only when their actions need it. They use the pipeline or organization's default agents unless you set `BUILDKITE_GHA_TARGET_QUEUE` to choose a queue. The plugin handles all of this setup for you, which is why it's the best option for most workflows.

## Next steps

- Learn how to [migrate from GitHub Actions](/docs/pipelines/migration/from-githubactions).
- [Translate a GitHub Actions workflow](/docs/pipelines/converter/github-actions) to native Buildkite Pipelines configuration.
- Learn more about [using plugins](/docs/pipelines/integrations/plugins/using).
