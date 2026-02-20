# Linux hosted agents

Buildkite's Linux hosted agents are:

- [Buildkite Agents](/docs/agent) hosted by Buildkite that run in a Linux environment.

- Configured as part of a _Buildkite hosted queue_, where the Buildkite hosted agent's machine type is Linux, has a particular [size](#sizes) to efficiently manage jobs with varying requirements, and comes pre-installed with software in the form of [agent images](#agent-images), which can be [customized with other software](/docs/agent/buildkite-hosted/linux/custom-base-images).

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/security/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/security/clusters), as well as [Manage queues](/docs/agent/queues/managing).

- How to configure a Linux hosted agent in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).

- The [concurrency](#concurrency) and [security](#security) of Linux hosted agents.

## Sizes

Buildkite offers a selection of Linux instance types (each based on a different combination of size and architecture, known as an _instance shape_), allowing you to tailor your hosted agent resources to the demands of your jobs. The architectures supported include AMD64 (x64_86) and ARM64 (AArch64).

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

Note the following about Linux hosted agent instances.

- Extra large instances are available on request.

- To accommodate different workloads, instances are capable of running up to 8 hours.

If you need extra large instances, or longer running hosted agents (over 8 hours), please contact Support at support@buildkite.com.

## Concurrency

Linux hosted agents can operate concurrently when running your Buildkite pipeline jobs.

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_concurrency_explanation' %>

The number of Linux hosted agents (of a [Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue)) that can process your pipeline jobs concurrently is calculated by your Buildkite plan's _maximum combined vCPU_ value divided by your [instance shape's](#sizes) _vCPU_ value. See the [Buildkite pricing](https://buildkite.com/pricing/) page for details on the **Linux Concurrency** that applies to your plan.

For example, if your Buildkite plan provides you with a maximum combined vCPU value of up to 48, and you've configured a Buildkite hosted queue with the `LINUX_AMD64_4X16` (Medium AMD64) [instance shape](#sizes), whose vCPU value is 4, then the number of concurrent hosted agents that can run jobs on this queue is 12 (that is, 48 / 4 = 12).

When concurrency limits are exceeded, additional jobs will be queued until sufficient capacity becomes available.

## Security

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_security_explanation' %>

## Agent images

Buildkite provides a Linux agent image pre-configured with common tools and utilities to help you get started quickly. This image also provides tools required for running jobs on hosted agents.

The image is based on Ubuntu 22.04 and includes the following tools:

- docker
- docker-compose
- docker-buildx
- git-lfs
- node
- aws-cli

You can customize the image that your hosted agents use by [creating an agent image](/docs/agent/buildkite-hosted/linux/custom-base-images).
