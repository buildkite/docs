# CircleCI

With the help of the [Buildkite migration tool](/docs/pipelines/migration/tool), you can start converting your CircleCI pipelines into Buildkite pipelines. This page lists the Buildkite migration tool's currently supported, partially supported, and unsupported attributes for translating from CircleCI pipelines to Buildkite pipelines.

## Using the Buildkite migration tool with CircleCI

To start converting your CircleCI pipelines to the Buildkite format:

1. Go to the [interactive web tool](https://buildkite.com/resources/migrate/) page.
1. Select **CircleCI** in the UI.
1. Paste your CircleCI pipeline configuration.
1. Click **Convert**.
1. See the converted pipeline configuration on the **Buildkite Pipeline** side of the tool.

For example, if you would like to convert the following CircleCI pipeline configuration:

```yml
version: 2.1

jobs:
  build:
    docker:
      - image: cimg/node:18.20

    steps:
      - checkout

      - run:
          name: Install dependencies
          command: npm install

workflows:
  build-workflow:
    jobs:
      - build
```

This is the output that the Buildkite migration tool is going to provide:

```yml
---
steps:
- commands:
  - "# No need for checkout, the agent takes care of that"
  - echo '~~~ Install dependencies'
  - npm install
  plugins:
  - docker#v5.10.0:
      image: cimg/node:18.20
  agents:
    executor_type: docker
  key: build
```

You will see the following in the Buildkite migration tool UI during the conversion of the example configuration:

<%= image "migration-tool-circleci.png", alt: "Converting a CircleCI pipeline in Buildkite migration tool's web UI" %>

> 📘 Local API use
> While the web-based migration tool provides a convenient interface for converting your existing pipelines, you can also run the Buildkite migration tool [locally via its HTTP API](/docs/pipelines/migration/tool#local-API-based-version). The local version offers the same conversion capabilities as the web interface.

You might need to adjust the syntax of the resulting converted output to make it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) syntax used in Buildkite Pipelines.

The Buildkite migration tool supports the use of YAML aliases - reusable configuration snippets to be applied to specific points in a CircleCI pipeline. These are defined with a `&` (anchor) within the top-level `aliases` key and substituted into CircleCI pipeline configuration with `*` (for example, `*tests`). Configuration defined by an alias will be respected and parsed at the specified section of the pipeline. Also note that the anchors will be expanded in the resulting converted pipeline.

> 📘
> Remember that not all the features of CircleCI can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting CircleCI pipelines to Buildkite Pipelines.

## Logical operators (helpers)

| Key | Supported | Notes |
| --- | --- | --- |
| `and` | Partially | Logical operator for denoting all inputs required to be true. Supported alongside the `when` key within setting up conditional `workflow` runs. |
| `or` | Partially | Logical operator for describing whether any of the inputs are true. Supported alongside the `when` key within setting up conditional `workflow` runs. |
| `not` | Partially | Logical operator for negating input. Supported alongside the `when` key within setting up conditional `workflow` runs. |

## Commands

| Key | Supported | Notes |
| --- | --- | --- |
| `commands` | Yes | A `command` defined in a CircleCI pipeline is a reusable set of instructions with parameters that can be inserted into required `job` executions. Commands can have their own lists of `steps` that are translated through to the generated [command step](/docs/pipelines/configure/step-types/command-step)'s `commands`. If a `command` contains a `parameters` key, those parameters are respected when used in jobs and workflows. When not specified otherwise, the default values are used. |

## Executors

| Key | Supported | Notes |
| --- | --- | --- |
| `executors` | Yes | The `executor` key defined at the top level in a CircleCI workflow is mapped to the use of the `executor` key specified within a specific `job`. Supported execution environments include `machine`, `docker`, `macos`, and `windows`. Further information can be found in the _Jobs_ table below. The execution environment in Buildkite Pipelines is specified with each environment's applied [tags](/docs/agent/v3/cli-start#setting-tags) in their generated [command step](/docs/pipelines/configure/step-types/command-step), which can be [targeted](/docs/pipelines/configure/defining-steps#targeting-specific-agents) when creating builds. |

## Jobs

### General

| Key | Supported | Notes |
| --- | --- | --- |
| `jobs` | Yes | A collection of steps that run on a single worker unit whether directly on a host or on a virtualized host (for example, within a Docker container). Orchestrated with `workflows`. |
| `jobs.<name>` | Yes | Named, individual `jobs` that make up a part of a given `workflow`. |
| `jobs.<name>.environment` | Yes | The `job`-level environment variables of a CircleCI pipeline. Applied in the generated [command step](/docs/pipelines/configure/step-types/command-step) as [step-level environment variables](/docs/pipelines/environment-variables#runtime-variable-interpolation) with the `env` key. |
| `jobs.<name>.parallelism` | No | A `parallelism` parameter (if greater than `1` is defined) will create a separate execution environment and will run the `steps` of the specific `job` in parallel. In Buildkite Pipelines, a similar `parallelism` key can be set to a [command step](/docs/pipelines/configure/step-types/command-step), which will run the defined `command` over separate jobs (sharing the same agent [queues](/docs/agent/v3/queues#setting-an-agents-queue) and [tags](/docs/agent/v3/cli-start#setting-tags) targeting). |
| `jobs.<name>.parameters` | Yes | Reusable keys that are used within `step` definitions within a `job`. Default parameters that are specified in a `parameters` block are passed through into the [command step](/docs/pipelines/configure/step-types/command-step)'s `commands` if specified. |
| `jobs.<name>.shell` | No | The `shell` property sets the default shell that is used across all commands within all steps. This should be configured on the agent - or by defining the `shell` [option](/docs/agent/v3/cli-start#shell) when starting a Buildkite Agent and this will set the shell command used to interpret all build commands. |
| `jobs.<name>.steps` | Partially | A collection of non-`orb` `jobs` commands that are executed as part of a CircleCI `job`. Steps can be defined within an `alias`. All the `steps` within a singular `job` are translated to the `commands` of a shared [command step](/docs/pipelines/configure/step-types/command-step) within the generated Buildkite pipeline to ensure they share the same execution environment. |
| `jobs.<name>.working_directory` | Yes | The location of the executor where steps are run. If set, a "change directory" (`cd`) command is created within the shared `commands` of a Buildkite Pipelines' [command step](/docs/pipelines/configure/step-types/command-step) to the desired location. |

### Executors

> 📘
> While the Buildkite migration tool will translate the executor types listed below, the prerequisite for using the generated steps will require a relevant compatible OS, dependencies, and tooling (for example, Docker or XCode) on the targeted agents. Buildkite offers the [Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack) as a fully scalable Buildkite agent fleet on AWS with a suite of tooling installed by default. Additionally, customized agents can be [set up](/docs/agent/v3/configuration) to target builds that require specific OSes/tooling. Or you can use [Buildkite hosted agents](/docs/pipelines/hosted-agents) - a platform for running your agents, fully managed by Buildkite.

| Key | Supported | Notes |
| --- | --- | --- |
| `jobs.<name>.docker` | Yes | Specifies that the `job` will run within a Docker container (using the `image` property) with the help of the [Docker Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) or [Docker Compose Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/). Additionally, the [Docker Login Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin/) is appended if an `auth` property is defined, or the [ECR Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/) if an `aws-auth` property is defined within the `docker` property. Sets the [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/configure/step-types/command-step) to `executor_type: docker`. |
| `jobs.<name>.executor` | Yes | Specifies the execution environment based on an executor definition supplied in the top-level `executors` key. |
| `jobs.<name>.macos` | Yes | Specifies that the `job` will run on a macOS-based execution environment. The [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/configure/step-types/command-step) will be set to `executor_type: osx` and the specified version of `xcode` from the `macos` parameters will be set as `executor_xcode: <version>`. |
| `jobs.<name>.machine` | Yes | Specifies that the `job` will run on a machine execution environment. This translates to [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/configure/step-types/command-step) through the tags of `executor_type: machine` and `executor_image: self-hosted`. |
| `jobs.<name>.resource_class` | Yes | The specification of compute that the executor will require for running a job. This is used to specify the `resource_class` [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tag for the corresponding [command step](/docs/pipelines/configure/step-types/command-step). |
| `jobs.<name>.windows` | Yes | Specifies that the `job` will run on a Windows-based execution environment. The [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/configure/step-types/command-step) will be set to `executor_type: windows`. |

## Orbs

| Key | Supported | Notes |
| --- | --- | --- |
| `orbs` | No | Orbs are currently not supported by the Buildkite migration tool and should be translated by hand if their equivalent functionality is required within a Buildkite pipeline. In Buildkite Pipelines, reusable [plugins](/docs/plugins/directory) can provide a similar functionality for integrating various common (and third-party integration-related) tasks throughout a Buildkite pipeline, such as [logging into ECR](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/), running a step within a [Docker container](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/), running multiple Docker images through a [compose file](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/), triggering builds in a [monorepo setup](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and more. |
| `Docker orbs` | Partially | Docker orbs will be converted but the translation will be an extreme approximation. It is recommended that any orb-related logic is rebuild in a Buildkite pipeline instead based on the recommendations outlined in `orbs`. |

## Parameters

| Key | Supported | Notes |
| --- | --- | --- |
| `parameters` | No | Pipeline-level parameters that can be used in the pipeline-level configuration. Pipeline-level [environment variables](/docs/pipelines/environment-variables#defining-your-own) allow for utilizing variables in Buildkite pipeline configuration with [conditionals](/docs/pipelines/configure/conditionals). |

## Setup

| Key | Supported | Notes |
| --- | --- | --- |
| `setup` | No | Allows for the conditional configuration trigger from outside the `.circleci` directory. Not directly compatible with Buildkite. However, Buildkite offers [trigger steps](/docs/pipelines/configure/step-types/trigger-step) that allow for triggering builds from another pipeline. |

## Version

| Key | Supported | Notes |
| --- | --- | --- |
| `version` | No | The version of the CircleCI pipeline configuration applied to this pipeline. No equivalent mapping exists in Buildkite Pipelines. Attributes for required and optional attributes in the various step types that are supported in Buildkite Pipelines are listed in the [Step type overview documentation](/docs/pipelines/configure/step-types) for each of the possible step types. |

## Workflows

| Key | Supported | Notes |
| --- | --- | --- |
| `workflows` | Yes | A collection of `jobs` the order of which defines how a CircleCI pipeline is run. |
| `workflows.<name>` | Yes | An individual named workflow that makes up a part of the CircleCI pipeline's definition. If a CircleCI pipeline has more than one `workflow` specified, each workflow will be transitioned to a [group step](/docs/pipelines/configure/step-types/group-step). |
| `workflows.<name>.jobs` | Yes | The individually named, non-`orb` `jobs` that make up a part of a specific workflow.<br/></br>Customized `jobs` defined as a part of a `workflow` will be translated to a Buildkite [command step](/docs/pipelines/configure/step-types/command-step) within the generated pipeline, and `jobs` with the `approval` type will be translated to a Buildkite [block step](/docs/pipelines/configure/step-types/block-step). |
| `workflows.<name>.jobs.<name>.branches` | No | The `branches` that will be allowed or blocked for a singular `job`. At the moment, the Buildkite migration tool supports setting `filters` within `workflows`, and in particular, sub-properties `branches` and `tags`  in setting a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the generated pipeline. |
| `workflows.<name>.jobs.<name>.filters` | Yes | The `branches` and `tag` filters that will determine the eligibility for a CircleCI to run. |
| `workflows.<name>.jobs.<name>.filters.branches`| Yes | The specific `branches` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps). |
| `workflows.<name>.jobs.<name>.filters.tags` | Yes |  The specific `tags` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps). |
| `workflows.<name>.jobs.<name>.matrix` | Yes | The `matrix` key allows running a specific job as part of a workload with different values. Translated to a [build matrix](/docs/pipelines/build-matrix) setup within a [command step](/docs/pipelines/configure/step-types/command-step). |
| `workflows.<name>.jobs.<name>.requires` | Yes | A list of `jobs` that require a certain `job` to start. Translated to explicit [step dependencies](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) with the `depends_on` key. |
| `workflows.<name>.when` | Yes | Conditionals that allow for running a workflow under certain conditions. The Buildkite migration tool allows for the specification using logical operators `and`, `or`, and `not` in creating command conditionals. |
