# Importing JUnit XML

While most test frameworks have a built-in JUnit XML export feature, these JUnit reports do not provide detailed span information. Therefore, features in Test Engine that depend on span information aren't available when using JUnit as a data source. If you need span information, consider using the [JSON import](/docs/test-engine/test-collection/importing-json) API instead.


## Mandatory JUnit XML attributes

The following attributes are mandatory for the `<testcase>` element:

- `classname`: full class name for the class the test method is in.
- `name`: name of the test method.

To learn more about the JUnit XML file format, see [Common JUnit XML format & examples
](https://github.com/testmoapp/junitxml).

## How to import JUnit XML in Buildkite

It's possible to import XML-formatted JUnit (or [JSON](/docs/test-engine/test-collection/importing-json#how-to-import-json-in-buildkite)) test results to Buildkite Test Engine with or without the help of a plugin.

### Using a plugin

To import XML-formatted JUnit test results to Test Engine using [Test Collector plugin](https://github.com/buildkite-plugins/test-collector-buildkite-plugin) from a build step:

```yml
steps:
  - label: "🔨 Test"
    command: "make test"
    plugins:
      - test-collector#v1.0.0:
          files: "test/junit-*.xml"
          format: "junit"
```
{: codeblock-file="pipeline.yml"}

See more configuration information in the [Test Collector plugin README](https://github.com/buildkite-plugins/test-collector-buildkite-plugin).

Using the plugin is the recommended way as it allows for a better debugging process in case of an issue.

### Not using a plugin

If for some reason you cannot or do not want to use the [Test Collector plugin](https://github.com/buildkite-plugins/test-collector-buildkite-plugin), or if you are looking to implement your own integration, another approach is possible.

To import XML-formatted JUnit test results to Test Engine, make a `POST` request to `https://analytics-api.buildkite.com/v1/uploads` with a `multipart/form-data`.
For example, to import the contents of a `junit.xml` file in a Buildkite pipeline:

1. Securely [set the Test Engine token environment variable](/docs/pipelines/security/secrets/managing) (`BUILDKITE_ANALYTICS_TOKEN`).

1. Run the following `curl` command:

    ```sh
    curl \
      -X POST \
      -H "Authorization: Token token=\"$BUILDKITE_ANALYTICS_TOKEN\"" \
      -F "data=@junit.xml" \
      -F "format=junit" \
      -F "run_env[CI]=buildkite" \
      -F "run_env[key]=$BUILDKITE_BUILD_ID" \
      -F "run_env[url]=$BUILDKITE_BUILD_URL" \
      -F "run_env[branch]=$BUILDKITE_BRANCH" \
      -F "run_env[commit_sha]=$BUILDKITE_COMMIT" \
      -F "run_env[number]=$BUILDKITE_BUILD_NUMBER" \
      -F "run_env[job_id]=$BUILDKITE_JOB_ID" \
      -F "run_env[message]=$BUILDKITE_MESSAGE" \
      https://analytics-api.buildkite.com/v1/uploads
    ```

To learn more about passing through environment variables to `run_env`-prefixed fields, see the [Buildkite](/docs/test-engine/test-collection/ci-environments#buildkite) or [Other CI providers](/docs/test-engine/test-collection/ci-environments#other-ci-providers) (including manually) on the [CI environments](/docs/test-engine/test-collection/ci-environments) page.

Note that when a payload is processed, Buildkite validates and queues each test execution result in a loop. For that reason, it is possible for some to be queued and others to be skipped. Even when some or all test executions get skipped, REST API will respond with a `202 Accepted` because the upload and the run were created in the database, but the skipped test execution results were not ingested.

Currently, the errors returned contain no information on individual records that failed the validation. This may complicate the process of fixing and retrying the request.

A single file can have a maximum of 5000 test results, and if that limit is exceeded then the upload request will fail. To upload more than 5000 test results for a single run upload multiple smaller files with the same `run_env[key]`.

#### Upload level custom tags

You can configure custom tags at the upload level.
These tags will be applied server-side to all test executions in the upload.
This is an efficient way to tag every execution with values that don't vary within one configuration—for example, cloud environment details, language/framework versions.

```sh
curl \
  -X POST \
  ... \
  -F "tags[team]=frontend" \
  -F "tags[feature]=alchemy" \
  https://analytics-api.buildkite.com/v1/uploads
```

If you need to import per-execution level custom tags, consider using [JSON import](/docs/test-engine/test-collection/importing-json).

## How to import JUnit XML in CircleCI

To import XML-formatted JUnit test results, make a `POST` request to `https://analytics-api.buildkite.com/v1/uploads` with a `multipart/form-data`.
For example, to import the contents of a `junit.xml` file in a CircleCI pipeline:

1. Securely [set the Test Engine token environment variable](/docs/pipelines/security/secrets/managing) (`BUILDKITE_ANALYTICS_TOKEN`).

1. Run the following `curl` command:

    ```sh
    curl \
      -X POST \
      -H "Authorization: Token token=\"$BUILDKITE_ANALYTICS_TOKEN\"" \
      -F "data=@junit.xml" \
      -F "format=junit" \
      -F "run_env[CI]=circleci" \
      -F "run_env[key]=$CIRCLE_WORKFLOW_ID-$CIRCLE_BUILD_NUM" \
      -F "run_env[number]=$CIRCLE_BUILD_NUM" \
      -F "run_env[branch]=$CIRCLE_BRANCH" \
      -F "run_env[commit_sha]=$CIRCLE_SHA1" \
      -F "run_env[url]=$CIRCLE_BUILD_URL" \
      https://analytics-api.buildkite.com/v1/uploads
    ```

To learn more about passing through environment variables to `run_env`-prefixed fields, see [CI environments > CircleCI](/docs/test-engine/test-collection/ci-environments#circleci) page section.

Note that when a payload is processed, Buildkite validates and queues each test execution result in a loop. For that reason, it is possible for some to be queued and others to be skipped. Even when some or all test executions get skipped, REST API will respond with a `202 Accepted` because the upload and the run were created in the database, but the skipped test execution results were not ingested.

Currently, the errors returned contain no information on individual records that failed the validation. This may complicate the process of fixing and retrying the request.

A single file can have a maximum of 5000 test results, and if that limit is exceeded then the upload request will fail. To upload more than 5000 test results for a single run upload multiple smaller files with the same `run_env[key]`.

## How to import JUnit XML in GitHub Actions

To import XML-formatted JUnit test results, make a `POST` request to `https://analytics-api.buildkite.com/v1/uploads` with a `multipart/form-data`.
For example, to import the contents of a `junit.xml` file in a GitHub Actions pipeline:

1. Securely [set the Test Engine token environment variable](/docs/pipelines/security/secrets/managing) (`BUILDKITE_ANALYTICS_TOKEN`).

1. Run the following `curl` command:

    ```sh
    curl \
      -X POST \
      --fail-with-body \
      -H "Authorization: Token token=\"$BUILDKITE_ANALYTICS_TOKEN\"" \
      -F "data=@junit.xml" \
      -F "format=junit" \
      -F "run_env[CI]=github_actions" \
      -F "run_env[key]=$GITHUB_ACTION-$GITHUB_RUN_NUMBER-$GITHUB_RUN_ATTEMPT" \
      -F "run_env[number]=$GITHUB_RUN_NUMBER" \
      -F "run_env[branch]=$GITHUB_REF" \
      -F "run_env[commit_sha]=$GITHUB_SHA" \
      -F "run_env[url]=https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" \
      https://analytics-api.buildkite.com/v1/uploads
    ```

To learn more about passing through environment variables to `run_env`-prefixed fields, see [CI environments > GitHub Actions](/docs/test-engine/test-collection/ci-environments#github-actions) page section.

Note that when a payload is processed, Buildkite validates and queues each test execution result in a loop. For that reason, it is possible for some to be queued and others to be skipped. Even when some or all test executions get skipped, REST API will respond with a `202 Accepted` because the upload and the run were created in the database, but the skipped test execution results were not ingested.

Currently, the errors returned contain no information on individual records that failed the validation. This may complicate the process of fixing and retrying the request.

A single file can have a maximum of 5000 test results, and if that limit is exceeded then the upload request will fail. To upload more than 5000 test results for a single run upload multiple smaller files with the same `run_env[key]`.
