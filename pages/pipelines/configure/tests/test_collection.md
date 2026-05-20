---
toc: false
---

# Test collection overview

To allow your [test suite](/docs/pipelines/configure/tests/test-suites) to collect test data from your development project, you need to configure a Buildkite _test collector_ for your project's test runners (for example, RSpec or minitest for Ruby, or Jest or Cypress for JavaScript), or some other mechanism for collecting data from your project's test runners to send to Test Engine.

A test collector is a library or plugin that runs inside your test runner to gather the required test data information to send back to Buildkite for Test Engine to interpret, analyze and report on.

Test collectors are available for the following languages and their test runners:

- [Android](/docs/pipelines/configure/tests/test-collection/android-collectors)
- [Elixir (ExUnit)](/docs/pipelines/configure/tests/test-collection/elixir-collectors)
- [Go (gotestsum)](/docs/pipelines/configure/tests/test-collection/golang-collectors)
- [Java (via JUnit XML import)](/docs/pipelines/configure/tests/test-collection/importing-junit-xml)
- [JavaScript (Jest, Cypress, Playwright, Mocha, Jasmine, Vitest)](/docs/pipelines/configure/tests/test-collection/javascript-collectors)
- [.NET (xUnit)](/docs/pipelines/configure/tests/test-collection/dotnet-collectors)
- [Python (pytest)](/docs/pipelines/configure/tests/test-collection/python-collectors)
- [Ruby (RSpec, minitest)](/docs/pipelines/configure/tests/test-collection/ruby-collectors)
- [Rust (Cargo test)](/docs/pipelines/configure/tests/test-collection/rust-collectors)
- [Swift (XCTest)](/docs/pipelines/configure/tests/test-collection/swift-collectors)
- [Other languages or test runners](/docs/test-engine/other-collectors)

Note that you can also [create your own test collectors](/docs/pipelines/configure/tests/test-collection/your-own-collectors).

If your test runner executions are automated through CI/CD, learn more about the [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) that test collectors (and other test collection mechanisms) provide to your Buildkite test suites, for reporting in test runs.

Once you have configured the appropriate test collectors for your projects, you can proceed to run your tests, and analyze and report on their data through their [test suites](/docs/pipelines/configure/tests/test-suites).
