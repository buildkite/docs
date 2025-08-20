# CircleCI

With the help of the Buildkite Migration tool, you can start converting your CircleCI pipelines into Buildkite pipelines. This page lists the Buildkite Migration tool's currently supported, partially supported, and unsupported attributes for translating from CircleCI pipelines to Buildkite pipelines.

## Logical operators (helpers)

> 📘
> The Buildkite Migration tool supports the use of YAML aliases - re-usable snippets of configuration to apply to a specific point in a CircleCI pipeline. These are defined with a `&` (anchor) within the top-level `aliases` key and substituted into CircleCI pipeline configuration with `*`: for example, `*tests`. Configuration defined by an alias will be respected and parsed accordingly at the specified section of the pipeline.

| Key | Supported | Notes |
| --- | --- | --- |
| `and` | Partially | Logical operator for denoting all inputs required to be true. Supported with the utilisation of the `when` key within setting up conditional `workflow` runs. |
| `or` | Partially | Logical operator for describing if any of the inputs are true. Supported with the utilisation of the `when` key within setting up conditional `workflow` runs. |
| `not` | Partially | Logical operator for negating input. Supported with the utilisation of the `when` key within setting up conditional `workflow` runs. |

## Commands

| Key | Supported | Notes |
| --- | --- | --- |
| `commands` | Yes | A `command` defined in a CircleCI pipeline is a reusable set of instructions with parameters that can be inserted into required `job` executions. Commands can have their own set list of `steps` that are translated through to the generated [command step](/docs/pipelines/command-step)'s `commands`. If a `command` contains a `parameters` key, they are respected when used in jobs/workflows and their defaults values used when not specified. |

## Executors

| Key | Supported | Notes |
| --- | --- | --- |
| `executors` | Yes | The `executor` key defined at topmost-level in a CircleCI workflow maps to the use of the `executor` key specified within a specific `job`. Supported execution environments include `machine`, `docker`, `macos` and `windows`; further information can be found in the Jobs table below. The execution environment in Buildkite is specified with each environment's applied [tags](/docs/agent/v3/cli-start#setting-tags) in their generated [command step](/docs/pipelines/command-step), for which can be [targeted](/docs/pipelines/defining-steps#targeting-specific-agents) when creating builds. |

## Jobs

### General

