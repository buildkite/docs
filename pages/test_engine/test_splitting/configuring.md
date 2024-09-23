# Configuring test splitting

Buildkite maintains its open source Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) tool. This tool uses your Test Engine test suite data to intelligently partition tests throughout your test suite into multiple sets, such that each set of tests runs in parallel across your agents. This process is known as _orchestration_ and results in a _test plan_, where a test plan defines which tests are run on which agents. Currently, the Test Engine Client tool only supports RSpec and Jest.

## Dependencies

The Test Engine Client relies on execution timing data captured by the test collectors from previous builds to partition your tests evenly across your agents. Therefore, you will need to configure the [Ruby test collector](/docs/test-engine/ruby-collectors) for your test suite if you are running RSpec, and [JavaScript test collector](/docs/test-engine/javascript-collectors) if you are running Jest.

## Installation

The Test Engine Client is supported on both Linux and macOS with 64-bit ARM and AMD architectures. You can install the client using the following installers:

- [Debian](client-installation#debian)
- [Red Hat](client-installation#red-hat)
- [macOS](client-installation#macos)
- [Docker](client-installation#docker)

If you need to install the client on a system not listed above you'll need to perform a manual installation using one of the binaries from [Test Engine Client's releases page](https://github.com/buildkite/test-engine-client/releases/latest). Once you have the binary, make it executable in your pipeline.

## Using the Test Engine Client

Once you have downloaded the Test Engine Client (bktec) binary and it is executable in your pipeline, you'll need to configure some additional environment variables for the Test Engine Client to function. You can then update your pipeline step to call `bktec` instead of calling RSpec to run your tests.

### Configure environment variables

The Test Engine Client tool uses a number of [predefined](#predefined-environment-variables), [mandatory](#mandatory-environment-variables), and [optional](#optional-environment-variables) environment variables.

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

<a id="optional-environment-variables"></a>

#### Optional environment variables

The following optional environment variables can also be used to configure the Test Engine Client's behavior.

**RSpec**

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

**Jest**

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

With the environment variables configured, you can now update your pipeline step to run the Test Engine Client instead of running RSpec, or Jest directly. The following example pipeline step demonstrates how to partition your RSpec test suite across 10 nodes.

```
steps:
  - name: "RSpec"
    command: bktec
    parallelism: 10
    env:
      BUILDKITE_TEST_ENGINE_API_ACCESS_TOKEN: your-secret-token
      BUILDKITE_TEST_ENGINE_RESULT_PATH: tmp/rspec-result.json
      BUILDKITE_TEST_ENGINE_SUITE_SLUG: my-suite
      BUILDKITE_TEST_ENGINE_RUNNER: rspec
```
{: codeblock-file="pipeline.yml"}

## API Rate Limits
There is a limit on the number of API requests that the Test Engine Client can make to the server. The limit is 10,000 requests per minute for each organization. When the rate limit is reached, the Test Engine Client will pause and wait until the rate limit is reset before retrying the request, ensuring that your build doesn't fail due to excessive API calls. This rate limit is separate from your REST API rate limit, meaning it specifically applies to the Test Engine Client's interactions with the server.
