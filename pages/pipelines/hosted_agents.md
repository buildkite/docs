# Buildkite hosted agents

Buildkite hosted agents provides a fully-managed platform on which you can run your agents, so that you don't have to manage agents in your own self-hosted environment.

With hosted agents, Buildkite handles infrastructure management tasks, such as provisioning, scaling, and maintaining the servers that run your agents.

## Hosted agent types

Buildkite offers both [macOS](/docs/pipelines/hosted-agents/macos) and [Linux](/docs/pipelines/hosted-agents/linux) hosted agents.

Usage of all instance types is billed on a per-minute basis.

Every Buildkite hosted agent within a cluster benefits from hypervisor-level isolation, ensuring robust separation between each instance.

## Creating a Buildkite hosted queue

You can set up distinct queues for your Buildkite hosted agents (known as _Buildkite hosted queues_), each configured with a specific type and size of hosted agent, to efficiently manage jobs with varying requirements. Learn more about how to do this in [Create a Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue).

For example you may have two queues set up:

- `mac_medium_28gb`
- `mac_large_56gb`

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/clusters).

- Configuring queues in general, in [Manage queues](/docs/pipelines/clusters/manage-queues).

## Using GitHub repositories in your hosted agent pipelines

Buildkite hosted agent services support both public and private repositories. Learn more about setting up code access in [Hosted agent code access](/docs/pipelines/hosted-agents/code-access).

## Migrating your pipelines to hosted agent services

Learn more about migrating existing pipelines to Buildkite hosted agent services in [Hosted agent pipeline migration](/docs/pipelines/hosted-agents/pipeline-migration).

## Accessing machines through a terminal

When a Buildkite hosted agent machine is running (during a pipeline build) you can access the machine through a terminal. Learn more about this feature in [Hosted agents terminal access](/docs/pipelines/hosted-agents/terminal-access).

## Using cache volumes

Buildkite's [macOS](/docs/pipelines/hosted-agents/macos) and [Linux](/docs/pipelines/hosted-agents/linux) hosted agents both provide support for _cache volumes_. Learn more about this feature in [Cache volumes](/docs/pipelines/hosted-agents/cache-volumes), noting that the [container cache](/docs/pipelines/hosted-agents/cache-volumes#container-cache) feature component is only supported by Linux hosted agents.

## Remote Docker builders

Customers on the [Enterprise plan](https://buildkite.com/pricing/) have automatic access to the [remote Docker builders](/docs/pipelines/hosted-agents/remote-docker-builders) feature, which are dedicated machines purpose built to build Docker images. This feature substantially speeds up the build times of pipelines that need to build Docker images.

## Secret management

_Buildkite secrets_ is a Buildkite secrets management feature designed for Buildkite hosted agents, and is available for self-hosted agents too.

This feature can be used to manage secrets such as API credentials or SSH keys for hosted agents. Learn more about this feature in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets).
