# Hosted agents terminal access

The Buildkite hosted agents feature provides you with _terminal/console access_ to jobs running on hosted agents. This feature is useful in allowing you to:

- Understand what components are installed, as you set up your pipeline.
- Test the behavior of different scripts (because they may not be well-documented).
- Debug issues that are not reproducible in your local environment.

This can be useful when migrating your pipelines across to [queues](/docs/clusters/manage-queues) on Buildkite hosted agents.

## Use terminal access on hosted agents

Assuming that [terminal access is activated across your Buildkite organization](#deactivate-and-reactivate-terminal-access-on-hosted-agents), you can access this terminal access feature from a currently building pipeline, when the job of the relevant step is being built.

The terminal access feature is available to users who:

- have build permissions on the pipeline that created the job
- are a [maintainer of the cluster](/docs/clusters/manage-clusters#manage-maintainers-on-a-cluster) containing this pipeline
- are a Buildkite organization administrator of this cluster

As a pipeline is being built, expand the relevant step and as its job is being built, select its **SSH** button. A new browser window will open with terminal you can use to execute commands to investigate your hosted agent's environment, test script behavior and debug other issues.

<%= image "ssh-button-on-job.png", alt: "Accessing the SSH button through the Buildkite UI" %>

## Deactivate and reactivate terminal access on hosted agents

By default, the terminal access feature for Buildkite hosted agents is active.

If this feature is not active, you can reactivate it for all hosted agents across all clusters within your Buildkite organization. Reactivating or deactivating the terminal access feature requires Buildkite organization administrator permissions.

To deactivate or reactivate the hosted agent terminal access feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.
1. Select **Pipelines** > **Settings** to access your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.
1. Scroll down to the **Hosted Agents SSH** and to:
    * _Deactivate this feature_, select the **Disable SSH** button, followed by **Disable Hosted Agents SSH** in the confirmation message.
    * _Reactivate this feature_, select the **Enable SSH** button, followed by **Enable Hosted Agents SSH** in the confirmation message.

Terminal access will now be either removed or made available to all Buildkite hosted agents across all clusters within your Buildkite organization.

When this feature is active, be aware that users require either:

- Build permissions on relevant pipelines to use this feature on these pipelines' jobs.
- Cluster maintainer permissions on these pipelines.
