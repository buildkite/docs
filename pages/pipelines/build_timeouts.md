# Build timeouts

You can set timeouts on your build in two ways: command step timeouts for running jobs and scheduled job expiry for jobs yet to be picked up.

Organisation level timeouts can be set in pipeline settings for your organization.

<%= image "pipeline_timeout_settings.png", width: 1724/2, height: 736/2, alt: "Set timeout period for your jobs" %>

## Command timeouts

Timeouts for jobs can be specified as [command steps attributes](/docs/pipelines/command-step#timeout_in_minutes), but it's possible to avoid having to set them manually every time.

To prevent jobs from consuming too many job minutes or running forever, you can specify default as well as maximum timeouts from your organization's [Pipeline Settings page](https://buildkite.com/organizations/~/pipeline-settings), or on a pipeline's Builds settings page.

Specific timeouts take precedence over more general ones — a step level timeout takes precedence over a pipeline timeout, which in turn takes precedence over an organization default.

Maximum timeouts are applied to command steps in the following situations:

- No timeout attribute is set on the step.
- No default timeout is set in the pipeline settings.
- When the timeout set is greater than the maximum timeout.

Maximums are always enforced, when supplied — the smallest value will be used.

Timeouts apply to the whole job lifecycle, including hooks and artifact uploads. If a timeout is triggered while a command or hook is running, there's a 10 second grace period by default. You can change the grace period by setting the [`cancel-grace-period`](https://buildkite.com/docs/agent/v3/configuration#cancel-grace-period) flag.

Command step timeouts won't apply to trigger steps and block steps.

## Scheduled job expiry

In the past, it's been very easy to have lingering jobs in your Buildkite account which are never assigned an agent, and will never run. Not only does this create unnecessary noise and risk within your account, but it means that Buildkite’s job processing logic needs to handle years-old jobs. Job expiration prevents this by cancelling any job that is older than 30 days by default. This also makes those builds fail.

You can override this default value by setting a shorter value in the pipeline settings for your organization.

This expiry is calculated from when a job is created not scheduled so please take that into account when setting this limit.
