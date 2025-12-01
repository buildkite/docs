# Build timeouts

Build timeouts are limits on the maximum time a job can run before being canceled, or how long a job can wait before being picked up by an agent. If a job exceeds the time limit, the job is automatically canceled and the build fails.

You can set timeouts on your builds in two ways:

- Command step timeouts for running jobs.
- Scheduled job expiration for jobs yet to be picked up.

Organization-level timeouts can be set in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings):

<%= image "pipeline_timeout_settings.png", width: 1724/2, height: 736/2, alt: "Set timeout period for your jobs" %>

## Command timeouts

There isn't a separate pipeline-level timeout in Buildkite—all timeouts are applied per command step, not to the build as a whole. You can specify timeouts for individual command steps using the [`timeout_in_minutes`](/docs/pipelines/configure/step-types/command-step#timeout_in_minutes) attribute, or set default and maximum timeouts at the organization or pipeline level.

The **Default Command Step Timeout** sets the default timeout in minutes for all command steps in this pipeline. This can still be overridden in any command step.

The **Maximum Command Step Timeout** sets the maximum timeout in minutes for all command steps in this pipeline. Any command step without a timeout or with a timeout greater than this value will be set to this value.

Timeout precedence: step-level timeout → pipeline default → organization default. This behavior is distinct from [scheduled job expiration](#scheduled-job-expiration).

Timeouts apply to the whole job lifecycle, including hooks and artifact uploads. If a timeout is triggered while a command or hook is running, there's a 10-second grace period by default. You can change the grace period by setting the [`cancel-grace-period`](/docs/agent/v3/configuration#cancel-grace-period) flag.

Note that command step timeouts don't apply to trigger steps and block steps.

## Scheduled job expiration

Scheduled job expiration helps you avoid having lingering jobs that are never assigned to an agent or run. This expiration time is calculated from when a job is created, not scheduled.

By default, jobs are canceled when not picked up for 30 days. This will cause the corresponding build to fail.

You can override the default by setting a shorter value in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.

Scheduled job limits should not be confused with [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds). A scheduled build's jobs will still go through the [build states](/docs/pipelines/configure/defining-steps#build-states), and the timeout will apply once its individual jobs are in the scheduled state waiting for agents.

> 📘 Delays in job expiration
> A job's expiration process is run hourly at 5 minutes past. When the expiration process runs and the job's scheduled expiration was not over at that hour, it will only be expired until the next hour when the process is executed again.
