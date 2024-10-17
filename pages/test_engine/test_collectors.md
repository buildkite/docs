---
toc: false
---

# Test collectors overview

Before configuring your [test suite](/docs/test-engine/test-suites), you need to configure a _test collector_ for it in your development project. A test collector gathers the required test data information from your development project at build time, and reports this information back to Buildkite for Test Engine to interpret.

Test collectors are available for development projects in the following language and language ecosystems:

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

Once you have configure the appropriate test collector for your project, you can proceed to [configure its test suite](/docs/test-engine/test-suites).
