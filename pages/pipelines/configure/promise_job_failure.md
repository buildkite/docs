# Promise job failure

A long-running job often knows it is going to fail well before it actually finishes. A test job might run for five minutes, but know after the first minute that a critical test has failed. Normally nothing reacts until the job exits, so everyone waits out the remaining four minutes before the build is marked as failing.

Promising job failure removes that wait. A running command job can declare the non-zero exit status it expects to finish with, and Buildkite Pipelines marks the build as `failing` straight away while the job keeps running. You, your teammates, and your AI agents can start investigating or fixing the failure immediately, and the job still runs to completion so it can finish uploading logs, artifacts, and test results.

This is useful whenever a job can determine its final result before the rest of its work is done. For example, a test job might know the build must fail after 2 of 100 tests fail, but you still want the remaining tests to run so engineers and AI agents can see the full set of failures.

## How it works

When a job declares a promised failure, Buildkite Pipelines records:

- The promised exit status.
- The time when the promise was recorded.
- An optional reason that explains why the job is expected to fail.

The job stays in the `running` state. The build and step can be marked as failing right away because the promised exit status is treated as a failure, but the job itself does not finish until the command exits, is canceled, or reaches another terminal state.

Buildkite Pipelines automatically respects the job's [retry](/docs/pipelines/configure/retry) and [soft fail](/docs/pipelines/configure/soft-fail) rules. A promised status that would be retried, or that matches a `soft_fail` rule, is not treated as a hard failure and does not mark the build as failing, so you do not need to account for these cases yourself. What Buildkite Pipelines cannot see are the retries that happen inside your test suite. Declare a promised failure only once your test suite has finished its own retries and the failure is final.

## Declare a promised failure

Use the [`buildkite-agent job promise-failure`](/docs/agent/cli/reference/job#promising-job-failure) command from inside a running command job:

```bash
buildkite-agent job promise-failure 1 --reason "test_failure (2 failed after retries)"
```

This declares that the current job expects to finish with exit status `1`. It does not stop the job.

Call the command only once per job, after your script or test runner has confirmed that the failure is final and build-critical. For test suites, wait until retries are exhausted and any muted or quarantined tests are accounted for.

You cannot promise success. Exit status `0` is not valid for a promised failure.

## Use Buildkite Test Engine Client

If you use [Buildkite Test Engine Client](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client), turn on promised failures by setting `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE` to `true`:

```yaml
steps:
  - label: "RSpec"
    command: bktec run
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_API_ACCESS_TOKEN: YOUR_API_TOKEN
      BUILDKITE_TEST_ENGINE_RESULT_PATH: tmp/rspec-result.json
      BUILDKITE_TEST_ENGINE_SUITE_SLUG: my-suite
      BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec
      BUILDKITE_TEST_ENGINE_PROMISE_FAILURE: "true"
```
{: codeblock-file="pipeline.yml"}

Buildkite Test Engine Client declares a promised failure only after retries are exhausted and hard test failures remain. Muted test failures do not trigger a declaration.

Declaring failures early is especially valuable for long-running feature, mobile, browser, and UI test suites, because these jobs often know the build will fail well before teardown, artifact upload, or the final result upload finishes.

## Jobs keep running after declaring a failure

Declaring a promised failure does not interrupt the job. The command keeps running to completion and continues to:

- Run the remaining tests in the suite.
- Upload JUnit XML and other test result files.
- Upload screenshots, traces, coverage, logs, and other [artifacts](/docs/pipelines/configure/artifacts).
- Emit annotations and log output that help engineers and AI agents understand the failure.

Because the build is marked as failing right away, people and AI agents can start investigating or fixing the problem while this job, and any other jobs in the build, keep running. You get the faster feedback loop without losing any of the final context from the job.

## Cancel other jobs automatically

A promised failure works with [`cancel_on_build_failing`](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). When a running job declares a hard failure and the build moves to `failing`, sibling jobs with `cancel_on_build_failing: true` can be canceled before the declaring job exits.

```yaml
steps:
  - label: "Tests"
    command: bktec run
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_PROMISE_FAILURE: "true"

  - label: "Visual diff"
    command: npm run visual-diff
    cancel_on_build_failing: true
```
{: codeblock-file="pipeline.yml"}

This pattern suits long-running parallel jobs where later work is no longer useful once a build-critical failure is known.

## Use with Preflight

A promised failure pairs well with Preflight, because Preflight can begin investigating as soon as the build enters `failing`, while the original job keeps collecting logs and results.

If you use Preflight with large test suites, declare promised failures in the jobs that can identify build-critical failures before they finish. Preflight can start remediation earlier, then review the final job result later for more context.

Preflight reads failed jobs from the [Jobs REST API](/docs/apis/rest-api/jobs). This requires Buildkite CLI version `3.49.3` or later.

## React to promised failures with notifications and integrations

When a promised exit status moves the build to `failing`, existing build-failure integrations can react earlier:

- Build notifications that use `build.failing` can fire before the promising job exits.
- Step notifications that use `step.failing` can fire when the step is marked as failing.
- Webhooks can receive `build.failing` and [`job.promised_exit_status`](/docs/apis/webhooks/pipelines/job-events#promised-exit-status-events) events.
- Amazon EventBridge can receive the `Job Promised Exit Status` event.

There is no separate Slack-specific promised failure notification. Use existing build-failure notification behavior to avoid duplicate notification noise.

## Query jobs with promised failures

Use the [Jobs REST API](/docs/apis/rest-api/jobs) when agents or tools need to find failed jobs in large builds. Querying jobs directly is more efficient than fetching a build with all nested jobs.

Failed-job filtering should include terminally failed jobs and running jobs that have declared a promised failure. The job exposes the promised exit status and the time it was recorded. The reason is not stored on the job itself: it is available from the job's promised exit status event, through webhooks and the GraphQL job event.

## Measure time saved

You can measure the feature's impact by comparing the promised failure timestamp with the job's final timestamp. Compare `promised_exit_status_at` with `finished_at` on the job to see how much earlier the job declared failure before it actually finished. Both fields are available from the [Jobs REST API](/docs/apis/rest-api/jobs).

## Troubleshooting

### A job declared a failure but is still running

This is expected. Declaring a promised failure is a signal, not a terminal job state. The job keeps running until the command exits or the job reaches another terminal state.

### The build did not move to failing

Check whether the promised exit status matches a `soft_fail` rule or an automatic retry rule. Buildkite Pipelines moves the build to `failing` only when the promise currently counts as a hard failure.

### The final exit status differs from the promised exit status

If a job promises a hard failure, it should ultimately exit as a hard failure. If the agent reports a different status after promising failure, Buildkite Pipelines shows both the promised and actual exit statuses in the job timeline. Buildkite Pipelines can use the promised non-zero status as the effective status when the final command result would otherwise break the promise.
