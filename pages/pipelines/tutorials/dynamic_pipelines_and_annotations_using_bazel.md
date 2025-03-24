# Creating dynamic pipelines and build annotations using Bazel

This tutorial takes you through the process of creating dynamic pipelines and build annotations in Buildkite Pipelines, using [Bazel](https://www.bazel.build/) as the build tool. If you are not already familiar with:

- How the Bazel build tool can integrate with Buildkite, learn more about this in the [Using Bazel with Buildkite tutorial](/docs/pipelines/tutorials/bazel), which uses a Buildkite pipeline to build a simple Bazel example.
- The basics of Buildkite Pipelines, run through the [Pipelines getting started tutorial](/docs/pipelines/getting-started) first, which explains Buildkite Pipelines' [architecture](/docs/pipelines/getting-started#understand-the-architecture) and [agent setup](/docs/pipelines/getting-started#set-up-an-agent), and builds a simple pipeline.

The tutorial uses an example Python project (built with Bazel) whose Buildkite pipeline is initially uploaded at the start of its build and runs its `main` Python target. The `main` target creates additional Buildkite pipeline steps (in JSON format), which are then uploaded to your Buildkite pipeline. As part of the same pipeline build, Buildkite continues to build these additional pipeline steps, which in turn build and test an emoji library.

Buildkite pipelines that generate new pipeline steps dynamically like this, which are then uploaded to run as part of the same pipeline build, are known as [_dynamic pipelines_](/docs/pipelines/configure/dynamic-pipelines).

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a 30-day free trial account</a>.

    When you create a new organization as part of sign-up, you'll be guided through a flow to create and run a starter pipeline. Complete that before continuing.

- To enable the YAML steps editor in Buildkite:

    * Select **Settings** > **YAML Migration** to open the [YAML migration settings](https://buildkite.com/organizations/~/pipeline-migration).
    * Select **Use YAML Steps for New Pipelines**, then confirm the action in the modal.

- [Git](https://git-scm.com/downloads). This tutorial uses GitHub, but Buildkite can work with any version control system.

## Set up your hosted agent

Buildkite Pipelines requires an [agent](/docs/agent/v3) running Bazel to build this pipeline. You can set up your own [self-hosted agent](/docs/agent/v3/installation) to do this. However, you can get up and running more rapidly by setting up a [Buildkite hosted agent](/docs/pipelines/hosted-agents/overview) running [macOS](/docs/pipelines/hosted-agents/macos), instead.

Unlike [Linux hosted agents](/docs/pipelines/hosted-agents/linux), which would require you to create and use an [agent image](/docs/pipelines/hosted-agents/linux#agent-images) to install Bazel, along with other configurations to ensure that Bazel runs successfully on the agent, [macOS hosted agents](/docs/pipelines/hosted-agents/macos) already come pre-installed with Bazel and ready to run Bazel.

> 📘 Already running an agent
> If you're already running an agent, skip to the [next step on creating a pipeline](#create-a-pipeline).

All agents are configured through a [_cluster_](/docs/pipelines/glossary#cluster), which provide a mechanism to organize your pipelines and agents together, such that the pipelines associated with a given cluster can _only_ be built by the agents (defined within [_queues_](/docs/pipelines/glossary#queue)) in the same cluster.

By default, Buildkite organizations have one cluster, named **Default cluster** with a single self-hosted queue, named **default-queue**, noting that a cluster maintainer or Buildkite organization administrator can customize these default names.

You need at least one Buildkite hosted agent queue configured to run a build.

You can create the first [Buildkite hosted agent](/docs/pipelines/hosted-agents/overview) for [macOS](/docs/pipelines/hosted-agents/macos) within a Buildkite organization for a two-week free trial, after which a usage cost (based on the agent's capacity) is charged per minute.

### Create a Buildkite hosted agent for macOS

If you already have configured a Buildkite hosted agent for macOS, skip to the [next step on creating a pipeline](#create-a-pipeline).

To create your macOS hosted agent:

1. Navigate to the [cluster](/docs/clusters/manage-clusters) you want to run your pipeline in. To do this, select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster (for example, **Default cluster**) to which the hosted agent will be added.
1. Follow the [Create a Buildkite hosted queue](/docs/clusters/manage-queues#create-a-buildkite-hosted-queue) > [Using the Buildkite interface](/docs/clusters/manage-queues#create-a-buildkite-hosted-queue-using-the-buildkite-interface) instructions to begin creating your hosted agent within its own queue.

    As part of this process:
    * Give this queue an intuitive **key** and **description**, for example, **buildkite-macos-hosted-queue** and **Buildkite macOS hosted queue**, respectively.
    * In the **Select your agent infrastructure** section, select **Hosted**.
    * Select **macOS** as the **Machine type** and **Small** for the **Capacity**.

1. Make your pipelines use your new macOS hosted agent by default, by ensuring its queue is the _default queue_. This should be indicated by **(default)** after the queue's key on the cluster's **Queues** page. If this is not the case and another queue is marked **(default)**:

    1. On the cluster's **Queues** page, select the queue with the hosted agent you just created.
    1. On the queue's **Overview** page, select the **Settings** tab to open this page.
    1. In the **Queue Management** section, select **Set as Default Queue**.

Your Buildkite macOS hosted agent, as the new default queue, is now ready to use.

## Create a pipeline

Next, you'll create a new pipeline that builds an [example Python project with Bazel](https://github.com/cnunciato/bazel-buildkite), which in turn, creates additional dynamically-generated steps in JSON format that Buildkite runs to build and test an emoji library.

To create this pipeline:

1. [Add a new pipeline](https://buildkite.com/new) in your Buildkite organization, using `https://github.com/cnunciato/bazel-buildkite.git` as the Git Repository value.
1. On the **New Pipeline** page, select the cluster you [created the hosted agent for macOS](#set-up-your-hosted-agent-create-a-buildkite-hosted-agent-for-macos) in.
1. If necessary, provide a **Name** for your new pipeline, then leave all other fields with their pre-filled default values, and select **Create Pipeline**. This associates the example repository with your new pipeline, and adds a step to upload the full pipeline definition from the repository.
1. On the next page showing your pipeline name, select **New Build**. In the resulting dialog, create a build using the pre-filled details.

    1. In the **Message** field, enter a short description for the build. For example, **My first build**.
    1. Select **Create Build**.

