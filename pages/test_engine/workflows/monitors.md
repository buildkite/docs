# Monitors

A workflow is configured with a _monitor_, which is a specialized type of observer to your [test suite](/docs/test-engine/test-suites). A monitor observes test [executions](/docs/test-engine/glossary#execution), and surfaces information and trends about the test's performance and reliability over time. Workflows are subject to a rate limit. See [Rate limit](/docs/test-engine/workflows#rate-limit) for more information.

Test Engine supports the following types of monitors:

- [Transition count](#transition-count)
- [Passed on retry](#passed-on-retry)
- [Probabilistic flakiness](#probabilistic-flakiness)

You can alter and reduce the amount of test executions that a monitor receives using [tag filters](#tag-filters).

## Transition count

A transition is a change from passing to failing, or failing to passing, in a sequence of results for a test over time.

<%= image "transition-count-light.png", class: 'light-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing tests with multiple results, and the transitions counts (pass -> fail, or fail -> pass) for each test" %>

<%= image "transition-count-dark.png", class: 'dark-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing tests with multiple results, and the transitions counts (pass -> fail, or fail -> pass) for each test" %>

The transition count monitor keeps track of how many times the result changes, over the configured window, and calculates a score based on this. A low transition score means that the test is either consistently passing, or consistently failing. A high transition count for a test indicates flakiness, as the test result is changing very frequently between **pass** and **fail**. For example:

- Over a window of 5, a test result pattern of `FFFFF` will have a score of 0.
- Over a window of 5, a test result pattern of `PPFFF` will have a score of 0.2.
- Over a window of 5, a test result pattern of `PFPFF` will have a score of 0.4.
- Over a window of 5, a test result pattern of `PFFFFF` will have a score count of 0 (the oldest result `P` has fallen outside the evaluation window, and so is ignored).
- Over a window of 5, a test result pattern of `PF` will have a score of 0.2 (the score is always calculated based on window, not number of results).

In addition to the window, the transition counts that cause the [_alarm_ and _recover_ actions](/docs/test-engine/workflows/actions) to be triggered are configurable.

A branch must be configured for the transition count monitor, and therefore, it is recommended setting this to the value of the main branch (for example, `main`, `master`, `trunk`). Configuring a branch is necessary so that transitions from feature branches are ignored in the accumulation of the transition count, as failures and passes on feature branches are a byproduct of a standard development workflow, and do not indicate test instability.

If you're unsure what the most suitable monitor is for your test suite, use this the transition count monitor on your test suite's default branch. This monitor will likely work without any pipeline configuration changes (for example, setting up job retries), and has more resiliency to "real world" events (for example, infrastructure-related events) which affect test results.

## Passed on retry

_Passed on retry_ refers to a test that both passes and fails on the same git commit SHA. When this occurs, the _alarm_ [action(s)](/docs/test-engine/workflows/actions) are triggered. If the monitor then does not encounter passed on retry events over the next seven days or 100 executions of the given test (whichever is reached first), then the _recover_ actions for your workflow will be triggered.

<%= image "passed-on-retry-light.png", class: 'light-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing multiple test results on one commit, and that a commit with a pass and a fail on the same commit is considered flaky" %>

<%= image "passed-on-retry-dark.png", class: 'dark-only', width: 1424 / 2, height: 368 / 2, alt: "Image showing multiple test results on one commit, and that a commit with a pass and a fail on the same commit is considered flaky" %>

Because this monitor relies on inconsistent results on the same commit SHA, you'll need to set up automatic retries on your test pipeline. You can do this with Buildkite Pipeline's [retry jobs](/docs/pipelines/configure/step-types/command-step#retry-attributes) or by setting the [retry count environment variable](/docs/test-engine/bktec/configuring#BUILDKITE_TEST_ENGINE_RETRY_COUNT) in Buildkite Test Engine Client.

The order and number of pass and fail results don't change the reportage of the passed on retry event, as long as there is at least one of each pass and fail. Other test results (for example, null, skipped, pending) are ignored in the detection of passed on retry events.

> 📘
> This monitor is created by default for all test suites.

## Probabilistic flakiness

This monitor tracks the [probabilistic flakiness score](https://engineering.fb.com/2020/12/10/developer-tools/probabilistic-flakiness/) (PFS) of each test. The PFS was developed by [Meta](https://www.meta.com/), and uses a Bayesian statistical model to derive the probability that a test will become flaky on its next execution. The PFS model takes into account the current result of the test, and the historical results of the test execution.

> 📘
> The probabilistic flakiness monitor is only available on [Enterprise](https://buildkite.com/pricing) plans.

The probabilistic flakiness monitor is best suited to large and complex test suites, where the volume and noise of test data prevents a simpler flaky test monitor from being successful. As the PFS is a continuous metric, these scores provide a smarter prioritization metric for larger organizations.

## Tag filters

Tag filters reduce the set of [execution](/docs/test-engine/glossary#execution) data that goes into a monitor, so that you can ignore lower relevancy data and produce better insights, or take different [actions](/docs/test-engine/workflows/actions) based on different types of test executions. This means that you can set up custom actions and monitors based on tag values, for example sending different notifications based on different team tag values, or using tags to segment the different types of test (e.g. feature, unit) and monitor on different thresholds.

<%= image "tag-filters.png", alt: "Screenshot showing tag filters, with the branch filter set to main" %>

Tag filters are optional and you can configure up to four of them per workflow. Tag filter values support the following matching operators:

- **is**
- **is not**
- **starts with**

If you haven't set up tags for test execution, see [Tags](/docs/test-engine/test-suites/tags) in the [Test suites](/docs/test-engine/test-suites) documentation for details.

### Default branch filter

By default, a filter for `scm.branch` is added, whose value is set to your default branch. This means that test instability on feature or development branches, or both, do not affect the reliability of your test suite. You may want to modify or remove this default branch filter if your organization meets any of the following criteria:

- Your organization is interested in test results on a specific branch, that is not your default branch. For example, your organization uses test selection and full test builds are run on a specific branch.
- Your organization uses merge queues, and is interested in branches following the merge queue naming convention.
- Your organization is interested in monitoring all branches.

> 📘
> Remove the branch filter if you want to monitor on all branches. The branch filter must be set to a value if you're using the transition count monitor.
