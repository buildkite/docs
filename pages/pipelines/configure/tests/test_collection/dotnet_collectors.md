---
toc: false
---

# .NET collector

To use Buildkite Test Engine with your .NET projects, either use the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) to run your NUnit tests through [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client), or use the :github: [`test-collector-dotnet`](https://github.com/buildkite/test-collector-dotnet) package with xUnit.

<%= render_markdown partial: 'pipelines/configure/tests/test_collection/tests_plugin_recommendation' %>

You can also upload test results by importing [JSON](/docs/pipelines/configure/tests/test-collection/importing-json) or [JUnit XML](/docs/pipelines/configure/tests/test-collection/importing-junit-xml).

## Tests Buildkite plugin example for NUnit

The following step uses the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) to run an NUnit suite through [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client). The plugin downloads bktec, requests an OIDC token, ensures the test suite exists, and exports the environment variables that bktec expects. Build your solution first so that each partition can run with `--no-build`, then invoke `bktec run`:

```yaml
steps:
  - label: "NUnit"
    command:
      - dotnet build
      - bktec run
    plugins:
      - tests#v1.0.0:
          test-runner: nunit
          result-path: test-results/results.xml
          test-file-pattern: "tests/**/*Tests.cs"
    parallelism: 4
```

See the [Tests Buildkite plugin page](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) for the full plugin reference, including all supported options and dynamic parallelism with `bktec plan`.

## xUnit collector

Before you start, make sure .NET runs with access to [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments).

1. Create a [test suite](/docs/pipelines/configure/tests/test-suites) and copy the API token that it gives you.

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

If all is well, you should see the test run analytics on the Buildkite Test Engine dashboard.
