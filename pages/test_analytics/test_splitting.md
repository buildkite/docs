# Configuring test splitting

Test splitting is the process of partitioning a test suite to run in parallel across multiple Buildkite agents. Buildkite maintains its open source Test Splitter ([test-splitter](https://github.com/buildkite/test-splitter)) tool. This tool uses your Buildkite Test Analytics test suite data to intelligently partition tests throughout your test suite into multiple sets, such that each set of tests runs in parallel across your agents. This process is known as _orchestration_ and results in a _test plan_, where a test plan defines which tests are run on which agents. Currently, test-splitter only supports RSpec.

## Dependencies

Test splitting relies on execution timing data captured by the Buildkite test collectors to partition your tests evenly across your agents. Therefore, you will need to configure the [Ruby test collector](./ruby-collectors) for your test suite.

## Installation

The [latest version of test-splitter](https://github.com/buildkite/test-splitter/releases) can be downloaded from GitHub for installation to your agent/s. Binaries are available for both Mac and Linux with 64-bit ARM and AMD architectures. Download the executable and make it available in your testing environment.

## Using the test splitter

Once you have downloaded the test-splitter binary and it's executable in your Buildkite pipeline, you'll need to configure some additional environment variables for the test splitter to function. You can then update your pipeline step to call test-splitter instead of calling RSpec to run your tests.

### Configure environment variables

The following Buildkite-provided environment variables are used by the test-splitter. By default, these are available to your testing environment and do not need any further configuration. If, however, you use Docker or some other type of containerization tool to run your tests, you may need to expose these environment variables to your containers.

| Environment Variable | Description|
| -------------------- | ----------- |
| `BUILDKITE_BUILD_ID` | The UUID of the pipeline build. Test Splitter uses this UUID along with `BUILDKITE_STEP_ID` to uniquely identify the test plan. |
| `BUILDKITE_JOB_ID` | The UUID of the job in the pipeline's build. |
| `BUILDKITE_ORGANIZATION_SLUG` | The slug of your Buildkite organization. |
| `BUILDKITE_PARALLEL_JOB` | The index number of a parallel job created from a parallel build step.<br/>Ensure you configure `parallelism` in your pipeline definition. Learn more about parallel build steps in [Concurrency and parallelism](https://buildkite.com/docs/pipelines/controlling-concurrency#concurrency-and-parallelism). |
| `BUILDKITE_PARALLEL_JOB_COUNT` | The total number of parallel jobs created from a parallel build step.<br/>Ensure you configure `parallelism` in your pipeline definition. Learn more about parallel build steps in [Concurrency and parallelism](https://buildkite.com/docs/pipelines/controlling-concurrency#concurrency-and-parallelism). |
| `BUILDKITE_STEP_ID` | The UUID of the step group in the pipeline build. Test Splitter uses this UUID along with `BUILDKITE_BUILD_ID` to uniquely identify the test plan.

#### Mandatory environment variables

The following environment variables must be set.

| Environment Variable | Description |
| -------------------- | ----------- |
| `BUILDKITE_SPLITTER_API_ACCESS_TOKEN ` | Buildkite API access token with `read_suites`, `read_test_plan`, and `write_test_plan` scopes. You can create an [API access token](https://buildkite.com/user/api-access-tokens) from **Personal Settings** > **API Access Tokens** in the Buildkite interface. |
| `BUILDKITE_SPLITTER_SUITE_SLUG` | The slug of your Buildkite Test Analytics test suite. You can find the suite slug in the url for your test suite. For example, the slug for the url: `https://buildkite.com/organizations/my-organization/analytics/suites/my-suite` is `my-suite` |

#### Optional environment variables

The following environment variables can optionally be used to configure the Test Splitter.

| Environment Variable | Default Value | Description |
| ---- | ---- | ----------- |
| `BUILDKITE_SPLITTER_DEBUG_ENABLED` | `false` | A flag to enable more verbose logging. |
| `BUILDKITE_SPLITTER_RETRY_COUNT` | `0` | The number of retries permitted. Test Splitter runs the test command defined in `BUILDKITE_SPLITTER_TEST_CMD`, and retries only the failing tests for a maximum of `BUILDKITE_SPLITTER_RETRY_COUNT` times. For RSpec, the Test Splitter runs `BUILDKITE_SPLITTER_TEST_CMD` with `--only-failures` as the retry command. |
| `BUILDKITE_SPLITTER_SPLIT_BY_EXAMPLE` | `false` | A flag to enable split by example. When this option is `true`, the Test Splitter will split the execution of slow test files over multiple partitions. |
| `BUILDKITE_SPLITTER_TEST_CMD` | `bundle exec rspec {{testExamples}}` | The test command to run your tests. The Test Splitter will replace and populate the `{{testExamples}}` placeholder with the test plan. |
| `BUILDKITE_SPLITTER_TEST_FILE_EXCLUDE_PATTERN` | - | The glob pattern to exclude certain test files or directories. The exclusion will be applied after discovering the test files using a pattern configured with `BUILDKITE_SPLITTER_TEST_FILE_PATTERN`.<br/>_This option accepts the pattern syntax supported by the [zzglob](https://github.com/DrJosh9000/zzglob?tab=readme-ov-file#pattern-syntax) library._ |
| `BUILDKITE_SPLITTER_TEST_FILE_PATTERN` | `spec/**/*_spec.rb` | The glob pattern to discover test files. You can exclude certain test files or directories from the discovered test files using a pattern that can be configured with `BUILDKITE_SPLITTER_TEST_FILE_EXCLUDE_PATTERN`.<br/>_This option accepts the pattern syntax supported by the [zzglob](https://github.com/DrJosh9000/zzglob?tab=readme-ov-file#pattern-syntax) library._ |


### Update the pipeline step

With the environment variables configured, you can now update your pipeline step to use test-splitter instead of running RSpec. The following example pipeline step demonstrates how to partition your test suite across 10 nodes.

```
steps:
  - name: "RSpec"
    command: ./test-splitter
    parallelism: 10
    env:
      BUILDKITE_SPLITTER_SUITE_SLUG: my-suite
      BUILDKITE_SPLITTER_API_ACCESS_TOKEN: your-secret-token
```
{: codeblock-file="pipeline.yml"}
