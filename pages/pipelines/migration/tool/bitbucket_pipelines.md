# Bitbucket Pipelines

The [Buildkite migration tool](/docs/pipelines/migration/tool) helps you convert your Bitbucket pipelines into Buildkite pipelines. This page lists the Buildkite migration tool's currently supported, partially supported, and unsupported keys for translating from Bitbucket pipelines to Buildkite pipelines.

> 📘
> The Bitbucket Pipeline configuration that is referred to in various sections below is specified in the central `bitbucket-pipelines.yml` within a specific Bitbucket workspace [repository](https://support.atlassian.com/bitbucket-cloud/docs/what-is-a-workspace/). In Buildkite, the pipeline configuration can be set in a singular `pipeline.yml` within a repository or it can also be set and uploaded dynamically through the use of [Dynamic Pipelines](/docs/pipelines/configure/dynamic-pipelines). Additionally, control and governance of Buildkite pipelines can be achieved through the use of [Pipeline Templates](/docs/pipelines/templates) to set shared pipeline configuration within a Buildkite organization.

## Using the Buildkite migration tool with Bitbucket

To start converting your Bitbucket pipeline into Buildkite Pipelines format:

1. Open the [Buildkite migration interactive web tool](https://buildkite.com/resources/migrate/) in a new browser tab.
1. Select **Bitbucket** at the top of the left panel.
1. Copy your Bitbucket pipeline configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

For example, when converting the following example Bitbucket pipeline configuration:

```yml
image: node:18

pipelines:
  default:
    - step:
        name: Build
        script:
          - npm install
```

The Buildkite migration tool should translate this to the following output:

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

The Buildkite migration tool interface should look similar to this:

<%= image "migration-tool-bitbucket.png", alt: "Converting a Bitbucket pipeline in Buildkite migration tool's web UI" %>

You might need to adjust the converted Buildkite pipeline output to ensure it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) used in Buildkite Pipelines.

> 📘
> Remember that not all the features of Bitbucket can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting Bitbucket pipelines to Buildkite Pipelines.

## Clone

| Key | Supported | Notes |
| --- | --- | --- |
| `clone` | Partially | Clone options for all steps of a Bitbucket pipeline. The majority of these options need to be set on a Buildkite agent itself via [configuration](/docs/agent/v3/configuration) of properties such as the clone flags (`git-clone-flags` or `git-clone-mirror-flags` if utilizing a Git mirror), fetch flags (`git-fetch-flags`) - or changing the entire checkout process in a customized [plugin](/docs/plugins/writing) overriding the default agent `checkout` hook. <br/><br/> Sparse-checkout properties of `code-mode`, `enabled`, and `patterns` will be translated to the respective properties within the [sparse-checkout-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/). <br/><br/> `clone` properties in a Bitbucket pipeline have higher precedence over these global properties. |

## Definitions

| Key | Supported | Notes |
| --- | --- | --- |
| `definitions` | Partially | Customized definitions utilized in a Bitbucket pipeline. `caches` and `services` are supported for translation within Buildkite Migration tool. |
| `definitions.caches` | Partially | Customized cache definitions that can be applied to specific Bitbucket pipeline steps - inclusive of folders, single file-cache, or multi-file cache. Targeted into specific steps with the `pipelines.default.step.caches.<name>` property, where the translation will utilize the [cache-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) that may require further setup and configuring around specific caching strategies. |
| `definitions.caches.<name>` | Yes | A customized cache name applicable to one or more steps within a Bitbucket pipeline. |
| `definitions.caches.<name>.path` | Yes | The path to a directory that needs to be cached. |
| `definitions.caches.<name>.key.files` | Partially | The list (one or more) files that are monitored for changes - and stored once the hash changes between the change of file versions. If multiple files are specified, then multiple cache-plugin definitions are set on the resulting Buildkite Pipelines command step (so the `manifest` properties between each will be different). <br/><br/> Note that this may cause issues if the same folder is being maintained by each cache definition. |
| `definitions.pipeline` | Partially | Pipelines that are exported for reuse within the repositories of the same workspace. A similar functionality exists within Buildkite Pipelines and is called [Pipeline Templates](/docs/pipelines/templates). |
| `definitions.services` | Partially | Docker services that are defined and applied within a Bitbucket pipeline. Services defined in a corresponding Bitbucket pipeline step using the `pipelines.default.step.services` property will have this configuration applied with the use of the [docker-compose-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/). <br/><br/> The generated configuration will need to be saved to a `compose.yaml` file within the repository, and the image utilized by the Buildkite Pipelines command step as `app`. <br/><br/> Refer to the Bitbucket pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/) for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline even if defined. |