| Key | Supported | Notes |
| --- | --- | --- |
| `jobs` | Yes | A collection of steps that are run on a single worker unit: whether that is on a host directly, or on a virtualized host (such as within a Docker container). Orchestrated with `workflows`. |
| `jobs.<name>` | Yes | The named, individual `jobs` that makes up part of a given `workflow`. |
| `jobs.<name>.environment` | Yes | The `job` level environment variables of a CircleCI pipeline. Applied in the generated [command step](/docs/pipelines/command-step) as [step level](/docs/pipelines/environment-variables#runtime-variable-interpolation) environment variables with the `env` key. |
| `jobs.<name>.parallelism` | No | A `parallelism` parameter (if defined greater than 1) will create a separate execution environment and will run the `steps` of the specific `job` in parallel. In Buildkite - a similar `parallelism` key can be set to a [command step](/docs/pipelines/command-step) which will run the defined `command` over separate jobs (sharing the same agent [queues](/docs/agent/v3/queues#setting-an-agents-queue)/[tags](/docs/agent/v3/cli-start#setting-tags) targets). |
| `jobs.<name>.parameters` | Yes | Reusable keys that are used within `step` definitions within a `job`. Default parameters that are specified in a `parameters` block are passed through into the [command step](/docs/pipelines/command-step)'s `commands` if specified. |
| `jobs.<name>.shell` | No | The `shell` property sets the default shell that is used across all commands within all steps. This should be configured on the agent - or by defining the `shell` [option](/docs/agent/v3/cli-start#shell) when starting a Buildkite agent: which will set the shell command used to interpret all build commands. |
| `jobs.<name>.steps` | Yes | A collection of non-`orb` `jobs` commands that are executed as part of a CircleCI `job`. Steps can be defined within an `alias`. All `steps` within a singular `job` are translated to the `commands` of a shared [command step](/docs/pipelines/command-step) within the generated Buildkite pipeline to ensure they share the same execution environment. |
| `jobs.<name>.working_directory` | Yes | The location of the executor where steps are run in. If set, a change directory (`cd`) command is created within the shared `commands` of a Buildkite [command step](/docs/pipelines/command-step) to the desired location. |

### Executors

> 📘
> While the Buildkite Migration Tool will translate the below executor types listed; the prerequisite of using the generated steps will require the relevant OS, dependencies and tooling (for example, Docker, XCode etc) on targeted agents. Buildkite offers the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws?tab=readme-ov-file#supported-features) as a fully scalable Buildkite agent fleet on AWS with a suite of tooling installed by default. Additionally, customised agents can be [setup](/docs/agent/v3/configuration) to target builds that require specific OSes/tooling.

| Key | Supported | Notes |
| --- | --- | --- |
| `jobs.<name>.docker` | Yes | Specifies that the `job` will run within a Docker container (by its `image` property) with the use of the [Docker Buildkite Plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin) or [Docker Compose Buildkite Plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin). Additionally, the [Docker Login Plugin](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) is appended if an `auth` property is defined, or the [ECR Buildkite Plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) if an `aws-auth` property is defined within the `docker` property. Sets the [agent targeting](/docs/pipelines/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/command-step) to `executor_type: docker`. |
| `jobs.<name>.executor` | Yes | Specifies the execution environment based from an executor definition supplied in the top-level `executors` key. |
| `jobs.<name>.macos` | Yes | Specifies that the `job` will run on a macOS bases execution environment. The [agent targeting](/docs/pipelines/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/command-step) will be set to `executor_type: osx`, as well as the specified version of `xcode` from the `macos` parameters as `executor_xcode: <version>`. |
| `jobs.<name>.machine` | Yes | Specifies that the `job` will run on a machine execution environment. This translates to [agent targeting](/docs/pipelines/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/command-step) through the tags of `executor_type: machine` and `executor_image: self-hosted`. |
| `jobs.<name>.resource_class` | Yes | The specification of compute that the executor will require in running a job. This is used to specify the `resource_class` [agent targeting](/docs/pipelines/defining-steps#targeting-specific-agents) tag for the corresponding [command step](/docs/pipelines/command-step). |
| `jobs.<name>.windows` | Yes | Specifies that the `job` will run on a Windows based execution environment. The [agent targeting](/docs/pipelines/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/command-step) will be set to `executor_type: windows`. |

## Orbs

| Key | Supported | Notes |
| --- | --- | --- |
| `orbs` | No | Orbs are currently not supported by the Buildkite Migration tool, and should be translated by hand if required to utilise within a Buildkite pipeline. The Buildkite platform has reusable [plugins](/docs/plugins/directory) that provide a similar experience for integrating various common (and third party integration) tasks throughout a Buildkite pipeline, such as [logging into ECR](https://github.com/buildkite-plugins/ecr-buildkite-plugin), running a step within a [Docker container](https://github.com/buildkite-plugins/docker-buildkite-plugin), running multiple Docker images through a [compose file](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin), triggering builds in a [monorepo setup](https://github.com/buildkite-plugins/monorepo-diff-buildkite-plugin) and more. |

## Parameters

| Key | Supported | Notes |
| --- | --- | --- |
| `parameters` | No | Pipeline-level parameters that allow for utilisation in the pipeline level configuration. Pipeline level [environment variables](/docs/pipelines/environment-variables#defining-your-own) allow for utilising variables in Buildkite pipeline configuration with [conditionals](/docs/pipelines/conditionals). |

## Setup

| Key | Supported | Notes |
| --- | --- | --- |
| `setup` | No | Allows for the conditional configuration trigger from outside the .circleci directory - not applicable with Buildkite. Buildkite offers [trigger steps](/docs/pipelines/trigger-step) that allow for triggering builds from another pipeline. |

## Version

| Key | Supported | Notes |
| --- | --- | --- |
| `version` | No | The version of the CircleCI pipeline configuration applied to this pipeline. No equivalent mapping exists in Buildkite. Attributes for required and optional attributes in the various step types supported in Buildkite are listed in the [docs](/docs/pipelines/step-reference). |

## Workflows

| Key | Supported | Notes |
| --- | --- | --- |
| `workflows` | Yes | A a collection of `jobs`, whose ordering defines how a CircleCI pipeline is run. |
| `workflows.<name>` | Yes | An individual named workflow that makes up part of the CircleCI pipeline's definition. If a CircleCI pipeline has more than 1 `workflow` specified, each will be transitioned to a [group step](/docs/pipelines/group-step). |
| `workflows.<name>.jobs` | Yes | The individually named, non-`orb` `jobs` that make up part of this specific workflow.<br/></br>Customised `jobs` defined as part of a `workflow` will be translated to a Buildkite [command step](/docs/pipelines/command-step) within the generated pipeline, and `jobs` with the `approval` type will be translated to a Buildkite [block step](/docs/pipelines/block-step). |
| `workflows.<name>.jobs.<name>.branches` | No | The `branches` that will be allowed/blocked for a singular `job`. Presently, the Buildkite Migration tool supports setting `filters` within `workflows`: and in particular, `branches` and `tags` sub-properties in setting a [step conditional](/docs/pipelines/conditionals#conditionals-in-steps) in the generated pipeline. |
| `workflows.<name>.jobs.<name>.filters` | Yes | The `branches` and `tag` filters that will determine the eligibility for a CircleCI to run. |
| `workflows.<name>.jobs.<name>.filters.branches`| Yes | The specific `branches` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/conditionals#conditionals-in-steps). |
| `workflows.<name>.jobs.<name>.filters.tags` | Yes |  The specific `tags` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/conditionals#conditionals-in-steps). |
| `workflows.<name>.jobs.<name>.matrix` | Yes | The `matrix` key allows running a specific job as part of a workload with different values. Translated to a [build matrix](/docs/pipelines/build-matrix) setup within a [command step](/docs/pipelines/command-step). |
| `workflows.<name>.jobs.<name>.requires` | Yes | A list of `jobs` that require this `job` to start. Translated to explicit [step dependencies](/docs/pipelines/dependencies#defining-explicit-dependencies) with the `depends_on` key. |
| `workflows.<name>.when` | Yes | Conditionals that allow for running a workflow under certain conditions. The Buildkite Migration tool allows for the specification using Logical operators `and`, `or` and `not` in creating command conditionals. |
