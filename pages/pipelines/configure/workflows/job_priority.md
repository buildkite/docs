# Job priority

Job priority affects the order in which runnable jobs are dispatched (assigned to agents). A job is runnable when it has reached the `scheduled` [job state](/docs/pipelines/configure/defining-steps#job-states), after its [dependencies](/docs/pipelines/configure/depends-on) and other scheduling constraints have been resolved. Priority does not make a job runnable or override those constraints.

For self-hosted agents, runnable jobs are dispatched on a first-in-first-out basis by default. However, job priority and pipeline upload time can affect that order.

You can set job priority for both [self-hosted agents](/docs/agent/self-hosted) and [Buildkite hosted agents](/docs/agent/buildkite-hosted). Hosted agents use priority on a best-effort basis without guaranteeing job start order.

## Prioritizing specific jobs

Job `priority` is 0 by default, you can prioritize or deprioritize jobs by assigning them a higher or lower integer value. For example:

```yml
steps:
  - command: "will-run-last.sh"
    priority: -1
  - command: "will-run-first.sh"
    priority: 1
```
{: codeblock-file="pipeline.yml"}

For self-hosted agents, higher-priority runnable jobs are assigned before lower-priority runnable jobs in the same [agent queue](/docs/agent/queues) that match the same available agent, regardless of which has been longest in the queue. Priority only applies to command jobs, including plugin commands.

## Prioritizing whole builds

The `priority` key can be set as a top-level value, which applies it to all steps in the pipeline that do not have their own `priority` key set. This is useful when an entire pipeline requires a higher priority than others. For example:

```yml
priority: 100
steps:
  - label: "emergency fix"
    command: "run_this_now.sh"
  - wait: ~
  - label: "this can wait"
    command: "tests.sh"
    priority: 1
```
{: codeblock-file="pipeline.yml"}

For self-hosted agents, once the `emergency fix` job is runnable, it takes precedence over lower-priority runnable jobs from other pipelines in the same queue that match the same available agent. Priority does not interrupt jobs already running. If all matching agents are busy, the job must wait for one to become available.

Prioritizing whole builds comes in handy when you need to reduce the number of agents (for example, to reduce costs over a weekend due to fewer available team members) but want to ensure any builds created on a critical pipeline are not left waiting for agents to run their jobs.

## Job dispatch precedence

For self-hosted agents, the following order applies only to jobs that are runnable at the time of dispatch, in the same queue, and match an available agent:

1. Job priority in descending order, highest number to lowest (`priority`)
1. Date and time scheduled in ascending order, oldest to most recent (`scheduled_at`). Note that jobs inherit `scheduled_at` from pipeline upload jobs, meaning jobs that are uploaded by a pipeline in an older build will be dispatched before builds created after that, and the value of `scheduled_at` cannot be modified.
1. Upload order in pipeline, first to last.
1. Internal id in ascending order, used as a tie breaker if all other values are the same, meaning older jobs will be dispatched first.

For hosted agents, Buildkite Pipelines prefers higher-priority jobs on a best-effort basis. Available capacity can affect job start order. This prevents a high-priority job that requires a large instance from blocking smaller, lower-priority jobs that fit the available capacity. The self-hosted dispatch ordering above does not describe how hosted agents order jobs with the same priority.

### Priority and dependencies

Jobs waiting on dependencies, wait steps, block steps, or concurrency limits do not compete for agent assignment until they become runnable. A job finishing and its dependent jobs becoming runnable are separate events. An agent can become available before a dependent job becomes runnable.

For example, a job with priority `1000` depends on a job that is still running. A job with priority `3` is already runnable and targets the same agent. When the running job finishes, the priority `3` job can be assigned before the priority `1000` job becomes runnable. Compare when jobs were assigned to agents, not when they started running, when investigating dispatch order.

Priority does not reserve an agent for dependent jobs or guarantee that a sequence of jobs runs without jobs from other builds in between, even when all jobs target the same agent. Use dependencies to enforce step order within a build, rather than relying on priority alone.

## Example

Here's an example of prioritizing jobs running on a default branch before pull request jobs:

```yaml
steps:
- label: "\:pipeline\:"
  agents: {queue: uploaders}
  command: |
    if [[ "$${BUILDKITE_BRANCH}" == "$${BUILDKITE_PIPELINE_DEFAULT_BRANCH}" ]]; then
      export PRIORITY=1
    else
      export PRIORITY=0
    fi
    buildkite-agent pipeline upload <<YAML
    steps:
    - label: priority $${PRIORITY}
      command: sleep 3
      priority: $${PRIORITY}
    YAML
```
{: codeblock-file="pipeline.yml"}
