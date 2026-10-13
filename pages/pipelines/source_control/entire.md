# Entire

[Entire](https://entire.io) is a Git repository hosting service. Buildkite Pipelines integrates with Entire to create builds from branch pushes, check out repositories on hosted agents, and report build status as checks. An organization administrator connects an Entire project, then pipelines in that Buildkite organization can select repositories from the connection.

## Connect an Entire project

Connecting an Entire project requires [Buildkite organization administrator](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) access.

1. Select **Settings** in the global navigation, then select [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers).
1. In **Add Provider**, select **Entire**. Buildkite redirects you to Entire.
1. In Entire, select a project and choose whether to grant access to all repositories or selected repositories.
1. Approve the connection. Entire returns you to the connection page in Buildkite.

## Create a pipeline

After connecting Entire, create a pipeline from a repository that the connection can access:

1. Select **Pipelines** > **New Pipeline**.
1. From **Git scope**, select the Entire connection.
1. From **Repository**, search for and select the repository.
1. Configure the pipeline's default branch and [checkout requirements](#check-out-repositories-on-hosted-agents).
1. Complete the remaining pipeline settings, then select **Create pipeline**.

Buildkite Pipelines keeps the repository's native `entire://` URL. Select the repository from the connection rather than entering a remote URL manually, so the pipeline is associated with the correct Entire project and repository.

## Build from branch pushes

Buildkite Pipelines creates builds when branches are created or updated in a connected repository. You don't need to configure a webhook in Entire or Buildkite.

Use a [branch filter](/docs/pipelines/configure/workflows/branch-configuration) or [conditional expression](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) to limit which pushes create builds. Tag events and branch deletions don't create builds.

## Check out repositories on hosted agents

Checkout requires the Entire Buildkite [plugin](/docs/pipelines/integrations/plugins) on each command step that checks out the repository, including the initial `buildkite-agent pipeline upload` step. The plugin installs the native Entire Git helper. Buildkite Pipelines does not add the plugin automatically.

For example, configure the initial pipeline-upload step with the unversioned `entire` plugin:

```yaml
steps:
  - label: "Upload pipeline"
    command: "buildkite-agent pipeline upload"
    plugins:
    - entire
```

Add the plugin to each command step in the uploaded pipeline that needs checkout.

Use [Buildkite hosted Linux agents](/docs/agent/buildkite-hosted/linux) on amd64 or arm64 with Buildkite agent version 4.3.0 or later. Command jobs receive a short-lived, read-only credential scoped to the pipeline's repository with `contents:read` permission. You don't need a personal Entire login or an `ENTIRE_TOKEN` environment variable.

This managed checkout is not available on self-hosted agents. Installing the plugin on a self-hosted agent does not enable it.

## Report build status

Buildkite Pipelines automatically reports one check per pipeline and commit in Entire. The check represents the overall build and links to its Buildkite build page. Individual jobs are not reported. Each rebuild starts a new attempt.

Builds created with a full commit SHA can report status from creation, including manual builds. For unresolved references such as `HEAD`, a branch name, or a short SHA, reporting starts after an agent resolves the commit.

Build state | Entire check status
----------- | -------------------
Scheduled | Queued
Running, failing, or canceling | In progress
Passed | Success
Failed | Failure
Canceled | Cancelled
Skipped or not run | Skipped
{: class="two-column"}

A blocked build remains pending by default. If a [block step](/docs/pipelines/configure/step-types/block-step) sets `blocked_state` to `passed`, the check reports `action_required`, which Entire treats as passing. Setting `blocked_state` to `failed` reports failure.

Check reporting uses a separate `checks:write` credential that stays within Buildkite. Jobs do not receive this permission.

### Required checks

To require the build check in Entire, use `<account>/<suite key>`:

- `account`: `ins-` followed by the Entire installation ULID in lowercase.
- `suite key`: `<Buildkite organization slug>/<pipeline slug>`.

The suite contains one run named `Build #<number>`.

Renaming the Buildkite organization or pipeline slug changes the suite key. Update the required check in Entire after a rename, or it continues waiting for the old key.

## Disconnect Entire

To disconnect an Entire project:

1. Select **Settings** > **Repository Providers** > the Entire connection.
1. In **Disconnect**, select **Disconnect** and confirm.

Disconnecting stops push-triggered builds, managed checkout, and check reporting for pipelines using the connection. It removes the Buildkite connection but does not uninstall Buildkite from Entire.
