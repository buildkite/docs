# Build timeouts

Build timeouts are limits on the maximum time a job can wait before being picked up by an agent. If a job exceeds the time limit, the job is automatically canceled and the build fails.

You can set timeouts on your builds in two ways:

- Command step timeouts for running jobs.
- Scheduled job expiry for jobs yet to be picked up.

Organization-level timeouts can be set in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings):

<%= image "pipeline_timeout_settings.png", width: 1724/2, height: 736/2, alt: "Set timeout period for your jobs" %>

## Command timeouts

You can specify timeouts for jobs as [command steps attributes](/docs/pipelines/configure/step-types/command-step#timeout_in_minutes), but it's possible to avoid setting them manually every time. To prevent jobs from consuming too many job minutes or running forever, specify default and maximum timeouts from your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings), or on an individual pipeline's **Settings**.

Specific timeouts take precedence over more general ones—a step-level timeout takes precedence over a pipeline timeout, which in turn takes precedence over an organization's default. This behavior is distinct from scheduled job expiry, which is explained further below.

Timeouts apply to the whole job lifecycle, including hooks and artifact uploads. If a timeout is triggered while a command or hook is running, there's a 10-second grace period by default. You can change the grace period by setting the [`cancel-grace-period`](/docs/agent/v3/configuration#cancel-grace-period) flag.

Maximum timeouts are applied to command steps in the following situations:

- No timeout attribute is set on the step.
- No default timeout is set in the pipeline settings.
- When the timeout set is greater than the maximum timeout.

Maximums are always enforced when supplied, and the smallest value will be used.

Note that command step timeouts don't apply to trigger steps and block steps.

## Scheduled job expiry

Scheduled job expiry helps you avoid having lingering jobs that are never assigned to an agent or run. This expiry time is calculated from when a job is created, not scheduled.

By default, jobs are canceled when not picked up for 30 days. This will cause the corresponding build to fail.

You can override the default by setting a shorter value in your organization's [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.

Scheduled job limits should not be confused with [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds). A scheduled build's jobs will still go through the [build states](/docs/pipelines/configure/defining-steps#build-states), and the timeout will apply once its individual jobs are in the scheduled state waiting for agents.

> 📘 Delays in job expiration
> A job's expiration process is run hourly at 5 minutes past. When the expiration process runs and the job's scheduled expiration was not over at that hour, it will only be expired until the next hour when the process is executed again.
