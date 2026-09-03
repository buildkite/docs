---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs in this public preview of the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

> 📘 Public preview
> Running GitHub Actions workflows in Buildkite is currently in public preview. To report issues with the preview, [open an issue in the `buildkite-gha` repository](https://github.com/buildkite/buildkite-gha/issues). For help migrating to native Buildkite Pipelines steps, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).
> The plugin and runtime are under active development. Review the [`buildkite-gha` v0.44.2 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.44.2/docs/compatibility.md) before adding a workflow.

The GitHub Actions Buildkite plugin runs supported GitHub Actions workflows as Buildkite Pipelines jobs. This lets you migrate a workflow with minimal changes, then replace imported jobs with [native Buildkite Pipelines steps](/docs/pipelines/migration/from-githubactions) over time.

During the preview, start with a simple workflow in a public `github.com` repository that targets Linux x86-64. Private repository checkout, statically named Buildkite secrets, temporary GitHub tokens, and OIDC require additional setup. Review the [supported functionality and limitations](#supported-functionality-and-limitations) before you begin.

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

Opening the panel doesn't change the pipeline configuration until you select a workflow. A workflow is selectable when at least one of its declared triggers can start a Buildkite build. `push`, `pull_request`, `workflow_dispatch`, `schedule`, `merge_group`, and a `release` trigger with a supported activity type always qualify. A trigger that can't start a build, such as `workflow_call` on its own, is struck through in the workflow's trigger list, with a tooltip explaining why. A workflow whose triggers are all like this shows a **Not directly runnable** badge and can't be selected. A workflow that mixes build-starting and other triggers stays selectable and shows a **Partially supported** badge. Selecting all workflows adds each selectable workflow path explicitly.

Selecting a workflow that declares `merge_group` or a supported `release` activity type also turns on the matching GitHub webhook setting for the pipeline, such as **Build merge queues**, so builds can start without further configuration. This applies whether you're creating a new pipeline or adding workflows to an existing one. A `release` trigger must declare a non-empty `types` list containing only `created`, `published`, or `released`, with no branch, tag, or path filters. A workflow with any other `release` declaration remains unavailable, because `buildkite-gha` can't compile it.

For organizations in the private preview for [issue activity builds](/docs/pipelines/source-control/github#running-builds-on-additional-github-events-running-builds-on-issue-activity), workflows that declare the `issues` event are also selectable. Selecting one while creating a pipeline enables **Build on GitHub issue activity** for the new pipeline.

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
    agents:
      queue: "importer-linux"
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
    agents:
      queue: "importer-linux"
    plugins:
      - github-actions#latest:
          workflows:
            - ".github/workflows/ci.yml"
            - ".github/workflows/release.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Use either `workflow` or `workflows`, but not both. Each present path must identify a regular, tracked `.yml` or `.yaml` file inside the repository. Missing or untracked paths produce a warning and are skipped. If every configured path is missing or untracked, the importer succeeds without uploading a pipeline. Directories, tracked files missing from the checkout, globs, symlinks, and paths outside the repository cause the import to fail.

When this step runs, the plugin turns the workflows into a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines). Each successfully compiled, directly runnable workflow becomes a group that depends on the plugin step. The generated jobs appear inside the group. A safe workflow-specific compilation or trigger-translation failure becomes a failing top-level replacement step. Other valid workflows continue. Parse, event-input, admission, artifact, and upload failures abort the transaction.

The plugin supports the following configuration:

| Property | Required | Description |
| --- | --- | --- |
| `workflow` | One selector is required | Path to one GitHub Actions workflow in the repository. |
| `workflows` | One selector is required | Array of paths to GitHub Actions workflows in the repository. |
| `version` | No | Latest stable or an exact `buildkite-gha` runtime release from `0.9.0` onward. The default is `latest`. |
| `source-ref` | No | Full lowercase 40-character runtime commit for testing unreleased changes. This property can't be used with `version`. |
| `minimum-release-age` | No | Minimum release age used by `mise` when resolving `latest`. The default is `0s`. |
| `experimental-runner-user` | No | Run generated Linux jobs as a dedicated `runner` user. The default is `true`. Set this property to `false` only as a temporary compatibility measure. |
| `oidc` | No | Buildkite OIDC token options for jobs that declare `permissions: id-token: write`. |
| `runners` | No | Explicit mappings from GitHub runner labels to Buildkite queues, optional Linux images, and optional Buildkite hosted cache volumes. A mapped selector bypasses Agent API runner resolution. |
{: class="responsive-table"}

The Git ref after `github-actions#` selects the plugin code. This is separate from `version`, which selects the `buildkite-gha` runtime. Use a specific plugin release, such as `github-actions#v0.13.0`, and an exact runtime `version` when you need immutable version selection.

By default, Buildkite Pipelines decides when the pipeline runs, so the workflow's `on` key doesn't create build triggers. Set up GitHub triggers and schedules in Buildkite Pipelines, or start a build yourself by selecting **New Build** or using the REST API. Within an existing build, the `on` key determines whether each selected workflow is eligible to run. The private-preview [GitHub Actions pipeline trigger](#add-a-github-actions-workflow-to-a-pipeline-trigger-builds-from-workflow-events) can create a build for a supported `push` or `pull_request` declaration.

For manual and scheduled builds, the plugin automatically finds the exact commit after checkout.

The plugin gives each workflow a GitHub event type based on how the Buildkite build started:

- Pull request builds receive `pull_request`.
- Verified merge queue builds receive `merge_group`.
- Verified release builds receive `release`.
- Verified issue activity builds receive `issues`.
- Builds started from the Buildkite interface or API receive `workflow_dispatch`.
- Scheduled builds receive `schedule`.
- Other builds, including branch, tag, and triggered builds, receive `push`.

Pull request builds check out and run against the head commit of the pull request branch (`refs/pull/<N>/head`). This matches how [Buildkite Pipelines handles pull request builds by default](/docs/pipelines/source-control/github#running-builds-on-pull-requests-building-the-test-merge-commit), and applies even before GitHub finishes computing the pull request's merge commit.

Release workflows require the GitHub Releases additional webhook, the **Code** trigger mode, and a supported `published`, `created`, or `released` activity type. With the full-access **GitHub** repository provider, Buildkite Pipelines resolves the release tag to its immutable commit before creating the build. Without this access, the plugin can use the checked-out `HEAD` as a compatibility fallback, but the build can't receive a workflow access token for the release.

Issue workflows require the private-preview [issue activity build setting](/docs/pipelines/source-control/github#running-builds-on-additional-github-events-running-builds-on-issue-activity). A bare `issues` trigger accepts every supported activity type. You can also list supported GitHub issue activity types explicitly. Branch, tag, path, and workflow filters aren't supported for this event.

Each successfully compiled workflow that declares the effective event becomes a group named for the workflow. A supported, non-empty `run-name` is appended to the group label, but doesn't change the build message or external check name. The external check identifies both the workflow and effective event. A workflow that doesn't declare the effective event becomes a top-level skipped step. After upload, an importer-scoped informational annotation lists skipped workflows. A local reusable workflow that declares only `workflow_call` can support another selected workflow, but doesn't create its own group.

The runtime supports branch, tag, and bounded path filters for `push`, and base-branch, activity type, and bounded path filters for `pull_request`. Path filters require a verified linked GitHub webhook and complete matching diff evidence from the local checkout. If that evidence is missing or uncertain, the affected workflow fails instead of running more broadly. For `merge_group`, `paths` and `paths-ignore` are accepted but ignored with a warning, matching GitHub behavior. Every workflow that declares `schedule` is eligible for every Buildkite scheduled build.

### Trigger builds from workflow events

> 📘 Private preview
> GitHub Actions pipeline triggers are in private preview and available only to selected Buildkite organizations. Contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com) for access.

A GitHub Actions pipeline trigger reads workflow files for each incoming GitHub webhook and creates a Buildkite Pipelines build when a supported `on` declaration matches. This trigger is separate from the plugin. The trigger decides whether to create a build, then the plugin independently determines which configured workflows are eligible within that build.

To configure the trigger for an enabled organization:

1. Use a GitHub.com pipeline connected using the full-access [**GitHub** repository provider](/docs/pipelines/source-control/github#github-repository-provider-options).
1. From the pipeline, select **Pipeline settings** > **Triggers** > **New Trigger**.
1. Select **GitHub Actions**, add a description, then create the trigger.
1. Copy the generated delivery URL into a GitHub repository webhook. Select the `push` and `pull_request` events, and use the `application/json` content type.
1. In the trigger's **Security** settings, select **Validate webhook deliveries**. Configure the same webhook secret in Buildkite and GitHub.

The trigger supports branch and tag pushes, plus same-repository pull requests. It supports `branches`, `branches-ignore`, `tags`, and `tags-ignore`. Without an explicit `types` filter, a pull request workflow triggers on the `opened`, `reopened`, and `synchronize` activity types. A pull request workflow can also use `types` to trigger explicitly on the `ready_for_review`, `labeled`, `review_request_removed`, `milestoned`, `unassigned`, `enqueued`, or `closed` activity types. Pull request builds use the head branch and commit, while `GITHUB_WORKFLOW_REF` identifies `refs/pull/<N>/merge`. Fork pull requests, path filters, unsupported events or activity types, and unsupported filter patterns fail closed and appear in **Recent Deliveries**.

For each webhook, the trigger sorts top-level workflow files under `.github/workflows/` by path and creates one build for the first matching workflow. Configure the plugin for that workflow path when you want only the matched workflow to run. If the plugin selects multiple workflows, the runtime can run every selected workflow that independently matches the event.

## Migrate incrementally

You don't have to convert the whole workflow at once. Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. In this example, the native `Deploy` step waits for all the imported test jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    agents:
      queue: "importer-linux"
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

You don't need to install `mise` or `buildkite-gha` yourself. The plugin uses a compatible `mise` from `PATH` or installs a pinned, verified copy. Mise installs and verifies the runtime release for the importer's Linux x86-64 or macOS arm64 host, then caches the installation before running it. When a workflow needs the other supported platform, the plugin downloads and verifies the matching runtime from the same release.

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

- A Linux x86-64 or native macOS arm64 agent selected explicitly by the importer step's `agents` configuration. The plugin's `runners` configuration doesn't schedule the importer.
- Buildkite agent v3.129.0 or later in the v3 release series. Agent v4 isn't supported because the runtime uses the `--reject-secrets` option, which Agent v4 doesn't provide.
- Bash, `cp`, `curl`, `mktemp`, `tar`, and either `sha256sum` on Linux or `shasum` on macOS. The download tools are used only when a compatible `mise` isn't already on `PATH`.
- Git when `BUILDKITE_COMMIT` isn't already a full commit SHA.
- Outbound HTTPS access to public GitHub release and action sources.

### Generated job requirements

Generated jobs need Buildkite agent v3.130.0 or later and a Linux x86-64 or native macOS arm64 execution environment. Linux jobs can run on [Buildkite hosted agents](/docs/agent/buildkite-hosted), the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s), or other self-hosted agents that provide the tools used by the workflow. macOS jobs require a native macOS arm64 queue. The runtime tells the agent to skip its usual repository checkout so that it can prepare the workflow's workspace instead.

Every generated-job host needs Bash, `buildkite-agent`, `mktemp`, `rm`, `awk`, `chmod`, and either `sha256sum` or `shasum -a 256`. Depending on the workflow, it also needs:

- `git` available on `PATH` for `actions/checkout`, plus Git LFS when the action sets `lfs: true`.
- Docker available on `PATH` for Linux job containers, service containers, and Dockerfile actions. Dockerfile actions also require Docker Buildx. The default Buildx builder must use the local `docker` driver. macOS jobs don't support Dockerfile actions or other Docker capabilities.
- `tar` and either the `zstd` tool suite or `gzip` available on `PATH` for `actions/cache`.

With the default dedicated `runner` user, generated Linux job hosts also need `getent`, `useradd`, `usermod`, `install`, and `sudo`. If the Docker socket exists and its group doesn't exist, the host also needs `groupadd`.

During upload, configured `runners` mappings bypass Agent API resolution. The runtime asks the job-scoped Agent API to resolve each remaining `runs-on` selector to a complete target: a queue, a platform, and, for Linux, an immutable image. Exact supported Ubuntu selectors (`ubuntu-latest`, `ubuntu-24.04`, and `ubuntu-22.04`) resolve to the hosted Linux queue with the matching Ubuntu image and no warning. Other selectors that look Linux-compatible, such as older `ubuntu-*` versions or custom self-hosted labels, resolve to the hosted Linux queue using the latest Ubuntu image. The job shows a warning annotation recommending an explicit runner mapping instead. These automatic hosted resolutions require an eligible Buildkite hosted `linux-medium` Linux AMD64 queue in the job's cluster. Without that queue, selectors that don't have a runtime preset, including older Ubuntu selectors, require an explicit mapping. Selectors for clearly incompatible operating systems, such as Windows or non-native macOS, or for non-AMD64 architectures, still fail closed with an unmapped labels error.

For macOS, `macos-latest` resolves to `macos-medium`. The versioned `macos-14`, `macos-15`, `macos-26`, and `macos-27` labels resolve to the matching `macos-<version>-medium` queue when it exists in the job's cluster, then fall back to `macos-medium`. New Buildkite organizations include these four versioned queues, but they aren't automatically added to existing organizations. If neither suitable queue exists, add an explicit mapping. Every macOS target is native arm64. These labels don't guarantee the same operating system, installed software, or Xcode versions as GitHub-hosted runners, particularly when a versioned label falls back to `macos-medium`.

An Agent API result takes precedence over runtime presets. Add a `runners` entry to map a GitHub runner label explicitly to a Buildkite queue, select a pinned macOS version using a versioned queue, or avoid fallback warnings.

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    agents:
      queue: "importer-linux"
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

Generated Linux jobs run as a dedicated `runner` user by default. The generated job must start as root so the runtime can create this account. The `runner` user can use `sudo` without a password and access the Docker socket when it exists, so the account isn't a security boundary. Set `experimental-runner-user: false` only as a temporary compatibility measure for workflows that require root execution.

Because these queues can run untrusted workflow code, they must provide whole-job isolation, no ambient protected credentials, and a clean machine for each untrusted job. Persistent self-hosted agents can expose host resources and state left by earlier jobs.

The generated jobs also need network access for anything they download at runtime:

- Jobs that use public GitHub Actions need outbound HTTPS access to `codeload.github.com`, where the runtime downloads each action's source archive.
- Jobs that use JavaScript actions need outbound HTTPS access to the managed Node.js and `mise` download sources. Actions that declare `node16` run on managed Node 16.20.2 and produce a deprecation warning. Actions that declare `node20` or `node24` run on managed Node 24.18.0. On Linux, managed Node binaries require glibc 2.28 or newer. Shell-only workflows don't have this glibc requirement.

When resolving a mutable tag or branch for a public action, the importer uses a dedicated action-source token only for public GitHub metadata requests and reuses it across the selected workflows and nested composite actions. Metadata requests for the repository that triggered the build and action archive downloads from `codeload.github.com` remain anonymous. If the importer can't obtain the token, it reports a warning and retries anonymously. A lowercase, full 40-character commit SHA doesn't require an API request.

### Cache generated-job directories

An explicit Linux `runners` mapping can attach one [Buildkite hosted cache volume](/docs/agent/buildkite-hosted/cache-volumes) to every generated job that uses the mapping:

```yaml
plugins:
  - github-actions#latest:
      workflow: ".github/workflows/ci.yml"
      runners:
        - runs-on: "ubuntu-latest"
          queue: "hosted"
          cache:
            paths:
              - "/home/runner/.gradle/caches"
              - "/home/runner/.gradle/wrapper"
            name: "gradle-${BUILDKITE_BRANCH}"
            size: "40g"
```
{: codeblock-file=".buildkite/pipeline.yml"}

The `paths` array is required and must contain unique absolute paths. The `name` and `size` attributes are optional. Cache volume sizes must be at least `20g`. Generated jobs that use a job container can't use this cache configuration.

Cache volumes are best-effort, pipeline- and cluster-scoped accelerators that are committed only after successful jobs. Treat their contents as untrusted executable state, and don't use them as durable storage. This cache is separate from the importer step's mise cache and the workflow's `actions/cache` behavior.

### Cache mise installations

On Buildkite hosted agents, attach a mise data cache to avoid reinstalling `mise` and `buildkite-gha`:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    agents:
      queue: "importer-linux"
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

- Linux x86-64 jobs using `ubuntu-latest`, `ubuntu-24.04`, or `ubuntu-22.04`, and native macOS arm64 jobs using `macos-latest`, `macos-14`, `macos-15`, `macos-26`, or `macos-27`. These labels identify a compatible platform, but don't give the agent the same tools, image layout, operating system, or Xcode installation as a GitHub-hosted runner. Other `runs-on` labels that look Linux-compatible, such as older Ubuntu versions, can use the latest supported Ubuntu image when the job's cluster has an eligible Buildkite hosted `linux-medium` Linux AMD64 queue. The job shows a warning annotation recommending an explicit runner mapping. Without an eligible queue, these labels require an explicit mapping. Labels for other operating systems or non-AMD64 architectures aren't supported.
- Bash, `sh`, `python`, and custom shell template run steps when the selected command is available on `PATH`. PowerShell and Windows shells aren't supported.
- Static job dependencies and matrices, including `include`, `exclude`, and compile-time expressions such as `fromJSON()`, up to 256 expanded instances per job.
- Supported job and step conditions, outputs, and timeouts. Step-level `continue-on-error` and `timeout-minutes` can use expressions that resolve to a Boolean value or a number greater than zero and no more than 360. Job-level forms accept literal values only. A tolerated job failure remains visible as a Buildkite soft failure, but downstream jobs receive `success` through the `needs` context. Timeout cancellations and runtime infrastructure failures remain hard failures.
- Public JavaScript, composite, and local actions on Linux and macOS, plus compiler-verified Dockerfile and public prebuilt-image actions on Linux. Prebuilt images are pulled anonymously. Pin the image by digest because a mutable tag can resolve to different content for each job.
- Local and literal public reusable workflows, up to four nesting levels. String inputs can use an exact `${{ needs.<job>.outputs.<name> }}` expression from a direct dependency. Local calls can use one-hop `secrets: inherit` when each nested call repeats it, or explicitly map a declared alias from one direct secret reference.
- Linux job and service containers, including compile-time container image expressions and supported health checks, registry credentials, ports, volumes, and the `job.services` context.
- `hashFiles()` in workflow step fields, step conditions, and JavaScript action lifecycle conditions. Each call accepts up to 255 patterns, scans up to 100,000 workspace entries, matches up to 10,000 files, and reads up to 1 GiB. It doesn't hash or follow symlinks. Multi-file hashes can differ from GitHub because this runtime uses lexical path order.
- `toJSON(github)` in supported step runtime fields. The runtime returns only its bounded GitHub context, applies normal `GITHUB_TOKEN` authorization, and redacts the token from logs and workflow outputs.
- Direct, projected, whole, and dynamically indexed `github.event` access. Jobs that need a whole, projected, or dynamically selected value load a digest-verified event payload artifact from the importer.
- `github.workspace`, `github.run_id`, `github.run_number`, and `github.run_attempt`, with matching `GITHUB_WORKSPACE`, `GITHUB_RUN_ID`, `GITHUB_RUN_NUMBER`, and `GITHUB_RUN_ATTEMPT` environment variables. Run identity values represent the Buildkite build ID, build number, and retry count plus one. They don't identify a GitHub Actions run or work in GitHub run URLs and APIs.
- `actions/checkout` for a detached checkout of the event repository at the exact commit that triggered the build or a static branch. Supported inputs include nested paths, partial clone filters, sparse checkout, Git LFS, and submodules. Checkout is anonymous for a public repository. For a private repository, it uses Buildkite's repository-provider Git credentials when they are enabled for the job and Buildkite authorizes the repository URL.
- Statically resolvable workflow- and job-level `concurrency`, including workflow-level concurrency in local and public called workflows. The runtime maps groups to repository-scoped Buildkite Pipelines concurrency groups.
- Native-backed `actions/upload-artifact` and `actions/download-artifact` for known revisions. An unknown lowercase, full 40-character commit uses the current bounded adapter contract and produces a warning instead of running the action's JavaScript.
- `actions/cache` for the audited revision, using the Buildkite Results service by default. The Buildkite organization must have GitHub Actions cache token minting enabled. Jobs must be able to reach the Results service and the Agent API. Buildkite mints a fresh cache token for each action phase, valid for up to six hours or the organization's [maximum OIDC lifetime](/docs/platform/limits#platform-and-organization-level-limits) quota, whichever is lower.
- Statically named Buildkite secrets in direct jobs and in local reusable workflow jobs using `secrets: inherit` or explicit declared-alias mappings.
- Opt-in temporary `GITHUB_TOKEN` and Buildkite-issued OIDC tokens within the documented authority boundaries.

> 🚧 Event payload artifacts are readable
> An event payload artifact can be up to 25 MiB and follows the Buildkite build's artifact access and retention settings. The payload isn't redacted or a secret store. Anyone who can download the artifact can read its user-provided values. Tokens, resolved secrets, OIDC credentials, registry credentials, and internal admission data aren't added to it.

The runtime rejects many unsupported or privileged features before it uploads any jobs. However, some unsupported settings are ignored rather than rejected. Important limitations include:

- GitHub Enterprise Server repositories, non-GitHub repository providers, private actions, and private reusable workflows.
- GitHub repository and environment secrets, ambient `GITHUB_TOKEN`, alternate-repository checkout, tags, and arbitrary dynamic checkout commits.
- Windows, Linux arm64, and macOS x86-64 jobs.
- Dockerfile actions, job containers, service containers, and other Docker capabilities on macOS.
- Direct workflow `uses: docker://...` steps, private prebuilt action images, and ambient Docker registry credentials.
- Runtime matrices derived from `needs` or step outputs, private reusable workflows, and dynamically selected reusable workflows.
- GitHub environments, approvals, environment secrets, deployment records, and protection rules.
- The matrix `strategy.fail-fast` setting. The runtime accepts this setting but doesn't enforce it, so a failed matrix job won't cancel the others. This differs from the GitHub Actions default. If `fail-fast` contains an expression, the workflow doesn't compile.
- Unlisted revisions of `actions/cache`. Unknown immutable checkout and upload artifact commits use the v7.0.1 contract, while unknown immutable download artifact commits use the v8.0.1 contract. These warning-producing fallbacks can differ from the action's actual manifest.
- The complete GitHub context and general emulation of GitHub services such as Packages, Releases, Checks, deployments, and GitHub artifact APIs.

### Known preview gaps

You may need to update a workflow before you can run it during the preview:

- **Check the `actions/upload-artifact` revision and inputs:** The native adapter supports known revisions from v1 through v7. An unknown lowercase, full 40-character commit uses the v7.0.1 contract with a warning. Known unsupported revisions, including v3.2.2, remain rejected. The v1 adapter accepts one literal file or directory. Later adapters accept up to 32 clean, workspace-relative literal paths or bounded file globs using `*`, `?`, character classes, and recursive `**`. Exclusions, braces, extglobs, leading glob comments, absolute or traversing paths, symlinks, and special files aren't supported. Hidden-file behavior and accepted inputs depend on the action revision. The runtime accepts `retention-days` where the action declares it, but treats the value as advisory because Buildkite controls artifact retention. Each upload can contain up to 10,000 files, 1 GiB of source data, and a 1 GiB ZIP archive.

See the [`buildkite-gha` v0.44.2 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.44.2/docs/compatibility.md) for the supported functionality and limitations of the latest stable runtime covered by this page. If a feature isn't listed in the guide, treat it as unsupported.

> 🚧 Treat workflow code as build code
> All steps in an imported job share a workspace, environment changes, processes, and action lifecycle. Docker actions and containers provide packaging, not a security boundary. Run imported jobs on a queue that provides whole-job isolation, no ambient protected credentials, a clean machine for each untrusted job, and host-level resource limits. Review the [`buildkite-gha` v0.44.2 security model](https://github.com/buildkite/buildkite-gha/blob/v0.44.2/docs/security.md) for the complete trust boundaries.

### Concurrency

The runtime turns each static `concurrency` group into a case-insensitive Buildkite Pipelines concurrency group scoped to the repository. Workflow-level groups use ordered opening and closing gates, while job-level groups use a concurrency limit of one.

Workflow-level groups can use supported `github` fields, `vars`, and static inputs in a called workflow. Job-level groups can also use concrete `matrix` values. Local and public called workflows retain their workflow-level concurrency gates, including nested gates. Each static call-matrix instance gets its own gate.

The workflow won't compile if a group can't be resolved. Called-workflow concurrency also isn't supported when the call uses `if` or `needs`, or when a job or nested call reuses an enclosing workflow's concurrency group.

Workflow-level `cancel-in-progress` accepts literal values and expressions that resolve statically to a Boolean value. A resolved `false` is accepted without a warning. A literal or statically resolved `true` produces a warning but doesn't cancel an older build. Job-level cancellation remains unsupported.

Buildkite queues every waiting entry, unlike GitHub's default behavior of replacing an existing pending entry. If you want similar cancellation behavior, turn on **Cancel Intermediate Builds** and **Skip Intermediate Builds** in the pipeline's build settings. These settings work by branch, so they match a workflow concurrency group only when its scope follows the same branch boundaries.

### Credentials, secrets, and OIDC

To check out the private repository that triggered the build, enable Buildkite's repository-provider Git credentials for the job. Buildkite must also authorize the repository URL. Without both, checkout is anonymous. This access doesn't provide `GITHUB_TOKEN` or `github.token`, and it can't be used for private actions or other repositories.

Direct jobs can use statically named `${{ secrets.NAME }}` references. Local reusable-workflow calls can pass secret authority using one-hop `secrets: inherit`, which each nested call must repeat. A local call can instead map an alias declared by the called workflow from one direct `${{ secrets.NAME }}` or `${{ secrets['NAME'] }}` reference. Every required alias must be mapped, and an unmapped optional alias is empty. The runtime retrieves each value using the generated job's Buildkite secret access policy. Dynamic secret names, literal or compound mappings, and secret forwarding to public reusable workflows aren't supported. These values are Buildkite secrets, not GitHub repository, environment, event, or fork-scoped secrets.

Buildkite can provide a short-lived token for the repository that triggered the build. The pipeline's workflow access token setting must be enabled. The setting is off by default when you configure the plugin manually. When you select workflows while creating a pipeline, Buildkite selects **Allow workflow-authorized GitHub access tokens** by default. Clear it before creating the pipeline if the workflows don't need tokens. The workflow picker for an existing pipeline doesn't change this setting. Configure it separately in the pipeline's GitHub settings.

During the preview, the Buildkite organization must also have GitHub scoped access token minting enabled. Contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com) to enable it for your organization.

The workflow file must be directly under `.github/workflows/` and have a simple `.yml` or `.yaml` filename. The job must either reference `secrets.GITHUB_TOKEN` directly or use an action whose default input references `github.token`.

If the workflow doesn't include top-level `permissions`, the token receives only `contents: read`, regardless of the GitHub repository or organization defaults. A non-empty top-level permissions map replaces that default. The `read-all` alias expands to every supported read permission. The `write-all` alias isn't supported and causes the token request to be denied. An empty map or a map containing only `none` doesn't produce a token. Job-level repository permission maps don't change the token scope. A job expanded from a local reusable workflow can receive a token, but its repository permissions always come from the top-level requesting workflow. The separate job-level `id-token` permission retains its documented behavior. Pull request builds and their triggered or rebuilt descendants can't receive more than `contents: read`. Merge queue builds and their descendants can't receive a token. The runtime doesn't add the token to the job's initial environment, although an action can make it available to later steps through `GITHUB_ENV`, as it can on a GitHub runner. An ambient `GITHUB_TOKEN` isn't available.

Each job can request up to 10 workflow access tokens per hour. Requests beyond this limit receive a `429 Too Many Requests` response with a `Retry-After` header, and no token is issued. This limit is tracked separately for each job.

> 🚧 Protect tokens in trusted branch and manual builds
> For builds outside pull requests and merge queues, a user who can create a build at an arbitrary commit may select code that requests the workflow's allowed permissions. Enable write tokens only when branch builds and other build-creation paths run trusted code.

For OIDC, the workflow job must declare `permissions: id-token: write`. Configure the plugin with the Buildkite claims that your identity provider accepts:

```yaml
plugins:
  - github-actions#latest:
      workflow: ".github/workflows/deploy.yml"
      oidc:
        claims:
          - "organization_id"
        aws-session-tags:
          - "organization_slug"
          - "pipeline_id"
        subject-claim: "pipeline_id"
```

These OIDC tokens use the Buildkite issuer and claims, not the GitHub issuer. Host JavaScript actions, including JavaScript actions called by composite actions, can request them. Shell steps, Docker actions, and actions in job containers can't request OIDC tokens. The `oidc` plugin configuration doesn't grant access to a job that omits `permissions: id-token: write`.

## Troubleshooting

Start with the Buildkite annotation. Its concise heading and message identify the user-visible cause and a corrective action or compatibility link. Expand **Diagnostic detail** for lower-level evidence, including resolved commits, adapter, service, and admission boundaries, and complete supported-value lists. Provider check summaries show concise guidance only.

Safe workflow-specific compilation and trigger-translation failures become failing top-level replacement steps. Other valid workflows continue. Parse, event-input, admission, artifact, and upload failures abort the transaction.

### The importer can't verify path filters

The compatibility runtime supports bounded `paths` and `paths-ignore` filters for branch pushes and pull requests. The build must have a verified linked GitHub webhook, and the local checkout must provide complete diff evidence that matches the webhook. Generated or explicit event snapshots can't provide this evidence. Missing, shallow, mismatched, or uncertain evidence replaces the affected workflow with a failing top-level step instead of broadening when it runs.

Check that the pipeline receives the original GitHub webhook and that the importer has a complete checkout of the relevant commits. If those requirements don't suit the pipeline, remove the filters or use the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions) to translate path filtering to native `if_changed` conditions.

### No workflow jobs appear

Check the importer log for missing or untracked workflow path warnings. The importer skips these paths. If every configured path is missing or untracked, the importer succeeds without uploading a pipeline.

Also check that the workflow declares the event represented by the Buildkite build. A workflow that doesn't declare the effective event appears as a top-level skipped step and in the importer-scoped informational annotation. If the importer reports `Uploaded 0 jobs from N workflows`, every selected workflow was skipped because it didn't match the effective event or its filters. For example, a workflow that declares only `pull_request` is skipped when the build represents a `push` event. Check the skipped top-level steps, then compare the effective event with the workflow's `on` trigger configuration.

A reusable workflow whose only trigger is `workflow_call` doesn't create its own group. Selecting only reusable workflows produces an error, but a reusable workflow can support another selected workflow. Buildkite webhook and schedule settings create builds. The workflow's `on` configuration determines whether a group is eligible after a build exists.

### macOS jobs wait for an agent

When a workflow uses a `macos-*` runner label and Buildkite Pipelines can't resolve a compatible queue, the importer reports `No compatible runner is configured.` If a converted pipeline already targets a queue without an available matching agent, the job remains in the `Waiting for agent` state.

As a temporary unblocker for a pipeline generated by the Buildkite pipeline converter:

1. [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) in the same cluster as the pipeline.
1. Set **Machine type** to **macOS**, select the required capacity, and configure a base image with the macOS and Xcode versions that the job needs.
1. Add the queue key as the `agents.queue` value on each generated macOS command step. For example:

    ```yaml
    steps:
      - label: "macOS tests"
        command: "bundle exec rake test"
        agents:
          queue: "macos-14-medium"
    ```

Buildkite hosted macOS agents support only Apple silicon. Converted macOS jobs must support the arm64 architecture. macOS queues don't support custom base images. A GitHub Actions `macos-*` label also doesn't guarantee the same tools, image layout, or Xcode installation on a Buildkite hosted agent. Review the [macOS hosted agent images and software](/docs/agent/buildkite-hosted/macos#macos-instance-software-support) before selecting a base image.

For workflows that continue to run through the GitHub Actions Buildkite plugin, map the `macos-*` label to the new queue using the plugin's [`runners` configuration](#requirements-generated-job-requirements), rather than editing the dynamic pipeline.

### GitHub Actions options aren't available in the legacy Pipelines UI

Customers using the legacy Pipelines UI can't currently switch to the new Pipelines UI themselves to use the GitHub Actions Buildkite plugin. Contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com) to request access. Buildkite team members should escalate these requests in `#project-buildkite-gha`.

### The workflow picker shows a repository access notice

If Buildkite doesn't have code access to the selected repository, the workflow picker doesn't try to detect workflows. Instead, the picker shows a notice explaining that Buildkite can't scan the repository. For a **GitHub (Limited Access)** connection, the notice includes a **Manage GitHub access** link when GitHub provides one. This connection can't provide code access, so connect the repository using the full-access [**GitHub** repository provider](/docs/pipelines/source-control/github#github-repository-provider-options), then select it in the repository picker. If a repository is missing from an existing full-access GitHub App installation, select **GitHub settings** in the repository picker to add it. The access notice can also appear without an action if Buildkite can't access a repository during a full-access scan.

When you create a new pipeline, other scan failures show a notice with a **Try again** option. Select **Try again** to retry the scan without reloading the page.

If the **YAML Steps editor** shows `Something went wrong checking your repository for GitHub Actions workflows`, the warning doesn't prevent you from saving or updating the pipeline.

If the repository check receives a `422 Unprocessable Entity` response, check the Buildkite GitHub App installation first:

- Confirm that the installation has access to the affected repository.
- Confirm that the installation has the required `contents: read` permission.

The current interface replaces the useful backend error with the generic warning. The error-monitoring service doesn't receive these failures. More specific error messages and observability are planned as a product follow-up.

### Private checkout or a GitHub token is unavailable

Private checkout and workflow access tokens use separate settings. For private checkout, enable Buildkite repository-provider Git credentials for the job and authorize the repository URL. For a temporary GitHub token, enable the pipeline's workflow access token setting. Then make sure the workflow uses a supported static token reference. Review the [credentials, secrets, and OIDC](#supported-functionality-and-limitations-credentials-secrets-and-oidc) restrictions before enabling write permissions.

If a generated job fails with `buildkite-gha: run-job: GitHub scoped access tokens are not enabled for this organization`, the Buildkite organization doesn't have GitHub scoped access token minting enabled. Contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com) to enable it.

### Validate a workflow locally

For most workflows, use the plugin. If you need more control or want to diagnose a problem, install `buildkite-gha` using `mise` 2026.5.12 or later:

```bash
mise use -g --minimum-release-age 0s github:buildkite/buildkite-gha
```

You can then check a workflow's syntax, declared triggers, and static job graph without running it:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

To resolve actions and apply the production upload policy for each declared supported event, use the hosted profile:

```bash
buildkite-gha validate \
  --profile hosted \
  --all-events \
  .github/workflows/ci.yml
```

This check doesn't run arbitrary action code or prove that every GitHub service an action uses is compatible. A `context-required` result means compilation and policy checks passed, but the generated event doesn't provide evidence required for admission. For example, path filters require a linked webhook and a verified local Git diff. Use `--event-path` with a bounded event snapshot when exact refs, activity types, repository identity, or payload fields matter. You can also use `--event issues` to validate against a representative `opened` issue event. Generated snapshots test compatibility, but don't prove support for every activity type or admission requirement.

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

The `validate` and `compile` commands don't use `mise` after you install the CLI, and they don't run workflow code. Each command produces a processing report with the status of each validation and generation stage. Use `validate --format json` for a machine-readable report. In each diagnostic, `message` provides actionable guidance, optional `detail` provides lower-level evidence, and the stable diagnostic `code`, `stage`, and `location` remain separate. Use the versioned compatibility guide as the authority for compatibility rules.

The `compile` command writes its report to standard error, while `upload` writes it to the importer job log. When these commands run in a Buildkite job, they also publish processing warnings and errors as job-scoped annotations. A failure to publish an annotation produces a warning but doesn't change the command result. Stages blocked by an earlier failure are reported as `not-evaluated`, not `failed`. If a required stage fails, the runtime doesn't publish plans or pipeline output.

Run `upload` from a keyed Buildkite Pipelines command step so that the `BUILDKITE` and `BUILDKITE_STEP_KEY` environment variables are available. The step must use Buildkite agent v3.129.0 or later in the v3 release series; Agent v4 isn't supported.

As with the plugin, generated jobs manage their own `mise` setup only when their actions need it. For a custom importer, use repeatable `--runner-queue` options to map runner labels to queues. Linux mappings can use `--runner-image` with an immutable image digest. The importer executable provides the Linux runtime by default. To run macOS jobs, provide the macOS arm64 runtime with `--runtime-distribution`. The plugin handles the runtime downloads and applies your `runners` configuration for you, which is why it's the best option for most workflows.

## Next steps

- Learn how to [migrate from GitHub Actions](/docs/pipelines/migration/from-githubactions).
- [Translate a GitHub Actions workflow](/docs/pipelines/converter/github-actions) to native Buildkite Pipelines configuration.
- Learn more about [using plugins](/docs/pipelines/integrations/plugins/using).
