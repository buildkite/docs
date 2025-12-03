# Hosted agents code access

Buildkite hosted agents can access private repositories in GitHub natively, by authorizing Buildkite to access these GitHub repositories. To access private repositories from another provider, the [git-ssh-checkout-buildkite-plugin](https://github.com/buildkite-plugins/git-ssh-checkout-buildkite-plugin) plugin is available to provide this capability.

To learn more about changes that may need to be completed at an individual pipeline level, see [Pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## GitHub private repositories

To use a private GitHub repository with Buildkite hosted agents, you need to authorize Buildkite to access your repository. This process can only be performed by [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.
1. In the **Integrations** section, select **Repository Providers**.
1. Select the **GitHub** option.
1. Follow the prompts to authorize the services on your GitHub account. You can restrict access to specific repositories during setup.

## GitHub token caching

Buildkite hosted agents also provides a feature for temporarily caching GitHub tokens, where any GitHub token used by a Buildkite hosted agent is cached for up to 50 minutes. This feature allows your hosted agents to use these GitHub tokens (how?) and avoid hitting Buildkite hosted agent rate limits (again how?), since these tokens can be re-used in subsequent builds.

## Public repositories

Buildkite does not require any special permissions to access public repositories.

## Private repositories with other providers

Using Buildkite hosted agents with a private repository on provider other than GitHub, has the following two requirements:

1. Add an SSH key as a secret to the Buildkite hosted agent cluster.
1. Add the plugin to the initial pipeline steps, and any further steps within the uploaded pipeline.

### Add the SSH key secret

Navigate to **Agents** from the top menu, and open the **Cluster** for Buildkite hosted agents. In the left-hand side navigation, there will be a **Secrets** option to follow. Clicking the **New Secret** button will open a modal to capture the new secret.

<%= image "secret-creation.png", width: 1516, height: 478, alt: "Creating a secret called GIT_SSH_CHECKOUT_PLUGIN_SSH_KEY" %>

This secret should contain the full private key (including the header and footer) that will be used to access the repository.

If there are multiple distinct keys to be used throughout the cluster, make sure to name them appropriately so they can each be used at their correct times.

### Add a new pipeline

With the secret now available, you can add a new pipeline to use it and access the Git repository.

The availability of the secret allows the creation of a new pipeline to utilize it and access the Git repository.

Once the secret is available, a new pipeline can be set up to use it and enable Git repository access.

Create a new pipeline following the **Create a new pipeline without provider integration** link on the **New pipeline** page. Complete the form with the basic details about the new pipeline, including the Git URL. At this time, the **Steps** can also be updated to include the plugin usage.

<%= image "pipeline-creation.png", width: 1752, height: 1060, alt: "Adding the details for creating a new pipeline" %>

To illustrate an example, if we assume a secret named `GIT_SSH_CHECKOUT_PLUGIN_SSH_KEY` now exists we can set our **Steps** value accordingly.

```yaml
steps:
  - label: "\:pipeline\: Upload"
    command: "buildkite-agent pipeline upload"
    plugins:
      - git-ssh-checkout#v0.4.1:
```

This base step content uses the new plugin with the default values to complete the Git checkout.

Once created, a screen is presented about setting up Webhooks. If the Git provider being used supports the GitHub format of webhook communication, the details shown can be used to complete the integration. If not, you can use the **Skip Webhook Setup** button to skip this step. This will mean that builds will require manual triggering.

At the completion of the pipeline creation process, a build can now be triggered that will use the SSH key from the secret to clone the Git repository.
