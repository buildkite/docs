# Bitbucket Pipelines

The [Buildkite pipeline converter](/docs/pipelines/migration/tool) helps you convert your Bitbucket pipelines into Buildkite pipelines. This page lists the Buildkite pipeline converter's currently supported, partially supported, and unsupported keys (known as _properties_ in Bitbucket Pipelines) when translating from Bitbucket pipelines to Buildkite pipelines.

For any partially supported and unsupported **Key**s listed in the tables on this page, you should follow the instructions provided in their relevant **Notes**, for details on how to successfully complete their translation into a working Buildkite pipeline.

> 📘
> The Bitbucket Pipeline configuration that is referred to in various sections below is specified in the central `bitbucket-pipelines.yml` within a specific Bitbucket workspace [repository](https://support.atlassian.com/bitbucket-cloud/docs/what-is-a-workspace/). In Buildkite, the pipeline configuration can be set in a singular `pipeline.yml` within a repository or it can also be set and uploaded dynamically through the use of [Dynamic Pipelines](/docs/pipelines/configure/dynamic-pipelines). Additionally, control and governance of Buildkite pipelines can be achieved through the use of [Pipeline Templates](/docs/pipelines/templates) to set shared pipeline configuration within a Buildkite organization.

## Using the Buildkite pipeline converter with Bitbucket

To start converting your Bitbucket pipeline into Buildkite Pipelines format:

1. Open the [Buildkite pipeline conversion interactive web tool](https://buildkite.com/resources/convert/) in a new browser tab.
1. Select **Bitbucket Pipelines** at the top of the left panel.
1. Copy your Bitbucket pipeline configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

You might need to adjust the converted Buildkite pipeline output to ensure it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) used in Buildkite Pipelines.

> 📘
> Remember that not all the features of Bitbucket can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting Bitbucket pipelines to Buildkite Pipelines.

## Clone

Bitbucket Pipelines' [`clone` property](https://support.atlassian.com/bitbucket-cloud/docs/git-clone-behavior/) provides options for controlling how a repository is cloned during a build.

| <div style="width: 50px;">Key</div>  | Supported | Notes |
| --- | --- | --- |
| `clone` | Partially | Clone options for all steps of a Bitbucket pipeline. The majority of these options need to be set on a Buildkite Agent itself through its [configuration of properties](/docs/agent/v3/self-hosted/configure) such as the clone flags (`git-clone-flags` or `git-clone-mirror-flags` if utilizing a Git mirror), fetch flags (`git-fetch-flags`) - or changing the entire checkout process in a customized [plugin](/docs/pipelines/integrations/plugins/writing) overriding the default agent `checkout` hook. <br/><br/> Sparse-checkout properties of `code-mode`, `enabled`, and `patterns` used in a Bitbucket pipeline will be translated to the respective properties within the [sparse-checkout-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/). <br/><br/> `clone` properties in a Bitbucket pipeline have higher precedence over these global properties. |
{: class="responsive-table"}

## Definitions

Bitbucket Pipelines' [`definitions` property](https://support.atlassian.com/bitbucket-cloud/docs/cache-and-service-container-definitions/) is used to define resources used elsewhere in a pipeline configuration.

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
        "key": "definitions",
        "supported": "Partially",
        "notes": "Customized definitions utilized in a Bitbucket pipeline. `caches` and `services` are supported for translation using the Buildkite pipeline converter."
      },
      {
        "key": "definitions.caches",
        "supported": "Partially",
        "notes": "Customized cache definitions that can be applied to specific Bitbucket pipeline steps - inclusive of folders, single file-cache, or multi-file cache. Targeted into specific steps with the `pipelines.default.step.caches.<name>` property, where the translation will utilize the [cache-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) that may require further setup and configuring around specific caching strategies."
      },
      {
        "key": "definitions.caches.&lt;name&gt;",
        "supported": "Yes",
        "notes": "A customized cache name applicable to one or more steps within a Bitbucket pipeline."
      },
      {
        "key": "definitions.caches.&lt;name&gt;.path",
        "supported": "Yes",
        "notes": "The path to a directory that needs to be cached."
      },
      {
        "key": "definitions.caches.&lt;name&gt;.key.files",
        "supported": "Partially",
        "notes": "The list of (one or more) files that are monitored for changes, and stored once the hash changes between file version changes. If multiple files are specified, then multiple cache-plugin definitions are set on the resulting Buildkite Pipelines command step (so the `manifest` properties between each will be different). <br/><br/> Note that this may cause issues if the same folder is being maintained by each cache definition."
      },
      {
        "key": "definitions.pipeline",
        "supported": "Partially",
        "notes": "Pipelines that are exported for reuse within the repositories of the same workspace. Similar functionality exists within Buildkite Pipelines, called [Pipeline templates](/docs/pipelines/templates)."
      },
      {
        "key": "definitions.services",
        "supported": "Partially",
        "notes": "Docker services that are defined and applied within a Bitbucket pipeline. Services defined in a corresponding Bitbucket pipeline step using the `pipelines.default.step.services` property will have this configuration applied with the use of the [docker-compose-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/). <br/><br/> The generated configuration will need to be saved to a `compose.yaml` file within the repository, and the image utilized by the Buildkite Pipelines command step as `app`. <br/><br/> Refer to the Bitbucket Pipelines' [Databases and service containers](https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/) documentation for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline even if defined."
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

## Export

| <div style="width: 70px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `export` | No | Bitbucket Premium option for sharing pipeline configurations between workspaces. Not applicable within Buildkite as an attribute. However, similar functionality exists in Buildkite Pipelines using [Pipeline templates](/docs/pipelines/templates). |
{: class="responsive-table"}

## Image

Bitbucket Pipelines' [`image` property](https://support.atlassian.com/bitbucket-cloud/docs/docker-image-options/) is used to specify public images or private images, and supports a number of sub-properties.

| <div style="width: 110px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `image` | Yes | The container image that applies to each step within a Bitbucket pipeline, using the image specified within the [docker-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/). This has a lower precedence over a per-step `image` configuration (see `pipelines.default.step.image`). |
| `image.aws`<br/>`image.aws.oidc`<br/>`image.name`<br/>`image.username`<br/>`image.password` | Partially | Supported through the use of the corresponding plugin ([Docker Login](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin) or [ECR](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/)). |
{: class="responsive-table"}

## Options

Bitbucket Pipelines' [`options` property](https://support.atlassian.com/bitbucket-cloud/docs/docker-image-options/) contains global settings that apply throughout a pipeline, or all of a repository's pipelines.

| <div style="width: 110px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `options` | Partially | Customized options utilized throughout a Bitbucket pipeline. |
| `options.max-time` | Partially | This property is supported for translation within the Buildkite pipeline converter into the generated Buildkite Pipelines command step's `timeout_in_minutes`. |
| `options.size`| Partially | This property is supported for translation within the Buildkite pipeline converter into the generated Buildkite Pipelines command step's agent tag. |
| `options.docker` | No | This property is not supported and will depend on the agent configuration the corresponding Buildkite Pipelines command step is being targeted to run said job has available. |
{: class="responsive-table"}

Note that both of these partially supported properties, when defined at the Bitbucket pipeline step-level, will have a higher precedence than when these properties are set at `options` level.

## Pipeline starting conditions

Bitbucket Pipelines allows the configuration of various [pipeline start conditions](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/), with each condition supporting different configurations and permissible properties, listed in the following set of tables, such as [`branches`](#pipeline-starting-conditions-branches), [`custom`](#pipeline-starting-conditions-custom), [`default`](#pipeline-starting-conditions-default), [`pull-requests`](#pipeline-starting-conditions-pull-requests), and [`tags`](#pipeline-starting-conditions-tags).

### Branches

Bitbucket Pipelines' [`branches` property](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Branches) defines all branch-specific build pipelines.

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
        "key": "pipelines.branches",
        "supported": "Yes",
        "notes": "Application of a specific Bitbucket pipeline configuration for specific branches. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `build.branch`/`BUILDKITE_BRANCH` variable."
      },
      {
        "key": "pipelines.branches.&lt;branch&gt;",
        "supported": "Yes",
        "notes": "The branch name or a wildcard where a specific Bitbucket pipeline step configuration needs to be applied."
      },
      {
        "key": "pipelines.branches.&lt;branch&gt;.parallel",
        "supported": "Yes",
        "notes": "Parallel (concurrent) step configuration for a specific branch within a Bitbucket pipeline. See more information regarding the available [pipeline parallel properties](#pipeline-properties-parallel) supported by the Buildkite pipeline converter and additional property information in the Bitbucket Pipelines' [Parallel step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) documentation."
      },
      {
        "key": "pipelines.branches.&lt;branch&gt;.step",
        "supported": "Yes",
        "notes": "Individual step configuration for a specific branch within a Bitbucket pipeline. See more information regarding the available [pipeline step properties](#pipeline-properties-step) supported by the pipeline converter, and additional property information in the Bitbucket Pipelines' [Step property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) documentation."
      },
      {
        "key": "pipelines.branches.&lt;branch&gt;.stage",
        "supported": "Yes",
        "notes": "Stage configuration for a specific branch within a Bitbucket pipeline. See the available [pipeline stage properties](#pipeline-properties-stage) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Stage options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) documentation."
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

### Custom

Bitbucket Pipelines' [`custom` property](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipelines) is used to define pipelines that can only be triggered manually.

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
        "key": "pipelines.custom",
        "supported": "Yes",
        "notes": "Bitbucket pipelines that can only be triggered manually. The corresponding Buildkite pipeline is first generated with an [input step](/docs/pipelines/configure/step-types/input-step) before any command jobs, to ensure that the triggered builds are processed manually."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;",
        "supported": "Yes",
        "notes": "The name of the custom Bitbucket pipeline."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;.import-pipeline.import",
        "supported": "No",
        "notes": "The specification of importing a pipeline from within a specific repository defined in top-level `definitions`. Consider using [trigger steps](/docs/pipelines/configure/step-types/trigger-step) to invoke builds on a specific Buildkite pipeline."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;.parallel",
        "supported": "Yes",
        "notes": "Parallel (concurrent) step configuration for a custom Bitbucket pipeline. See the available [pipeline parallel properties](#pipeline-properties-parallel) supported by the Buildkite pipeline converter as well as the additional property information in the Bitbucket Pipelines' [Parallel step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) documentation."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;.stage",
        "supported": "Yes",
        "notes": "Stage configuration for a custom Bitbucket pipeline. See the available [pipeline stage properties](#pipeline-properties-stage) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Stage options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) documentation."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;.step",
        "supported": "Yes",
        "notes": "Individual step configuration for a custom Bitbucket pipeline. See the available [pipeline step properties](#pipeline-properties-step) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Step property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) documentation."
      },
      {
        "key": "pipelines.custom.&lt;name&gt;.variables",
        "supported": "Partially",
        "notes": "Variable configuration for a custom Bitbucket pipeline. See the available [pipeline variable properties](#pipeline-properties-variables) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Custom (manual) pipeline variables](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables) documenation."
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

### Default

Bitbucket Pipelines' [`default` property](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Default) contains the pipeline definition for all branches that don't match a pipeline definition in other sections.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:35%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:55%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.default",
        "supported": "Yes",
        "notes": "Bitbucket pipeline configuration that does not meet a specific condition."
      },
      {
        "key": "pipelines.default.parallel",
        "supported": "Yes",
        "notes": "Parallel (concurrent step) configuration for default Bitbucket pipelines. See the available [pipeline parallel properties](#pipeline-properties-parallel) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Parallel step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) documentation."
      },
      {
        "key": "pipelines.default.stage",
        "supported": "Yes",
        "notes": "Stage configuration for default Bitbucket pipelines. See the available [pipeline stage properties](#pipeline-properties-stage) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Stage options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) documentation."
      },
      {
        "key": "pipelines.default.step",
        "supported": "Yes",
        "notes": "Individual step configuration for default Bitbucket pipelines. See the available [pipeline step properties](#pipeline-properties-step) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Step property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) documentation."
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

### Pull requests

Bitbucket Pipelines' [`pull-requests` property](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Pull-Requests) defines pipelines that only run when a pull request is created.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:35%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:55%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.pull-requests",
        "supported": "Yes",
        "notes": "Application of specific Bitbucket pipeline configuration based for pull requests. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `pull_request.id`/`BUILDKITE_PULL_REQUEST` and `build.branch`/`BUILDKITE_BRANCH` variables."
      },
      {
        "key": "pipelines.pull-requests.&lt;branch&gt;",
        "supported": "Yes",
        "notes": "The base branch name or a wildcard to be applied within a specific Bitbucket pipeline step configuration. To apply the configuration for all builds, use a `**` wildcard."
      },
      {
        "key": "pipelines.pull-requests.&lt;branch&gt;.parallel",
        "supported": "Yes",
        "notes": "Parallel (concurrent) step configuration for pull request builds of a Bitbucket pipeline. See the available [pipeline parallel properties](#pipeline-properties-parallel) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Parallel step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) documentation."
      },
      {
        "key": "pipelines.pull-requests.&lt;branch&gt;.stage",
        "supported": "Yes",
        "notes": "Stage configuration for pull request builds of a Bitbucket pipelines. See the available [pipeline stage properties](#pipeline-properties-stage) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Stage options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) documentation."
      },
      {
        "key": "pipelines.pull-requests.&lt;branch&gt;.step",
        "supported": "Yes",
        "notes": "Individual step configuration for pull requests builds within a Bitbucket pipeline. See the available [pipeline step properties](#pipeline-properties-step) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Step property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) documentation."
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

### Tags

Bitbucket Pipelines' [`tags` property](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Tags) defines all tag-specific build pipelines.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:40%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:50%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.tags",
        "supported": "Yes",
        "notes": "Application of a specific Bitbucket pipeline configuration based on triggered tag builds. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the corresponding Buildkite pipeline utilizing the `build.tag`/`BUILDKITE_TAG` variable."
      },
      {
        "key": "pipelines.tags.&lt;tag&gt;",
        "supported": "Yes",
        "notes": "The tag name or a wildcard to be applied within a specific Bitbucket pipeline step configuration."
      },
      {
        "key": "pipelines.tags.&lt;tag&gt;.parallel",
        "supported": "Yes",
        "notes": "Parallel (concurrent) step configuration for tag builds of a Bitbucket pipeline. See the available [pipeline parallel properties](#pipeline-properties-parallel) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Parallel step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) documentation."
      },
      {
        "key": "pipelines.tags.&lt;tag&gt;.stage",
        "supported": "Yes",
        "notes": "Stage configuration for tag builds of a Bitbucket pipeline. See the available [pipeline stage properties](#pipeline-properties-stage) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Stage options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) documentation."
      },
      {
        "key": "pipelines.tags.&lt;tag&gt;.step",
        "supported": "Yes",
        "notes": "Individual step configuration for tag builds within a Bitbucket pipeline. See the available [pipeline step properties](#pipeline-properties-step) supported by the Buildkite pipeline converter, and additional property information in the Bitbucket Pipelines' [Step property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) documentation."
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

## Pipeline properties

Each [pipeline starting condition](#pipeline-starting-conditions) in Bitbucket can support various pipeline properties like [`parallel`](#pipeline-properties-parallel), [`step`](#pipeline-properties-step), [`stage`](#pipeline-properties-stage), and [`variables`](#pipeline-properties-variables).

Additionally, implementation of these pipeline properties can be enhanced with best practices by using [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to generate and upload pipeline configuration dynamically and using [conditionals](/docs/pipelines/configure/conditionals#conditionals-in-pipelines) at both pipeline level and step level to apply jobs only when certain conditions are met, and setting [trigger steps](/docs/pipelines/configure/step-types/trigger-step) with required attributes and environment variable configurations passed through to the triggered builds.

### Parallel

Bitbucket Pipelines' [`parallel` step options](https://support.atlassian.com/bitbucket-cloud/docs/parallel-step-options/#Parallel) allow faster building and testing of code by running a list of steps concurrently.

| <div style="width: 120px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `pipelines.<start-condition>.parallel` | Yes | The grouping of multiple steps within a Bitbucket pipeline to be run concurrently. By default, Buildkite executes steps in parallel, unless [implicit or explicit dependencies](/docs/pipelines/dependencies) are set. Parallel Bitbucket pipeline steps are transitioned into a [group step](/docs/pipelines/configure/step-types/group-step) within the generated Buildkite pipeline without explicit dependencies. |
| `pipelines.<start-condition>.parallel.fail-fast` | No | Whether a Bitbucket pipeline allows this parallel step to fail entirely if it fails (set as `true`), or allows failures (set as `false`). Consider using a combination of `soft_fail` and/or `cancel_on_build_failing` in the corresponding Buildkite Pipelines command steps' [attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes) for a similar [approach](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs). |
{: class="responsive-table"}

### Step

Bitbucket Pipelines' [`step` property options](https://support.atlassian.com/bitbucket-cloud/docs/step-options/#The-Step-property) are used to define build execution units.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:40%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:50%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.&lt;start-condition&gt;.step.after-script",
        "supported": "No",
        "notes": "The actions that a Bitbucket pipeline will undertake after the commands in the `script` key are run. For similar behavior in Buildkite Pipelines, use a [repository-level](/docs/agent/v3/self-hosted/hooks#hook-locations-repository-hooks) `pre-exit` hook running at the latter end of the [job lifecycle](/docs/agent/v3/self-hosted/hooks#job-lifecycle-hooks)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.artifacts",
        "supported": "Partially",
        "notes": "Build artifacts that will be required for steps later in the Bitbucket pipeline (by default, not obtained unless an explicit `buildkite-agent artifact download` [command](/docs/agent/v3/cli/reference/artifact#downloading-artifacts) is run beforehand within the generated Buildkite Pipelines command step). Artifacts that are specified (whether one specific file, or multiple) will be set within the generated command step within the `artifact_paths` [key](/docs/pipelines/configure/step-types/command-step). Each file found matching (or via glob syntax) will be uploaded to Buildkite's [Artifact storage](/docs/agent/v3/cli/reference/artifact) that can be obtained in later steps."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.caches",
        "supported": "Yes",
        "notes": "Step-level dependencies downloaded from external sources (for example, Docker, Maven, PyPi) which can be reused in later Bitbucket pipeline steps. Caches that are set at step level (or through the top-level `definition.cache.<name>` property) are translated in the corresponding Buildkite pipeline utilizing the [cache-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/) to store the downloaded dependencies for reuse between Buildkite builds."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.condition",
        "supported": "Partially",
        "notes": "The configuration for preventing a Bitbucket pipeline step from running unless the specific conditional is met. Translated to an inline conditional (`if`) within the corresponding Buildkite pipelines' command step's `commands`, based on a `git diff` of the base branch."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.condition.changeset.includePaths",
        "supported": "Partially",
        "notes": "The specific file (or files) that need to be detected as changed for the `condition` to apply. This can be set as specific files – or wildcards that match multiple files in a specific directory/directories. <br/><br/> Translated to a script that will review the changed files through git. This means that the step itself will actually run and just be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the [monorepo-diff-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and watching specific folders or files and then uploading the resulting [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) upon a diff detection."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.clone",
        "supported": "Partially",
        "notes": "Clone options for a specific step of a Bitbucket pipeline. The majority of these options should be set directly on a Buildkite Agent via [configuration](/docs/agent/v3/self-hosted/configure) of properties such as the clone flags (`git-clone-flags`, `git-clone-mirror-flags` if utilizing a Git mirror), fetch flags (`git-fetch-flags`) – or changing the entire checkout process in a customized [plugin](/docs/pipelines/integrations/plugins/writing) overriding the default agent `checkout` hook. Sparse checkout options are supported (with the `sparse-checkout` sub-property)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.deployment",
        "supported": "No",
        "notes": "The environment set for the Bitbucket Deployments dashboard that has no translatable equivalent within Buildkite Pipelines."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.docker",
        "supported": "No",
        "notes": "The availability of Docker in a specific Bitbucket pipeline step. This will depend on the agent configuration that the corresponding Buildkite command step is being targeted to run the job. Consider [tagging](/docs/agent/v3/cli/reference/start#tags) agents with `docker=true` to ensure Buildkite Pipelines command steps requiring hosts with Docker installed and configured to accept and run specific jobs."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.fail-fast",
        "supported": "No",
        "notes": "Whether a specific step of a Bitbucket pipeline allows a parallel step to fail entirely if it fails (set as `true`), or allows failures (set as `false`). Consider using a combination of `soft_fail` and/or `cancel_on_build_failing` in the corresponding Buildkite Pipelines command steps' [attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes) for a similar [approach](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.image",
        "supported": "Yes",
        "notes": "The container image that is to be applied to a specific step within a Bitbucket pipeline. Images set at this level will be applied irrespective of the pipeline-level `image` key, and will be applied in the corresponding Buildkite pipeline using the [docker-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/). <br/><br/> The `aws`, `aws.oidc`, `name`, `username`, and `password` sub-properties are supported through the use of the corresponding plugin ([Docker Login](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin) or [ECR](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/))."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.max-time",
        "supported": "Yes",
        "notes": "The maximum allowable time that a step within a Bitbucket pipeline is able to run for. Translates to the corresponding Buildkite Pipelines command step `timeout_in_minutes` attribute."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.name",
        "supported": "Yes",
        "notes": "The name of a specific step within a Bitbucket pipeline. Translates to a Buildkite command step's `label`."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.oidc",
        "supported": "Yes",
        "notes": "Open ID Connect configuration that will be applied for this Bitbucket pipeline step. The generated command step in the corresponding Buildkite pipeline will [request](/docs/agent/v3/cli/reference/oidc#request-oidc-token) an OIDC token and export it into the job environment as `BITBUCKET_STEP_OIDC_TOKEN` (to be passed to `sts` to assume an AWS role for example)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.runs-on",
        "supported": "Yes",
        "notes": "Allocating the Bitbucket pipeline to run on a self-hosted runner with the specific label. All `runs-on` values will be set as agent [tags](/docs/pipelines/configure/defining-steps#targeting-specific-agents) in the Buildkite command step for targeting on specific Buildkite Agents within an organization."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.services",
        "supported": "Partially",
        "notes": "The name of one or more services defined at `definitions.services.<name>` that will be applied for this step. Translated to utilize the service configuration with the [docker-compose-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/). <br/><br/> Generated configuration will need to be saved to a `compose.yaml` file within the repository, and the image utilized with the Buildkite command step as `app`. <br/><br/> Refer to the Bitbucket Pipelines' [Databases and service containers](https://support.atlassian.com/bitbucket-cloud/docs/databases-and-service-containers/) documentation for more details on service containers and configuration references. <br/><br/> Authentication-based parameters will not be translated to the corresponding Buildkite pipeline if defined."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.script",
        "supported": "Yes",
        "notes": "The individual commands that make up a specific step. Each is translated into a singular command within the `commands` key of a Buildkite command step."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.script.pipe",
        "supported": "No",
        "notes": "Reusable modules to make configuration in Bitbucket pipelines easier and modular. Consider exploring the suite of available [Buildkite Plugins](/docs/pipelines/integrations/plugins) for corresponding functionality that is required."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.size",
        "supported": "Yes",
        "notes": "Allocation of sizing options for the given memory for a specific step within a Bitbucket pipeline. The `size` value will be set as an agent [tag](/docs/pipelines/configure/defining-steps#targeting-specific-agents) in the Buildkite command step for targeting on specific Buildkite agents within an organization."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.step.trigger",
        "supported": "Yes",
        "notes": "The configuration setting for running of a Bitbucket pipeline step manually or automatically (the default setting). For `manual` triggers, an [input step](/docs/pipelines/configure/step-types/input-step) is inserted into the generated Buildkite pipeline before the specified `script` within a further command step. Explicit dependencies with `depends_on` are set between the two steps; requires manual processing."
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

### Stage

Bitbucket Pipelines' [`stage` options](https://support.atlassian.com/bitbucket-cloud/docs/stage-options/#Stage) allow the grouping of pipeline steps with shared properties.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:40%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:50%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.&lt;start-condition&gt;.stage",
        "supported": "Yes",
        "notes": "The logical grouping of one or more Bitbucket pipeline steps. Bitbucket pipeline stages are translated into the corresponding Buildkite pipeline as a [group step](/docs/pipelines/configure/step-types/group-step)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.stage.condition.changeset.includePaths",
        "supported": "Partially",
        "notes": "The specific file (or files) that need to be detected as changed for the `condition` to apply. This can be set as specific files or wildcards that match multiple files in the specific directories. <br/><br/> Translated into a script that will review the changed files through git. This means that the step itself will actually run and will be marked as passed, which may not be what you want or need. <br/><br/> You may want to consider utilizing the [monorepo-diff-buildkite-plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and watching for specific folders and files and uploading the resulting [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) upon diff detection."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.stage.name",
        "supported": "Yes",
        "notes": "The name of the Bitbucket pipeline stage. Transitioned to the `group` label of the corresponding Buildkite [group step](/docs/pipelines/configure/step-types/group-step)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.stage.steps",
        "supported": "Yes",
        "notes": "Individual step configuration for a Bitbucket pipeline stage. See the configuration options in this section (`pipelines.default.step.<property>`) for the supported and unsupported properties."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.stage.trigger",
        "supported": "Yes",
        "notes": "The configuration setting for running of a Bitbucket pipeline stage manually or automatically (the default setting). For `manual` triggers, an [input step](/docs/pipelines/configure/step-types/input-step) is inserted into the generated Buildkite pipeline's [group step](/docs/pipelines/configure/step-types/group-step) before the specified `steps` of this stage. The explicit dependencies with `depends_on` are set between the input step and the following steps to ensure manual processing is required for these to run."
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

### Variables

Bitbucket Pipelines' [Custom (manual) pipeline variables](https://support.atlassian.com/bitbucket-cloud/docs/pipeline-start-conditions/#Custom--manual--pipeline-variables) allow defined variables to be set or updated when a custom pipeline is run.

<table class="responsive-table">
  <thead>
    <tr>
      <th style="width:40%">Key</th>
      <th style="width:10%">Supported</th>
      <th style="width:50%">Notes</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "key": "pipelines.&lt;start-condition&gt;.variables",
        "supported": "Partially",
        "notes": "Custom variables that are passed to Bitbucket pipeline steps. Each variable defined in a Bitbucket pipeline step is translated to a Buildkite [input step](/docs/pipelines/configure/step-types/input-step) with/without defaults and allowed values specified below. <br/><br/> Variables that are translated into the corresponding [input step](/docs/pipelines/configure/step-types/input-step) within the generated Buildkite pipeline will require to be fetched in subsequent steps through a `buildkite-agent meta-data get` [command](/docs/agent/v3/cli/reference/meta-data#getting-data)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.variables.name",
        "supported": "Yes",
        "notes": "The variables' name: translated to the `key` attribute of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step) (text entry)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.variables.default",
        "supported": "Yes",
        "notes": "The default variable value if no value is set. Set as the `default` attribute within the `field` of an [input step](/docs/pipelines/configure/step-types/input-step)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.variables.description",
        "supported": "Yes",
        "notes": "The description of the variable. Translated to the `text` attribute of a specific `field` within the generated  [input step](/docs/pipelines/configure/step-types/input-step)."
      },
      {
        "key": "pipelines.&lt;start-condition&gt;.variables.allowed-values",
        "supported": "Yes",
        "notes": "The variable's allowed values: each option is translated to a singular `options` object with given value of a specific `field` of an [input step](/docs/pipelines/configure/step-types/input-step)."
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
