# CircleCI

The [Buildkite migration tool](/docs/pipelines/migration/tool) helps you convert your CircleCI pipelines into Buildkite pipelines. This page lists the Buildkite migration tool's currently supported, partially supported, and unsupported CircleCI keys when translating from CircleCI pipeline configurations to Buildkite pipelines.

For any partially supported and unsupported **Key**s listed in the tables on this page, you should follow the instructions provided in their relevant **Notes**, for details on how to successfully complete their translation into a working Buildkite pipeline.

## Using the Buildkite migration tool with CircleCI

To start converting your CircleCI pipeline configurations into Buildkite Pipelines format:

1. Open the [Buildkite migration interactive web tool](https://buildkite.com/resources/migrate/) in a new browser tab.
1. Select **CircleCI** at the top of the left panel.
1. Copy your CircleCI pipeline configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

For example, when converting the following example CircleCI pipeline configuration:

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

The Buildkite migration tool should translate this to the following output:

```yml
---
steps:
- commands:
  - "# No need for checkout, the agent takes care of that"
  - echo '~~~ Install dependencies'
  - npm install
  plugins:
  - docker#v5.13.0:
      image: cimg/node:18.20
  agents:
    executor_type: docker
  key: build
```

The Buildkite migration tool interface should look similar to this:

<%= image "migration-tool-circleci.png", alt: "Converting a CircleCI pipeline in Buildkite migration tool's web UI" %>

You might need to adjust the converted Buildkite pipeline output to ensure it is consistent with the [step configuration conventions](/docs/pipelines/configure/step-types) used in Buildkite Pipelines.

The Buildkite migration tool supports the use of [YAML aliases in CircleCI pipeline configurations](https://circleci.com/docs/guides/getting-started/introduction-to-yaml-configurations/#anchors-and-aliases), which are reusable configuration snippets that can applied to specific points in a pipeline configuration. A YAML alias is defined by an `&` (anchor, for example, `&tests`) within the top-level `aliases` key and substituted into a CircleCI pipeline configuration with an `*` (for example, `*tests`). A configuration defined by an alias is respected and parsed at its specified section in the pipeline configuration. Also note that more complex (for example, multi-line) anchors defined as a YAML alias in a CircleCI pipeline configuration are expanded upon their translation into Buildkite pipeline format.

> 📘
> Remember that not all the features of CircleCI can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitation of converting CircleCI pipelines to Buildkite Pipelines.

## Logical operators (helpers)

| <div style="width: 50px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `and` | Partially | Logical operator for denoting that all inputs required to be true. Supported alongside the [`when` key within setting up conditional `workflow` runs](#workflows). |
| `or` | Partially | Logical operator for describing whether any of the inputs are true. Supported alongside the [`when` key within setting up conditional `workflow` runs](#workflows). |
| `not` | Partially | Logical operator for negating input. Supported alongside the [`when` key within setting up conditional `workflow` runs](#workflows). |
{: class="responsive-table"}

## Commands

| <div style="width: 80px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `commands` | Yes | A `command` defined in a CircleCI pipeline is a reusable set of instructions with parameters that can be inserted into required `job` executions. Commands can have their own lists of `steps` that are translated through to the generated [command step](/docs/pipelines/configure/step-types/command-step)'s `commands`. If a `command` contains a `parameters` key, these parameters are respected when used in jobs and workflows. When not specified, the parameters' default values are used. |
{: class="responsive-table"}

## Executors

| <div style="width: 80px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `executors` | Yes | The `executor` key defined at the top level in a CircleCI workflow is mapped to the use of the `executor` key specified within a specific `job`. Supported execution environments include `machine`, `docker`, `macos`, and `windows`. Further information can be found in the [Jobs > Executors](/docs/pipelines/migration/tool/circleci#jobs-executors) table below. The execution environment in Buildkite Pipelines is specified with each environment's applied [tags](/docs/agent/v3/cli-start#setting-tags) in their generated [command step](/docs/pipelines/configure/step-types/command-step), which can be [targeted](/docs/pipelines/configure/defining-steps#targeting-specific-agents) when creating builds. |
{: class="responsive-table"}

## Jobs

### General

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
        "key": "jobs.&lt;name&gt;",
        "supported": "Yes",
        "notes": "Named, individual `jobs` that make up a part of a given `workflow`."
      },
      {
        "key": "jobs.&lt;name&gt;.environment",
        "supported": "Yes",
        "notes": "The `job`-level environment variables of a CircleCI pipeline. Applied in the generated [command step](/docs/pipelines/configure/step-types/command-step) as [step-level environment variables](/docs/pipelines/environment-variables#runtime-variable-interpolation) with the `env` key."
      },
      {
        "key": "jobs.&lt;name&gt;.parallelism",
        "supported": "No",
        "notes": "A `parallelism` parameter (if greater than `1` is defined) will create a separate execution environment and will run the `steps` of the specific `job` in parallel. In Buildkite Pipelines, a similar `parallelism` key can be set to a [command step](/docs/pipelines/configure/step-types/command-step), which will run the defined `command` over separate jobs (sharing the same agent [queues](/docs/agent/v3/targeting/queues#setting-an-agents-queue) and [tags](/docs/agent/v3/cli-start#setting-tags) targeting)."
      },
      {
        "key": "jobs.&lt;name&gt;.parameters",
        "supported": "Yes",
        "notes": "Reusable keys that are used within `step` definitions within a `job`. Default parameters that are specified in a `parameters` block are passed through into the [command step](/docs/pipelines/configure/step-types/command-step)'s `commands` if specified."
      },
      {
        "key": "jobs.&lt;name&gt;.shell",
        "supported": "No",
        "notes": "The `shell` property sets the default shell that is used across all commands within all steps. This should be configured on the Buildkite Agent itself, or by defining the [`shell` option](/docs/agent/v3/cli-start#shell) when starting a Buildkite Agent, which sets the shell command used to interpret all build commands."
      },
      {
        "key": "jobs.&lt;name&gt;.steps",
        "supported": "Partially",
        "notes": "A collection of non-`orb` `jobs` commands that are executed as part of a CircleCI `job`. Steps can be defined within an `alias`. All the `steps` within a singular `job` are translated to the `commands` of a shared [command step](/docs/pipelines/configure/step-types/command-step) within the generated Buildkite pipeline to ensure they share the same execution environment."
      },
      {
        "key": "jobs.&lt;name&gt;.working_directory",
        "supported": "Yes",
        "notes": "The location of the executor where steps are run. If set, a \"change directory\" (`cd`) command is created within the shared `commands` of a Buildkite Pipelines' [command step](/docs/pipelines/configure/step-types/command-step) to the desired location."
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

### Executors

While the Buildkite migration tool will translate the following listed executor types, to use the generated steps in your translated Buildkite pipeline, your targeted agents must have the relevant operating system (OS), as well as dependencies, and tooling (for example, Docker or XCode) available on them. Buildkite offers the [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) as a fully scalable Buildkite Agent fleet on AWS with a suite of tooling installed by default. Additionally, customized agents can be [set up](/docs/agent/v3/self-hosted/configure) to target builds that requires a specific OS, tooling, or both. Or you can use [Buildkite hosted agents](/docs/pipelines/hosted-agents)—a fully-managed solution offered by Buildkite.

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
        "key": "jobs.&lt;name&gt;.docker",
        "supported": "Yes",
        "notes": "Specifies that the `job` will run within a Docker container (using the `image` property) with the help of the [Docker Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/) or [Docker Compose Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/). Additionally, the [Docker Login Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin/) is appended if an `auth` property is defined, or the [ECR Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/) if an `aws-auth` property is defined within the `docker` property. Sets the [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/configure/step-types/command-step) to `executor_type: docker`."
      },
      {
        "key": "jobs.&lt;name&gt;.executor",
        "supported": "Yes",
        "notes": "Specifies the execution environment based on an executor definition supplied in the top-level `executors` key."
      },
      {
        "key": "jobs.&lt;name&gt;.macos",
        "supported": "Yes",
        "notes": "Specifies that the `job` will run on a macOS-based execution environment. The [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/configure/step-types/command-step) will be set to `executor_type: osx` and the specified version of `xcode` from the `macos` parameters will be set as `executor_xcode: <version>`."
      },
      {
        "key": "jobs.&lt;name&gt;.machine",
        "supported": "Yes",
        "notes": "Specifies that the `job` will run on a machine execution environment. This translates to [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for the generated [command step](/docs/pipelines/configure/step-types/command-step) through the tags of `executor_type: machine` and `executor_image: self-hosted`."
      },
      {
        "key": "jobs.&lt;name&gt;.resource_class",
        "supported": "Yes",
        "notes": "The specification of compute that the executor will require for running a job. This is used to specify the `resource_class` [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tag for the corresponding [command step](/docs/pipelines/configure/step-types/command-step)."
      },
      {
        "key": "jobs.&lt;name&gt;.windows",
        "supported": "Yes",
        "notes": "Specifies that the `job` will run on a Windows-based execution environment. The [agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents) tags for the generated [command step](/docs/pipelines/configure/step-types/command-step) will be set to `executor_type: windows`."
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

## Orbs

| <div style="width: 90px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `orbs` | No | Orbs are currently not supported by the Buildkite migration tool and should be translated by hand if their equivalent functionality is required within a Buildkite pipeline. In Buildkite Pipelines, reusable [plugins](/docs/plugins/directory) can provide a similar functionality for integrating various common (and third-party integration-related) tasks throughout a Buildkite pipeline, such as [logging into ECR](https://buildkite.com/resources/plugins/buildkite-plugins/ecr-buildkite-plugin/), running a step within a [Docker container](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/), running multiple Docker images through a [compose file](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/), triggering builds in a [monorepo setup](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/), to list a small number of these plugins. |
| Docker `orbs` | Partially | Docker orbs are converted but their translation is only an approximation. It is recommended that you reconstruct any orb-related logic in a Buildkite pipeline instead based on the recommendations outlined in `orbs`. |
{: class="responsive-table"}

## Parameters

| <div style="width: 90px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `parameters` | No | Pipeline-level parameters that can be used in the pipeline-level configuration. Pipeline-level [environment variables](/docs/pipelines/environment-variables#defining-your-own) allow for utilizing variables in a Buildkite pipeline configuration with [conditionals](/docs/pipelines/configure/conditionals). |
{: class="responsive-table"}

## Setup

| <div style="width: 50px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `setup` | No | Allows for the conditional configuration trigger from outside the `.circleci` directory. While this is not directly compatible with Buildkite Pipelines, Buildkite Pipelines offers [trigger steps](/docs/pipelines/configure/step-types/trigger-step), which allow for triggering builds from another pipeline. |
{: class="responsive-table"}

## Version

| <div style="width: 70px;">Key</div> | Supported | Notes |
| --- | --- | --- |
| `version` | No | The version of the CircleCI pipeline configuration applied to this pipeline. Since Buildkite Pipelines is a fully-SaaS product, there is no equivalent mapping for this key in Buildkite Pipelines, and this key can generally be ignored. |
{: class="responsive-table"}

## Workflows

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
        "key": "workflows",
        "supported": "Yes",
        "notes": "A collection of `jobs` the order of which defines how a CircleCI pipeline is run."
      },
      {
        "key": "workflows.&lt;name&gt;",
        "supported": "Yes",
        "notes": "An individual named workflow that makes up a part of the CircleCI pipeline's definition. If a CircleCI pipeline has more than one `workflow` specified, each workflow will be transitioned to a [group step](/docs/pipelines/configure/step-types/group-step)."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs",
        "supported": "Yes",
        "notes": "The individually named, non-`orb` `jobs` that make up a part of a specific workflow.<br/><br/>Customized `jobs` defined as a part of a `workflow` will be translated to a Buildkite [command step](/docs/pipelines/configure/step-types/command-step) within the generated pipeline, and `jobs` with the `approval` type will be translated to a Buildkite [block step](/docs/pipelines/configure/step-types/block-step)."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.branches",
        "supported": "No",
        "notes": "The `branches` that will be allowed or blocked for a singular `job`. At the moment, the Buildkite migration tool supports setting `filters` within `workflows`, and in particular, sub-properties `branches` and `tags`  in setting a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps) in the generated pipeline."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.filters",
        "supported": "Yes",
        "notes": "The `branches` and `tag` filters that will determine the eligibility for a CircleCI to run."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.filters.branches",
        "supported": "Yes",
        "notes": "The specific `branches` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps)."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.filters.tags",
        "supported": "Yes",
        "notes": "The specific `tags` that are applicable to the `job`'s filter. Translated to a [step conditional](/docs/pipelines/configure/conditionals#conditionals-in-steps)."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.matrix",
        "supported": "Yes",
        "notes": "The `matrix` key allows running a specific job as part of a workload with different values. Translated to a [build matrix](/docs/pipelines/build-matrix) setup within a [command step](/docs/pipelines/configure/step-types/command-step)."
      },
      {
        "key": "workflows.&lt;name&gt;.jobs.&lt;name&gt;.requires",
        "supported": "Yes",
        "notes": "A list of `jobs` that require a certain `job` to start. Translated to explicit [step dependencies](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) with the `depends_on` key."
      },
      {
        "key": "workflows.&lt;name&gt;.when",
        "supported": "Yes",
        "notes": "Conditional execution key that allows workflows to run under certain conditions, such as those based on pipeline parameters. The Buildkite migration tool allows for the specification using [logical operators `and`, `or`, and `not`](#logical-operators-helpers) in creating command conditionals, and maps basic `when` conditions to Buildkite's conditional steps, though complex nested conditions may require manual adjustment."
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