## Export

| Key | Supported | Notes |
| --- | --- | --- |
| `export` | No | Bitbucket Premium option for sharing pipeline configurations between workspaces. Not applicable within Buildkite as an attribute, however, similar functionality exists in Buildkite Pipelines within [Pipeline Templates](/docs/pipelines/templates). |

## Image

| Key | Supported | Notes |
| --- | --- | --- |
| `image` | Yes | The container image that is to be applied to each step within a Bitbucket pipeline, utilizing the specified image within the [docker-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/). This has lower precedence over per-step `image` configuration (see `pipelines.default.step.image`). |
| `aws`, `aws.oidc`, `name`, `username`, `password` | Partially | Supported through the use of the corresponding plugin ([Docker Login](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin) or [ECR](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/)). |

## Options

| Key | Supported | Notes |
| --- | --- | --- |
| `options` | Partially | Customized options utilized throughout a Bitbucket pipeline. |
| `max-time`, `size`| Partially | These sub-properties are supported for translation within the Buildkite migration tool into the generated Buildkite Pipelines command step's `timeout_in_minutes` and agent tag respectively. |
| `docker` | No| This sub-property is not supported and will depend on the agent configuration the corresponding Buildkite Pipelines command step is being targeted to run said job has available. |

Note that both supported properties in the Bitbucket pipeline step-level definition will have higher precedences than the two values set at `options` level. |

## Pipeline starting conditions

