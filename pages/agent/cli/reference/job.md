# buildkite-agent job

The `buildkite-agent job` command provides subcommands for updating or declaring information about the current job.

## Updating a job

Use this command in your build scripts to update a job's attributes. Only command jobs can be updated and must not have finished.

Currently, only the `timeout_in_minutes` attribute can be updated.

`timeout_in_minutes` (alias `timeout`): The maximum number of minutes this step is allowed to run, relative to the job's start time. If the job exceeds this time limit, the job is automatically canceled and the build fails. Jobs that time out with an exit status of <code>0</code> are marked as <code>passed</code>. See [Updating timeouts during a job](/docs/pipelines/configure/build-timeouts#command-timeouts-updating-timeouts-during-a-job) for more information.

<%= render 'agent/cli/help/job_update' %>

## Promising job failure

Use `buildkite-agent job promise-failure` in a running command job to declare that the job is expected to fail before the command exits. This lets Buildkite Pipelines signal build failure early while the job continues running and uploading logs, artifacts, and test results. For usage guidance, see [Promise job failure](/docs/pipelines/configure/promise-job-failure).

```bash
buildkite-agent job promise-failure 1 --reason "test_failure (2 failed after retries)"
```

The positional argument is the promised exit status. It must be a positive integer. Exit status `0` is not valid because it promises success rather than failure.

Options:

<table>
  <tbody>
    <tr>
      <th><code>--job</code></th>
      <td>The job to declare the promised failure for. Defaults to the current job (<code>$BUILDKITE_JOB_ID</code>).</td>
    </tr>
    <tr>
      <th><code>--reason</code></th>
      <td>Optional human-readable reason for the promised failure.</td>
    </tr>
  </tbody>
</table>

Call this command only once per job, after your script or test runner has confirmed the job should fail. Submitting the same exit status again is treated as a duplicate and safely ignored (the original declaration stands). Submitting a different exit status for a job that has already declared one is rejected as a conflict (HTTP `409`).

Buildkite Pipelines evaluates the promised exit status against retry and soft-fail rules. A promised status that would be retried or soft-failed does not count as a hard failure when the build is marked as failing.
