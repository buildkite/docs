# Installing and using the client

This page provides instructions on how to install the Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) using [installers](#installation) provided by Buildkite, as well as [configure and use bktec](#using-bktec).

## Installation

bktec is supported on both Linux ([Debian](#installation-debian) and [Red Hat](#installation-red-hat)) and [macOS](#installation-macos), as well as in [Docker](#installation-docker), for 64-bit ARM and AMD architectures. You can install the client using the following installers.
If you need to install this tool on a system without an installer listed below, you'll need to perform a manual installation using one of the binaries from [Test Engine Client's releases page](https://github.com/buildkite/test-engine-client/releases/latest). Once you have the binary, make it executable in your pipeline.

### Debian

1. Ensure you have curl and gpg installed first:

    ```shell
    apt update && apt install curl gpg -y
    ```

1. Install the registry signing key:

    ```shell
    curl -fsSL "https://packages.buildkite.com/buildkite/test-engine-client-deb/gpgkey" | gpg --dearmor -o /etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg
    ```

1. Configure the registry:

    ```shell
    echo -e "deb [signed-by=/etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/test-engine-client-deb/any/ any main\ndeb-src [signed-by=/etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/test-engine-client-deb/any/ any main" > /etc/apt/sources.list.d/buildkite-buildkite-test-engine-client-deb.list
    ```

1. Install the package:

    ```shell
    apt update && apt install bktec
    ```

### Red Hat

1. Configure the registry:

    ```shell
    echo -e "[test-engine-client-rpm]\nname=Test Engine Client - rpm\nbaseurl=https://packages.buildkite.com/buildkite/test-engine-client-rpm/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://packages.buildkite.com/buildkite/test-engine-client-rpm/gpgkey\npriority=1" > /etc/yum.repos.d/test-engine-client-rpm.repo
    ```

2. Install the package:

    ```shell
    dnf install -y bktec
    ```

### macOS

The Test Engine Client can be installed using [Homebrew](https://brew.sh) with [Buildkite tap formulae](https://github.com/buildkite/homebrew-buildkite). To install, run:

```shell
brew tap buildkite/buildkite && brew install buildkite/buildkite/bktec
```

### Docker

You can run the Test Engine Client inside a Docker container using the official image in [Docker Hub](https://hub.docker.com/r/buildkite/test-engine-client/tags).

To run the client using Docker:

```shell
docker run buildkite/test-engine-client
```

Or, to add the Test Engine Client binary to your Docker image, include the following in your Dockerfile:

```dockerfile
COPY --from=buildkite/test-engine-client /usr/local/bin/bktec /usr/local/bin/bktec
```

### Buildkite plugin

The [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) installs bktec automatically by default. Manual installation of bktec is not required when using the plugin.

Before downloading, the plugin checks whether bktec is already available on the `PATH`. If bktec is already installed and no specific `client-version`, `client-os`, or `client-arch` is configured, the plugin uses the existing binary and skips the download.

Set `install-client: false` in the plugin configuration to skip automatic installation and manage bktec yourself:

```yaml
steps:
  - label: "RSpec"
    command: bktec run
    plugins:
      - tests#v1.0.0:
          test-runner: rspec
          install-client: false
```
{: codeblock-file="pipeline.yml"}

Skipping automatic installation is useful when bktec is pre-installed in your build environment, such as through a shared Docker image or a package manager on your agent.

## Using bktec

Buildkite maintains its open source Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) tool. For the current list of test frameworks bktec supports, see the [supported runners and features](https://github.com/buildkite/test-engine-client#supported-runners-and-features) table in the bktec README.

If your testing framework is not supported, get in touch through support@buildkite.com or submit a pull request.

Once you have [installed the bktec binary](#installation) and it is executable in your pipeline, you'll need to [configure some additional environment variables](#using-bktec-configure-environment-variables) for bktec to function. You can then [update your pipeline step](#using-bktec-update-the-pipeline-step) to call `bktec run` instead of calling RSpec to run your tests.

### Configure result uploads

A [language-specific test collector](/docs/pipelines/configure/tests/test-collection) is not required to use bktec. Configure one of these methods to upload results from each test run:

- **Built-in bktec upload:** With bktec version 2.7.0 or later, set `BUILDKITE_TEST_ENGINE_UPLOAD_RESULTS` to `true`. Do not configure a language-specific collector to upload the same results.
- **Language-specific collector:** Install and configure the collector, then set `BUILDKITE_TEST_ENGINE_UPLOAD_RESULTS` to `false`. The collector uploads the results while bktec continues to run and split the tests.

Built-in uploads require either a suite token in `BUILDKITE_ANALYTICS_TOKEN` or an [OIDC policy](/docs/pipelines/configure/tests/test-collection/oidc) that grants the `write_uploads` scope.

> 🚧 Avoid duplicate test executions
> Do not activate both result upload methods for the same test run. If bktec and a language-specific collector both upload the results, Test Engine records duplicate test executions.

When you invoke bktec directly, built-in uploads are disabled by default. If you configure bktec using the Tests Buildkite plugin, built-in uploads are enabled by default. Set `upload-results: false` when a language-specific collector uploads the results.

### Selector-based test splitting

bktec v3 uses [selector-based test splitting](https://github.com/buildkite/test-engine-client#selector-based-test-splitting) by default for every supported test runner. A selector identifies a unit of work that a test runner can execute. Buildkite Test Engine matches each selector to historical test executions and uses their durations to balance work across parallel jobs. The Test Engine Client documentation explains how bktec discovers the selector for each runner.

bktec v2 continues to use file-based test splitting. Before upgrading, see [Migrating from bktec v2 to v3](https://github.com/buildkite/test-engine-client/blob/main/docs/migrating-to-v3.md) for collector version recommendations, location-prefix implications, Go and custom runner requirements, and behavior when selector history is unavailable.

### Configure environment variables

bktec uses a number of [predefined](#predefined-environment-variables) and [mandatory](#mandatory-environment-variables) environment variables, as well as several optional ones for either [RSpec](#optional-rspec-environment-variables) or [Jest](#optional-jest-environment-variables).

<h4 id="predefined-environment-variables">Predefined environment variables</h4>

By default, the following predefined environment variables are available to your testing environment and do not need any further configuration. If, however, you use Docker or some other type of containerization tool to run your tests, and you wish to use these predefined environment variables in these tests, you may need to expose these environment variables to your containers.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['predefined'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
        </th>
        <td>
          <% var['desc'].each do |d| %>
              <%= render_markdown(text: d) %>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="mandatory-environment-variables">Mandatory environment variables</h4>

The following mandatory environment variables must be set.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['mandatory'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
        </th>
        <td>
          <% var['desc'].each do |d| %>
            <%= render_markdown(text: d) %>
          <% end %>

          <% if var['note'].present? %>
            <section class="callout callout--info">
              <% var['note'].each do |d| %>
                <%= render_markdown(text: d) %>
              <% end %>
            </section>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="result-upload-environment-variables">Result upload environment variables</h4>

The following optional environment variable controls whether `bktec` uploads test results.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['optional']['result_upload'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
          <p class="Docs__attribute__env-var">
            <strong>Default</strong>:<br>
            <code><%= var['default'] %></code>
          </p>
        </th>
        <td>
          <% var['desc'].each do |d| %>
            <%= render_markdown(text: d) %>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="optional-environment-variables">Authentication environment variables</h4>

The following optional environment variables control authentication for `bktec` and test collection in the configured runner.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['optional']['auth'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
        </th>
        <td>
          <% var['desc'].each do |d| %>
            <%= render_markdown(text: d) %>
          <% end %>

          <% if var['note'].present? %>
            <section class="callout callout--info">
              <% var['note'].each do |d| %>
                <%= render_markdown(text: d) %>
              <% end %>
            </section>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="optional-rspec-environment-variables">Optional RSpec environment variables</h4>

The following optional RSpec environment variables can also be used to configure bktec's behavior.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['optional']['rspec'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
          <p class="Docs__attribute__env-var">
            <strong>Default</strong>:<br>
            <code><%= var['default'] || "-" %></code>
          </p>
        </th>
        <td>
          <% var['desc'].each do |d| %>
            <%= render_markdown(text: d) %>
          <% end %>

          <% if var['note'].present? %>
            <section class="callout callout--info">
              <% var['note'].each do |d| %>
                <%= render_markdown(text: d) %>
              <% end %>
            </section>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<h4 id="optional-jest-environment-variables">Optional Jest environment variables</h4>

The following optional Jest environment variables can also be used to configure bktec's behavior.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['optional']['jest'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
          <p class="Docs__attribute__env-var">
            <strong>Default</strong>:<br>
            <code><%= var['default'] || "-" %></code>
          </p>
        </th>
        <td>
          <% var['desc'].each do |d| %>
            <%= render_markdown(text: d) %>
          <% end %>

          <% if var['note'].present? %>
            <section class="callout callout--info">
              <% var['note'].each do |d| %>
                <%= render_markdown(text: d) %>
              <% end %>
            </section>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Promise failure

To let `bktec` declare that a Buildkite Pipelines job is expected to fail before the job exits, set `BUILDKITE_TEST_ENGINE_PROMISE_FAILURE` to `true`.

When this option is enabled, `bktec` calls [`buildkite-agent job promise-failure`](/docs/agent/cli/reference/job#promising-job-failure) after retries are exhausted and hard test failures remain. Muted test failures do not cause `bktec` to promise failure.

```yaml
steps:
  - label: "RSpec"
    command: bktec run
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_API_ACCESS_TOKEN: YOUR_API_TOKEN
      BUILDKITE_TEST_ENGINE_RESULT_PATH: tmp/rspec-result.json
      BUILDKITE_TEST_ENGINE_SUITE_SLUG: my-suite
      BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec
      BUILDKITE_TEST_ENGINE_PROMISE_FAILURE: "true"
```
{: codeblock-file="pipeline.yml"}

This helps Buildkite Pipelines move the build to `failing` earlier while the test job continues uploading logs and results. Learn more in [Promise job failure](/docs/pipelines/configure/promise-job-failure).

### Update the pipeline step

With the environment variables configured, you can now update your pipeline step to run bktec instead of running RSpec or Jest directly. The following example pipeline step partitions an RSpec test suite across 10 jobs and uses the built-in `bktec` upload:

```yaml
steps:
  - label: "RSpec"
    command: bktec run
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_RESULT_PATH: tmp/rspec-result.json
      BUILDKITE_TEST_ENGINE_SUITE_SLUG: my-suite
      BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec
      BUILDKITE_TEST_ENGINE_UPLOAD_RESULTS: "true"
```
{: codeblock-file="pipeline.yml"}

## API rate limits

There is a limit on the number of API requests that bktec can make to the server. This limit is 10,000 requests per minute per Buildkite organization. When this limit is reached, bktec will pause and wait until the next minute is reached before retrying the request. This rate limit is independent of the [REST API rate limits](/docs/apis/rest-api/limits), and only applies to the Test Engine Client's interactions with the Test Splitting API.

## Dynamic parallelism

Usually the `parallelism` value is hard coded in the bktec pipeline step. However, from version 2.0.0, it is possible to run bktec with a dynamic `parallelism` value based on a target time for the test run. A common use case for this is test selection, where feature branch builds only run a subset of tests relevant to the changes being made.

Dynamic parallelism is supported using the `bktec plan` command. When used with the `--max-parallelism` and `--target-time` flags (see list of [bktec plan flags](#dynamic-parallelism-bktec-plan-flags) for more information), bktec generates a test plan and estimates the `parallelism` required to achieve the specified target build time. bktec then [uploads a dynamic pipeline](/docs/agent/cli/reference/pipeline) using the specified pipeline template.

In the following example, the `test-selection.sh` script is assumed to generate a list of test files, one per line, relevant to the changes in a feature branch.

```
steps:
  - name: "Test selection"
    command: test-selection.sh > selected-files.txt

  - wait: ~

  - name: "Dynamic pipeline"
    key: "dynamic-pipeline"
    command: bktec plan --max-parallelism 10 --target-time 2m --files selected-files.txt --pipeline-upload .buildkite/dynamic-pipeline-template.yml
```
{: codeblock-file="pipeline.yml"}

In this example pipeline, bktec uploads a dynamic pipeline using `.buildkite/dynamic-pipeline-template.yml` by invoking `buildkite agent pipeline upload`. Learn more about the [bktec plan additional environment variables](#dynamic-parallelism-bktec-plan-additional-environment-variables) generated during pipeline uploads.

These variables can be used in the template file provided to the `--pipeline-upload` flag, where you can use [environment variable substitution](/docs/agent/cli/reference/pipeline#environment-variable-substitution) to obtain their values.

```
steps:
- command: "bktec run --plan-identifier ${BUILDKITE_TEST_ENGINE_PLAN_IDENTIFIER}"
  name: "bktec run"
  depends_on: "dynamic-pipeline"
  parallelism: ${BUILDKITE_TEST_ENGINE_PARALLELISM}
```
{: codeblock-file=".buildkite/dynamic-pipeline-template.yml"}

### bktec plan flags

The `bktec plan` command supports the following flags, which controls the behavior of the dynamic parallelism test plan. Each flag's value alternatively can be supplied using an environment variable.

<table class="responsive-table">
  <tbody>
    <tr>
      <td><code>--max-parallelism</code></td>
      <td>
        The maximum allowed parallelism for a dynamic parallelism test plan.
        <br>
        <strong>Environment variable:</strong>
        <code>$BUILDKITE_TEST_ENGINE_MAX_PARALLELISM</code>
      </td>
    </tr>
    <tr>
      <td><code>--target-time</code></td>
      <td>
        Target duration for each node, for example, <code>2m30s</code>.
        The test planner will attempt to split the test plan into equal duration buckets of this duration and calculate the optimum parallelism to achieve this, up to the value supplied to <code>--max-parallelism</code>
        <br>
        <strong>Environment variable:</strong>
        <code>$BUILDKITE_TEST_ENGINE_TARGET_TIME</code>
      </td>
    </tr>
    <tr>
      <td><code>--files</code></td>
      <td>
        Path to a file containing a newline separated list of test file names to be executed.
        <br>
        <strong>Environment variable:</strong>
        <code>$BUILDKITE_TEST_ENGINE_FILES</code>
      </td>
    </tr>
  </tbody>
</table>

### bktec plan additional environment variables

The `bktec plan` command generates the following additional environment variables when uploading the pipeline.

<table class="responsive-table">
  <tbody>
    <tr>
      <td><code>BUILDKITE_TEST_ENGINE_PLAN_IDENTIFIER</code></td>
      <td>The identifier of the test plan generated by <code>bktec plan</code>.</td>
    </tr>
    <tr>
      <td><code>BUILDKITE_TEST_ENGINE_PARALLELISM</code></td>
      <td>The parallelism estimated by the test planner to achieve the requested target build time.</td>
    </tr>
  </tbody>
</table>

## Manual test selection

Manual test selection runs only the tests you list, instead of the full test suite. You decide which tests a build needs, for example, the specs related to the files changed on a feature branch, and bktec passes that list to Test Engine with the test plan request.

bktec still discovers the full suite and sends it to Test Engine as the set of _candidates_. Test Engine keeps the candidates that match your list, then splits the selected tests across your parallel jobs using historical timing data. Because Test Engine selects from the full suite, it records how many candidates were selected, which you can [review on the build's Orchestration page](#review-selection-in-orchestration).

Manual test selection requires bktec v3.2.0 or later. It works with every runner that bktec supports, and you can use it with both fixed `parallelism` and [dynamic parallelism](#dynamic-parallelism).

### Set up manual test selection

The recommended setup uses two steps. The first step generates the list of tests to run and saves it as an [artifact](/docs/pipelines/configure/artifacts). The second step downloads the list and passes it to `bktec run`. Generating the list once means every parallel job uses an identical list.

1. Create a `.buildkite/select-tests.sh` script that writes the tests to run to `tests-to-run.txt`, one path per line. The following example selects the RSpec spec files changed on the current branch. Replace the `git diff` command with your own selection logic:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    base_branch="${BUILDKITE_PULL_REQUEST_BASE_BRANCH:-main}"
    git fetch origin "${base_branch}"

    # Select the spec files that were added or changed on this branch
    git diff --name-only --diff-filter=d "origin/${base_branch}...HEAD" -- '*_spec.rb' > tests-to-run.txt
    ```

1. Create a `.buildkite/run-selected-tests.sh` script that downloads the list and runs bktec with the `manual` selection strategy. Pass the list as the `files` selection parameter:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail

    buildkite-agent artifact download tests-to-run.txt .

    if ! grep -q '[^[:space:]]' tests-to-run.txt; then
      echo "No tests selected for this build"
      exit 0
    fi

    bktec run \
      --selection-strategy manual \
      --selection-param "files=$(cat tests-to-run.txt)"
    ```

    Keep the double quotes around the `--selection-param` value, so that the newlines between paths are preserved. The empty list check is required because Test Engine rejects a manual selection request with no paths.

1. Add both steps to your `pipeline.yml` file. Use the [Tests Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/tests-buildkite-plugin/) on the test step, so that the plugin installs bktec, authenticates with OIDC, and enables built-in result uploads:

    ```yaml
    steps:
      - label: "Select tests"
        key: "select-tests"
        command: ".buildkite/select-tests.sh"
        artifact_paths: "tests-to-run.txt"

      - label: "RSpec"
        depends_on: "select-tests"
        command: ".buildkite/run-selected-tests.sh"
        parallelism: 10
        plugins:
          - tests#v1.0.0:
              test-runner: rspec
              result-path: tmp/rspec-result.json
    ```

    The plugin doesn't have an option for manual selection, so the selection flags are passed to bktec in the script. The plugin installs the latest bktec release by default. If you set the plugin's `client-version` option, use version 3.2.0 or later. If you don't use the plugin, set the [environment variables](#using-bktec-configure-environment-variables) that bktec needs on the test step instead.

When Test Engine selects fewer tests than there are parallel jobs, the remaining jobs receive no tests and exit successfully. To size the step to the selected tests instead, [use manual selection with dynamic parallelism](#manual-test-selection-use-manual-selection-with-dynamic-parallelism).

You can also set the strategy with the `BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY` environment variable, instead of the `--selection-strategy` flag. The `--selection-param` value can only be set with the flag.

<table class="responsive-table">
  <tbody>
    <tr>
      <td><code>--selection-strategy</code></td>
      <td>
        The test selection strategy. Set to <code>manual</code> to run only the tests passed with <code>--selection-param files=...</code>.
        <br>
        <strong>Environment variable:</strong>
        <code>$BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY</code>
      </td>
    </tr>
    <tr>
      <td><code>--selection-param</code></td>
      <td>
        A selection strategy parameter in <code>key=value</code> format. For manual selection, pass <code>files=</code> followed by a newline-separated list of test paths.
      </td>
    </tr>
    <tr>
      <td><code>--collect-git-metadata</code></td>
      <td>
        Whether bktec sends git metadata with the test plan request. Defaults to <code>true</code> when a selection strategy is set. Set to <code>false</code> to opt out. Learn more in <a href="#manual-test-selection-git-metadata">Git metadata</a>.
        <br>
        <strong>Environment variable:</strong>
        <code>$BUILDKITE_TEST_ENGINE_COLLECT_GIT_METADATA</code>
      </td>
    </tr>
  </tbody>
</table>

### List test paths

Each line of the `files` value must match a test as bktec discovers it:

- **Relative to the bktec working directory:** List paths relative to the directory that bktec runs in, not the repository root. For example, if bktec runs in a `frontend` directory, list `src/app.test.js`, not `frontend/src/app.test.js`.
- **Without a location prefix:** If you set `BUILDKITE_TEST_ENGINE_LOCATION_PREFIX`, don't add the prefix to the listed paths.
- **One test file per line:** Manual selection matches whole test files. Line numbers and test IDs, such as `spec/user_spec.rb:12`, `spec/user_spec.rb[1:1]`, or `tests/test_user.py::test_login`, are removed, so the whole file is selected.
- **Go packages for gotest:** The gotest runner discovers Go packages, so list package import paths, such as `example.com/project/internal/users`.
- **Selectors for a selector file:** If you provide selectors with `--selector-file`, list selectors from that file.

A leading `./`, leading and trailing spaces, blank lines, and duplicate paths are ignored. Listed paths that don't match a discovered test are also ignored, so a listed file that bktec doesn't discover, for example because it's excluded by a test file pattern, doesn't run.

If none of the listed paths match, bktec prints a warning and runs no tests, rather than falling back to running the full suite.

### Use manual selection with dynamic parallelism

To size the test step to the selected tests, pass the same selection flags to `bktec plan`, and set a maximum parallelism and target time. bktec creates the test plan, then uploads the test step with the parallelism needed to reach the target time. Learn more in [Dynamic parallelism](#dynamic-parallelism).

In the following pipeline, the planning step sets the maximum parallelism and target time using the Tests Buildkite plugin:

```yaml
steps:
  - label: "Select tests"
    key: "select-tests"
    command: ".buildkite/select-tests.sh"
    artifact_paths: "tests-to-run.txt"

  - label: "Plan selected tests"
    key: "plan-selected-tests"
    depends_on: "select-tests"
    command: ".buildkite/plan-selected-tests.sh"
    plugins:
      - tests#v1.0.0:
          test-runner: rspec
          result-path: tmp/rspec-result.json
          max-parallelism: 10
          target-time: 2m
```
{: codeblock-file="pipeline.yml"}

The planning script runs `bktec plan` with the selected tests:

```bash
#!/usr/bin/env bash
set -euo pipefail

buildkite-agent artifact download tests-to-run.txt .

if ! grep -q '[^[:space:]]' tests-to-run.txt; then
  echo "No tests selected for this build"
  exit 0
fi

bktec plan \
  --selection-strategy manual \
  --selection-param "files=$(cat tests-to-run.txt)" \
  --pipeline-upload .buildkite/selected-tests-template.yml
```
{: codeblock-file=".buildkite/plan-selected-tests.sh"}

The pipeline template runs the `.buildkite/run-selected-tests.sh` script from the [setup steps](#manual-test-selection-set-up-manual-test-selection), with the plan identifier from `bktec plan`:

```yaml
steps:
  - label: "RSpec"
    command: ".buildkite/run-selected-tests.sh"
    depends_on: "plan-selected-tests"
    parallelism: ${BUILDKITE_TEST_ENGINE_PARALLELISM}
    plugins:
      - tests#v1.0.0:
          test-runner: rspec
          result-path: tmp/rspec-result.json
          plan-identifier: ${BUILDKITE_TEST_ENGINE_PLAN_IDENTIFIER}
```
{: codeblock-file=".buildkite/selected-tests-template.yml"}

Test Engine caches the test plan under its plan identifier. The planning step and every job that uses the plan identifier must pass the same selection strategy and list of tests. If none of the listed tests match, `bktec plan` reports a parallelism of `0` and doesn't upload the pipeline template.

### Check the selection in the job log

bktec prints a planning summary at the start of each job. The **Requested** section shows the selection that this job sent, including the number of listed paths. The paths themselves aren't printed. The **Selection summary** section shows the selection that Test Engine applied to the test plan:

```
+++ Buildkite Test Engine Client: Planning
bktec v3.2.0

Requested
  Selection strategy: manual
    files = <3 nonblank entries; 92 bytes>
  Parallelism: 10 (fixed)

Selection summary
  Applied strategy: manual
  Selected: 3 of 412 test selectors (0.7%)
  Estimated compute: 72.4s of 2304s (3.1%)
  Candidate timing coverage: 96%
```

The selected and candidate counts are _test selectors_, the units that bktec splits across jobs. These are usually test files. However, bktec can split some files into individual tests, for example, RSpec files that contain [skipped tests](/docs/pipelines/configure/tests/test-suites/test-state-and-quarantine), so the selected count can be higher than the number of listed paths.

The **Estimated compute** line compares the total duration of the selected tests with the total duration of all candidates, using the mean of each test's historical durations. Candidates without timing history are estimated using the median duration of the other candidates. This estimate is the total test time across all jobs, not the build's wall-clock time. The **Candidate timing coverage** line shows the proportion of candidates that have timing history. If fewer than half of the candidates have timing history, the estimate shows `unavailable`.

To save the full test plan that a job used, including the selected tests for every job, set `BUILDKITE_TEST_ENGINE_PLAN_OUT` to a file path, or pass `--plan-out` to `bktec run`.

### Git metadata

When a selection strategy is set, bktec also collects git metadata from the repository and sends it with the test plan request. This metadata includes the commit details, the branch and base branch, Buildkite build context, the files changed against the base branch, and the full `git diff` against the base branch, which contains your source changes.

Manual selection doesn't need this metadata to select tests. To stop bktec from collecting it, for example, because of large diffs or to avoid sending source changes, set `BUILDKITE_TEST_ENGINE_COLLECT_GIT_METADATA` to `false`. Set this variable for the whole build, such as in the pipeline-level `env`, rather than on individual steps.

## Review selection in Orchestration

Each build page's **Tests** tab includes an **Orchestration** page, which shows how bktec selected and split the tests in the build. Use it to confirm that manual selection ran the tests you expected, and to compare the selected tests with the rest of the suite.

To open the **Orchestration** page:

1. Open the build page.
1. Select the **Tests** tab.
1. Select **Orchestration**.

<%= image "orchestration-page.png", width: 2848/2, height: 1372/2, alt: "The Orchestration page on the build Tests tab, showing the partition timeline and a test plan panel with Test selection, Test splitting, and Test results cards" %>

The **Orchestration** page is only available for the whole build, not for an individual job. The **Tests** tab is shown once the build has uploaded test results to Test Engine.

### Test plans for the build

The **Orchestration** page lists the test plans that bktec used in the build, with one panel for each plan. Each panel shows the label of the step that ran bktec, the number of partitions (parallel jobs), and a **View test plan** link, which opens the plan's test splitting page with the tests assigned to each partition. The first panel is expanded. Select a panel's heading to expand or collapse it.

A test plan is listed once a `bktec run` job using that plan finishes and reports its results. Plans that bktec created locally because Test Engine was unavailable aren't listed. When a build has more than 50 test plans, the page shows the 50 plans with the most partitions.

Each panel contains the following cards:

- **Test selection:** For a plan that used a selection strategy, this card shows how many candidates were selected, for example, 3 of 412 candidates selected, and the selected percentage. Candidates are test files, individual tests, or selectors, and one candidate can produce multiple test results. The **Strategy** row shows **Manual** for manual selection. When Test Engine didn't apply the requested selection, the card shows the candidates included and a **Reason** row. Plans that didn't use a selection strategy don't show this card.

    When Test Engine has timing history for at least half of the candidates, the card also shows estimates of the time that the selection saved:

    * **Estimated compute saved:** The total duration of all candidates, minus the total duration of the selected tests, using the mean of each test's historical durations. This is the test time saved across all partitions.
    * **Estimated test wall-clock time saved:** The duration of the longest partition when all candidates are split across the plan's partitions, minus the duration of the longest partition for the selected tests, using median durations. This row only appears for steps with a fixed `parallelism`, not for [dynamic parallelism](#manual-test-selection-use-manual-selection-with-dynamic-parallelism).
    * **Timing coverage:** The proportion of candidates that have timing history. Candidates without timing history are estimated using the median duration of the other candidates.

    These are estimates based on historical durations, not measurements of the build.
- **Test splitting:** This card shows how many files, tests, or selectors were split across the partitions, how many of them had historical durations or used a median or default duration instead, the slowest reported partition, and the estimated time saved by splitting.
- **Test results:** This card shows the number of results reported, broken down by passed, passed on retry, failed, and skipped results, as well as any [muted](/docs/pipelines/configure/tests/test-suites/test-state-and-quarantine) results.

### Partition timeline

When bktec reports timing for the partitions, a **Partition timeline** appears above the test plans. Each line is one partition, positioned at its reported start time, with a length matching its duration. Partitions are colored by test plan.

<%= image "partition-timeline.png", width: 2764/2, height: 380/2, alt: "The partition timeline, showing one line for each of four partitions in an RSpec test plan" %>

- Use the **Sort** menu to order partitions by **Latest finish**, **Longest duration**, or **Earliest start**.
- Select a step in the legend to show only that test plan's partitions.
- Hover over a line to see the partition's step, number, test count, how many tests had historical durations, start offset, and duration.
- Select a line to open the test plan at that partition.

### Selection coverage map

For a test plan where the selection was applied and selected at least one test, the expanded panel also shows a **Selection map**. The map shows where the selected tests sit in your whole test suite, so you can see at a glance which areas of the codebase the build tested and which it skipped.

The selection map is a treemap of the test files or selectors that have run in the suite recently:

- Each tile is a test file, or a selector, such as a Go package.
- A tile's size reflects the number of tests recorded for it.
- Tiles are grouped by directory and ordered by path, so each file keeps the same position from one build to the next.
- Purple tiles were selected in this plan. Gray tiles are other files or selectors in the suite that weren't selected.

<%= image "selection-map.png", width: 2696/2, height: 586/2, alt: "The selection map, showing the suite's spec files grouped by directory, with the selected files in purple and the other files in gray" %>

Hover over a tile to see its path, its number of tests, and whether it was selected. Select **View test plan** below the map to open the full test plan.

The selection map isn't available for a test plan that mixes test files and individual tests, which happens when bktec splits some files into individual tests. In this case, the panel shows the message **Coverage map unavailable for plans with mixed test formats**.

## Troubleshoot manual test selection

The following sections describe common manual test selection problems and how to resolve them. To see more detail about the requests that bktec makes, set `BUILDKITE_TEST_ENGINE_DEBUG_ENABLED` to `true`.

### bktec exits with an error

- **`flag provided but not defined: -selection-strategy`:** Your bktec version doesn't support manual test selection. Upgrade to bktec v3.2.0 or later. Earlier versions also ignore `BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY` and run the full suite.
- **`selection strategy must be set when selection params are provided`:** You passed `--selection-param` without a selection strategy. Add `--selection-strategy manual`, or set `BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY`.
- **`must use key=value format`:** The `--selection-param` value is missing the `files=` key. Pass the value as `"files=$(cat tests-to-run.txt)"`.
- **`Invalid Request` with `params.files must include at least one filename`:** The list of tests was empty. Check for an empty list before running bktec, as shown in [Set up manual test selection](#manual-test-selection-set-up-manual-test-selection).

### The full suite runs

Check the **Requested** and **Selection summary** sections of the [planning summary](#manual-test-selection-check-the-selection-in-the-job-log) in the job log:

- **`Selection: none requested`:** bktec didn't send a selection. Check that the step sets `--selection-strategy manual` or `BUILDKITE_TEST_ENGINE_SELECTION_STRATEGY`. The values `none`, `off`, `false`, `disabled`, and `no` turn selection off.
- **`Not applied: local fallback uses the full locally discovered suite`:** bktec couldn't get a test plan from Test Engine, for example, because the API timed out. bktec runs the full suite rather than skipping tests. The warnings before the summary explain the cause.
- **`No selection metadata returned`:** Test Engine returned a test plan without a selection. If the summary also shows `Using existing plan`, the job reused a test plan that was created without a selection, as described in [A changed list has no effect](#troubleshoot-manual-test-selection-a-changed-list-has-no-effect). Otherwise, contact support@buildkite.com.

### No tests or fewer tests than expected run

If bktec prints `Selection matched none of the ... candidate test selectors`, or the selected count is lower than the number of listed paths, some listed paths don't match a test that bktec discovered. Check the paths against [List test paths](#manual-test-selection-list-test-paths). The most common causes are:

- Paths that are relative to the repository root, when bktec runs in a subdirectory.
- Paths that include the location prefix.
- Paths to files that were deleted, or that the runner's test file pattern excludes.
- File paths listed for the gotest runner, instead of package import paths.

To see the paths that bktec discovers, run `bktec plan --plan-out - --plan-identifier "$(uuidgen)"` without a selection strategy, from the same directory and with the same environment variables as your test step. Then compare your list with the `path` or `value` of the tests in the plan. The unique plan identifier keeps this plan separate from the test plans that your build uses.

If some parallel jobs run no tests while others do, Test Engine selected fewer tests than the step's `parallelism`. These jobs exit successfully, unless you've set `BUILDKITE_TEST_ENGINE_FAIL_ON_NO_TESTS` to `true`. To avoid idle jobs, [use manual selection with dynamic parallelism](#manual-test-selection-use-manual-selection-with-dynamic-parallelism).

### A changed list has no effect

Test Engine caches each test plan under its plan identifier, which defaults to the build ID and step ID. Retrying a job reuses the cached test plan, so a list that changed after the plan was created has no effect, and the planning summary shows `Using existing plan`. Start a new build to create a new test plan.

For the same reason, every parallel job in a step must pass the same list. If jobs generate their own lists, the first job to request a plan determines the selection for all of them. Generate the list in an earlier step, as shown in [Set up manual test selection](#manual-test-selection-set-up-manual-test-selection).

### Git metadata warnings appear

bktec can print warnings such as `Could not resolve base branch for diff metadata` or `Not a git repository, skipping metadata auto-collection`. These warnings don't affect manual selection. To stop bktec from collecting git metadata, set `BUILDKITE_TEST_ENGINE_COLLECT_GIT_METADATA` to `false` for the whole build.

### A test plan is missing from the Orchestration page

- Open the **Orchestration** page from the build's **Tests** tab, rather than from a job's tests.
- Wait for at least one `bktec run` job using the plan to finish. Test plans appear once a job reports its results.
- Check the job log for `Using local fallback`. Test plans that bktec creates locally aren't listed.
- If the build has more than 50 test plans, only the 50 plans with the most partitions are listed.

### Time saved estimates are missing

- **No time saved estimates:** If the job log shows `Estimated compute: unavailable` and the **Test selection** card has no estimated time saved rows, fewer than half of the candidates have timing history, so Test Engine can't estimate the time saved. Upload test results from full-suite builds, for example, builds of your default branch, so that Test Engine records timing history for the whole suite.
- **No Estimated test wall-clock time saved row:** The step uses dynamic parallelism. Test Engine only estimates wall-clock time saved for steps with a fixed `parallelism`.

### The selection map isn't shown

The selection map is only shown for a test plan where Test Engine applied the selection and selected at least one test. If the map shows a message instead:

- **No tests were selected for this plan:** The selection matched no tests. See [No tests or fewer tests than expected run](#troubleshoot-manual-test-selection-no-tests-or-fewer-tests-than-expected-run).
- **Coverage map unavailable for plans with mixed test formats:** bktec split some files into individual tests, for example, RSpec files that contain skipped tests. The **Test selection** card still shows the selection.
- **The coverage map could not be loaded:** Select **Retry**.
