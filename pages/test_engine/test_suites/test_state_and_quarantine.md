# Test state and quarantine

Customers on the [Pro and Enterprise](https://buildkite.com/pricing) plan can access Buildkite Test Engine's **Test state** management feature, which provides [test state](/docs/test-engine/glossary#test-state) flags of **enabled**, **muted** and **skipped**.

[_Quarantine_](/docs/test-engine/glossary#quarantine) refers to the action of moving a test from a trusted state (**enabled**) to one of the untrusted states (**muted** or **skipped**). Tests can be quarantined [automatically](#automatic-quarantine) or [manually](#manual-quarantine).

Quarantining [flaky tests](/docs/test-engine/reduce-flaky-tests) and then using [bktec](/docs/test-engine/speed-up-builds-with-bktec#increase-build-reliability-with-test-states) on pipeline's builds allows the pipeline to be built more rapidly, and run with a higher success rate.

## Lifecycle states

Users with the [**Full Access** permission to a test suite](/docs/test-engine/permissions#manage-teams-and-permissions-test-suite-level-permissions) can enable a **Test state** in a test suite's **Settings**, by selecting the appropriate test states that quarantining can be based upon.

<%= image "lifecycle-management.png", alt: "The UI for test state lifecycle management" %>

### Mute (recommended)

Muted tests will still execute as jobs in your pipeline builds, but any failed results of these test jobs are handled as a _soft fail_. A soft fail result does not affect the result of your pipeline build, and allows the pipeline build to pass. However, metadata about the test is still collected by Test Engine.

### Skip

Skipped tests are not run during your pipeline builds. Since these tests are not executed, no data is recorded from them by Test Engine. To collect metadata about your [flaky tests](/docs/test-engine/reduce-flaky-tests), it is recommended that you only use the **Skip** option when you have a scheduled pipeline that is running skipped tests.

## Automatic quarantine

You can automatically quarantine tests using [workflows](/docs/test-engine/reduce-flaky-tests#quarantining-flaky-tests). To do this, use the [workflow change state action](/docs/test-engine/workflows/actions#change-state), to automatically transition tests into different states.

<%= image "automatic-quarantine.png", width: 1364/2, height: 318/2, alt: "Screenshot showing Slack workflow action configuration", align: :center %>

Using [labelling](/docs/test-engine/test-suites/labels) on a test when it is quarantined and removing the label when the test is released from quarantine is also recommended. Learn more about automatic labelling in [workflow label actions](/docs/test-engine/workflows/actions#add-or-remove-label).

## Manual quarantine

You can manually quarantine flaky tests via the dropdown menu within the test's page itself or the test digest. This helps unblock builds affected by unreliable tests in real time.

<%= image "manual-quarantine.png", alt: "Manually quarantine individual tests via the dropdown." %>

Manually quarantining a test either mutes or skips that test when the pipeline is built on any branch.

## Configuring builds with quarantine

### bktec

The easiest way to respect test states in your builds is to run the [Buildkite Test Engine Client (bktec)](https://github.com/buildkite/test-engine-client) command in your pipelines. The `bktec` command automatically excludes quarantined tests from your test runs, preventing [flaky tests](/docs/test-engine/reduce-flaky-tests) from causing build failures, leading to faster, more reliable builds, and less need for retries.

Currently, bktec supports the following test frameworks for:

- muting tests—RSpec, Jest, and Playwright
- skipping tests—RSpec only

When using a supported test framework, bktec automatically handles quarantined tests, along with providing the benefits of efficient [test splitting](/docs/test-engine/test-splitting) and retry support.

```yaml
- name: "Run tests, excluding quarantined ones, with bktec"
  command: bktec
  parallelism: 10
  env:
    BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec|jest|playwright
```

### REST API

If you are not using bktec, you can [query the REST API's `tests` endpoint](/docs/apis/rest-api/test-engine/quarantine) for your test suite to retrieve a list of tests that are currently skipped or muted and configure your build scripts accordingly.
