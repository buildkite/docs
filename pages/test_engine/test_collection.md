---
toc: false
---

# Test collection overview

Before configuring a [test suite](/docs/test-engine/test-suites), you need to configure a Buildkite _test collector_ for your development project's test runners (for example, RSpec or minitest for Ruby, or Jest or Cypress for JavaScript), or some other mechanism for collecting data from your project's test runners to send to Test Engine.

A test collector is a library or plugin that runs inside your test runner to gather the required test data information, and sends this information back to Buildkite for Test Engine to interpret, analyze and report on.

Test collectors are available for the following test runners:

- [Ruby (RSpec, minitest)](/docs/test-engine/ruby-collectors)
- [JavaScript (Jest, Cypress, Playwright, Mocha, Jasmine)](/docs/test-engine/javascript-collectors)
- [Swift (CXTest)](/docs/test-engine/swift-collectors)
- [Android](/docs/test-engine/android-collectors)
- [Python (pytest)](/docs/test-engine/python-collectors)
- [Go (gotestsum)](/docs/test-engine/golang-collectors)
- [.NET (xUnit)](/docs/test-engine/dotnet-collectors)
- [Elixir (ExUnit)](/docs/test-engine/elixir-collectors)
- [Rust (Cargo test)](/docs/test-engine/rust-collectors)
- [Java (via JUnit XML import)](/docs/test-engine/importing-junit-xml)
- [Other languages](/docs/test-engine/other-collectors)

Once you have configure the appropriate test collector for your project, you can proceed to run your tests, and analyze and report on their data through its [test suite](/docs/test-engine/test-suites).
