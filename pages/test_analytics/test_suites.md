# Configuring test suites

In Test Analytics, a test _suite_ is a collection of tests. A suite has a _run_, which is the execution of tests in a suite. A suite's run is analogous to a pipeline's build.

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

Test Analytics reviews the test results to detect flaky tests after every test run.

## Run issues

<%= image "run-issues.png", alt: "Screenshot of a run with issues displaying in a list, including flaky, slow and failures." %>

Test Analytics will automatically detect issues per run. For each test, we currently detect three issues:

- **Flaky:** [See section on detecting flaky tests](#detecting-flaky-tests).

- **Slow:** Slowness is measured by the comparative performance of tests within the current run. The system automatically flags slow tests when the slowest 1% of tests take more than 15% of the overall run time. This threshold can be manually amended within the suite settings.

- **Failure:** A failed test will impact the overall test performance and efficiency.

Tests with these issues will display in order of most problematic to least problematic. Issues are also shown on the test execution page:

<%= image "execution-issues.png", alt: "Screenshot of an execution with issues with their descriptions, displaying a dropdown, including flaky, slow and failures." %>

## Tracking reliability

Test Analytics calculates reliability of both your entire test suite and individual tests as a measure of flakiness over time.

_Reliability_ is defined as percentage calculated by:

- Test suite reliability = `passed_runs / (passed_runs + failed_runs) * 100`
- Individual test reliability = `passed_test_executions / (passed_test_executions + failed_test_executions) * 100`

Other test execution results such as `unknown` and `skipped` are ignored in the test reliability calculation.

In Test Analytics, a run is marked as `failed` as soon as a test execution fails, regardless of whether it passes on a retry. This helps surface unreliable tests. You can have a situation where a build eventually passes on retry in a Pipeline, and the related run is marked as `failed` in Test Analytics.

## Trends and analysis

Once your test suite is set up, you'll have many types of information automatically calculated and displayed to help you surface and investigate problems in your test suite.

For individual tests, views include trend information on reliability, test execution count, test execution duration at p50 and p95, along with detailed information about flaky and failed test executions.

<%= image "test-stats.png", width: 1166, height: 327, alt: "Screenshot of test trend page showing test trend information over the last 28 days, including test reliability and test execution durations" %>

Select any individual test execution to see more trend and deep-dive information, including any issues found within the execution.

<%= image "test-execution-stats.png", width: 1170, height: 578, alt: "Screenshot of individual test execution page showing test information related to that individual execution of the test" %>

You can also annotate span information to help investigate problems, and see detailed log information inside Test Analytics for any failed test or run.

<%= image "span-timeline.png", width: 1125, height: 451, alt: "Screenshot of span timeline with user-defined annotation" %>
