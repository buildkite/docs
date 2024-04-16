# CI environments

Buildkite Test Analytics collectors automatically detect common continuous integration (CI) environments.
If available, test collectors gather information about your test runs, such as branch names and build IDs.
Test collectors gather information from the following CI environments:

- [Buildkite](/docs/test-analytics/ci-environments#buildkite)
- [CircleCI](/docs/test-analytics/ci-environments#circleci)
- [GitHub Actions](/docs/test-analytics/ci-environments#github-actions)

If you run test collectors inside [containers](/docs/test-analytics/ci-environments#containers-and-test-collectors) or use another CI system, you must set variables to report your CI details to Buildkite.

If you're not using a test collector, see [Importing JSON](/docs/test-analytics/importing-json) and [Importing JUnit XML](/docs/test-analytics/importing-junit-xml) to learn how to provide run environment data.

## Recommended environment variables

If you're manually providing environment variables, we strongly recommend setting the following variables:

- `run_env[key]`: A required variable that sends the UUID for the build, letting you group batches of data by the key.
- `run_env[branch]`: Sends the branch or reference for this build, enabling you to filter data by branch.
- `run_env[url]`: Provides the URL for the build on your CI provider, giving you a handy link back to the CI build.
- `run_env[commit_sha]`: Sends the commit hash for the head of the branch, enabling automatic flaky test detection in your builds.
- `run_env[message]`: Forwards the commit message for the head of the branch, helping you identify different runs more easily.

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

| Field name             | Environment variable     | Description                                   |
|------------------------|--------------------------|-----------------------------------------------|
| `run_env[branch]`      | `BUILDKITE_BRANCH`       | the branch or reference for this build        |
| `run_env[key]`         | `BUILDKITE_BUILD_ID`     | the UUID for the build                        |
| `run_env[number]`      | `BUILDKITE_BUILD_NUMBER` | the build number                              |
| `run_env[url]`         | `BUILDKITE_BUILD_URL`    | the URL for the build on Buildkite            |
| `run_env[commit_sha]`  | `BUILDKITE_COMMIT`       | the commit hash for the head of the branch    |
| `run_env[job_id]`      | `BUILDKITE_JOB_ID`       | the job UUID                                  |
| `run_env[message]`     | `BUILDKITE_MESSAGE`      | the commit message for the head of the branch |
{: class="responsive-table"}

## CircleCI

During CircleCI workflow runs, test collectors upload information from the following environment variables, and test importers use the following field names:

| Field name            | Environment variable | Description                                |
|-----------------------|----------------------|--------------------------------------------|
| `run_env[branch]`     | `CIRCLE_BRANCH`      | the branch or reference being built        |
| See note below        | `CIRCLE_BUILD_NUM`   | the number for the job                     |
| `run_env[url]`        | `CIRCLE_BUILD_URL`   | the URL for the job on CircleCI            |
| `run_env[commit_sha]` | `CIRCLE_SHA1`        | the commit hash for the head of the branch |
| See note below        | `CIRCLE_WORKFLOW_ID` | the unique identifier for the workflow run |
{: class="responsive-table"}

For CircleCI runs:

```
run_env[key]=$CIRCLE_WORKFLOW_ID-$CIRCLE_BUILD_NUM
```

## GitHub Actions

During GitHub Actions workflow runs,test collectors upload information from the following environment variables, and test importers use the following field names:

| Field name            | Environment variable | Description                                             |
|-----------------------|----------------------|---------------------------------------------------------|
| See note below        | `GITHUB_ACTION`      | the name of the action running or its step ID           |
| `run_env[branch]`     | `GITHUB_REF_NAME`    | the ref (branch or tag) that triggered the workflow run |
| `run_env[url]`        | `GITHUB_REPOSITORY`  | the repository owner and repository name                |
| See note below        | `GITHUB_RUN_ATTEMPT` | the numbered attempt of the workflow run                |
| `run_env[commit_sha]` | `GITHUB_SHA`         | the commit hash for the head of the branch              |
| See note below        | `GITHUB_RUN_ID`      | the unique number for the workflow run                  |
| `run_env[number]`     | `GITHUB_RUN_NUMBER`  | the cumulative number of runs for the workflow          |
{: class="responsive-table"}

For GitHub Action runs:

```
run_env[key]=$GITHUB_ACTION-$GITHUB_RUN_NUMBER-$GITHUB_RUN_ATTEMPT
```

## Other CI providers

If you're using other CI providers (or [containers](#containers-and-test-collectors)), then set environment variables for test collectors to gather information about your builds and tests.
If you don't set these environment variables, then Test Analytics lacks the details needed to produce useful reports.

Each environment variable corresponds to a `run_env` key in the payload `https://analytics-api.buildkite.com/v1/uploads`. Read [Importing JSON](/docs/test-analytics/importing-json) to learn how these keys are used to make API calls.

<table class="responsive-table">
  <thead>
    <tr>
      <th>Field name</th>
      <th>Environment variable</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <% TEST_ANALYTICS_RUN_ENV['keys'].each do |key| -%>
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
