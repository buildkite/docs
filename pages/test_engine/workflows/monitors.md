# Monitors

A workflow is configured with a _monitor_ which is a specialised type of observer to your test suite. A monitor observes test executions, and surfaces information and trends about the test's performance and reliability over time.

The types of monitors Test Engine currently offers are:

## Transition count

<%= image "transition-count-light.png", class: 'light-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing tests with multiple results, and the transitions counts (pass -> fail, or fail -> pass) for each test" %>

<%= image "transition-count-dark.png", class: 'dark-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing tests with multiple results, and the transitions counts (pass -> fail, or fail -> pass) for each test" %>

A transition is a change from passing to failing, or failing to passing, in a sequence of results for a test over time. The transition count monitor keeps track of how many times the result changes, over the configured window, and calculates a score based on this. A low transition score means that the test is consistently passing, or consistently failing. A high transition count for a test indicates flakiness, as the test result is changing very frequently between "pass" and "fail". For example:

- Over a window of 5, a test result pattern of `FFFFF` will have a score of 0
- Over a window of 5, a test result pattern of `PPFFF` will have a score of 0.2
- Over a window of 5, a test result pattern of `PFPFF` will have a score of 0.4
- Over a window of 5, a test result pattern of `PFFFFF` will have a score count of 0 (the oldest result P has fallen outside the evaluation window, and so is ignored)
- Over a window of 5, a test result pattern of `PF` will have a score of 0.2 (score is always calculated based on window, not number of results)

In addition to the window, the transition counts that cause the _alarm_ and _recover_ actions to be performed are configurable.

A branch must be configured for the transition count monitor, we suggest setting this to the value of the main branch (e.g. `main`, `master`, `trunk`). This is necessary so that transitions from feature branches are ignored in the accumulation of the transition count, as failures and passes on feature branches are a byproduct of a standard development workflow, and do not indicate test instability.

If you're unsure what the most suitable monitor is for your test suite, we recommend using the transition count monitor on your suite's default branch. This monitor will likely work without any pipeline configuration changes (i.e having to set up job retries), and has more resiliency to "real world" events (i.e. infrastructure) that affect test results.

## Passed on retry

<%= image "passed-on-retry-light.png", class: 'light-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing multiple test results on one commit, and that a commit with a pass and a fail on the same commit is considered flaky" %>

<%= image "passed-on-retry-dark.png", class: 'dark-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing multiple test results on one commit, and that a commit with a pass and a fail on the same commit is considered flaky" %>

“Passed on retry” refers to a test both passing and failing on the same git commit SHA. When this occurs, the _alarm_ action(s) are applied. If the monitor then doesn't see "passed on retry" events over the next 7 days days or 100 executions of the given test (whichever is reached first), then the _recover_ actions for your workflow will be triggered.

As this monitor relies on inconsistent results on the same commit SHA, you'll need to set up automatic retries on your test pipeline. You can do this with Buildkite Pipeline's [retry jobs](/docs/pipelines/configure/step-types/command-step#retry-attributes) or by setting the [retry count environment variable](/docs/test-engine/bktec/configuring#BUILDKITE_TEST_ENGINE_RETRY_COUNT) in Buildkite Test Engine Client.

The order and number of pass and fail results don't change the reportage of the passed on retry event, as long as there is at least one of each pass and fail. Other test results (e.g. null, skipped, pending) are ignored in the detection of passed on retry events.

This monitor is created by default for all test suites.

## Probabilistic flakiness (beta)

This monitor tracks the [probabilistic flakiness score](https://engineering.fb.com/2020/12/10/developer-tools/probabilistic-flakiness/) (PFS) of each test. The PFS was developed by Meta, and uses a Bayesian statistical model to derive the probability that a test will flake on its next execution. The PFS model takes into account the current result of the test, and the historical results of the test execution.

The probabilistic flakiness monitor is best suited to large and complex test suites, where the volume and noise of test data prevents a simpler flaky test monitor from being successful. As the PFS is a continuous metric, it provides a smarter prioritisation metric for larger organizations.

This monitor is only available to Enterprise customers.

## Filters

Tag filters reduce the execution data set that goes into a monitor, so that you can ignore lower relevancy data and produce better insights, or take different actions based on different types of test executions. This means that you can set up custom actions and monitors based on tag values, for example sending different notifications based on different team tag values, or using tags to segment the different types of test (e.g. feature, unit) and monitor on different thresholds.

Tag filters are optional and you can configure up to four of them per workflow. Tag filter values support matching operators (e.g. "is" or "starts with"). If you haven't set up execution tagging, see [this page](/docs/test-engine/test-suites/tags).

### Default branch filter

By default, we add a filter for `scm.branch` set to the value of your default branch. This means that test instability on feature/development branches do not affect the reliability of your test suite. You may want to modify or remove this default branch filter if:

- your organization is interested in test results on a specific branch, that is not your default branch, e.g. your organization uses test selection and full test builds are run on a specific branch
- your organization uses merge queues, and are interested in branches following the merge queue naming convention
- your organization is interested in monitoring all branches

> 📘
> Remove the branch filter if you want to monitor on all branches. The branch filter must be set to a value if you're using the transition count monitor.
