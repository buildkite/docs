# Test collection overview

To analyze your test data in [Buildkite Test Engine](/docs/test-engine), you need a way to collect data from your project's test runners (for example, RSpec or minitest for Ruby, Jest or Cypress for JavaScript, or pytest for Python) and send that data to a [test suite](/docs/pipelines/configure/tests/test-suites).

The recommended starting point is to add the [Tests Buildkite plugin](https://github.com/buildkite-plugins/tests-buildkite-plugin) to your pipeline. The plugin sets up your pipeline to run tests with Buildkite Test Engine: it downloads the [Test Engine Client (bktec)](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client), requests an [OIDC](/docs/pipelines/configure/tests/test-collection/oidc) token, ensures your test suite exists, and collects the test data — all without requiring any changes to your application code. The Tests Buildkite plugin works out of the box with every test runner that bktec supports, including RSpec, Jest, pytest, and `go test`. All other test runners are also supported, as long as they are set up as a customer runner and can output JUnit XML. See bktec docs for more information.

Adding the Tests Buildkite plugin is the fastest way to get a test suite reporting data to Buildkite Test Engine, because the entire setup lives in `pipeline.yml`. Use a language-specific test collector instead when you want deeper framework integration—such as RSpec annotation spans, pytest custom markers, and richer per-framework execution tags. This path requires adding a library dependency to your application code, so it takes more effort to set up than the plugin-only path.

## Migrating from the Test Collector plugin

If your pipelines currently upload test results to Buildkite Test Engine through the [Test Collector plugin](https://github.com/buildkite-plugins/test-collector-buildkite-plugin) (for example, by generating JUnit XML during a test run and then uploading the files in the same step) — switch to the Tests Buildkite plugin. The Tests Buildkite plugin runs your tests through bktec and collects test data natively, so a single step both runs your tests and reports results to Buildkite Test Engine without a separate upload stage.

A typical migration replaces a Test Collector plugin step like this:

```yaml
steps:
  - label: "Run tests"
    command: "make test"
    plugins:
      - test-collector#v1.0.0:
          files: "test/junit-*.xml"
          format: "junit"
```

With a Tests Buildkite plugin step that runs the tests through bktec and reports results directly:

```yaml
steps:
  - label: "Run tests"
    command: bktec run
    parallelism: 5
    plugins:
      - tests#v1.0.0:
          test-runner: pytest
```

Set `test-runner` to the runner used by your project—for example, `rspec`, `pytest`, `jest`, or `gotestsum`. See the [Tests Buildkite plugin page](https://github.com/buildkite-plugins/tests-buildkite-plugin) for the full list of supported runners and configuration options.

Reasons to move to the Tests Buildkite plugin:

- **Configuration-only setup:** the entire setup lives in `pipeline.yml`, with no JUnit or JSON export step required.
- **Native bktec integration:** the plugin downloads bktec, requests an OIDC token, ensures your test suite exists, and runs your tests with full access to bktec features such as [test splitting](/docs/pipelines/speed-up-builds-with-bktec).
- **Broader runner support:** works with every test runner that [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client) supports, including RSpec, Jest, pytest, and `go test`.

The Test Collector plugin remains supported for [JUnit XML import](/docs/pipelines/configure/tests/test-collection/importing-junit-xml) and [JSON import](/docs/pipelines/configure/tests/test-collection/importing-json), and is the right choice when you need to upload pre-generated test reports from a system that bktec does not drive directly.

## Language-specific test collectors

Language-specific test collectors are available for the following languages and their test runners:

- [Android](/docs/pipelines/configure/tests/test-collection/android-collectors)
- [Elixir (ExUnit)](/docs/pipelines/configure/tests/test-collection/elixir-collectors)
- [Go (gotestsum)](/docs/pipelines/configure/tests/test-collection/golang-collectors)
- [Java (using JUnit XML import)](/docs/pipelines/configure/tests/test-collection/importing-junit-xml)
- [JavaScript (Jest, Cypress, Playwright, Mocha, Jasmine, Vitest)](/docs/pipelines/configure/tests/test-collection/javascript-collectors)
- [.NET (xUnit)](/docs/pipelines/configure/tests/test-collection/dotnet-collectors)
- [Python (pytest)](/docs/pipelines/configure/tests/test-collection/python-collectors)
- [Ruby (RSpec, minitest)](/docs/pipelines/configure/tests/test-collection/ruby-collectors)
- [Rust (Cargo test)](/docs/pipelines/configure/tests/test-collection/rust-collectors)
- [Swift (XCTest)](/docs/pipelines/configure/tests/test-collection/swift-collectors)
- [Other languages or test runners](/docs/pipelines/configure/tests/test-collection/other-collectors)

You can also [create your own test collector](/docs/pipelines/configure/tests/test-collection/your-own-collectors).

## CI environment variables

If your test runner executions are automated through CI/CD, see [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) to learn more about the data that test collectors (and other test collection mechanisms) send to your Buildkite test suites for reporting in test runs.

Once you have configured a test collection mechanism for your projects, you can run your tests and then analyze and report on their data through [test suites](/docs/pipelines/configure/tests/test-suites).
