# buildkite-agent job

The Buildkite agent's `job update` command provides the ability to update the attributes of a job.

## Updating a job

Use this command in your build scripts to update a job's attributes. Only command jobs can be updated and must not have finished.

Currently, only the `timeout_in_minutes` attribute can be updated.

`timeout_in_minutes` (alias `timeout`): The maximum number of minutes this step is allowed to run, relative to the job's start time. If the job exceeds this time limit, the job is automatically canceled and the build fails. Jobs that time out with an exit status of <code>0</code> are marked as <code>passed</code>. See [Updating timeouts during a job](/docs/pipelines/configure/build-timeouts#command-timeouts-updating-timeouts-during-a-job) for more information.

<%= render 'agent/cli/help/job_update' %>
