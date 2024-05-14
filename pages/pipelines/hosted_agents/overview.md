# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your agents, so that you don't have to manage agents in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

## Hosted agent types

During the private trial phase, Buildkite is offering both Mac and Linux hosted agents. Buildkite plans to add support for Windows hosted agents by late 2024, as part of extending these services.

For detailed information about available agent sizes and configuration, refer to [Mac hosted agents](/docs/pipelines/hosted-agents/mac), and [Linux hosted agents](/docs/pipelines/hosted-agents/linux).

Usage of all instance types is billed on a per-minute basis.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

## Creating a hosted agent queue

You can set up distinct hosted agent queues, each configured with specific types and sizes to efficiently manage jobs with varying requirements.

For example you may have two queues set up:

- `mac_small_7gb`
- `mac_large_32gb`

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/clusters/overview#clusters-and-queues-best-practices-how-should-i-structure-my-queues).
- How to set up and create a Buildkite hosted agent queue in [Manage queues](/docs/clusters/manage-queues).

## Using GitHub repositories in your hosted agent pipelines

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

## Migrating your pipelines to hosted agent services

Learn more about migrating existing pipelines to Buildkite hosted agent services in [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## Accessing machines through a terminal

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).

## Secret management

_Buildkite secrets_ is a Buildkite secrets management feature designed for Buildkite hosted agents, and is available for self-hosted agents too.

This feature can be used to manage secrets such as API credentials or SSH keys for hosted agents. Learn more about this feature in [Buildkite secrets](/docs/pipelines/buildkite-secrets).
