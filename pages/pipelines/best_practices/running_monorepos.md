# Running monorepos

A monorepo development strategy means that the code for multiple projects is stored in a single, centralized version-controlled repository. This strategy provides advantages like easier code sharing, unified versioning, and consistent tooling, but it also poses challenges such as longer build times and potential conflicts if not managed effectively. This page is a collection of approaches and best practices for effectively managing and running monorepos.

## Approaches to running monorepos

All such approaches start with detecting changes in your monorepo, usually at the folder level. To detect these changes, you can use either the [`--apply_if_changed` option](/docs/agent/v3/cli-pipeline#apply-if-changed) on the [`pipeline upload` command](/docs/agent/v3/cli-pipeline) of the Buildkite Agent, or the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/).

> 📘
> In Buildkite Pipelines, you have the ability to structure your monorepo pipeline as a "single pipeline container of many pipelines" or a "single pipeline container of many steps" which have tradeoffs. Some users prefer the clean separation that "trigger another pipeline" provides, while others prefer the closeness provided by "all my steps conditionally run in the same pipeline depending on path." The Monorepo diff plugin supports either structuring of your pipeline.

There are two preferred approaches to running monorepos with Buildkite Pipelines:

- **Static**: a single diff pipeline triggers different static pipelines in your monorepo based on what parts of the monorepo were changed.
- **Dynamic**: [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) that inject specific steps into a single pipeline based on the changes in the monorepo. You will need to run bash scripts to inject steps according to the changes. You can also use the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) to inject steps dynamically in one of its supported programming languages of your choice.

Now, let's look into implementing these three possible approaches to running monorepos in more detail.

## Static pipelines approach

The static pipelines approach involves creating a single orchestrating pipeline that triggers other pipelines (predefined for different scenarios) in your monorepo.

A typical example of the static approach would be a single main pipeline that contains the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and, depending on what files get modified in the repository, this pipeline will trigger other pipelines. For example, see the [Monorepo example](https://buildkite.com/resources/examples/buildkite/monorepo-example/) pipeline.

> 🚧
> When using the static approach, the triggered pipeline must never be triggered directly by any means other than by its orchestrating pipeline.

## Dynamic pipelines approach

The dynamic pipelines approach involves writing dynamic pipeline steps in your programming language of choice, which injects specific steps into a single pipeline in your monorepo.

When implementing the dynamic pipelines approach, you can use either:

- [Direct scripting](/docs/pipelines/configure/dynamic-pipelines)
- [The Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

The common way to implement dynamic pipelines is to upload the generated YAML steps file as an artifact using the `buildkite-agent artifact upload` command. This allows you to download and review that YAML file later to see exactly what was generated.

> 📘 Dry-run preview
> If you want to preview the pipeline before it's uploaded, you can use `buildkite-agent pipeline upload --dry-run` command to output the final YAML without running it.

Buildkite customers who use [Bazel](/docs/pipelines/tutorials/bazel) and [Gradle](https://gradle.org/) prefer the dynamic approach since these build systems allow targeting certain steps once the diff that needs to be built is identified. These tools also allow you to map which tests to run on the paths that changed.

### Implementation with dynamic pipelines

This high-level example demonstrates a dynamic pipeline that analyzes Git changes to determine which projects need to be built, then constructs a dependency graph to ensure that the projects build in the correct order.

How it works:

1. Change detection stage - the pipeline analyzes Git diff to identify changed files.
1. Dependency resolution stage - a dependency graph is built to determine which projects need building.
1. Pipeline generation stage - a dynamic pipeline with proper job dependencies is created.
1. Parallel execution - independent projects build in parallel, respecting dependencies.

You can see an example of a dynamic pipelines-based approach in this [Bazel monorepo example](https://github.com/buildkite/bazel-monorepo-example).

This implementation is also valid if using Buildkite SDK.

### Using the Buildkite SDK

The [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) provides an SDK library of methods for a number of supported languages (that is, JavaScript/TypeScript, Python, Go, and Ruby), which you can use to help you dynamically generate Buildkite pipeline steps in YAML or JSON format, to upload back to your Buildkite pipeline. The Buildkite SDK acts as a translation layer, making it easier to generate Buildkite pipeline steps to re-upload to your pipeline, rather than having to manually script these pipeline steps yourself.

For example, if you need to detect changes in a Bazel- or Gradle-based monorepo, you could use the Buildkite SDK to dynamically generate the required pipeline steps based on the execution outcomes from your Bazel or Gradle build scripts.

## Combined approach

In your CI/CD process, you don't need to limit your options to a single one of these described approaches to working with a monorepo. Many customers, especially those with large Buildkite organizations, mix and combine static and dynamic approaches based on their specific requirements.
