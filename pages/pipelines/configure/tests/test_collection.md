<!--
TODO(tests-buildkite-plugin): The links to the Tests Buildkite plugin and the
Test Collector Buildkite plugin below are placeholders pending the release of
the new Tests Buildkite plugin (formal name pending). Update both URLs once
the plugins are published to https://buildkite.com/resources/plugins/.
-->

# Test collection overview

To analyze your test data in [Buildkite Test Engine](/docs/test-engine), you need a way to collect data from your project's test runners (for example, RSpec or minitest for Ruby, Jest or Cypress for JavaScript, or pytest for Python) and send that data to a [test suite](/docs/pipelines/configure/tests/test-suites).

The recommended starting point is to add the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/tests-buildkite-plugin) to your pipeline. The plugin sets up your pipeline to run tests with Buildkite Test Engine: it downloads the [Test Engine Client (bktec)](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client), requests an [OIDC](/docs/pipelines/configure/tests/test-collection/oidc) token, ensures your test suite exists, and exports the environment variables that bktec expects. The Tests Buildkite plugin works with every test runner that bktec supports, including RSpec, Jest, pytest, and `go test`.

After adding the Tests Buildkite plugin, choose how to collect the test data itself. There are two supported paths:

- **Use the Test Collector Buildkite plugin (recommended):** the [Test Collector Buildkite plugin](https://buildkite.com/resources/plugins/test-collector-buildkite-plugin) collects test data without requiring any changes to your application code. Pairing the Tests Buildkite plugin with the Test Collector Buildkite plugin is the fastest way to get a test suite reporting data to Buildkite Test Engine, because the entire setup lives in `pipeline.yml`.
- **Use a language-specific test collector:** language-specific collectors provide deeper framework integration—such as RSpec annotation spans, pytest custom markers, and richer per-framework execution tags. This path requires adding a library dependency to your application code, so it takes more effort to set up than the plugin-only path.

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
