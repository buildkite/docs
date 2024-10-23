---
toc: false
---

# Test collection overview

Before configuring your [test suite](/docs/test-engine/test-suites), you need to configure a Buildkite _test collector_ for it in your development project, or some other mechanism for collecting data from your development project to send to Test Engine.

A test collector is a library or code addition that gathers the required test data information from your development project at build time, and sends this information back to Buildkite for Test Engine to interpret and report on.

Test collectors are available for development projects in the following language frameworks:

- [Ruby](/docs/test-engine/ruby-collectors)
- [JavaScript](/docs/test-engine/javascript-collectors)
- [Swift](/docs/test-engine/swift-collectors)
- [Android](/docs/test-engine/android-collectors)
- [Python](/docs/test-engine/python-collectors)
- [Go](/docs/test-engine/golang-collectors)
- [.NET](/docs/test-engine/dotnet-collectors)
- [Elixir](/docs/test-engine/elixir-collectors)
- [Rust](/docs/test-engine/rust-collectors)
- [Java (via JUnit XML import)](/docs/test-engine/importing-junit-xml)
- [Other languages](/docs/test-engine/other-collectors)

Once you have configure the appropriate test collector for your project, you can proceed to run your tests and analyze the data through its [test suite](/docs/test-engine/test-suites).
