# Build timeouts

Build timeouts limit how long a job can run before being canceled, or how long a job can wait before being picked up by an agent. If a job exceeds the time limit, the job will automatically be canceled and the build will fail.

You can set timeouts on your builds through:

- Command step timeouts for running jobs
- Scheduled job expiration for jobs yet to be picked up

Organization-level timeouts can be set in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings):

<%= image "pipeline_timeout_settings.png", width: 1724/2, height: 736/2, alt: "Set timeout period for your jobs" %>

## Command timeouts

There is no separate pipeline-level timeout in Buildkite Pipelines as all timeouts are applied per [command step](/docs/pipelines/configure/step-types/command-step), not to the build as a whole. You can specify timeouts for individual command steps using the [`timeout_in_minutes`](/docs/pipelines/configure/step-types/command-step#timeout_in_minutes) attribute, or set the default and maximum timeouts at the organization or pipeline level.

The **Default Command Step Timeout** sets the default timeout in minutes for all command steps in a pipeline. This timeout can still be overridden in a command step.

The **Maximum Command Step Timeout** sets the maximum timeout in minutes for all command steps in a pipeline. Any command step without a timeout or with a timeout greater than this value will be set to this value.

Timeout precedence in the order of priority: step-level timeout → pipeline default → organization default. This behavior is distinct from [scheduled job expiration](#scheduled-job-expiration).

Timeouts apply to the whole job lifecycle, including hooks and artifact uploads. If a timeout is triggered while a command or hook is running, there's a 10-second grace period by default. You can change the grace period by setting the [`cancel-grace-period`](/docs/agent/v3/self-hosted/configure#cancel-grace-period) flag.

Note that command step timeouts don't apply to [trigger steps](/docs/pipelines/configure/step-types/trigger-step) and [block steps](/docs/pipelines/configure/step-types/block-step).

### Updating timeouts during a job

You can dynamically update a command job's timeout before it is finished, using the `buildkite-agent job update` command. This is useful when a job learns more about how long it should take during execution, for example, after completing a setup phase.

> 📘 Minimum Buildkite Agent version requirement
> To update a job's timeout, version 3.118.0 or later of the Buildkite Agent is required. Using earlier versions of the Buildkite Agent will result in pipeline failures.

To update the timeout for the current job:

```bash
buildkite-agent job update timeout 20
```

To extend the timeout of the current job:

```yml
steps:
  - label: ":timer_clock:"
    command: |
      echo "Extending job timeout by 10 minutes"
      buildkite-agent job update timeout "$$(( BUILDKITE_TIMEOUT + 10 ))"
    timeout_in_minutes: 1
```

To reduce the timeout of the current job:

```yml
steps:
  - label: ":timer_clock:"
    command: |
      echo "Reducing job timeout by 10 minutes"
      buildkite-agent job update timeout "$$(( BUILDKITE_TIMEOUT - 10 ))"
    timeout_in_minutes: 30
```

To set the timeout of job:

```yml
steps:
  - label: ":timer_clock:"
    command: |
      echo "Setting job's timeout to 50 minutes"
      buildkite-agent job update timeout 50
```

This command can be used to reduce an existing timeout, extend it (by up to an hour), or set a timeout on a job that doesn't have one. Updated timeouts are enforced on the server and can take up to two minutes to be enforced. Existing timeouts cannot be removed.

Timeout updates are recorded in the job's activity timeline, showing the previous and new timeout values.

The following limits apply to updating a job's timeout:

- The timeout value must be a positive integer, specified in minutes. The timeout is relative to the job's start time.
- Only command jobs can be updated.
- Jobs can only be updated before they finish. Once a job reaches a terminal state, the timeout can no longer be changed.
- Timeouts cannot be removed.
- The updated timeout can't exceed the pipeline's **Maximum Command Step Timeout**, the organization's **Maximum Command Step Timeout**, or four hours on the Personal plan (Pro and Enterprise plans have no plan-level limit). If the updated timeout exceeds any of these limits, the update is rejected.
- Jobs that have an initial timeout (`$BUILDKITE_TIMEOUT`) can extend their timeout by up to 60 minutes beyond that initial value. The initial timeout can come from a step-level `timeout_in_minutes`, a pipeline or organization default, a maximum timeout, or a plan-level limit. For example, a job with an initial timeout of 90 minutes can be extended to a maximum of 150 minutes. Repeated updates can't exceed this limit. Jobs without an initial timeout are not subject to this limit.

## Scheduled job expiration

Scheduled job expiration helps you avoid having lingering jobs that are never assigned to an agent or run. This expiration time is calculated from when a job is created, not scheduled.

By default, jobs expire (are canceled) when not picked up for 30 days. This will cause the corresponding build to fail.

You can override the default by setting a shorter value in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.

Scheduled job expiration limits should not be confused with [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds). A scheduled build's jobs will still go through the [build states](/docs/pipelines/configure/defining-steps#build-states), and the timeout will apply once its individual jobs are in the scheduled state waiting for agents.

> 📘 Delays in job expiration
> The job expiration process runs hourly at 5 minutes past the hour. If a job's scheduled expiration time hasn't been reached when the process runs, the job will only expire when the process runs again in the next hour.
