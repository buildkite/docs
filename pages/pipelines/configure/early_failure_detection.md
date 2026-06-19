# Detect job failures early

Job early failure detection lets a running command job declare that it is expected to fail before the command exits. Buildkite Pipelines records a promised non-zero exit status for the job, moves the build to `failing` when that promise counts as a hard failure, and lets the job keep running so it can finish uploading logs, artifacts, and test results.

Use early failure detection when a job can know its final result before all job work is complete. For example, a test job might know the build must fail after test 2 of 100 fails, but you still want the remaining tests to run so engineers and AI agents can see the full failure set.

## How early failure detection works

When a job declares early failure, Buildkite Pipelines records:

- The promised exit status.
- The time when the promise was recorded.
- An optional reason that explains why the job is expected to fail.

The job state remains `running` after the declaration. The build and step can still show as failing because the promised exit status counts toward failure rollup, but the job does not finish until the command exits, is canceled, or reaches another terminal state.

Buildkite Pipelines evaluates the promised exit status against the job's [retry](/docs/pipelines/configure/retry) and [soft fail](/docs/pipelines/configure/soft-fail) rules. If the promised status would be retried or soft-failed, Buildkite Pipelines does not treat it as a hard failure for build-failing rollup.

## Declare early failure from a job

Use the [`buildkite-agent job promise-failure`](/docs/agent/cli/reference/job#promising-job-failure) command from inside a running command job:

```bash
buildkite-agent job promise-failure 1 --reason "test_failure (2 failed after retries)"
```

The command declares that the current job is expected to finish with exit status `1`. The command does not stop the job.

Call `buildkite-agent job promise-failure` only once per job, after your script or test runner has confirmed that the failure is build-critical. For test suites, wait until retries are exhausted and muted or quarantined tests are accounted for.

You cannot promise success. Exit status `0` is not valid for an early failure declaration.

## Use Buildkite Test Engine Client

If you use [Buildkite Test Engine Client](/docs/test-engine/bktec/installing-and-using-the-client), enable early failure declarations by setting `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE` to `true`:

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

Buildkite Test Engine Client declares early failure only after retries are exhausted and hard test failures remain. Muted test failures do not cause a promise failure declaration.

Early failure detection is especially useful for long-running feature, mobile, browser, and UI test suites because these jobs often know the build will fail before teardown, artifact upload, or full result upload finishes.

## Continue uploading results after declaring failure

After a job declares early failure, the command continues running. Use this to keep collecting useful debugging context:

- Continue running the remaining tests in the suite.
- Upload JUnit XML and other test result files.
- Upload screenshots, traces, coverage, logs, and other [artifacts](/docs/pipelines/configure/artifacts).
- Emit annotations or log output that helps engineers and AI agents understand the failure.

This gives downstream tools an early failure signal without losing the final context from the job.

## Use early failure with automatic cancellation

Early failure declarations work with [`cancel_on_build_failing`](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). If a running job promises a hard failure and the build moves to `failing`, sibling jobs with `cancel_on_build_failing: true` can be canceled before the promising job exits.

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

Use this pattern for long-running parallel jobs where later work is not useful after a build-critical failure is known.

## Use early failure with retries and soft failures

Declare early failure only when the promised exit status represents the final expected outcome for the job.

For automatic retries, wait until retry rules are exhausted. A failure that might be retried is not yet a final hard failure.

For soft failures, ensure the promised exit status does not match a `soft_fail` rule unless you intend to declare an expected soft failure. A promised status that matches `soft_fail` does not move the build to `failing` as a hard failure.

## Use early failure with Preflight

Early failure detection pairs well with Preflight because Preflight can begin investigating as soon as the build enters `failing`, while the original job continues to collect more logs and results.

If you use Preflight with large test suites, enable early failure detection in the jobs that can identify build-critical failures before they finish. Preflight can start remediation earlier, then review the final job result later for additional context.

Use the latest Buildkite CLI version when relying on Preflight behavior that reads failed jobs from the Jobs REST API.

## React to early failure with notifications and integrations

When a promised exit status moves the build to `failing`, existing build-failure integrations can react earlier:

- Build notifications that use `build.failing` can fire before the promising job exits.
- Step notifications that use `step.failing` can fire when the step is marked as failing.
- Webhooks can receive `build.failing` and [`job.promised_exit_status`](/docs/apis/webhooks/pipelines/job-events#promised-exit-status-events) events.
- Amazon EventBridge can receive the `Job Promised Exit Status` event.

There is no separate Slack-specific promise failure notification. Use existing build-failure notification behavior to avoid duplicate notification noise.

## Query jobs with promised failures

Use the [Jobs REST API](/docs/apis/rest-api/jobs) when agents or tools need to find failed jobs in large builds. Querying jobs directly is more efficient than fetching a build with all nested jobs.

Failed-job filtering should include terminally failed jobs and running jobs that have declared a promised failure. Job payloads expose the promised exit status and the time when it was recorded. The optional reason is available from job events, webhooks, and GraphQL job event data.

## Measure time saved

You can measure the feature's impact by comparing the promised failure timestamp with later build timestamps:

- Compare `promised_exit_status_at` with `finished_at` to see how much earlier the job declared failure before it finished.
- Compare `failing_at` with `finished_at` on the build to see how much earlier Buildkite Pipelines signaled that the build was failing.

## Troubleshooting

### The job promised failure but still shows as running

This is expected. Early failure detection is a signal, not a terminal job state. The job continues running until the command exits or the job reaches another terminal state.

### The build did not move to failing

Check whether the promised exit status matches a `soft_fail` rule or an automatic retry rule. Buildkite Pipelines moves the build to `failing` only when the promise currently counts as a hard failure.

### The final exit status differs from the promised exit status

If a job promises a hard failure, it should ultimately exit as a hard failure. If the agent reports a different status after promising failure, Buildkite Pipelines shows both the promised and actual exit statuses in the job timeline. Buildkite Pipelines can use the promised non-zero status as the effective status when the final command result would otherwise break the promise.
