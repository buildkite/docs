# Configuring Go with Buildkite Test Engine

To use Buildkite Test Engine with your [Go](https://go.dev/) language projects, either use the [Tests Buildkite plugin](https://github.com/buildkite-plugins/tests-buildkite-plugin) to run `go test` through [bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client), or use [gotestsum](https://github.com/gotestyourself/gotestsum) to generate JUnit XML files and [upload them](/docs/pipelines/configure/tests/test-collection/importing-junit-xml) to Buildkite Test Engine.

<%= render_markdown partial: 'pipelines/configure/tests/test_collection/tests_plugin_recommendation' %>

## Tests Buildkite plugin example for Go test

The following step uses the [Tests Buildkite plugin](https://github.com/buildkite-plugins/tests-buildkite-plugin) to run `gotestsum` through bktec. The plugin downloads bktec, requests an OIDC token, ensures the test suite exists, and exports the environment variables that bktec expects, so the step's command only needs to invoke `bktec run`:

```yaml
steps:
  - label: "Go test"
    command: bktec run
    plugins:
      - tests#v1.0.0:
          test-runner: gotest
          result-path: gotest-results.xml
    parallelism: 4
```

See the [Tests Buildkite plugin page](https://github.com/buildkite-plugins/tests-buildkite-plugin) for the full plugin reference, including all supported options and dynamic parallelism with `bktec plan`.

## Uploading JUnit XML with gotestsum

If you want to use the JUnit XML import path instead of the Tests Buildkite plugin:

1. Install [gotestsum](https://github.com/gotestyourself/gotestsum):

    ```sh
    go install gotest.tools/gotestsum@latest
    ```

1. Use gotestsum to run your tests and output JUnit XML, by replacing `go test` with `gotestsum`, for example:

    ```sh
    gotestsum --junitfile junit.xml ./...
    ```

1. Upload the JUnit.xml to Buildkite:

    ```sh
    curl \
      -X POST \
      --fail-with-body \
      -H "Authorization: Token token=\"$BUILDKITE_ANALYTICS_TOKEN\"" \
      -F "data=@junit.xml" \
      -F "format=junit" \
      -F "run_env[CI]=buildkite" \
      -F "run_env[key]=$BUILDKITE_BUILD_ID" \
      -F "run_env[number]=$BUILDKITE_BUILD_NUMBER" \
      -F "run_env[job_id]=$BUILDKITE_JOB_ID" \
      -F "run_env[branch]=$BUILDKITE_BRANCH" \
      -F "run_env[commit_sha]=$BUILDKITE_COMMIT" \
      -F "run_env[message]=$BUILDKITE_MESSAGE" \
      -F "run_env[url]=$BUILDKITE_BUILD_URL" \
      https://analytics-api.buildkite.com/v1/uploads
    ```

See [gotestsum](https://github.com/gotestyourself/gotestsum) for full documentation of its features and command-line flags.
