# Test state and quarantine

Test Engine's **Test state** management feature provides the [test state](/docs/pipelines/glossary#test-state) flags of **enabled**, **muted** and **skipped**.

[_Quarantine_](/docs/pipelines/glossary#quarantine) refers to the action of moving a test from a trusted state (**enabled**) to one of the untrusted states (**muted** or **skipped**). Tests can be quarantined [automatically](#automatic-quarantine) or [manually](#manual-quarantine).

Quarantining [flaky tests](/docs/pipelines/configure/tests/flaky-tests) and then using [bktec](/docs/pipelines/speed-up-builds-with-bktec#increase-build-reliability-with-test-states) on pipeline's builds allows the pipeline to be built more rapidly, and run with a higher success rate.

> 📘 Pro and Enterprise plan features
> Test state management is available on the [Pro and Enterprise](https://buildkite.com/pricing) plans. Configuring automatic quarantine using a **Change state** workflow action requires an Enterprise plan. See [Plan availability and limits](/docs/pipelines/configure/tests/workflows#plan-availability-and-limits) for details.

## Lifecycle states

Users with the [**Full Access** permission to a test suite](/docs/pipelines/security/permissions#manage-teams-and-permissions-test-suite-level-permissions) can enable a **Test state** in a test suite's **Settings**, by selecting the appropriate test states that quarantining can be based upon.

<%= image "lifecycle-management.png", alt: "The UI for test state lifecycle management" %>

> 🚧 Disabling test state management resets test states
> Disabling test state management permanently resets all muted and skipped tests in the suite to enabled. Re-enabling test state management does not restore their previous states.

### Mute (recommended)

Prefer muting over skipping. Muted tests continue running, but their failures do not affect the build result. Test Engine continues collecting execution data from muted tests, so it can detect when they become reliable.

### Skip

Use skipping only when a test must not run. Skipped tests do not produce execution data, so Test Engine cannot detect when they become reliable. If you skip [flaky tests](/docs/pipelines/configure/tests/flaky-tests), use a scheduled pipeline to run them and collect their results.

## Automatic quarantine

On an Enterprise plan, you can automatically quarantine tests using the [**Change state** action](/docs/pipelines/configure/tests/workflows/actions#change-state) in a [workflow](/docs/pipelines/configure/tests/workflows). Set the alarm action to **muted** or **skipped**, and the recover action to **enabled**. Test state management must be enabled for the suite, with the requested states allowed.

The current Pro plan includes test state management but does not allow you to configure **Change state** workflow actions. You can still [quarantine tests manually](#manual-quarantine) or change their state using the [Test Engine REST API](/docs/apis/rest-api/test-engine/quarantine#update-test-state).

<%= image "automatic-quarantine.png", width: 1364/2, height: 318/2, alt: "Screenshot showing Slack workflow action configuration", align: :center %>

Using [labelling](/docs/pipelines/configure/tests/test-suites/labels) on a test when it is quarantined and removing the label when the test is released from quarantine is also recommended. Learn more about automatic labelling in [workflow label actions](/docs/pipelines/configure/tests/workflows/actions#add-or-remove-label).

## Manual quarantine

You can manually quarantine flaky tests using the dropdown menu within the test's page itself or the test digest. This helps unblock builds affected by unreliable tests in real time.

<%= image "manual-quarantine.png", alt: "Manually quarantine individual tests using the dropdown." %>

Manually quarantining a test either mutes or skips that test when the pipeline is built on any branch.

## Configuring builds with quarantine

### bktec

The easiest way to apply test states in your builds is to run the [Buildkite Test Engine Client (bktec)](https://github.com/buildkite/test-engine-client) command in your pipelines. Depending on the state, bktec prevents a quarantined test failure from failing the build or excludes the test from the run.

Support for muting and skipping varies by test framework. Check the [supported runners and features](https://github.com/buildkite/test-engine-client#supported-runners-and-features) table for your framework's current support.

When using a supported test framework, bktec automatically handles quarantined tests, along with providing the benefits of efficient [test splitting](/docs/pipelines/speed-up-builds-with-bktec) and retry support.

```yaml
- name: "Run tests, excluding quarantined ones, with bktec"
  command: bktec
  parallelism: 10
  env:
    BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec # see supported runners in the bktec README
```

### REST API

If you are not using bktec, you can [query the REST API's `tests` endpoint](/docs/apis/rest-api/test-engine/quarantine) for your test suite to retrieve a list of tests that are currently skipped or muted and configure your build scripts accordingly.
