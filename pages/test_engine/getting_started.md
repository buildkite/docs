# Getting started with Test Engine

👋 Welcome to Buildkite Test Engine! You can use Test Engine to help you track and analyze the test steps automated through CI/CD using either [Buildkite Pipelines](/docs/pipelines) or another CI/CD application.

This getting started page is a tutorial that helps you understand Buildkite Test Engine's fundamentals, by providing you with high level guidance on how you'd create a new Test Engine [test suite](/docs/test-engine/test-suites), and then cloning and running a simple example Ruby project to generate test results that are collected and reported through this test suite.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account and a basic familiarity with [Buildkite Pipelines](/docs/pipelines). If you don't already have a Buildkite account and want to gain some familiarity with this product, run through the [Getting started with Pipelines](/docs/pipelines/getting-started) tutorial first.

    Otherwise, you can create a free personal Buildkite account from the <a href="<%= url_helpers.signup_path %>">sign-up page</a>.

- [Git](https://git-scm.com/downloads), to work with a locally cloned project you want to implement Test Engine test suites on.

## Create a test suite

To begin creating a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**, for example, `My project`.
1. Enter a mandatory **Test suite name**, for example, `My project test suite`.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time, for example (and usually), `main`.
1. Enter an optional **Suite emoji**, using [emoji syntax](/docs/pipelines/emojis), for example, `\:test_tube\:` for a test tube emoji.
1. Enter an optional **Suite color**, using the `#RRGGBB` syntax. See the [HTML Color Codes](https://htmlcolorcodes.com/) page to help you choose a color.

    **Note:** At this point, you can select one of the buttons towards the end of this page which match your project's testing framework (or test runners) for instructions on how to set up [test collection](/docs/test-engine/test-collection) for your project. This opens up the relevant documentation page with instructions on how to set up test collection for your test runners, which you'll be doing this in the next section. Otherwise, if your project's testing framework is not listed, see [Collecting test data from other test runners](/docs/test-engine/test-collection/other-collectors) for details on how to implement test collection for other testing frameworks. Regardless, keep the relevant page/s open.

1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/test-engine/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to [configure your test collector within your development project](#configure-your-project-with-its-test-collector).

## Configure your project with its test collector

Next, configure your project's test runners with its Buildkite test collector:

1. On the **Complete test suite setup** page, under **Set up an integrated test collector**, select the test collector option for your test runners.
1. Follow the instructions on the right of the page (along with the relevant documentation page you opened above for more detailed information) to implement the relevant test collection capabilities for your project.

    **Note:** When instructed to add the `BUILDKITE_ANALYTICS_TOKEN`

## Run RSpec (again) to send your test data to Test Engine

1. Back on the **Complete test suite setup** page, copy the **Test Suite API token** value.

1. At your terminal/command prompt, run the following `rspec` command (with additional environment variables) to execute the RSpec test runner and send its execution data back to your Test Engine test suite:

    ```bash
    BUILDKITE_ANALYTICS_TOKEN=<api-token-value> BUILDKITE_ANALYTICS_MESSAGE="My first test run" rspec
    ```

    where:
    * `<api-token-value>` is the value of the **Test Suite API token** value you copied in the previous step. This value can typically be pasted without any quotation marks.
    * `BUILDKITE_ANALYTICS_MESSAGE` is an environment variable, which is usually used for a source control (Git) commit message, and is presented in a run of your Buildkite test suite. However, in this scenario, this environment variable and its value are being used to describe the test run (or build). Learn more about [these types of environment variables](/docs/test-engine/test-collection/ci-environments#other-ci-providers), which are available to _other CI/CD providers_ (that is, those other than [Buildkite Pipelines](/docs/test-engine/test-collection/ci-environments#buildkite), [CircleCI](/docs/test-engine/test-collection/ci-environments#circleci) or [GitHub Actions](/docs/test-engine/test-collection/ci-environments#github-actions)), as well as [containers](/docs/test-engine/test-collection/ci-environments#containers-and-test-collectors), and manually run builds such as this `rspec` execution command above.

    The command output should display something similar to:

    ```bash
    disabled tests
    ......................

    Finished in 1 minute 4.06 seconds (files took 0.25227 seconds to load)
    22 examples, 0 failures
    ```

1. Back in Test Engine, your test suite should now be displayed, showing its **Runs** tab, with a summary of details from the last execution of the RSpec test runner in the previous step. The final result should indicate **My first test run** (obtained from the value of `BUILDKITE_ANALYTICS_MESSAGE` in the previous step) with a status of **PASSED**.

    If this page indicates **Still processing data** after a while, refresh your browser page to display the results. If the status indicates **PENDING**, wait a little longer until the final result appears.

## Next steps

That's it! You've successfully created a test suite, configured your Ruby project with a test collector, and executed the project's test runner to send its test data to your test suite. 🎉

Learn more about:

- How to configure [test collection](/docs/test-engine/test-collection) for other test runners.
- [CI environment variables](/docs/test-engine/test-collection/ci-environments) that test collectors (and other test collection mechanisms) provide to your Buildkite test suites, when your test runs are automated through CI/CD.
- How to work with [test suites](/docs/test-engine/test-suites) in Buildkite Test Engine.
