# GitHub Actions

This page list the Buildkite Migration tool's currently supported, partially supported and unsupported properties in translation of GitHub Action workflows to Buildkite pipelines.

> 📘
> The Buildkite Migration tool does not currently support [GitHub secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) stored within GitHub organizations or repositories (such as `{{ secrets.FOO }}`).<br/><br/>A core principle of the Buildkite's [Self-hosted (hybrid) architecture](/docs/pipelines/architecture) is that secrets and sensitive data are decoupled from the core SaaS platform and remains on customer/tenant environments and are not seen or stored.<br/><br/>The utilisation of a [secret storage service](/docs/pipelines/security/secrets/managing) such as [Hashicorp Vault](https://www.vaultproject.io/) or [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), accompanied by the use of their respective [plugin](https://github.com/buildkite-plugins) can be configured to read and utilize secrets within Buildkite pipelines. Additionally, the [S3 Secrets Buildkite plugin](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks) can be installed within a Buildkite agent - this service automatically included within [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) setups to expose secrets from S3 into the jobs of a Buildkite pipelines' builds.

## Concurrency

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `concurrency` | No | [Buildkite concurrency groups](/docs/pipelines/controlling-concurrency#concurrency-groups) don't apply to whole pipelines but steps so there is no direct translation of this configuration. Refer to the support of the job-level configuration for more information: [`jobs.<id>.concurrency`](#jobs). |

## Defaults

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `defaults.run` | No | Buildkite pipeline definitions allow for common pipeline configuration to be applied with [YAML anchors](/docs/plugins/using#using-yaml-anchors-with-plugins), as well as setting up customised [agent](/docs/agent/v3/hooks#agent-lifecycle-hooks) and [job](/docs/agent/v3/hooks#job-lifecycle-hooks) lifecycle hooks. |

## Environment

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `env` | Yes | Environment variables that are defined at the top of a workflow will be transition to [build level](/docs/pipelines/environment-variables#environment-variable-precedence) environment variables in the generated Buildkite pipeline |

## Jobs

> 📘
> > When Buildkite builds are run; each created command step inside the pipeline is ran as a [job](/docs/pipelines/defining-steps#job-states) that will be distributed and assigned to the matching agents meeting its specific queue and/or tag [targeting](/docs/pipelines/defining-steps#targeting-specific-agents). Each job is run within its own separate environment, with potentially different environment variables (for example those defined at [step](/docs/pipelines/command-step#command-step-attributes) level) - and is not always guaranteed to run on the same agent depending on targeting rules specified/agent fleet setup.

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `jobs.<id>.concurrency` | Partially | The `group` name inside a `concurrency` definition inside a job maps to the `concurrency_group` [key](/docs/pipelines/controlling-concurrency#concurrency-groups) available within Buildkite.<br/><br/>The `cancel-in-progress` optional value maps to the Buildkite pipeline setting of [Cancel Intermediate Builds](/docs/pipelines/skipping#cancel-running-intermediate-builds).<br/><br/>Buildkite also allows a upper limit on how much jobs are created through a single step definition with the `concurrency` key: which is set as `1` by default (there isn't a translatable key within a GitHub Action workflow). |
| `jobs.<id>.env` | Yes | Environment variables defined within the context of each of a workflow's `jobs` are transitioned to [step level](/docs/pipelines/environment-variables#runtime-variable-interpolation) environment variables. |
| `jobs.<id>.runs-on` | Yes | This attribute is mapped to the agent targeting [tag](/docs/agent/v3/queues#targeting-a-queue) `runs-on`. Jobs that target custom `tag` names will have a `queue` target of `default`. |
| `jobs.<id>.steps`| Yes | Steps that make up a particular action's `job`. |
| `jobs.<id>.steps.env` | Yes | Environment variables that are defined at `step` level are translated as a variable definition within the `commands` of a Buildkite [command step](/docs/pipelines/command-step). |
| `jobs.<id>.steps.run` | Yes | The commands (less than 21,000 characters) that make up a particular job. Each `run` is translated to a separate command inside of the output `commands` block of its generated Buildkite command step. |
| `jobs.<id>.steps.strategy` | Yes | Allows for the conversion of a step's `strategy` (matrix) to create multiple jobs of a combination of values. |
| `jobs.<id>.steps.strategy.matrix` | Yes | A `matrix` key inside of a step's `strategy` will be translated to a [Buildkite build matrix](/docs/pipelines/build-matrix). |
| `jobs.<id>.steps.strategy.matrix.include` | Yes| Key/value pairs to add in the generated [matrix](/docs/pipelines/build-matrix)'s combinations. |
| `jobs.<id>.steps.strategy.matrix.exclude`| Yes | Key/value pairs to exclude in the generated [matrix](/docs/pipelines/build-matrix)'s combinations (`skip`). |
| `jobs.<id>.steps.uses` | No | `uses` defines a separate action to use within the context of a action's job, and is currently not supported. |

## Name

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `name` | No | The `name` key sets the name of the action as it will appear in the GitHub repository's "Actions" tab. When creating a Buildkite pipeline, it's name is set through the UI when first creating the pipeline - and can be altered within its pipeline settings, or via the [REST](/docs/apis/rest-api/pipelines#update-a-pipeline) or [GraphQL](/docs/apis/graphql/schemas/input-object/pipelineupdateinput) APIs. |

## On
| Key | Supported | Notes |
| --- | ---------- | ----- |
| `on` | No | The `on` key allows for triggering a GitHub Action workflow. In Buildkite pipelines - this capability is defined within a `trigger` [step](/docs/pipelines/trigger-step) - where utilized within a pipeline, will create a build on the specified pipeline with additional properties. |

## Permissions

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `permissions` | No | [API Access Tokens](/docs/apis/managing-api-tokens) can be used within the context of a pipelines' build to interact with various Buildkite resources such as pipelines, artifacts, users, Test suites and more. Each token has a specified [token scope](/docs/apis/managing-api-tokens#token-scopes) that applies to interactions with the [REST](/docs/apis/rest-api) API, and can be configured with permission to interact with Buildkite's [GraphQL](/docs/apis/graphql-api) API. The `permissions` key allows for the interaction with commit `statuses`. For Buildkite to publish commit statuses for builds based on commits and pull requests on pipeline builds: the [GitHub App](/docs/integrations/github#connect-your-buildkite-account-to-github-using-the-github-app) must be added to the respective GitHub organization for statuses to appear based on a build's outcome. The GitHub App can be configured with access to all repositories within a GitHub organization - or a select number. |

## Run name

| Key | Supported | Notes |
| --- | ---------- | ----- |
| `run-name` | No | Build messages in Buildkite are set as the `BUILDKITE_MESSAGE` environment variable (commit message from source control). Build messages are settable in manual build creation, and via both [REST](/docs/apis/rest-api/builds#create-a-build) and [GraphQL](/docs/apis/graphql/schemas/mutation/buildcreate) APIs. |
