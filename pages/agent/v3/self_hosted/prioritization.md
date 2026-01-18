# Buildkite Agent prioritization

Agent prioritization controls how Buildkite assigns jobs to available agents. Understanding how the job dispatch system works helps you optimize your agent configuration for better performance and resource utilization.

## Agent selection criteria

When Buildkite's job dispatch system is selecting an agent to process a job, the evaluation is based on several factors: agent's priority, success in running previous jobs, or targeting constraints.

### Priority-based selection

Agent priority is the primary factor in job assignment:

- Agents with higher priority values are assigned jobs before agents with lower priority values.
- Priority can be set to any integer value, with higher numbers indicating higher priority.
- Agents with the default priority of `null` are assigned jobs last.

### Success-based preference

When selecting from a pool of agents of the same priority level, Buildkite's job dispatch favors agents that have most recently completed jobs successfully. This helps ensure jobs are assigned to more reliable agents and infrastructure. If the most successful agent is busy, the next most successful available agent is selected.

### Job targeting constraints

Jobs can be targeted to specific agents using [agent tags](/docs/agent/v3/cli/reference/start#setting-tags) that define queues, and other capabilities.

## Setting agent priority

You can configure agent priority in the agent configuration file, by using a command line flag, or through an environment variable.

### Configuration file

Set the priority in your agent configuration file:

```ini
priority=5
```
{: codeblock-file="buildkite-agent.cfg"}

### Command line flag

Use the `--priority` flag when starting the agent:

```bash
buildkite-agent start --priority 5
```

### Environment variable

Set the priority using the `BUILDKITE_AGENT_PRIORITY` environment variable:

```bash
BUILDKITE_AGENT_PRIORITY=5 buildkite-agent start
```

## Load balancing strategies

Agent priority allows you to apply sophisticated load balancing strategies within your infrastructure. Here are a few example strategies you might choose to implement.

### Common load balancing

Distributing jobs evenly across multiple machines can be accomplished with the `--spawn-with-priority` command-line [option](/docs/agent/v3/cli/reference/start#spawn-with-priority):

**Machine A:**

```bash
buildkite-agent start --tags "queue=ci-builds" --spawn 5 --spawn-with-priority
```

**Machine B:**

```bash
buildkite-agent start --tags "queue=ci-builds" --spawn 5 --spawn-with-priority
```

**Machine C:**

```bash
buildkite-agent start --tags "queue=ci-builds" --spawn 5 --spawn-with-priority
```

This configuration will launch 5 agents on each machine (a total of 15 agents) that handle scheduled jobs in the `ci-builds` queue. Using the `--spawn-with-priority` option will launch each agent with a priority equal to their agent's index. Jobs will be equally distributed across agents running on all machines.

### Resource-based prioritization

If your environment has a mix of hardware capabilities, you can adjust agent priority to ensure jobs are assigned to your most capable hardware first. Here is how to prioritize jobs to agents with the highest hardware capabilities:

```bash
# High-performance agents running on larger hardware for intensive jobs
buildkite-agent start --priority 16 --tags "queue=ci-builds,performance=high,cpu=16-core"

# Standard agents running on standard hardware for regular jobs
buildkite-agent start --priority 8 --tags "queue=ci-builds,performance=standard,cpu=8-core"

# Lightweight agents running on smaller hardware for simple tasks
buildkite-agent start --priority 4 --tags "queue=ci-builds,performance=basic,cpu=4-core"
```

This configuration schedules jobs in the `ci-builds` queue onto larger hardware first, but still allows users to target jobs to a specific agent's hardware using [tags](/docs/pipelines/configure/defining-steps#targeting-specific-agents).

### Spillover strategy

Spillover strategy is an advanced strategy that greatly increases overall resource utilization on your self-hosted infrastructure. This strategy is applied by configuring agents with overlapping capabilities that can handle multiple job types based on priority and availability, while also leveraging job priorities to ensure higher priority jobs are always dispatched first.

#### Agent configuration for spillover strategy

Set up agents with overlapping tags where some agents can handle multiple job types:

**Dedicated release agents (higher priority):**

```bash
buildkite-agent start --spawn 3 --priority 5 --tags "queue=ci-builds,build_type=release"
```

**Flexible agents (lower priority, multiple capabilities):**

```bash
buildkite-agent start --spawn 5 --priority 1 --tags "queue=ci-builds,build_type=normal,build_type=release"
```

#### Pipeline configuration for spillover strategy

Configure your pipelines with higher priority jobs for "release" steps, while also targeting specific agent tags:

**High-priority release builds:**

```yaml
steps:
  - command: "make release"
    priority: 2
    agents:
      queue: "ci-builds"
      build_type: "release"
```
{: codeblock-file="pipeline.yml"}

**Regular-priority development builds:**

```yaml
steps:
  - command: "make test"
    priority: 1
    agents:
      queue: "ci-builds"
      build_type: "normal"
```
{: codeblock-file="pipeline.yml"}

#### How spillover strategy works

The configuration described in the previous section creates a spillover system that operates as follows:

1. High-priority "release" jobs are handled by dedicated `build_type=release` agents first.
1. When these dedicated agents are all busy, "release" jobs can spillover to flexible agents that have agent tags for both `build_type=normal` and `build_type=release`.
1. Higher priority "release" jobs will always be processed before lower priority "normal" jobs, regardless of which jobs were created first.
1. Flexible agents return to handling "normal" jobs when there is sufficient dedicated agent capacity for high-priority "release" jobs.

## Retry agent affinity

When a job fails on a [self-hosted queue](/docs/agent/v3/queues/managing#create-a-self-hosted-queue), and you retry it, Buildkite Pipelines will (by default) retry the job on any agent that recently finished job, such as the same agent that ran this failed job.

There may be scenarios where you might want to retry the job on a different agent, such as a [flaky test](/docs/test-engine/glossary#flaky-test), where environment settings that could have caused the job to fail are unlikely to be present. Therefore, you can configure your self-hosted queue to instead retry the job on a different agent, where such an agent is available.

This type of configuration is known as _agent affinity_, which has the following settings:

- **Prefer Warmest Agent**: The default setting, where jobs are retried on any agent that recently finished a job.
- **Prefer Different Agent**: Retry jobs on any agent which is different to the one that ran the previous attempt, if they're available.
