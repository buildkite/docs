# Test executions

Each [Buildkite plan](https://buildkite.com/pricing) has test execution inclusions, which vary depending on the plan type and the number of users in your organization.

You can find the test execution details for a run at the bottom of the run page, and your organization's [total usage](#usage-page) in Settings.
<%= image "test_executions.png", alt: "Test executions run page" %>

## Usage page

The [Usage page](https://buildkite.com/organizations/~/usage) is available on every Buildkite plan and shows a breakdown of job minutes and test executions for your organization.

The [test executions usage page](https://buildkite.com/organizations/~/usage/test_executions) graphs the total executions over the organization's billing periods. It includes a breakdown of usage by suite and a CSV download of usage over the period.

Your organization's usage is also accessible in the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#query-the-usage-api).
