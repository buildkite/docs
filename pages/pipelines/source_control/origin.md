# Origin

[Origin](https://cursor.com/origin) is a Git repository hosting service. Buildkite Pipelines integrates with Origin to create builds from branch pushes, tag pushes, and pull request events. The integration can also check out private repositories on [Buildkite hosted agents](/docs/agent/buildkite-hosted) and publish build results to Origin.

> 📘 Public preview
> The Origin integration is in public preview and must be enabled for your Buildkite organization. Contact support at support@buildkite.com to request access.

## Connect Origin

You must be a Buildkite organization administrator to connect Origin. The Origin app can access all repositories in an Origin installation or only repositories selected during installation.

To connect Origin:

1. Select **Settings** > **Repository Providers**.
1. In **Add Provider**, select **Origin**. Buildkite redirects you to Origin.
1. In Origin, select the target and choose whether to grant access to all repositories or selected repositories.
1. Install the app. Origin returns you to the repository provider settings in Buildkite.

The app requests read access to repository contents and pull requests. It also requests read and write access to checks so Buildkite Pipelines can publish build results.

### Manage repository access

The Origin provider settings show whether the installation can access all repositories or selected repositories. To change this access, select **Origin settings**.

### Disconnect Origin

To disconnect Origin from your Buildkite organization:

1. Select **Settings** > **Repository Providers** > **Origin**.
1. In **Disconnect**, select **Disconnect**.

Disconnecting the provider from Buildkite does not uninstall the app in Origin.

## Create a pipeline

After connecting Origin, create a pipeline from a repository that the app can access:

1. Select **Pipelines** > **New Pipeline**.
1. From **Git scope**, select the Origin installation. It appears as **Origin (target-name)**.
1. From **Repository**, search for and select the repository.
1. Complete the remaining pipeline settings, then select **Create pipeline**.

Buildkite Pipelines validates access to the selected repository and saves its canonical HTTPS checkout URL. If the repository contains `.buildkite/pipeline.yml`, the **YAML Steps editor** automatically selects **Pipeline upload**.

> 📘 Select a connected repository
> Select the repository from the connected Origin installation instead of entering its URL manually. The association lets Buildkite Pipelines provide hosted-agent checkout credentials, receive repository events, and publish check runs.

## Change a pipeline repository

To associate an existing pipeline with an Origin repository:

1. Select **Pipelines** > your pipeline > **Settings** > **Repository**.
1. Select **Change repository**.
1. Select the Origin installation and repository.
1. Select **Save Repository**.

If the associated Origin installation is disconnected, the repository settings show **The Origin installation for this pipeline is disconnected.** Organization administrators can select **Reconnect Origin** to restore the connection. Buildkite Pipelines preserves the existing repository URL and provider settings while the installation is disconnected.

## Check out private repositories on hosted agents

Jobs running on Buildkite hosted agents can check out a connected private Origin repository without an SSH key or extra pipeline configuration. Before checkout, Buildkite Pipelines creates a short-lived `repository:contents:read` token scoped to the exact repository configured on the pipeline.

Native Origin authentication applies only to Buildkite hosted agents.

## Configure build triggers

Select **Pipelines** > your pipeline > **Settings** > **Origin** to configure which Origin events create builds.

Buildkite Pipelines receives signed events through the installed Origin app. You do not need to configure a webhook for each pipeline.

### Branch and tag pushes

- **Build branches**: Creates builds when commits are pushed to branches. This setting is enabled by default.
- **Build tags**: Creates builds when tags are pushed. This setting is disabled by default. For tag builds, `BUILDKITE_TAG` and `BUILDKITE_BRANCH` contain the tag name.

Deleted branches and tags do not create builds.

### Pull requests

**Build when pull request is opened or updated** creates a build when a pull request is opened or its head branch is pushed. This setting is enabled by default.

Pull request builds ignore pipeline-level branch filters. When pull request builds are disabled, a push to the same branch can still create a branch build if **Build branches** is enabled.

### Conditional filtering

Use a [conditional expression](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) to filter incoming Origin events before the other build trigger settings apply.

## Publish checks to Origin

**Update commit statuses** publishes Buildkite Pipelines build results to Origin. This setting is enabled by default.

Despite the setting name, the integration uses the Origin Checks API rather than commit statuses. Buildkite Pipelines creates a check run when a build is created. It updates the same check run as the build starts, finishes, fails, or is skipped.

### Configure required checks

Origin identifies required checks by the installed app and the keys of the check suite and check run. Display names are not used for matching.

Key             | Value
--------------- | ---------------------------------------------
Check suite key | `<buildkite-organization-slug> / <pipeline-slug>`
Check run key   | `<pipeline-slug>`
{: class="two-column"}

When configuring a required Buildkite check in Origin, select the Buildkite app and use both keys. Retries keep the same keys and appear as separate attempts.

The keys use the current organization and pipeline slugs. If either slug changes, update the required check configuration in Origin to use the new keys.

## Troubleshooting

### Origin is not available in repository providers

Confirm that Buildkite Support has enabled the public preview for your organization and that you are a Buildkite organization administrator.

### A repository is missing

Open the provider under **Settings** > **Repository Providers** > **Origin**, then select **Origin settings**. Confirm that the app can access the repository.

### Hosted-agent checkout fails

Confirm that the pipeline repository was selected from a connected Origin installation and that the installation still has access to the repository. Native Origin checkout credentials are available only on Buildkite hosted agents.

### Builds are not created

Check **Build branches**, **Build tags**, **Build when pull request is opened or updated**, and any conditional filter under the pipeline's **Origin** settings. Origin uses the app installation to send events, so there is no pipeline webhook to configure.

### Checks do not appear

Confirm that **Update commit statuses** is enabled and that the pipeline remains associated with a repository from the connected Origin installation. If a required check stopped matching after an organization or pipeline rename, update its suite and run keys in Origin.

For Origin availability, see the [Cursor status page](https://status.cursor.com/).

To inspect the connection using the Buildkite API, see:

- [Repository connections REST API](/docs/apis/rest-api/organizations/repository-connections)
- [Repositories for a connection REST API](/docs/apis/rest-api/repository-connections)
- [Origin provider settings in the pipelines REST API](/docs/apis/rest-api/pipelines#provider-settings-properties)
- [Origin organization connection in the GraphQL API](/docs/apis/graphql/schemas/object/organizationrepositoryprovidercursororigin)
- [Origin pipeline provider settings in the GraphQL API](/docs/apis/graphql/schemas/object/repositoryprovidercursororiginsettings)
