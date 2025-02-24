# Quarantine

Customers on the [Enterprise plan](https://buildkite.com/pricing) can access Buildkite Test Engine's quarantine feature. Contact Buildkite sales at sales@buildkite.com to gain access to this feature and try it out.

The quarantine feature allows you to [automatically](#automatic-quarantine) or [manually](#manual-quarantine) assign a state to a [flaky test](/docs/test-engine/test-suites#detecting-flaky-tests) of a pipeline, so that when the pipeline is being built, any failures in these flaky tests will be ignored, or the flaky tests will be skipped completely.

Quarantining the flaky tests of a pipeline's builds allows the pipeline to be built more rapidly, and with a higher success rate.

## Lifecycle states

Test suite administrators can enable a test state in a test suite's **Settings**, by selecting the appropriate test states that quarantining can be based upon.

<%= image "lifecycle-management.png", alt: "The UI for test state lifecycle management" %>

### Mute (recommended)

Muted tests will still run as jobs in your pipeline builds, but any failed results of these test jobs are handled as a _soft fail_. A soft fail result does not affect the result of your pipeline build, and allows the pipeline build to pass. However, metadata about the test is still collected by Test Engine.

### Skip

Skipped tests are not run during your pipeline builds. Since these tests are not run, no data is recorded from them by Test Engine. To collect metadata about your [flaky tests](/docs/test-engine/test-suites#detecting-flaky-tests), it is recommended that you only use the **Skip** option when you have a scheduled pipeline that is running skipped tests.

## Automatic quarantine

Users can enable automatic quarantine from the test suite settings, and define rules for quarantining tests at build time.

<%= image "quarantine-instructions.png", alt: "The form with rules to apply or remove quarantine to failing tests." %>

Automatic quarantining only mutes or skips flaky tests when the pipeline is built on the test suite's **Default branch**, as well as the merge queue branch.

## Manual quarantine

Users can manually quarantine flaky tests via the dropdown menu in the Test show page or the test digest. This helps unblock builds affected by unreliable tests in real time.

<%= image "manual-quarantine.png", alt: "Manually quarantine individual tests via the dropdown." %>

Manually quarantining a test, mutes or skips that test when the pipeline is built on any branch.

## Configuring builds with quarantine

### bktec

The easiest way to respect test states in your builds is by using the [Buildkite Test Engine Client (bktec)](https://github.com/buildkite/test-engine-client). bktec can automatically exclude quarantined tests from affecting test run results, preventing them from causing build failures. This leads to faster, more reliable builds with fewer retries.

If you're using a supported test framework, bktec handles quarantined tests automatically—along with benefits like efficient test splitting and retry support.

```yaml
- name: "Run tests, excluding quarantined ones, with bktec"
  command: bktec
  parallelism: 10
  env:
    BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec|jest|cypress|playwright
```

### REST API

If you are not using bktec, you can [query the REST API's `tests` endpoint](/docs/apis/rest-api/test-engine/quarantine) for your test suite to retrieve a list of tests that are currently skipped or muted and configure your build scripts accordingly.
