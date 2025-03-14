---
toc: false
---

# Test collection overview

Before configuring a [test suite](/docs/test-engine/test-suites), you need to configure a Buildkite _test collector_ for your development project's test runners (for example, RSpec or minitest for Ruby, or Jest or Cypress for JavaScript), or some other mechanism for collecting data from your project's test runners to send to Test Engine.

A test collector is a library or plugin that runs inside your test runner to gather the required test data information to send back to Buildkite for Test Engine to interpret, analyze and report on.

Test collectors are available for the following languages and their test runners:

- [Android](/docs/test-engine/android-collectors)
- [Elixir (ExUnit)](/docs/test-engine/elixir-collectors)
- [Go (gotestsum)](/docs/test-engine/golang-collectors)
- [Java (via JUnit XML import)](/docs/test-engine/importing-junit-xml)
- [JavaScript (Jest, Cypress, Playwright, Mocha, Jasmine)](/docs/test-engine/javascript-collectors)
- [.NET (xUnit)](/docs/test-engine/dotnet-collectors)
- [Python (pytest)](/docs/test-engine/python-collectors)
- [Ruby (RSpec, minitest)](/docs/test-engine/ruby-collectors)
- [Rust (Cargo test)](/docs/test-engine/rust-collectors)
- [Swift (XCTest)](/docs/test-engine/swift-collectors)
- [Other languages or test runners](/docs/test-engine/other-collectors)

Note that you can also [create your own test collectors](/docs/test-engine/your-own-collectors).

If your test runner executions are automated through CI/CD, learn more about the [CI environment variables](/docs/test-engine/ci-environments) that test collectors (and other test collection mechanisms) provide to your Buildkite test suites, for reporting in test runs.

Once you have configured the appropriate test collectors for your projects, you can proceed to run your tests, and analyze and report on their data through their [test suites](/docs/test-engine/test-suites).
