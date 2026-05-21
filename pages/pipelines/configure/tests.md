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

Run through the [Getting started](/docs/pipelines/test-engine-getting-started) tutorial for a step-by-step guide on how to use Buildkite Test Engine.

If you're familiar with the basics, understand how to run your tests within your development project, and analyze and report on them through a Test Engine [_test suite_](/docs/pipelines/configure/tests/test-suites).

As part of configuring a test suite, you'll need to configure [test collection](/docs/pipelines/configure/tests/test-collection) for your development project. Do this by setting it up with the required Buildkite _test collectors_ for your project's testing frameworks (also known as _test runners_), which sends the required test data information to Test Engine:

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

- Test Engine's APIs through the [REST API documentation](/docs/apis/rest-api), and related endpoints, starting with [test suites](/docs/apis/rest-api/test-engine/suites).
- The [Buildkite MCP server](/docs/apis/mcp-server) and its Test Engine-specific MCP [tools](/docs/apis/mcp-server/tools#available-mcp-tools-test-engine) and [toolsets](/docs/apis/mcp-server/tools/toolsets#available-toolsets).
- Test Engine's [webhooks](/docs/apis/webhooks/test-engine).
- Test Engine [glossary](/docs/pipelines/glossary) of important terms.
