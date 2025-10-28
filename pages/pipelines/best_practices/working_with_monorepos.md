# Working with monorepos

A monorepo development strategy means that the code for multiple projects is stored in a single, centralized version-controlled repository. This strategy provides advantages like easier code sharing, unified versioning, and consistent tooling, but it also poses challenges such as longer build times and potential conflicts if not managed effectively. This page covers approaches and best practices for effectively managing and running monorepos.

## Approaches to running monorepos

All such approaches start with detecting changes in your monorepo, usually at the folder level. To detect these changes, you can use either the [`--apply-if-changed` option](/docs/agent/v3/cli-pipeline#apply-if-changed) on the [pipeline upload command](/docs/agent/v3/cli-pipeline) of the Buildkite Agent to detect [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) usage in your pipeline steps, or the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/).

> 📘
> In Buildkite Pipelines, you have the ability to structure your monorepo pipeline as a single pipeline that orchestrates other pipelines by triggering them, or as a single pipeline containing many steps. Both approaches have tradeoffs. Some users prefer the clean separation that triggering pipelines by another provides, while others prefer all their steps to run conditionally in a single pipeline. The Monorepo diff plugin supports either method of structuring your pipelines.

There are two preferred approaches to running monorepos with Buildkite Pipelines:

- **Static**: a single diff pipeline triggers different static pipelines in your monorepo based on what parts of the monorepo were changed.
- **Dynamic**: [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) inject specific steps into a single pipeline based on the changes in the monorepo. You will need to run bash scripts to inject steps according to the changes. You can also use the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) to inject steps dynamically in one of its supported programming languages.

Now, let's look into implementing these possible approaches to working with monorepos in more detail.

## Static approach

The static approach to working with monorepos involves creating a single orchestrating pipeline that triggers other pipelines (predefined for different scenarios) in your monorepo.

A typical example of the static approach would be a single main pipeline that contains the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and, depending on what files get modified in the repository, this pipeline will trigger other pipelines. You can check out the [Monorepo example](https://buildkite.com/resources/examples/buildkite/monorepo-example/) pipeline to see a practical implementation.

> 🚧
> In the static monorepo approach, the triggered pipelines must only be triggered by the dedicated triggering pipeline and _never_ directly via the Buildkite interface, API, or other means. Direct execution bypasses the change detection logic, causing the pipeline to run without awareness of the changes in the monorepo, or the necessary build context from the triggering pipeline. This might lead to a number of unwanted consequences, such as build artifacts being generated with incorrect library versions.

## Dynamic approach

The dynamic approach to working with monorepos involves having dynamic pipelines that inject specific steps in the programming language of your choice into a single pipeline in your monorepo based on the detected changes.

When implementing the dynamic pipelines approach, you can use either:

- [Direct scripting](/docs/pipelines/configure/dynamic-pipelines)
- [The Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

A useful way to implement dynamic pipelines is to upload the generated YAML steps file as an artifact using the `buildkite-agent artifact upload` command. This allows you to download and review that YAML file later to see exactly what was generated.

> 📘 Dry-run preview
> If you want to preview the pipeline before it's uploaded, you can use `buildkite-agent pipeline upload --dry-run` command to output the final YAML without running it.

Buildkite customers who use [Bazel](/docs/pipelines/tutorials/bazel) and [Gradle](https://gradle.org/) prefer the dynamic approach since these build systems allow you to target certain steps once the diff that needs to be built is identified. These tools also allow you to map which tests to run on the paths that changed.

### Implementation with dynamic pipelines

You can see a hands-on implementation of the dynamic pipelines-based approach in this [Bazel monorepo example](https://github.com/buildkite/bazel-monorepo-example). The example analyzes Git changes to determine which projects need to be built, then constructs a dependency graph to ensure that the projects build in the correct order.

How the example works:

1. Change detection stage - the pipeline analyzes Git diff to identify changed files.
1. Dependency resolution stage - a dependency graph is built to determine which projects need building.
1. Pipeline generation stage - a dynamic pipeline with proper job dependencies is created.
1. Parallel execution - independent projects build in parallel, respecting dependencies.

Learn more about running through this example in [Creating dynamic pipelines and build annotations using Bazel](/docs/pipelines/tutorials/dynamic-pipelines-and-annotations-using-bazel). This implementation is also valid if using Buildkite SDK.

### Using the Buildkite SDK

The [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) provides an SDK library of methods for a number of supported languages (JavaScript/TypeScript, Python, Go, and Ruby), which you can use to help you dynamically generate Buildkite pipeline steps in YAML or JSON format, to upload to your Buildkite pipeline. The Buildkite SDK acts as a translation layer, making it easier to generate Buildkite pipeline steps to re-upload to your pipeline, rather than having to manually script these dynamic pipeline steps yourself.

For example, if you need to detect changes in a Bazel- or Gradle-based monorepo, you could use the Buildkite SDK to dynamically generate the required pipeline steps based on the execution outcomes from your Bazel or Gradle build scripts.

## Combined approach

In your CI/CD process, you don't need to limit your options to a single one of these described approaches to be working with a monorepo. Many customers, especially those with large Buildkite organizations, mix and combine static and dynamic approaches based on their specific requirements.
