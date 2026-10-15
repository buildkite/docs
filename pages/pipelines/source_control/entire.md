# Entire

[Entire](https://entire.io) is a Git repository hosting service. Buildkite Pipelines integrates with Entire to create builds from branch and tag pushes, check out repositories, and report build status as checks. An organization administrator connects an Entire project, then pipelines in that Buildkite organization can select repositories from the connection.

> 📘 Preview
> The Entire integration is in preview. Share feedback or report issues at [support@buildkite.com](mailto:support@buildkite.com?subject=Entire%20Feedback).

## Connect an Entire project

Connecting an Entire project requires [Buildkite organization administrator](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) access.

1. Select **Settings** in the global navigation, then select [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers).
1. In **Add Provider**, select **Entire**. Buildkite redirects you to Entire.
1. In Entire, select a project and choose **All repositories** or **Only selected repositories**. The default, **All repositories**, includes repositories added later. For selected repositories, select at least one repository.
1. Select **Install**. Entire returns you to the new connection's page in Buildkite.

> 🚧 Retry a failed connection
> If the connection fails after approval, return to **Settings** > **Repository Providers** and select **Entire** again. Restart the installation rather than reusing the previous return URL.

## Create a pipeline

After connecting Entire, create a pipeline from a repository that the connection can access:

1. Select **Pipelines** > **New Pipeline**.
1. From **Git scope**, select the Entire connection.
1. From **Repository**, search for and select the repository.
1. Configure the pipeline's default branch and [checkout plugin](#configure-the-checkout-plugin).
1. Complete the remaining pipeline settings, then select **Create pipeline**.

Buildkite Pipelines keeps the repository's native `entire://` URL. Select the repository from the connection rather than entering a remote URL manually, so the pipeline is associated with the correct Entire project and repository.

## Build from branch and tag pushes

Buildkite Pipelines creates builds when you push to a connected repository. You don't need to configure a webhook in Entire or Buildkite.

Select **Pipelines** > your pipeline > **Settings** > **Entire**. In **Entire Settings**, choose which pushes create builds, then select **Save Entire Settings**:

- **Build branches**: Creates builds when commits are pushed to new or existing branches. This setting is enabled by default.
- **Build tags**: Creates builds when tags are created or updated. This setting is disabled by default. For tag builds, `BUILDKITE_TAG` and `BUILDKITE_BRANCH` contain the tag name. For an annotated tag, `BUILDKITE_COMMIT` is the tag object ID, and checkout resolves it to the tagged commit.

The pipeline's [branch filter](/docs/pipelines/configure/workflows/branch-configuration#pipeline-level-branch-filtering), in **Branch Limiting** on the same page, applies to both branch and tag names. For example, with **Build tags** enabled, `v* !v*-rc*` builds `v1.0` but not `v1.0-rc1`. Deleted branches and tags don't create builds.

## Configure the checkout plugin

The Entire Buildkite [plugin](/docs/pipelines/integrations/plugins) installs the native Entire Git helper. By default, Buildkite Pipelines adds the unversioned `entire` plugin first on each command job using the connection, including pipeline-upload jobs. If a step already lists the plugin, its declaration is preserved without adding another copy.

An organization administrator can turn this off in **Settings** > **Repository Providers** > the Entire connection. In the connection's **Settings** panel, clear **Add the Entire plugin to every job**, then select **Save Entire Settings**.

> 🚧 Pipeline signing
> Automatic plugin setup does not modify [signed steps](/docs/agent/self-hosted/security/signed-pipelines). List the Entire plugin in those steps before signing.

If automatic plugin setup is off, list the plugin on each command step that needs checkout, including the initial `buildkite-agent pipeline upload` step:

```yaml
steps:
  - label: "Upload pipeline"
    command: "buildkite-agent pipeline upload"
    plugins:
    - entire
```

## Check out repositories on hosted agents

Use [Buildkite hosted Linux agents](/docs/agent/buildkite-hosted/linux) on amd64 or arm64. Command jobs can obtain a short-lived, read-only credential scoped to the pipeline's repository with `contents:read` permission.

The plugin requests the credential once and exports it as `ENTIRE_TOKEN` for the job. You don't need an Entire login or a user-supplied token. If the job already has a non-empty `ENTIRE_TOKEN`, the plugin uses it instead and does not request a credential. If the plugin cannot obtain a credential, it continues without a token.

> 🚧 Job credentials
> The token is available to processes running in the job. Do not print `ENTIRE_TOKEN` or dump the job's environment. The plugin does not refresh the token, so it can expire during a long job.

## Check out repositories on self-hosted agents

By default, Buildkite does not issue checkout credentials to self-hosted agents. Export your own `ENTIRE_TOKEN` in an agent [environment hook](/docs/agent/hooks#job-lifecycle-hooks). The plugin uses a non-empty `ENTIRE_TOKEN` and does not request a credential from Buildkite.

An organization administrator can check for a Buildkite-issued alternative in **Settings** > **Repository Providers** > the Entire connection. If the connection's **Settings** panel shows **Allow self-hosted agents to use checkout credentials**, select it, then select **Save Entire Settings**. If the setting is not shown, use your own `ENTIRE_TOKEN`.

With this setting on, command jobs on self-hosted agents without a non-empty `ENTIRE_TOKEN` can obtain the same short-lived, read-only credential as hosted agents. The plugin requests it in the same way, which requires Buildkite agent v4.3.0 or later. The credential is available to processes running in the job, and the plugin does not refresh it.

If no token is available, the Entire Git helper can use a saved Entire login for the agent user. To prevent this, set `ENTIRE_GIT_NO_LOGIN_FALLBACK=true` on the agent. The plugin then fails the job when no token is available.

Install the [Entire CLI](https://docs.entire.io/installation) for the agent user and ensure `git-remote-entire` is on `PATH`. Do not print the token or dump the job's environment.

## Report build status

Buildkite Pipelines reports one check per pipeline and commit in Entire. The check represents the overall build and links to its Buildkite build page. Individual jobs are not reported. Each rebuild starts a new attempt of the same check. When a rebuild reports, its result replaces the previous attempt's displayed result, and Entire keeps earlier attempts as history.

**Publish build status as checks**, in the pipeline's **Entire Settings**, is enabled by default. When you turn it off, Buildkite Pipelines stops sending check updates for the pipeline, including updates already queued. Checks already in Entire keep their last reported status.

Builds created with a full commit SHA can report status from creation, including manual builds. For unresolved references such as `HEAD`, a branch name, or a short SHA, reporting starts after an agent resolves the commit.

Build state | Entire status | Entire conclusion
----------- | ------------- | -----------------
Scheduled | `queued` | None
Running, failing, or canceling | `in_progress` | None
Passed | `completed` | `success`
Failed | `completed` | `failure`
Canceled | `completed` | `cancelled`
Skipped or not run | `completed` | `skipped`
{: class="responsive-table"}

A blocked build reports `in_progress` with no conclusion by default. If a [block step](/docs/pipelines/configure/step-types/block-step) sets `blocked_state` to `passed`, the check reports `completed` with the conclusion `action_required`, which Entire treats as passing. Setting `blocked_state` to `failed` reports `completed` with the conclusion `failure`.

Check reporting uses a separate `checks:write` credential that stays within Buildkite. Jobs do not receive this permission.

### Required checks

Connecting Buildkite does not enable the checks gate in Entire. With the gate off, check results are informational. Enable the gate in Entire to require checks before merging.

To require the Buildkite build check, name it as `<account>/<suite key>`:

- `account`: `ins-` followed by the Entire installation ULID in lowercase.
- `suite key`: `<Buildkite organization slug>/<pipeline slug>`.

Buildkite reports the overall build state directly on this suite, without job-level check runs.

With named required checks, only those suites must report and pass. If you enable the gate without naming required checks, every integration that has reported on the repository must report on the head commit and every reported suite must pass. An expected integration that has not reported on the head commit keeps the gate pending. This includes earlier installations that reported on the repository.

If **Publish build status as checks** is off, new commits receive no report from this pipeline, so a required check for it stays pending. Checks it already reported keep their status.

Renaming the Buildkite organization or pipeline slug changes the suite key. Update the required check in Entire after a rename, or it continues waiting for the old key.

## Disconnect Entire

To disconnect an Entire project:

1. Select **Settings** > **Repository Providers** > the Entire connection.
1. In **Disconnect**, select **Disconnect** and confirm.

Disconnecting stops push-triggered builds, managed checkout, and check reporting for pipelines using the connection. It removes the Buildkite connection but does not uninstall Buildkite from Entire.
