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
1. For the **Suite emoji** field, enter the emoji syntax for a ruby, which is `\:ruby\:`.
1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/test-engine/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to configure your test collector within your development project.

## Clone the Ruby example test suite project

Then, clone the Ruby example test suite project:

1. Run the following command:

    ```bash
    git clone git@github.com:buildkite/ruby-example-test-suite.git
    ```

1. Change directory (`cd`) into the `ruby-example-test-suite` directory.
1. (Optional) Run the following `rspec` command to test that RSpec test runner executes successfully:

    ```bash
    rspec
    ```

    The command output should display something similar to:

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

## Run RSpec (again) to send your test data to Test Engine
