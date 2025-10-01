# Test Engine glossary

The following terms describe key concepts to help you use Test Engine.

## Action

An action is part of a [workflow](#workflow) and provides a user defined operation that is triggered automatically when a workflow [monitor](#monitor) enters the [alarm](#alarm) or [recover](#recover) event state for a [test](#test). Actions can be for operations that happen within the Test Engine system (that is, changing a test's [state](#test-state) or [label](/docs/test-engine/test-suites/labels)), or externally to Test Engine (for example, sending a Slack notification about the test).

Learn more about actions in [Alarm and recover actions](/docs/test-engine/workflows/actions).

## Alarm

Alarm, along with [recover](#recover), is one of the two types of events that a workflow [monitor](#monitor) can alert on. Alarm events are reported by the monitor when the alarm conditions are met. Depending on the monitor type, these alarm conditions are configurable.

Alarm [actions](#action) are performed when the alarm event is reported by the monitor. Repeated occurrences of the test meeting the alarm conditions do not retrigger alarm actions.

## Dimensions

In the context of Test Engine, dimensions are structured data, consisting of [tags](#tag), which can be used to filter or group (that is, aggregate) test [executions](#execution). Dimensions are added to test executions using the tags feature, which you can learn more about in [Tags](/docs/test-engine/test-suites/tags).

## Execution

An execution is an instance of a single test, which is generated as part of a [run](#run). An execution tracks several aspects of a test, including its _result_ (passed, failed, skipped, other), _duration_ (time), and [dimensions](#dimensions) (that is, [tags](#tag)).

## Flaky test

A flaky test is a [test](#test) that produce inconsistent or unreliable results, despite being run in the same code and environment. Flaky tests are identified via [workflows](docs/test-engine/workflows).

Learn more about flaky tests in [reduce flaky tests](/docs/test-engine/reduce-flaky-tests).

## Managed test

A managed test refers to any [test](#test) (within all test suites of a Buildkite organization) that can be uniquely identified by its combination of [test suite](#test-suite), [scope](#scope), and name of the test.

For example, each of the following three tests are unique managed tests:

- Test Suite 1 - here.is.scope.one - Login Test name

- Test Suite 1 - here.is.another.scope - Login Test name

- Test Suite 2 - here.is.scope.one - Login Test name

Test Engine uses managed tests to track key areas [test runs](#run), and for billing purposes.

Learn more about managed tests in [Usage and billing](/docs/test-engine/usage-and-billing).

## Monitor

A monitor is a part of a [workflow](#workflow) and is used to observe [tests](#test) over time. Monitors help to surface valuable qualitative information about the tests in your [test suite](#test-suite), which can be difficult to surmise from raw execution data. Monitors can report on special events (for example, a passed on retry event) or produce scores (such as, transition count score).

A single monitor watches over all the tests in your test suite (apart from those excluded by filters) and generates individual [alarm](#alarm) and [recover](#recover) events for each test, which then trigger the associated alarm and recover [action](#action).

Learn more about the different monitors types in [Monitors](/docs/test-engine/workflows/monitors).

## Quarantine

Quarantine is a classification applied to a [test](#test) that, based on the [state of the test](#test-state), changes how Test Engine [executes](#execution) that test as part of a [run](#run). When a test is quarantined, and its test state is flagged as:

- **muted**, the test is [executed](#execution) as part of the [run](#run), but its failure does not cause the pipeline build to fail, allowing the test's metadata to still be collected.

- **skipped**, the test is not be [executed](#execution) as part of the [run](#run), which can allow pipeline builds to execute more rapidly and can reduce costs, but no data is recorded from the test.

Learn more about quarantining tests in [Test state and quarantine](/docs/test-engine/test-suites/test-state-and-quarantine).

## Recover

Recover, along with [alarm](#alarm), is one of the two types of events that a workflow [monitor](#monitor) can alert on. Recover events are [hysteric](https://en.wikipedia.org/wiki/Hysteresis), meaning that the recover event can only be reported on a test that has a previous alarm event. In such a situation, when the monitor detects that the test has met the recover conditions, a recover event is reported. Depending on the monitor type, these recover conditions can be configurable.

Recover [actions](#action) are performed when the recover event is reported by the monitor. Repeated occurrences of the test meeting the recover conditions do not retrigger recover actions.

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

When a test is in a trusted state, its test state is flagged as **enabled**, and the following test state flags are supported when a test is being quarantined:

- **muted**, the test is [executed](#execution) as part of the [run](#run), but its failure does not cause the pipeline build to fail, allowing the test's metadata to still be collected.

- **skipped**, the test is not be [executed](#execution) as part of the [run](#run), which can allow pipeline builds to execute more rapidly and can reduce costs, but no data is recorded from the test.

Learn more about test states in [Test state and quarantine](/docs/test-engine/test-suites/test-state-and-quarantine).

## Test suite

A test suite is a collection of [tests](#test), which is managed through Buildkite Test Engine. A _test suite_ is sometimes abbreviated to _suite_.

In a development project configured with of one or more [test runners](#test-runner), it is usually typical to configure a separate test suite each of the project's test runners.

## Workflow

A workflow defines a process that's composed of a single [monitor](#monitor) and any number of [actions](#action). A workflow enables a user to define a custom identification and management system for tests of interest in their suite. Flaky test management is a common use case for workflows.

Learn more about workflows in the [Workflows overview](/docs/test-engine/workflows).
