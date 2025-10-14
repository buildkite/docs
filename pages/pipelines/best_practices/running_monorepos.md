# Running monorepos

Monorepo development strategy means that the code for multiple projects is stored in a single, centralized version-controlled repository. This provides advantages like easier code sharing, unified versioning, and consistent tooling, as well as pose challenges such as longer build times and potential conflicts if not managed effectively. This page is a collection of best practices for effectively managing and running monorepos.

## Approaches to running monorepos

There are three preferred approaches to running monorepos with Buildkite Pipelines:

- Static - by having a single pipeline that triggers other pipelines when it detects changes in the monorepo.
- Dynamic - by using [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines) that inject specific steps into a single pipeline based on the changes in the monorepo.
- [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)-based approach - a version of the dynamic approach.

Let's look into how to implement these approaches in more detail.

## Static approach

Static approach to monorepos means having a pipeline that triggers other pipelines based on the detected changes.

In Buildkite Pipelines, you have the ability to structure your monorepo pipeline as a "single pipeline container of many pipelines" or a "single pipeline container of many steps" which have tradeoffs. Some users prefer the clean separation that "trigger another pipeline" provides, while others prefer the closeness provided by "all my steps conditionally run in the same pipeline depending on path." The [monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) supports either structuring of your pipeline.

You will need to have a pipeline that has a [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) running - this pipeline is the one that triggers other static pipelines.

A typical example of the static approach would be a single main pipeline that contains the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and, depending on what files get modified in the repository, this pipeline will trigger other pipelines.

Some considerations:

- In the static monorepo approach, the triggered pipeline must never be triggered directly.
- To have commit statuses from the pipelines that are triggered, the pull requests will have to be made against your monorepo.

Potential issues in this approach:

- Path-based triggering
- Build avoidance configuration (needs explanation)
- Dynamic pipeline generation
- Selective testing
- Monorepo-diff plugin setup

Alternatively, in the static approach, instead of using the monorepo diff plugin, you can use  [`if_changed`](/docs/agent/v3/cli-pipeline#apply-if-changed) feature on the agent.

## Dynamic approach

Dynamic approach to monorepo means having dynamic pipelines that inject specific steps into a single pipeline based on the detected changes.

To implement this, you can use:

- Both monorepo and dynamic steps in same pipeline
- Buildkite [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

The common approach is uploading the generated YAML as an artifact using `buildkite-agent artifact upload`. This allows you to download and review it later to see exactly what was generated. If you want to preview the pipeline before it's uploaded, you can use `buildkite-agent pipeline upload --dry-run` to output the final YAML without running it.

### Implementation with dynamic pipelines

This high-level example demonstrates a dynamic pipeline that analyzes git changes to determine which projects need to be built, then constructs a dependency graph to ensure projects build in the correct order.

How it works:

1. Change detection stage - the pipeline analyzes `git diff` to identify changed files.
1. Dependency resolution stage - a dependency graph is built to determine which projects need building.
1. Pipeline generation stage - a dynamic pipeline with proper job dependencies is created.
1. Parallel execution - independent projects build in parallel, respecting dependencies.

You can see an example of a dynamic pipelines-based approach in this [Bazel monorepo example](https://github.com/buildkite/bazel-monorepo-example).

## The SDK approach

In the SDK-based monorepo strategy, dynamic steps that are not injected based on the changed files but are injected using the [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

## Combined approach

In your CI/CD process, you don't need to limit your options to either of the approaches to monorepo as many customers, especially those with large Buildkite organizations, are known to mix and combine static and dynamic approaches based on their needs using both the monorepo diff plugin and dynamic pipelines.
