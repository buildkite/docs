# Getting started

👋 Welcome to Buildkite Test Engine! You can use Test Engine to help you track and analyze the test steps automated through CI/CD using either [Buildkite Pipelines](/docs/pipelines) or another CI/CD application, by shipping code to production faster through test optimization, as well as improving the performance and reliability of your tests.

While this tutorial uses a simple Ruby project example, Buildkite Test Engine supports [other languages and test runners](/docs/test-engine/test-collection) too.

## Before you start

To complete this tutorial, you'll need:

- A Buildkite account. If you don't have one already, <a href="<%= url_helpers.signup_path %>">create a 30-day free trial account</a>.

- [Git](https://git-scm.com/downloads), to clone the Ruby project example.

- [Ruby](https://www.ruby-lang.org/en/downloads)—macOS users can also install Ruby with [Homebrew](https://formulae.brew.sh/formula/ruby).

## Create a test suite

To begin creating a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**. For example, `RSpec test suites`.
1. Enter a mandatory **Test suite name**. For example, `My RSpec example test suite`.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time. For example (and usually), `main`.
1. Enter an optional **Suite emoji**, using [emoji syntax](/docs/pipelines/emojis). For example, `\:ruby\:` for a ruby emoji representing the Ruby language.
1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/test-engine/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to configure your test collector within your development project.

    Keep this web page open.

## Clone the Ruby example test suite project

Then, clone the Ruby example test suite project:

1. Open a terminal or command prompt, and run the following command:

    ```bash
    git clone git@github.com:buildkite/ruby-example-test-suite.git
    ```

1. Change directory (`cd`) into the `ruby-example-test-suite` directory.
1. (Optional) Run the following `rspec` command to test that RSpec test runner executes successfully:

    ```bash
    rspec
    ```

    After about a minute, the command output should display something similar to:

    ```bash
    disabled tests
    ......................

    Finished in 1 minute 4.06 seconds (files took 0.29045 seconds to load)
    22 examples, 0 failures
    ```

## Configure your Ruby project with its test collector

Next, configure your Ruby project's RSpec test runner with its test collector:

1. Install the [`buildkite-test_collector`](https://rubygems.org/gems/buildkite-test_collector) gem by running the following `gem` command:

    ```bash
    gem install buildkite-test_collector
    ```

1. Add the following lines of code to your project's `spec_helper.rb` file:

    ```ruby
    require 'buildkite/test_collector'

    Buildkite::TestCollector.configure(hook: :rspec)
    ```

    The top of this file should look similar to:

    ```ruby
    require 'yaml'
    require 'json'
    require 'buildkite/test_collector'

    Buildkite::TestCollector.configure(hook: :rspec)

    begin
      skip_data = File.read('skipped.json')
      skip = JSON.parse(skip_data)
    rescue
      skip = []
    end

    ...
    ```

## Run RSpec (again) to send your test data to Test Engine

1. Back on the **Complete test suite setup** page, copy the **Test Suite API token** value.

1. At your terminal/command prompt, run the following `rspec` command (with additional environment variables) to execute the RSpec test runner and send its execution data back to your Test Engine test suite:

    ```bash
    BUILDKITE_ANALYTICS_TOKEN=<api-token-value> BUILDKITE_ANALYTICS_MESSAGE="My first test run" rspec
    ```

    where `<api-token-value>` is the value of the **Test Suite API token** value you copied in the previous step. This value can typically be pasted without any quotation marks.

    The command output should display something similar to:

    ```bash
    disabled tests
    ......................

    Finished in 1 minute 4.06 seconds (files took 0.25227 seconds to load)
    22 examples, 0 failures
    ```

1. Back in Test Engine, your test suite should now be displayed, showing its **Runs** tab, with a summary of details from the last execution of the RSpec test runner in the previous step. The final result should indicate a status of **PASSED**.

    If this page indicates **Still processing data** after a while, refresh your browser page to display the results. If the status indicates **PENDING**, wait a little longer until the final result appears.

## Next steps

That's it! You've successfully created a test suite, configured your Ruby project with a test collector, and executed the project's test runner to send its test data to your test suite. 🎉

Learn more about:

- How to configure [test collection](/docs/test-engine/test-collection) for other test runners.
- [CI environment variables](/docs/test-engine/ci-environments) that test collectors and other test collection mechanisms provide to your Test Engine test suites, when your test runs are automated through CD/CD.
- How to work with Buildkite Test Engine in [Test suites](/docs/test-engine/test-suites).
