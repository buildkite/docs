---
toc: false
---

# Test splitting

Intelligently partition your pipeline with test splitting to substantially reduce build times and your critical path to delivery.

- Split tests automatically based on your historical timing data.
- Maintain peak speed through continuous optimization and automated re-balancing.

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing/) can leverage test splitting. If you are on a legacy plan please contact sales@buildkite.com to gain access this feature and try it out.

Test Engine can automatically split tests on the following frameworks: Cypress, Jest, PlayWright, Pytest, pytest-pants, RSpec, Go, and cucumber.

## How it works

The following image from Test Engine's test splitting setup page illustrates how this feature works.

<%= image "setup-page-summary.png", alt: "The test splitting setup page in Test Engine" %>

In this example, _without_ test splitting, the test suite build time would take as long as it takes for the slowest combination of tests to run on a single partition (Buildkite job), which is 10 minutes.

Since the sum of all test executions across all agents is 16 minutes, _with_ test splitting implemented, all four partitions would take approximately 4 minutes to run, such that the overall test suite build time would be approximately 4 minutes, or a 6-minute reduction.

Learn more about how to configure test splitting for your test suites in [Configuring test splitting](/docs/test-engine/test-splitting/configuring).
