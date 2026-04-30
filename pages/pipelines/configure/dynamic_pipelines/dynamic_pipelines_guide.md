# Dynamic pipelines guide

This guide covers when and how to use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) in Buildkite Pipelines. It walks through building your first dynamic pipeline, common patterns for monorepos and matrix builds, advanced orchestration techniques, and troubleshooting.

## What are dynamic pipelines and when do you need them?

In a static pipeline, every step is defined before the build starts. This works well when the pipeline runs the same steps every time, but it becomes a problem at scale. A monorepo with forty services rebuilds all of them on every commit, even when only one changed. Deploy pipelines that need different approval gates per environment have to account for every path upfront. ML training sweeps with variable parameters and GPU routing can't adjust to runtime conditions. Static matrix builds can handle some of this, but you end up with deeply nested YAML that's hard to read, harder to debug, and can't respond to what actually changed or what a previous step produced. In practice, that means builds running the full pipeline when only a fraction of it is needed.

Dynamic pipelines solve this. Instead of defining every step before the build starts, you write a script that runs *during* the build and decides what happens next. Your script can check which files changed, query an API, read a configuration file, or look at what a previous step produced, then generate only the steps the build actually needs.

In Buildkite Pipelines, any step in a build can generate new steps and add them to the same build using [`buildkite-agent pipeline upload`](/docs/agent/cli/reference/pipeline). That means step 1 can check which files changed and only queue builds for affected services. Step 3 can look at what step 2 produced and branch accordingly. The build assembles itself based on what's actually happening, not what you predicted when you wrote the configuration.

Any step in a running build can call `pipeline upload` to add new steps at any point during execution. Multiple steps can upload, and a single step can upload more than once. Default quotas apply (500 steps per upload, 500 uploads per build, 4,000 jobs per build) and can be raised through support.

### How dynamic pipelines work

Buildkite uses a hybrid architecture: a hosted control plane handles scheduling and the web UI, while [agents](/docs/agent) run on your infrastructure (or on [Buildkite-hosted machines](/docs/agent/buildkite-hosted)). Agents check out your code and execute jobs. The control plane never touches your source code or secrets. See [Architecture](/docs/pipelines/architecture) for the full picture.

The agent uploads pipeline definitions to the API using `pipeline upload`. This command can be called multiple times during a build, from different jobs, with different YAML each time. Each upload adds new steps to the running build.

### How pipeline upload works

When a running job calls `buildkite-agent pipeline upload`, it sends the YAML payload to the control plane API. The control plane parses it, creates new step records, and merges them into the running build. The new steps appear in the UI and get dispatched to agents like any other steps.

Any running job can upload new steps. A build can receive multiple uploads from different jobs. Learn more in the [`pipeline upload` CLI reference](/docs/agent/cli/reference/pipeline).

### Decision framework: when to use what

**Static YAML** works when the pipeline runs the same steps every time, with at most branch-level `if:` conditions for variation. When your requirements outgrow static YAML, `if_changed` and the options below let you add dynamism incrementally.

**[Conditional step execution](/docs/pipelines/configure/dynamic-pipelines/if-changed)** with `if_changed` is the simplest way to skip work that doesn't need to run. Add glob patterns to a step definition and the agent runs `git diff` against the merge base at upload time, excluding steps where nothing matched. Learn more in the [`if_changed` docs](/docs/pipelines/configure/dynamic-pipelines/if-changed) for agent version requirements and supported syntax. Learn more about [combining file-change and branch conditions with if_changed](#combining-file-change-and-branch-conditions-with-if_changed).

**Monorepo plugin** ([`monorepo-diff`](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/)) watches for directory-level changes and triggers only the sub-pipelines that are affected. Configuration is declarative (no scripting). It works at the directory level and triggers separate pipelines for each match, rather than composing steps within a single build. See [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos).

