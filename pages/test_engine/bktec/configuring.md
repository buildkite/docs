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
