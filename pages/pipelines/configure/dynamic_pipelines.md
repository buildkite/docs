# Dynamic pipelines

When your source code projects are built with Buildkite Pipelines, you can write scripts that generate new Buildkite pipeline steps at build time, in either YAML or JSON format, and upload them to the same pipeline using the [pipeline upload step](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file). The dynamically generated steps run on the same Buildkite agent as part of the same build, and appear as their own steps in the build, giving you the flexibility to structure pipelines however you require.

You can write a pipeline generator script in any language that produces YAML or JSON on stdout, or use the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) for type-safe, unit-testable pipeline definitions in JavaScript/TypeScript, Python, Go, and Ruby.

Any running job in a build can call `buildkite-agent pipeline upload` to add new steps, multiple jobs can call it within the same build, and a single job can call it more than once.

## Your first dynamic pipeline

The most common dynamic pipeline pattern is _bootstrap to generate_: a single bootstrap step runs a pipeline generator script that produces the full pipeline in one upload.

### The bootstrap pipeline

The `.buildkite/pipeline.yml` file contains a single step that runs the pipeline generator script and pipes its output to `buildkite-agent pipeline upload`:

```yaml
steps:
  - label: "\:pipeline\: Generate pipeline"
    command: ".buildkite/generate-pipeline.sh | buildkite-agent pipeline upload"
```
{: codeblock-file=".buildkite/pipeline.yml"}

The generated steps are inserted into the running build immediately after the bootstrap step.

### An example pipeline generator script

A pipeline generator script can be written in any language that produces valid YAML or JSON on stdout. Teams commonly use Bash, Python, Ruby, Node.js, Go, and PHP. For type safety, IDE support, and unit-testable pipeline definitions, see the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

The following Bash example generates a test step for each subdirectory of `tests/`:

```bash
#!/bin/bash
set -euo pipefail

echo "steps:"

for test_dir in tests/*/; do
  suite=$(basename "$test_dir")
  cat <<YAML
  - label: "\:test_tube\: Test ${suite}"
    command: "make test SUITE=${suite}"
    agents:
      queue: "default"
YAML
done
```
{: codeblock-file=".buildkite/generate-pipeline.sh"}

