# Working with monorepos

A monorepo development strategy means that the code for multiple projects is stored in a single, centralized version-controlled repository. This strategy provides advantages like easier code sharing, unified versioning, and consistent tooling, but it also poses challenges such as longer build times and potential conflicts if not managed effectively. This page covers approaches and best practices for effectively managing and running monorepos.

## Approaches to running monorepos

All such approaches start with detecting changes in your monorepo, usually at the folder level. To detect these changes, add an [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) to your [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes), [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes), or [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes) steps, then run the [pipeline upload command](/docs/agent/cli/reference/pipeline) with the [`--apply-if-changed` option](/docs/agent/cli/reference/pipeline#apply-if-changed). The Buildkite agent then evaluates each step's `if_changed` expression against the changed files in the build.

> 📘
> In Buildkite Pipelines, you can structure your monorepo pipeline as a single pipeline that orchestrates other pipelines by triggering them, or as a single pipeline containing many steps. Both approaches have tradeoffs. Some users prefer the clean separation that triggering pipelines by another provides, while others prefer all their steps to run conditionally in a single pipeline.

There are two preferred approaches to running monorepos with Buildkite Pipelines:

- **Static**: a single diff pipeline triggers different static pipelines in your monorepo based on what parts of the monorepo were changed.
- **Dynamic**: [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) inject specific steps into a single pipeline based on the changes in the monorepo. You need to run a generator script to inject steps according to the changes. You can also use the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) to inject steps dynamically in one of its supported programming languages.

The following sections describe each approach in more detail.

## Static approach

The static approach to working with monorepos involves creating a single orchestrating pipeline that triggers other pipelines (predefined for different scenarios) in your monorepo.

A typical example of the static approach is a single main pipeline that contains the [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) and, depending on what files get modified in the repository, this pipeline triggers other pipelines:

```yaml
steps:
  - label: "Detect changed projects"
    key: diff
    soft_fail: true
    plugins:
      - monorepo-diff#v1.3.0:
          diff: .buildkite/scripts/git-diff-files.sh
          watch:
            - path: "service-app"
              config:
                trigger: "monorepo-service-app-example"
            - path: "test"
              config:
                trigger: "monorepo-test-example"
```

