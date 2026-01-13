# Creating dynamic pipelines and build annotations using Bazel

This tutorial takes you through the process of creating dynamic pipelines and build annotations in Buildkite Pipelines, using [Bazel](https://www.bazel.build/) as the build tool. If you are not already familiar with:

- How the Bazel build tool can integrate with Buildkite, learn more about this in the [Using Bazel with Buildkite tutorial](/docs/pipelines/tutorials/bazel), which uses a Buildkite pipeline to build a simple Bazel example.
- The basics of Buildkite Pipelines, run through the [Pipelines getting started tutorial](/docs/pipelines/getting-started) first, which explains Buildkite Pipelines' [architecture](/docs/pipelines/getting-started#understand-the-architecture) and [agent setup](/docs/pipelines/getting-started#set-up-an-agent), and builds a simple pipeline.

The tutorial uses an [Bazel Monorepo Example](https://github.com/buildkite/bazel-monorepo-example) project, whose program `pipeline.py` within the `.buildkite/` directory is one of the first things run by Buildkite Pipelines when the pipeline commences its build. This Python program creates additional Buildkite pipeline steps (in JSON format) that are then uploaded to the same pipeline, which Buildkite continues to run as part of the same pipeline build. Buildkite pipelines that generate new pipeline steps dynamically like this are known as [_dynamic pipelines_](/docs/pipelines/configure/dynamic-pipelines).

This `pipeline.py` Python program:

- Determines which initial Bazel packages need to be built, based on changes that have been committed to either the `app/` or `library/` files, and then proceeds to upload the relevant steps that builds these packages as part of the same pipeline build.
- Also runs [Bazel queries](https://bazel.build/query/guide) to determine which additional Bazel packages (defined within the packages' `BUILD.bazel` files) depend on these initial Bazel packages (for example, to build the `library/`'s dependency, which is `app/`), and then builds those additional packages too.

## Before you start

To complete this tutorial, you'll need to have done the following:

- Run through the [Getting started with Pipelines](/docs/pipelines/getting-started) tutorial, to familiarize yourself with the basics of Buildkite Pipelines.

- Make your own copy or fork of the [bazel-monorepo-example](https://github.com/buildkite/bazel-monorepo-example) repository within your own GitHub account, or Git-based setup.

## Set up an agent

Buildkite Pipelines requires an [agent](/docs/agent/v3) running Bazel to build this pipeline. You can [set up your own self-hosted agent](#set-up-an-agent-set-up-a-self-hosted-agent) to do this. However, you can get up and running more rapidly by [creating a Buildkite hosted agent for macOS](#set-up-an-agent-create-a-buildkite-hosted-agent-for-macos), instead.

> 📘 Already running an agent
> If you're already running an agent and its operating system environment is already running [Bazel](https://bazel.build/install), skip to the [next step on creating a pipeline](#create-a-pipeline).

### Create a Buildkite hosted agent for macOS

Unlike [Linux hosted agents](/docs/agent/v3/buildkite-hosted/linux), which would require you to install Bazel or Bazelisk on the agent (for example, using an [agent image](/docs/agent/v3/buildkite-hosted/linux#agent-images)), and implement other configurations to ensure that Bazel runs successfully on the agent (for example, ensuring Bazel runs as a non-root user), [macOS hosted agents](/docs/agent/v3/buildkite-hosted/macos) already come pre-installed with Bazelisk and ready to run Bazel.

You can create the first [Buildkite hosted agent](/docs/agent/v3/buildkite-hosted) for [macOS](/docs/agent/v3/buildkite-hosted/macos) within a Buildkite organization for a two-week free trial, after which a usage cost (based on the agent's capacity) is charged per minute.

> 📘
> If you're unable to access the Buildkite hosted agent feature or create one in your cluster, please contact support at support@buildkite.com to request access to this feature. Otherwise, you can set yourself up with a [self-hosted agent](#set-up-an-agent-set-up-a-self-hosted-agent) instead.

To create your macOS hosted agent:

1. Follow the [Create a Buildkite hosted queue](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue) > [Using the Buildkite interface](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue-using-the-buildkite-interface) instructions to begin creating your hosted agent within its own queue.

    As part of this process:
    * Give this queue an intuitive **key** and **description**, for example, **macos** and **Buildkite macOS hosted queue**, respectively.
    * In the **Select your agent infrastructure** section, select **Hosted**.
    * Select **macOS** as the **Machine type** and **Medium** for the **Capacity**.

1. Make your pipelines use your new macOS hosted agent by default, by ensuring its queue is the _default queue_. This should be indicated by **(default)** after the queue's key on the cluster's **Queues** page. If this is not the case and another queue is marked **(default)**:

    1. On the cluster's **Queues** page, select the queue with the hosted agent you just created.
    1. On the queue's **Overview** page, select the **Settings** tab to open this page.
    1. In the **Queue Management** section, select **Set as Default Queue**.

Your Buildkite macOS hosted agent, as the new default queue, is now ready to use.

### Set up a self-hosted agent

Setting up a self-hosted agent for this tutorial requires you to first install a Buildkite Agent in a self-hosted environment, and then install [Bazel](https://www.bazel.build/) to the same environment.

To set up a self-hosted agent for this tutorial:

1. Ensure you have followed the [Install and run a self-hosted agent](/docs/pipelines/getting-started#set-up-an-agent-install-and-run-a-self-hosted-agent) instructions from the [Getting started with Pipelines](/docs/pipelines/getting-started) tutorial to get set up with your self-hosted agent.

1. Install Bazel, by following the relevant instructions to install [Bazelisk (recommended)](https://bazel.build/install/bazelisk) or the relevant [Bazel package](https://bazel.build/install) to the same operating system environment that your self-hosted agent was installed to.

## Create a pipeline

Next, you'll create a new pipeline that builds an [example Python project with Bazel](https://github.com/buildkite/bazel-monorepo-example), which in turn creates additional dynamically-generated steps in JSON format that Buildkite runs to build and test a hello-world library.

To create this pipeline:

1. [Add a new pipeline](https://buildkite.com/new) in your Buildkite organization, select your GitHub account from the **Any account** dropdown, and specify [your copy or fork of the 'bazel-monorepo-example' repository](#before-you-start) for the **Git Repository** value.

1. On the **New Pipeline** page, select the cluster associated with the [agent you had set up with Bazel](#set-up-an-agent).

1. If necessary, provide a **Name** for your new pipeline.

1. Select the **Cluster** of the [agent you had previously set up](#set-up-an-agent).

1. If your Buildkite organization already has the [teams feature enabled](/docs/platform/team-management/permissions#manage-teams-and-permissions), choose the **Team** who will have access to this pipeline.

1. Leave all other fields with their pre-filled default values, and select **Create Pipeline**. This associates the example repository with your new pipeline, and adds a step to upload the full pipeline definition from the repository.

## Build the pipeline

Now that your pipeline has been set up and [created](#create-a-pipeline) in Buildkite Pipelines, it is ready to start being built, and we can start making commits to different areas of this project to see how these affect your dynamic pipeline builds.

### Step 1: Create the first build

1. On the next page after [creating](#create-a-pipeline) your pipeline, which shows its name, select **New Build**. In the resulting dialog, create a build using the pre-filled details.

    1. In the **Message** field, enter a short description for the build. For example, **My first build**.
    1. Select **Create Build**.

1. Once the build has completed, visit [your pipeline's build summary page](https://buildkite.com/~/bazel-monorepo-example), and verify that only the initial **Compute the pipeline with Python** step has been run.

### Step 2: Make changes to both an app and library file

1. Edit one of the files within both the `./app` and `./library` directories, and commit and push this change to its `main` branch, with an appropriate message (for example, **A change to both an app and a library file**).

1. On [your pipeline's build summary page](https://buildkite.com/~/bazel-monorepo-example), and notice that both the dynamically generated **Build and test //library/...** _and_ **Build and test //app/...** Bazel package build steps have also been run.

1. Note also the **Bazel Results** build annotation on this pipeline build's results, which are generated from Bazel builds using the [Bazel BEP Annotate Buildkite Plugin](https://github.com/buildkite-plugins/bazel-annotate-buildkite-plugin). This plugin is defined in the example Python project's `utils.py` file, which in turn, is used by the `pipeline.py` file.

### Step 3: Make changes to only an app file

1. Edit one of the files within the `./app` directory only, and commit and push this change to its `main` branch, with an appropriate message (for example, **A change to only an app file**).

1. On [your pipeline's build summary page](https://buildkite.com/~/bazel-monorepo-example) again, and notice that only the dynamically generated **Build and test //app/...** Bazel package build step is built.

### Step 4: Make changes to only a library file

1. Edit one of the files within the `./library` directory only, and commit and push this change to its `main` branch, with an appropriate message (for example, **A change to only a library file**).

1. On [your pipeline's build summary page](https://buildkite.com/~/bazel-monorepo-example), notice that both the dynamically generated **Build and test //library/...** _and_ **Build and test //app/...** Bazel package build steps have been built.

**Why?** According to each Bazel package's respective `BUILD.bazel` files in this project, `//app` has a dependency on `//library`. Therefore, if any change is made to a file in `./library`, then `./app` needs to be re-built to determine if the changes in `./library` also affect those in `./app`.

## Next steps

That's it! You've successfully configured a Buildkite agent, built a Buildkite pipeline with an example Python program that:

- Builds pipeline steps dynamically.
- Uses Bazel to define Bazel package dependencies, and runs [Bazel queries](https://bazel.build/query/guide) to determine which Bazel packages need to be built (based on their dependencies).
- Generates pipeline build annotations using the using the [Bazel BEP Annotate Buildkite Plugin](https://github.com/buildkite-plugins/bazel-annotate-buildkite-plugin). 🎉

Learn more about dynamic pipelines from the [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) page.
