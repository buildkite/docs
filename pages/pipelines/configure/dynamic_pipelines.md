# Dynamic pipelines

When your source code projects are built with Buildkite Pipelines, you can write scripts that generate new pipeline steps at build time, in either YAML or JSON, and upload them to the same pipeline using the [pipeline upload step](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file). The generated steps run on the same Buildkite agent as part of the same build, and appear as their own steps in the build, giving you the flexibility to structure pipelines however you require.

A pipeline generator script can be written in any language that produces YAML or JSON on stdout—teams commonly use Bash, Python, Ruby, Node.js, Go, C#, and PHP. For type-safe, unit-testable pipeline definitions in JavaScript/TypeScript, Python, Go, and Ruby, see the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

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

`pipeline upload` inserts new steps immediately after the step that called it. If a single command step calls `pipeline upload` more than once, each batch of uploaded steps appears in reverse order in the Buildkite interface. To control ordering, define each upload step in reverse order—the steps to run first should be defined last—or set explicit dependencies with `depends_on`. See [Insertion order](/docs/agent/cli/reference/pipeline#insertion-order) in the `pipeline upload` CLI reference for details.

### Environment variable interpolation

The Buildkite agent interpolates environment variables in the uploaded YAML at upload time, before the steps run. To defer resolution until the step runs (so a step's own `env` attribute takes effect), escape the dollar sign with `$$` or `\$`, or pass `--no-interpolation` to skip interpolation for the entire upload. See [Environment variable substitution](/docs/agent/cli/reference/pipeline#environment-variable-substitution) for the full syntax.

### Job and upload limits

Pipeline uploads are subject to default service quotas of 500 jobs per upload, 500 uploads per build, and 4,000 jobs per build. If a script produces more jobs than the per-upload quota allows, see [Upload performance at scale](#upload-performance-at-scale). For the full set of quotas and how to raise them, see [Pipelines limits](/docs/platform/limits#pipelines-limits).

## When to use dynamic pipelines

Buildkite Pipelines supports several approaches to varying what runs in a build, ranging from fully static configuration to fully dynamic step generation. Use the following guide to find the right starting point:

| Your situation | Approach | Where to start |
|----------------|----------|----------------|
| Your pipeline runs the same steps every time | Static YAML | [Pipelines getting started](/docs/pipelines/getting-started) |
| You want to skip steps when specific files haven't changed | `if_changed` | [Using if_changed](/docs/pipelines/configure/dynamic-pipelines/if-changed) |
| Your monorepo has separate pipelines per service | monorepo-diff plugin | [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) |
| You need consistent configuration, transitive dependency analysis, or matrix combinations calculated at runtime | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline) |
| You need to retry on different infrastructure or recover from failures | Dynamic generation | [Retrying on different infrastructure](#advanced-patterns-retrying-on-different-infrastructure) |
| Your pipeline YAML has outgrown what the team can maintain | Dynamic generation (SDK) | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) |
| Your steps depend on output from previous steps, external APIs, or feature flags mid-build | Multi-stage dynamic pipeline | [Advanced patterns](#advanced-patterns) |
| A webhook handler needs to decide at runtime which steps to add | Dynamic generation | [Your first dynamic pipeline](#your-first-dynamic-pipeline) |

## Combining file-change and branch conditions with if_changed

The [`if_changed`](/docs/pipelines/configure/dynamic-pipelines/if-changed) attribute skips or includes steps based on which files changed, without requiring a pipeline generator script. A single step definition combines `if` and `if_changed` with AND logic—both conditions must be true for the step to run. To express OR logic (for example, "run on `main` OR when certain files changed"), define two steps that share the same `command` and `key` prefix: one guarded by `if`, the other by `if_changed` (with an `if` clause that excludes the branch already covered by the first step, so the work does not run twice).

```yaml
steps:
  - label: "\:rocket\: Deploy from main"
    key: "deploy-main"
    if: build.branch == "main"
    command: "make deploy"
    agents:
      queue: "deploy"
  - label: "\:rocket\: Deploy for deploy/ changes"
    key: "deploy-changed"
    if: build.branch != "main"
    if_changed: "deploy/**"
    command: "make deploy"
    agents:
      queue: "deploy"
```

The same pattern applies when one variant of a step needs different environment or tagging than the other. For example, build and publish a container image on every commit to `release/*`, and also on any branch that touches the `Dockerfile` or `docker/` directory:

```yaml
steps:
  - label: "\:docker\: Build release image"
    key: "image-release"
    if: build.branch =~ /^release\//
    env:
      IMAGE_TAG: "release-${BUILDKITE_COMMIT:0:7}"
    command: "./scripts/build-and-push.sh"
  - label: "\:docker\: Build preview image"
    key: "image-preview"
    if: build.branch !~ /^release\//
    if_changed:
      - "Dockerfile"
      - "docker/**"
    env:
      IMAGE_TAG: "preview-build-${BUILDKITE_BUILD_NUMBER}"
    command: "./scripts/build-and-push.sh"
```

For more complex needs, see [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos) or the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk).

## Dynamic pipeline templates

If you need to use pipelines from a central catalog or enforce certain configuration rules, you can either use dynamic pipelines and the [`pipeline upload`](/docs/agent/cli/reference/pipeline#uploading-pipelines) command, or [write custom plugins](/docs/pipelines/integrations/plugins) and share them across your organization. To use dynamic pipelines, make a pipeline like:

```yaml
steps:
  - command: "enforce-rules.sh | buildkite-agent pipeline upload"
    label: "\:pipeline\: Upload"
```

Each team defines their steps in `team-steps.yml`. The templating logic in `enforce-rules.sh` can add steps to the YAML, require certain dependency or plugin versions, or implement any other logic. You can also source `enforce-rules.sh` from an external catalog instead of committing it to the team repository.

See how [Hasura.io](https://hasura.io) used [dynamic templates and pipelines](https://hasura.io/blog/what-we-learnt-by-migrating-from-circleci-to-buildkite/#dynamic-pipelines) to replace their YAML configuration with Go and shell scripts.

## Advanced patterns

The patterns in this section build on the bootstrap pattern in [Your first dynamic pipeline](#your-first-dynamic-pipeline) to solve specific problems: replacing the bootstrap step in the interface so it does not appear alongside the generated work, varying entire pipeline definitions per branch, and recovering from infrastructure failures by retrying on a different queue. Each pattern is independent—pick the ones that match the problems you face.

### Replacing the bootstrap step with --replace

Some pipelines need a two-phase start: the first step sets build context (environment variables, build meta-data), and the second step generates the real work based on that context. Passing `--replace` to `pipeline upload` removes the pending bootstrap steps from the build and replaces them with the uploaded ones, so the bootstrap step does not linger in the interface after it finishes:

```bash
#!/bin/bash
set -euo pipefail

# Read context recorded by an earlier step using buildkite-agent meta-data set.
SERVICE=$(buildkite-agent meta-data get "service")
ENVIRONMENT=$(buildkite-agent meta-data get "environment")

buildkite-agent pipeline upload --replace <<YAML
steps:
  - label: "\:test_tube\: Test ${SERVICE}"
    command: "make test SERVICE=${SERVICE}"
    key: "tests"
  - wait
  - label: "\:rocket\: Deploy ${SERVICE} to ${ENVIRONMENT}"
    command: "make deploy SERVICE=${SERVICE} ENV=${ENVIRONMENT}"
YAML
```
{: codeblock-file=".buildkite/scripts/generate-pipeline.sh"}

You can extend this pattern by chaining multiple uploads, where each phase reads results from the previous phase (using [artifacts](/docs/pipelines/configure/artifacts) or [build meta-data](/docs/pipelines/configure/build-meta-data)) to decide what to upload next.

### Branch-based routing

A pipeline generator script can vary things that static YAML cannot control conditionally, such as agent queues, concurrency limits, priority, or swapping to a completely different pipeline definition per branch. For example, pull request builds can route to smaller queues while `main` builds route to faster queues with warm caches:

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

### Retrying on different infrastructure

The built-in `retry: automatic` attribute retries on the same queue. For failures caused by resource constraints (out-of-memory, disk exhaustion, spot preemption), a [`pre-exit` hook](/docs/agent/hooks) can detect the failure and use `pipeline upload` to add a step that targets a bigger or more stable queue:

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

The `limit: 1` value prevents an infinite retry loop. For high-volume pipelines, keep retry caps low to avoid retry storms during fleet-wide infrastructure issues.

## Testing dynamic pipelines

With a static pipeline, the YAML lives in the repository and can be reviewed before it runs. With a dynamic pipeline, the output only exists at runtime, so validate it both during development and on every build.

### Local validation with dry-run

The [`--dry-run`](/docs/agent/cli/reference/pipeline#uploading-pipelines) flag parses and interpolates the pipeline definition, then prints the result to stdout instead of uploading it. Use it during development to catch YAML syntax and step validation errors before committing:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --dry-run
```

For complex scripts where the parse error message does not pinpoint the exact line, redirect the output to a file and run it through a YAML linter or [`bk pipeline validate`](/docs/platform/cli/reference/pipeline#validate-a-pipeline).

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

Combined with `set -euo pipefail` (see [Handling upload failures](#troubleshooting-dynamic-pipelines-handling-upload-failures)), any failure at any stage stops the build.

## Troubleshooting dynamic pipelines

When a dynamic pipeline misbehaves, the cause is usually one of three things: a failed upload that did not stop the build, a successful upload that produced steps you did not expect, or a retried upload that produced duplicate steps.

### Handling upload failures

In a static pipeline, a YAML syntax error is caught before the build runs. In a dynamic pipeline, the YAML is generated and uploaded mid-build, so a rejected upload (invalid YAML, validation error) or transient failure happens while the build is already running. `pipeline upload` exits non-zero in both cases, but Bash does not exit on errors by default, so a failed upload inside a script does not fail the build step, and the build continues with no record that steps were expected.

Add [`set -euo pipefail`](/docs/pipelines/configure/writing-build-scripts) to the top of every pipeline generator script:

```bash
#!/bin/bash
set -euo pipefail

.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload
```

`-e` exits on any non-zero return, and `pipefail` makes a failure anywhere in a pipe fail the whole pipe. Together they ensure a failed `pipeline upload` also fails the build step.

### Debugging the generator output

When a build produces unexpected steps, retrieve the YAML the script actually uploaded rather than re-running the script locally and guessing. Use the artifact-capture approach in [Production validation with artifact capture](#testing-dynamic-pipelines-production-validation-with-artifact-capture) so every build has an auditable copy, then download it with [`buildkite-agent artifact download`](/docs/agent/cli/reference/artifact#downloading-artifacts) and replay it locally with `--dry-run`.

### Retried steps producing duplicates

A step that runs `pipeline upload` can fail and be retried. When it retries, the script runs again, but the steps from the first run are still in the build. Always set `key` on every step the script produces—without keys, duplicates are silently added; with keys, the second upload fails with a duplicate-key error.

If the upload step is responsible for the entire remaining pipeline, use `--replace` to make retries safe:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --replace
```

`--replace` removes all pending steps before adding the new ones; jobs already running are not affected. Do not use `--replace` when multiple steps each upload their own portion of the build, since a retry of one would remove the steps uploaded by the others.

## Upload performance at scale

After each `pipeline upload` call, the control plane parses, validates, and merges the uploaded steps into the running build. Small uploads complete in under a second; uploads of hundreds of steps can take significantly longer, and may exceed the server-side timeout.

To stay well under the timeout, split large outputs across multiple smaller `pipeline upload` calls. Each upload is processed independently, so two uploads of 300 steps each process faster and more reliably than a single upload of 600:

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

Use `depends_on` to control execution order, since multiple uploads from a single step are inserted in reverse order (see [Step insertion order](#your-first-dynamic-pipeline-step-insertion-order)). For even larger workloads, use [trigger steps](/docs/pipelines/configure/step-types/trigger-step) to fan work out across separate builds.

## Observability for dynamic builds

Dynamic pipelines can produce different steps on every build—a monorepo script might produce three steps on one commit and 47 on the next. To debug failures or compare build times across runs, have the script record its decisions: use [build annotations](/docs/pipelines/configure/annotations) to surface a summary on the build page, and [build meta-data](/docs/pipelines/configure/build-meta-data) to store the inputs for querying later using the API.

Use consistent `key` values across builds so the same logical step (for example, `test-api`) can be tracked over time, even when the rest of the pipeline changes.

For general pipeline monitoring, see [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).

## Security considerations for dynamic pipelines

Any running job can call `pipeline upload` to add steps to the current build. If a forked repository modifies `.buildkite/` scripts, those scripts run on your agents and can upload arbitrary steps. The [Enforcing security controls](/docs/pipelines/best-practices/security-controls) page recommends [disabling fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for public pipelines. For pipelines that need to accept fork builds, gate them with a `block` step, either using a static `if` conditional (`if: build.pull_request_repo != "" && build.pull_request_repo != build.repository`) or a pipeline generator script for more complex logic such as checking an allowlist of trusted forks.

To reject pipeline uploads containing values that match secret-name patterns (`*_TOKEN`, `*_SECRET`, `*_KEY`, and others), pass the `--reject-secrets` flag to `pipeline upload`. See [Secrets management](/docs/pipelines/best-practices/security-controls#secrets-management) for related guidance.

[Pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) prevents unsigned steps from being injected using `pipeline upload`. For dynamic pipelines, both the pipeline generator script and the steps it produces must be signed.

In Kubernetes environments, `pipeline upload` can inject steps that run with higher-privilege service accounts, creating a privilege escalation path. Audit which steps can call `pipeline upload` and what service accounts those steps run under.
