# Usage and billing

Test Engine is designed to optimize your test suites through the management of your tests.

## Managed tests

Each and every test that can be uniquely identified by its combination of test suite, scope, and name, is a _managed test_, which in turn is used for billing purposes in Test Engine.

For example, each of the following three tests are unique managed tests:

- Test Suite 1 - here.is.scope.one - Login Test name
- Test Suite 1 - here.is.another.scope - Login Test name
- Test Suite 2 - here.is.scope.one - Login Test name

Test Engine conducts the following on each managed test:

- Tracks its history
- Maintains its state (for example, [Enterprise plan](https://buildkite.com/pricing) customers can quarantine tests by disabling them under certain conditions)
- Attributes [ownership by team](/docs/test-engine/test-suites/test-ownership)

For billing purposes, Buildkite measures usage by calculating the number of managed tests that have executed (run) at least once each day, and then bills based on the 90th percentile of this usage for the month. This billing method ensures that occasional spikes in usage, such as those caused by refactoring, don't result in excessive charges.

> 📘 Executed managed tests are only charged once per day
> If a specific managed test has run multiple times on a specific day, then this only counts once towards the usage measurement for that day.

## Test executions

Some legacy Buildkite plans measure usage based on the _total number of times_ a test was executed (run).

You can find the test execution details for a run at the bottom of the run page, and your organization's [total usage](#usage-page) in Settings.

<%= image "test_executions.png", alt: "Test executions run page" %>

## Usage page

The [Usage page](https://buildkite.com/organizations/~/usage?product=test_engine) is available on every Buildkite plan, and shows a breakdown of all billable usage for your organization including managed tests and test executions.

The [managed tests usage page](https://buildkite.com/organizations/~/usage/test_engine_managed_tests) graphs the maximum number of unique tests per day over the organization's billing periods. This page includes a breakdown of usage by suite and a CSV download of usage over the period.

The [test executions usage page](https://buildkite.com/organizations/~/usage/test_executions) graphs the total executions over the organization's billing periods. This page includes a breakdown of usage by suite and a CSV download of usage over the period.
