# Bitbucket Pipelines

With the help of the [Buildkite migration tool](/docs/pipelines/migration/tool), you can start converting your Bitbucket pipelines into Buildkite pipelines. This page lists the Buildkite migration tool's currently supported, partially supported, and unsupported attributes for translating from Bitbucket pipelines to Buildkite pipelines.

> 📘
> The Bitbucket Pipeline configuration that is referred to in various sections below is specified in the central `bitbucket-pipelines.yml` within a specific Bitbucket workspace [repository](https://support.atlassian.com/bitbucket-cloud/docs/what-is-a-workspace/). In Buildkite, the pipeline configuration can be set in a singular `pipeline.yml` within a repository or it can also be set and uploaded dynamically through the use of [Dynamic Pipelines](/docs/pipelines/configure/dynamic-pipelines). Additionally, control and governance of Buildkite pipelines can be achieved through the use of [Pipeline Templates](/docs/pipelines/templates) to set shared pipeline configuration within a Buildkite organization.

## Using the Buildkite migration tool with Bitbucket

To start converting your Bitbucket pipelines to the Buildkite format:

1. Go to the [interactive web tool](https://buildkite.com/resources/migrate/) page.
1. Select **Bitbucket** in the UI.
1. Paste your Bitbucket pipeline configuration.
1. Click **Convert**.
1. See the converted pipeline configuration on the **Buildkite Pipeline** side of the tool.

For example, you would like to convert the following Bitbucket pipeline configuration:

```yml
image: node:18

pipelines:
  default:
    - step:
        name: Build
        script:
          - npm install
```

This is the output that the Buildkite migration tool is going to provide:

```yml
---
steps:
- commands:
  - npm install
  plugins:
  - docker#v5.10.0:
      image: node:18
  label: Build
```

You will see the following in the Buildkite migration tool UI during the conversion of the example configuration:

<%= image "migration-tool-bitbucket.png", alt: "Converting a Bitbucket pipeline in Buildkite migration tool's web UI" %>

You might need to adjust the syntax of the resulting converted output to make it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) syntax used in Buildkite Pipelines.

> 📘
> Remember that not all the features of Bitbucket can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting Bitbucket pipelines to Buildkite Pipelines.

## Clone

| Key | Supported | Notes |
| --- | --- | --- |
| `clone` | Partially | Clone options for all steps of a Bitbucket pipeline. The majority of these options need to be set on a Buildkite agent itself via [configuration](/docs/agent/v3/configuration) of properties such as the clone flags (`git-clone-flags` or `git-clone-mirror-flags` if utilizing a Git mirror), fetch flags (`git-fetch-flags`) - or changing the entire checkout process in a customized [plugin](/docs/plugins/writing) overriding the default agent `checkout` hook. <br/><br/> Sparse-checkout properties of `code-mode`, `enabled`, and `patterns` will be translated to the respective properties within the [sparse-checkout-buildkite-plugin](https://github.com/buildkite-plugins/sparse-checkout-buildkite-plugin). <br/><br/> `clone` properties in a Bitbucket pipeline have higher precedence over these global properties. |

## Definitions

| Key | Supported | Notes |
| --- | --- | --- |
| `definitions` | Partially | Customized definitions utilized in a Bitbucket pipeline. `caches` and `services` are supported for translation within Buildkite Migration tool. |
| `definitions.caches` | Partially | Customized cache definitions that can be applied to specific Bitbucket pipeline steps - inclusive of folders, single file-cache, or multi-file cache. Targeted into specific steps with the `pipelines.default.step.caches.<name>` property, where the translation will utilize the [cache-buildkite-plugin](https://github.com/buildkite-plugins/cache-buildkite-plugin) that may require further setup and configuring around specific caching strategies. |
| `definitions.caches.<name>` | Yes | A customized cache name applicable to one or more steps within a Bitbucket pipeline. |
| `definitions.caches.<name>.path` | Yes | The directory path that is desired to be cached. |
| `definitions.caches.<name>.key.files` | Partially | The list (one or more) files that are monitored for changes - and stored once the hash changes between file versions change. If multiple files are specified, then multiple cache-plugin definitions are set on the resulting Buildkite command step (so the `manifest` properties between each will be different). <br/><br/> Note this may cause issues if the same folder is being maintained by each cache definition! |
| `definitions.pipeline` | Partially | Pipelines that are exported for re-use within repositories of the same workspace. A similar functionality exists within Buildkite and is called [Pipeline Templates](/docs/pipelines/templates). |
| `definitions.services` | Partially | Defined Docker services that are applied within a Bitbucket pipeline. Services defined in a corresponding Bitbucket pipeline step using the `pipelines.default.step.services` property will have its configuration applied with the use of the [docker-compose-buildkite-plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin). <br/><br/> Generated configuration will need to be saved to a `compose.yaml` file within the repository, and the image utilized with the Buildkite command step as `app`. <br/><br/> Refer to the Bitbucket pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/) for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline if defined. |

## Export

| Key | Supported | Notes |
| --- | --- | --- |
| `export` | No | Bitbucket Premium option for sharing pipeline configurations between workspaces. Not applicable within Buildkite as an attribute, however, similar functionality exists in Buildkite Pipelines within [Pipeline Templates](/docs/pipelines/templates). |

## Image

| Key | Supported | Notes |
| --- | --- | --- |
| `image` | Yes | The container image that is to be applied to each step within a Bitbucket pipeline, utilizing the specified image within the [docker-buildkite-plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin). This has lower precedence over per-step `image` configuration (see `pipelines.default.step.image`). <br/><br/> The `aws`, `aws.oidc`, `name`, `username` and `password` sub-properties are supported through the use of the corresponding plugin ([Docker Login](https://github.com/buildkite-plugins/docker-login-buildkite-plugin/) or [ECR](https://github.com/buildkite-plugins/ecr-buildkite-plugin/)). |

## Options

| Key | Supported | Notes |
| --- | --- | --- |
| `options` | Partially | Customized options utilized throughout a Bitbucket pipeline. The `max-time` and `size` sub-properties are supported for translation within the Buildkite migration tool into the generated Buildkite command step's `timeout_in_minutes` and agent tag respectively. <br/></br> The `docker` sub-property is not supported and will depend on the agent configuration that the corresponding Buildkite command step is being targeted to run said job has available. <br/><br/> Both supported properties in the Bitbucket pipeline step-level definition will have higher precedences than the two values set at `options` level. |

## Pipeline starting conditions

> 📘
> Bitbucket Pipelines allows the configuration of various pipeline start conditions, with each condition supporting different configuration and permissible properties:
> - `branches`: defines the branch-specific configuration of a Bitbucket pipeline.
> - `custom`: a customized starting condition where only manual triggering is allowed.
> - `default`: the default starting configuration of a Bitbucket pipeline if no other conditions apply.
> - `pull_request`: defines the pull request-specific configuration of a Bitbucket pipeline.
> - `tags`: defines the tag-specific configuration of a Bitbucket pipeline.
>
> For information on each of these individual starting conditions, refer to the reference within the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables).

### Branches

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.branches` | Yes | Application of a specific Bitbucket pipeline configuration for specific branches. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `build.branch`/`BUILDKITE_BRANCH` variable. |
| `pipelines.branches.<branch>` | Yes | The branch name or a wildcard where a specific Bitbucket pipeline step configuration needs to be applied. |
| `pipelines.branches.<branch>.parallel` | Yes | Parallel (concurrent) step configuration for a specific branch within a Bitbucket pipeline. See more information regarding the available parallel [properties](#pipeline-properties-parallel) supported by the Buildkite migration tool and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel). |
| `pipelines.branches.<branch>.step` | Yes | Individual step configuration for a specific branch within a Bitbucket pipeline. See more information regarding the available step [properties](#pipeline-properties-step) supported by the migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property). |
| `pipelines.branches.<branch>.stage` | Yes | Stage configuration for a specific branch within a Bitbucket pipeline. See the available stage [properties](#pipeline-properties-stage) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage). |

### Custom

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.custom` | Yes | Bitbucket pipelines that can only be triggered manually. The corresponding Buildkite pipeline is first generated with an [input step](/docs/pipelines/configure/step-types/input-step) before any command jobs, to ensure that the triggered builds are processed manually. |
| `pipelines.custom.<name>` | Yes | The name of the custom Bitbucket pipeline. |
| `pipelines.custom.<name>.import-pipeline.import` | No | The specification of importing a pipeline from within a specific repository defined in top-level `definitions`. Consider using [trigger steps](/docs/pipelines/configure/step-types/trigger-step) to invoke builds on a specific Buildkite pipeline. |
| `pipelines.custom.<name>.parallel` | Yes | Parallel (concurrent) step configuration for a custom Bitbucket pipeline. See the available parallel [properties](#pipeline-properties-parallel) supported by the Buildkite migration tool as well as the additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel). |
| `pipelines.custom.<name>.stage` | Yes | Stage configuration for a custom Bitbucket pipeline. See the available stage [properties](#pipeline-properties-stage) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage). |
| `pipelines.custom.<name>.step` | Yes | Individual step configuration for a custom Bitbucket pipeline. See the available step [properties](#pipeline-properties-step) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property). |
| `pipelines.custom.<name>.variables` | Partially | Variable configuration for a custom Bitbucket pipeline. See the available variable [properties](#pipeline-properties-variables) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables). |

### Default

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.default` | Yes | Bitbucket pipeline configuration that does not meet a specific configuration. Additional details can be found on this pipeline type's [documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Default) |
| `pipelines.default.parallel` | Yes | Parallel (concurrent step) configuration for default Bitbucket pipelines. See the available parallel [properties](#pipeline-properties-parallel) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel). |
| `pipelines.default.stage` | Yes | Stage configuration for default Bitbucket pipelines. See the available stage [properties](#pipeline-properties-stage) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage).  |
| `pipelines.default.step` | Yes | Individual step configuration for default Bitbucket pipelines. See the available step [properties](#pipeline-properties-step) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property). |


### Pull request

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.pull_request` | Yes | Application of specific Bitbucket pipeline configuration based for pull requests. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `pull_request.id`/`BUILDKITE_PULL_REQUEST` and `build.branch`/`BUILDKITE_BRANCH` variables. |
| `pipelines.pull_request.<branch>` | Yes | The base branch name or a wildcard to be applied within a specific Bitbucket pipeline step configuration. To apply the configuration for all builds, use a `**` wildcard. |
| `pipelines.pull_request.<branch>.parallel` | Yes | Parallel (concurrent) step configuration for pull request builds of a Bitbucket pipeline. See the available parallel [properties](#pipeline-properties-parallel) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel). |
| `pipelines.default.stage` | Yes | Stage configuration for pull request builds of a Bitbucket pipelines. See the available stage [properties](#pipeline-properties-stage) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage).  |
| `pipelines.pull_request.<branch>.step` | Yes | Individual step configuration for pull requests builds within a Bitbucket pipeline. See the available step [properties](#pipeline-properties-step) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property). |


### Tags

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.tags` | Yes | Application of a specific Bitbucket pipeline configuration based on triggered tag builds. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `build.tag`/`BUILDKITE_TAG` variable. |
| `pipelines.tags.<tag>` | Yes | The tag name or a wildcard to be applied within a specific Bitbucket pipeline step configuration. |
| `pipelines.tags.<tag>.parallel` | Yes | Parallel (concurrent) step configuration for tag builds of a Bitbucket pipeline. See the available parallel [properties](#pipeline-properties-parallel) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel). |
| `pipelines.tags.<tag>.stage` | Yes | Stage configuration for tag builds of a Bitbucket pipeline. See the available stage [properties](#pipeline-properties-stage) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage).  |
| `pipelines.tags.<tag>.step` | Yes | Individual step configuration for tag builds within a Bitbucket pipeline. See the available step [properties](#pipeline-properties-step) supported by the Buildkite migration tool - and additional property information in the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property). |


## Pipeline properties

> 📘
> Each starting pipeline condition listed [above](#pipeline-starting-conditions) can support various pipeline properties:
> - `parallel`: a grouping of multiple steps within a Bitbucket pipeline to be run concurrently.
> - `step`: a logical execution unit that makes up a specific workflow within a Bitbucket pipeline.
> - `stage`: a grouping of multiple Bitbucket pipeline steps with shared properties.
> - `variables`: a customized variable definition to utilize within a custom Bitbucket pipeline starting condition.
>
> For information on each of these individual properties, refer to the reference within the Bitbucket Pipelines documentation for [parallel](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel), [step](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property), [stage](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) and [variable](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables) properties.
>
> Additionally, implementation of these pipeline properties can be enhanced with best practices by using [Dynamic Pipelines](/docs/pipelines/configure/dynamic-pipelines) to generate and upload pipeline configuration dynamically and using [conditionals](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) at both pipeline level and step level to apply jobs only when certain conditions are met, and setting [trigger steps](/docs/pipelines/configure/step-types/trigger-step) with required attributes and environment variable configurations passed through to the triggered builds.

### Parallel

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.parallel` | Yes | The grouping of multiple steps within a Bitbucket pipeline to be run concurrently. By default, Buildkite executes steps in parallel, unless [implicit or explicit dependencies](/docs/pipelines/dependencies) are set. Parallel Bitbucket pipeline steps are transitioned into a [group step](/docs/pipelines/configure/step-types/group-step) within the generated Buildkite pipeline without explicit dependencies. |
| `pipelines.<start-condition>.parallel.fail-fast` | No | Whether a Bitbucket pipeline allows this parallel step to fail entirely if it fails (set as `true`), or allows failures (set as `false`). Consider using a combination of `soft_fail` and/or `cancel_on_build_failing` in the corresponding Buildkite command steps' [attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes) for a similar [approach](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). |

### Step

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.step.after-script` | No | The actions that a Bitbucket pipeline will undertake after the commands in the `script` key are run. For similar behaviour in Buildkite, use a [repository-level](/docs/agent/v3/hooks#hook-locations-repository-hooks) `pre-exit` hook running at the latter end of the [job lifecycle](/docs/agent/v3/hooks#job-lifecycle-hooks). |
| `pipelines.<start-condition>.step.artifacts` | Partially | Build artifacts that will be required for steps later in the Bitbucket pipeline (by default, not obtained unless an explicit `buildkite-agent artifact download` [command](/docs/agent/v3/cli-artifact#downloading-artifacts) is run beforehand within the generated Buildkite command step). Artifacts that are specified (whether one specific file, or multiple) will be set within the generated command step within the `artifact_paths` [key](/docs/pipelines/configure/step-types/command-step). Each file found matching (or via glob syntax) will be uploaded to Buildkite's [Artifact storage](/docs/agent/v3/cli-artifact) that can be obtained in later steps. |
| `pipelines.<start-condition>.step.caches` | Yes | Step-level dependencies downloaded from external sources (for example,Docker, Maven, PyPi) which can be reused in later Bitbucket pipeline steps. Caches that are set at step level (or through the top-level `definition.cache.<name>` property) are translated in the corresponding Buildkite pipeline utilizing the [cache-buildkite-plugin](https://github.com/buildkite-plugins/cache-buildkite-plugin) to store the downloaded dependencies for reuse between Buildkite builds. |
| `pipelines.<start-condition>.step.condition` | Partially | The configuration for preventing a Bitbucket pipeline step from running unless the specific conditional is met. Translated to an inline conditional (`if`) within the corresponding Buildkite pipelines' command step's `commands` - based on a `git diff` of the base branch. |
| `pipelines.<start-condition>.step.condition.changeset.includePaths` | Partially | The specific file (or files) that need to be detected as changed for the `condition` to apply. This can be set as specific files - or wildcards that match multiple files in a specific directory/directories. <br/><br/> Translated to a script that will review the changed files through git. This means that the step itself will actually run and just be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the [monorepo-diff-buildkite-plugin](https://github.com/buildkite-plugins/monorepo-diff-buildkite-plugin) and watching specific folders or files and the uploading the resulting [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) upon a diff detection. |
| `pipelines.<start-condition>.step.clone` | Partially | Clone options for a specific step of a Bitbucket pipeline. The majority of these options should be set directly on a Buildkite agent via [configuration](/docs/agent/v3/configuration) of properties such as the clone flags (`git-clone-flags`, `git-clone-mirror-flags` if utilizing a Git mirror), fetch flags (`git-fetch-flags`) - or changing the entire checkout process in a customized [plugin](/docs/plugins/writing) overriding the default agent `checkout` hook. Sparse checkout options are supported (with the `sparse-checkout` sub-property) |
| `pipelines.<start-condition>.step.deployment` | No | The environment set for the Bitbucket Deployments dashboard. This has no translatable equivalent within Buildkite. |
| `pipelines.<start-condition>.step.docker` | No | The availability of Docker in a specific Bitbucket pipeline step. This will depend on the agent configuration that the corresponding Buildkite command step is being targeted to run the job. Consider [tagging](/docs/agent/v3/cli-start#tags) agents with `docker=true` to ensure Buildkite command steps requiring hosts with Docker installed and configured to accept and run specific jobs. |
| `pipelines.<start-condition>.step.fail-fast` | No | Whether a specific step of a Bitbucket pipeline allows a parallel step to fail entirely if it fails (set as `true`), or allows failures (set as `false`). Consider using a combination of `soft_fail` and/or `cancel_on_build_failing` in the corresponding Buildkite command steps' [attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes) for a similar [approach](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). |
| `pipelines.<start-condition>.step.image` | Yes | The container image that is to be applied to a specific step within a Bitbucket pipeline. Images set at this level will be applied irrespective of the pipeline-level `image` key, and will be applied in the corresponding Buildkite pipeline using the [docker-buildkite-plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin). <br/><br/> The `aws`, `aws.oidc`, `name`, `username` and `password` sub-properties are supported through the use of the corresponding plugin ([Docker Login](https://github.com/buildkite-plugins/docker-login-buildkite-plugin/) or [ECR](https://github.com/buildkite-plugins/ecr-buildkite-plugin/)). |
| `pipelines.<start-condition>.step.max-time` | Yes | The maximum allowable time that a step within a Bitbucket pipeline is able to run for. Translates to the corresponding Buildkite pipelines' command step `timeout_in_minutes` attribute. |
| `pipelines.<start-condition>.step.name` | Yes | The name of a specific step within a Bitbucket pipeline. Translates to a Buildkite command step's `label`. |
| `pipelines.<start-condition>.step.oidc` | Yes | Open ID Connect configuration that will be applied for this Bitbucket pipeline step. The generated command step in the corresponding Buildkite pipeline will [request](/docs/agent/v3/cli-oidc#request-oidc-token) an OIDC token and export it into the job environment as `BITBUCKET_STEP_OIDC_TOKEN` (to be passed to `sts` to assume an AWS role for example) |
| `pipelines.<start-condition>.step.runs-on` | Yes | Allocating the Bitbucket pipeline to run on a self-hosted runner with the specific label. All `runs-on` values will be set as agent [tags](/docs/pipelines/configure/defining-steps#targeting-specific-agents) in the Buildkite command step for targeting on specific Buildkite agents within an organization. |
| `pipelines.<start-condition>.step.services` | Partially | The name of one or more services defined at `definitions.services.<name>` that will be applied for this step. Translated to utilize the service configuration with the [docker-compose-buildkite-plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin). <br/><br/> Generated configuration will need to be saved to a `compose.yaml` file within the repository, and the image utilized with the Buildkite command step as `app`. <br/><br/> Refer to the Bitbucket pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/) for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline if defined. |
| `pipelines.<start-condition>.step.script` | Yes | The individual commands that make up a specific step. Each is translated into a singular command within the `commands` key of a Buildkite command step. |
| `pipelines.<start-condition>.step.script.pipe` | No | Reusable modules to make configuration in Bitbucket pipelines easier and modular. Consider exploring the suite of available [Buildkite Plugins](/docs/pipelines/integrations/plugins) for corresponding functionality that is required. |
| `pipelines.<start-condition>.step.size` | Yes | Allocation of sizing options for the given memory for a specific step within a Bitbucket pipeline. The `size` value will be set as an agent [tag](/docs/pipelines/configure/defining-steps#targeting-specific-agents) in the Buildkite command step for targeting on specific Buildkite agents within an organization. |
| `pipelines.<start-condition>.step.trigger` | Yes | The configuration setting for running of a Bitbucket pipeline step manually or automatically (the default setting). For `manual` triggers, an [input step](/docs/pipelines/configure/step-types/input-step) is inserted into the generated Buildkite pipeline before the specified `script` within a further command step. Explicit dependencies with `depends_on` are set between the two steps; requires manual processing. |

### Stage

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.stage` | Yes | The logical grouping of one or more Bitbucket pipeline steps. Bitbucket pipeline stages are translated into the corresponding Buildkite pipeline as a [group step](/docs/pipelines/configure/step-types/group-step). |
| `pipelines.<start-condition>.stage.condition.changeset.includePaths` | Partially | The specific file (or files) that need to be detected as changed for the `condition` to apply. This can be set as specific files or wildcards that match multiple files in the specific directories. <br/><br/> Translated into a script that will review the changed files through git. This means that the step itself will actually run and will be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the [monorepo-diff-buildkite-plugin](https://github.com/buildkite-plugins/monorepo-diff-buildkite-plugin) and watching for specific folders and files and uploading the resulting [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) upon diff detection. |
| `pipelines.<start-condition>.stage.name` | Yes | The name of the Bitbucket pipeline stage. Transitioned to the `group` label of the corresponding Buildkite [group step](/docs/pipelines/configure/step-types/group-step). |
| `pipelines.<start-condition>.stage.steps` | Yes | Individual step configuration for a Bitbucket pipeline stage. See configuration options in this section (`pipelines.default.step.<property>`) for the supported and unsupported properties. |
| `pipelines.<start-condition>.stage.trigger` | Yes | The configuration setting for running of a Bitbucket pipeline stage manually or automatically (the default setting). For `manual` triggers, an [input step](/docs/pipelines/configure/step-types/input-step) is inserted into the generated Buildkite pipeline's [group step](/docs/pipelines/configure/step-types/group-step) before the specified `steps` of this stage. The explicit dependencies with `depends_on` are set between the input step and the following steps to ensure manual processing is required for these to run. |

### Variables

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.variables` | Partially | Custom variables that are passed to Bitbucket pipeline steps. Each variable defined in a Bitbucket pipeline step is translated to a Buildkite [input step](/docs/pipelines/configure/step-types/input-step) with/without defaults and allowed values specified below. <br/><br/> Variables that are translated into the corresponding [input step](/docs/pipelines/configure/step-types/input-step) within the generated Buildkite pipeline will require to be fetched in subsequent steps through a `buildkite-agent meta-data get` [command](/docs/agent/v3/cli-meta-data#getting-data). |
| `pipelines.<start-condition>.variables.name` | Yes | The variables' name: translated to the `key` attribute of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step) (text entry).|
| `pipelines.<start-condition>.variables.default` | Yes | The default variable value if no value is set. Set as the `default` attribute within the `field` of an [input step](/docs/pipelines/configure/step-types/input-step). |
| `pipelines.<start-condition>.variables.description` | Yes | The description of the variable. Translated to the `text` attribute of a specific `field` within the generated  [input step](/docs/pipelines/configure/step-types/input-step). |
| `pipelines.<start-condition>.variables.allowed-values` | Yes | The variable's allowed values: each option is translated to a singular `options` object with given value of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step). |
