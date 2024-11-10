# Getting started with Mobile Delivery Cloud

👋 Welcome to Buildkite Mobile Delivery Cloud! You can use Mobile Delivery Cloud to help you run CI/CD pipelines to build your mobile apps, and track and analyze automated tests, as well as house your built mobile app artifacts within appropriate registries, all within a matter of steps.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a 30-day free trial account</a>.

    When you create a new organization as part of sign-up, you'll be guided through a flow to create and run a starter pipeline. Complete that before continuing, and keep your agent running to continue using it in this tutorial.

- To enable the YAML steps editor in Buildkite:

    * Select **Settings** > **YAML Migration** to open the [YAML migration settings](https://buildkite.com/organizations/~/pipeline-migration).
    * Select **Use YAML Steps for New Pipelines**, then confirm the action in the modal.

- [Git](https://git-scm.com/downloads). This tutorial uses GitHub, but Buildkite can work with any version control system.

## Set up your hosted agent

An agent is a small, reliable, and cross-platform program that runs pipeline builds. The agent polls Buildkite for work, runs jobs, and reports results.

Mobile Delivery Cloud uses [Buildkite hosted agents](/docs/pipelines/hosted-agents/overview) running [macOS on Mac machines](/docs/pipelines/hosted-agents/mac), which are configured through a [_cluster_](/docs/pipelines/glossary#cluster). Clusters provide a mechanism to organize your pipelines and agents together, such that the pipelines associated with a given cluster can _only_ be built by the agents (defined within [_queues_](/docs/pipelines/glossary#queue)) in the same cluster.

By default, Buildkite organizations have one cluster, named **Default cluster** with a single queue, named **default-queue**, noting that a cluster maintainer or Buildkite organization administrator can customize these default names.

You need at least one agent configured within its own queue and cluster to run builds.

### Create a Buildkite hosted agent for Mac

You can create the first [Buildkite hosted agent](/docs/pipelines/hosted-agents/overview) for [Mac](/docs/pipelines/hosted-agents/mac) within a Buildkite organization for a two-week free trial, after which a usage cost (based on the agent's capacity) is charged per minute.

To create your Mac hosted agent:

1. Navigate to the [cluster](/docs/clusters/manage-clusters) you want to run your pipeline in. To do this, select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster (for example, **Default cluster**) to which the hosted agent will be added.
1. Follow the [Create a queue](/docs/clusters/manage-queues#create-a-queue) > [Using the Buildkite interface](/docs/clusters/manage-queues#create-a-queue-using-the-buildkite-interface) instructions to begin creating your hosted agent within its own queue.

    As part of this process:
    * In the **Select your agent infrastructure** section, choose **Hosted**.
    * Follow the relevant sub-steps for configuring your hosted agent.

1. Make your pipelines use this hosted agent by default, by ensuring its queue is the _default queue_. This should be indicated by **(default)** after the queue's key on the cluster's **Queues** page. If this is not the case and another queue is marked **(default)**:

    1. On the cluster's **Queues** page, select the queue with the hosted agent you just created.
    1. On the queue's **Overview** page, select the **Settings** tab to open this page.
    1. In the **Queue Management** section, select **Set as Default Queue**.

Your Buildkite hosted agent, as the new default queue, is now ready to use.
