# Using dynamic pipelines

[Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) generate steps at build time using a script or the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk). This page helps you decide whether dynamic pipelines fit your situation, walks through the most common adoption patterns, and explains how to manage job limits as your pipelines scale.

Use the following table to find the right starting point for your situation:

| Your situation | Approach | Where to start |
|----------------|----------|----------------|
| Your pipeline runs the same steps every time | Static YAML | [Pipelines getting started](/docs/pipelines/getting-started) |
| You want to skip work that doesn't need to be done when specific files haven't changed | `if_changed` | [Combining file-change and branch conditions with if_changed](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#combining-file-change-and-branch-conditions-with-if_changed) |
| Your monorepo has separate pipelines per service | monorepo-diff plugin | [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) |
| You need consistent pipeline configuration across many pipelines | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#dynamic-generation-patterns) |
| You need to calculate test shards, parallelism, or matrix combinations at runtime | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#dynamic-generation-patterns) |
| Your monorepo has transitive dependencies between services | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#dynamic-generation-patterns) |
| Your pipelines need to retry on different infrastructure or recover from failures | Dynamic generation | [Advanced patterns](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#advanced-patterns), [details below](#dynamic-generation-patterns) |
| Your pipeline YAML has outgrown what the team can maintain, and they'd rather write code | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk), [details below](#dynamic-generation-patterns) |
| Your steps depend on output from previous steps | Multi-stage dynamic pipeline | [Advanced patterns](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#advanced-patterns) |
| You need to call external APIs or check feature flags mid-build | Dynamic generation | [Advanced patterns](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#advanced-patterns) |
| A webhook handler needs to decide at runtime whether to add steps and what kind | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline) |
| You want parameterized pipeline templates for multiple services | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| You need select/input options populated from APIs at runtime | Dynamic generation | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |

## Dynamic generation patterns

The following patterns cover the most common reasons teams adopt dynamic pipelines:

**You want a golden path and governance for pipeline standards across your organization.** Platform teams managing 40+ pipelines need retry policies, environment variables, and timeout configurations applied consistently. A generator that reads shared configuration and injects it at build time gives you that consistency: define your policies once in code, and every pipeline gets the current version at runtime.

**You want to combine file-change and branch conditions.** `if_changed` skips steps based on file changes and `if:` filters on branch, source, or other build attributes, but they cannot be combined with OR logic in a single step definition. If you need something like `if: build.branch == "main" OR if_changed: "deploy/**"`, a dynamic upload can evaluate both conditions and generate the right steps. See [Combining file-change and branch conditions with if_changed](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#combining-file-change-and-branch-conditions-with-if_changed).

**`matrix` and `parallelism` aren't enough on their own.** You can't use `matrix` and `parallelism` together in a single step. For example, if you want to run your test suite sharded across 3 parallel workers on each of 4 operating system versions (`ubuntu`, `debian`, `alpine`, `amazonlinux`), that's 12 jobs. Static YAML can give you one or the other on a single step, but not both. A generator calculates the combinations and produces all 12 step definitions automatically, each with the right shard index and operating system.

**Your monorepo has outgrown directory-level change detection.** The `monorepo-diff` plugin works at the directory level: "did anything in `/services/auth` change?" When you need transitive dependency analysis (service A changed, and service B imports from service A, so both need testing), a generator that understands your dependency graph takes over. Large monorepos commonly use custom pipeline generators for this reason.

**You want pipelines that recover from failures on their own.** When a job runs out of memory, a hook can upload a retry step that targets a bigger agent queue. Dynamic pipelines let the build respond to what's happening at runtime instead of failing and waiting for someone to re-trigger it.

**A webhook handler needs to decide what work to run.** A bootstrap step evaluates a webhook payload (a GitHub PR event, a Linear issue update, a deployment trigger) and conditionally uploads the right steps for that event. For example, the Buildkite [`buildkite-agentic-examples`](https://github.com/orgs/buildkite-agentic-examples/repositories) repositories use this pattern to launch AI agents: a PR labeled `buildkite-review` triggers a pipeline, the handler checks the label, and uploads a step that runs Claude Code to review the changes. The step only exists if the conditions are met, so the pipeline decides at runtime whether work is needed.

**Your pipeline YAML has outgrown what your team can maintain.** As matrix configurations, conditional logic, and shared steps accumulate, large YAML files become difficult to read and review. Writing the pipeline definition in Python, TypeScript, Go, Ruby, or Java lets your team use familiar tools (IDEs, linters, test frameworks) and unit test the generator before it runs a build.

## Managing job limits

Buildkite Pipelines enforces [job limits](/docs/platform/limits) on pipeline uploads. Generators that produce many grouped steps, especially in monorepos, are the most likely to hit them.

| Limit | Default |
|---|---|
| Jobs per pipeline upload | 500 |
| Jobs per build (across all uploads) | 4,000 |
| Pipeline uploads per build | 500 |

These are default quotas and can be raised by contacting [Buildkite support](/docs/platform/limits). Your organization's current limits are visible in **Organization Settings > Quotas > Service Quotas**.

These limits count jobs, not steps. `parallelism` multiplies the job count, and each group step counts as one job. A step with `parallelism: 10` counts as 10 jobs, not one. If your generator creates groups with high parallelism values, the job count adds up quickly.

When an upload exceeds the per-upload limit, the server rejects it. Steps already in the build are unaffected, but nothing from the rejected upload is added.

### Reducing job count per upload

**Use trigger steps to fan out across builds.** Instead of uploading all jobs into a single build, a generator can create [trigger steps](/docs/pipelines/configure/step-types/trigger-step) that start separate builds for each service. Each triggered build has its own job limits.

For example, a monorepo with 20 services generating 30 steps each would need 600+ jobs in a single upload. With trigger steps, the generator uploads 20 trigger steps (well under 500), and each service pipeline handles its own steps independently:

```yaml
# Generated by the monorepo generator
steps:
  - trigger: "auth-service-pipeline"
    label: ":package: Auth Service"
    build:
      branch: "${BUILDKITE_BRANCH}"
      commit: "${BUILDKITE_COMMIT}"

  - trigger: "payments-service-pipeline"
    label: ":package: Payments Service"
    build:
      branch: "${BUILDKITE_BRANCH}"
      commit: "${BUILDKITE_COMMIT}"

  # ...one trigger per changed service
```

This also provides per-service build status, so failures are isolated to the service that caused them rather than buried in a single large build.

**Use test splitting to reduce parallelism.** [Test splitting in Buildkite Test Engine](/docs/test-engine/test-splitting) uses historical timing data to distribute tests evenly, which can achieve the same test coverage with fewer parallel jobs. Four well-balanced shards can cover the same suite that previously needed ten evenly split ones.

**Account for retries in per-build counts.** Every retried job counts toward the jobs-per-build limit. When no `limit` is set, [`automatic_retry`](/docs/pipelines/configure/retry#retry-attributes-automatic-retry-attributes) defaults to two attempts per step. If an infrastructure failure fails many jobs at once, those retries add up quickly. Set an explicit `limit` on `automatic_retry` for each step to cap the total.

**Retry on different infrastructure.** Built-in `retry: automatic` retries on the same queue. For failures caused by resource constraints (out-of-memory, disk exhaustion, spot preemption), a [`pre-exit` hook](/docs/agent/hooks) can detect the failure and use `pipeline upload` to add a new step targeting a bigger or more stable agent queue:

```bash
# .buildkite/hooks/pre-exit
if [[ "$BUILDKITE_COMMAND_EXIT_STATUS" == "137" ]]; then
  echo "OOM detected. Retrying on memory-optimized agent."
  buildkite-agent pipeline upload <<YAML
steps:
  - label: ":repeat: Retry ${BUILDKITE_LABEL} (memory-optimized)"
    command: "${BUILDKITE_COMMAND}"
    agents:
      queue: "memory-optimized"
    retry:
      automatic:
        - exit_status: 137
          limit: 1
YAML
fi
```

The `limit: 1` on the uploaded step prevents an infinite retry loop if the larger agent also runs out of memory. For high-volume pipelines, keep retry caps low to prevent retry storms during fleet-wide infrastructure issues.
