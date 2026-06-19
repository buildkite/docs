# buildkite-agent job

The `buildkite-agent job` command provides subcommands for updating or declaring information about the current job.

## Updating a job

Use this command in your build scripts to update a job's attributes. Only command jobs can be updated and must not have finished.

Currently, only the `timeout_in_minutes` attribute can be updated.

`timeout_in_minutes` (alias `timeout`): The maximum number of minutes this step is allowed to run, relative to the job's start time. If the job exceeds this time limit, the job is automatically canceled and the build fails. Jobs that time out with an exit status of <code>0</code> are marked as <code>passed</code>. See [Updating timeouts during a job](/docs/pipelines/configure/build-timeouts#command-timeouts-updating-timeouts-during-a-job) for more information.

<%= render 'agent/cli/help/job_update' %>

## Promising job failure

Use `buildkite-agent job promise-failure` in a running command job to declare that the job is expected to fail before the command exits. This lets Buildkite Pipelines signal build failure early while the job continues running and uploading logs, artifacts, and test results. For usage guidance, see [Detect job failures early](/docs/pipelines/configure/promise-job-failure).

```bash
buildkite-agent job promise-failure 1 --reason "test_failure (2 failed after retries)"
```

The positional argument is the promised exit status. It must be a non-zero integer. Exit status `0` is not valid because it promises success rather than failure.

Options:

<table>
  <tbody>
    <tr>
      <th><code>--reason</code></th>
      <td>Optional human-readable reason for the promised failure.</td>
    </tr>
  </tbody>
</table>

Call this command only once per job, after your script or test runner has confirmed that the job should fail. If the same promised status is submitted more than once, Buildkite Pipelines handles it as a duplicate declaration. Declaring a different promised status for the same job is a conflict.

Buildkite Pipelines evaluates the promised exit status against retry and soft-fail rules. A promised status that would be retried or soft-failed does not count as a hard failure when the build is marked as failing.
