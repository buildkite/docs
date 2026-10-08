# Manual test selection

Manual test selection runs only the tests you list, instead of the full test suite. You decide which tests a build needs, for example, the specs related to the files changed on a feature branch, and the Test Engine Client ([bktec](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client)) passes that list to Test Engine with the test plan request.

bktec still discovers the full suite and sends it to Test Engine as the set of _candidates_. Test Engine keeps the candidates that match your list, then splits the selected tests across your parallel jobs using historical timing data. You can [review the selection on the build's Orchestration page](#review-selection-in-orchestration).

Manual test selection works with every runner that bktec supports. The setup on this page uses the `manual-selection-command` option of the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/), which requires version 1.1.0 or later of the plugin and bktec v3.3.0 or later.

## Set up manual test selection

The Tests Buildkite plugin runs a selection command that you provide before the step's command, and passes the tests that the command prints to bktec.

1. Create a `.buildkite/select-tests.sh` script that prints the tests to run, one [selector](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client#using-bktec-selector-based-test-splitting) per line. For most test runners, a selector is the test file path. The following example prints the RSpec spec files changed on the current branch. Replace the `git diff` command with your own selection logic:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    base_branch="${BUILDKITE_PULL_REQUEST_BASE_BRANCH:-main}"
    git fetch origin "${base_branch}" >&2

    # Print the spec files that were added or changed on this branch
    git diff --name-only --diff-filter=d --relative \
      "origin/${base_branch}...HEAD" -- '*_spec.rb'
    ```

    The plugin treats each line that the command prints to standard output as a selector, so send any other output to standard error. Make the script executable with `chmod +x .buildkite/select-tests.sh`.

    List each selector as bktec discovers it. Selectors are relative to the directory that bktec runs in, without a location prefix. If bktec runs in a subdirectory, such as `backend` in a monorepo, replace `--relative` with `--relative=backend`.

1. Add a step to your `pipeline.yml` file that runs `bktec run` with the Tests Buildkite plugin, and set `manual-selection-command` to the script:

    ```yaml
    steps:
      - label: "Run selected tests"
        command: "bktec run"
        parallelism: 10
        plugins:
          - tests#v1.1.0:
              test-runner: rspec
              result-path: tmp/rspec-result.json
              manual-selection-command: ".buildkite/select-tests.sh"
    ```

    Setting `manual-selection-command` sets the selection strategy to `manual`, so the step doesn't need any selection flags.

Each parallel job runs the selection command, and the jobs in a step share one test plan, so the command must print the same list in every job. If the command fails, the job fails. If the command prints no tests, the jobs pass without running any tests.

If none of the listed selectors match a test that bktec discovers, `bktec run` and `bktec plan` fail. To pass the job even when nothing matches, set `fail-on-no-tests: false` in the plugin configuration. When fewer tests are selected than there are parallel jobs, the remaining jobs exit without running tests. To size the step to the selected tests, [use dynamic parallelism](#use-manual-selection-with-dynamic-parallelism).

## Use manual selection with dynamic parallelism

To size the test step to the selected tests, run the selection command on a planning step that runs `bktec plan`, and set a maximum parallelism and target time. bktec creates the test plan, then uploads the test step with the parallelism needed to reach the target time. The selection command only runs once, on the planning step. Learn more in [Dynamic parallelism](/docs/pipelines/configure/tests/bktec/installing-and-using-the-client#dynamic-parallelism).

```yaml
steps:
  - label: "Plan selected tests"
    key: "plan-selected-tests"
    command: "bktec plan --pipeline-upload .buildkite/selected-tests-template.yml"
    plugins:
      - tests#v1.1.0:
          test-runner: rspec
          result-path: tmp/rspec-result.json
          max-parallelism: 10
          target-time: 2m
          manual-selection-command: ".buildkite/select-tests.sh"
```
{: codeblock-file="pipeline.yml"}

The pipeline template runs the plan that `bktec plan` created. The test step doesn't need `manual-selection-command`, because the plan already contains the selected tests:

```yaml
steps:
  - label: "Run selected tests"
    command: "bktec run"
    depends_on: "plan-selected-tests"
    parallelism: ${BUILDKITE_TEST_ENGINE_PARALLELISM}
    plugins:
      - tests#v1.1.0:
          test-runner: rspec
          result-path: tmp/rspec-result.json
          plan-identifier: ${BUILDKITE_TEST_ENGINE_PLAN_IDENTIFIER}
```
{: codeblock-file=".buildkite/selected-tests-template.yml"}

If the selection command prints no tests, `bktec plan` doesn't upload the test step.

## Run selected tests in Docker

The plugin runs the selection command on the agent before the step's command, and passes the selected tests to bktec in the `BUILDKITE_TEST_ENGINE_SELECTION_SELECTORS` environment variable. When bktec runs inside a container using the [Docker plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/), add this variable to the Docker plugin's `environment` attribute. The Docker plugin's `propagate-environment` option doesn't pass it to the container. Without this variable, bktec sends no selectors and the job fails.

```yaml
steps:
  - label: "Run selected tests"
    command: "bktec run"
    parallelism: 10
    plugins:
      - tests#v1.1.0:
          test-runner: rspec
          result-path: tmp/rspec-result.json
          client-os: linux
          manual-selection-command: ".buildkite/select-tests.sh"
      - docker#v5.13.0:
          image: "ruby:3.4"
          expand-volume-vars: true
          volumes:
            - "$$BUILDKITE_TEST_ENGINE_CLIENT_PATH:/usr/local/bin/bktec"
          propagate-environment: true
          environment:
            - BUILDKITE_TEST_ENGINE_SELECTION_SELECTORS
```
{: codeblock-file="pipeline.yml"}

## Use manual selection without the plugin

If you don't use the Tests Buildkite plugin, pass the selection to bktec yourself. Set the selection strategy with `--selection-strategy manual` or `BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY=manual`, and pass the newline-separated selectors with `--selection-param "selectors=..."` or, from bktec v3.3.0, the `BUILDKITE_TEST_ENGINE_SELECTION_SELECTORS` environment variable. For example:

```bash
bktec run \
  --selection-strategy manual \
  --selection-param "selectors=$(.buildkite/select-tests.sh)"
```

Keep the double quotes around the `--selection-param` value, so that the newlines between selectors are preserved. Passing selectors with `--selection-param` requires bktec v3.2.1 or later.

## Check the selection in the job log

bktec prints a planning summary at the start of each job, showing the selection this job requested and the selection that Test Engine applied:

```
Requested
  Selection strategy: manual
    selectors = <3 nonblank entries; 92 bytes>
  Parallelism: 10 (fixed)

Selection summary
  Applied strategy: manual
  Selected: 3 of 412 test selectors (0.7%)
  Estimated compute: 72.4s of 2304s (3.1%)
  Candidate timing coverage: 96%
```

Test Engine caches each test plan, so retrying a job reuses the original selection, even if the list has changed. The summary then shows `Using existing plan`. Start a new build to select tests again.

## Git metadata

When a selection strategy is set, bktec also sends git metadata with the test plan request, including the full `git diff` against the base branch, which contains your source changes. Manual selection doesn't need this metadata. To turn it off, set `BUILDKITE_TEST_ENGINE_COLLECT_GIT_METADATA` to `false` in the pipeline-level `env`.

## Review selection in Orchestration

Each build page's **Tests** tab includes an **Orchestration** page, which shows how bktec selected and split the tests in each test plan used in the build. To open it, select the build's **Tests** tab, then select **Orchestration**. A test plan appears once a job using it finishes.

<%= image "orchestration-page.png", width: 2848/2, height: 1372/2, alt: "The Orchestration page on the build Tests tab, showing the partition timeline and a test plan panel with Test selection, Test splitting, and Test results cards" %>

The estimated time saved rows on the **Test selection** card only appear when at least half of the candidates have timing history. **Estimated test wall-clock time saved** only appears for steps with a fixed parallelism.

When at least one test was selected, the panel also shows a **Selection map** of the suite's test files, with the selected files in purple. Plans that mix test files or selectors with individual tests show **Coverage map unavailable for plans with mixed test formats** instead.

<%= image "selection-map.png", width: 2696/2, height: 586/2, alt: "The selection map, showing the suite's spec files grouped by directory, with the selected files in purple and the other files in gray" %>
