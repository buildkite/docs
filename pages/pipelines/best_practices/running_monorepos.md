# Running monorepos

Monorepo development strategy means that the code for multiple projects is stored in a single, centralized version-controlled repository. This provides advantages like easier code sharing, unified versioning, and consistent tooling, as well as pose challenges such as longer build times and potential conflicts if not managed effectively. This page is a collection of best practices for effectively managing and running monorepos.

## Approaches to running monorepos

There are three preferred approaches to running monorepos with Buildkite Pipelines:

- Static - a single diff pipeline that triggers different static pipelines in your monorepo based on what parts of the monorepo were changed.
- Dynamic - [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines) that inject specific steps into a single pipeline based on the changes in the monorepo. You will need to run bash scripts to inject steps according to the changes.
- [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)-based approach - by using the Buildkite SDK to inject steps dynamically in the programming language of your choice.

All the approaches start with detecting changes in your monorepo, usually at the folder level. To detect these changes, you can use either [`if_changed`](/docs/agent/v3/cli-pipeline#apply-if-changed) feature on the agent or the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/).

In Buildkite Pipelines, you have the ability to structure your monorepo pipeline as a "single pipeline container of many pipelines" or a "single pipeline container of many steps" which have tradeoffs. Some users prefer the clean separation that "trigger another pipeline" provides, while others prefer the closeness provided by "all my steps conditionally run in the same pipeline depending on path." The monorepo diff plugin supports either structuring of your pipeline.

Now, let's look into how to implement the three possible approaches to running monorepos in more detail.

## Static approach

Static approach to monorepos means having a single pipeline that triggers other pipelines (pre-created for different scenarios in your monorepo) based on the detected changes.

A typical example of the static approach would be a single main pipeline that contains the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and, depending on what files get modified in the repository, this pipeline will trigger other pipelines. See a [Monorepo example](https://buildkite.com/resources/examples/buildkite/monorepo-example/).

Some considerations:

- In the static monorepo approach, the triggered pipeline must never be triggered directly.
- To have commit statuses from the pipelines that are triggered, the pull requests will have to be made against your monorepo.

## Dynamic approach

Dynamic approach to monorepo means having dynamic pipelines that inject specific steps into a single pipeline based on the detected changes.

When implementing the dynamic approach, you can use:

- Both monorepo diff plugin and dynamic steps in same pipeline
- Buildkite [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

The common approach is uploading the generated YAML as an artifact using `buildkite-agent artifact upload`. This allows you to download and review it later to see exactly what was generated. If you want to preview the pipeline before it's uploaded, you can use `buildkite-agent pipeline upload --dry-run` to output the final YAML without running it.

Buildkite customers who use [Bazel](/docs/pipelines/tutorials/bazel) and [Gradle](https://gradle.org/) prefer the dynamic approach since these build systems allow targeting certain steps once the diff that needs to be built is identified. These tools also allow you to map which tests to run on the paths that changed.

### Implementation with dynamic pipelines

This high-level example demonstrates a dynamic pipeline that analyzes git changes to determine which projects need to be built, then constructs a dependency graph to ensure projects build in the correct order.

How it works:

1. Change detection stage - the pipeline analyzes `git diff` to identify changed files.
1. Dependency resolution stage - a dependency graph is built to determine which projects need building.
1. Pipeline generation stage - a dynamic pipeline with proper job dependencies is created.
1. Parallel execution - independent projects build in parallel, respecting dependencies.

You can see an example of a dynamic pipelines-based approach in this [Bazel monorepo example](https://github.com/buildkite/bazel-monorepo-example).

This implementation is also valid for the SDK approach.

## The SDK approach

In the [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)-based monorepo strategy, you also first need to detect the changes and then inject steps dynamically, using Bazel and Gradle or shell. SDK acts as a translation layer to allow you to do this.

## Combined approach

In your CI/CD process, you don't need to limit your options to either of the approaches to monorepo as many customers, especially those with large Buildkite organizations, are known to mix and combine static and dynamic approaches based on their needs using both static and dynamic pipelines.
