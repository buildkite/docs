# Workflows

A workflow allows you to create custom mappings between _observations_ that Test Engine makes about your test suite, and the _actions_ that would like to take from them. This means that observations about the health and performance of your tests (for example: test is flaky, test is slow) can generate automatic actions (for example: label the test as flaky, send a notification) to help you automate their management and resolution.

## Monitors

A workflow is configured with a _monitor_ which is a specialised type of observer to your test suite. A monitor observes test executions, and surfaces information and trends about the test's performance and reliability over time.

The types of monitors Test Engine currently offers are:

### Transition count

A _transition_ is a change in the pass or fail result of a test. The transition count monitor keeps track of how many times the result changes, over the configured window. A low transition count means that the tests is consistently passing, or consistently failing. A high transition count for a test indicates flakiness, as the test result is changing very frequently between "pass" and "fail". Generally, scores over 0.1 indicate a moderate level of flakiness, as it means that on average 1 in 10 test results are inconsistent. Transition count scores over 0.4 indicate high levels of flakiness.

If you're unsure which type of monitor is best suited for your test suite, we recommend starting with this one.

### Passed on retry

This monitor keeps count of the number of times that both a passing and failing test result is reported by a test, on the same git commit SHA. This monitor is best suited to systems where failed tests are automatically retried, for example if you're using Buildkite Pipeline's [retry jobs](/docs/pipelines/configure/step-types/command-step#retry-attributes) or using the [Buildkite Test Engine Client](/docs/test-engine/test-splitting/configuring).

### Probabilistic flakiness score

The probabilistic flakiness score (PFS) was developed by [Meta](https://engineering.fb.com/2020/12/10/developer-tools/probabilistic-flakiness/) and uses a statistical model to derive the probability that a test will flake on its next execution. A low PFS indicates high test stability, whereas PFS over 0.1 indicates a moderate level of test unreliability, and a PFS over 0.4 indicates a high level of test unreliability.

## Trigger and resolve actions

When conditions in your test suite trigger or resolve a monitor, there are several automatic actions that Test Engine can perform. They are:

- Adding or removing a label on a test
- Changing the 'state' (enabled, muted, skipped) of a test
- Sending a notification

