# GitHub Actions

The [Buildkite migration tool](/docs/pipelines/migration/tool) helps you convert your GitHub Actions workflows into Buildkite pipelines. This page lists the Buildkite migration tool's supported, partially supported, and unsupported GitHub Actions keys when translating from GitHub Actions workflows to Buildkite pipelines.

For any partially supported and unsupported **Key**s listed in the tables on this page, you should follow the instructions provided in their relevant **Notes**, for details on how to successfully complete their translation into a working Buildkite pipeline.

> 📘
> The Buildkite migration tool currently does not support [GitHub secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) stored within GitHub organizations or repositories (such as `{{ secrets.FOO }}`).
> A core principle of Buildkite's [self-hosted (hybrid) architecture](/docs/pipelines/architecture#self-hosted-hybrid-architecture) is that secrets and sensitive data stay in the customer's environments, which in turn are decoupled from and not seen by the core Buildkite Pipelines SaaS control plane.
> Using a [secret storage service](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service) such as [Hashicorp Vault](https://www.vaultproject.io/) or [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), along with their respective plugin, can be configured to read and utilize secrets within Buildkite pipelines. The [S3 Secrets Buildkite plugin](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks) can be installed within a Buildkite agent—this service is automatically included within [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) setups to expose secrets from S3 into the jobs of a Buildkite pipeline's builds.

## Using the Buildkite migration tool with GitHub Actions

To start converting your GitHub Actions workflow into Buildkite Pipelines format:

1. Open the [Buildkite migration interactive web tool](https://buildkite.com/resources/migrate/) in a new browser tab.
1. Ensure **GitHub Actions** is selected at the top of the left panel.
1. Copy your GitHub Actions workflow configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

For example, when converting the following example GitHub Actions workflow configuration:

```yml
name: CI

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'

    - name: Install dependencies
      run: npm install
```

The Buildkite migration tool should translate this to the following output:

```yml
---
steps:
- commands:
  - "# action actions/checkout@v4 is not necessary in Buildkite"
  - echo '~~~ Install dependencies'
  - npm install
  plugins:
  - docker#v5.13.0:
      image: node:18
  agents:
    runs-on: ubuntu-latest
  label: "\:github\: build"
  key: build
  branches: main
```

The Buildkite migration tool interface should look similar to this:

<%= image "migration-tool-gha.png", alt: "Converting a GitHub Actions pipeline in Buildkite migration tool's web UI" %>

You might need to adjust the converted Buildkite pipeline output to ensure it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) used in Buildkite Pipelines.

> 📘
> Remember that not all the features of GitHub Actions can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting GitHub Actions workflows to Buildkite pipelines.

## Concurrency

| <div style="width: 90px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `concurrency` | No | Buildkite Pipelines' [concurrency groups](/docs/pipelines/controlling-concurrency#concurrency-groups) don't apply to whole pipelines but rather to individual steps, so there is no direct translation of this configuration. Refer to the support of the job-level configuration for more information: [`jobs.<id>.concurrency`](#jobs). |
{: class="responsive-table"}

## Defaults

| <div style="width: 100px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `defaults.run` | No | Buildkite pipeline definitions allow for common pipeline configurations to be applied with [YAML anchors](/docs/plugins/using#using-yaml-anchors-with-plugins), as well as setting up customised [agent](/docs/agent/v3/hooks#agent-lifecycle-hooks) and [job](/docs/agent/v3/hooks#job-lifecycle-hooks) lifecycle hooks. |
{: class="responsive-table"}

## Environment

| <div style="width: 50px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `env` | Yes | Environment variables that are defined at the top of a workflow will be translated to [build-level environment variables](/docs/pipelines/environment-variables#environment-variable-precedence) in the generated Buildkite pipeline. |
{: class="responsive-table"}

## Jobs

When Buildkite pipelines are built, each command step inside the pipeline is ran as a [job](/docs/pipelines/configure/defining-steps#job-states) that will be distributed and assigned to the matching agents meeting their specific queue and tag [targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents). Each job is run within its own separate environment, with potentially different environment variables (for example, those defined at the [step](/docs/pipelines/configure/step-types/command-step#command-step-attributes) level) and is not guaranteed to run on the same agent depending on targeting rules and the agent fleet setup.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:30%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:60%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "jobs.&lt;id&gt;.concurrency",
        "supported": "Partially",
        "notes": "The `group` name inside a `concurrency` definition inside of a job maps to the `concurrency_group` [key](/docs/pipelines/controlling-concurrency#concurrency-groups) available within Buildkite Pipelines.<br/><br/>The `cancel-in-progress` optional value maps to the Buildkite pipeline setting of [Cancel Intermediate Builds](/docs/pipelines/skipping#cancel-running-intermediate-builds).<br/><br/>Buildkite Pipelines also allow setting an upper limit on how many jobs are created through a single step definition with the `concurrency` key which is set as `1` by default (there isn't a translatable counterpart to the \"key\" parameter within a GitHub Action workflow)."
      },
      {
        "key": "jobs.&lt;id&gt;.env",
        "supported": "Yes",
        "notes": "Environment variables defined within the context of each of a workflow's `jobs` are translated to [step-level environment variables](/docs/pipelines/environment-variables#runtime-variable-interpolation)."
      },
      {
        "key": "jobs.&lt;id&gt;.runs-on",
        "supported": "Yes",
        "notes": "This attribute is mapped to the agent targeting [tag](/docs/agent/v3/targeting/queues#targeting-a-queue) `runs-on`. Jobs that target custom `tag` names will have a `queue` target of `default`."
      },
      {
        "key": "jobs.&lt;id&gt;.steps",
        "supported": "Yes",
        "notes": "Steps that make up a particular action's `job`."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.env",
        "supported": "Yes",
        "notes": "Environment variables that are defined at `step` level are translated as a variable definition within the `commands` of a [command step](/docs/pipelines/configure/step-types/command-step)."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.run",
        "supported": "Yes",
        "notes": "The commands (must be shorter than 21,000 characters) that make up a particular job. Each `run` is translated to a separate command inside of the output `commands` block of its generated Buildkite Pipelines command step."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.strategy",
        "supported": "Yes",
        "notes": "Allows for the conversion of a step's `strategy` (matrix) to create multiple jobs from a combination of values."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.strategy.matrix",
        "supported": "Yes",
        "notes": "A `matrix` key inside of a step's `strategy` will be translated to a [Buildkite build matrix](/docs/pipelines/build-matrix)."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.strategy.matrix.include",
        "supported": "Yes",
        "notes": "Key-value pairs to add as combinations (using [`adjustments.with`](/docs/pipelines/configure/workflows/build-matrix#adding-combinations-to-the-build-matrix)) to the generated [build matrix](/docs/pipelines/configure/workflows/build-matrix)'s combinations."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.strategy.matrix.exclude",
        "supported": "Yes",
        "notes": "Key-value pairs to exclude from being processed (using [`skip`](/docs/pipelines/configure/workflows/build-matrix#excluding-combinations-from-the-build-matrix)) from the generated [build matrix](/docs/pipelines/build-matrix)'s combinations."
      },
      {
        "key": "jobs.&lt;id&gt;.steps.uses",
        "supported": "No",
        "notes": "`uses` defines a separate action to use within the context of a GitHub Action's job. This key currently isn't supported."
      }
    ].select { |field| field[:key] }.each do |field| %>
      <tr>
        <td>
          <code><%= field[:key] %></code>
        </td>
        <td>
          <p><%= field[:supported] %></p>
        </td>
        <td>
          <p><%= render_markdown(text: field[:notes]) %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Name

