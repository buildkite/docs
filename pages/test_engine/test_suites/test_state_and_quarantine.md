# Test state and quarantine

Customers on the [Enterprise plan](https://buildkite.com/pricing) can access Buildkite Test Engine's _test state management_ feature. Contact Buildkite sales at sales@buildkite.com to gain access this feature and try it out.

The quarantine aspect of this feature allows you to [automatically](#automatic-quarantine) or [manually](#manual-quarantine) assign a state to a [flaky test](/docs/test-engine/test-suites/flaky-test-management#detecting-flaky-tests) of a pipeline, so that when the pipeline is being built, any failures in these flaky tests will be ignored, or the flaky tests will be skipped completely.

Quarantining the flaky tests of a pipeline's builds allows the pipeline to be built more rapidly, and with a higher success rate.

## Lifecycle states

Users with the [**Full Access** permission to a test suite](/docs/test-engine/permissions#manage-teams-and-permissions-test-suite-level-permissions) can enable a _test state_ in a test suite's **Settings**, by selecting the appropriate test states that quarantining can be based upon.

<%= image "lifecycle-management.png", alt: "The UI for test state lifecycle management" %>

### Mute (recommended)

Muted tests will still execute as jobs in your pipeline builds, but any failed results of these test jobs are handled as a _soft fail_. A soft fail result does not affect the result of your pipeline build, and allows the pipeline build to pass. However, metadata about the test is still collected by Test Engine.

### Skip

Skipped tests are not run during your pipeline builds. Since these tests are not executed, no data is recorded from them by Test Engine. To collect metadata about your [flaky tests](/docs/test-engine/test-suites/flaky-test-management#detecting-flaky-tests), it is recommended that you only use the **Skip** option when you have a scheduled pipeline that is running skipped tests.

## Automatic quarantine

Users can enable automatic quarantine from the test suite's **Settings** > **Test state** page > **Automatically quarantine tests** section, and define rules for quarantining tests at build time.

<%= image "quarantine-test-configuration.png", alt: "The form with rules to apply or remove quarantine to failing tests." %>

Automatic quarantining tests only either mutes or skips [flaky tests](/docs/test-engine/test-suites/flaky-test-management#detecting-flaky-tests) when the pipeline is built on the test suite's **Default branch**, as well as the merge queue branch.

Along with changing the test state, the automatic quarantine feature can apply a label to a test when the test is quarantined and remove the label when the test is released from quarantine. Learn more about labeling in [Labels](/docs/test-engine/test-suites/labels).

## Manual quarantine

Users can manually quarantine flaky tests via the dropdown menu within the test's page itself or the test digest. This helps unblock builds affected by unreliable tests in real time.

<%= image "manual-quarantine.png", alt: "Manually quarantine individual tests via the dropdown." %>

Manually quarantining a test either mutes or skips that test when the pipeline is built on any branch.

## Configuring builds with quarantine

### bktec

The easiest way to respect test states in your builds is to run the [Buildkite Test Engine Client (bktec)](https://github.com/buildkite/test-engine-client) command in your pipelines. The `bktec` command automatically excludes quarantined tests from your test runs, preventing [flaky tests](/docs/test-engine/test-suites/flaky-test-management#detecting-flaky-tests) from causing build failures, leading to faster, more reliable builds, and less need for retries.

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
