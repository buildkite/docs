---
template: "landing_page"
---

# Buildkite Test Engine

Scale out your testing across any framework with Buildkite Test Engine. Get more out of fewer tests with performance insights to speed up builds and isolate unreliable tests.

Where [Buildkite Pipelines](/docs/pipelines) helps you automate your CI/CD pipelines, Test Engine helps you track and analyze the steps in these pipelines, by:

- Shipping code to production faster through test suite optimization.
- Working directly with Buildkite Pipelines, as well as other CI/CD applications.
- Identifying, fixing, and monitoring test suite performance.
- Tracking, improving, and monitoring test suite reliability.

<%= image "overview.png", width: 975, height: 205, alt: "Screenshot of test suite trend showing five metrics over 28 days" %>

_Buildkite Test Engine_ was previously called _Buildkite Test Analytics_.

## Get started

Run through the 'Getting started' section of these Test Engine docs, beginning with [Configuring test suites](/docs/test-engine/test-suites) for an overview of Test Engine's concepts and functionality, followed by the appropriate test collector for project's language:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":rspec: RSpec", "/docs/test-engine/ruby-collectors#rspec-collector" %>
  <%= button ":ruby: minitest", "/docs/test-engine/ruby-collectors#minitest-collector" %>
  <%= button ":jest: Jest", "/docs/test-engine/javascript-collectors#configure-the-test-framework-jest" %>
  <%= button ":mocha: Mocha", "/docs/test-engine/javascript-collectors#configure-the-test-framework-mocha" %>
  <%= button ":cypress: Cypress", "/docs/test-engine/javascript-collectors#configure-the-test-framework-cypress" %>
  <%= button ":jasmine: Jasmine", "/docs/test-engine/javascript-collectors#configure-the-test-framework-jasmine" %>
  <%= button ":playwright: Playwright", "/docs/test-engine/javascript-collectors#configure-the-test-framework-playwright" %>
  <%= button ":swift: Swift", "/docs/test-engine/swift-collectors" %>
  <%= button ":android: Android", "/docs/test-engine/android-collectors" %>
  <%= button ":pytest: pytest", "/docs/test-engine/python-collectors" %>
  <%= button ":golang: Go", "/docs/test-engine/golang-collectors" %>
  <%= button ":junit: JUnit", "/docs/test-engine/importing-junit-xml" %>
  <%= button ":dotnet: .NET", "/docs/test-engine/dotnet-collectors" %>
  <%= button ":elixir: Elixir", "/docs/test-engine/elixir-collectors" %>
  <%= button ":rust: Rust", "/docs/test-engine/rust-collectors" %>
</div>

<!-- vale on -->

You can also upload test results by importing [JSON](/docs/test-engine/importing-json) or [JUnit XML](/docs/test-engine/importing-junit-xml).

<br/>

<%= tiles "test_engine_features" %>

> 📘 Data retention
> The data uploaded to Test Engine is stored in S3 and deleted after six months.

<%= tiles "test_engine_guides" %>
