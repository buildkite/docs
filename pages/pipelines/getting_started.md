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

Ensure you familiarize yourself with the **New Pipeline** page's functionality in [Understanding the New Pipeline page](#create-a-new-pipeline-understanding-the-new-pipeline-page) before proceeding to build some [example pipelines](#create-a-new-pipeline-example-pipelines).

### Understanding the New Pipeline page

<%= image "new-pipeline-page.png", alt: "New Pipeline page" %>

The **New Pipeline** page has the following fields:

- **Git scope**: Allows you to select from the following list of options:

    * Your GitHub account or organization.
    * A selection of **Buildkite Examples** to start with, which allows you to learn more about how Buildkite Pipelines builds projects for a variety of different use cases.
    * The **Use remote URL**, allows you to select a **GitLab**, **Bitbucket**, or **Any account**, for any other remotely accessible Git repository. The **Manage accounts** option further down this list also allows you to configure connections to these repository providers.
    * The **Connect GitHub account**, allows you to do just that. This option is useful if you signed up by email, and need to connect your GitHub account to the Buildkite platform, and generates the [same **Install Buildkite** step as part of the GitHub sign-up process](#before-you-start).

- **Repository**: Select the Git repository available to your selected **Git scope**. Upon selecting a repository:

    * The **Checkout using** option appears, where you can select between **SSH** or **HTTPS**.
    * If you selected a repository which is not one of the **Buildkite Examples**, then the **Build Triggers** section may appear, which shows the actions that trigger a build of this pipeline. You can disable this triggering by clearing the **Trigger builds when** checkbox.

- **Pipeline name**: Buildkite Pipelines automatically generates a name for your pipeline, which is based on your repository's name. However, you can change this default name using this field.
- **Description** ( _optional_ ): Enter a description for your pipeline, which will appear under the pipeline name on the main **Pipelines** page.
- **Default Branch**: The repository branch that your pipeline will build, unless instructed otherwise. Leave this unchanged for this tutorial.
- **Teams**: The Buildkite teams that have permission to build your pipeline.

    **Note:** If you just [signed up to Buildkite Pipelines](#before-you-start), then this field won't be visible, as it's only shown once [teams](/docs/platform/team-management) have been configured in your Buildkite account/organization. If this field is shown, leave it unchanged for this tutorial.

- **Cluster**: The Buildkite cluster whose configured agents will build your pipeline. Leave this unchanged for this tutorial.
- **YAML Steps editor**: This field allows you to define steps within your main Buildkite pipeline. To make things easier though, you can start with an initial pipeline from the **Template** dropdown. Using this dropdown, you can select from the **Helper templates**:

    * **Hello world**: For a simple example of how to structure commands in Buildkite pipeline YAML.
    * **Pipeline upload**: To upload a Buildkite pipeline stored in your repository.
    * **Example templates**: This section lists pipelines which are used to build example projects available from the **Repository** field, when the **Git scope** has been set to **Buildkite Examples**.

> 📘
> If you're already familiar with creating Buildkite pipelines and have created one at `.buildkite/pipeline.yml` from the root of your selected **Repository**, then ensure the **Pipeline upload** option has been selected from the **Template** dropdown of the **YAML Steps editor**. This option generates a pipeline step within your main Buildkite pipeline, which uploads the rest of your pipeline (defined in the `.buildkite/pipeline.yml` file from your repository), and uses the steps in that file to build your project.
> If you already have a Buildkite account/organization and user account, you can access the **New Pipeline** page by selecting **Pipelines** from the global navigation > **New pipeline**.

### Example pipelines

Ensure you're already familiar with the **New Pipeline** page's functionality (described in [Understanding the New Pipeline page](#create-a-new-pipeline-understanding-the-new-pipeline-page)) before proceeding.

If you're new to Buildkite Pipelines:

1. Ensure **Buildkite Examples** is selected in **Git scope** and select **Starter pipeline**.
1. In the **YAML Steps editor**, note the three steps that constitute this pipeline: `build`, `test`, and `deploy`, and the dependency order in which these steps' jobs will be run.

    **Note:** Without analyzing the pipeline syntax in too much detail, note the annotation-related command that's part of the `deploy` step.

1. Select **Create and run** to create your first **Starter pipeline**. This button creates your **Starter pipeline** and runs its first build.
1. Once your build has completed, check its **Annotations** tab, which displays the content of the repository's `.buildkite/annotation.md` file.

Once you've seen how Buildkite builds a simple pipeline like **Starter pipeline**, try creating and building other pipelines from the **Buildkite Examples** provided, which suit the technologies you've been working with.

> 📘
> For each repository of the **Buildkite Examples** selected in the **Repository** field, the pipeline shown is retrieved from the repository's `.buildkite/pipeline.yml file`.
> Also be aware that Buildkite pipelines commits nothing to your repository, unless you explicitly instruct your pipeline to do so.

More Buildkite example repositories are available from the [Buildkite Resources Examples](https://buildkite.com/resources/examples/) page.

## Next steps

That's it! You've got yourself up and running with Buildkite Pipelines and have already created and built some new pipelines!

As part of this setup process, behind the scenes, Buildkite Pipelines set you up with a few default configurations. These include the following:

- A _Buildkite cluster_: Buildkite Pipelines requires that all of its pipelines are managed through a [Buildkite cluster](/docs/pipelines/glossary#cluster), which is a security feature that's used to organize queues. When a new Buildkite account/organization is created, a single cluster is created, called **Default cluster**. Learn more Buildkite clusters from the [Clusters overview](/docs/pipelines/security/clusters).
- A _queue_: When the **Default cluster** is created, a default [queue](/docs/pipelines/glossary#queue), simply called **queue** is also created. When creating a personal Buildkite account, this queue is a _Buildkite hosted queue_, which runs _Buildkite hosted agents_. Learn more about queues from [Queues overview](/docs/agent/v3/queues) and Buildkite hosted agents from its [overview](/docs/agent/v3/buildkite-hosted) page.

While creating a new personal Buildkite account automatically sets you up to run Buildkite hosted agents, Buildkite also supports self-hosted agents, which you can manage in your own infrastructure. Learn more about the differences between these agent architectures in [Buildkite Pipelines architecture](/docs/pipelines/architecture).

Once you're familiar with building some Buildkite examples, next try [creating your own pipeline](/docs/pipelines/create-your-own).