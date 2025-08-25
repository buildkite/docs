---
toc: false
---

# Configuring Go with Test Engine

To use Test Engine with your [Go](https://go.dev/) language projects use [gotestsum](https://github.com/gotestyourself/gotestsum) to generate JUnit XML files, then [upload the JUnit XML files](/docs/test-engine/test-collection/importing-junit-xml) to Test Engine.

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
