---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs in this public preview of the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

> 📘 Public preview
> Running GitHub Actions workflows in Buildkite is currently in public preview. To report issues with the preview, [open an issue in the `buildkite-gha` repository](https://github.com/buildkite/buildkite-gha/issues). For help migrating to native Buildkite Pipelines steps, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).
> The plugin and runtime are under active development. Review the [`buildkite-gha` v0.71.1 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.71.1/docs/compatibility.md) before adding a workflow.

Buildkite Pipelines can match GitHub events against your workflows and create one build per matching workflow for each event. This server-side workflow dispatch is the recommended way to run GitHub Actions workflows. The GitHub Actions Buildkite plugin runs the selected workflow as Pipelines jobs, so you can migrate with minimal changes, then replace imported jobs with [native Buildkite Pipelines steps](/docs/pipelines/migration/from-githubactions) over time.

During the preview, start with a simple workflow in a public `github.com` repository that targets Linux x86-64. Private repository checkout, statically named Buildkite secrets, temporary GitHub tokens, and OIDC require additional setup. Review the [supported functionality and limitations](#supported-functionality-and-limitations) before you begin.

## Add a GitHub Actions workflow to a pipeline

Use GitHub Actions setup mode when creating a pipeline in the Buildkite interface. For pipelines created using the CLI, API, or an agent-based automation workflow, configure the equivalent steps, settings, and trigger manually.

### Create a GitHub Actions pipeline

Connect your repository using the full-access [**GitHub** repository provider](/docs/pipelines/source-control/github#github-repository-provider-options), which gives Buildkite Pipelines access to workflow files. **GitHub (Limited Access)** and GitHub Enterprise Server aren't supported for server-side dispatch.

To create a pipeline:

1. From the Buildkite dashboard, select **New Pipeline**.
1. Under **Git scope**, select your GitHub account or organization. Then select a repository that contains GitHub Actions workflow files on its default branch.
1. When Buildkite Pipelines detects your workflows, review the **Run your GitHub Actions workflows** setup and the pipeline details.
1. Select **Create GitHub Actions pipeline**.

The new pipeline uses the following configuration without an explicit `workflow`, `workflows`, or importer `key`:

```yaml
steps:
  - label: "\:github\:"
    plugin: github-actions
```

This setup creates an enabled **GitHub Actions** pipeline trigger and provisions its own signed repository webhook. It skips the traditional GitHub webhook setup, not webhooks altogether. Don't add a second native repository webhook for this pipeline, because it can create duplicate builds.

The pipeline enables workflow-authorized GitHub access tokens and disables pipeline-level commit status publishing. Review [token permissions and trust boundaries](#supported-functionality-and-limitations-credentials-secrets-and-oidc), and disable workflow access tokens in the pipeline's GitHub settings if your workflows don't need them.

### Configure an equivalent pipeline manually

Creating or uploading pipeline YAML alone doesn't configure server-side dispatch. CLI, API, and agent-based setup must also configure the pipeline settings and create the GitHub Actions pipeline trigger.

1. Connect the GitHub.com repository using the full-access **GitHub** repository provider.
1. [Create a YAML pipeline](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline) with the following JSON request body. Replace `YOUR_CLUSTER_ID`, the repository URL, and `main` with your cluster, repository, and default branch. The settings match GitHub Actions setup mode in the interface.

    ```json
    {
      "name": "GitHub Actions",
      "repository": "https://github.com/acme-inc/example.git",
      "cluster_id": "YOUR_CLUSTER_ID",
      "default_branch": "main",
      "configuration": "steps:\n  - label: \":github:\"\n    plugin: github-actions\n",
      "branch_configuration": null,
      "skip_queued_branch_builds": false,
      "cancel_running_branch_builds": false,
      "provider_settings": {
        "github_workflow_access_tokens_enabled": true,
        "publish_commit_status": false,
        "build_branches": true,
        "build_pull_requests": true,
        "build_tags": true,
        "filter_enabled": false,
        "filter_condition": null,
        "pull_request_branch_filter_enabled": false,
        "pull_request_branch_filter_configuration": null,
        "ignore_default_branch_pull_requests": false,
        "skip_builds_for_closed_pull_requests": false,
        "skip_builds_for_existing_commits": false,
        "skip_pull_request_builds_for_existing_commits": false,
        "trigger_mode": "code"
      }
    }
    ```

1. [Create a GitHub Actions pipeline trigger](/docs/apis/rest-api/pipeline-triggers#create-a-pipeline-trigger-create-a-github-actions-pipeline-trigger) with `type: "github_actions"`, `enabled: true`, and `create_webhook: true`. This provisions a signed repository webhook. Don't configure a traditional repository webhook for the pipeline.
1. Save the response's `endpoint_url` securely and check `webhook_creation.status`. A `201 Created` response confirms trigger creation, not successful webhook provisioning. If provisioning failed, repair the webhook setup for the existing trigger rather than creating another trigger.
1. Send a supported GitHub event and inspect **Recent Deliveries** and the resulting builds. An event matching two workflows should create two builds, each running its matched workflow.

The REST API requires the `write_pipelines` scope to create pipelines and triggers, and **Full Access** to manage the pipeline's triggers. See the [provider settings reference](/docs/apis/rest-api/pipelines#provider-settings-properties) for the settings payload. `github_actions_mode` is interface presentation metadata, not an API switch that configures these resources.

### Trigger builds from workflow events

A GitHub Actions pipeline trigger reads top-level workflow files under `.github/workflows/` and matches their `on` declarations against each incoming GitHub event before creating builds. It creates one build per matching workflow per event, and passes the selected workflow to the plugin. Don't set `workflow` or `workflows` in the plugin configuration: either explicit selector overrides the server's choice.

Server-side dispatch is not GitHub's `workflow_dispatch` event. The trigger handles supported `create`, `delete`, `deployment`, `deployment_status`, `issue_comment`, `issues`, `label`, `merge_group`, `pull_request`, `pull_request_review`, `pull_request_review_comment`, `push`, and `release` declarations. It doesn't start builds for standalone `workflow_dispatch`, `schedule`, or `workflow_call` declarations. Manual and scheduled Buildkite builds remain available through the [explicit-workflow setup](#use-explicit-workflows-in-an-existing-build).

The trigger supports branch and tag pushes, plus same-repository pull requests. It supports `branches`, `branches-ignore`, `tags`, and `tags-ignore`. Without an explicit `types` filter, a pull request workflow triggers on `opened`, `reopened`, and `synchronize`. Pull request builds use the head branch and commit, while `GITHUB_WORKFLOW_REF` identifies `refs/pull/<N>/merge`. Fork pull requests, unsupported activity types, and unsupported filter patterns fail closed and appear in **Recent Deliveries**.

For push and pull request workflows, the server accepts `paths` and `paths-ignore` but defers path matching to the importer. A candidate build can be created before the importer determines that the workflow should be skipped. Path matching requires a verified linked webhook and matching diff evidence from the checkout. Runtime event support alone doesn't imply server-side dispatch support; review the current [pipeline trigger selection contract](https://github.com/buildkite/buildkite-gha/blob/main/docs/cli.md#github-actions-pipeline-trigger-selection) and [compatibility guide](https://github.com/buildkite/buildkite-gha/blob/main/docs/compatibility.md) for event-specific limits.

The trigger's workflow matching decides which builds to create. Traditional provider build filters and duplicate-commit qualification aren't applied to these builds. Don't rely on those settings to restrict workflow-triggered builds. Configure supported workflow filters instead, and leave branch-wide intermediate-build skipping and cancellation disabled so one workflow's build doesn't suppress another.

## Migrate to server-side dispatch

Buildkite strongly recommends migrating existing explicit-workflow pipelines to server-side dispatch. The explicit-workflow plugin and native GitHub webhook setup remain supported.

1. Review the workflow's events and filters against the server-side dispatch limits above. Keep unsupported event paths, such as manual or scheduled builds, in a separately configured explicit-workflow pipeline if needed.
1. In the pipeline's GitHub settings, select **Disable Incoming GitHub Webhook Processing**, or use the [Disable GitHub webhook processing API](/docs/apis/rest-api/pipelines#github-webhook-processing-disable-github-webhook-processing). This disables native webhook processing for this pipeline without affecting GitHub Actions pipeline triggers. If this feature isn't available for your organization, disable only the GitHub repository webhook dedicated to this pipeline. Don't delete or disable webhooks used by other pipelines.
1. Remove `workflow` and `workflows` from the plugin configuration so the server-selected workflow runs. For a dedicated GitHub Actions pipeline, use the minimal configuration above. Preserve any required plugin options, such as runner mappings or OIDC configuration, when using the expanded plugin syntax.
1. Apply the pipeline and provider settings from the manual setup example using [Update a pipeline](/docs/apis/rest-api/pipelines#update-a-pipeline). Review token access before enabling it. Disable branch-wide intermediate-build skipping and cancellation. Update required GitHub checks to use the workflow checks before disabling pipeline-level commit status publishing, so branch protection doesn't wait for a status that is no longer published.
1. Create the GitHub Actions pipeline trigger with webhook provisioning as described above. Check the provisioning result, preserve the one-time endpoint URL, and repair partial failures without recreating the trigger.
1. Verify a supported event in **Recent Deliveries**. Confirm that each matching workflow creates its own build and that no native webhook creates additional builds.

If the existing pipeline mixes imported and native steps, review those steps before migrating: every workflow-triggered build runs the pipeline configuration. Native steps that previously ran once per event might now run once per matching workflow.

## Use explicit workflows in an existing build

The previous setup remains supported for pipelines where native GitHub webhooks, schedules, or manual actions create the build and the plugin selects workflows inside it. Prefer server-side dispatch for new GitHub Actions pipelines.

### Detect workflows automatically

For an existing pipeline connected through the full-access **GitHub** repository provider, the workflow picker can add explicit workflow paths to the plugin step:

1. Select **Pipeline settings** > **Edit steps**.
1. In the detected **GitHub Actions** workflows panel, select **Select workflows...**.
1. Select supported workflows, then review the generated step in the **YAML Steps editor**.
1. Select **Save steps**.

This configures explicit workflow selection inside a build. It doesn't migrate the pipeline to server-side dispatch. Don't add explicit selectors to a pipeline that already uses server-side dispatch.

### Configure the plugin manually

Add the following step to your [pipeline configuration](/docs/pipelines/configure/defining-steps). Set `workflow` to the path of one workflow file in your repository. Give the step a unique `key` so Buildkite Pipelines can connect it to the jobs created by the plugin:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    agents:
      queue: "importer-linux"
    plugins:
      - github-actions:
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
      - github-actions:
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
| `workflow` | Only without server selection | Path to one GitHub Actions workflow in the repository. Overrides the server-selected workflow. |
| `workflows` | Only without server selection | Array of paths to GitHub Actions workflows in the repository. Overrides the server-selected workflow. Use this or `workflow`, not both. |
| `version` | No | Latest stable or an exact `buildkite-gha` runtime release from `0.9.0` onward. The default is `latest`. |
| `source-ref` | No | Full lowercase 40-character runtime commit for testing unreleased changes. This property can't be used with `version`. |
| `minimum-release-age` | No | Minimum release age used by `mise` when resolving `latest`. The default is `0s`. |
| `experimental-runner-user` | No | Run generated Linux jobs as a dedicated `runner` user. The default is `true`. Set this property to `false` only as a temporary compatibility measure. |
| `oidc` | No | Buildkite OIDC token options for jobs that declare `permissions: id-token: write`. |
| `runners` | No | Explicit mappings from GitHub runner labels to Buildkite queues, optional Linux images, and optional Buildkite hosted cache volumes. A mapped selector bypasses Agent API runner resolution. |
{: class="responsive-table"}

The Git ref after `github-actions#` selects the plugin code. This is separate from `version`, which selects the `buildkite-gha` runtime. Use a specific plugin release, such as `github-actions#v0.13.0`, and an exact runtime `version` when you need immutable version selection.

In this explicit-workflow setup, the plugin doesn't create build triggers from the workflow's `on` key. Set up native GitHub triggers and schedules in Buildkite Pipelines, or start a build yourself by selecting **New Build** or using the REST API. Within the existing build, the `on` key determines whether each selected workflow is eligible to run. In the recommended [server-side setup](#add-a-github-actions-workflow-to-a-pipeline-trigger-builds-from-workflow-events), workflow matching happens before build creation.

For native pull request triggers, turn off **Skip when pull request has existing build for commit and branch** and **Skip when pull request is closed or merged** in the pipeline's GitHub settings if those events need to reach the imported workflow.

For manual and scheduled builds, the plugin automatically finds the exact commit after checkout.

The plugin gives each workflow a GitHub event type based on how the Buildkite build started:

- Pull request builds receive `pull_request`.
- Verified merge queue builds receive `merge_group`.
- Verified release builds receive `release`.
- Verified issue activity builds receive `issues`.
- Builds started from the Buildkite interface or API fall back to `push`. A `workflow_dispatch` event requires an explicit event snapshot or authoritative event metadata; see the [event input reference](https://github.com/buildkite/buildkite-gha/blob/main/docs/cli.md).
- Scheduled builds receive `schedule`.
- Other builds, including branch, tag, and triggered builds, receive `push`.

Pull request builds check out and run against the head commit of the pull request branch (`refs/pull/<N>/head`). This matches how [Buildkite Pipelines handles pull request builds by default](/docs/pipelines/source-control/github#running-builds-on-pull-requests-building-the-test-merge-commit), and applies even before GitHub finishes computing the pull request's merge commit.

Release workflows require the GitHub Releases additional webhook, the **Code** trigger mode, and a supported `published`, `created`, or `released` activity type. With the full-access **GitHub** repository provider, Buildkite Pipelines resolves the release tag to its immutable commit before creating the build. Without this access, the plugin can use the checked-out `HEAD` as a compatibility fallback, but the build can't receive a workflow access token for the release.

Issue workflows require the private-preview [issue activity build setting](/docs/pipelines/source-control/github#running-builds-on-additional-github-events-running-builds-on-issue-activity). A bare `issues` trigger accepts every supported activity type. You can also list supported GitHub issue activity types explicitly. Branch, tag, path, and workflow filters aren't supported for this event.

Each successfully compiled workflow that declares the effective event becomes a group named for the workflow. A supported, non-empty `run-name` is appended to the group label, but doesn't change the build message or external check name. The external check identifies both the workflow and effective event. A workflow that doesn't declare the effective event becomes a top-level skipped step. After upload, an importer-scoped informational annotation lists skipped workflows. A local reusable workflow that declares only `workflow_call` can support another selected workflow, but doesn't create its own group.

The runtime supports branch, tag, and bounded path filters for `push`, and base-branch, activity type, and bounded path filters for `pull_request`. Path filters require a verified linked GitHub webhook and complete matching diff evidence from the local checkout. If that evidence is missing or uncertain, the affected workflow fails instead of running more broadly. For `merge_group`, `paths` and `paths-ignore` are accepted but ignored with a warning, matching GitHub behavior. Every workflow that declares `schedule` is eligible for every Buildkite scheduled build.

## Migrate incrementally

You don't have to convert the whole workflow at once. Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. In this example, the native `Deploy` step waits for all the imported test jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    agents:
      queue: "importer-linux"
    plugins:
      - github-actions:
          workflow: ".github/workflows/ci.yml"

  - label: "Deploy"
    key: "deploy"
    depends_on: "github-actions-tests"
    command: ".buildkite/deploy.sh"
```
{: codeblock-file=".buildkite/pipeline.yml"}

As you replace jobs with native Buildkite Pipelines steps, the remaining supported workflow jobs can keep running through the plugin. If you want to convert a whole workflow instead, use the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions).

## How the plugin and runtime work

The plugin and the `buildkite-gha` runtime work together to run the workflow. This page calls the step that runs the plugin the _importer step_, and the jobs it creates the _generated jobs_. The minimal server-dispatch configuration doesn't require an explicit importer key.

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

- A Linux x86-64 or native macOS arm64 agent. When configuring an importer step explicitly, select a compatible queue with its `agents` configuration. The plugin's `runners` configuration doesn't schedule the importer.
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
      - github-actions:
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
  - github-actions:
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
      - github-actions:
          workflow: ".github/workflows/ci.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Without this volume, mise uses the agent or user data directory. Treat the mise data directory as executable state. Don't share it with untrusted jobs or principals that can modify it. This importer cache is separate from generated-job runtime caching and the workflow's `actions/cache` behavior.

This example configures an explicit-workflow importer. If you add caching to a server-dispatch pipeline, omit `workflow` and `workflows` so the plugin uses the server's selection.

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

See the [`buildkite-gha` v0.71.1 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.71.1/docs/compatibility.md) for the supported functionality and limitations of the latest stable runtime covered by this page. If a feature isn't listed in the guide, treat it as unsupported.

> 🚧 Treat workflow code as build code
> All steps in an imported job share a workspace, environment changes, processes, and action lifecycle. Docker actions and containers provide packaging, not a security boundary. Run imported jobs on a queue that provides whole-job isolation, no ambient protected credentials, a clean machine for each untrusted job, and host-level resource limits. Review the [`buildkite-gha` v0.71.1 security model](https://github.com/buildkite/buildkite-gha/blob/v0.71.1/docs/security.md) for the complete trust boundaries.

### Concurrency

The runtime turns each static `concurrency` group into a case-insensitive Buildkite Pipelines concurrency group scoped to the repository. Workflow-level groups use ordered opening and closing gates, while job-level groups use a concurrency limit of one.

Workflow-level groups can use supported `github` fields, `vars`, and static inputs in a called workflow. Job-level groups can also use concrete `matrix` values. Local and public called workflows retain their workflow-level concurrency gates, including nested gates. Each static call-matrix instance gets its own gate.

The workflow won't compile if a group can't be resolved. Called-workflow concurrency also isn't supported when the call uses `if` or `needs`, or when a job or nested call reuses an enclosing workflow's concurrency group.

Workflow-level `cancel-in-progress` accepts literal values and expressions that resolve statically to a Boolean value. A resolved `false` is accepted without a warning. A literal or statically resolved `true` produces a warning but doesn't cancel an older build. Job-level cancellation remains unsupported.

Buildkite queues every waiting entry, unlike GitHub's default behavior of replacing an existing pending entry. For an explicit-workflow pipeline, you can turn on **Cancel Intermediate Builds** and **Skip Intermediate Builds** in the pipeline's build settings for similar cancellation behavior. These settings work by branch, so they match a workflow concurrency group only when its scope follows the same branch boundaries. Leave both settings disabled for server-side dispatch, where they can cancel or skip sibling workflow builds from the same event.

### Credentials, secrets, and OIDC

To check out the private repository that triggered the build, enable Buildkite's repository-provider Git credentials for the job. Buildkite must also authorize the repository URL. Without both, checkout is anonymous. This access doesn't provide `GITHUB_TOKEN` or `github.token`, and it can't be used for private actions or other repositories.

Direct jobs can use statically named `${{ secrets.NAME }}` references. Local reusable-workflow calls can pass secret authority using one-hop `secrets: inherit`, which each nested call must repeat. A local call can instead map an alias declared by the called workflow from one direct `${{ secrets.NAME }}` or `${{ secrets['NAME'] }}` reference. Every required alias must be mapped, and an unmapped optional alias is empty. The runtime retrieves each value using the generated job's Buildkite secret access policy. Dynamic secret names, literal or compound mappings, and secret forwarding to public reusable workflows aren't supported. These values are Buildkite secrets, not GitHub repository, environment, event, or fork-scoped secrets.

Buildkite Pipelines can provide a short-lived token for the repository that triggered the build. The pipeline's workflow access token setting must be enabled. GitHub Actions setup mode enables **Allow workflow-authorized GitHub access tokens** by default. Disable it in the pipeline's GitHub settings if your workflows don't need tokens. Adding the plugin to an existing pipeline doesn't enable this setting; configure it separately.

During the preview, the Buildkite organization must also have GitHub scoped access token minting enabled. Contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com) to enable it for your organization.

The workflow file must be directly under `.github/workflows/` and have a simple `.yml` or `.yaml` filename. The job must either reference `secrets.GITHUB_TOKEN` directly or use an action whose default input references `github.token`.

If the workflow doesn't include top-level `permissions`, the token receives only `contents: read`, regardless of the GitHub repository or organization defaults. A non-empty top-level permissions map replaces that default. The `read-all` alias expands to every supported read permission. The `write-all` alias isn't supported and causes the token request to be denied. An empty map or a map containing only `none` doesn't produce a token. Job-level repository permission maps don't change the token scope. A job expanded from a local reusable workflow can receive a token, but its repository permissions always come from the top-level requesting workflow. The separate job-level `id-token` permission retains its documented behavior. Pull request builds and their triggered or rebuilt descendants can't receive more than `contents: read`. Merge queue builds and their descendants can't receive a token. The runtime doesn't add the token to the job's initial environment, although an action can make it available to later steps through `GITHUB_ENV`, as it can on a GitHub runner. An ambient `GITHUB_TOKEN` isn't available.

Each job can request up to 10 workflow access tokens per hour. Requests beyond this limit receive a `429 Too Many Requests` response with a `Retry-After` header, and no token is issued. This limit is tracked separately for each job.

> 🚧 Protect tokens in trusted branch and manual builds
> For builds outside pull requests and merge queues, a user who can create a build at an arbitrary commit may select code that requests the workflow's allowed permissions. Enable write tokens only when branch builds and other build-creation paths run trusted code.

For OIDC, the workflow job must declare `permissions: id-token: write`. Configure the plugin with the Buildkite claims that your identity provider accepts:

```yaml
plugins:
  - github-actions:
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

A reusable workflow whose only trigger is `workflow_call` doesn't create its own group. Selecting only reusable workflows produces an error, but a reusable workflow can support another selected workflow. For explicit-workflow pipelines, native webhook and schedule settings create builds, and `on` determines eligibility within the build. For server-side dispatch, check **Recent Deliveries** first: only a matching supported workflow event creates a build.

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
