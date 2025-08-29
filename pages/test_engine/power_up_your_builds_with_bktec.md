# Power up builds with the Test Engine Client

The Buildkite Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) is a powerful tool that leverages your Test Engine test suite data to make your Buildkite pipelines run faster and be more reliable.

## Speed up build times with test splitting

Intelligently partition your pipeline with bktec to substantially reduce build times on your critical path to delivery. bktec split tests automatically based on your historical timing data, and maintains peak speed through continuous optimization and automated re-balancing.

The following image from Test Engine's test splitting setup page illustrates how this feature works.

<%= image "setup-page-summary.png", alt: "The test splitting setup page in Test Engine" %>

In this example, _without_ bktec, the test suite build time would take as long as it takes for the slowest combination of tests to run on a single partition (Buildkite job), which is 10 minutes.

Since the sum of all test executions across all agents is 16 minutes, _with_ test splitting implemented, all four partitions would take approximately 4 minutes to run, such that the overall test suite build time would be approximately 4 minutes, or a 6-minute reduction.

## Increase build reliability with test states

bktec uses test state data from Test Engine suite to _mute_ or _skip_ problematic tests, so that flaky tests don't affect the result of your build. This reduces build times by ensuring passing builds, first time, without having to retry jobs with failing tests.

A test marked _skip_ within Test Engine won't be executed as part of your test run.

A test marked with _mute_ within Test Engine will still be executed, but the result of the test will be ignored.

Buildkite recommends muting tests rather than skipping them, as a muted test will still report its result to Test Engine, so if the test's reliability improves over time, it can be re-enabled.

## Learn more

bktec supports Cypress, Jest, PlayWright, Pytest and RSpec. Test splitting is available to all Pro and Enterprise customers, and test state is available for all Enterprise customers. If you are on a legacy plan please contact sales@buildkite.com to gain access these feature and try it out.

Install and configure bktec in [configuring test splitting](/docs/test-engine/test-splitting/configuring).
