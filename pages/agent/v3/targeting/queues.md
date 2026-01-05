# Buildkite Agent job queues

Each pipeline has the ability to separate its jobs (define by the pipeline's steps) using queues. This allows you to isolate a set of jobs and/or agents, making sure that only specific agents will run jobs that are intended for them.

Common use cases for queues include deployment agents, and pools of agents for specific pipelines or teams.

## Setting an agent's queue

An agent's queue is configured using an [agent tag](/docs/agent/v3/cli-start#setting-tags) as a [queue tag](/docs/agent/v3/cli-start#the-queue-tag). This configuration can be set at the [command line](/docs/agent/v3/cli-start) when starting the agent, the agent's [configuration file](/docs/agent/v3/configuration), or through an environment variable.

Agents can only be configured to listen on a single queue within a cluster.

In the following example, the `--tags` flag of the `buildkite-agent start` command is used to configure this agent to listen on the `linux-medium-x86` queue, which is part of the **Testing** cluster:

```
buildkite-agent start --token "TESTING-AGENT-TOKEN-VALUE" --tags "queue=linux-medium-x86"
```

> 📘 Ensure you have already configured your cluster's agent tokens and queues
> Your [clusters](/docs/pipelines/clusters/manage-clusters) and [queues](/docs/agent/v3/targeting/queues/managing) should already be configured before starting your agents to target these queues.

### Setting up queues for unclustered agents

> 🚧 This section documents a deprecated Buildkite feature
> Learn more about unclustered agents and their tokens in [Unclustered agent tokens](/docs/agent/v3/self-hosted/unclustered-tokens).

For unclustered agents, queues are configured when starting a Buildkite agent. An unclustered agent can listen on a single queue or on multiple queues. For multiple queues, add as many extra `queue` tags as are required.

In the following example, the `--tags` flag of the `buildkite-agent start` command is used to configure this unclustered agent to listen on both the `development` and `testing` queues:

```
buildkite-agent start --token "UNCLUSTERED-AGENT-TOKEN-VALUE" --tags "queue=development,queue=testing"
```

## The default queue

If you don't configure a queue for your agent by [setting](/docs/agent/v3/cli-start#setting-tags) the [queue tag](/docs/agent/v3/cli-start#the-queue-tag) (for example, `queue=linux-medium-x86`), the agent will accept jobs from the default queue as if you had set (that is, `queue=default`).

> 📘 Clusters without a default queue configured
> If you start your agent without explicitly specifying an [existing queue in your cluster](/docs/agent/v3/targeting/queues/managing#setting-up-queues) _and_ a default queue is not configured in this cluster, then your agent will fail to start.
> You must either explicitly specify an existing queue within in your [cluster](/docs/pipelines/clusters/manage-clusters) when starting the agent, or have a default queue already configured in this cluster for the agent to start successfully.

## Targeting a queue

Target specific queues using the `agents` attribute on your pipeline steps or at the root level for the entire pipeline.

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

## Alternative methods

[Branch patterns](/docs/pipelines/configure/workflows/branch-configuration) are another way to control what work is done. You can use branch patterns to determine which pipelines and steps run based on the branch name.
