---
template: "landing_page"
---

# Buildkite Test Engine

Scale out your testing across any framework with _Buildkite Test Engine_. Speed up builds with real-time flaky test management and intelligent test splitting. Drive accountability and get more out of your existing CI compute with performance insights and analytics.

Where [Buildkite Pipelines](/docs/pipelines) helps you automate your CI/CD pipelines, Test Engine helps you track and analyze the steps in these pipelines, by:

- Shipping code to production faster through test optimization.
- Working directly with Buildkite Pipelines, as well as other CI/CD applications.
- Identifying, fixing, and monitoring test performance.
- Tracking, improving, and monitoring test reliability.

<%= image "overview.png", width: 975, height: 205, alt: "Screenshot of test suite trend showing five metrics over 28 days" %>

## Get started

Run through the [Getting started](/docs/test-engine/getting-started) tutorial for a step-by-step guide on how to use Buildkite Test Engine.

If you're familiar with the basics, begin configuring [test collection](/docs/test-engine/test-collection) for your development project. Do this by setting it up with the required Buildkite _test collectors_ for your project's testing frameworks (also known as _test runners_), which sends the required test data information to Test Engine:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":rspec: RSpec", "/docs/test-engine/ruby-collectors#rspec-collector" %>
  <%= button ":ruby: minitest", "/docs/test-engine/ruby-collectors#minitest-collector" %>
  <%= button ":jest: Jest", "/docs/test-engine/javascript-collectors#configure-the-test-framework-jest" %>
  <%= button ":mocha: Mocha", "/docs/test-engine/javascript-collectors#configure-the-test-framework-mocha" %>
  <%= button ":cypress: Cypress", "/docs/test-engine/javascript-collectors#configure-the-test-framework-cypress" %>
  <%= button ":jasmine: Jasmine", "/docs/test-engine/javascript-collectors#configure-the-test-framework-jasmine" %>
  <%= button ":playwright: Playwright", "/docs/test-engine/javascript-collectors#configure-the-test-framework-playwright" %>
  <%= button ":playwright: Vitest", "/docs/test-engine/javascript-collectors#configure-the-test-framework-vitest" %>
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

If a Buildkite test collector is not available for one of these test runners, you can use [other test collection](/docs/test-engine/other-collectors) mechanisms instead.

Once test collection has been set up in your development project, you can proceed to run your tests, and analyze and report on them through its test suites. Learn more about this from the [Test suites overview](/docs/test-engine/test-suites) page, which covers Test Engine's concepts and functionality.

## Core features

<%= tiles "test_engine_features" %>

> 📘 Data retention
> The data uploaded to Test Engine is stored in S3 and deleted after six months.

## API & references

Learn more about Test Engine's APIs through the [REST API documentation](/docs/apis/rest-api), and related endpoints, starting with [test suites](/docs/apis/rest-api/test-engine/suites), as well as Test Engine-specific [webhooks](/docs/apis/webhooks/test-engine).
