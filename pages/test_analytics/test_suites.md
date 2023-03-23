# Configuring test suites

In Test Analytics, a test _Suite_ is a collection of tests. A run is to a suite what a build is to a Pipeline.

Many organizations set up one suite per test framework, for example one suite for RSpec, and another suite for Jest. Others use a common standard, such as JUnit XML, to combine tests from multiple frameworks to set up custom backend and frontend suites.

Each suite inside Test Analytics has a unique API token that you can use to route test information to the correct suite. Pipelines and test suites do not need to have a one-to-one relationship.

To delete a suite, or regenerate its API token, go to suite settings.


## Parallelized builds

Test Analytics works even when your test runs are split across different agents by de-duplicating against the Test Analytics API token and unique build identifier.

The information that serves as a unique build identifier differs between CI environments. For details, see `run_env[key]` environment variables on our [CI environments page](/docs/test-analytics/ci-environments).

## Compare across branches

All test suites have a default branch so you can track trends for your most important codebase, and compare it to results across all branches.

Organizations typically choose their main production branch as their default, although this is not required.

To change your default branch, go to suite settings. You can also filter Test Analytics views by any branch by typing its name into the branch query parameter in the Test Analytics URL.

## Detecting flaky tests

Flaky tests are automated tests that produce inconsistent or unreliable results, despite being run on the same code and environment. They cause frustration, decrease confidence in testing, and waste time while you investigate whether the failure is due to a genuine bug.

Test Analytics detects flaky tests by surfacing when the same test is run multiple times on the same commit SHA with different results. The tests might run multiple times within a single build or across different builds. Either way, they are detected as flaky if they report both passed and failed results.

If your test suite supports it, we recommend enabling the option to retry failed tests automatically. Automatic retries are typically run more often and provide more data to detect flaky tests. If you can't use automatic retries, Test Analytics also detects flaky tests from manual retries.

Alternatively, you can create [scheduled builds](/docs/pipelines/scheduled-builds) to run your test suite on the default branch. You can schedule them outside your typical development time to run the test suite multiple times against the same commit SHA. You can still enable test retries in this setup, but they're less important. The more builds you run, the more likely you'll detect flaky tests that fail infrequently.

Test Analytics reviews the test results to detect flaky tests once per day. The list of flaky tests doesn't change often, so we've found this to be frequent enough to provide helpful information.

## Tracking reliability

Test Analytics calculates reliability of both your entire test suite and individual tests as a measure of flakiness over time.

_Reliability_ is defined as percentage calculated by:

- Test suite reliability = `passed_runs / (passed_runs + failed_runs) * 100`
- Individual test reliability = `passed_test_executions / (passed_test_executions + failed_test_executions) * 100`

Other test execution results such as `unknown` and `skipped` are ignored in the test reliability calculation.

In Test Analytics, a run is marked as `failed` as soon as a test execution fails, regardless of whether it passes on a retry. This helps surface unreliable tests. You can have a situation where a build eventually passes on retry in a Pipeline, and the related run is marked as `failed` in Test Analytics.

## Trends and analysis

Once your test suite is set up, you'll have many types of information automatically calculated and displayed to help you surface and investigate problems in your test suite.

For individual tests, views include trend information on reliability, test execution count, failed test execution count, and test execution duration at p50 and p95, along with detailed information about span duration and total duration of that test execution over time.

<%= image "test-stats.png", width: 1166, height: 327, alt: "Screenshot of test trend page showing test trend information over the last 7 days, including failed test execution count and test execution durations" %>

<%= image "test-trend.png", width: 1167, height: 394, alt: "Screenshot of test trend page showing change in duration across test runs and a recent failed test executions" %>

Select any individual test execution to see more trend and deep-dive information, including comparisons against previous executions of this test.

For example, in the following screenshot, you can see that the test execution duration of 5.26 seconds is 2 seconds and 233 milliseconds more than the median of the previous 25 executions. In addition, the current value for this test execution of 5.26 seconds is in the 66th percentile within the distribution over the last 25 executions.

<%= image "test-execution-stats.png", width: 1170, height: 578, alt: "Screenshot of individual test execution page showing test information related to that individual execution of the test" %>

You can also annotate span information to help investigate problems, and see detailed log information inside Test Analytics for any failed test or run.

<%= image "span-timeline.png", width: 1125, height: 451, alt: "Screenshot of span timeline with user-defined annotation" %>
