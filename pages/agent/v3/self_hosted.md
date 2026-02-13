# Self-hosted agents

Buildkite's self-hosted agents are [Buildkite agents](/docs/agent/v3) that you run in your own self-hosted environment or infrastructure, which could be servers that you host on-premises, or cloud-based services, such as AWS, Google Cloud, and within Kubernetes.

With self-hosted agents, you have control over managing infrastructure tasks, such as provisioning, scaling, security, and maintaining the servers that run your agents.

The following diagram provides an overview of how Buildkite Pipelines, which is a software-as-as-service (SaaS) platform known as the Buildkite platform, interacts with Buildkite agents in your own self-hosted infrastructure.

<%= image "buildkite-hybrid-architecture.png", alt: "Shows the hybrid architecture combining a SaaS platform with your infrastructure" %>

## Installation

You can install the agent on a wide variety of platforms, see the [installation instructions](/docs/agent/v3/self-hosted/install) for a full list and for information on how to get started.

## Starting the agent

To start an agent, you'll need an [agent token](/docs/agent/v3/self-hosted/tokens) associated with one of your Buildkite organization's [clusters](/docs/pipelines/security/clusters), along with a configured [self-hosted queue](/docs/agent/v3/queues) in that cluster. The agent token is passed to the agent using an environment variable or command line flag (with an optional queue tag), and the token will register itself with your Buildkite Pipeline's cluster and wait to accept jobs. Learn more about this process in [Assigning a self-hosted agent to a queue](/docs/agent/v3/queues#assigning-a-self-hosted-agent-to-a-queue).

## Configuration

The agent has a standard configuration file format on all systems to set meta-data, priority, etc. See the [configuration documentation](/docs/agent/v3/self-hosted/configure) for more details.

## Experimental features

Buildkite frequently introduces new experimental features to the agent. See [Agent experiments](/docs/agent/v3/self-hosted/configure/experiments) for the full list of available and promoted experiments.