| <div style="width: 50px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `name` | No | The `name` key sets the name of the action as it will appear in the GitHub repository's **Actions** tab. When creating a Buildkite pipeline, its name is usually set through the Buildkite interface when a pipeline is first created, and can be altered through the pipeline settings, or using the [REST](/docs/apis/rest-api/pipelines#update-a-pipeline) or [GraphQL](/docs/apis/graphql/schemas/input-object/pipelineupdateinput) APIs. |
{: class="responsive-table"}

## On

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `on` | No | The `on` key defines the pipeline trigger in a GitHub Action workflow. In Buildkite Pipelines, this is a Buildkite interface setting in the pipeline's **Settings** > **GitHub** page > **GitHub Settings** section. |
{: class="responsive-table"}

## Permissions

| <div style="width: 90px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `permissions` | No | [API Access Tokens](/docs/apis/managing-api-tokens) can be used within the context of a pipeline's build to interact with various Buildkite resources such as pipelines, artifacts, users, Test Suites, and more. Each access token has a specified set of [token scopes](/docs/apis/managing-api-tokens#token-scopes) that applies to interactions with the [REST](/docs/apis/rest-api) API, and can be configured with a permission to interact with Buildkite's [GraphQL](/docs/apis/graphql-api) API. The `permissions` key allows for the interaction with commit `statuses`. The [Buildkite GitHub App](/docs/integrations/github#connect-your-buildkite-account-to-github-using-the-github-app) must be added to the respective GitHub organization to allow Buildkite Pipelines to publish commit statuses for builds based on commits and pull requests on pipeline builds and for the statuses to appear based on a build's outcome. The GitHub App can be configured with access to all or a select number of repositories within a GitHub organization. |
{: class="responsive-table"}

## Run name

| <div style="width: 80px;">Key</div> | Supported | Notes |
| --- | ---------- | ----- |
| `run-name` | No | Build messages in Buildkite Pipelines are set as the `BUILDKITE_MESSAGE` environment variable (commit message from source control). Build messages can be set in when creating new builds manually, or by using the [REST](/docs/apis/rest-api/builds#create-a-build) or [GraphQL](/docs/apis/graphql/cookbooks/builds#create-a-build-on-a-pipeline) APIs. |
{: class="responsive-table"}
