---
template: "landing_page"
---

# Test Engine overview

Test Engine is the testing layer of [Buildkite Pipelines](/docs/pipelines). It collects test results from the jobs your pipelines run, then provides tools to track, analyze, and act on those results across any testing framework. Test Engine also accepts results from non-Buildkite CI systems, so you can use it alongside an existing CI/CD setup while migrating to Buildkite Pipelines.

Use Test Engine to:

- Detect and quarantine flaky tests so they stop blocking builds.
- Split tests across parallel jobs to reduce build duration.
- Monitor test performance, reliability, and ownership over time.
- Surface the slowest and least reliable tests in each suite.

<%= image "overview.png", width: 2594, height: 624, alt: "Screenshot of test suite trend showing six metrics over the last day" %>

## Get started

New to Test Engine? Work through the [Add a test suite](/docs/pipelines/getting-started#add-a-test-suite) section of the Pipelines getting started tutorial, which walks you through creating a [test suite](/docs/pipelines/configure/tests/test-suites), configuring a [test collector](/docs/pipelines/configure/tests/test-collection) for your project, and automating the test runner with Buildkite Pipelines.

<!--
TODO(tests-buildkite-plugin): The links to the Tests Buildkite plugin and the
Test Collector Buildkite plugin below are placeholders pending the release of
the new Tests Buildkite plugin (formal name pending). Update both URLs once
the plugins are published to https://buildkite.com/resources/plugins/.
-->

> 📘 Recommended setup
> The golden path for new test suites is to add the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/tests-buildkite-plugin) together with the [Test Collector Buildkite plugin](https://buildkite.com/resources/plugins/test-collector-buildkite-plugin) to the step that runs your tests. Learn more in the [Test collection overview](/docs/pipelines/configure/tests/test-collection).

If you're already familiar with the basics, jump directly to a collector for your testing framework (also known as a _test runner_):

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":rspec: RSpec", "/docs/pipelines/configure/tests/test-collection/ruby-collectors#rspec-collector" %>
  <%= button ":ruby: minitest", "/docs/pipelines/configure/tests/test-collection/ruby-collectors#minitest-collector" %>
  <%= button ":jest: Jest", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-jest" %>
  <%= button ":mocha: Mocha", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-mocha" %>
  <%= button ":cypress: Cypress", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-cypress" %>
  <%= button ":jasmine: Jasmine", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-jasmine" %>
  <%= button ":playwright: Playwright", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-playwright" %>
  <%= button ":vitest: Vitest", "/docs/pipelines/configure/tests/test-collection/javascript-collectors#configure-the-test-framework-vitest" %>
  <%= button ":swift: Swift", "/docs/pipelines/configure/tests/test-collection/swift-collectors" %>
  <%= button ":android: Android", "/docs/pipelines/configure/tests/test-collection/android-collectors" %>
  <%= button ":pytest: pytest", "/docs/pipelines/configure/tests/test-collection/python-collectors" %>
  <%= button ":golang: Go", "/docs/pipelines/configure/tests/test-collection/golang-collectors" %>
  <%= button ":junit: JUnit", "/docs/pipelines/configure/tests/test-collection/importing-junit-xml" %>
  <%= button ":dotnet: .NET", "/docs/pipelines/configure/tests/test-collection/dotnet-collectors" %>
  <%= button ":elixir: Elixir", "/docs/pipelines/configure/tests/test-collection/elixir-collectors" %>
  <%= button ":rust: Rust", "/docs/pipelines/configure/tests/test-collection/rust-collectors" %>
</div>

<!-- vale on -->

If a Buildkite test collector is not available for one of these test runners, you can use [other test collection](/docs/pipelines/configure/tests/test-collection/other-collectors) mechanisms instead.

## Core features

<%= tiles "test_engine_features" %>

> 📘 Data retention
> The execution data uploaded to Test Engine is stored in S3 and deleted after 120 days.

## API & references

Learn more about:

- The Test Engine [REST API endpoints](/docs/apis/rest-api/test-engine/suites), starting with test suites.
- The [Buildkite MCP server](/docs/apis/mcp-server) and its Test Engine-specific [tools](/docs/apis/mcp-server/tools#available-mcp-tools-test-engine) and [toolsets](/docs/apis/mcp-server/tools/toolsets#available-toolsets).
- Test Engine [webhooks](/docs/apis/webhooks/test-engine).
- Test Engine terms in the Pipelines [glossary](/docs/pipelines/glossary).
