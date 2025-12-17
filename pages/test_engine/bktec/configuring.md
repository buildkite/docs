# Configuring the Test Engine Client

Buildkite maintains its open source Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) tool. Currently, the bktec tool supports [RSpec](/docs/test-engine/test-collection/ruby-collectors#rspec-collector), [Jest](/docs/test-engine/test-collection/javascript-collectors#configure-the-test-framework-jest), [Cypress](/docs/test-engine/test-collection/javascript-collectors#configure-the-test-framework-cypress), [PlayWright](/docs/test-engine/test-collection/javascript-collectors#configure-the-test-framework-playwright), and [Pytest](/docs/test-engine/test-collection/python-collectors#pytest-collector), pytest-pants, [Go](/docs/test-engine/test-collection/golang-collectors), and cucumber testing frameworks.

If your testing framework is not supported, get in touch via support@buildkite.com or submit a pull request.

## Dependencies

bktec relies on execution timing data captured by the test collectors from previous builds to partition your tests evenly across your agents. Therefore, you will need to configure the [test collector](/docs/test-engine/test-collection) for your test framework.

## Installation

bktec is supported on both Linux and macOS with 64-bit ARM and AMD architectures. You can install the client using the following installers:

- [Debian](/docs/test-engine/bktec/installing-the-client#debian)
- [Red Hat](/docs/test-engine/bktec/installing-the-client#red-hat)
- [macOS](/docs/test-engine/bktec/installing-the-client#macos)
- [Docker](/docs/test-engine/bktec/installing-the-client#docker)

If you need to install this tool on a system without an installer listed above, you'll need to perform a manual installation using one of the binaries from [Test Engine Client's releases page](https://github.com/buildkite/test-engine-client/releases/latest). Once you have the binary, make it executable in your pipeline.

## Using bktec

Once you have downloaded the bktec binary and it is executable in your pipeline, you'll need to configure some additional environment variables for bktec to function. You can then update your pipeline step to call `bktec run` instead of calling RSpec to run your tests. Learn more about how to do this in [Update the pipeline step](#using-bktec-update-the-pipeline-step).

### Configure environment variables

bktec uses a number of [predefined](#predefined-environment-variables) and [mandatory](#mandatory-environment-variables) environment variables, as well as several optional ones for either [RSpec](#optional-rspec-environment-variables) or [Jest](#optional-jest-environment-variables).

<a id="predefined-environment-variables"></a>

#### Predefined environment variables

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

<a id="mandatory-environment-variables"></a>

#### Mandatory environment variables

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

<a id="optional-rspec-environment-variables"></a>

#### Optional RSpec environment variables

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

<a id="optional-jest-environment-variables"></a>

#### Optional Jest environment variables

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


### Update the pipeline step

With the environment variables configured, you can now update your pipeline step to run bktec instead of running RSpec, or Jest directly. The following example pipeline step demonstrates how to partition your RSpec test suite across 10 nodes.

```
steps:
  - name: "RSpec"
    command: bktec run
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_API_ACCESS_TOKEN: your-secret-token
      BUILDKITE_TEST_ENGINE_RESULT_PATH: tmp/rspec-result.json
      BUILDKITE_TEST_ENGINE_SUITE_SLUG: my-suite
      BUILDKITE_TEST_ENGINE_TEST_RUNNER: rspec
```
{: codeblock-file="pipeline.yml"}

## API rate limits

There is a limit on the number of API requests that bktec can make to the server. This limit is 10,000 requests per minute per Buildkite organization. When this limit is reached, bktec will pause and wait until the next minute is reached before retrying the request. This rate limit is independent of the [REST API rate limits](/docs/apis/rest-api/limits), and only applies to the Test Engine Client's interactions with the Test Splitting API.

## Dynamic parallelism

Usually the `parallelism` value is hard coded in the bktec pipeline step. However, from version 2.0.0, it is possible to run bktec with a dynamic `parallelism` value based on a target time for the test run. A common use case for this is test selection, where feature branch builds only run a subset of tests relevant to the changes being made.

Dynamic parallelism is supported using the `bktec plan` command. When used with the `--max-parallelism` and `--target-time` flags (see list of [bktec plan flags](#dynamic-parallelism-bktec-plan-flags) for more information), bktec generates a test plan and estimates the `parallelism` required to achieve the specified target build time. bktec then [uploads a dynamic pipeline](/docs/agent/v3/cli-pipeline) using the specified pipeline template.

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

These variables can be used in the template file provided to the `--pipeline-upload` flag, where you can use [environment variable substitution](/docs/agent/v3/cli-pipeline#environment-variable-substitution) to obtain their values.

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
