# Hosted agents terminal access

The Buildkite hosted agents feature provides you with _terminal/console access_ to jobs running on hosted agents. This feature is useful in allowing you to:

- Understand what components are installed, as you set up your pipeline.
- Test the behavior of different scripts (because they may not be well-documented).
- Debug issues that are not reproducible in your local environment.

This can be useful when migrating your pipelines across to [queues](/docs/agent/v3/targeting/queues/managing) on Buildkite hosted agents.

## Use terminal access on hosted agents

Assuming that [terminal access is active across your Buildkite organization](#deactivate-and-reactivate-terminal-access-on-hosted-agents), you can access this terminal access feature from a currently building pipeline, when the job of the relevant step is being built.

The terminal access feature is available to users who have/are any of the following:

- build permissions on the pipeline that created the job
- a [maintainer of the cluster](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) containing this pipeline
- a Buildkite organization administrator of this cluster

As a pipeline is being built, expand the relevant step and as its job is being built, select its **Open Terminal** button. A new browser window will open with terminal you can use to execute commands to investigate your hosted agent's environment, test script behavior and debug other issues.

<%= image "terminal-button-on-job.png", alt: "Accessing the SSH button through the Buildkite UI" %>

To extend the terminal session time, it is recommended that you include a `sleep` [command](/docs/pipelines/configure/step-types/command-step) within your job steps. This can help maintain an active terminal connection and prevent the session from timing out too quickly, allowing you to debug your job or investigate the environment the job is running in.

In the example below, the job will pause for 10 minutes before continuing. Adjust the sleep duration according to your specific needs.

```yml
steps:
  - label: "Extend Terminal Session"
    command: |
      echo "Starting job..."
      sleep 600  # Sleep for 10 minutes
      echo "Job complete."
```

## Deactivate and reactivate terminal access on hosted agents

By default, the terminal access feature for Buildkite hosted agents is active.

If this feature is not active, you can reactivate it for all hosted agents across all clusters within your Buildkite organization. Reactivating or deactivating the terminal access feature requires Buildkite organization administrator permissions.

To deactivate or reactivate the hosted agent terminal access feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.
1. Select **Pipelines** > **Settings** to access your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.
1. Scroll down to the **Hosted Agents Terminal Access** and to:
    * _Deactivate this feature_, select the **Disable Terminal Access** button, followed by **Disable Hosted Agents Terminal Access** in the confirmation message.
    * _Reactivate this feature_, select the **Enable Terminal Access** button, followed by **Enable Hosted Agents Terminal Access** in the confirmation message.

Terminal access will now be either removed or made available to all Buildkite hosted agents across all clusters within your Buildkite organization.

When this feature is active, be aware that users require either:

- Build permissions on relevant pipelines to use this feature on these pipelines' jobs.
- Cluster maintainer permissions on the cluster the pipeline belongs to, or Buildkite organization administrator permissions.
