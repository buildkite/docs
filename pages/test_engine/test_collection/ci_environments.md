# CI environments

Buildkite Test Engine collectors automatically detect common continuous integration (CI) environments.
If available, test collectors gather information about your test runs, such as branch names and build IDs.
Test collectors gather information from the following CI environments:

- [Buildkite](/docs/test-engine/test-collection/ci-environments#buildkite)
- [CircleCI](/docs/test-engine/test-collection/ci-environments#circleci)
- [GitHub Actions](/docs/test-engine/test-collection/ci-environments#github-actions)

If you run test collectors inside [containers](/docs/test-engine/test-collection/ci-environments#containers-and-test-collectors) or use another CI system, you must set variables to report your CI details to Buildkite.

If you're not using a test collector, see [Importing JSON](/docs/test-engine/test-collection/importing-json) and [Importing JUnit XML](/docs/test-engine/test-collection/importing-junit-xml) to learn how to provide run environment data.


## Run environment

### Required

- `run_env[key]`: The identifier of a run, which may be the same across multiple uploads; often the build ID.

### Recommended

If you're manually providing environment variables, we strongly recommend setting the following variables:

- `run_env[branch]`: Sends the branch or reference for this build, enabling you to filter data by branch.
- `run_env[commit_sha]`: Sends the commit hash for the head of the branch, enabling automatic flaky test detection in your builds.
- `run_env[message]`: Forwards the commit message for the head of the branch, helping you identify different runs more easily.
- `run_env[url]`: Provides the URL for the build on your CI provider, giving you a handy link back to the CI build.

## Containers and test collectors

If you're using containers within your CI system, then the environment variables used by test collectors may not be exposed to those containers by default.
Make sure to export your CI environment's variables and your Buildkite API token to your containerized builds and tests.

For example, by default Docker does not receive the host's environment variables.
To pass them through to the Docker container, use the `--env` option:

```
  docker run \
    --env BUILDKITE_ANALYTICS_TOKEN \
    --env BUILDKITE_BUILD_ID \
    --env BUILDKITE_BUILD_NUMBER \
    --env BUILDKITE_JOB_ID \
    --env BUILDKITE_BRANCH \
    --env BUILDKITE_COMMIT \
    --env BUILDKITE_MESSAGE \
    --env BUILDKITE_BUILD_URL \
    bundle exec rspec
```

Review the following sections for the environment variables expected by test collectors.

## Buildkite

During Buildkite pipeline runs, test collectors upload information from the following environment variables, and test importers use the following field names:

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:25%">Field name</th>
      <th style="width:30%">Environment variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        field_name: "run_env[branch]",
        env_variable: "BUILDKITE_BRANCH",
        description: "The branch or reference for this build."
      },
      {
        field_name: "run_env[commit_sha]",
        env_variable: "BUILDKITE_COMMIT",
        description: "The commit hash for the head of the branch."
      },
      {
        field_name: "run_env[job_id]",
        env_variable: "BUILDKITE_JOB_ID",
        description: "The UUID of the job."
      },
      {
        field_name: "run_env[key]",
        env_variable: "BUILDKITE_BUILD_ID",
        description: "The UUID for the build."
      },
      {
        field_name: "run_env[message]",
        env_variable: "BUILDKITE_MESSAGE",
        description: "The commit message for the head of the branch."
      },
      {
        field_name: "run_env[number]",
        env_variable: "BUILDKITE_BUILD_NUMBER",
        description: "The build number."
      },
      {
        field_name: "run_env[url]",
        env_variable: "BUILDKITE_BUILD_URL",
        description: "The URL for the build on Buildkite."
      }
    ].each do |field| %>
      <tr>
        <td>
          <code><%= field[:field_name] %></code>
        </td>
        <td>
          <code><%= field[:env_variable] %></code>
        </td>
        <td>
          <%= field[:description] %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## CircleCI

During CircleCI workflow runs, test collectors upload information from the following environment variables, and test importers use the following field names:

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:25%">Field name</th>
      <th>Environment variable(s)</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        field_name: "run_env[branch]",
        env_variable: "CIRCLE_BRANCH",
        description: "The branch or reference being built."
      },
      {
        field_name: "run_env[commit_sha]",
        env_variable: "CIRCLE_SHA1",
        description: "The commit hash for the head of the branch."
      },
      {
        field_name: "run_env[key]",
        env_variable: "CIRCLE_WORKFLOW_ID",
        env_variable_2: "CIRCLE_BUILD_NUM",
        description: "The unique identifier for the workflow run, and the number for the job, each separated by a hyphen. That is, <code>$CIRCLE_WORKFLOW_ID-$CIRCLE_BUILD_NUM</code>."
      },
      {
        field_name: "run_env[url]",
        env_variable: "CIRCLE_BUILD_URL",
        description: "The URL for the job on CircleCI."
      }
    ].each do |field| %>
      <tr>
        <td>
          <code><%= field[:field_name] %></code>
        </td>
        <td>
          <code><%= field[:env_variable] %></code>
          <% if field[:env_variable_2] %>
            <br/>
            <code><%= field[:env_variable_2] %></code>
          <% end %>
        </td>
        <td>
          <%= field[:description] %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## GitHub Actions

