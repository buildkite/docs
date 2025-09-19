# Test suites overview

In Test Engine, a _test suite_ (or _suite_) is a collection of tests. A suite has a _run_, which is the execution of tests in a suite. A pipeline's build may create one or more of these runs.

Many organizations set up one suite per test framework, for example one suite for RSpec, and another suite for Jest. Others use a common standard, such as JUnit XML, to combine tests from multiple frameworks to set up custom backend and frontend suites.

Each suite inside Test Engine has a unique API token that you can use to route test information to the correct suite. Pipelines and test suites do not need to have a one-to-one relationship.

When [creating a test suite](/docs/test-engine/getting-started#create-a-test-suite) for your development project, you'll need to have configured the appropriate _test collectors_ for your project's test runners before your test suite can fully function and start collecting test data. Learn more about how to do this from the [Test collection](/docs/test-engine/test-collection) section of these docs.

To delete a suite, or regenerate its API token, go to suite settings.

## Tests tab on build pages

Test Engine information is available on your test pipeline's build pages, in the [new build view](/docs/pipelines/build-page).

<%= image "tests-tab.png", width: 3170, height: 1668, alt: "Screenshot of the tests tab on the build page" %>

This allows you to easily view the failing tests in a given build, and filter the test executions to analyze and surface trends about your tests suite. You can also select "Display" to change the columns displayed on the Test tab, so that other types of aggregate data (e.g. average duration) is shown. By default, the executions are grouped by test so that retried tests are shown together.

## Parallelized builds

In CI/CD, a build's tests can be made to run in parallel using features of your own CI/CD pipeline or workflow tool. Parallelized pipeline/workflow builds typically run and complete faster than builds which are not parallelized.

In Buildkite Pipelines, you can run tests in parallel when they are configured as [parallel jobs](/docs/pipelines/tutorials/parallel-builds#parallel-jobs).

> 📘
> When tests are run in parallel across multiple agents, they can be grouped into the same run by defining the same `run_env[key]` environment variable. Learn more about this environment variable and others in [CI environments](/docs/test-engine/test-collection/ci-environments).
> The best way to coordinate the distribution of tests in a parallelized build is by implementing [test splitting](/docs/test-engine/test-splitting).

## View by branch

All test suites have a _default branch_ so you can track trends for your most important branch, and compare it to results across _all branches_. Organizations typically choose their main production branch as their default, although this is not required. All Test Engine views are filtered automatically to the default branch.

In addition to the default branch, you can add any number of additional _stored branches_. Stored branches accept prefix wildcard operators, and are useful for merge queues and other similar naming conventions. You can filter Test Engine views by a stored branch, or any branch, by using the branch filter.

To configure your branches, go to suite settings. In most cases, branch name is tracked automatically as part of the [core tags](/docs/test-engine/test-suites/tags#core-tags) Test Engine ingests on your behalf.

## Tracking reliability

Test Engine calculates reliability of both your entire test suite and individual tests as a measure of pass/fail rate over time.

_Reliability_ is defined as percentage calculated by:

- Test suite reliability = `passed_runs / (passed_runs + failed_runs) * 100`
- Individual test reliability = `passed_test_executions / (passed_test_executions + failed_test_executions) * 100`

Other test execution results such as `unknown` and `skipped` are ignored in the test reliability calculation.

In Test Engine, a run is marked as `failed` as soon as a test execution fails, regardless of whether it passes on a retry. This helps surface unreliable tests. You can have a situation where a build eventually passes on retry in a Pipeline, and the related run is marked as `failed` in Test Engine.

## Trends and analysis

Once your test suite is set up, you'll have many types of information automatically calculated and displayed to help you surface and investigate problems in your test suite.

The Summary and Test pages are able to be filtered by branch, result (e.g. pass, fail), state (e.g. enabled, disabled), owner (e.g. core-team, platform-team), label (e.g. flaky, slow, feature-test) and [tag](/docs/test-engine/test-suites/tags). This allows greater flexibility and deeper analysis into the performance of your test suite.

<%= image "test-stats.png", width: 2570, height: 902, alt: "Screenshot of test trend page showing test trend information over the last day, including test reliability and test execution durations" %>

Select any individual test execution to see more trend and deep-dive information.

<%= image "test-execution-stats.png", width: 2930, height: 1812, alt: "Screenshot of individual test execution page showing test information related to that individual execution of the test" %>

You can also annotate span information to help investigate problems, and see detailed log information inside Test Engine for any failed test or run.

<%= image "span-timeline.png", width: 1868, height: 1430, alt: "Screenshot of span timeline with user-defined annotation" %>