> 📘
> Bitbucket Pipelines allows the configuration of various pipeline start conditions, with each condition supporting different configuration and permissible properties like `branches`, `custom`, `default`, `pull_request`, `tags`, and more. For information on each of these individual starting conditions, refer to the reference within the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables).

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
| `pipelines.default` | Yes | Bitbucket pipeline configuration that does not meet a specific condition. Additional details can be found the Bitbucket Pipelines [documentation](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Default) |
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
> Each [starting pipeline condition](#pipeline-starting-conditions) in Bitbucket can support various pipeline properties like `parallel`, `step`, `stage`, `variables` and so on.
> For information on each of these individual properties, refer to the Bitbucket Pipelines documentation for [parallel](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel), [step](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property), [stage](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage), and [variable](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables) properties.
>
> Additionally, implementation of these pipeline properties can be enhanced with best practices by using [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to generate and upload pipeline configuration dynamically and using [conditionals](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) at both pipeline level and step level to apply jobs only when certain conditions are met, and setting [trigger steps](/docs/pipelines/configure/step-types/trigger-step) with required attributes and environment variable configurations passed through to the triggered builds.

### Parallel

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.parallel` | Yes | The grouping of multiple steps within a Bitbucket pipeline to be run concurrently. By default, Buildkite executes steps in parallel, unless [implicit or explicit dependencies](/docs/pipelines/dependencies) are set. Parallel Bitbucket pipeline steps are transitioned into a [group step](/docs/pipelines/configure/step-types/group-step) within the generated Buildkite pipeline without explicit dependencies. |
| `pipelines.<start-condition>.parallel.fail-fast` | No | Whether a Bitbucket pipeline allows this parallel step to fail entirely if it fails (set as `true`), or allows failures (set as `false`). Consider using a combination of `soft_fail` and/or `cancel_on_build_failing` in the corresponding Buildkite Pipelines command steps' [attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes) for a similar [approach](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). |

### Step

<table>
  <thead>
    <tr>
      <th style="width:30%">Key</th>
      <th style="width:15%">Supported</th>
      <th style="width:55%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.after-script</code></td>
      <td>No</td>
      <td>The actions that a Bitbucket pipeline will undertake after the commands in the <code>script</code> key are run. For similar behaviour in Buildkite Pipelines, use a <a href="/docs/agent/v3/hooks#hook-locations-repository-hooks">repository-level</a> <code>pre-exit</code> hook running at the latter end of the <a href="/docs/agent/v3/hooks#job-lifecycle-hooks">job lifecycle</a>.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.artifacts</code></td>
      <td>Partially</td>
      <td>Build artifacts that will be required for steps later in the Bitbucket pipeline (by default, not obtained unless an explicit <code>buildkite-agent artifact download</code> <a href="/docs/agent/v3/cli-artifact#downloading-artifacts">command</a> is run beforehand within the generated Buildkite Pipelines command step). Artifacts that are specified (whether one specific file, or multiple) will be set within the generated command step within the <code>artifact_paths</code> <a href="/docs/pipelines/configure/step-types/command-step">key</a>. Each file found matching (or via glob syntax) will be uploaded to Buildkite's <a href="/docs/agent/v3/cli-artifact">Artifact storage</a> that can be obtained in later steps.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.caches</code></td>
      <td>Yes</td>
      <td>Step-level dependencies downloaded from external sources (for example, Docker, Maven, PyPi) which can be reused in later Bitbucket pipeline steps. Caches that are set at step level (or through the top-level <code>definition.cache.&lt;name&gt;</code> property) are translated in the corresponding Buildkite pipeline utilizing the <a href="https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/">cache-buildkite-plugin</a> to store the downloaded dependencies for reuse between Buildkite builds.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.condition</code></td>
      <td>Partially</td>
      <td>The configuration for preventing a Bitbucket pipeline step from running unless the specific conditional is met. Translated to an inline conditional (<code>if</code>) within the corresponding Buildkite pipelines' command step's <code>commands</code> – based on a <code>git diff</code> of the base branch.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.condition.&shy;changeset.includePaths</code></td>
      <td>Partially</td>
      <td>The specific file (or files) that need to be detected as changed for the <code>condition</code> to apply. This can be set as specific files – or wildcards that match multiple files in a specific directory/directories. <br/><br/> Translated to a script that will review the changed files through git. This means that the step itself will actually run and just be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the <a href="https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/">monorepo-diff-buildkite-plugin</a> and watching specific folders or files and then uploading the resulting <a href="/docs/pipelines/configure/dynamic-pipelines">Dynamic pipelines</a> upon a diff detection.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.clone</code></td>
      <td>Partially</td>
      <td>Clone options for a specific step of a Bitbucket pipeline. The majority of these options should be set directly on a Buildkite Agent via <a href="/docs/agent/v3/configuration">configuration</a> of properties such as the clone flags (<code>git-clone-flags</code>, <code>git-clone-mirror-flags</code> if utilizing a Git mirror), fetch flags (<code>git-fetch-flags</code>) – or changing the entire checkout process in a customized <a href="/docs/plugins/writing">plugin</a> overriding the default agent <code>checkout</code> hook. Sparse checkout options are supported (with the <code>sparse-checkout</code> sub-property).</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.deployment</code></td>
      <td>No</td>
      <td>The environment set for the Bitbucket Deployments dashboard that has no translatable equivalent within Buildkite Pipelines.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.docker</code></td>
      <td>No</td>
      <td>The availability of Docker in a specific Bitbucket pipeline step. This will depend on the agent configuration that the corresponding Buildkite command step is being targeted to run the job. Consider <a href="/docs/agent/v3/cli-start#tags">tagging</a> agents with <code>docker=true</code> to ensure Buildkite Pipelines command steps requiring hosts with Docker installed and configured to accept and run specific jobs.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.fail-fast</code></td>
      <td>No</td>
      <td>Whether a specific step of a Bitbucket pipeline allows a parallel step to fail entirely if it fails (set as <code>true</code>), or allows failures (set as <code>false</code>). Consider using a combination of <code>soft_fail</code> and/or <code>cancel_on_build_failing</code> in the corresponding Buildkite Pipelines command steps' <a href="/docs/pipelines/configure/step-types/command-step#command-step-attributes">attributes</a> for a similar <a href="/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs">approach</a>.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.image</code></td>
      <td>Yes</td>
      <td>The container image that is to be applied to a specific step within a Bitbucket pipeline. Images set at this level will be applied irrespective of the pipeline-level <code>image</code> key, and will be applied in the corresponding Buildkite pipeline using the <a href="https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/">docker-buildkite-plugin</a>. <br/><br/> The <code>aws</code>, <code>aws.oidc</code>, <code>name</code>, <code>username</code>, and <code>password</code> sub-properties are supported through the use of the corresponding plugin (<a href="https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin">Docker Login</a> or <a href="https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/">ECR</a>).</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.max-time</code></td>
      <td>Yes</td>
      <td>The maximum allowable time that a step within a Bitbucket pipeline is able to run for. Translates to the corresponding Buildkite Pipelines command step <code>timeout_in_minutes</code> attribute.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.name</code></td>
      <td>Yes</td>
      <td>The name of a specific step within a Bitbucket pipeline. Translates to a Buildkite command step's <code>label</code>.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.oidc</code></td>
      <td>Yes</td>
      <td>Open ID Connect configuration that will be applied for this Bitbucket pipeline step. The generated command step in the corresponding Buildkite pipeline will <a href="/docs/agent/v3/cli-oidc#request-oidc-token">request</a> an OIDC token and export it into the job environment as <code>BITBUCKET_STEP_OIDC_TOKEN</code> (to be passed to <code>sts</code> to assume an AWS role for example).</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.runs-on</code></td>
      <td>Yes</td>
      <td>Allocating the Bitbucket pipeline to run on a self-hosted runner with the specific label. All <code>runs-on</code> values will be set as agent <a href="/docs/pipelines/configure/defining-steps#targeting-specific-agents">tags</a> in the Buildkite command step for targeting on specific Buildkite Agents within an organization.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.services</code></td>
      <td>Partially</td>
      <td>The name of one or more services defined at <code>definitions.services.&lt;name&gt;</code> that will be applied for this step. Translated to utilize the service configuration with the <a href="https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/">docker-compose-buildkite-plugin</a>. <br/><br/> Generated configuration will need to be saved to a <code>compose.yaml</code> file within the repository, and the image utilized with the Buildkite command step as <code>app</code>. <br/><br/> Refer to the Bitbucket pipelines <a href="https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/">documentation</a> for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline if defined.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.script</code></td>
      <td>Yes</td>
      <td>The individual commands that make up a specific step. Each is translated into a singular command within the <code>commands</code> key of a Buildkite command step.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.script.pipe</code></td>
      <td>No</td>
      <td>Reusable modules to make configuration in Bitbucket pipelines easier and modular. Consider exploring the suite of available <a href="/docs/pipelines/integrations/plugins">Buildkite Plugins</a> for corresponding functionality that is required.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.size</code></td>
      <td>Yes</td>
      <td>Allocation of sizing options for the given memory for a specific step within a Bitbucket pipeline. The <code>size</code> value will be set as an agent <a href="/docs/pipelines/configure/defining-steps#targeting-specific-agents">tag</a> in the Buildkite command step for targeting on specific Buildkite agents within an organization.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.step.trigger</code></td>
      <td>Yes</td>
      <td>The configuration setting for running of a Bitbucket pipeline step manually or automatically (the default setting). For <code>manual</code> triggers, an <a href="/docs/pipelines/configure/step-types/input-step">input step</a> is inserted into the generated Buildkite pipeline before the specified <code>script</code> within a further command step. Explicit dependencies with <code>depends_on</code> are set between the two steps; requires manual processing.</td>
    </tr>
  </tbody>
</table>

### Stage

<table>
  <thead>
    <tr>
      <th style="width:35%">Key</th>
      <th style="width:20%">Supported</th>
      <th style="width:45%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.stage</code></td>
      <td>Yes</td>
      <td>The logical grouping of one or more Bitbucket pipeline steps. Bitbucket pipeline stages are translated into the corresponding Buildkite pipeline as a <a href="/docs/pipelines/configure/step-types/group-step">group step</a>.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.stage.condition.&shy;changeset.includePaths</code></td>
      <td>Partially</td>
      <td>The specific file (or files) that need to be detected as changed for the <code>condition</code> to apply. This can be set as specific files or wildcards that match multiple files in the specific directories. <br/><br/> Translated into a script that will review the changed files through git. This means that the step itself will actually run and will be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the <a href="https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/">monorepo-diff-buildkite-plugin</a> and watching for specific folders and files and uploading the resulting <a href="/docs/pipelines/configure/dynamic-pipelines">Dynamic pipelines</a> upon diff detection.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.stage.name</code></td>
      <td>Yes</td>
      <td>The name of the Bitbucket pipeline stage. Transitioned to the <code>group</code> label of the corresponding Buildkite <a href="/docs/pipelines/configure/step-types/group-step">group step</a>.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.stage.steps</code></td>
      <td>Yes</td>
      <td>Individual step configuration for a Bitbucket pipeline stage. See configuration options in this section (<code>pipelines.default.step.&lt;property&gt;</code>) for the supported and unsupported properties.</td>
    </tr>
    <tr>
      <td><code>pipelines.&lt;start-condition&gt;.stage.trigger</code></td>
      <td>Yes</td>
      <td>The configuration setting for running of a Bitbucket pipeline stage manually or automatically (the default setting). For <code>manual</code> triggers, an <a href="/docs/pipelines/configure/step-types/input-step">input step</a> is inserted into the generated Buildkite pipeline's <a href="/docs/pipelines/configure/step-types/group-step">group step</a> before the specified <code>steps</code> of this stage. The explicit dependencies with <code>depends_on</code> are set between the input step and the following steps to ensure manual processing is required for these to run.</td>
    </tr>
  </tbody>
</table>



### Variables

| Key | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.variables` | Partially | Custom variables that are passed to Bitbucket pipeline steps. Each variable defined in a Bitbucket pipeline step is translated to a Buildkite [input step](/docs/pipelines/configure/step-types/input-step) with/without defaults and allowed values specified below. <br/><br/> Variables that are translated into the corresponding [input step](/docs/pipelines/configure/step-types/input-step) within the generated Buildkite pipeline will require to be fetched in subsequent steps through a `buildkite-agent meta-data get` [command](/docs/agent/v3/cli-meta-data#getting-data). |
| `pipelines.<start-condition>.variables.name` | Yes | The variables' name: translated to the `key` attribute of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step) (text entry).|
| `pipelines.<start-condition>.variables.default` | Yes | The default variable value if no value is set. Set as the `default` attribute within the `field` of an [input step](/docs/pipelines/configure/step-types/input-step). |
| `pipelines.<start-condition>.variables.description` | Yes | The description of the variable. Translated to the `text` attribute of a specific `field` within the generated  [input step](/docs/pipelines/configure/step-types/input-step). |
| `pipelines.<start-condition>.variables.allowed-values` | Yes | The variable's allowed values: each option is translated to a singular `options` object with given value of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step). |
