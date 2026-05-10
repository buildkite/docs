# Using dynamic pipelines

[Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) generate steps at build time using a pipeline generator script or the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk). This page covers when to choose dynamic pipelines and the practices that keep them reliable as they scale. For tutorial-style guidance and code examples, see the [Dynamic pipelines guide](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide).

## When to use dynamic pipelines

Use the following table to find the right starting point for your situation:

| Your situation | Approach | Where to start |
|----------------|----------|----------------|
| Your pipeline runs the same steps every time | Static YAML | [Pipelines getting started](/docs/pipelines/getting-started) |
| You want to skip work that doesn't need to be done when specific files haven't changed | `if_changed` | [Combining file-change and branch conditions with if_changed](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#combining-file-change-and-branch-conditions-with-if_changed) |
| Your monorepo has separate pipelines per service | monorepo-diff plugin | [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) |
| You need consistent pipeline configuration across many pipelines | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| You need to calculate test shards, parallelism, or matrix combinations at runtime | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| Your monorepo has transitive dependencies between services | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| Your pipelines need to retry on different infrastructure or recover from failures | Dynamic generation | [Retrying on different infrastructure](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#retrying-on-different-infrastructure) |
| Your pipeline YAML has outgrown what the team can maintain, and they'd rather write code | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| Your steps depend on output from previous steps | Multi-stage dynamic pipeline | [Advanced patterns](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#advanced-patterns) |
| You need to call external APIs or check feature flags mid-build | Dynamic generation | [Advanced patterns](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#advanced-patterns) |
| A webhook handler needs to decide at runtime whether to add steps and what kind | Dynamic generation | [Your first dynamic pipeline](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#your-first-dynamic-pipeline) |
| You want parameterized pipeline templates for multiple services | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| You need select/input options populated from APIs at runtime | Dynamic generation | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |

## Reasons to choose dynamic generation

The following patterns cover the most common reasons teams adopt dynamic pipelines:

**You want a golden path and governance for pipeline standards across your organization.** Platform teams managing many pipelines need retry policies, environment variables, and timeout configurations applied consistently. A pipeline generator script that reads shared configuration and injects it at build time gives you that consistency: define your policies once in code, and every pipeline gets the current version at runtime.

**You want to combine file-change and branch conditions.** `if_changed` skips steps based on file changes and `if:` filters on branch, source, or other build attributes, but they cannot be combined with OR logic in a single step definition. If you need something like `if: build.branch == "main" OR if_changed: "deploy/**"`, a dynamic upload can evaluate both conditions and produce the right steps. See [Combining file-change and branch conditions with if_changed](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#combining-file-change-and-branch-conditions-with-if_changed).

**`matrix` and `parallelism` aren't enough on their own.** A single step cannot use `matrix` and `parallelism` together. For example, sharding a test suite across three parallel workers on each of four operating system versions (`ubuntu`, `debian`, `alpine`, `amazonlinux`) is 12 jobs. Static YAML can give you one or the other on a single step, but not both. A pipeline generator script calculates the combinations and produces all 12 step definitions automatically, each with the right shard index and operating system.

**Your monorepo has outgrown directory-level change detection.** The `monorepo-diff` plugin works at the directory level: "did anything in `/services/auth` change?" When you need transitive dependency analysis (service A changed, and service B imports from service A, so both need testing), a pipeline generator script that understands your dependency graph takes over. Large monorepos commonly use custom pipeline generator scripts for this reason.

**You want pipelines that recover from failures on their own.** When a job runs out of memory, a hook can upload a retry step that targets a bigger agent queue. Dynamic pipelines let the build respond to what's happening at runtime instead of failing and waiting for someone to re-trigger it. See [Retrying on different infrastructure](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#retrying-on-different-infrastructure) for the implementation.

**A webhook handler needs to decide what work to run.** A bootstrap step evaluates a webhook payload (a GitHub PR event, a Linear issue update, a deployment trigger) and conditionally uploads the right steps for that event. For example, the Buildkite [`buildkite-agentic-examples`](https://github.com/orgs/buildkite-agentic-examples/repositories) repositories use this pattern to launch AI agents: a pull request labeled `buildkite-review` triggers a pipeline, the handler checks the label, and uploads a step that runs Claude Code to review the changes. The step only exists if the conditions are met, so the pipeline decides at runtime whether work is needed.

**Your pipeline YAML has outgrown what your team can maintain.** As matrix configurations, conditional logic, and shared steps accumulate, large YAML files become difficult to read and review. Writing the pipeline definition in Python, TypeScript, Go, Ruby, or Java lets your team use familiar tools (IDEs, linters, test frameworks) and unit test the pipeline generator script before it runs a build.

## Set keys on every dynamically generated step

Every step a pipeline generator script produces should include a `key` attribute. If a step that runs `pipeline upload` is retried, the script runs again and re-uploads its steps. Without keys, duplicate steps are silently added to the build. With keys, the second upload fails with a clear duplicate-key error instead.

For pipelines where a single step owns the entire remaining build, `pipeline upload --replace` is the safer pattern. See [Retrying steps that upload](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#retrying-steps-that-upload) for the full pattern.

## Make pipeline upload failures stop the build

In a static pipeline, YAML errors are caught before the build runs. In a dynamic pipeline, generation happens mid-build, and a failed `pipeline upload` does not automatically fail the script that called it. Bash does not exit on errors by default, so the build continues with no record that steps were expected.

Add [`set -euo pipefail`](/docs/pipelines/configure/writing-build-scripts) to the top of every pipeline generator script. The combination ensures that any non-zero return — including a rejected `pipeline upload` — fails the build step. See [Upload failures](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#upload-failures) for the rationale and example.

## Validate generated YAML before uploading

A pipeline generator script's output only exists at runtime, so problems surface during builds rather than in code review. Two practices keep this manageable:

- Run `buildkite-agent pipeline upload --dry-run` locally during development to catch syntax and validation errors before pushing.
- In production, save the generated YAML as a [build artifact](/docs/pipelines/configure/artifacts) before uploading it, so each build has an auditable record of what the script produced.

See [Debugging your pipeline generator script](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#debugging-your-pipeline-generator-script) for the end-to-end pattern.

## Record what the pipeline generator script decided

Dynamic pipelines can produce different steps on every build. To compare runs and debug failures later, have the script record its decisions:

- Use [build annotations](/docs/pipelines/configure/annotations) to surface a summary on the build page.
- Use [build meta-data](/docs/pipelines/configure/build-meta-data) to store the inputs that drove the decision so they can be queried using the API.

Use consistent `key` values across builds so the same logical step (for example, `test-api`) can be tracked over time, even when the rest of the pipeline changes. See [Observability for dynamic builds](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#observability-for-dynamic-builds) for an end-to-end example.

## Managing job limits

Buildkite Pipelines enforces [job limits](/docs/platform/limits) on pipeline uploads. Pipeline generator scripts that produce many grouped steps, especially in monorepos, are the most likely to hit them.

| Limit | Default |
|---|---|
| Jobs per pipeline upload | 500 |
| Jobs per build (across all uploads) | 4,000 |
| Pipeline uploads per build | 500 |

These are default quotas and can be raised by contacting [Buildkite support](/docs/platform/limits). Your organization's current limits are visible in **Organization Settings > Quotas > Service Quotas**.

These limits count jobs, not steps. `parallelism` multiplies the job count, and each group step counts as one job. A step with `parallelism: 10` counts as 10 jobs, not one. If a pipeline generator script creates groups with high parallelism values, the job count adds up quickly.

When an upload exceeds the per-upload limit, the server rejects it. Steps already in the build are unaffected, but nothing from the rejected upload is added.

### Reducing job count per upload

**Use trigger steps to fan out across builds.** Instead of uploading all jobs into a single build, a pipeline generator script can create [trigger steps](/docs/pipelines/configure/step-types/trigger-step) that start separate builds for each service. Each triggered build has its own job limits.

For example, a monorepo with 20 services generating 30 steps each would need 600+ jobs in a single upload. With trigger steps, the pipeline generator script uploads 20 trigger steps (well under 500), and each service pipeline handles its own steps independently:

```yaml
# Generated by the monorepo pipeline generator script
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

**Retry on different infrastructure for resource-related failures.** For out-of-memory, disk-exhaustion, or spot-preemption failures, a [`pre-exit` hook](/docs/agent/hooks) can use `pipeline upload` to add a new step targeting a bigger or more stable agent queue. See [Retrying on different infrastructure](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#retrying-on-different-infrastructure) for the implementation.

## Secure your dynamic pipelines

Any running job can call `pipeline upload` to add steps to the current build. This is a privilege escalation surface that needs explicit guardrails:

- For public pipelines, [disable fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) by default. If fork builds are required, gate them behind a `block` step requiring manual approval.
- Use [pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) to prevent unsigned steps from being injected. Both the pipeline generator script and the steps it produces must be signed.
- In Kubernetes environments, audit which steps can call `pipeline upload` and which service accounts those steps run under, since `pipeline upload` can be used to inject steps that run with higher-privilege service accounts.

See [Security considerations for dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines/dynamic-pipelines-guide#security-considerations-for-dynamic-pipelines) for the fork-gating example, and [Enforcing security controls](/docs/pipelines/best-practices/security-controls) for broader pipeline security guidance.
