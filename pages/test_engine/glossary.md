# Test Engine glossary

The following terms describe key concepts to help you use Test Engine.

## Dimensions

In the context of Test Engine, dimensions are structured data, consisting of [tags](#tag), which can be used to filter or group (that is, aggregate) test [executions](#execution). Dimensions are added to test executions using the tags feature, which you can learn more about in [Tags](/docs/test-engine/test-suites/tags).

## Execution

An execution is an instance of a single test, which is generated as part of a [run](#run). An execution tracks several aspects of a test, including its _result_ (passed, failed, skipped, other), _duration_ (time), and [dimensions](#dimensions) (that is, [tags](#tag)).

## Flaky test

A flaky test is a [test](#test) that produce inconsistent or unreliable results, despite being run in the same code and environment. Flaky tests are usually identified following a number of [runs](#run) which are executed as part of pipeline builds, such as [those of a Buildkite pipeline](/docs/pipelines/glossary#build).

Learn more about flaky tests in [reduce flaky tests](/docs/test-engine/reduce-flaky-tests).

## Managed test

A managed test refers to any [test](#test) (within all test suites of a Buildkite organization) that can be uniquely identified by its combination of [test suite](#test-suite), [scope](#scope), and name of the test.

For example, each of the following three tests are unique managed tests:

- Test Suite 1 - here.is.scope.one - Login Test name

- Test Suite 1 - here.is.another.scope - Login Test name

- Test Suite 2 - here.is.scope.one - Login Test name

Test Engine uses managed tests to track key areas [test runs](#run), and for billing purposes.

Learn more about managed tests in [Usage and billing](/docs/test-engine/usage-and-billing).

## Quarantine

Quarantine is a classification applied to a [test](#test) that, based on the [state of the test](#test-state), changes how Test Engine [executes](#execution) that test as part of a [run](#run). When a test is quarantined, and its test state is flagged as:

- _mute_, the test is [executed](#execution) as part of the [run](#run), but its failure does not cause the pipeline build to fail, allowing the test's metadata to still be collected.

- _skip_, the test is not be [executed](#execution) as part of the [run](#run), which can allow pipeline builds to execute more rapidly and can reduce costs, but no data is recorded from the test.

Learn more about quarantining tests in [Test state and quarantine](/docs/test-engine/test-suites/test-state-and-quarantine).

## Run

A run is the [execution](#execution) of one or more tests in a [test suite](#test-suite). A _run_ is sometimes referred to as a _test run_, bearing in mind that a single test run usually involves the [execution](#execution) of multiple [tests](#test). A Test Engine _run_ is analogous to a Pipeline [_build_](/docs/pipelines/glossary#build).

## Scope

A scope is a mechanism that can be implemented to differentiate between two or more identically named tests. For example, the following hypothetical tests have the same name as they both test the process of a user logging into a product platform. However, one of these applies to this test being done on a mobile device, while the other applies to a desktop web setting. Therefore, a scope can be used to differentiate between these two tests.

| Name | Scope | Description |
| ----- | ---- | ----------- |
| User logs into platform | Mobile | A mobile user logs into the platform |
| User logs into platform | Web | A web user logs into the platform |

A test's scope is used in determining a [managed test](#managed-test)'s uniqueness.

## Tag

A tag is a `key:value` pair containing two parts:

- The tag's `key` is the identifier, which can only exist once on each test, and is case sensitive.
- The tag's `value` is the specific data or information associated with the `key`.

In Test Engine, tags add [dimensions](#dimensions) to test execution metadata, so that [tests](#test) and their [executions](#execution) can be better filtered, aggregated, and compared in Test Engine visualizations.

Tagging can be used to observe aggregated data points—for example, to observe aggregated performance across several tests, and (optionally) narrow the dataset further based on specific constraints.

Learn more about tags in the [Tags](/docs/test-engine/test-suites/tags) topic.

## Test

A test is an individual piece of code that runs as part of an application's or component's (for example, a library's) building process (which can be automated by [Pipelines](/docs/pipelines)), to ensure that a specific area of the application or component functions as expected.

## Test collection

Test collection is the process of collecting test data from a development project. Test collection may consist of one or more [test collectors](#test-collector) configured within a development project, or make use other methods based on common standards such as JUnit XML or JSON to collect tests.

While a development project's [test runners](#test-runner) (such RSpec or Jest) are typically configured with their respective test collectors, the JUnit XML or JSON test collection mechanisms can be used to collect test data from multiple test runners.

## Test collector

A test collector is a dedicated open source source library (developed by Buildkite) that can be implemented into your development project, to collect test data from a [test runner](#test-runner) within your project.

Buildkite offers [a number of test collectors](/docs/test-engine/test-collection) for a range of languages and their test runners.

## Test runner

A test runner is a synonymous term used for a _test framework_, which is typically a code library that can be integrated into a development project to facilitate the implementation of [tests](#test) for that project.

## Test state

A test state is a configurable flag that can be applied to a [test](#test) (typically [flaky tests](#flaky-test)), which [quarantines](#quarantine) the test and affects how the test is [executed](#execution) as part of a [run](#run).

The following test state flags for quarantining tests are supported:

- _mute_, the test is [executed](#execution) as part of the [run](#run), but its failure does not cause the pipeline build to fail, allowing the test's metadata to still be collected.

- _skip_, the test is not be [executed](#execution) as part of the [run](#run), which can allow pipeline builds to execute more rapidly and can reduce costs, but no data is recorded from the test.

Learn more about test states in [Test state and quarantine](/docs/test-engine/test-suites/test-state-and-quarantine).

## Test suite

A test suite is a collection of [tests](#test), which is managed through Buildkite Test Engine. A _test suite_ is sometimes abbreviated to _suite_.

In a development project configured with of one or more [test runners](#test-runner), it is usually typical to configure a separate test suite each of the project's test runners.
