# Getting started

👋 Welcome to Buildkite Test Engine! You can use Test Engine to help you track and analyze the test steps in your CI/CD pipelines, by shipping code to production faster through test optimization, as well as improving the performance and reliability of your tests.

Test Engine manages your development project's tests through a test suite.

## Create a test suite

To begin creating a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**. This is only a consideration if you have a large development project that consists of more than one test suite.
1. Enter a mandatory **Test suite name**, which, together with the **Application name** (if specified), will appear on the test suite on the **Test Suites** page.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time.
1. If your Buildkite organization has the [teams feature](/docs/test-engine/permissions) enabled, select the relevant **Teams** to be granted access to this test suite.
1. Select **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to configure your test collector within your development project.
