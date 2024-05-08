# Hosted agents terminal access

The Buildkite hosted agents feature provides you with _terminal/console access_ to jobs running on hosted agents. This feature is useful in allowing you to:

- Understand what components are installed, as you set up your pipeline.
- Test the behavior of different scripts (because they may not be well-documented).
- Debug issues that are not reproducible in your local environment.

This can be useful when migrating your pipelines across to [queues](/docs/clusters/manage-queues) on Buildkite hosted agents.

## Activate hosted agent terminal access

Before you can use the terminal access feature on your Buildkite hosted agents, you'll need to activate this feature for your Buildkite organization, which requires Buildkite organization administrator permissions.

To activate hosted agent terminal access:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.
1. Select **Pipelines** > **Settings** to access your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.
1. Scroll down to the **Hosted Agents SSH** and select the **Enable SSH** button.
1. Confirm this action by selecting the **Enable Hosted Agents SSH** button.

Terminal access is now granted to all Buildkite hosted agents across all clusters within your Buildkite organization.

Be aware that users require build permissions on pipelines to use the terminal access feature on the pipelines' jobs.

## Use hosted agent terminal access

Once this feature is [activated across your Buildkite organization](#activate-hosted-agent-terminal-access), you can access this terminal access feature from a currently building pipeline, when the job of the relevant step is being built.

As a pipeline is being built, expand the relevant step and as its job is being built, select its **SSH** button. A new browser window will open with terminal you can use to execute commands to investigate your hosted agent's environment, test script behavior and debug other issues.

<%= image "ssh-button-on-job.png", alt: "Accessing the SSH button through the Buildkite UI" %>