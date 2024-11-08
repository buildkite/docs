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

Mobile Delivery Cloud uses [Buildkite hosted agents](/docs/pipelines/hosted-agents/overview) for [Mac](/docs/pipelines/hosted-agents/mac), which are configured through a [_cluster_](/docs/pipelines/glossary#cluster). Clusters provide a mechanism to organize your pipelines and agents together, such that the pipelines associated with a given cluster can _only_ be built by the agents (defined within [_queues_](/docs/pipelines/glossary#queue)) in the same cluster.
