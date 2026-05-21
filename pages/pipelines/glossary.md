# Pipelines glossary

The following terms describe key concepts to help you use Buildkite Pipelines, including its [test suites](/docs/pipelines/configure/tests) features (Test Engine).

## Action

An action is part of a [workflow](#workflow) and provides a user defined operation that is triggered automatically when a workflow [monitor](#monitor) enters the [alarm](#alarm) or [recover](#recover) event state for a [test](#test). Actions can apply to the test itself (for example, changing its [state](#test-state) or [label](/docs/pipelines/configure/tests/test-suites/labels)), or to an external system (for example, sending a Slack notification about the test).

Learn more about actions in [Alarm and recover actions](/docs/pipelines/configure/tests/workflows/actions).

## Agent

An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines. You need at least one agent to run builds.

To learn more, see the [Agent overview](/docs/agent).

## Alarm

Alarm, along with [recover](#recover), is one of the two types of events that a workflow [monitor](#monitor) can alert on. Alarm events are reported by the monitor when the alarm conditions are met. Depending on the monitor type, these alarm conditions are configurable.

Alarm [actions](#action) are performed when the alarm event is reported by the monitor. Repeated occurrences of the test meeting the alarm conditions do not retrigger alarm actions.

## Artifact

An artifact is a file generated during a build. You can keep artifacts in a Buildkite-managed storage service or a third-party cloud storage service like Amazon S3, Google Cloud Storage, or Artifactory. Common uses include storing assets like logs and reports, or passing files between steps.

To learn more, see [Build artifacts](/docs/pipelines/configure/artifacts).

## Build

A build is a single run of a pipeline. You can trigger a build in various ways, including through the dashboard, API, as the result of a webhook, on a schedule, or even from another pipeline using a trigger step.

## Buildkite organization administrator

A Buildkite organization administrator is a user with full administrative control over a Buildkite organization. Organization administrators can manage teams, configure organization-level settings, control pipeline and security permissions, and access usage reports and [audit logs](/docs/platform/audit-log).

To learn more, see [User and team permissions](/docs/platform/team-management/permissions).

## Cluster

A cluster groups [queues](#queue) of agents along with pipelines. Clusters allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

To learn more, see the [Clusters overview](/docs/pipelines/security/clusters).

## Dimensions

In the context of [test suites](/docs/pipelines/configure/tests), dimensions are structured data, consisting of [tags](#tag), which can be used to filter or group (that is, aggregate) test [executions](#execution). Dimensions are added to test executions using the tags feature, which you can learn more about in [Tags](/docs/pipelines/configure/tests/test-suites/tags).

## Dynamic pipeline

Dynamic pipelines define their steps at runtime using scripts, giving you the flexibility to only run the steps relevant to particular code changes and workflows.

Dynamic pipelines are helpful when you have a complex build process that requires different steps to execute based on runtime conditions, such as the branch, the environment, or the results of previous steps.

To learn more, see [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

## Ephemeral agent

An ephemeral agent is a Buildkite agent that only operates for the duration in which it runs a [job](#job). Such an agent is disconnected either once its job is completed, or the agent's idle time period has been reached. An ephemeral agent is created when one of the following options has been used to [start the Buildkite agent](/docs/agent/cli/reference/start):

- `--acquire-job`
- `--disconnect-after-job`
- `--disconnect-after-idle-timeout`

Learn more about ephemeral agents in [Pause and resume an agent](/docs/agent/self-hosted/pausing-and-resuming).

## Execution

An execution is an instance of a single test, which is generated as part of a [run](#run). An execution tracks several aspects of a test, including its _result_ (passed, failed, skipped, other), _duration_ (time), and [dimensions](#dimensions) (that is, [tags](#tag)).

## Flaky test

A flaky test is a [test](#test) that produce inconsistent or unreliable results, despite being run in the same code and environment. Flaky tests are identified via [workflows](/docs/pipelines/configure/tests/workflows).

Learn more about flaky tests in [Reduce flaky tests](/docs/pipelines/reduce-flaky-tests).

## Hook

A hook is a method of customizing the behavior of Buildkite through lifecycle events. They let you run scripts at different points of the agent or job lifecycle. Using hooks, you can extend the functionality of Buildkite and automate tasks specific to your workflow and requirements.

To learn more, see [Hooks](/docs/agent/hooks).

## Job

A job is the execution of a command step during a build. Jobs run the commands, scripts, or plugins defined in the step.

A job can be in various states during its lifecycle, such as `pending`, `scheduled`, `running`, `finished`, `failed`, `canceled`, and others. These states represent the execution state of the job as it progresses through the build system.

To learn more, see [Job states](/docs/pipelines/configure/defining-steps#job-states).

## Managed test

A managed test refers to any [test](#test) (within all test suites of a Buildkite organization) that can be uniquely identified by its combination of [test suite](#test-suite), [scope](#scope), and name of the test.

For example, each of the following three tests are unique managed tests:

- Test Suite 1 - here.is.scope.one - Login Test name

- Test Suite 1 - here.is.another.scope - Login Test name

- Test Suite 2 - here.is.scope.one - Login Test name

Managed tests are used to track key areas of [test runs](#run), and for billing purposes.

## Monitor

A monitor is a part of a [workflow](#workflow) and is used to observe [tests](#test) over time. Monitors help to surface valuable qualitative information about the tests in your [test suite](#test-suite), which can be difficult to surmise from raw execution data. Monitors can report on special events (for example, a passed on retry event) or produce scores (such as, transition count score).

A single monitor watches over all the tests in your test suite (apart from those excluded by filters) and generates individual [alarm](#alarm) and [recover](#recover) events for each test, which then trigger the associated alarm and recover [action](#action).

Learn more about the different monitors types in [Monitors](/docs/pipelines/configure/tests/workflows/monitors).

## Pipeline

A pipeline is a container for modeling and defining workflows. Pipelines contain a series of steps to achieve goals like building, testing, and deploying software.

To learn more, see the [Pipeline overview](/docs/pipelines).

## Plugin

Plugins are small, self-contained pieces of extra functionality that help you customize Buildkite to your specific workflow. They modify command steps using hooks to perform actions like checking code quality, deploying to cloud services, or sending notifications.

Plugins can be open source and available for anyone to use or private for just your organization.

To learn more, see [Plugins](/docs/pipelines/integrations/plugins).

## Quarantine

Quarantine is a classification applied to a [test](#test) that, based on the [state of the test](#test-state), changes how that test is [executed](#execution) as part of a [run](#run). When a test is quarantined, and its test state is flagged as:

- **muted**, the test is [executed](#execution) as part of the [run](#run), but its failure does not cause the pipeline build to fail, allowing the test's metadata to still be collected.

- **skipped**, the test is not [executed](#execution) as part of the [run](#run), which can allow pipeline builds to execute more rapidly and can reduce costs, but no data is recorded from the test.

Learn more about quarantining tests in [Test state and quarantine](/docs/pipelines/configure/tests/test-suites/test-state-and-quarantine).

## Queue

A queue defines agents on which pipeline builds can run their jobs. Queues are configured within a [cluster](#cluster), where each queue defines a particular group of agents, isolating a set of your pipeline's jobs and the agents they run on. Typical uses for queues include separating deployment agents and pools of agents for specific pipelines or teams.

To learn more, see the [Queues overview](/docs/agent/queues) and [Manage queues](/docs/agent/queues/managing) pages.

## Recover

Recover, along with [alarm](#alarm), is one of the two types of events that a workflow [monitor](#monitor) can alert on. Recover events are [hysteric](https://en.wikipedia.org/wiki/Hysteresis), meaning that the recover event can only be reported on a test that has a previous alarm event. In such a situation, when the monitor detects that the test has met the recover conditions, a recover event is reported. Depending on the monitor type, these recover conditions can be configurable.

Recover [actions](#action) are performed when the recover event is reported by the monitor. Repeated occurrences of the test meeting the recover conditions do not retrigger recover actions.

## Run

A run is the [execution](#execution) of one or more tests in a [test suite](#test-suite). A _run_ is sometimes referred to as a _test run_, bearing in mind that a single test run usually involves the [execution](#execution) of multiple [tests](#test). A test suite _run_ is analogous to a pipeline [_build_](#build).

## Scope

A scope is a mechanism that can be implemented to differentiate between two or more identically named tests. For example, the following hypothetical tests have the same name as they both test the process of a user logging into a product platform. However, one of these applies to this test being done on a mobile device, while the other applies to a desktop web setting. Therefore, a scope can be used to differentiate between these two tests.

| Name | Scope | Description |
| ----- | ---- | ----------- |
| User logs into platform | Mobile | A mobile user logs into the platform |
| User logs into platform | Web | A web user logs into the platform |

A test's scope is used in determining a [managed test](#managed-test)'s uniqueness.

## Step

A step describes a single, self-contained task as part of a pipeline. You define a step in the pipeline configuration using one of the following [step types](/docs/pipelines/configure/step-types):

- Command step: Runs one or more shell commands on one or more agents.
- Wait step: Pauses a build until all previous jobs have completed.
- Block step: Pauses a build until it's manually unblocked.
- Input step: Pauses a build until information has been collected from a user.
- Trigger step: Creates a build on another pipeline.
- Group step: Displays a group of sub-steps as one parent step.

A step can be in one of the following internal _states_, which the [Buildkite agent can retrieve](/docs/agent/cli/reference/step#getting-a-step), when the step is ready to run, or is currently running:

- `ignored`: The step is ignored due to a conditional evaluation.
- `waiting_for_dependencies`: The step is waiting for its dependencies to complete.
- `ready`: The step is ready to run but hasn't started yet.
- `running`: The step is currently running.
- `failing`: The step is in the process of failing.
- `finished`: The step has completed execution—usually follows either the `running` or `failing` state.
- `canceled`: The step has been canceled—follows the `waiting_for_dependencies`, `ready`, `running`, or `failing` state.

Once a step's run has completed with a state of `finished`, the [step's outcome](/docs/agent/cli/reference/step#getting-the-outcome-of-a-step) can be one of the following states:

- `neutral`: The passing or failure of the step's outcome is not relevant (for example, the outcome of a wait step).
- `passed`: The step's outcome is considered successful.
- `soft_failed`: The step's outcome is considered successful, but with a warning.
- `hard_failed`: The step's outcome is considered failed.
- `errored`: The step's outcome is considered failed because something happened to abort the step early.

A block or input step tracks the state of the build and its steps that ran before it, which can be `failed`, `passed`, or `running`.

To learn more, see [Defining steps](/docs/pipelines/configure/defining-steps).

## Tag

A tag is a `key:value` pair containing two parts:

- The tag's `key` is the identifier, which can only exist once on each test, and is case sensitive.
- The tag's `value` is the specific data or information associated with the `key`.

Within [test suites](/docs/pipelines/configure/tests), tags add [dimensions](#dimensions) to test execution metadata, so that [tests](#test) and their [executions](#execution) can be better filtered, aggregated, and compared in test suite visualizations.

Tagging can be used to observe aggregated data points—for example, to observe aggregated performance across several tests, and (optionally) narrow the dataset further based on specific constraints.

Learn more about tags in the [Tags](/docs/pipelines/configure/tests/test-suites/tags) topic.

## Test

A test is an individual piece of code that runs as part of an application's or component's (for example, a library's) building process (which can be automated by [Pipelines](/docs/pipelines)), to ensure that a specific area of the application or component functions as expected.

## Test collection

Test collection is the process of collecting test data from a development project. Test collection may consist of one or more [test collectors](#test-collector) configured within a development project, or make use other methods based on common standards such as JUnit XML or JSON to collect tests.

While a development project's [test runners](#test-runner) (such RSpec or Jest) are typically configured with their respective test collectors, the JUnit XML or JSON test collection mechanisms can be used to collect test data from multiple test runners.

## Test collector

A test collector is a dedicated open source source library (developed by Buildkite) that can be implemented into your development project, to collect test data from a [test runner](#test-runner) within your project.

Buildkite offers [a number of test collectors](/docs/pipelines/configure/tests/test-collection) for a range of languages and their test runners.

## Test runner

A test runner is a synonymous term used for a _test framework_, which is typically a code library that can be integrated into a development project to facilitate the implementation of [tests](#test) for that project.

## Test state

A test state is a configurable flag that can be applied to a [test](#test) (typically [flaky tests](#flaky-test)), which [quarantines](#quarantine) the test and affects how the test is [executed](#execution) as part of a [run](#run).

The supported test state flags are:

- **enabled**: the test is in a trusted state and runs normally.
- **muted**: the test is quarantined—see [Quarantine](#quarantine) for the resulting run behavior.
- **skipped**: the test is quarantined—see [Quarantine](#quarantine) for the resulting run behavior.

Learn more about test states in [Test state and quarantine](/docs/pipelines/configure/tests/test-suites/test-state-and-quarantine).

## Test suite

A test suite is a collection of [tests](#test), managed within Buildkite Pipelines through its [test suites](/docs/pipelines/configure/tests) features (Test Engine). A _test suite_ is sometimes abbreviated to _suite_.

In a development project configured with of one or more [test runners](#test-runner), it is usually typical to configure a separate test suite each of the project's test runners.

## Workflow

A workflow defines a process that's composed of a single [monitor](#monitor) and any number of [actions](#action). A workflow enables a user to define a custom identification and management system for tests of interest in their suite. Flaky test management is a common use case for workflows.

Learn more about workflows in the [Workflows overview](/docs/pipelines/configure/tests/workflows).
