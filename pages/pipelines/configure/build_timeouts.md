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

## Updating timeouts during a job

You can dynamically update a command job's timeout while it is running using the `buildkite-agent job update` command. This is useful when a job learns more about how long it should take during execution, for example, after completing a setup phase.

To update the timeout for the current job:

```bash
buildkite-agent job update timeout 20
```

You can also pipe the value from STDIN:

```bash
echo 20 | buildkite-agent job update timeout
```

This command can be used to reduce an existing timeout, extend it, or set a new timeout on a job that doesn't have one. Updated timeouts are enforced on the server and can take up to two minutes to be enforced.

Jobs with a timeout can extend the timeout by up to 60 minutes beyond the original timeout. For example, a job with a `timeout_in_minutes` of 60 can be extended to a maximum of 120 minutes. Repeated updates cannot exceed this cap, as it is always calculated from the original step timeout. Jobs without a timeout are not subject to the extension cap, but are still subject to the pipeline and organization maximum timeout limits.

Timeout updates are also subject to the same maximum timeout limits that apply when a job is created. The updated timeout cannot exceed:

- The pipeline's **Maximum Command Step Timeout**, if set
- The organization's **Maximum Command Step Timeout**, if set
- Four hours on the Personal plan (Pro and Enterprise plans have no plan-level limit)

If the updated timeout exceeds any of these limits, the update is rejected.

The following additional constraints apply:

- Only command jobs can be updated. Trigger steps and block steps are not supported.
- Jobs can only be updated before they finish. Once a job reaches a terminal state, the timeout can no longer be changed.
- The timeout value must be a positive integer in minutes. Setting the timeout to `0` is not allowed, as this would remove timeout protection.

Timeout updates are recorded in the job's activity timeline, showing the previous and new timeout values.

## Scheduled job expiration

Scheduled job expiration helps you avoid having lingering jobs that are never assigned to an agent or run. This expiration time is calculated from when a job is created, not scheduled.

By default, jobs expire (are canceled) when not picked up for 30 days. This will cause the corresponding build to fail.

You can override the default by setting a shorter value in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.

Scheduled job expiration limits should not be confused with [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds). A scheduled build's jobs will still go through the [build states](/docs/pipelines/configure/defining-steps#build-states), and the timeout will apply once its individual jobs are in the scheduled state waiting for agents.

> 📘 Delays in job expiration
> The job expiration process runs hourly at 5 minutes past the hour. If a job's scheduled expiration time hasn't been reached when the process runs, the job will only expire when the process runs again in the next hour.
