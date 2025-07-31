# Buildkite Agent prioritization

Agent prioritization controls how Buildkite assigns jobs to available agents. Understanding how the job dispatch system works helps you optimize your agent configuration for better performance and resource utilization.

## Agent selection criteria

Several factors are evaluated by the Buildkite job dispatcher when selecting an agent to process a job. These factors can be priority-based, success-based or targeting constraints.

### Priority-based selection

Agent priority is the primary factor in job assignment:

* Agents with higher priority values are assigned jobs before lower priority agents
* Priority can be any integer value, with higher numbers indicating higher priority
* Agents with the default priority of `null` are assigned jobs last

### Success-based preference

Within agents of the same priority level, Buildkite favors agents with better track records. Our job dispatcher prefers agents that have most recently completed jobs successfully. This helps ensure jobs are assigned to more reliable agents and infrastructure. If the most successful agent is busy, the next most successful available agent is selected.

### Job targeting constraints

Jobs can be targeted to specific agents with agent tags that define queues and other capabilities.

## Setting agent priority

You can configure agent priority using several methods:

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

Agent priority allows you to apply sophisticated load balancing strategies within your infrastructure. Here are a few example strategies you might choose to implement:

### Basic load balancing

Distribute jobs evenly across multiple machines by setting different priorities on each machine:

**Machine A:**

```bash
buildkite-agent start --priority 3 --tags "queue=ci-builds" --name "machine-a3"
buildkite-agent start --priority 2 --tags "queue=ci-builds" --name "machine-a2"
buildkite-agent start --priority 1 --tags "queue=ci-builds" --name "machine-a1"
```

**Machine B:**

```bash
buildkite-agent start --priority 3 --tags "queue=ci-builds" --name "machine-b3"
buildkite-agent start --priority 2 --tags "queue=ci-builds" --name "machine-b2"
buildkite-agent start --priority 1 --tags "queue=ci-builds" --name "machine-b1"
```

This configuration ensures scheduled jobs in the `ci-builds` queue are distributed across agents equally using matching priority levels.

### Resource-based prioritization

Prioritize agents based on their hardware capabilities:

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

Increase resource utilization density on self-hosted infrastructure by configuring agents with overlapping capabilities that can handle multiple job types based on priority and availability.

#### Agent configuration

Set up agents with overlapping tags where some agents can handle multiple job types:

**Dedicated release agents (higher priority):**

```bash
buildkite-agent start --priority 5 --tags "queue=ci-builds,build_type=release"
buildkite-agent start --priority 5 --tags "queue=ci-builds,build_type=release"
buildkite-agent start --priority 5 --tags "queue=ci-builds,build_type=release"
```

**Flexible agents (lower priority, multiple capabilities):**

```bash
buildkite-agent start --priority 1 --tags "queue=ci-builds,build_type=normal,build_type=release"
buildkite-agent start --priority 1 --tags "queue=ci-builds,build_type=normal,build_type=release"
```

#### Pipeline configuration

Configure your pipelines with higher priority jobs for "release" steps, while also targeting the specific agent tags:

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

**Normal development builds:**

```yaml
steps:
  - command: "make test"
    priority: 1
    agents:
      queue: "ci-builds"
      build_type: "normal"
```
{: codeblock-file="pipeline.yml"}

#### How spillover works

This configuration creates a spillover system that operates as follows:

1. High-priority "release" jobs are handled by dedicated `build_type=release` agents first
2. When these dedicated agents are all busy, "release" jobs can spillover to flexible agents that have both `build_type=normal` and `build_type=release` tags
3. Higher priority "release" jobs will always be processed before lower priority "normal" jobs, regardless of which jobs were created first
4. Flexible agents handle "normal" jobs when there is sufficient capacity for high-priority "release" jobs
