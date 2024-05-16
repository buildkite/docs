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
  <%= button ":rspec: RSpec", "/docs/test-analytics/ruby-collectors#rspec-collector" %>
  <%= button ":ruby: minitest", "/docs/test-analytics/ruby-collectors#minitest-collector" %>
  <%= button ":jest: Jest", "/docs/test-analytics/javascript-collectors#configure-the-test-framework-jest" %>
  <%= button ":mocha: Mocha", "/docs/test-analytics/javascript-collectors#configure-the-test-framework-mocha" %>
  <%= button ":cypress: Cypress", "/docs/test-analytics/javascript-collectors#configure-the-test-framework-cypress" %>
  <%= button ":jasmine: Jasmine", "/docs/test-analytics/javascript-collectors#configure-the-test-framework-jasmine" %>
  <%= button ":playwright: Playwright", "/docs/test-analytics/javascript-collectors#configure-the-test-framework-playwright" %>
  <%= button ":swift: Swift", "/docs/test-analytics/swift-collectors" %>
  <%= button ":android: Android", "/docs/test-analytics/android-collectors" %>
  <%= button ":pytest: pytest", "/docs/test-analytics/python-collectors" %>
  <%= button ":golang: Go", "/docs/test-analytics/golang-collectors" %>
  <%= button ":junit: JUnit", "/docs/test-analytics/importing-junit-xml" %>
  <%= button ":dotnet: .NET", "/docs/test-analytics/dotnet-collectors" %>
  <%= button ":elixir: Elixir", "/docs/test-analytics/elixir-collectors" %>
  <%= button ":rust: Rust", "/docs/test-analytics/rust-collectors" %>
</div>

<!-- vale on -->

You can also upload test results by importing [JSON](/docs/test-analytics/importing-json) or [JUnit XML](/docs/test-analytics/importing-junit-xml).

>📘 Data retention
> The data uploaded to Test Analytics is stored in S3 and deleted after six months.

----

<%= tiles "test_analytics_features" %>

----

<%= tiles "test_analytics_guides" %>
