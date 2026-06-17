---
description: "Definitions of key Buildkite Pipelines terms, including agents, builds, jobs, pipelines, queues, steps, and Test Engine concepts such as test suites, runs, and flaky tests."
---

# Pipelines glossary

This glossary defines the key terms and concepts used across Buildkite Pipelines, including the [test suites](/docs/pipelines/configure/tests) features (Test Engine). Terms are listed alphabetically. Each entry gives a short, self-contained definition, followed by links to more detailed documentation.

## Action

An action is part of a [workflow](#workflow) and provides a user-defined operation that is triggered automatically when a workflow [monitor](#monitor) enters the [alarm](#alarm) or [recover](#recover) event state for a [test](#test). Actions can apply to the test itself (for example, changing its [state](#test-state) or [label](/docs/pipelines/configure/tests/test-suites/labels)), or to an external system (for example, sending a Slack notification about the test).

Learn more about actions in [Alarm and recover actions](/docs/pipelines/configure/tests/workflows/actions).

## Agent

An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines. You need at least one agent to run builds.

To learn more, see the [Agent overview](/docs/agent).

## Agent targeting

Agent targeting is how a [step](#step) selects which [agents](#agent) can run its [jobs](#job). A step declares its requirements using the `agents` attribute, which holds one or more `key=value` tags (for example, `queue=ios` or `os=linux`). An agent only accepts a job when its own tags satisfy the step's `agents` query. The most common targeting tag is `queue`, which routes a job to a [queue](#queue).

To learn more, see [Defining steps](/docs/pipelines/configure/defining-steps) and the [Queues overview](/docs/agent/queues).

## Alarm

An alarm is one of the two types of events that a workflow [monitor](#monitor) can alert on, the other being [recover](#recover). Alarm events are reported by the monitor when the alarm conditions are met. Depending on the monitor type, these alarm conditions are configurable.

Alarm [actions](#action) are performed when the alarm event is reported by the monitor. Repeated occurrences of the test meeting the alarm conditions do not retrigger alarm actions.

## Annotation

An annotation is rich content (Markdown, with optional HTML, images, and styling) that a [step](#step) attaches to a [build](#build) to add context beyond the raw job log. Common uses include test failure summaries, deployment links, and custom buttons. Annotations are created with the `buildkite-agent annotate` command and appear on the build page.

To learn more, see [Annotations](/docs/pipelines/configure/annotations).

## Artifact

An artifact is a file generated during a build. You can keep artifacts in a Buildkite-managed storage service or a third-party cloud storage service like Amazon S3, Google Cloud Storage, or Artifactory. Common uses include storing assets like logs and reports, or passing files between steps.

To learn more, see [Build artifacts](/docs/pipelines/configure/artifacts).

## Block step

A block step pauses a [build](#build) until it is manually unblocked, either in the Buildkite interface or through the API. Block steps are often used as a manual approval gate before a sensitive step, such as a production deployment.

To learn more, see [Block step](/docs/pipelines/configure/step-types/block-step).

## Build

A build is a single run of a pipeline. You can trigger a build in various ways, including through the dashboard, API, as the result of a webhook, on a schedule, or even from another pipeline using a [trigger step](#trigger-step).

## Build matrix

A build matrix expands a single command step into multiple [jobs](#job), one for each combination of values across one or more dimensions (for example, operating system and language version). It is a concise way to run the same command across many configurations without defining each [step](#step) by hand.

To learn more, see [Build matrix](/docs/pipelines/configure/workflows/build-matrix).

## Build metadata

Build metadata is a set of `key/value` string pairs attached to a [build](#build) that any [job](#job) in that build can read or write using the `buildkite-agent meta-data` command. It is the standard way to pass small pieces of state, such as a commit reference or an approval decision, between steps in the same build. For larger files, use [artifacts](#artifact) instead.

To learn more, see [Build meta-data](/docs/pipelines/configure/build-meta-data).

## Buildkite organization administrator

A Buildkite organization administrator is a user with full administrative control over a Buildkite organization. Organization administrators can manage teams, configure organization-level settings, control pipeline and security permissions, and access usage reports and [audit logs](/docs/platform/audit-log).

To learn more, see [User and team permissions](/docs/platform/team-management/permissions).

## Cluster

A cluster groups [queues](#queue) of agents along with pipelines. Clusters allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

To learn more, see the [Clusters overview](/docs/pipelines/security/clusters).

## Concurrency group

A concurrency group is a named limit, configured on a [step](#step), that controls how many [jobs](#job) sharing the same group key can run at once across [builds](#build) and pipelines. Concurrency groups are commonly used to serialize access to a shared resource, such as a deployment target, without an external lock.

To learn more, see [Controlling concurrency](/docs/pipelines/configure/workflows/controlling-concurrency).

## Dimensions

In the context of [test suites](/docs/pipelines/configure/tests), dimensions are structured data, consisting of [tags](#tag), which can be used to filter or group (that is, aggregate) test [executions](#execution). Dimensions are added to test executions using the tags feature, which you can learn more about in [Tags](/docs/pipelines/configure/tests/test-suites/tags).

## Dynamic pipeline

Dynamic pipelines define their steps at runtime using scripts, giving you the flexibility to only run the steps relevant to particular code changes and workflows.

Dynamic pipelines are helpful when you have a complex build process that requires different steps to execute based on runtime conditions, such as the branch, the environment, or the results of previous steps. A dynamic pipeline generates its steps using a [pipeline upload](#pipeline-upload), where a [job](#job) runs `buildkite-agent pipeline upload` to add steps to the current build.

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

A flaky test is a [test](#test) that produces inconsistent or unreliable results, despite being run in the same code and environment. Flaky tests are identified using [workflows](/docs/pipelines/configure/tests/workflows).

Learn more about flaky tests in [Reduce flaky tests](/docs/pipelines/reduce-flaky-tests).

## Hook

A hook is a method of customizing the behavior of Buildkite through lifecycle events. They let you run scripts at different points of the agent or job lifecycle. Using hooks, you can extend the functionality of Buildkite and automate tasks specific to your workflow and requirements.

Hooks run at named points in the agent or job lifecycle, such as `environment`, `checkout`, `pre-command`, `command`, `post-command`, and `pre-exit`. The `pre-exit` hook runs after the command, before the agent reports the job result, and is commonly used for cleanup tasks.

To learn more, see [Hooks](/docs/agent/hooks).

## Hosted agent

A hosted agent is a Buildkite [agent](#agent) that runs on infrastructure managed by Buildkite, so you do not provision, scale, or maintain the machine yourself. Hosted agents are configured per [queue](#queue) and are available with Linux and macOS images. A [self-hosted agent](/docs/agent/self-hosted), by contrast, runs on infrastructure you control.

To learn more, see the [Buildkite hosted agents overview](/docs/agent/buildkite-hosted).

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

## Merge queue

Merge queue support is the integration between Buildkite Pipelines and a source control provider merge queue, such as the GitHub merge queue. When enabled, Buildkite triggers a [build](#build) for each commit the merge queue proposes, so that changes are tested together in their intended merge order before they land.

To learn more, see [Set up a GitHub merge queue](/docs/pipelines/tutorials/github-merge-queue).

## Monitor

A monitor is a part of a [workflow](#workflow) and is used to observe [tests](#test) over time. Monitors help to surface valuable qualitative information about the tests in your [test suite](#test-suite), which can be difficult to surmise from raw execution data. Monitors can report on special events (for example, a passed on retry event) or produce scores (such as, transition count score).

A single monitor watches over all the tests in your test suite (apart from those excluded by filters) and generates individual [alarm](#alarm) and [recover](#recover) events for each test, which then trigger the associated alarm and recover [action](#action).

Learn more about the different monitors types in [Monitors](/docs/pipelines/configure/tests/workflows/monitors).

## Notification

A notification is an outbound message that Buildkite Pipelines sends when a [build](#build) event occurs, such as a build starting, passing, or failing. Notifications are configured in the pipeline with the `notify` attribute, or through integrations, and can be delivered to channels such as email, Slack, and webhooks.

To learn more, see [Triggering notifications](/docs/pipelines/configure/notify).

## OIDC

OpenID Connect (OIDC) lets a [job](#job) authenticate to an external service, such as a cloud provider, without storing long-lived secrets. A job requests a short-lived OIDC token with the `buildkite-agent oidc request-token` command and exchanges it for provider credentials. The token's claims, such as the organization, pipeline, and branch, let the provider apply fine-grained trust policies.

To learn more, see [OpenID Connect (OIDC) in Buildkite Pipelines](/docs/pipelines/security/oidc).

## Parallelism

Parallelism runs the same command step across a number of [jobs](#job) at the same time. Set the `parallelism` attribute on a [step](#step) to the number of parallel jobs you want. Combined with test splitting, parallelism shards a long test suite across many [agents](#agent).

To learn more, see [Parallelizing builds](/docs/pipelines/best-practices/parallel-builds).

## Pipeline

A pipeline is a container for modeling and defining workflows. Pipelines contain a series of steps to achieve goals like building, testing, and deploying software.

To learn more, see the [Pipeline overview](/docs/pipelines).

## Pipeline schedule

A pipeline schedule creates a [build](#build) automatically at a recurring time, defined using cron syntax. A schedule can set the branch, commit, message, and environment used for the builds it creates.

To learn more, see [Scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds).

## Pipeline template

A pipeline template is a reusable [pipeline](#pipeline) configuration, managed at the Buildkite organization level, that multiple pipelines can be created from. Templates let platform teams provide a consistent, governed starting point so that pipeline owners do not each maintain their own copy.

To learn more, see [Pipeline templates](/docs/pipelines/governance/templates).

## Pipeline upload

A pipeline upload is the action a running [job](#job) takes when it adds steps to the current [build](#build) using the `buildkite-agent pipeline upload` command. Uploaded steps can be appended, or used to replace steps that have not yet started. Pipeline upload is the mechanism behind [dynamic pipelines](#dynamic-pipeline).

To learn more, see the [`buildkite-agent pipeline` command reference](/docs/agent/cli/reference/pipeline).

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

A recover is one of the two types of events that a workflow [monitor](#monitor) can alert on, the other being [alarm](#alarm). Recover events are [hysteric](https://en.wikipedia.org/wiki/Hysteresis), meaning that the recover event can only be reported on a test that has a previous alarm event. In such a situation, when the monitor detects that the test has met the recover conditions, a recover event is reported. Depending on the monitor type, these recover conditions can be configurable.

Recover [actions](#action) are performed when the recover event is reported by the monitor. Repeated occurrences of the test meeting the recover conditions do not retrigger recover actions.

## Retry

A retry re-runs a failed [job](#job). Buildkite Pipelines supports automatic retries, configured with the `retry` attribute on a [step](#step) (for example, by exit status or when an agent is lost), and manual retries triggered by a user in the Buildkite interface or through the API.

To learn more, see [Retrying jobs](/docs/pipelines/configure/retry).

## Run

A run is the [execution](#execution) of one or more tests in a [test suite](#test-suite). A _run_ is sometimes referred to as a _test run_, bearing in mind that a single test run usually involves the [execution](#execution) of multiple [tests](#test). A test suite _run_ is analogous to a pipeline [_build_](#build).

## Scope

A scope is a mechanism that can be implemented to differentiate between two or more identically named tests. For example, the following hypothetical tests have the same name as they both test the process of a user logging into a product platform. However, one of these applies to this test being done on a mobile device, while the other applies to a desktop web setting. Therefore, a scope can be used to differentiate between these two tests.

| Name | Scope | Description |
| ----- | ---- | ----------- |
| User logs into platform | Mobile | A mobile user logs into the platform |
| User logs into platform | Web | A web user logs into the platform |

A test's scope is used in determining a [managed test](#managed-test)'s uniqueness.

## Signed pipelines

Signed pipelines cryptographically sign step definitions so that an [agent](#agent) only runs steps signed by a trusted key. This reduces the risk of unauthorized steps being added to a privileged [build](#build) through a [pipeline upload](#pipeline-upload).

To learn more, see [Signed pipelines](/docs/agent/self-hosted/security/signed-pipelines).

## Skip and cancel intermediate builds

Skip and cancel intermediate builds are pipeline settings that avoid running superseded [builds](#build) when several commits arrive on the same branch in quick succession. Skipping prevents a queued intermediate build from starting, while canceling stops a running intermediate build, so that only the latest commit is built.

To learn more, see [Skip queued intermediate builds](/docs/pipelines/configure/skipping#skip-queued-intermediate-builds) and [Cancel running intermediate builds](/docs/pipelines/configure/canceling-builds#cancel-running-intermediate-builds).

## Soft fail

A soft fail is a [step](#step) outcome that reports failure without failing the [build](#build). Set the `soft_fail` attribute on a step to `true`, or to a list of exit statuses, so that a failing step is surfaced for visibility but does not block downstream steps. This differs from a hard failure, which fails the build. The corresponding step outcome is `soft_failed`, described in [Step](#step).

To learn more, see [Soft failing a step](/docs/pipelines/configure/soft-fail).

## Step

A step describes a single, self-contained task as part of a pipeline. You define a step in the pipeline configuration using one of the following [step types](/docs/pipelines/configure/step-types):

- Command step: Runs one or more shell commands on one or more agents.
- Wait step: Pauses a build until all previous jobs have completed.
- [Block step](#block-step): Pauses a build until it's manually unblocked.
- Input step: Pauses a build until information has been collected from a user.
- [Trigger step](#trigger-step): Creates a build on another pipeline.
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
- `soft_failed`: The step's outcome is considered successful, but with a warning. See [Soft fail](#soft-fail).
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

Test collection is the process of collecting test data from a development project. Test collection may consist of one or more [test collectors](#test-collector) configured within a development project, or make use of other methods based on common standards such as JUnit XML or JSON to collect tests.

While a development project's [test runners](#test-runner) (such as RSpec or Jest) are typically configured with their respective test collectors, the JUnit XML or JSON test collection mechanisms can be used to collect test data from multiple test runners.

## Test collector

A test collector is a dedicated open source library (developed by Buildkite) that can be implemented into your development project, to collect test data from a [test runner](#test-runner) within your project.

Buildkite offers [a number of test collectors](/docs/pipelines/configure/tests/test-collection) for a range of languages and their test runners.

## Test Engine Client (bktec)

The Test Engine Client (`bktec`) is a command-line tool that splits a [test suite](#test-suite) across parallel [jobs](#job) using historical timing data so that each job runs a similar share of the total test time. It is part of the Buildkite Pipelines [test suites](/docs/pipelines/configure/tests) feature.

To learn more, see [Speed up builds with bktec](/docs/pipelines/speed-up-builds-with-bktec).

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

In a development project configured with one or more [test runners](#test-runner), it is typical to configure a separate test suite for each of the project's test runners.

## Trigger step

A trigger step creates a [build](#build) on another [pipeline](#pipeline) from within the current build. It can pass environment variables and [build metadata](#build-metadata) to the triggered build, which makes it the standard way to chain pipelines together, such as a build pipeline triggering a separate deployment pipeline.

To learn more, see [Trigger step](/docs/pipelines/configure/step-types/trigger-step).

## Workflow

A workflow defines a process that's composed of a single [monitor](#monitor) and any number of [actions](#action). A workflow enables a user to define a custom identification and management system for tests of interest in their suite. Flaky test management is a common use case for workflows.

Learn more about workflows in the [Workflows overview](/docs/pipelines/configure/tests/workflows).
