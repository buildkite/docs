# Automatic quarantine

Customers on the [Enterprise plan](https://buildkite.com/pricing) have access to the quarantine feature. [Contact our Sales department](mailto:sales@buildkite.com) to try it out.

## Automatic quarantine
Suite admins can enable automatic quarantine in suite settings, where they can manage available lifecycle events
<%= image "lifecycle-management.png", alt: "The UI for test state lifecycle management" %>
and define rules for automatically quarantining tests at runtime.
<%= image "quarantine-instructions.png", alt: "The form with rules to apply or remove quarantine to failing tests." %>
The easiest way to respect test states in your builds is by using the [Buildkite Test Engine Client (bktec)](https://github.com/buildkite/test-engine-client). bktec can automatically exclude quarantined tests from affecting test run results, preventing them from causing build failures. This leads to faster, more reliable builds with fewer retries.

If you're using a supported test framework, bktec handles quarantined tests automatically—along with benefits like efficient test splitting and retry support.

```yaml
- name: "Run tests, excluding quarantined ones, with bktec"
  command: bktec
  parallelism: 10
  env:
    BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec|jest|cypress|playwright
```

## Manual quarantine
Users can manually quarantine flaky tests via the dropdown menu in the Test show page or the test digest. This helps unblock builds affected by unreliable tests in real time.
<%= image "manual-quarantine.png", alt: "Manually quarantine individual tests via the dropdown." %>

