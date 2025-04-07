# Pipelines glossary

The following terms describe key concepts to help you use Test Engine.

## Dimensions

In the context of Test Engine, dimensions relate to structured data, consisting of [tags](#tag), which can be used to filter or group (that is, aggregate) test executions. Dimensions are added to test executions using the tags feature, which you can learn more about in [Tags](/docs/test-engine/tags).

## Execution

An execution is the result of a single test run.

## Managed test

A managed test refers to any [test](#test) (within all test suites of a Buildkite organization) that can be uniquely identified by its combination of [test suite](#test-suite), [scope](#scope), and name of the test.

For example, each of the following three tests are unique managed tests:

- Test Suite 1 - here.is.scope.one - Login Test name

- Test Suite 1 - here.is.another.scope - Login Test name

- Test Suite 2 - here.is.scope.one - Login Test name

Test Engine uses managed tests to track of key areas test runs, and for billing purposes.

Learn more about managed tests in [Usage and billing](/docs/test-engine/usage-and-billing).

## Quarantine



## Run

The execution of one or more tests in a [test suite](#test-suite).

## Scope



## Tag



## Test

A test is an individual piece of code that runs as part of an application's or component's (for example, a library's) building process (which can be automated by [Pipelines](/docs/pipelines)), to ensure that a specific area of the application or component functions as expected.

## Test collection

Test collection is the process of collecting test data from a development project. Test collection may consist of one or more [test collectors](#test-collector) configured within a development project, or make use other methods based on common standards such as JUnit XML or JSON to collect tests.

While a development project's test runners (such RSpec or Jest) are typically configured with their respective test collectors, the JUnit XML or JSON test collection mechanisms can be used to collect test data from multiple test runners.

## Test collector

A test collector is a dedicated open source source library (developed by Buildkite) that can be implemented into your development project, to collect test data from a test runner within your project.

Buildkite offers [a number of test collectors](/docs/test-engine/test-collection) for a range of languages and their test runners.

## Test runner

A test runner is a synonymous term used for a _test framework_, which is typical a code library that can be integrated into a development project to facilitate the implementation of [tests](#test) for that project.

## Test state



## Test suite

A test suite is a collection of [tests](#test), which is managed through Buildkite Test Engine. A _test suite_ is sometimes abbreviated to _suite_.

In a development project configured with of one or more [test runners](#test-runner), it is usually typical to configure one test suite for each of these test runners.