During GitHub Actions workflow runs, test collectors upload information from the following environment variables, and test importers use the following field names:

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:25%">Field name</th>
      <th>Environment variable(s)</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        field_name: "run_env[branch]",
        env_variable: "GITHUB_REF_NAME",
        description: "The ref (branch or tag) that triggered the workflow run."
      },
      {
        field_name: "run_env[commit_sha]",
        env_variable: "GITHUB_SHA",
        description: "The commit hash for the head of the branch."
      },
      {
        field_name: "run_env[key]",
        env_variable: "GITHUB_ACTION",
        env_variable_2: "GITHUB_RUN_NUMBER",
        env_variable_3: "GITHUB_RUN_ATTEMPT",
        description: "The name of the action running or its step ID, the cumulative number of runs for the workflow, and the numbered attempt of the workflow run, each separated by a hyphen. That is, <code>$GITHUB_ACTION-$GITHUB_RUN_NUMBER-$GITHUB_RUN_ATTEMPT</code>."
      },
      {
        field_name: "run_env[number]",
        env_variable: "GITHUB_RUN_ID",
        description: "The unique number for the workflow run."
      },
      {
        field_name: "run_env[url]",
        env_variable: "GITHUB_REPOSITORY",
        description: "The repository owner and repository name."
      }
    ].each do |field| %>
      <tr>
        <td>
          <code><%= field[:field_name] %></code>
        </td>
        <td>
          <code><%= field[:env_variable] %></code>
          <% if field[:env_variable_2] && field[:env_variable_3] %>
            <br/>
            <code><%= field[:env_variable_2] %></code>
            <br/>
            <code><%= field[:env_variable_3] %></code>
          <% end %>
        </td>
        <td>
          <%= field[:description] %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Other CI providers

If you're using other CI providers (or [containers](#containers-and-test-collectors)), then set environment variables for test collectors to gather information about your builds and tests.
If you don't set these environment variables, then Test Engine lacks the details needed to produce useful reports.

Each environment variable corresponds to a `run_env` key in the payload `https://analytics-api.buildkite.com/v1/uploads`. Read [Importing JSON](/docs/test-engine/test-collection/importing-json) to learn how these keys are used to make API calls.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:25%">Field name</th>
      <th style="width:35%">Environment variable</th>
      <th style="width:40%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% TEST_ENGINE_RUN_ENV['keys'].each do |key| -%>
      <tr>
        <td><code>run_env[<%= key['name'] %>]</code></td>
        <td><code><%= key['environment_variable'] %></code></td>
        <td>
          <%= render_markdown(text: key['description']) %>
          Examples:
          <%= key['examples'].map{|example| "<code>#{example}</code>"}.join(', ') %>
        </td>
      </tr>
    <% end -%>
  </tbody>
</table>
