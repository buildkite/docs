# Configuring Test Splitting

Test splitting is the process of partitioning your test suite to run in parallel across multiple Buildkite agents. Buildkite maintains an open source tool called [test-splitter](https://github.com/buildkite/test-splitter) to orchestrate your test suites, using your Buildkite Test Analytics suite data to intelligently partition and parallelise your tests. Currently, the test-splitter supports RSpec with support for other frameworks coming soon.

## Dependencies

Test splitting relies on execution timing data captured by the Buildkite test collectors to partition your tests evenly, so you will need to configure the [Ruby test collector](./ruby-collectors) for your test suite.

## Installation

The latest version of test-splitter can be downloaded from [Github](https://github.com/buildkite/test-splitter/releases). Binaries are available for both Mac and Linux with 64-bit ARM and AMD architectures. Please download the executable and make it available in your testing environment.

## Using the Test Splitter

Once you have downloaded the test-splitter binary and it can be executed in your Buildkite pipeline, you will need to configure some additional environment variables for the test-splitter to function. Then, you can update your pipeline step to call the test-splitter instead of calling RSpec to run your tests.

### Configure environment variables

The following Buildkite-provided environment variables are used by the test-splitter. Generally, these will be available in your testing environment by default, so you do not need to configure them. However, if you use Docker or some other type of containerization to run your tests, you may need to expose them to the containers.

| Environment Variable | Description|
| -------------------- | ----------- |
| `BUILDKITE_BUILD_ID` | The UUID of the Buildkite build. Test Splitter uses this UUID along with `BUILDKITE_STEP_ID` to uniquely identify the test plan. |
| `BUILDKITE_JOB_ID` | The UUID of the job in Buildkite build. |
| `BUILDKITE_ORGANIZATION_SLUG` | The slug of your Buildkite organization. |
| `BUILDKITE_PARALLEL_JOB` | The index number of a parallel job created from a Buildkite parallel build step. <br>Make sure you configure `parallelism` in your pipeline definition.  You can read more about Buildkite parallel build step on this [page](https://buildkite.com/docs/pipelines/controlling-concurrency#concurrency-and-parallelism).| 
| `BUILDKITE_PARALLEL_JOB_COUNT` | The total number of parallel jobs created from a Buildkite parallel build step. <br>Make sure you configure `parallelism` in your pipeline definition.  You can read more about Buildkite parallel build step on this [page](https://buildkite.com/docs/pipelines/controlling-concurrency#concurrency-and-parallelism). |
| `BUILDKITE_STEP_ID` | The UUID of the step group in Buildkite build. Test Splitter uses this UUID along with `BUILDKITE_BUILD_ID` to uniquely identify the test plan.

<br>

In addition to the above variables, you must set the following environment variables.

| Environment Variable | Description |
| -------------------- | ----------- |
| `BUILDKITE_SPLITTER_API_ACCESS_TOKEN ` | Buildkite API access token with `read_suites`, `read_test_plan`, and `write_test_plan` scopes. You can create an access token from [Personal Settings](https://buildkite.com/user/api-access-tokens) in Buildkite |
| `BUILDKITE_SPLITTER_SUITE_SLUG` | The slug of your Buildkite Test Analytics test suite. You can find the suite slug in the url for your suite. For example, the slug for the url: https://buildkite.com/organizations/my-organization/analytics/suites/my-suite is `my-suite` |

<br>

The following environment variables can be used optionally to configure your Test Splitter.

| Environment Variable | Default Value | Description |
| ---- | ---- | ----------- |
| `BUILDKITE_SPLITTER_DEBUG_ENABLED` | `false` | Flag to enable more verbose logging. |
| `BUILDKITE_SPLITTER_RETRY_COUNT` | `0` | The number of retries permitted. Test splitter runs the test command defined in `BUILDKITE_SPLITTER_TEST_CMD`, and retries only the failing tests for a maximum of `BUILDKITE_SPLITTER_RETRY_COUNT` times. For Rspec, the Test Splitter runs `BUILDKITE_SPLITTER_TEST_CMD` with `--only-failures` as the retry command. |
| `BUILDKITE_SPLITTER_SPLIT_BY_EXAMPLE` | `false` | Flag to enable split by example. When this option is `true`, the Test Splitter will split the execution of slow test files over multiple partitions. |
| `BUILDKITE_SPLITTER_TEST_CMD` | `bundle exec rspec {{testExamples}}` | Test command to run your tests. Test splitter will fill in the `{{testExamples}}` placeholder with the test splitting results |
| `BUILDKITE_SPLITTER_TEST_FILE_EXCLUDE_PATTERN` | - | Glob pattern to exclude certain test files or directories. The exclusion will be applied after discovering the test files using a pattern configured with `BUILDKITE_SPLITTER_TEST_FILE_PATTERN`. </br> *This option accepts the pattern syntax supported by the [zzglob](https://github.com/DrJosh9000/zzglob?tab=readme-ov-file#pattern-syntax) library.* |
| `BUILDKITE_SPLITTER_TEST_FILE_PATTERN` | `spec/**/*_spec.rb` | Glob pattern to discover test files. You can exclude certain test files or directories from the discovered test files using a pattern that can be configured with `BUILDKITE_SPLITTER_TEST_FILE_EXCLUDE_PATTERN`.</br> *This option accepts the pattern syntax supported by the [zzglob](https://github.com/DrJosh9000/zzglob?tab=readme-ov-file#pattern-syntax) library.* |


### Update the pipeline step

With the environment variables configured, you can now update your pipeline step to use test-splitter instead of running RSpec. A sample pipeline step for partitioning your test suite across 10 nodes is shown below.

```
steps:
  - name: "RSpec"
    command: ./test-splitter
    parallelism: 10
    env:
      BUILDKITE_SPLITTER_SUITE_SLUG: my-suite
      BUILDKITE_SPLITTER_API_ACCESS_TOKEN: your-secret-token
```