You can check out the [Monorepo example](https://buildkite.com/resources/examples/buildkite/monorepo-example/) pipeline to see a working implementation you can clone and adapt.

> 🚧
> In the static monorepo approach, the triggered pipelines must only be triggered by the dedicated triggering pipeline and _never_ directly through the Buildkite interface, API, or other means. Direct execution bypasses the change detection logic, causing the pipeline to run without awareness of the changes in the monorepo, or the necessary build context from the triggering pipeline. This might lead to a number of unwanted consequences, such as build artifacts being generated with incorrect library versions.

## Dynamic approach

The dynamic approach to working with monorepos involves having dynamic pipelines that inject specific steps in the programming language of your choice into a single pipeline in your monorepo based on the detected changes.

When implementing the dynamic pipelines approach, you can use either:

- [Direct scripting](/docs/pipelines/configure/dynamic-pipelines)
- [The Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)

A useful way to implement dynamic pipelines is to upload the generated YAML steps file as an artifact using the `buildkite-agent artifact upload` command. This allows you to download and review that YAML file later to see exactly what was generated.

> 📘 Dry-run preview
> If you want to preview the pipeline before it's uploaded, you can use the `buildkite-agent pipeline upload --dry-run` command to output the final YAML without running it.

Buildkite customers who use [Bazel](/docs/pipelines/tutorials/bazel) and [Gradle](https://gradle.org/) prefer the dynamic approach. These build systems let you target specific steps once the diff that needs to be built is identified, and map which tests to run on the paths that changed.

### Implementation with dynamic pipelines

In many monorepos, services share code. Changing a shared library means you need to rebuild and test every service that depends on it, not just the ones with direct file changes. The `monorepo-diff` plugin watches file paths, but it doesn't understand dependency graphs. For that, you need a pipeline generator script that resolves transitive dependencies:

```bash
#!/bin/bash
set -euo pipefail

CHANGED_FILES=$(git diff --name-only --merge-base origin/main)

services=("api" "web" "worker")
watched_paths=(
  "services/api libs/auth libs/database"
  "services/web libs/ui libs/auth"
  "services/worker libs/database"
)

services_to_build=()

for i in "${!services[@]}"; do
  service="${services[$i]}"
  for path in ${watched_paths[$i]}; do
    if grep -q "^${path}/" <<< "$CHANGED_FILES"; then
      services_to_build+=("$service")
      break
    fi
  done
done

if (( ${#services_to_build[@]} == 0 )); then
  echo "steps: []"
  exit 0
fi

echo "steps:"

for service in "${services_to_build[@]}"; do
  cat <<YAML
  - label: ":hammer: Build ${service}"
    command: "make build -C services/${service}"
    key: "build-${service}"
    agents:
      queue: "default"
  - label: ":test_tube: Test ${service}"
    command: "make test -C services/${service}"
    depends_on: "build-${service}"
    agents:
      queue: "default"
YAML
done
```

If one service out of 50 changed, only that service's build and test steps are generated.

### Bazel monorepo example

For more sophisticated dependency resolution (including transitive dependencies), a generator script can parse a dependency graph and produce a parallel-safe pipeline with correct `depends_on` links. You can see a hands-on implementation in the [Bazel monorepo example](https://github.com/buildkite/bazel-monorepo-example). The example analyzes Git changes to determine which projects need to be built, then constructs a dependency graph to ensure that the projects build in the correct order.

How the example works:

1. Change detection stage: the pipeline analyzes Git diff to identify changed files.
1. Dependency resolution stage: a dependency graph is built to determine which projects need building.
1. Pipeline generation stage: a dynamic pipeline with proper job dependencies is created.
1. Parallel execution: independent projects build in parallel, respecting dependencies.

Learn more about running through this example in [Creating dynamic pipelines and build annotations using Bazel](/docs/pipelines/tutorials/dynamic-pipelines-and-annotations-using-bazel). This implementation is also valid if using the Buildkite SDK.

### Using the Buildkite SDK

The [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) provides a library of methods for several supported languages (JavaScript and TypeScript, Python, Go, and Ruby). You can use it to dynamically generate Buildkite pipeline steps in YAML or JSON format, then upload them to your Buildkite pipeline. The Buildkite SDK acts as a translation layer that makes it easier to generate these steps, rather than having to manually script them yourself.

For example, if you need to detect changes in a Bazel- or Gradle-based monorepo, you could use the Buildkite SDK to dynamically generate the required pipeline steps based on the execution outcomes from your Bazel or Gradle build scripts.

### Features that work well with monorepo dynamic generation

The following features pair well with dynamic pipeline generation because your generator script can set them differently for each step based on what it knows at build time:

- **[Retry configuration](/docs/pipelines/configure/step-retry):** For transient failures like spot instance preemption, network timeouts, or flaky dependencies. Set `automatic` retry with `limit: 2` and your generator applies it to every step it produces, so you don't need to maintain retry policies per-pipeline.
- **[Agent targeting](/docs/pipelines/configure/defining-steps#targeting-specific-agents):** Lets your generator route steps to the right infrastructure at runtime. GPU training jobs go to `gpu-a100` queues, integration tests to `large-memory` agents, linting to low-cost spot instances. A single pipeline can span multiple infrastructure tiers without needing separate pipelines for each. See [How to lower costs while scaling your CI/CD: Use Spot Instances](https://buildkite.com/resources/blog/lower-cost-while-scaling-ci-cd-spot-instances/) for more on cost-optimized agent strategies.
- **[Group steps](/docs/pipelines/configure/group-steps):** When a generator produces more than 30 steps, grouping by service or phase makes the build page easier to navigate. See [Group steps in dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#group-steps-in-dynamic-pipelines) for details.
- **[`depends_on`](/docs/pipelines/configure/dependencies):** Gives you finer-grained control over execution order than `wait` steps. A `wait` step blocks everything until the entire previous phase finishes. `depends_on` lets each step declare exactly which steps it needs, so unrelated work runs in parallel. When your generator produces steps with different durations, this can significantly reduce build times.

### Shared configuration across pipelines

Platform teams managing dozens of pipelines often need retry policies, timeouts, and environment variables applied consistently. Instead of duplicating that configuration across every pipeline YAML, a generator can read from a single centrally managed file and apply it at build time:

```python
#!/usr/bin/env python3
import copy
import sys
import yaml

with open(".buildkite/shared-config.yml") as shared_file:
    shared = yaml.safe_load(shared_file)

with open(f".buildkite/{sys.argv[1]}-steps.yml") as steps_file:
    team_steps = yaml.safe_load(steps_file)

for step in team_steps["steps"]:
    if "command" in step or "commands" in step:
        if "retry" in shared:
            step.setdefault("retry", copy.deepcopy(shared["retry"]))
        if "timeout" in shared:
            step.setdefault("timeout_in_minutes", shared["timeout"])
        if "env" in shared:
            step["env"] = {**shared["env"], **step.get("env", {})}

yaml.safe_dump({"steps": team_steps["steps"]}, sys.stdout, sort_keys=False)
```

When you update the retry policy in `shared-config.yml`, every pipeline picks it up on its next build. If your shared configuration lives in a separate repository, your generator can clone it at build time and pipe its output to `pipeline upload`.

## Combined approach

You don't need to limit your CI/CD process to a single one of these approaches when working with a monorepo. Many customers, especially those with large Buildkite organizations, combine static and dynamic approaches based on their specific requirements.

## Pipeline step count guidance

When designing monorepo pipelines, consider keeping each pipeline build to no more than 500 steps so that the UI and build processing remain responsive.

If your use case requires a large number of steps in a build, consider consolidating some steps, splitting work across multiple pipelines, or using an orchestrator pattern. For builds that consistently need step counts well beyond this range, [contact the Buildkite sales team](mailto:sales@buildkite.com) to discuss your requirements.

> 📘
> The step count is not the same as the total number of jobs in a build. Attributes such as [`parallelism`](/docs/pipelines/configure/step-types/command-step#parallelism) and [`matrix`](/docs/pipelines/configure/step-types/command-step#matrix-attributes) expand a single step into multiple jobs at runtime.

### Handling very large monorepos

For monorepos that could generate hundreds or thousands of steps, use an orchestrator pipeline that [dynamically generates](/docs/pipelines/configure/dynamic-pipelines) only the steps needed for each build. Upload steps in batches, or [trigger](/docs/pipelines/configure/step-types/trigger-step) child pipelines, so that no single build exceeds a few hundred steps.
