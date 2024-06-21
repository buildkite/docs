# Hosted agents code access

Natively, Buildkite hosted agents can only be used with GitHub integrated repositories. To utilize a private repository from another provider, we've [made a plugin](https://github.com/buildkite-plugins/git-ssh-checkout-buildkite-plugin) available that's documented below.

To learn more about changes that may need to be completed at an individual pipeline level, see [Pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## GitHub Private repositories

To use a private GitHub repository with Buildkite hosted agents, you'll need to authorize Buildkite to access your repository.

1. Navigate to your [Buildkite organization's settings page](https://buildkite.com/organizations/~/settings).
1. On the left hand menu select **Repository Providers**.
1. Select the **GitHub (with code access)** option.
1. Follow the prompts to authorize the services on your GitHub account. You can restrict access to specific repositories during setup.

## Public repositories

Buildkite does not require any special permissions to access public repositories.

## Other Private repositories

There are 2 key aspects to utilizing a private repository with Buildkite hosted agents.

1. Adding an SSH key as a Secret to the Buildkite hosted agent cluster.
1. Adding the plugin to the initial pipeline steps, and any further steps within the pipeline that are loaded.

### Adding the SSH key secret

Navigate to **Agents** from the top menu, and open the **Cluster** for Buildkite hosted agents. In the left-hand side navigation, there will be a **Secrets** option to follow. Clicking the **New Secret** button will open a modal to capture the new secret.

<%= image "secret-creation.png", width: 1516, height: 478, alt: "Creating a secret called GIT_SSH_CHECKOUT_PLUGIN_SSH_KEY" %>

This secret should contain the full private key (including the header and footer) that will be used to access the repository.

If there are multiple distinct keys to be used throughout the cluster, make sure to name them appropriately so they can each be used at their correct times.

### Adding a new pipeline

With the secret available, a new pipeline can be added that will use it and allow for the Git repository to be used.

Create a new pipeline using the **Create a new pipeline without provider integration** link on the **New pipeline** page. Complete the form with the basic details about the new pipeline, including the Git URL. At this time, the **Steps** can also be updated to include the plugin usage.

<%= image "pipeline-creation.png", width: 1752, height: 1060, alt: "Adding the details for creating a new pipeline" %>

To illustrate an example, if we assume there now exists the secret named `GIT_SSH_CHECKOUT_PLUGIN_SSH_KEY` we can set our **Steps** value accordingly.

```yaml
steps:
  - label: "\:pipeline\: Upload"
    command: "buildkite-agent pipeline upload"
    plugins:
      - git-ssh-checkout#v0.3.2:
```

This base step content uses the new plugin, with the default values, to complete the Git checkout.

Once created, a screen is presented about setting up Webhooks. If the Git provider being used supports the GitHub format of webhook communication, the details shown can be used to complete the integration. If not, the **Skip Webhook Setup** button can be used to skip this step. This will mean that builds will require manual triggering.

At the completion of the pipeline creation process, a build can now be triggered that will use the SSH key from the secret to clone the Git repository.