**Dynamic generation** is for cases where the steps themselves need to change based on runtime information. Your generator runs as a build step, looks at whatever context it needs (file changes, dependency graphs, API responses, shared configuration), and uploads the right steps for this specific build. The [patterns below](#dynamic-generation-patterns) cover the most common use cases. This is the most powerful approach, and the one that makes Buildkite fundamentally different from other CI platforms.

## Your first dynamic pipeline

The most common dynamic pipeline pattern is "bootstrap to generate": a single bootstrap step runs a script that generates the full pipeline in one upload. This page walks through building one from scratch.

### The bootstrap pipeline

The `.buildkite/pipeline.yml` contains a single step that runs the generator script and pipes the output to `pipeline upload`:

```yaml
# .buildkite/pipeline.yml
steps:
  - label: ":pipeline: Generate pipeline"
    command: ".buildkite/generate-pipeline.sh | buildkite-agent pipeline upload"
```

The step runs the generator script, pipes the YAML output to `pipeline upload`, and the generated steps are inserted into the running build after the bootstrap step.

### The generator script

```bash
#!/bin/bash
set -euo pipefail

echo "steps:"

# Discover test directories and generate a step for each
for test_dir in tests/*/; do
  suite=$(basename "$test_dir")
  cat <<YAML
  - label: ":test_tube: Test ${suite}"
    command: "make test SUITE=${suite}"
    agents:
      queue: "default"
YAML
done
```

Save this as `.buildkite/generate-pipeline.sh` and make it executable (`chmod +x`). If the repo contains `tests/unit/`, `tests/integration/`, and `tests/e2e/`, the build gets three test steps. Adding a new test directory requires no pipeline YAML changes.

See the [`dynamic-pipeline-example/`](https://github.com/buildkite/dynamic-pipeline-example) repo for a working implementation of this pattern.

### Testing locally with dry-run

Validate generated YAML locally before pushing:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --dry-run
```

The `--dry-run` flag parses and validates the YAML without uploading it. It catches syntax errors, malformed YAML, and step validation issues before they fail a build.

### Generator language

The generator script can be written in any language that can produce valid YAML or JSON on stdout. The agent doesn't care what language your script is written in; it pipes the output straight to `pipeline upload`. In production, teams use Bash, Python, Ruby, Node.js, Go, and PHP.

If you want type safety, IDE support, and the ability to unit test your pipeline definitions, the [Buildkite SDK](#using-the-sdk) supports JavaScript/TypeScript, Python, Go, and Ruby.

### Things to know

#### Step insertion order

`pipeline upload` inserts new steps immediately after the step that called it. If you upload three batches (A, then B, then C) from the same step, they appear as C, B, A in the build because each new batch is inserted at the same position, pushing earlier batches down. Use `depends_on` to control execution order explicitly.

#### Environment variable interpolation

When the agent uploads your pipeline YAML, it interpolates environment variables *before* the steps run. This matters when your generated steps reference variables that should be evaluated later, at execution time, by the agent running that step.

**Upload-time interpolation (default behavior):**

The agent replaces `$VAR` and `${VAR}` references with their current values during upload. This is useful when you want to bake values into the pipeline definition:

```yaml
steps:
  - label: "Build ${BUILDKITE_BRANCH}"
    command: "make build"
```

The agent resolves `${BUILDKITE_BRANCH}` when it uploads the pipeline, so the step label shows the actual branch name (for example, "Build main").

**Deferring evaluation to execution time:**

If you need a variable to be evaluated when the step runs (not when the pipeline is uploaded), escape the dollar sign with `$$` or `\$`:

```yaml
steps:
  - label: "Deploy"
    command: "deploy.sh $$DEPLOY_TARGET"
    env:
      DEPLOY_TARGET: "production"
```

Without the escaping, the agent would try to resolve `$DEPLOY_TARGET` at upload time, before the step's `env` block has taken effect, and the variable would be empty.

**Advanced interpolation syntax:**

The agent supports several additional patterns:

```yaml
# Required variable (upload fails if MY_VAR is not set)
command: "deploy.sh ${MY_VAR?}"

# Default value (uses "fallback" if MY_VAR is not set)
command: "deploy.sh ${MY_VAR:-fallback}"

# Substring extraction (characters 0 through 7)
label: "Commit ${BUILDKITE_COMMIT:0:7}"
```

**Disabling interpolation entirely:**

If your generated YAML contains many variable references that should all be evaluated at runtime, you can skip interpolation on the entire upload:

```bash
buildkite-agent pipeline upload --no-interpolation
```

This is particularly useful for generated pipelines where the output already contains the literal values you want, or where shell variables in command strings would otherwise be consumed by the agent before the shell sees them.

#### Default job limits

Each `pipeline upload` call can create up to 500 steps. A single pipeline build supports up to 500 separate uploads, and up to 4,000 steps total (including retries). These are default quotas and can be raised by contacting support. Your organization's current limits are visible in **Organization Settings > Quotas > Service Quotas**.

If your generator produces more than 500 steps, split the output across multiple uploads (see [Upload performance at scale](#upload-performance-at-scale)) or request a quota increase.

#### Secret detection

The agent redacts environment variable values matching certain name patterns (`*_TOKEN`, `*_SECRET`, `*_KEY`, and others) in log output. To also reject pipeline uploads that contain these values, pass the [`--reject-secrets`](/docs/agent/cli/reference/pipeline) flag to `pipeline upload`. This is opt-in (disabled by default). If your generated YAML contains what looks like a secret but isn't one, you may need to adjust your variable naming or the `--redacted-vars` pattern. Learn more in the [`pipeline upload` CLI reference](/docs/agent/cli/reference/pipeline).

## Combining file-change and branch conditions with if_changed

The [`if_changed`](/docs/pipelines/configure/dynamic-pipelines/if-changed) attribute skips or includes steps based on which files changed, without requiring a generator script. See the full [`if_changed` reference](/docs/pipelines/configure/dynamic-pipelines/if-changed) for syntax, agent version requirements, and configuration options.

If you want to combine `if` and `if_changed` with OR logic (for example, "run this step on main OR when these files changed"), you need a generator script. There's no way to express this in a single step definition. The generator checks both conditions and produces the appropriate steps:

```bash
#!/bin/bash
# .buildkite/scripts/conditional-deploy.sh
# Run deploy if on main branch OR if deploy-related files changed

BRANCH="$BUILDKITE_BRANCH"
CHANGED_FILES=$(git diff --name-only origin/main...HEAD)
DEPLOY_FILES_CHANGED=$(echo "$CHANGED_FILES" | grep -c '^deploy/' || true)

if [[ "$BRANCH" == "main" ]] || [[ "$DEPLOY_FILES_CHANGED" -gt 0 ]]; then
  cat <<YAML
steps:
  - label: ":rocket: Deploy"
    command: "make deploy"
    agents:
      queue: "deploy"
YAML
else
  echo "steps: []"
fi
```

Teams with more complex needs typically move to a custom generator script. See [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) or [Using the SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

## Monorepo pipelines

Monorepo change detection is one of the most common use cases for dynamic pipelines. See [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) for plugin-based and custom approaches, transitive dependency resolution, shared configuration, and features that pair well with dynamic generation.

## Using the SDK

The [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) (currently in preview) lets you define pipeline steps as typed objects in Python, TypeScript, Go, or Ruby instead of writing YAML. When your generator needs matrix combinations, dependency resolution, or multi-step conditionals, a typed language catches errors at write time that a shell script would only surface at runtime. See the [SDK reference](/docs/pipelines/configure/dynamic-pipelines/sdk) for setup, language-specific examples, and testing patterns.

## Group steps in dynamic pipelines

When a generator produces more than about 10 steps, [group steps](/docs/pipelines/configure/step-types/group-step) keep the build page readable by collecting related steps into collapsible sections. For monorepo pipelines producing 50+ steps, grouping becomes essential.

Adding any group step to a pipeline automatically enables directed acyclic graph (DAG) mode for that build. In DAG mode, steps without `depends_on` or `wait` between them run in parallel rather than top-to-bottom. If your existing pipeline relies on steps running in order without explicit dependencies, adding a group causes those steps to run concurrently. Add `depends_on` or `wait` steps to preserve the ordering you need.

### Generating groups dynamically

The following generator script creates one group per changed service:

```bash
#!/bin/bash
set -euo pipefail

CHANGED_FILES=$(git diff --name-only --merge-base origin/main)

echo "steps:"

for service_dir in services/*/; do
  service=$(basename "$service_dir")
  if echo "$CHANGED_FILES" | grep -q "^services/${service}/"; then
    cat <<YAML
  - group: ":package: ${service}"
    key: "group-${service}"
    steps:
      - label: ":hammer: Build ${service}"
        command: "make build -C services/${service}"
        key: "build-${service}"
      - label: ":test_tube: Test ${service}"
        command: "make test -C services/${service}"
        depends_on: "build-${service}"
YAML
  fi
done
```

Each changed service gets its own collapsible group. Within each group, the test step waits for the build step using `depends_on`, but the groups themselves run in parallel because there's no dependency between them.

For monorepo pipelines, group by service so each service has its own collapsible section. For single-service pipelines, group by phase: one group for linting, one for unit tests, one for integration tests, one for deploy. The goal is for any engineer to locate a failed step without scrolling through unrelated output.

### Concurrency controls inside groups

[Concurrency groups](/docs/pipelines/configure/workflows/controlling-concurrency) limit how many jobs with a given label can run at the same time, across all builds in an organization. Set concurrency on individual command steps, not on the group. `concurrency`, `concurrency_group`, and `concurrency_method` are command-step attributes. If you put them on a group step, the server rejects the pipeline upload.

In this example, each service deploy is limited to one concurrent job:

```yaml
steps:
  - group: ":rocket: Deploy"
    key: "deploy"
    depends_on: "tests"
    steps:
      - label: "Deploy auth"
        command: "make deploy-auth"
        concurrency: 1
        concurrency_group: "deploy/auth"
      - label: "Deploy payments"
        command: "make deploy-payments"
        concurrency: 1
        concurrency_group: "deploy/payments"
```

The `concurrency_group` name determines which jobs queue together. In the example above, `deploy/auth` and `deploy/payments` are separate groups, so auth and payments deploys can run in parallel, but two auth deploys from different builds cannot.

When your generator produces deploy steps, make sure it sets `concurrency` and `concurrency_group` on each step. This is easy to miss because it feels like something that should go on the group.

### Organizing groups without nesting

Groups in Buildkite Pipelines are one level deep. If your pipeline upload includes a group inside another group, the server rejects it with: `Group steps can't be nested within groups`.

The workaround is flat groups with a naming convention that implies the hierarchy. Use a `Category: Subcategory` pattern in the group label so the build page reads like a structured list even though the groups are siblings:

```yaml
steps:
  - group: ":test_tube: Backend: Auth Tests"
    key: "backend-auth"
    steps:
      - label: "Auth unit tests"
        command: "make test-auth-unit"
      - label: "Auth integration tests"
        command: "make test-auth-integration"

  - group: ":test_tube: Backend: API Tests"
    key: "backend-api"
    steps:
      - label: "API unit tests"
        command: "make test-api-unit"
      - label: "API integration tests"
        command: "make test-api-integration"
```

If you need the "Backend" groups to run as a unit before a downstream stage, give them related keys and use `depends_on` with an array:

```yaml
  - group: ":rocket: Deploy"
    depends_on:
      - "backend-auth"
      - "backend-api"
    steps:
      - label: "Deploy to staging"
        command: "make deploy-staging"
```

This is especially relevant for generators that loop over components. If your generator tries to produce nested groups (for example, an outer group per team and inner groups per service), restructure it to output flat groups with descriptive names instead.

### Group merging across uploads

Groups can merge across `pipeline upload` calls, but only under specific conditions. When the job running the upload is inside a group, and the first step of the uploaded pipeline is a group with the same label, the server merges them: the uploaded steps get added to the existing group rather than creating a new one. See [group merging](/docs/pipelines/configure/step-types/group-step#group-merging) for full details.

If your pipeline has multiple generators that each run `pipeline upload` separately, each upload creates its own groups. Two uploads that both create a group called `:test_tube: Tests` produce two separate groups in the UI with the same name. To avoid this, either give each generator's groups a distinct name (`:test_tube: Auth Tests`, `:test_tube: Payments Tests`), or consolidate the steps into a single upload so they land in one group.

### Groups on the build page

All groups in a build share the same default collapse state on page load. There is no way to configure some groups to start collapsed and others expanded. Use descriptive group names so engineers can quickly find the right group to expand when investigating a failure.

There is no built-in way to cancel other steps in a group when one succeeds or fails. If your generator produces groups where only one result matters (for example, testing against multiple environments and using the first to pass), use the [Buildkite API](/docs/apis) from within the step command to cancel the remaining jobs.

## Advanced patterns

Each pattern here solves a specific orchestration problem.

### Replacing the bootstrap step with --replace

Some pipelines need a two-phase start: the first step sets build context (environment variables, metadata), and the second step generates the real work. Passing `--replace` to `pipeline upload` removes the initial steps from the build and replaces them with the uploaded ones, so the bootstrap step does not linger in the UI after it finishes.

The bootstrap `pipeline.yml` has a single step that runs the generator script:

```yaml
# .buildkite/pipeline.yml
steps:
  - label: ":pipeline: Generate pipeline"
    command: ".buildkite/scripts/generate-pipeline.sh"
```

The script calls `pipeline upload --replace`, which swaps out the bootstrap step and inserts the real pipeline:

```bash
#!/bin/bash
# .buildkite/scripts/generate-pipeline.sh
set -euo pipefail

buildkite-agent pipeline upload --replace <<'YAML'
steps:
  - label: ":test_tube: Run tests"
    command: "make test"
    key: "tests"
  - wait
  - label: ":rocket: Deploy"
    command: "make deploy"
YAML
```

The quoted heredoc (`<<'YAML'`) prevents the shell from expanding variables or running command substitutions before the YAML reaches the agent. Use a quoted heredoc when the pipeline definition is fully static. If you need the shell to substitute values at upload time, use an unquoted heredoc (`<<YAML`) instead.

You can extend this pattern by chaining multiple uploads, where each phase's generator reads results from the previous phase (using [artifacts](/docs/pipelines/configure/managing-artifacts) or [metadata](/docs/pipelines/configure/managing-build-metadata)) to decide what to upload next.

### Branch-based routing

Static YAML can already filter steps by branch using `branches` or `if` conditionals. Where a dynamic generator adds value is varying things that static YAML can't control conditionally: agent queues, concurrency limits, priority, or swapping to a completely different pipeline definition per branch.

For example, PR builds can route to smaller, cheaper agent queues while main branch builds route to faster queues with warm build caches and higher priority:

```bash
#!/bin/bash
set -euo pipefail

if [[ "$BUILDKITE_BRANCH" == "main" ]]; then
  cat .buildkite/production-steps.yml
elif [[ "$BUILDKITE_BRANCH" =~ ^release/ ]]; then
  cat .buildkite/release-steps.yml
else
  cat .buildkite/feature-steps.yml
fi | buildkite-agent pipeline upload
```

Each YAML file defines its own `agents.queue`, `priority`, and step configuration, so the generator selects the right combination at build time.

## Troubleshooting and limits

For upload failures, debugging generators, upload performance at scale, notifications, retry behavior, observability, and security considerations, see [Troubleshooting dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines/troubleshooting).
