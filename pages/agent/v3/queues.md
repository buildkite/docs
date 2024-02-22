# Buildkite Agent job queues

Each pipeline has the ability to separate its jobs (define by the pipeline's steps) using queues. This allows you to isolate a set of jobs and/or agents, making sure that only specific agents will run jobs that are intended for them.

Common use cases for queues include deployment agents, and pools of agents for specific pipelines or teams.

## Setting an agent's queue

An agent's queue is configured using an [agent tag](/docs/agent/v3/cli-start#setting-tags) as a [queue tag](/docs/agent/v3/cli-start#the-queue-tag). This configuration can be set at the [command line](/docs/agent/v3/cli-start) when starting the agent, the agent's [configuration file](/docs/agent/v3/configuration), or through an environment variable.

Agents can only be configured to listen on a single queue within a cluster.

In the following example, the `--tags` flag of the `buildkite-agent start` command is used to configure this agent to listen on the `my-example-queue` queue, which is part of the _My cluster_ cluster:

```
buildkite-agent start --token "MY-CLUSTERS-AGENT-TOKEN-VALUE" --tags "queue=my-example-queue"
```

> 📘 Ensure you have already configured your cluster's agent tokens and queues
> Your [clusters](/docs/clusters/manage-clusters) and [queues](/docs/clusters/manage-queues) should already be configured before starting your agents to target these queues.

### Setting up queues for unclustered agents

> 🚧 This section documents a deprecated Buildkite feature
> Learn more about unclustered agents and their tokens in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

For unclustered agents, queues are configured when starting a Buildkite agent. Unclustered agent  can listen on a single queue or on multiple queues. You can add as many extra `queue` tags as are required.

In the below example using the `--tags` flag of the `buildkite-agent start` command, two queues are specified which will result in the agent listening on both the `building` and `testing` queues:

```
buildkite-agent start --tags "queue=building,queue=testing"
```

<%= image "agent-queues.png", width: 1182/2, height: 160/2, alt: "Screenshot of an agent's tags showing both building and testing queues" %>

## The default queue

If you don't configure a queue for your agent by [setting](/docs/agent/v3/cli-start#setting-tags) the [queue tag](/docs/agent/v3/cli-start#the-queue-tag) (for example, `queue=my-example-queue`), the agent will accept jobs from the default queue as if you had set (that is, `queue=default`).

> 📘 Clusters without a default queue configured
> If you start your agent without explicitly specifying an [existing queue in your cluster](/docs/clusters/manage-queues#setting-up-queues) _and_ a default queue is not configured in your cluster, then your agent will fail to start.
> Within in your [cluster](/docs/clusters/manage-clusters), either an existing queue must explicitly be specified or a default queue configured, for the agent to start successfully.

## Targeting a queue

Target specific queues using the `agents` attribute on your pipeline steps or at the root level for the entire pipeline.

For example, the following pipeline would run on the `priority` queue as determined by the root level `agents` attribute (and ignores the agents running the `default` queue). The `tests.sh` build step matches only agents running on the `deploy` queue.

```yaml
agents:
  queue: "priority"

steps:
  - command: echo "hello"

  - command: tests.sh
    agents:
      queue: "deploy"
```

## Alternative methods

[Branch patterns](/docs/pipelines/branch-configuration) are another way to control what work is done. You can use branch patterns to determine which pipelines and steps run based on the branch name.
