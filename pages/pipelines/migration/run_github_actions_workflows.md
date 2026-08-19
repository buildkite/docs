---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs in this public preview of the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

> 📘 Public preview
> Running GitHub Actions workflows in Buildkite is currently in public preview. To report issues with the preview, [open an issue in the `buildkite-gha` repository](https://github.com/buildkite/buildkite-gha/issues). For help migrating to native Buildkite Pipelines steps, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).
> The plugin and runtime are under active development. Review the [`buildkite-gha` v0.13.11 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.13.11/docs/compatibility.md) before adding a workflow.

The GitHub Actions Buildkite plugin runs supported GitHub Actions workflows as Buildkite Pipelines jobs. This lets you migrate a workflow with minimal changes, then replace imported jobs with [native Buildkite Pipelines steps](/docs/pipelines/migration/from-githubactions) over time.

During the preview, start with a Linux x86-64 workflow in a public `github.com` repository that doesn't need secrets. Private repository checkout and temporary GitHub tokens require additional setup. Review the [supported functionality and limitations](#supported-functionality-and-limitations) before you begin.

## Add a GitHub Actions workflow to a pipeline

Use the workflow picker or GitHub Actions template to create a new pipeline. You can also use the workflow picker or configure the plugin manually in an existing pipeline.

### Detect workflows automatically

> 📘 Workflow picker availability
> The workflow picker is rolling out to existing Buildkite organizations. It is available for repositories connected using the full-access [**GitHub** repository provider](/docs/pipelines/source-control/github#github-repository-provider-options), which gives Buildkite access to workflow files on the repository's default branch. The picker isn't available for **GitHub (Limited Access)** connections. If the picker doesn't appear for an eligible repository, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com). In the meantime, use the GitHub Actions template described in the next section.

The workflow picker detects GitHub Actions workflows on the repository's default branch and lists them in the **YAML Steps editor**, so you don't have to configure the plugin step by hand. Selecting a detected workflow adds a GitHub Actions Buildkite plugin step to your YAML, including a [mise cache](#requirements-cache-mise-installations) so the importer can reuse `mise` and `buildkite-gha` across builds.

#### Create a new pipeline with the workflow picker

To create a pipeline using detected GitHub Actions workflows:

1. From the Buildkite dashboard, select **New Pipeline**.
1. Under **Git scope**, select your GitHub account or organization. Then select a repository that contains GitHub Actions workflow files on its default branch.
1. In the detected **GitHub Actions** workflows panel, select **Select workflows...**.
1. Select each supported workflow that you want to run, or select **Select all**.
1. Review the generated plugin step in the **YAML Steps editor**.
1. Select **Create and run**.

Opening the panel doesn't change the pipeline configuration until you select a workflow. Only workflows with supported triggers can be selected. Other workflows appear as **Not supported**. Selecting all workflows adds each workflow path explicitly.

#### Add workflows to an existing pipeline

To add detected workflows to an existing pipeline:

1. From your pipeline, select **Pipeline settings** > **Edit steps**. Any user who can edit the pipeline can use the workflow picker, even without permission to create pipelines.
1. In the detected **GitHub Actions** workflows panel, select **Select workflows...**.
1. Select each supported workflow that you want to run, or select **Select all**. If your existing GitHub Actions Buildkite plugin step uses `workflow`, selecting workflows replaces it with `workflows` and keeps the plugin's version, other options, and comments.
1. Review the generated plugin step in the **YAML Steps editor**, then select **Save steps**.

Your existing pipeline configuration, including any steps you've already added, is preserved while workflows load and while you select or deselect them.

> 📘 Pull request build settings for existing pipelines
> If a selected workflow handles pull request events, review the pipeline's [GitHub settings](/docs/pipelines/source-control/github#running-builds-on-pull-requests). Turn off **Skip when pull request has existing build for commit and branch** and **Skip when pull request is closed or merged** to ensure duplicate-commit and closed or merged pull request webhook events reach the imported workflow.

### Create a new pipeline from the template

The GitHub Actions template provides a manual fallback when the workflow picker isn't available. Your pipeline must use the **YAML Steps editor**, rather than the traditional drag-and-drop editor, to access this template.

To create a pipeline for a GitHub Actions workflow:

1. From the Buildkite dashboard, select **New Pipeline**.
1. Select the GitHub repository that contains your workflow.
1. In the **YAML Steps editor**, open the **Template** dropdown and select **GitHub Actions**.
1. In the generated YAML, set `workflow` to the path of the workflow file in your repository.
1. Select **Create and run**.

> 📘 Pull request build settings for pipelines using GitHub Actions workflows
> When you create a pipeline with GitHub Actions workflows selected, Buildkite Pipelines turns off the new pipeline's **Skip when pull request has existing build for commit and branch** and **Skip when pull request is closed or merged** GitHub settings. This ensures pull request webhook events reach the imported workflow as expected. Pipelines created without selecting any GitHub Actions workflows keep the normal defaults for both settings. You can change either setting at any time in the pipeline's [GitHub settings](/docs/pipelines/source-control/github#running-builds-on-pull-requests).

### Configure the plugin manually

To configure the plugin without using the template, add the following step to your [pipeline configuration](/docs/pipelines/configure/defining-steps). Set `workflow` to the path of one workflow file in your repository. Give the step a unique `key` so Buildkite can connect it to the jobs created by the plugin:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#latest:
          workflow: ".github/workflows/ci.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

To select multiple workflows, use `workflows` with an array of explicit paths:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#latest:
          workflows:
            - ".github/workflows/ci.yml"
            - ".github/workflows/release.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Use either `workflow` or `workflows`, but not both. Each path must identify a tracked `.yml` or `.yaml` file inside the repository. Directories, globs, symlinks, untracked files, and paths outside the repository aren't supported.

When this step runs, the plugin turns the workflows into a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines). Each successfully compiled, directly runnable workflow becomes a group that depends on the plugin step. The generated jobs appear inside the group. A safe workflow-specific compilation or trigger-translation failure becomes a failing top-level replacement step. Other valid workflows continue. Parse, event-input, admission, artifact, and upload failures abort the transaction.

The plugin supports the following configuration:

| Property | Required | Description |
| --- | --- | --- |
| `workflow` | One selector is required | Path to one GitHub Actions workflow in the repository. |
| `workflows` | One selector is required | Array of paths to GitHub Actions workflows in the repository. |
| `version` | No | Latest stable or an exact `buildkite-gha` runtime release from `0.9.0` onward. The default is `latest`. |
| `source-ref` | No | Full lowercase 40-character runtime commit for testing unreleased changes. This property can't be used with `version`. |
| `minimum-release-age` | No | Minimum release age used by `mise` when resolving `latest`. The default is `0s`. |
| `runners` | No | Array that maps GitHub runner labels to Buildkite queues and optional Linux images. |
{: class="responsive-table"}

Buildkite decides when the pipeline runs, so the workflow's `on` key doesn't create build triggers. Set up GitHub triggers and schedules in Buildkite, or start a build yourself by selecting **New Build** or using the REST API. Within an existing build, the `on` key determines whether each selected workflow is eligible to run.

For manual and scheduled builds, the plugin automatically finds the exact commit after checkout.

The plugin gives each workflow a GitHub event type based on how the Buildkite build started:

- Pull request builds receive `pull_request`.
- Builds started from the Buildkite interface or API receive `workflow_dispatch`.
- Scheduled builds receive `schedule`.
- Other builds, including branch, tag, and triggered builds, receive `push`.

Each successfully compiled workflow that declares the effective event becomes a group named for the workflow. Its external check identifies both the workflow and effective event. A workflow that doesn't declare the effective event becomes a top-level skipped step. After upload, an importer-scoped informational annotation lists skipped workflows. A local reusable workflow that declares only `workflow_call` can support another selected workflow, but doesn't create its own group.

The runtime supports branch and tag filters for `push`, and base-branch and activity filters for `pull_request`. Every workflow that declares `schedule` is eligible for every Buildkite scheduled build. Path filters are rejected because Buildkite Pipelines change-based conditions don't have equivalent behavior.

## Migrate incrementally

You don't have to convert the whole workflow at once. Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. In this example, the native `Deploy` step waits for all the imported test jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    plugins:
      - github-actions#latest:
          workflow: ".github/workflows/ci.yml"

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

- **GitHub Actions Buildkite plugin:** Reads your configuration, prepares `mise`, then asks it to select and run the configured `buildkite-gha` release.
- **`buildkite-gha`:** Checks that the workflow is supported, turns its jobs into Buildkite Pipelines command jobs, uploads them, and runs each generated job.

You don't need to install `mise` or `buildkite-gha` yourself. The plugin uses a compatible `mise` from `PATH` or installs a pinned, verified copy. Mise installs and verifies the selected Linux x86-64 runtime release, then caches the installation before running it. When a workflow needs macOS, the plugin also downloads and verifies the matching macOS arm64 runtime release.

Jobs that use JavaScript actions need `mise` 2026.5.12 or later. The runtime checks `BUILDKITE_GHA_MISE`, then `PATH`, and downloads and verifies a managed copy if neither provides a compatible version. A runtime image doesn't remove this requirement. Shell-only jobs and jobs that use only native adapters or Docker don't need `mise`. The `validate` and `compile` commands don't need it either.

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

The importer step and generated jobs have different host, tooling, network, and caching requirements.

### Importer step requirements

Before it can download the runtime and create the workflow jobs, the importer step needs:

- A Linux x86-64 agent.
- Buildkite agent v3.34.1 or later in the v3 release series. Agent v4 isn't supported because the runtime uses the `--reject-secrets` option, which Agent v4 doesn't provide.
- Bash, `cp`, `curl`, `mktemp`, `sha256sum`, and `tar`. The download tools are used only when a compatible `mise` isn't already on `PATH`.
- Git when `BUILDKITE_COMMIT` isn't already a full commit SHA.
- Outbound HTTPS access to public GitHub release and action sources.

### Generated job requirements

Generated jobs need Buildkite agent v3.130.0 or later and a Linux x86-64 or native macOS arm64 execution environment. Linux jobs can run on [Buildkite hosted agents](/docs/agent/buildkite-hosted), the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s), or other self-hosted agents that provide the tools used by the workflow. macOS jobs require a native macOS arm64 queue. The runtime tells the agent to skip its usual repository checkout so that it can prepare the workflow's workspace instead.

Every generated-job host needs Bash, `buildkite-agent`, `mktemp`, `rm`, `awk`, `chmod`, and either `sha256sum` or `shasum -a 256`. Depending on the workflow, it also needs:

- `git` available on `PATH` for `actions/checkout`.
- Docker and Docker Buildx available on `PATH` for Dockerfile actions on Linux. The default Buildx builder must use the local `docker` driver. macOS jobs don't support Dockerfile actions or other Docker capabilities.
- `tar` and either the `zstd` tool suite or `gzip` available on `PATH` for `actions/cache`.

Generated Linux jobs use the pipeline or organization's default agents unless you configure `runners`. Add one entry for each GitHub runner label that you want to map to a Buildkite queue. macOS labels always require an explicit queue mapping.

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#latest:
          workflow: ".github/workflows/ci.yml"
          runners:
            - runs-on: "ubuntu-latest"
              queue: "hosted"
            - runs-on: "macos-14"
              queue: "gha-macos-arm64"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Each entry requires `runs-on` and `queue`. A configured Ubuntu label uses the runtime's pinned default toolchain image unless you set `image` to another lowercase registry reference pinned to an immutable SHA-256 digest. The image must provide `/opt/hostedtoolcache`. Images are supported only on Buildkite hosted agents or Agent Stack for Kubernetes controller v0.30.0 or later. For other self-hosted Linux agents, omit the runner mapping and use the pipeline or organization's default agent targeting. macOS entries don't support `image`.

Because these queues can run untrusted workflow code, they must provide whole-job isolation, no ambient protected credentials, and a clean machine for each untrusted job. Persistent self-hosted agents can expose host resources and state left by earlier jobs.

The generated jobs also need network access for anything they download at runtime:

- Jobs that use public GitHub Actions need outbound HTTPS access to `codeload.github.com`, where the runtime downloads each action's source archive.
- Jobs that use JavaScript actions need outbound HTTPS access to the managed Node.js and `mise` download sources. Actions that declare `node16` run on managed Node 16.20.2 and produce a deprecation warning. Actions that declare `node20` or `node24` run on managed Node 24.18.0. On Linux, managed Node binaries require glibc 2.28 or newer. Shell-only workflows don't have this glibc requirement.

When resolving a mutable tag or branch for a public action, the importer uses a dedicated action-source token only for public GitHub metadata requests and reuses it across the selected workflows and nested composite actions. Metadata requests for the repository that triggered the build and action archive downloads from `codeload.github.com` remain anonymous. If the importer can't obtain the token, it reports a warning and retries anonymously. A lowercase, full 40-character commit SHA doesn't require an API request.

### Cache mise installations

On Buildkite hosted agents, attach a mise data cache to avoid reinstalling `mise` and `buildkite-gha`:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    cache: "/cache/bkcache/mise"
    plugins:
      - github-actions#latest:
          workflow: ".github/workflows/ci.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Without this volume, mise uses the agent or user data directory. Treat the mise data directory as executable state. Don't share it with untrusted jobs or principals that can modify it. This importer cache is separate from generated-job runtime caching and the workflow's `actions/cache` behavior.

A step generated by the [workflow picker](#add-a-github-actions-workflow-to-a-pipeline-detect-workflows-automatically) includes this cache automatically. Add it yourself when you configure the plugin manually or use the GitHub Actions template.

## Supported functionality and limitations

The preview supports an evolving subset of GitHub Actions. The following lists summarize common supported features and limitations:

- Linux x86-64 jobs using `ubuntu-latest`, `ubuntu-24.04`, or `ubuntu-22.04`, and native macOS arm64 jobs using `macos-latest`, `macos-15`, or `macos-14`. These labels identify a compatible platform, but don't give the agent the same tools, image layout, or Xcode installation as a GitHub-hosted runner.
- Bash and `sh` run steps.
- Static job dependencies and matrices, including `include` and `exclude`, up to 256 expanded instances per job.
- Supported job and step conditions, outputs, and timeouts, plus step-level `continue-on-error` behavior. Job-level `continue-on-error` supports literal Boolean values. A tolerated job failure remains visible as a Buildkite soft failure, but downstream jobs receive `success` through the `needs` context. Timeout cancellations and runtime infrastructure failures remain hard failures.
- Public JavaScript, composite, and local actions on Linux and macOS, plus compiler-verified Dockerfile actions on Linux.
- Local reusable workflows with statically resolvable inputs.
- `hashFiles()` in step conditions and top-level workflow step fields, including `run`, `env`, `with`, explicit `shell`, and explicit `working-directory`. The runtime evaluates the function against the workspace when each field is used. Job conditions and other compile-time fields don't support it.
- `actions/checkout` for a detached checkout of the event repository at the exact commit that triggered the build or a static branch. Checkout is anonymous for a public repository. For a private repository, it uses Buildkite's repository-provider Git credentials when they are enabled for the job and Buildkite authorizes the repository URL.
- Statically resolvable workflow- and job-level `concurrency`, mapped to repository-scoped Buildkite Pipelines concurrency groups.
- Native-backed `actions/upload-artifact` and `actions/download-artifact`, for the audited action revisions only.
- `actions/cache` for the audited revision, using the Buildkite Results service by default. The Buildkite organization must have GitHub Actions cache token minting enabled. Jobs must be able to reach the Results service and the Agent API.

The runtime rejects many unsupported or privileged features before it uploads any jobs. However, some unsupported settings are ignored rather than rejected. Important limitations include:

- GitHub Enterprise Server repositories, non-GitHub repository providers, private actions, and private reusable workflows.
- General workflow secrets, ambient `GITHUB_TOKEN`, alternate-repository checkout, tags, dynamic refs other than expressions that resolve to the exact event SHA, and GitHub-compatible OIDC, including `id-token`.
- Windows, Linux arm64, and macOS x86-64 jobs.
- Dockerfile actions and other Docker capabilities on macOS.
- Job and service containers. The runtime can run them, but the current production upload policy doesn't admit them.
- `docker://` actions, which the runtime rejects during validation.
- Dynamic matrices and remote reusable workflows.
- The matrix `strategy.fail-fast` setting. The runtime accepts this setting but doesn't enforce it, so a failed matrix job won't cancel the others. This differs from the GitHub Actions default. If `fail-fast` contains an expression, the workflow doesn't compile.
- Unaudited revisions of actions with native support, including checkout, artifacts, and cache.
- The complete `github.event` payload and GitHub-specific event behavior.

### Known preview gaps

You may need to update a workflow before you can run it during the preview:

- **Check `actions/upload-artifact` inputs.** The `path` input accepts up to 32 clean, workspace-relative literal files or directories, or bounded file globs using `*`, `?`, character classes, and recursive `**`. Path expressions are supported when their evaluated values follow the same rules. Exclusions, braces, extglobs, leading glob comments, absolute or traversing paths, symlinks, and special files aren't supported. Literal directories include regular-file descendants. A trailing `/` selects directories only, and hidden paths require `include-hidden-files`. The runtime accepts `retention-days` but treats it as advisory because Buildkite controls artifact retention. Each upload can contain up to 10,000 files, 1 GiB of source data, and a 1 GiB ZIP archive.

See the [`buildkite-gha` v0.13.11 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.13.11/docs/compatibility.md) for the supported functionality and limitations of the latest stable runtime covered by this page. If a feature isn't listed in the guide, treat it as unsupported.

> 🚧 Treat workflow code as build code
> All steps in an imported job share a workspace, environment changes, processes, and action lifecycle. Docker actions provide packaging, not a security boundary. Run imported jobs on a queue that provides whole-job isolation, no ambient protected credentials, and a clean machine for each untrusted job. Review the [`buildkite-gha` security model](https://github.com/buildkite/buildkite-gha/blob/v0.13.11/docs/security.md) for the complete trust boundaries.

### Concurrency

The runtime turns each static `concurrency` group into a case-insensitive Buildkite Pipelines concurrency group scoped to the repository. Workflow-level groups use ordered opening and closing gates, while job-level groups use a concurrency limit of one.

Workflow-level groups can use supported `github` fields and `vars`. Job-level groups can also use concrete `matrix` values and inputs from local reusable workflows when their values are known before the job runs. The workflow won't compile if a group can't be resolved, and workflow-level concurrency isn't supported inside a called reusable workflow.

Workflow-level `cancel-in-progress` accepts literal values and expressions that resolve statically to a Boolean value. A resolved `false` is accepted without a warning. A literal or statically resolved `true` produces a warning but doesn't cancel an older build. Job-level cancellation remains unsupported.

Buildkite queues every waiting entry, unlike GitHub's default behavior of replacing an existing pending entry. If you want similar cancellation behavior, turn on **Cancel Intermediate Builds** and **Skip Intermediate Builds** in the pipeline's build settings. These settings work by branch, so they match a workflow concurrency group only when its scope follows the same branch boundaries.

### Credentials and tokens

To check out the private repository that triggered the build, enable Buildkite's repository-provider Git credentials for the job. Buildkite must also authorize the repository URL. Without both, checkout is anonymous. This access doesn't provide `GITHUB_TOKEN` or `github.token`, and it can't be used for private actions or other repositories.

Buildkite can provide a short-lived token for the repository that triggered the build. The organization feature and the pipeline's workflow access token setting must both be enabled. The organization feature is off by default. The pipeline setting is also off by default when you configure the plugin manually. When you select workflows while creating a pipeline, Buildkite selects **Allow workflow-authorized GitHub access tokens** by default. Clear it before creating the pipeline if the workflows don't need tokens. The workflow picker for an existing pipeline doesn't change this setting. Configure it separately in the pipeline's GitHub settings.

The workflow file must be directly under `.github/workflows/` and have a simple `.yml` or `.yaml` filename. The job must either reference `secrets.GITHUB_TOKEN` directly or use an action whose default input references `github.token`.

If the workflow doesn't include a top-level `permissions` map, the token receives only `contents: read`, regardless of the GitHub repository or organization defaults. A non-empty top-level map replaces that default, while an empty map or a map containing only `none` doesn't produce a token. Job-level permission maps and reusable workflow jobs can't receive tokens. Pull request builds and their triggered or rebuilt descendants can't receive more than `contents: read`. Merge queue builds and their descendants can't receive a token. The runtime doesn't add the token to the job's initial environment, although an action can make it available to later steps through `GITHUB_ENV`, as it can on a GitHub runner. General workflow secrets and an ambient `GITHUB_TOKEN` aren't available.

Each job can request up to 10 workflow access tokens per hour. Requests beyond this limit receive a `429 Too Many Requests` response with a `Retry-After` header, and no token is issued. This limit is tracked separately for each job.

> 🚧 Protect tokens in trusted branch and manual builds
> For builds outside pull requests and merge queues, a user who can create a build at an arbitrary commit may select code that requests the workflow's allowed permissions. Enable write tokens only when branch builds and other build-creation paths run trusted code.

## Troubleshooting

Start with the Buildkite annotation. Its concise heading and message identify the user-visible cause and a corrective action or compatibility link. Expand **Diagnostic detail** for lower-level evidence, including resolved commits, adapter, service, and admission boundaries, and complete supported-value lists. Provider check summaries show concise guidance only.

Safe workflow-specific compilation and trigger-translation failures become failing top-level replacement steps. Other valid workflows continue. Parse, event-input, admission, artifact, and upload failures abort the transaction.

### The importer reports path filters are unsupported

The compatibility runtime rejects `paths` and `paths-ignore` under `push` and `pull_request` because Buildkite Pipelines `if_changed` has different semantics. A path filter replaces the affected workflow with a failing top-level step. Remove these filters before importing the workflow. Without them, the workflow may run for changes that GitHub Actions would have skipped.

The [Buildkite pipeline converter](/docs/pipelines/converter/github-actions) is a separate tool that generates native pipeline configuration and can translate path filtering to `if_changed`.

### No workflow jobs appear

Check that each selected path is an explicit, tracked `.yml` or `.yaml` file. Also check that the workflow declares the event represented by the Buildkite build. A workflow that doesn't declare the effective event appears as a top-level skipped step and in the importer-scoped informational annotation. If no selected workflows declare the event, the generated pipeline contains only skipped steps.

A reusable workflow whose only trigger is `workflow_call` doesn't create its own group. Selecting only reusable workflows produces an error, but a reusable workflow can support another selected workflow. Buildkite webhook and schedule settings create builds. The workflow's `on` configuration determines whether a group is eligible after a build exists.

### The workflow picker shows a repository access notice

If Buildkite doesn't have code access to the selected repository, the workflow picker doesn't try to detect workflows. Instead, the picker shows a notice with a **Manage GitHub access** link. This notice means that the repository uses a **GitHub (Limited Access)** connection, which can't provide code access. Connect the repository using the full-access [**GitHub** repository provider](/docs/pipelines/source-control/github#github-repository-provider-options), then select it in the repository picker. If a repository is missing from an existing full-access GitHub App installation, select **GitHub settings** in the repository picker to add it.

When you create a new pipeline, other scan failures show a notice with a **Try again** option. Select **Try again** to retry the scan without reloading the page.

### Private checkout or a GitHub token is unavailable

Private checkout and workflow access tokens use separate settings. For private checkout, enable Buildkite repository-provider Git credentials for the job and authorize the repository URL. For a temporary GitHub token, enable the organization feature and the pipeline's workflow access token setting. Then make sure the workflow uses a supported static token reference. Review the [credentials and tokens](#supported-functionality-and-limitations-credentials-and-tokens) restrictions before enabling write permissions.

### Validate a workflow locally

For most workflows, use the plugin. If you need more control or want to diagnose a problem, you can download the `buildkite-gha` binary from the [`buildkite-gha` releases](https://github.com/buildkite/buildkite-gha/releases).

After downloading the release archive, verify it against the published checksums. You can then check a workflow's syntax and static job graph without running it:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

To resolve actions and apply the production upload policy, provide an event snapshot and the production profile:

```bash
buildkite-gha validate \
  --profile hosted \
  --event-path event.json \
  .github/workflows/ci.yml
```

The CLI also provides `compile` and `upload` commands. Pass one or more explicit workflow paths to `upload`, with each path as a separate argument:

```bash
buildkite-gha upload \
  --runner-queue ubuntu-latest=hosted \
  --runner-queue macos-14=gha-macos-arm64 \
  --runtime-distribution darwin/arm64=/opt/buildkite-gha-darwin \
  -- \
  .github/workflows/ci.yml \
  .github/workflows/release.yml
```

The `--` separator is required when a path begins with `-`.

The `validate` and `compile` commands don't need `mise` and don't run workflow code. Each command produces a processing report with the status of each validation and generation stage. Use `validate --format json` for a machine-readable `buildkite-gha/processing-report/v2` report. In each diagnostic, `message` provides actionable guidance, optional `detail` provides lower-level evidence, and the stable diagnostic `code`, `stage`, and `location` remain separate. Use the versioned compatibility guide as the authority for compatibility rules.

The `compile` command writes its report to standard error, while `upload` writes it to the importer job log. When these commands run in a Buildkite job, they also publish processing warnings and errors as job-scoped annotations. A failure to publish an annotation produces a warning but doesn't change the command result. Stages blocked by an earlier failure are reported as `not-evaluated`, not `failed`. If a required stage fails, the runtime doesn't publish plans or pipeline output.

Run `upload` from a keyed Buildkite Pipelines command step so that the `BUILDKITE` and `BUILDKITE_STEP_KEY` environment variables are available. The step must use Buildkite agent v3.34.1 or later in the v3 release series; Agent v4 isn't supported.

As with the plugin, generated jobs manage their own `mise` setup only when their actions need it. For a custom importer, use repeatable `--runner-queue` options to map runner labels to queues. Linux mappings can use `--runner-image` with an immutable image digest. The importer executable provides the Linux runtime by default. To run macOS jobs, provide the macOS arm64 runtime with `--runtime-distribution`. The plugin handles the runtime downloads and applies your `runners` configuration for you, which is why it's the best option for most workflows.

## Next steps

- Learn how to [migrate from GitHub Actions](/docs/pipelines/migration/from-githubactions).
- [Translate a GitHub Actions workflow](/docs/pipelines/converter/github-actions) to native Buildkite Pipelines configuration.
- Learn more about [using plugins](/docs/pipelines/integrations/plugins/using).
