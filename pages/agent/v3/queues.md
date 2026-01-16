# Buildkite Agent job queues

Each [pipeline](/docs/pipelines/configure) has the ability to separate its jobs (define by the pipeline's steps) using queues. This allows you to isolate a set of jobs and/or agents, making sure that only specific agents will run jobs that are intended for them.

Common use cases for queues include deployment agents, and pools of agents for specific pipelines or teams.

## Assigning a self-hosted agent to a queue

A self-hosted agent can be assigned to a [self-hosted queue](/docs/agent/v3/queues/managing#create-a-self-hosted-queue) using an [agent tag](/docs/agent/v3/cli/reference/start#setting-tags) as a [queue tag](/docs/agent/v3/cli/reference/start#the-queue-tag) when the agent is started.

This configuration can be set at the [command line when starting the agent](/docs/agent/v3/cli/reference/start), the agent's [configuration file](/docs/agent/v3/self-hosted/configure), or through an environment variable.

Agents can only be assigned to a single self-hosted queue within a cluster.

In the following example, the `--tags` flag of the `buildkite-agent start` command is used to configure this agent to listen on the `linux-medium-x86` queue, which is part of the **Testing** cluster:

```
buildkite-agent start --token "TESTING-AGENT-TOKEN-VALUE" --tags "queue=linux-medium-x86"
```

> 📘 Ensure you have already configured your cluster's agent tokens and queues
> Your [clusters](/docs/pipelines/security/clusters/manage) and [queues](/docs/agent/v3/queues/managing) should already be configured before starting your agents to target these queues.

### The default self-hosted queue

If you don't assign a self-hosted agent to a [self-hosted queue](/docs/agent/v3/queues/managing#create-a-self-hosted-queue) by [setting](/docs/agent/v3/cli/reference/start#setting-tags) the agent's [queue tag](/docs/agent/v3/cli/reference/start#the-queue-tag) (for example, `queue=linux-medium-x86`) when it is started, the agent will accept jobs from the default self-hosted queue as if you had set (for example, `queue=default`).

> 📘 Clusters without a default self-hosted queue configured
> If you start a self-hosted agent without explicitly specifying an existing self-hosted queue in your cluster _and_ a default [self-hosted queue](/docs/agent/v3/queues/managing#create-a-self-hosted-queue) is not configured in this cluster, or your default queue is set to a [Buildkite hosted queue](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue), then your agent will fail to start.
> You must either explicitly specify an existing self-hosted queue within in your [cluster](/docs/pipelines/security/clusters/manage) when starting the agent, or have a default self-hosted queue already configured in this cluster for the agent to start successfully.

## Targeting a queue from a pipeline

Target specific queues (either [self-hosted](/docs/agent/v3/queues/managing#create-a-self-hosted-queue) or [Buildkite hosted](/docs/agent/v3/queues/managing#create-a-buildkite-hosted-queue) ones) using the `agents` attribute on your pipeline steps, or at the root level for the entire pipeline.

For example, the following pipeline would run on the `priority` queue as determined by the root level `agents` attribute (and ignores the agents running the `default` queue). The `tests.sh` build step matches only agents running on the `linux-medium-x86` queue.

```yaml
agents:
  queue: "priority"

steps:
  - command: echo "hello"

  - command: tests.sh
    agents:
      queue: "linux-medium-x86"
```

### Alternative methods

[Branch patterns](/docs/pipelines/configure/workflows/branch-configuration) are another way to control what work is done. You can use branch patterns to determine which pipelines and steps run based on the branch name.

## Setting up queues for unclustered agents

> 🚧 This section documents a deprecated Buildkite feature
> Learn more about unclustered agents and their tokens in [Unclustered agent tokens](/docs/agent/v3/self-hosted/unclustered-tokens).

For unclustered agents, queues are configured when starting a Buildkite agent. An unclustered agent can listen on a single queue or on multiple queues. For multiple queues, add as many extra `queue` tags as are required.

In the following example, the `--tags` flag of the `buildkite-agent start` command is used to configure this unclustered agent to listen on both the `development` and `testing` queues:

```
buildkite-agent start --token "UNCLUSTERED-AGENT-TOKEN-VALUE" --tags "queue=development,queue=testing"
```
