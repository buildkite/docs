# Configuring test splitting

Buildkite maintains its open source Test Splitter ([test-splitter](https://github.com/buildkite/test-splitter)) tool. This tool uses your Buildkite Test Engine test suite data to intelligently partition tests throughout your test suite into multiple sets, such that each set of tests runs in parallel across your agents. This process is known as _orchestration_ and results in a _test plan_, where a test plan defines which tests are run on which agents. Currently, the Test Splitter tool only supports RSpec.

## Dependencies

The Test Splitter relies on execution timing data captured by the Buildkite test collectors from previous builds to partition your tests evenly across your agents. Therefore, you will need to configure the [Ruby test collector](/docs/test-engine/ruby-collectors) for your test suite.

## Installation

The [latest version of test-splitter](https://github.com/buildkite/test-splitter/releases) can be downloaded from GitHub for installation to your agent/s. Binaries are available for both Mac and Linux with 64-bit ARM and AMD architectures. Download the executable and make it available in your testing environment.

## Using the test splitter

Once you have downloaded the test-splitter binary and it's executable in your Buildkite pipeline, you'll need to configure some additional environment variables for the test splitter to function. You can then update your pipeline step to call test-splitter instead of calling RSpec to run your tests.

### Configure environment variables

The Test Splitter tool uses a number of [predefined](#predefined-environment-variables), [mandatory](#mandatory-environment-variables), and [optional](#optional-environment-variables) environment variables.

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
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

<a id="optional-environment-variables"></a>

#### Optional environment variables

The following optional environment variables can also be used to configure the Test Splitter's behavior.

<table class="Docs__attribute__table">
  <tbody>
    <% TEST_SPLITTING_ENV['optional'].each do |var| %>
      <tr id="<%= var['name'] %>">
        <th>
          <code><%= var['name'] %> <a class="Docs__attribute__link" href="#<%= var['name'] %>">#</a></code>
          <p class="Docs__attribute__env-var">
            <strong>Default</strong>:
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
