# GitHub Actions

With the help of the [Buildkite migration tool](/docs/pipelines/migration/tool), you can start converting your GitHub Actions workflows into Buildkite pipelines. This page lists the Buildkite migration tool's currently supported, partially supported, and unsupported attributes for translating from GitHub Actions workflows to Buildkite pipelines.

> 📘
> The Buildkite migration tool does not currently support [GitHub secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) stored within GitHub organizations or repositories (such as `{{ secrets.FOO }}`).
> A core principle of Buildkite's [Self-hosted (hybrid) architecture](/docs/pipelines/architecture) is that secrets and sensitive data are decoupled from the core SaaS platform and stay in the customer's environments and are not seen or stored.
> Using a [secret storage service](/docs/pipelines/security/secrets/managing) such as [Hashicorp Vault](https://www.vaultproject.io/) or [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), along with their respective [plugin](https://github.com/buildkite-plugins) can be configured to read and utilize secrets within Buildkite pipelines. The [S3 Secrets Buildkite plugin](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks) can be installed within a Buildkite agent - and this service is automatically included within [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) setups to expose secrets from S3 into the jobs of Buildkite Pipelines' builds.

## Using the Buildkite migration tool with GitHub Actions

To start converting your GitHub Actions pipelines to the Buildkite format:

1. Go to the [interactive web tool](https://buildkite.com/resources/migrate/) page.
1. Select **GitHub Actions** in the UI.
1. Paste your GitHub Actions pipeline configuration.
1. Click **Convert**.
1. See the converted pipeline configuration on the **Buildkite Pipeline** side of the tool.

For example, you would like to convert the following GitHub Actions pipeline configuration:

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

This is the output that the Buildkite migration tool is going to provide:

```yml
---
steps:
- commands:
  - "# action actions/checkout@v4 is not necessary in Buildkite"
  - echo '~~~ Install dependencies'
  - npm install
  plugins:
  - docker#v5.10.0:
      image: node:18
  agents:
    runs-on: ubuntu-latest
  label: ":github: build"
  key: build
  branches: main
```

You will see the following in the Buildkite migration tool UI during the conversion of the example configuration:

<%= image "migration-tool-gha.png", alt: "Converting a GitHub Actions pipeline in Buildkite migration tool's web UI" %>

You might need to adjust the syntax of the resulting converted output to make it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) syntax used in Buildkite Pipelines.

> 📘
> Remember that not all the features of GitHub Actions can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting GitHub Actions pipelines to Buildkite Pipelines.

## Concurrency

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `concurrency` | No | [Buildkite concurrency groups](/docs/pipelines/controlling-concurrency#concurrency-groups) don't apply to whole pipelines but rather to individual steps so there is no direct translation of this configuration. Refer to the support of the job-level configuration for more information: [`jobs.<id>.concurrency`](#jobs). |

## Defaults

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `defaults.run` | No | Buildkite pipeline definitions allow for common pipeline configurations to be applied with [YAML anchors](/docs/plugins/using#using-yaml-anchors-with-plugins), as well as setting up customised [agent](/docs/agent/v3/hooks#agent-lifecycle-hooks) and [job](/docs/agent/v3/hooks#job-lifecycle-hooks) lifecycle hooks. |

## Environment

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `env` | Yes | Environment variables that are defined at the top of a workflow will be transition to [build level](/docs/pipelines/environment-variables#environment-variable-precedence) environment variables in the generated Buildkite pipeline |

## Jobs

> 📘
> When Buildkite builds are run, each created command step inside the pipeline is ran as a [job](/docs/pipelines/configure/defining-steps#job-states) that will be distributed and assigned to the matching agents meeting their specific queue and tag [targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents). Each job is run within its own separate environment, with potentially different environment variables (for example, those defined at the [step](/docs/pipelines/configure/step-types/command-step#command-step-attributes) level) and is not guaranteed to run on the same agent depending on targeting rules specified and the agent fleet setup.

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `jobs.<id>.concurrency` | Partially | The `group` name inside a `concurrency` definition inside of a job maps to the `concurrency_group` [key](/docs/pipelines/controlling-concurrency#concurrency-groups) available within Buildkite.<br/><br/>The `cancel-in-progress` optional value maps to the Buildkite pipeline setting of [Cancel Intermediate Builds](/docs/pipelines/skipping#cancel-running-intermediate-builds).<br/><br/>Buildkite Pipelines also allow an upper limit on how many jobs are created through a single step definition with the `concurrency` key: which is set as `1` by default (there isn't a translatable key within a GitHub Action workflow). |
| `jobs.<id>.env` | Yes | Environment variables defined within the context of each of a workflow's `jobs` are transitioned to [step level](/docs/pipelines/environment-variables#runtime-variable-interpolation) environment variables. |
| `jobs.<id>.runs-on` | Yes | This attribute is mapped to the agent targeting [tag](/docs/agent/v3/queues#targeting-a-queue) `runs-on`. Jobs that target custom `tag` names will have a `queue` target of `default`. |
| `jobs.<id>.steps`| Yes | Steps that make up a particular action's `job`. |
| `jobs.<id>.steps.env` | Yes | Environment variables that are defined at `step` level are translated as a variable definition within the `commands` of a [command step](/docs/pipelines/configure/step-types/command-step). |
| `jobs.<id>.steps.run` | Yes | The commands (must be shorter than 21,000 characters) that make up a particular job. Each `run` is translated to a separate command inside of the output `commands` block of its generated Buildkite command step. |
| `jobs.<id>.steps.strategy` | Yes | Allows for the conversion of a step's `strategy` (matrix) to create multiple jobs of a combination of values. |
| `jobs.<id>.steps.strategy.matrix` | Yes | A `matrix` key inside of a step's `strategy` will be translated to a [Buildkite build matrix](/docs/pipelines/build-matrix). |
| `jobs.<id>.steps.strategy.matrix.include` | Yes| Key-value pairs to add in the generated [matrix](/docs/pipelines/build-matrix)'s combinations. |
| `jobs.<id>.steps.strategy.matrix.exclude`| Yes | Key-value pairs to exclude in the generated [matrix](/docs/pipelines/build-matrix)'s combinations (`skip`). |
| `jobs.<id>.steps.uses` | No | `uses` defines a separate action to use within the context of a action's job. Currently isn't supported. |

## Name

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `name` | No | The `name` key sets the name of the action as it will appear in the GitHub repository's **Actions** tab. When creating a Buildkite pipeline, its name is set through the UI when a pipeline is first created - and can be altered through the pipeline settings, or via the [REST](/docs/apis/rest-api/pipelines#update-a-pipeline) or [GraphQL](/docs/apis/graphql/schemas/input-object/pipelineupdateinput) APIs. |

## On
| Key | Supported | Notes |
| --- | ---------- | ----- |
| `on` | No | The `on` key allows for triggering a GitHub Action workflow. In Buildkite pipelines this capability is defined within a `trigger` [step](/docs/pipelines/configure/step-types/trigger-step) - where utilized within a pipeline, will create a build on the specified pipeline with additional properties. |

## Permissions

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `permissions` | No | [API Access Tokens](/docs/apis/managing-api-tokens) can be used within the context of a pipelines' build to interact with various Buildkite resources such as pipelines, artifacts, users, test suites, and more. Each token has a specified [token scope](/docs/apis/managing-api-tokens#token-scopes) that applies to interactions with the [REST](/docs/apis/rest-api) API, and can be configured with permission to interact with Buildkite's [GraphQL](/docs/apis/graphql-api) API. The `permissions` key allows for the interaction with commit `statuses`. For Buildkite to publish commit statuses for builds based on commits and pull requests on pipeline builds, the [GitHub App](/docs/integrations/github#connect-your-buildkite-account-to-github-using-the-github-app) must be added to the respective GitHub organization for the statuses to appear based on a build's outcome. The GitHub App can be configured with access to all or a select number of repositories within a GitHub organization. |

## Run name

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `run-name` | No | Build messages in Buildkite Pipelines are set as the `BUILDKITE_MESSAGE` environment variable (commit message from source control). Build messages can be set in manual build creation or by using [REST](/docs/apis/rest-api/builds#create-a-build) or [GraphQL](/docs/apis/graphql/schemas/mutation/buildcreate) APIs. |
