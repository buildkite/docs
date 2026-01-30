---
keywords: docs, pipelines, tutorials, getting started
---

# Getting started with Pipelines

👋 Welcome to Buildkite Pipelines! You can use Pipelines to build your dream CI/CD workflows on a secure, scalable, and flexible platform.

This getting started page is a tutorial that helps you understand Pipelines' fundamentals, by guiding you through the creation of a pipeline to automate builds of your own or an example project, which you could use as a starting point.

## Before you start

<%= render_markdown partial: 'pipelines/pipelines_tutorials_prereqs' %>

## Create a new pipeline

A [_pipeline_](/docs/pipelines/glossary#pipeline) is what represents a CI/CD workflow in Buildkite Pipelines. You define each pipeline with a series of [_steps_](/docs/pipelines/glossary#step) to run. When you trigger a pipeline, you create a [_build_](/docs/pipelines/glossary#build), and steps are dispatched as [_jobs_](/docs/pipelines/glossary#job), which are run on [agents](/docs/pipelines/glossary#agent). Jobs are independent of each other and can run on different agents.

If you signed up:

- With GitHub, the **New Pipeline** page's **Git scope** is set to your GitHub account, and its most recently updated repository is automatically selected in the **Repository** field.

    **Note:**

    * If you're new to Buildkite Pipelines and want to learn more about creating them, select **Or try an example** to choose from an [existing Buildkite pipeline example](#create-a-new-pipeline-example-pipelines) that you can build.

    * If your GitHub account is new and contains no repositories, the **Starter pipeline** of the **Buildkite Examples** is automatically selected.

- By email, the **New Pipeline** page presents the **Starter pipeline** of the **Buildkite Examples**.

<%= image "new-pipeline-page.png", alt: "New Pipeline page" %>

### Understanding the New Pipeline page

The **New Pipeline** page has the following fields:

- **Git scope**: Allows you to select from the following list of options:
    * Your GitHub account or organization.
    * A selection of **Buildkite Examples** to start with, which allows you to learn more about how Buildkite Pipelines builds projects for a variety of different use cases.
    * The **Use remote URL**, allows you to select a GitLab, Bitbucket, or any other remotely accessible Git repository. The **Manage accounts** option further down this list also allows you to configure connections to these repository providers.
    * The **Connect GitHub account**, allows you to do just that. This option is useful if you signed up by email, and need to connect your GitHub account to the Buildkite platform.
- **Repository**: Select the Git repository available to your selected **Git scope**. Upon selecting a repository, the **Checkout using** option appears, where you can select between **SSH** or **HTTPS**.
- **Pipeline name**: Buildkite Pipelines automatically generates a name for your pipeline in [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case), which is based on your repository's name. However, you can change the name in this field.

> 📘
> Alternatively, if you're familiar with creating Buildkite pipelines and have already created one at `.buildkite/pipeline.yml` from the root of your selected **Repository**, then select **Pipeline upload** from the **Template** drop-down of the **YAML Steps editor**, which generates a pipeline step that uploads the `.buildkite/pipeline.yml` pipeline file from this repository to Buildkite Pipelines, and uses the steps in that file to build your project.
> If you already have a Buildkite organization and user account, you can access the **New Pipeline** page by selecting **Pipelines** from the global navigation > **New pipeline**.

### Example pipelines

Important things to cover:

- Nothing is committed to the repo.
- The YAML file in the UI comes from the repos' existing .buildkite/pipeline.yml file.
- Link to https://buildkite.com/resources/examples/
- Explaining the New Pipeline dropdowns.

On next page of 'Create your own pipeline':

- Get rid of Continue running the agent
- In 'Define the steps', mention that the use can convert their existing pipeline from another CI provider to Buildkite Pipelines, and link through to that section.

To create a pipeline:

1. Select **Add to Buildkite** for the appropriate example based on where your agent is running.
    * For Bash:<br/>
        <a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/bash-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add Bash Example to Buildkite" class="no-decoration" width="160" height="30"></a><br/>
        (from the [Bash example](https://github.com/buildkite/bash-example/) GitHub repository)
    * For PowerShell:<br/>
        <a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/powershell-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add PowerShell Example to Buildkite" class="no-decoration" width="160" height="30"></a><br/>
        (from the [PowerShell example](https://github.com/buildkite/powershell-example/) GitHub repository)

    **Note:** Both of these example pipelines result in the same behavior—the pipeline definition is uploaded from the repository (`.buildkite/pipeline.yml`), then a script runs that prints output to the logs.

1. On the **New Pipeline** page, select the **Cluster** of the [agent you had previously set up](#set-up-an-agent).

1. If the **Team** field appears further down the page, this means that your Buildkite organization already has the [teams feature enabled](/docs/platform/team-management/permissions#manage-teams-and-permissions). Therefore, choose the **Team** who will have access to this pipeline.

1. Leave all fields with their pre-filled default values and select **Create Pipeline**. This associates the example repository with your new pipeline, and adds a step to upload the full pipeline definition from the repository.

    **Note:** If the **GitHub Webhook Setup** (or other webhook setup) page appears, just select **Skip Webhook Setup** to continue, as there is no need to set up a webhook as part of this tutorial.

1. On the next page showing your pipeline name, select **New Build**. In the resulting dialog, create a build using the pre-filled details.

   1. In the **Message** field, enter a short description for the build. For example, **My first build**.
   1. Select **Create Build**.

The page for the build then opens and begins running:

<%= image "getting-started-first-build.png", alt: "The build page" %>

## Check the output

After triggering the build, you can view the output as it runs and the full results when complete. The output for each step shows in the job list.

Expand the row in the job list to view the output for a step. For example, selecting **Example Script** shows the following:

<%= image "getting-started-log-output.png", alt: "The log output from the Example Script step" %>

In the output, you'll see:

- A pre-command hook ran and printed some text in the logs.
- The agent checked out the repository.
- The agent accessed different environment variables shown in the job environment.
- The script ran and printed text to the logs and uploaded an image as an artifact of the build.

Beyond the log, select one of the other tabs to see the artifacts, a timeline breakdown, and the environment variables.

## Next steps

That's it! You've installed an agent, run a build, and checked the output. 🎉

Now try [creating your own pipeline](/docs/pipelines/create-your-own).

## Understand the architecture

Before creating a pipeline, take a moment to understand Buildkite's architectures and the advantages they provide. Buildkite provides both a _hosted_ (as a _managed_ solution) and _self-hosted_ architecture for its build environments.

You can learn more about the differences between these architectures in [Buildkite Pipelines architecture](/docs/pipelines/architecture).

If you're already familiar with Buildkite Pipelines' architectures, continue on, bearing in mind that the remainder of this tutorial assumes that you already understand the fundamental differences between them.

## Set up an agent

The program that executes work is called an _agent_ in Buildkite. An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. The agent polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines, as well as part of [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted), which provides the quickest method to get up and running with Pipelines.

Buildkite agents connect to Buildkite through a [_cluster_](/docs/pipelines/glossary#cluster). Clusters provide a mechanism to organize your pipelines and agents together, such that the pipelines associated with a given cluster can _only_ be built by the agents (defined within [_queues_](/docs/pipelines/glossary#queue)) in the same cluster.

By default, new Buildkite organizations have one cluster, named **Default cluster** with a single queue, named with the key **default**. A cluster maintainer or Buildkite organization administrator can customize the cluster's name.

You need at least one agent configured within its own queue and cluster to run builds.

> 📘 Already running an agent
> If you're already running an agent, skip to the [next step on creating a pipeline](#create-a-pipeline).

### Create a Buildkite hosted agent

You can create the first [Buildkite hosted agent](/docs/agent/v3/buildkite-hosted) within a Buildkite organization for a two-week free trial, after which a usage cost (based on the agent's capacity) is charged per minute.

Before creating your Buildkite hosted agent, ensure you have a [cluster](/docs/pipelines/security/clusters/manage) (for example, **Default cluster**) you can connect this agent to.

> 📘
> If you're unable to access the Buildkite hosted agent feature or create one in your cluster, please contact support at support@buildkite.com to request access to this feature. Otherwise, you can set yourself up with a [self-hosted agent](#set-up-an-agent-install-and-run-a-self-hosted-agent) instead.

To create a hosted agent:

1. Navigate to the [cluster](/docs/pipelines/security/clusters/manage) you want to run your pipeline in. To do this, select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster (for example, **Default cluster**) to which the hosted agent will be added.
1. Follow the [Create a Buildkite hosted queue](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue) > [Using the Buildkite interface](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue-using-the-buildkite-interface) instructions to begin creating your hosted agent within its own queue.

    As part of this process:
    * In the **Select your agent infrastructure** section, select **Hosted**.
    * Follow the relevant sub-steps for configuring your hosted agent.

1. Make your pipelines use this hosted agent by default, by ensuring its queue is the _default queue_. This should be indicated by **(default)** after the queue's key on the cluster's **Queues** page. If this is not the case and another queue is marked **(default)**:

    1. On the cluster's **Queues** page, select the queue with the hosted agent you just created.
    1. On the queue's **Overview** page, select the **Settings** tab to open this page.
    1. In the **Queue Management** section, select **Set as Default Queue**.

Your Buildkite hosted agent, as the new default queue, is now ready to use. You can now skip to the [next step on creating a pipeline](#create-a-pipeline).

### Install and run a self-hosted agent

Before installing and running a self-hosted agent, ensure you have:

- a [cluster](/docs/pipelines/security/clusters/manage) (for example, **Default cluster**) you can connect this agent to,
- a [queue](/docs/agent/v3/queues/managing#create-a-self-hosted-queue) (for example, with the key **default**) to which the agent will be associated with, and
- the value of an [agent token](/docs/agent/v3/self-hosted/tokens) (for example, **Initial agent token**), which you can configure for the agent.

    Be aware that since [hosted agents](#set-up-an-agent-create-a-buildkite-hosted-agent) are managed by Buildkite, there is no need to create agent tokens for these types of agents.

To install and run an agent in your own self-hosted infrastructure (including your own computer):

1. Decide where you want to run the agent.

    Most engineers start by running an agent on their local machine while playing around with pipeline definitions before setting up a long-term solution.

1. Follow the instructions for where you want to install the agent.

    To install locally, see:
    * [macOS](/docs/agent/v3/self-hosted/install/macos#installation)
    * [Windows](/docs/agent/v3/self-hosted/install/windows#automated-install-with-powershell)
    * [Linux](/docs/agent/v3/self-hosted/install/linux#installation)
    * [Docker](/docs/agent/v3/self-hosted/install/docker#running-using-docker)

    Or see [all installation options](/docs/agent/v3/self-hosted/install).

    Ensure you configure the agent token, which connects the agent to your Buildkite account.

To confirm that your agent is running, and configured correctly with your credentials, go to [Agents](https://buildkite.com/organizations/~/agents). You should see a list of all agents linked to the account and their status.
