# Reduce flaky tests

Flaky tests produce inconsistent results when run against the same code and environment. They can block builds, waste investigation time, and reduce confidence in your test suite.

[Test Engine](/docs/pipelines/configure/tests), the testing layer of Buildkite Pipelines, helps you manage flaky tests throughout their lifecycle. Test Engine uses historical test data to detect unreliable tests, limit their effect on builds, notify the teams responsible for fixing them, and recognize when they become reliable again.

## Detecting flaky tests

Test Engine [workflow monitors](/docs/pipelines/configure/tests/workflows/monitors) identify tests whose results indicate flakiness. Labels then make these tests easy to find in Test Engine and on the **Tests** tab of a build.

Learn how to [detect flaky tests with Test Engine](/docs/pipelines/configure/tests/flaky-tests#detect-flaky-tests).

<%= image "workflows.png", width: 2576/2, height: 1422/2, alt: "The workflows index page in Test Engine" %>

## Quarantining flaky tests

Quarantine prevents unreliable tests from blocking builds. Test Engine can continue collecting data from muted tests, while bktec applies the test state during test execution.

Learn how to [quarantine flaky tests with Test Engine](/docs/pipelines/configure/tests/flaky-tests#quarantine-flaky-tests).

## Remediating flaky tests

Workflow actions can send a webhook, post a Slack message, or create a Linear issue for the team responsible for fixing a flaky test. Recovery actions remove flaky labels and restore quarantined tests automatically after their reliability improves.

Learn how to [notify the responsible team](/docs/pipelines/configure/tests/flaky-tests#notify-the-responsible-team) and [track test recovery](/docs/pipelines/configure/tests/flaky-tests#track-recovery).
