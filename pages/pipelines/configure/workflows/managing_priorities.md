# Job prioritization

By default, jobs are dispatched (taken from the queue and assigned to an agent) on a first-in-first-out basis. However, job priority and pipeline upload time can affect that order.

This is not the case for [Buildkite hosted agents](/docs/pipelines/hosted-agents), where jobs are assigned and dispatched at the time they are executed.

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

Job priority is considered before jobs are dispatched to [agent queues](/docs/agent/v3/queues), so jobs with higher priority are assigned before jobs with lower priority, regardless of which has been longest in the queue. Priority only applies to command jobs, including plugin commands.

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

The `emergency fix` step runs before _any step of any other running pipeline_ within your organization, unless one of these other pipeline steps has a priority greater than 100. If all available agents are running jobs, an appropriate agent will run the `emergency fix` step _only_ after its current job completes running.

Prioritizing whole builds comes in handy when you need to reduce the number of agents (for example, to reduce costs over a weekend due to fewer available team members) but want to ensure any builds created on a critical pipeline are not left waiting for agents to run their jobs.

## Job dispatch precedence

Jobs are dispatched in the following order:

1. Job priority in descending order, highest number to lowest (`priority`)
1. Date and time scheduled in ascending order, oldest to most recent (`scheduled_at`). Note that jobs inherit `scheduled_at` from pipeline upload jobs, meaning jobs that are uploaded by a pipeline in an older build will be dispatched before builds created after that, and the value of `scheduled_at` cannot be modified.
1. Upload order in pipeline, first to last.
1. Internal id in ascending order, used as a tie breaker if all other value are the same, meaning older jobs will be dispatched first.

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
