# Controlling Concurrency in Buildkite Pipelines

## Introduction
Controlling concurrency is crucial in Continuous Integration/Continuous Deployment (CI/CD) pipelines to prevent tasks from colliding and to manage the orderly execution of jobs. This document explores various mechanisms offered by Buildkite to control concurrency efficiently, ensuring seamless deployment, application releases, and infrastructure tasks. Readers will gain insights into concurrency limits, concurrency groups, advanced concurrency control techniques, and more.

## Intended Audience
This document is intended for users familiar with Buildkite and general CI/CD concepts. Readers should have a basic understanding of pipeline configuration. For those new to these concepts, introductory resources and a glossary of terms are recommended.

## Basic Concurrency Control

### Concurrency Limits
Concurrency limits specify the number of jobs that can run concurrently. These are set per step and apply only to jobs created from that specific step. Setting a concurrency limit of `1` ensures exclusivity, even in the presence of available agents.

Concurrency limits can be set in your Buildkite `pipeline.yml` file by adding a `concurrency` attribute. When doing so, including a `concurrency_group` attribute is also necessary to extend its use across other pipelines.

> **Note:** If you receive an error about a missing `concurrency_group_id`, it indicates the absence of the `concurrency_group` attribute on the step with a `concurrency` attribute.

### Concurrency Groups
Concurrency groups are labels that manage concurrency across multiple Buildkite jobs by applying concurrency limits. Group labels become available to all pipelines within an organization and control job execution flow.

Concurrency groups function as queues, processing jobs in the order they enter. Once a job in an "active" state transitions to a "terminal" state (e.g., `finished` or `canceled`), it is removed, allowing the next job in the queue to proceed.

"Active" job states include `limiting`, `limited`, `scheduled`, `waiting`, `assigned`, `accepted`, `running`, `canceling`, and `timing out`.

An example of a command step that controls deployments:

```yaml
- command: 'deploy.sh'
  label: '🚀 Deploy production'
  branches: 'main'
  agents:
    deploy: true
  concurrency: 1
  concurrency_group: 'our-payment-gateway/deploy'
```
{: codeblock-file="pipeline.yml"}

Ensure `concurrency_group` names are unique unless accessing shared resources. Unique names help maintain independent concurrency groups.

## Advanced Concurrency Control

### Concurrency and Parallelism
In scenarios where strict concurrency is required alongside parallel execution of jobs, *concurrency gates* can be used. Concurrency gates regulate entry and ensure designated steps operate sequentially, while others run in parallel within specified limits.

Example setup ensuring sequential deployment while allowing parallel test execution:

```yaml
steps:
  - command: echo "Running unit tests"
    key: unit-tests

  - command: echo "--> Start of concurrency gate"
    concurrency_group: gate
    concurrency: 1
    key: start-gate
    depends_on: unit-tests

  - wait

  - command: echo "Running deployment to staging environment"
    key: stage-deploy
    depends_on: start-gate

  - command: echo "Running e2e tests after the deployment"
    parallelism: 3
    depends_on: [stage-deploy]
    key: e2e

  - wait

  - command: echo "End of concurrency gate <--"
    concurrency_group: gate
    concurrency: 1
    key: end-gate

  - command: echo "This and subsequent steps run independently"
    depends_on: end-gate
```
{: codeblock-file="pipeline.yml"}

### Controlling Command Order
Steps in the same concurrency group execute in the order they were added, known as the `ordered` method. This is advantageous for sequential deployments but may hinder scenarios involving limited resources.

Setting the `concurrency_method` to `eager` relaxes this order, optimizing resource usage.

```yaml
steps:
  - command: echo "Using a limited resource, only 10 at a time, no order preference"
    concurrency_group: saucelabs
    concurrency: 10
    concurrency_method: eager
```
{: codeblock-file="pipeline.yml"}

### Concurrency and Prioritization
When `eager` concurrency is applied along with [job prioritization](docs/pipelines/managing-priorities), higher priority jobs will occupy available concurrency slots before others.

## Conclusion
Controlling concurrency in Buildkite helps streamline job execution and resource management across CI/CD pipelines. By effectively utilizing concurrency limits, groups, gates, and respecting job priorities, users ensure that their pipelines run efficiently while avoiding resource contention.