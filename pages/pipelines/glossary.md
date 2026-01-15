# Pipelines glossary

The following terms describe key concepts to help you use Pipelines.

## Agent

An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines. You need at least one agent to run builds.

To learn more, see the [Agent overview](/docs/agent/v3).

## Artifact

An artifact is a file generated during a build. You can keep artifacts in a Buildkite-managed storage service or a third-party cloud storage service like Amazon S3, Google Cloud Storage, or Artifactory. Common uses include storing assets like logs and reports, or passing files between steps.

To learn more, see [Build artifacts](/docs/pipelines/configure/artifacts).

## Build

A build is a single run of a pipeline. You can trigger a build in various ways, including through the dashboard, API, as the result of a webhook, on a schedule, or even from another pipeline using a trigger step.

## Cluster

A cluster groups [queues](#queue) of agents along with pipelines. Clusters allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

To learn more, see the [Clusters overview](/docs/pipelines/security/clusters).

## Dynamic pipeline

Dynamic pipelines define their steps at runtime using scripts, giving you the flexibility to only run the steps relevant to particular code changes and workflows.

Dynamic pipelines are helpful when you have a complex build process that requires different steps to execute based on runtime conditions, such as the branch, the environment, or the results of previous steps.

To learn more, see [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

## Ephemeral agent

An ephemeral agent is a Buildkite Agent that only operates for the duration in which it runs a [job](#job). Such an agent is disconnected either once its job is completed, or the agent's idle time period has been reached. An ephemeral agent is created when one of the following options has been used to [start the Buildkite Agent](/docs/agent/v3/cli/reference/start):

- `--acquire-job`
- `--disconnect-after-job`
- `--disconnect-after-idle-timeout`

Learn more about ephemeral agents in [Pause and resume an agent](/docs/agent/v3/queues/managing/pausing-and-resuming).

## Hook

A hook is a method of customizing the behavior of Buildkite through lifecycle events. They let you run scripts at different points of the agent or job lifecycle. Using hooks, you can extend the functionality of Buildkite and automate tasks specific to your workflow and requirements.

To learn more, see [Hooks](/docs/agent/v3/self-hosted/hooks).

## Job

A job is the execution of a command step during a build. Jobs run the commands, scripts, or plugins defined in the step.

A job can be in various states during its lifecycle, such as `pending`, `scheduled`, `running`, `finished`, `failed`, `canceled`, and others. These states represent the execution state of the job as it progresses through the build system.

To learn more, see [Job states](/docs/pipelines/configure/defining-steps#job-states).

## Pipeline

A pipeline is a container for modeling and defining workflows. They contain a series of steps to achieve goals like building, testing, and deploying software.

To learn more, see the [Pipeline overview](/docs/pipelines).

## Plugin

Plugins are small, self-contained pieces of extra functionality that help you customize Buildkite to your specific workflow. They modify command steps using hooks to perform actions like checking code quality, deploying to cloud services, or sending notifications.

Plugins can be open source and available for anyone to use or private for just your organization.

To learn more, see [Plugins](/docs/pipelines/integrations/plugins).

## Queue

A queue defines agents on which pipeline builds can run their jobs. Queues are configured within a [cluster](#cluster), where each queue defines a particular group of agents, isolating a set of your pipeline's jobs and the agents they run on. Typical uses for queues include separating deployment agents and pools of agents for specific pipelines or teams.

To learn more, see [Manage queues](/docs/agent/v3/queues/managing) and [Buildkite Agent job queues](/docs/agent/v3/queues).

## Step

A step describes a single, self-contained task as part of a pipeline. You define a step in the pipeline configuration using one of the following [step types](/docs/pipelines/configure/step-types):

- Command step: Runs one or more shell commands on one or more agents.
- Wait step: Pauses a build until all previous jobs have completed.
- Block step: Pauses a build until it's manually unblocked.
- Input step: Pauses a build until information has been collected from a user.
- Trigger step: Creates a build on another pipeline.
- Group step: Displays a group of sub-steps as one parent step.

A step can be in one of the following internal _states_, which the [Buildkite agent can retrieve](/docs/agent/v3/cli/reference/step#getting-a-step), when the step is ready to run, or is currently running:

- `ignored`: The step is ignored due to a conditional evaluation.
- `waiting_for_dependencies`: The step is waiting for its dependencies to complete.
- `ready`: The step is ready to run but hasn't started yet.
- `running`: The step is currently running.
- `failing`: The step is in the process of failing.
- `finished`: The step has completed execution—usually follows either the `running` or `failing` state.
- `canceled`: The step has been canceled—follows the `waiting_for_dependencies`, `ready`, `running`, or `failing` state.

Once a step's run has completed with a state of `finished`, the [step's outcome](/docs/agent/v3/cli/reference/step#getting-the-outcome-of-a-step) can be one of the following states:

- `neutral`: The passing or failure of the step's outcome is not relevant (for example, the outcome of a wait step).
- `passed`: The step's outcome is considered successful.
- `soft_failed`: The step's outcome is considered successful, but with a warning.
- `hard_failed`: The step's outcome is considered failed.
- `errored`: The step's outcome is considered failed because something happened to abort the step early.

A block or input step tracks the state of the build and its steps that ran before it, which can be `failed`, `passed`, or `running`.

To learn more, see [Defining steps](/docs/pipelines/configure/defining-steps).
