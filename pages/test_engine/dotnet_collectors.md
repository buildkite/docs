---
toc: false
---

# .NET collector

To use Test Analytics with your .NET projects use the :github: [`test-collector-dotnet`](https://github.com/buildkite/test-collector-dotnet) package with xUnit.

You can also upload test results by importing [JSON](/docs/test-analytics/importing-json) or [JUnit XML](/docs/test-analytics/importing-junit-xml).

Before you start, make sure .NET runs with access to [CI environment variables](/docs/test-analytics/ci-environments).

1. Create a [test suite](/docs/test-analytics/test-suites) and copy the API token that it gives you.

1. Add `Buildkite.TestAnalytics.Xunit` to your list of dependencies in your xUnit test project:

    ```sh
    $ dotnet add package Buildkite.TestAnalytics.Xunit
    ```

1. Set up your API token

    Add the `BUILDKITE_ANALYTICS_TOKEN` environment variable to your build system's environment.

1. Run your tests

    Run your tests like normal.  Note that we attempt to detect the presence of several common CI environments, however if this fails you can set the `CI` environment variable to any value and it will work.

    ```sh
    $ dotnet test Buildkite.TestAnalytics.Tests
    ```

1. Verify that it works

If all is well, you should see the test run in the test analytics section of the Buildkite dashboard.
