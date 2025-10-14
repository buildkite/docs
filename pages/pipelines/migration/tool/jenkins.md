# Jenkins

> 📘
> The Buildkite migration tool for Jenkins in currently in beta.

The [Buildkite migration tool](/docs/pipelines/migration/tool) helps you convert your Jenkins pipeline jobs into Buildkite pipelines. Both the Scripted and Declarative forms of Jenkins pipelines are supported. Because Jenkins pipelines can be written using the Groovy scripting language, their potential for complexity is much greater than that of other YAML-based CI configuration formats. Therefore, to get the best results in the translation process, we make use of an AI Large Language Model (LLM).

The LLM first analyzes the Jenkins pipeline to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline. Note: The AI model *does not* use any submitted data for its own training, and nothing that you submit is stored after the translation is complete.

As with any of the other CI systems we translate from ([GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)), there will be Jenkins pipeline features that don't have a direct equivalent in Buildkite Pipelines. In those cases, the migration tool will include comments in the output with suggestions about possible solutions you could explore.

The goal of the migration tool is to give you a starting point or framework of a pipeline, so you can see how patterns you're used to in Jenkins would function in Buildkite. As such, the tool will not try to convert your build's shell scripts or other complex logic automatically. Instead, it will generate placeholder steps for those items, so that you can see the structure of the pipeline working in Buildkite. You can then flesh out the details of an equivalent pipeline functionality at your own convenience and pace.

## Using the Buildkite migration tool with Jenkins pipelines

To start converting a Jenkins pipeline into Buildkite Pipelines format:

1. Open the [Buildkite migration interactive web tool](https://buildkite.com/resources/migrate/) in a new browser tab.
1. Ensure that **Jenkins** is selected at the top of the left panel.
1. Copy your Jenkins pipeline configuration and paste it into the left panel.
1. Select **Convert** to reveal the translated pipeline configuration in the **Buildkite Pipeline** panel.

> 📘
> Remember that not all the features of Jenkins pipelines can be fully converted to the Buildkite Pipelines format. See the following sections to learn more about the compatibility, workarounds, and limitations of converting Jenkins pipelines to Buildkite pipelines.

## Stages

The migration tool will start by examining the `stage {}` blocks in your Jenkins pipeline. If the stage only contains one step, that step will be translated on its own. If the stage includes multiple steps, those will be captured in a `group` block (see [Group step](/docs/pipelines/configure/step-types/group-step) for more details) in the Buildkite pipeline.

## Step concurrency

By default, Jenkins pipeline steps run serially, whereas Buildkite pipeline steps are executed in [parallel](/docs/pipelines/tutorials/parallel-builds). For consistency, your translated Jenkins pipeline will have `wait` steps (see [Wait step](/docs/pipelines/configure/step-types/wait-step) for more details) added, to maintain the existing serial execution. You can then remove any of the generated wait steps in case they are unnecessary, for example, if you have several different test suites which can safely run in parallel.

## Build parameters

Jenkins supports a variety of different build parameter types natively (`string`, `text`, `boolean`, `choice`, and `password`), with additional types possible with the use of plugin. Buildkite only supports `string` and `select` (see [Input step](/docs/pipelines/configure/step-types/input-step) for more details), so Jenkins parameters will be translated as follows:

| Parameter type | Conversion |
| --- | ---------- |
| String, text | String |
| Choice | Select |
| Boolean | Choice with true and false options |
| Password | Not supported; using [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) store is recommended instead |
| Others (plugins) | Not supported |
{: class="responsive-table"}

Also, note that Buildkite pipeline's input parameter values are stored as [build meta-data](/docs/pipelines/configure/build-meta-data), not as variables that can be used in the pipeline definition itself. The migration tool will provide guidance about best practices for using input values in your pipeline.
