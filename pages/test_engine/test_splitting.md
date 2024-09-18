# Test splitting

Test splitting is a feature that:

- Allows you to substantially reduce your overall build times, especially for pipelines with highly complex and computationally intensive test suites.
- Intelligently partitions your test suites to run in parallel across multiple agents, with the intent to even out test execution times across your agents, such that each agent will complete its partitioned test executions at approximately similar times.

The following image from Test Engine's test splitting setup page illustrates how this feature works. In this example, _without_ test splitting, the test suite build time would take as long as it takes for the slowest combination of tests and agent (known as a partition) to run, which is 10 minutes. Since the sum of all test executions across all agents is 16 minutes, _with_ test splitting implemented, all four partitions would take approximately 4 minutes to run, such that the overall test suite build time would be approximately 4 minutes, or a 6-minute reduction.

<%= image "setup-page-summary.png", alt: "The test splitting setup page in Test Engine" %>

Learn more about how to configure test splitting for your test suites in [Configuring test splitting](/docs/test-engine/test-splitting/configuring).