Save this script to the `.buildkite/` directory and ensure it is executable. With `tests/unit/`, `tests/integration/`, and `tests/e2e/` in the repository, the build gets three test steps, and adding a new test directory requires no pipeline YAML changes. For a working implementation, see the [`dynamic-pipeline-example`](https://github.com/buildkite/dynamic-pipeline-example) repository.

### Step insertion order

`pipeline upload` inserts new steps immediately after the step that called it. Multiple uploads from a single step therefore appear in reverse order. Use `depends_on` to control execution order explicitly. See [Insertion order](/docs/agent/cli/reference/pipeline#insertion-order) in the `pipeline upload` CLI reference for details.

> 📘 Step ordering in the Buildkite interface
> If a single command step runs `pipeline upload` multiple times (for example, by running a script that calls upload more than once), each batch of uploaded steps appears in reverse order in the Buildkite interface, such as the **Pipeline** view (in the sidebar) or **Table** view of the [new build page](/docs/pipelines/build-page), as well as the **Jobs** view of the classic build page, since the upload command inserts its steps immediately after the upload step.
> To avoid this, define each upload step in reverse order—the steps to run first should be defined last—or define explicit dependencies using the `depends_on` attribute.

In the following `pipeline.yml` example, the `.buildkite/pipeline.sh` script runs first, the test steps from the script are added to the build _before_ the wait step and command step, and the wait and command step run after the test steps complete.

```yaml
steps:
  - command: ".buildkite/pipeline.sh | buildkite-agent pipeline upload"
    label: "\:pipeline\: Upload"
  - wait
  - command: "other-script.sh"
    label: "Run other operations"
```
{: codeblock-file="pipeline.yml"}

### Environment variable interpolation

The Buildkite agent interpolates environment variables in the uploaded YAML at upload time, before the steps run. To defer resolution until the step runs (so a step's own `env` attribute takes effect), escape the dollar sign with `$$` or `\$`, or pass `--no-interpolation` to skip interpolation for the entire upload. See [Environment variable substitution](/docs/agent/cli/reference/pipeline#environment-variable-substitution) in the `pipeline upload` CLI reference for the full syntax.

### Job and upload limits

Buildkite Pipelines applies default service quotas of 500 jobs per upload, 500 uploads per build, and 4,000 jobs per build. If a pipeline generator script produces more jobs than the per-upload quota allows, split the output across multiple uploads (see [Upload performance at scale](#upload-performance-at-scale)). For the full set of quotas and how to raise them, see [Pipelines limits](/docs/platform/limits#pipelines-limits).

### Secret detection

To reject pipeline uploads containing values that match secret-name patterns (`*_TOKEN`, `*_SECRET`, `*_KEY`, and others), pass the `--reject-secrets` flag to `pipeline upload`. See [Secrets management](/docs/pipelines/best-practices/security-controls#secrets-management) for related guidance.

## When to use dynamic pipelines

Buildkite Pipelines supports several approaches to varying what runs in a build, ranging from fully static configuration to fully dynamic step generation. The right approach depends on how much the steps need to change from one build to the next.

Use the following decision matrix to find the right starting point for your situation:

| Your situation | Approach | Where to start |
|----------------|----------|----------------|
| Your pipeline runs the same steps every time | Static YAML | [Pipelines getting started](/docs/pipelines/getting-started) |
| You want to skip work when specific files haven't changed | `if_changed` | [Combining file-change and branch conditions with if_changed](#combining-file-change-and-branch-conditions-with-if_changed) |
| Your monorepo has separate pipelines per service | monorepo-diff plugin | [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) |
| You need consistent pipeline configuration across many pipelines | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| You need to calculate test shards, parallelism, or matrix combinations at runtime | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| Your monorepo has transitive dependencies between services | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline), [details below](#reasons-to-choose-dynamic-generation) |
| Your pipelines need to retry on different infrastructure or recover from failures | Dynamic generation | [Retrying on different infrastructure](#retrying-on-different-infrastructure) |
| Your pipeline YAML has outgrown what the team can maintain, and they'd rather write code | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| Your steps depend on output from previous steps | Multi-stage dynamic pipeline | [Advanced patterns](#advanced-patterns) |
| You need to call external APIs or check feature flags mid-build | Dynamic generation | [Advanced patterns](#advanced-patterns) |
| A webhook handler needs to decide at runtime whether to add steps and what kind | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline) |
| You want parameterized pipeline templates for multiple services | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| You need select/input options populated from APIs at runtime | Dynamic generation | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |

### Reasons to choose dynamic generation

Common reasons teams adopt dynamic pipelines include:

- **A golden path and governance for pipeline standards:** Platform teams managing many pipelines need retry policies, environment variables, and timeout configurations applied consistently. A pipeline generator script that reads shared configuration and injects it at build time gives that consistency. Policies are defined once in code, and every pipeline gets the current version at runtime.

- **Combining file-change and branch conditions:** `if_changed` skips steps based on file changes and `if:` filters on branch, source, or other build attributes, but they cannot be combined with OR logic in a single step definition. If you need something like `if: build.branch == "main" OR if_changed: "deploy/**"`, a dynamic upload can evaluate both conditions and produce the right steps. See [Combining file-change and branch conditions with if_changed](#combining-file-change-and-branch-conditions-with-if_changed).

- **Combining `matrix` and `parallelism`:** A single step cannot use `matrix` and `parallelism` together. For example, sharding a test suite across three parallel workers on each of four operating system versions (`ubuntu`, `debian`, `alpine`, `amazonlinux`) is 12 jobs. Static YAML can give you one or the other on a single step, but not both. A pipeline generator script calculates the combinations and produces all 12 step definitions automatically, each with the right shard index and operating system.

- **Monorepos with transitive dependencies:** The `monorepo-diff` plugin works at the directory level: "did anything in `/services/auth` change?" When you need transitive dependency analysis (service A changed, and service B imports from service A, so both need testing), a pipeline generator script that understands your dependency graph takes over. Large monorepos commonly use custom pipeline generator scripts for this reason.

- **Pipelines that recover from failures on their own:** When a job runs out of memory, a hook can upload a retry step that targets a bigger queue. Dynamic pipelines let the build respond to runtime conditions instead of failing and waiting for someone to re-trigger it. See [Retrying on different infrastructure](#retrying-on-different-infrastructure) for the implementation.

- **Webhook-driven step generation:** A bootstrap step evaluates a webhook payload (a GitHub PR event, a Linear issue update, a deployment trigger) and conditionally uploads the right steps for that event. For example, the [`buildkite-agentic-examples`](https://github.com/orgs/buildkite-agentic-examples/repositories) repositories use this pattern to launch AI agents: a pull request labeled `buildkite-review` triggers a pipeline, the handler checks the label, and uploads a step that runs Claude Code to review the changes. The step only exists if the conditions are met.

- **Pipeline YAML that has outgrown what your team can maintain:** As matrix configurations, conditional logic, and shared steps accumulate, large YAML files become difficult to read and review. Writing the pipeline definition in Python, TypeScript, Go, Ruby, or Java lets your team use familiar tools (IDEs, linters, test frameworks) and unit test the pipeline generator script before it runs a build.

## Combining file-change and branch conditions with if_changed

The [`if_changed`](/docs/pipelines/configure/dynamic-pipelines/if-changed) attribute skips or includes steps based on which files changed, without requiring a pipeline generator script. See the [`if_changed` reference](/docs/pipelines/configure/dynamic-pipelines/if-changed) for syntax, agent version requirements, and configuration options.

To combine `if` and `if_changed` with OR logic (for example, "run this step on `main` OR when certain files changed"), use a pipeline generator script. A single step definition cannot express this. The generator script checks both conditions and produces the appropriate steps:

```bash
#!/bin/bash
# Run deploy if on main branch OR if deploy-related files changed

BRANCH="$BUILDKITE_BRANCH"
CHANGED_FILES=$(git diff --name-only origin/main...HEAD)
DEPLOY_FILES_CHANGED=$(echo "$CHANGED_FILES" | grep -c '^deploy/' || true)

if [[ "$BRANCH" == "main" ]] || [[ "$DEPLOY_FILES_CHANGED" -gt 0 ]]; then
  cat <<YAML
steps:
  - label: "\:rocket\: Deploy"
    command: "make deploy"
    agents:
      queue: "deploy"
YAML
else
  echo "steps: []"
fi
```
{: codeblock-file=".buildkite/scripts/conditional-deploy.sh"}

Teams with more complex needs typically move to a custom pipeline generator script. See [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) or the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

## Dynamic pipeline templates

If you need to use pipelines from a central catalog or enforce certain configuration rules, you can either use dynamic pipelines and the [`pipeline upload`](/docs/agent/cli/reference/pipeline#uploading-pipelines) command, or [write custom plugins](/docs/pipelines/integrations/plugins) and share them across your organization.

To use dynamic pipelines and the pipeline upload command, make a pipeline that looks something like this:

```yaml
steps:
  - command: "enforce-rules.sh | buildkite-agent pipeline upload"
    label: "\:pipeline\: Upload"
```

Each team defines their steps in `team-steps.yml`. The templating logic lives in `enforce-rules.sh`, which can be written in any language that can pass YAML to the pipeline upload.

In `enforce-rules.sh`, you can add steps to the YAML, require certain versions of dependencies or plugins, or implement any other logic you can program. Depending on your use case, you might want to source `enforce-rules.sh` from an external catalog instead of committing it to the team repository.

See how [Hasura.io](https://hasura.io) used [dynamic templates and pipelines](https://hasura.io/blog/what-we-learnt-by-migrating-from-circleci-to-buildkite/#dynamic-pipelines) to replace their YAML configuration with Go and shell scripts.

## Advanced patterns

### Replacing the bootstrap step with --replace

Some pipelines need a two-phase start: the first step sets build context (environment variables, metadata), and the second step generates the real work. Passing `--replace` to `pipeline upload` removes the initial steps from the build and replaces them with the uploaded ones, so the bootstrap step does not linger in the interface after it finishes.

The bootstrap `pipeline.yml` file has a single step that runs the pipeline generator script:

```yaml
steps:
  - label: "\:pipeline\: Generate pipeline"
    command: ".buildkite/scripts/generate-pipeline.sh"
```
{: codeblock-file=".buildkite/pipeline.yml"}

The script calls `pipeline upload --replace`, which swaps out the bootstrap step and inserts the real pipeline:

```bash
#!/bin/bash
set -euo pipefail

buildkite-agent pipeline upload --replace <<'YAML'
steps:
  - label: "\:test_tube\: Run tests"
    command: "make test"
    key: "tests"
  - wait
  - label: "\:rocket\: Deploy"
    command: "make deploy"
YAML
```
{: codeblock-file=".buildkite/scripts/generate-pipeline.sh"}

The quoted heredoc (`<<'YAML'`) prevents the shell from expanding variables or running command substitutions before the YAML reaches the Buildkite agent. Use a quoted heredoc when the pipeline definition is fully static. If the shell needs to substitute values at upload time, use an unquoted heredoc (`<<YAML`) instead.

You can extend this pattern by chaining multiple uploads, where each phase's pipeline generator script reads results from the previous phase (using [artifacts](/docs/pipelines/configure/artifacts) or [build meta-data](/docs/pipelines/configure/build-meta-data)) to decide what to upload next.

### Branch-based routing

Static YAML can already filter steps by branch using `branches` or `if` conditionals. A pipeline generator script adds value when varying things that static YAML cannot control conditionally: agent queues, concurrency limits, priority, or swapping to a completely different pipeline definition per branch.

For example, pull request builds can route to smaller, cheaper queues while `main` branch builds route to faster queues with warm build caches and higher priority:

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

Each YAML file defines its own `agents.queue`, `priority`, and step configuration, so the pipeline generator script selects the right combination at build time.

### Retrying on different infrastructure

The built-in `retry: automatic` attribute retries on the same queue. For failures caused by resource constraints (out-of-memory, disk exhaustion, spot preemption), a [`pre-exit` hook](/docs/agent/hooks) can detect the failure and use `pipeline upload` to add a new step that targets a bigger or more stable queue:

```bash
if [[ "$BUILDKITE_COMMAND_EXIT_STATUS" == "137" ]]; then
  echo "OOM detected. Retrying on memory-optimized agent."
  buildkite-agent pipeline upload <<YAML
steps:
  - label: "\:repeat\: Retry ${BUILDKITE_LABEL} (memory-optimized)"
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
{: codeblock-file=".buildkite/hooks/pre-exit"}

The `limit: 1` value on the uploaded step prevents an infinite retry loop if the larger agent also runs out of memory. For high-volume pipelines, keep retry caps low to prevent retry storms during fleet-wide infrastructure issues.

## Testing dynamic pipelines

With a static pipeline, the YAML lives in the repository and can be reviewed before it runs. With a dynamic pipeline, the output only exists at runtime, so it pays to validate the generated YAML both during development and on every build.

### Local validation with dry-run

The [`--dry-run`](/docs/agent/cli/reference/pipeline#uploading-pipelines) flag parses and interpolates the pipeline definition, then prints the result to stdout instead of uploading it. Use it during development to catch YAML syntax and step validation errors before committing:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --dry-run
```

The parse error message might not pinpoint the exact line, so for complex scripts, redirect the output to a file and run it through a YAML linter or [`bk pipeline validate`](/docs/platform/cli/reference/pipeline#validate-a-pipeline).

### Production validation with artifact capture

Save the generated YAML as a [build artifact](/docs/pipelines/configure/artifacts) before uploading, so each build has an auditable record of what the script produced:

```bash
#!/bin/bash
set -euo pipefail

.buildkite/generate-pipeline.sh > /tmp/generated-pipeline.yml
buildkite-agent pipeline upload --dry-run < /tmp/generated-pipeline.yml > /dev/null
buildkite-agent artifact upload /tmp/generated-pipeline.yml
buildkite-agent pipeline upload /tmp/generated-pipeline.yml
```

Combined with `set -euo pipefail` (see [Handling upload failures](#troubleshooting-dynamic-pipelines-handling-upload-failures)), any failure at any stage stops the build. The artifact is available on the build page and using [`buildkite-agent artifact download`](/docs/agent/cli/reference/artifact#downloading-artifacts).

## Troubleshooting dynamic pipelines

When a dynamic pipeline misbehaves, the cause is usually one of two things: a failed upload that did not stop the build, or a successful upload that produced steps you did not expect. The following sections cover both.

### Handling upload failures

In a static pipeline, a YAML syntax error is caught before the build runs. In a dynamic pipeline, the YAML is generated and uploaded mid-build, so a rejected upload (invalid YAML, validation error) or a transient failure (system error, timeout) happens while the build is already running. `pipeline upload` exits non-zero in both cases, but Bash does not exit on errors by default. A failed upload inside a script does not fail the build step, and the build continues with no record that steps were expected.

To prevent this, add [`set -euo pipefail`](/docs/pipelines/configure/writing-build-scripts) to the top of every pipeline generator script:

```bash
#!/bin/bash
set -euo pipefail

.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload
```

`-e` exits on any non-zero return, and `pipefail` makes a failure anywhere in a pipe fail the whole pipe. Together they ensure a failed `pipeline upload` also fails the build step. See [Writing build scripts](/docs/pipelines/configure/writing-build-scripts) for more on these options.

### Debugging the generator output

When a build produces unexpected steps, retrieve the YAML the script actually uploaded rather than re-running the script locally and guessing. Use the artifact-capture approach in [Production validation with artifact capture](#testing-dynamic-pipelines-production-validation-with-artifact-capture) so every build has an auditable copy of the generated YAML, then download it with [`buildkite-agent artifact download`](/docs/agent/cli/reference/artifact#downloading-artifacts) and replay it locally with `--dry-run` to inspect the parsed result.

## Upload performance at scale

After each `pipeline upload` call, the control plane parses, validates, and merges the uploaded steps into the running build. The Buildkite agent waits for this processing to complete, polling with backoff and retrying if the server-side timeout is exceeded. Small uploads complete in under a second; uploads of hundreds of steps can take significantly longer. With `set -euo pipefail` (see [Handling upload failures](#troubleshooting-dynamic-pipelines-handling-upload-failures)), the build step fails if the agent exhausts its retries.

To stay well under the timeout, split large outputs across multiple smaller `pipeline upload` calls. Each upload is processed independently, so two uploads of 300 steps each process faster and more reliably than a single upload of 600. Both the [monorepo best practices](/docs/pipelines/best-practices/working-with-monorepos#tip-for-large-monorepos) page and [`pipeline upload` reference](/docs/agent/cli/reference/pipeline#uploading-pipelines) recommend this approach for large pipelines:

```bash
#!/bin/bash
set -euo pipefail

# One pipeline upload per service, processed independently on the control plane.
for service in api web worker payments notifications search; do
  cat <<YAML | buildkite-agent pipeline upload
steps:
  - label: "\:test_tube\: Test ${service}"
    command: "make test -C services/${service}"
    key: "test-${service}"
  - label: "\:rocket\: Deploy ${service}"
    command: "make deploy -C services/${service}"
    depends_on: "test-${service}"
YAML
done
```

The same approach works for any pipeline generator script that iterates over targets such as test shards, changed paths, or matrix combinations. Use `depends_on` to control execution order, since multiple uploads from a single step are inserted in reverse order (see [Step insertion order](#step-insertion-order)).

For even larger workloads, use [trigger steps](/docs/pipelines/configure/step-types/trigger-step) to fan work out across separate builds. Each triggered build has its own upload and job limits.

## Retrying steps that upload

A step that runs `pipeline upload` can fail and be retried. When it retries, the pipeline generator script runs again, but the steps from the first run are still in the build. Without `key` values, duplicate steps are silently added. With `key` values, the second upload fails loudly with a duplicate-key error, which is the desired outcome. Always set `key` on every step the script produces.

If the upload step is responsible for the entire remaining pipeline, use `--replace` to make retries safe:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --replace
```

`--replace` removes all pending steps before adding the new ones; jobs already running are not affected. See the [`pipeline upload` CLI reference](/docs/agent/cli/reference/pipeline) for details. Do not use `--replace` when multiple steps each upload their own portion of the build, since a retry of one would remove the steps uploaded by the others.

## Observability for dynamic builds

Dynamic pipelines can produce different steps on every build. A monorepo pipeline generator script might produce three steps on one commit and 47 on the next. To debug failures or compare build times across runs, have the script record what it decided: use [build annotations](/docs/pipelines/configure/annotations) to surface a summary on the build page, and [build meta-data](/docs/pipelines/configure/build-meta-data) to store the inputs for querying later using the API.

For general pipeline monitoring, including fleet health, build lifecycle traces, and queue metrics, see [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).

```bash
#!/bin/bash
set -euo pipefail

# Detect which services changed
CHANGED=$(git diff --name-only HEAD~1 -- services/ \
  | cut -d/ -f2 | sort -u | paste -sd ' ')

if [[ -z "$CHANGED" ]]; then
  buildkite-agent annotate "No services changed, skipping generation." \
    --style "info" --context "generator"
  exit 0
fi

# Record the decision as build metadata (queryable using API)
buildkite-agent meta-data set "generated-services" "$CHANGED"

# Record the decision as a build annotation (visible on build page)
buildkite-agent annotate "Generated steps for: ${CHANGED}" \
  --style "info" --context "generator"

# Generate and upload steps for each changed service
for service in $CHANGED; do
  cat <<YAML | buildkite-agent pipeline upload
steps:
  - label: "\:test_tube\: Test ${service}"
    command: "make test -C services/${service}"
    key: "test-${service}"
YAML
done
```

Use consistent `key` values across builds so the same logical step can be compared across different pipeline generator script outputs. For example, always using `test-api` as the key for the API test step means that step's duration can be tracked over time, even when the rest of the pipeline changes.

## Security considerations for dynamic pipelines

Any running job can call `pipeline upload` to add steps to the current build. If a forked repository modifies `.buildkite/` scripts, those scripts run on your agents and can upload arbitrary steps. The [Enforcing security controls](/docs/pipelines/best-practices/security-controls) page recommends [disabling fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for public pipelines. For pipelines that need to accept fork builds, a pipeline generator script can gate them with a `block` step requiring manual approval:

```bash
#!/bin/bash
set -euo pipefail

if [ "${BUILDKITE_PULL_REQUEST_REPO}" != "" ] && \
   [ "${BUILDKITE_PULL_REQUEST_REPO}" != "${BUILDKITE_REPO}" ]; then
  buildkite-agent pipeline upload <<'YAML'
steps:
  - block: "\:lock\: Approve fork build"
    prompt: "This build is from a fork. Review the code before allowing it to run on our agents."
YAML
fi

# Upload the main pipeline. Steps appear after the block step if one was added.
buildkite-agent pipeline upload
```

A static `if` conditional on a block step achieves the same result (`if: build.pull_request_repo != "" && build.pull_request_repo != build.repository`). The pipeline generator script approach is useful for more complex logic, such as checking an allowlist of trusted fork repositories.

[Pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) prevents unsigned steps from being injected using `pipeline upload`. For dynamic pipelines, both the pipeline generator script and the steps it produces must be signed.

In Kubernetes environments, `pipeline upload` can inject steps that run with higher-privilege service accounts, creating a privilege escalation path. Audit which steps can call `pipeline upload` and what service accounts those steps run under.

## Buildkite SDK

For type-safe, unit-testable pipeline generation in JavaScript/TypeScript, Python, Go, and Ruby, see the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) page.
