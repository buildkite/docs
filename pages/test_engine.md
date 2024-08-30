---
template: "landing_page"
---

# Buildkite Test Analytics

Where Buildkite Pipelines help you automate your build pipelines,
Test Analytics helps you track and analyze the steps in that pipeline that involve tests:

- Ship code to production faster by optimizing test suites
- Works with any continuous integration
- Identify, fix, and monitor test suite performance
- Track, improve, and monitor test suite reliability

<%= image "overview.png", width: 975, height: 205, alt: "Screenshot of test suite trend showing five metrics over 28 days" %>

## Get started

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

>📘 Data retention
> The data uploaded to Test Analytics is stored in S3 and deleted after six months.

----

<%= tiles "test_analytics_features" %>

----

<%= tiles "test_analytics_guides" %>
