---
description: "Run supported GitHub Actions workflows as Buildkite Pipelines jobs with the GitHub Actions Buildkite plugin and buildkite-gha compatibility runtime."
---

# Run GitHub Actions workflows in Buildkite

The [GitHub Actions Buildkite plugin](https://buildkite.com/resources/plugins/) lets you run supported GitHub Actions workflows as jobs in a Buildkite Pipelines build. Use the plugin to move workflows to Buildkite Pipelines incrementally before [translating them to native pipeline steps](/docs/pipelines/migration/from-githubactions).

This functionality is an experimental preview. The current compatibility profile supports public, tokenless Linux x86-64 workflows. Review the [supported functionality and limitations](#supported-functionality-and-limitations) before adding a workflow.

## Add a GitHub Actions workflow to a pipeline

Add a keyed command step to your [pipeline configuration](/docs/pipelines/configure/defining-steps). Configure the plugin with the path to the workflow:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#v0.2.0:
          workflow: ".github/workflows/ci.yml"
```
{: codeblock-file=".buildkite/pipeline.yml"}

The `key` attribute is required. The plugin uploads the workflow jobs as a [dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines), and each generated job depends on the plugin step.

The plugin accepts the following configuration:

| Property | Required | Description |
| --- | --- | --- |
| `workflow` | Yes | Path to the GitHub Actions workflow in the repository. |
| `version` | No | Exact `buildkite-gha` version to use. The plugin release sets a default version. |
{: class="responsive-table"}

Pin the plugin to a released version. To pin both components independently, set `version`:

```yaml
steps:
  - label: "\:github\: GitHub Actions"
    key: "github-actions"
    plugins:
      - github-actions#v0.2.0:
          workflow: ".github/workflows/ci.yml"
          version: "0.2.0"
```
{: codeblock-file=".buildkite/pipeline.yml"}

Buildkite controls when builds run. Configure source control triggers and schedules in Buildkite, and start manual builds with **New Build** or the API. The workflow's `on` key does not configure Buildkite Pipelines build triggers.

The plugin provides `pull_request` context for pull request builds. Branch, tag, scheduled, and manual builds receive `push` context. The plugin does not provide `schedule`, `workflow_dispatch`, or dispatch inputs.

## Migrate incrementally

Imported workflow jobs and native Buildkite Pipelines steps can run in the same build. A native step that depends on the plugin step waits for all generated workflow jobs to finish:

```yaml
steps:
  - label: "\:github\: Tests"
    key: "github-actions-tests"
    plugins:
      - github-actions#v0.2.0:
          workflow: ".github/workflows/ci.yml"

  - label: "Deploy"
    key: "deploy"
    depends_on: "github-actions-tests"
    command: ".buildkite/deploy.sh"
```
{: codeblock-file=".buildkite/pipeline.yml"}

This approach lets you keep supported workflows running while replacing jobs with native Buildkite Pipelines steps. To translate a workflow rather than run it through the compatibility runtime, use the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions).

## How the plugin and runtime work

The plugin and the `buildkite-gha` runtime have separate responsibilities:

- **GitHub Actions Buildkite plugin:** Reads the plugin configuration, downloads and verifies the configured `buildkite-gha` release, then runs its `upload` command.
- **`buildkite-gha`:** Validates and compiles the workflow, translates its jobs into Buildkite Pipelines command jobs, uploads the generated pipeline, and provides the compatibility runtime that executes each generated job.

You do not need to download or install `buildkite-gha` when using the plugin. The plugin downloads the Linux x86-64 binary and verifies its checksum and archive contents before running it. The plugin also downloads and verifies the pinned `mise` release that the runtime uses to provide supported Node.js versions for JavaScript actions.

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
- Bash, `curl`, `tar`, `sha256sum`, `awk`, `grep`, `find`, `sed`, `sort`, `mktemp`, and `cp`.
- Outbound HTTPS access to public GitHub release and action sources.

The pipeline's cluster must have a Linux x86-64 [Buildkite hosted queue](/docs/agent/buildkite-hosted) with the key `hosted`. The generated-job queue cannot be configured in v0.2.0.

JavaScript actions use managed Node.js versions and require glibc 2.28 or newer. These jobs need outbound HTTPS access to the managed Node.js distribution downloads. Shell-only workflows do not have the glibc requirement. Step summaries and warning or error annotations require Buildkite agent v3.112.0 or later.

## Supported functionality and limitations

The compatibility runtime supports a defined subset of GitHub Actions. The supported functionality includes:

- Linux x86-64 jobs using `ubuntu-latest`, `ubuntu-24.04`, or `ubuntu-22.04`.
- Bash and `sh` run steps.
- Static job dependencies and matrices, including `include` and `exclude`.
- Supported job and step conditions, outputs, timeouts, and `continue-on-error` behavior.
- Public JavaScript, composite, local, and supported Dockerfile actions.
- Local reusable workflows with statically resolvable inputs.
- Credential-free `actions/checkout` for the public event repository.
- Restricted, native-backed artifact upload and download behavior.
- Restricted cache behavior for an audited `actions/cache` revision when a compatible cache service is configured.

The compatibility profile rejects unsupported or privileged functionality before uploading generated jobs. Current limitations include:

- Private repositories and private actions.
- Workflow secrets, `GITHUB_TOKEN`, GitHub-compatible OIDC, protected environments, and protected queues.
- Windows and macOS jobs.
- Job containers, service containers, and `docker://` actions.
- Dynamic matrices and remote reusable workflows.
- Arbitrary action revisions for actions that receive special native support, including checkout, artifacts, and cache.
- The complete `github.event` payload and GitHub-specific event behavior.

See the [`buildkite-gha` v0.2.0 compatibility guide](https://github.com/buildkite/buildkite-gha/blob/v0.2.0/docs/compatibility.md) for the compatibility matrix, admitted action revisions, event behavior, and detailed limits.

> 🚧 Treat workflow code as build code
> Steps in an imported GitHub Actions job share a workspace and process lifecycle. Docker actions are an execution backend, not a security boundary between steps. Use disposable per-job machines when workflow code must be isolated from other jobs or from the agent host.

## Use the buildkite-gha CLI directly

The plugin is the recommended way to run workflows. The [`buildkite-gha` releases](https://github.com/buildkite/buildkite-gha/releases) also provide a separately downloadable binary for validation, diagnostics, and advanced direct use.

After downloading the release archive and verifying it against the published checksums, use the CLI to validate a workflow's syntax and static compatibility:

```bash
buildkite-gha validate .github/workflows/ci.yml
```

The CLI also provides `compile` and `upload` commands. Direct `upload` use must run from a keyed Buildkite Pipelines command step and requires the supported `mise` version on `PATH` when a workflow uses actions. The plugin automates these installation and upload requirements, so use direct CLI execution only when you need more control or diagnostics.

## Next steps

- Learn how to [migrate from GitHub Actions](/docs/pipelines/migration/from-githubactions).
- [Translate a GitHub Actions workflow](/docs/pipelines/converter/github-actions) to native Buildkite Pipelines configuration.
- Learn more about [using plugins](/docs/pipelines/integrations/plugins/using).
