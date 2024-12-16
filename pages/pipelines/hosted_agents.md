# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your agents, so that you don't have to manage agents in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

## Hosted agent types

Buildkite offers both [Mac](/docs/pipelines/hosted-agents/mac) and [Linux](/docs/pipelines/hosted-agents/linux) hosted agents.

### Instance shapes for Linux hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

### Instance shapes for Mac hosted agents

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

Usage of all instance types is billed on a per-minute basis.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

## Creating a hosted agent queue

You can create a hosted queue using the [Buildkite interface](#create-a-hosted-queue-using-the-buildkite-interface), the [REST API](#create-a-hosted-queue-using-the-rest-api), or the [GraphQL API](#create-a-hosted-queue-using-the-graphql-api). Learn more about configuring hosted queues in [Manage queues](/docs/pipelines/clusters/manage-queues).

You can set up distinct hosted agent queues, each configured with specific types and sizes to efficiently manage jobs with varying requirements.

For example you may have two queues set up:

- `mac_small_7gb`
- `mac_large_32gb`

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues).

## Using GitHub repositories in your hosted agent pipelines

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

## Migrating your pipelines to hosted agent services

Learn more about migrating existing pipelines to Buildkite hosted agent services in [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## Accessing machines through a terminal

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).

## Secret management

_Buildkite secrets_ is a Buildkite secrets management feature designed for Buildkite hosted agents, and is available for self-hosted agents too.

This feature can be used to manage secrets such as API credentials or SSH keys for hosted agents. Learn more about this feature in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets).
