# Usage and billing

Test Engine is designed to optimize your test suite through the management of your tests.

## Managed tests

A _managed test_ is a uniquely identifiable test by scope and name.

Test Engine will track the history of each test, calculate flakiness, automatically
quarantine and attribute ownership based on this uniquely identified managed test.

Buildkite calculates your usage by determining the number of managed tests each day
and then bill based on the 90th percentile of usage for the month. This method ensures
occasional spikes in usage, such as those caused by refactoring, don't result in excessive charges.

## Test executions (legacy)

Some legacy Buildkite plans meter on the number of times a test was executed (run).

You can find the test execution details for a run at the bottom of the run page, and your organization's [total usage](#usage-page) in Settings.

<%= image "test_executions.png", alt: "Test executions run page" %>

## Usage page

The [Usage page](https://buildkite.com/organizations/~/usage) is available on every Buildkite plan and shows a breakdown of all billable usage for your organization including managed tests and test executions.

The [managed tests usage page](https://buildkite.com/organizations/~/usage/test_engine_managed_tests) graphs the maximum number of unique
tests per day over the organization's billing periods. It includes a breakdown of usage by suite and a CSV download of usage over the period.

The [test executions usage page](https://buildkite.com/organizations/~/usage/test_executions) graphs the total executions over the organization's billing periods. It includes a breakdown of usage by suite and a CSV download of usage over the period.

Your organization's usage is also accessible in the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#query-the-usage-api).
