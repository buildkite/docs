# Running monorepos

A monorepo development strategy assumes stores the code for multiple projects in a single, centralized version-controlled repository. This provides advantages like easier code sharing, unified versioning, and consistent tooling, but can also pose challenges such as longer build times and potential conflicts if not managed effectively. This page is a collection of best practices regarding effectively managing and running monorepos.

There are two preferred approaches to running monorepos:

* Having a single pipelines that triggers other pipelines when it detects changes in the mono repository.
* Using [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines) the inject specific steps into a single pipeline based on the changes in the mono repository.

Let's look into both approaches in more detail.

## A pipeline that triggers other pipelines based on detected changes

Have a pipeline that has a [monorepo diff](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) running that triggers other static pipelines.

For example: you have a monorepo with the following, rather standard configuration:
One main pipeline with the monorepo plugin that triggers other pipelines depending on what files are modified.
You would like the pull requests against your monorepo to have commit statuses from the pipelines that are triggered.

In Buildkite pipelines, you have the ability to structure your monorepo pipeline as a "single pipeline container of many pipelines" or a "single pipeline container of many steps" which have tradeoffs. Some users prefer the clean separation that "trigger another pipeline" provides, while others prefer the closeness provided by "all my steps conditionally run in the same pipeline depending on path." The [monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) supports either structuring of your pipeline.

[walkthrough of the setup as the triggered pipeline must never be triggered directly].

Potential issues in this approach:

* Path-based triggering
* Build avoidance configuration
* dynamic pipeline generation
* selective testing
* monorepo-diff plugin setup

Pattern in this approach:

Path detection → selective testing → monorepo-diff plugin → build avoidance

Alternatively, instead of a monorepo diff, you can use  [`if_changed`](/docs/agent/v3/cli-pipeline#apply-if-changed) feature from the agent.

## Dynamic pipelines injecting specific steps based on detected changes

You can use dynamic pipelines to inject steps into a single pipeline according to what changed. To actually implement this, you can use:

* Both monorepo & dynamic steps in same pipeline
* Buildkite [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

The common approach is uploading the generated YAML as an artifact using `buildkite-agent artifact upload`. This allows you to download and review it later to see exactly what was generated. If you want to preview the pipeline before it's uploaded, you can use `buildkite-agent pipeline upload --dry-run` to output the final YAML without running it.

### Implementation with dynamic pipelines

This high-level example demonstrates a dynamic pipeline that analyzes git changes to determine which projects need to be built, then constructs a dependency graph to ensure projects build in the correct order.

How it works:

1. **Change Detection**: the pipeline analyzes `git diff` to identify changed files.
1. **Dependency Resolution**: builds a dependency graph to determine which projects need building.
1. **Pipeline Generation**: creates a dynamic pipeline with proper job dependencies.
1. **Parallel Execution**: independent projects build in parallel while respecting dependencies.

## The SDK approach

With the monorepo strategy, dynamic steps that are injected based on the changed files, in a single pipeline and or using the [SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).
