# Getting started

👋 Welcome to Buildkite Pipelines! You can use Pipelines to build your dream CI/CD workflows on a secure, scalable, and flexible platform. This tutorial takes you through creating a basic pipeline from an example.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a free account</a>.

    When you create a new organization as part of sign-up, you'll be guided through a flow to create and run a starter pipeline. Complete that before continuing, and keep your agent running to continue using it in this tutorial.

- To enable the YAML steps editor in Buildkite:

  * Open the [YAML migration settings](https://buildkite.com/organizations/~/pipeline-migration) by selecting _Settings_ > _YAML Migration_.
  * Select _Use YAML Steps for New Pipelines_, then confirm the action in the modal.

- [Git](https://git-scm.com/downloads). This tutorial uses GitHub, but Buildkite can work with any version control system.

## Understand the architecture

Before creating a pipeline, take a moment to understand [Buildkite's architecture](/docs/pipelines/architecture) and the advantages it provides.

## Install and run an agent

The program that executes work is called an _agent_ in Buildkite. An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines. You need at least one agent to run builds.

>📘 Already running an agent
> If you're already running an agent, skip to the [next step](#create-a-pipeline).

To install and run an agent:

1. Decide where you want to run the agent.

    Most engineers start by running an agent on their local machine while playing around with pipeline definitions before setting up a long-term solution.

1. Follow the instructions for where you want to install the agent.

    To install locally, see:
   * [macOS](/docs/agent/v3/macos#installation)
   * [Windows](/docs/agent/v3/windows#automated-install-with-powershell)
   * [Linux](/docs/agent/v3/linux#installation)
   * [Docker](/docs/agent/v3/docker#running-using-docker)

     Or see [all installation options](/docs/agent/v3/installation).

     Ensure you configure the agent token, which connects the agent to your Buildkite account.

To confirm that your agent is running, and configured correctly with your credentials, go to [Agents](https://buildkite.com/organizations/~/agents). You should see a list of all agents linked to the account and their status.

## Create a pipeline

_Pipelines_ are how Buildkite represents a CI/CD workflow. You define each pipeline with a series of _steps_ to run. When you trigger a pipeline, you create a _build_, and steps are dispatched as _jobs_ to run on agents. Jobs are independent of each other and can run on different agents.

Next, you'll create a new pipeline based on one of the following example pipelines:

- [Bash example](https://github.com/buildkite/bash-example/)
- [PowerShell example](https://github.com/buildkite/powershell-example/)

Both result in the same behavior: the pipeline definition is uploaded from the repository (`.buildkite/pipeline.yml`), then a script runs that prints output to the logs.

To create a pipeline:

1. Select _Add to Buildkite_ for the appropriate example based on where your agent is running.

    For Bash:

    <a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/bash-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add Bash Example to Buildkite" class="no-decoration" width="160" height="30"></a>

    For PowerShell:

    <a class="inline-block" href="https://buildkite.com/new?template=https://github.com/buildkite/powershell-example" target="_blank" rel="nofollow"><img src="https://buildkite.com/button.svg" alt="Add PowerShell Example to Buildkite" class="no-decoration" width="160" height="30"></a>

1. Accept the pre-filled defaults by selecting *Create Pipeline*. This associates the example repository with your new pipeline.
1. Accept the pre-filled defaults by selecting _Save and Build_. This adds a step to upload the full pipeline definition from the repository.
1. In the modal that opens, create a build using the pre-filled details.

   1. Enter a message for the build. For example, _My first build_.
   1. Select _Create Build_.

The page for the build then opens and begins running:

<%= image "getting-started-first-build.png", alt: "The build page" %>

## Check the output

After triggering the build, you can view the output as it runs and the full results when complete. The output for each step shows in the job list.

Expand the row in the job list to view the output for a step. For example, selecting _Example Script_ shows the following:

<%= image "getting-started-log-output.png", alt: "The log output from the Example Script step" %>

In the output, you'll see:

- A pre-command hook ran and printed some text in the logs.
- The agent checked out the repository.
- The agent can access different environment variables shown in the job environment.
- The script ran and printed text to the logs and uploaded an image as an artifact of the build.

Beyond the log, select one of the other tabs to see the artifacts, a timeline breakdown, and the environment variables.

## Next steps

That's it! You've installed an agent, run a build, and checked the output. 🎉

We recommend you continue by [creating your own pipeline](/docs/pipelines/create-your-own).

