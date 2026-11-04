---
description: "Generate pipeline steps at build time in Buildkite Pipelines. Start with a Bash example, validate uploads, and choose SDK or monorepo patterns."
---

# Dynamic pipelines

Dynamic pipelines generate and upload new steps while a Buildkite Pipelines build is running. Use them when the work depends on changed files, results from earlier steps, or other information available at build time.

A generator script outputs YAML or JSON, which the [`buildkite-agent pipeline upload` command](/docs/agent/cli/reference/pipeline#uploading-pipelines) adds to the current build. Generated command steps run as jobs on matching [agents](/docs/agent) in the targeted [queues](/docs/agent/queues). Your generator can use any programming language that writes to standard output.

<figure>
  <video id="dynamic-pipeline-animation" src="<%= image_path('dynamic-pipeline.mp4') %>" data-autoplay controls loop muted playsinline preload="none" width="960" height="372" style="display: block; max-width: 100%; height: auto;" aria-label="Jobs and agents in a growing dynamic pipeline" aria-describedby="dynamic-pipeline-animation-description" poster="<%= image_path('dynamic-pipeline.png') %>">
    <%= image "dynamic-pipeline.png", width: 1920/2, height: 744/2, alt: "An agent runs a generator job, matching agents run its generated jobs, and one job adds deployment jobs to the same build." %>
  </video>
  <div data-animation-controls hidden>
    <button type="button" class="Button Button--default Button--small Button--inline" data-animation-toggle aria-controls="dynamic-pipeline-animation">Play animation</button>
    <a href="<%= image_path('dynamic-pipeline.mp4') %>" target="_blank" rel="noopener">View full size</a>
  </div>
  <figcaption id="dynamic-pipeline-animation-description">An agent runs a generator job, which uploads three command steps into the running build. Matching agents run the generated jobs. One of those jobs then uploads two deployment steps, expanding the graph again. Each command job runs on an agent, and the new steps stay in the same build.</figcaption>
</figure>

## When to use dynamic pipelines

Buildkite Pipelines supports both static configuration and dynamic step generation. Choose the simplest approach that meets your needs:

Your situation | Approach | Where to start
-------------- | -------- | --------------
You run the same steps every time | Static YAML | [Pipelines getting started](/docs/pipelines/getting-started)
You want to skip steps when specific files haven't changed | File-change conditions | [Using if_changed](/docs/pipelines/configure/dynamic-pipelines/if-changed)
Your monorepo has separate pipelines per service | Change detection and pipeline triggers | [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos)
You calculate steps, dependencies, or matrix combinations at build time | A pipeline generator script | [Your first dynamic pipeline](#your-first-dynamic-pipeline)
You want typed, testable step definitions in your preferred language | Dynamic generation with the SDK | [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk)
Your steps depend on earlier results, external APIs, or feature flags | Multi-stage generation | [Advanced patterns](#advanced-patterns)
You need to investigate a failure on different infrastructure | A generated diagnostic step | [Retrying on different infrastructure](#advanced-patterns-retrying-on-different-infrastructure)
{: class="responsive-table"}

## Your first dynamic pipeline

Start with one step that runs a script to generate and upload the rest of your pipeline.

### The bootstrap pipeline

The `.buildkite/pipeline.yml` file contains a single step that runs the pipeline generator script and pipes its output to `buildkite-agent pipeline upload`:

```yaml
steps:
  - label: "\:pipeline\: Generate pipeline"
    command: |
      set -euo pipefail
      .buildkite/generate-pipeline.sh | buildkite-agent pipeline upload
```
{: codeblock-file=".buildkite/pipeline.yml"}

Configure your pipeline to [load this file from your repository](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file). The generated steps are inserted into the running build immediately after the bootstrap step. The shell options ensure that a failed generator or upload fails the bootstrap step.

<figure>
  <video id="dynamic-pipeline-upload-animation" src="<%= image_path('dynamic-pipeline-upload.webm') %>" data-autoplay controls loop muted playsinline preload="none" width="960" height="234" style="display: block; max-width: 100%; height: auto;" aria-label="Generated YAML adds test steps to a running build" aria-describedby="dynamic-pipeline-upload-animation-description" poster="<%= image_path('dynamic-pipeline-upload.png') %>">
    <%= image "dynamic-pipeline-upload.png", width: 1920/2, height: 468/2, alt: "A generator outputs YAML and uploads it, adding unit, integration, and end-to-end test steps to the running build." %>
  </video>
  <div data-animation-controls hidden>
    <button type="button" class="Button Button--default Button--small Button--inline" data-animation-toggle aria-controls="dynamic-pipeline-upload-animation">Play animation</button>
    <a href="<%= image_path('dynamic-pipeline-upload.webm') %>" target="_blank" rel="noopener">View full size</a>
  </div>
  <figcaption id="dynamic-pipeline-upload-animation-description">The generator outputs YAML for three test steps. Uploading that YAML adds the steps to the same running build.</figcaption>
</figure>

### An example pipeline generator script

The following Bash example generates a test step for each subdirectory of `tests/`:

```bash
#!/bin/bash
set -euo pipefail

echo "steps:"

for test_dir in tests/*/; do
  suite=$(basename "$test_dir")
  if [[ ! "$suite" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    printf 'Unsupported test suite directory: %s\n' "$test_dir" >&2
    exit 1
  fi
  cat <<YAML
  - label: "\:test_tube\: Test ${suite}"
    key: "test-${suite}"
    command: "make test SUITE=${suite}"
    agents:
      queue: "default"
YAML
done
```
{: codeblock-file=".buildkite/generate-pipeline.sh"}

Save this script as `.buildkite/generate-pipeline.sh` and make it executable with `chmod +x .buildkite/generate-pipeline.sh`. The example assumes your repository has test subdirectories, a `make test` target that accepts `SUITE`, and an agent queue named `default`. Suite directory names must contain only ASCII letters, digits, dashes, or underscores so they produce valid step keys and command arguments. The script rejects other names, including `unit.v2`, rather than uploading an invalid step. Adapt these values to your project.

### Validate the generated steps

<a id="testing-dynamic-pipelines-local-validation-with-dry-run"></a>

With the Buildkite agent CLI installed locally, preview the generated pipeline without uploading or running any steps:

```bash
set -euo pipefail
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --dry-run
```

The `--dry-run` flag parses and interpolates the pipeline, then prints it to standard output. With `tests/unit/`, `tests/integration/`, and `tests/e2e/`, check that the output contains three test steps with keys `test-unit`, `test-integration`, and `test-e2e`. Start a build to run them. Adding a test directory requires no changes to the pipeline definition.

For additional validation, save the generated output to a file and use [`bk pipeline validate`](/docs/platform/cli/reference/pipeline#validate-a-pipeline). For a runnable project to adapt, see the [`dynamic-pipeline-example`](https://github.com/buildkite/dynamic-pipeline-example) repository.

Once the generated test steps run, [collect their results in Test Engine](/docs/pipelines/configure/tests/test-collection) to track slow or flaky tests across builds.

### Step insertion order

`pipeline upload` inserts new steps immediately after the step that called it. If one command step uploads more than once, the batches appear in reverse upload order in the Buildkite Pipelines interface. Upload the batches in reverse order to control their display order. Use [explicit dependencies with `depends_on`](/docs/pipelines/configure/depends-on) to control execution order. See [Insertion order](/docs/agent/cli/reference/pipeline#insertion-order) for details.

### Environment variable interpolation

The Buildkite agent interpolates environment variables in the uploaded YAML at upload time, before the steps run. To defer resolution until the step runs (so a step's own `env` attribute takes effect), escape the dollar sign with `$$` or `\$`, or pass `--no-interpolation` to skip interpolation for the entire upload. See [Environment variable substitution](/docs/agent/cli/reference/pipeline#environment-variable-substitution) for the full syntax.

### Job and upload limits

Pipeline uploads are subject to default service quotas of 500 jobs per upload, 500 uploads per build, and 4,000 jobs per build. If a script produces more jobs than the per-upload quota allows, see [Upload performance at scale](#upload-performance-at-scale). For the full set of quotas and how to raise them, see [Pipelines limits](/docs/platform/limits#pipelines-limits).

## Combining file-change and branch conditions with if_changed

The `if_changed` attribute skips or includes steps based on which files changed, without a generator script. A step that combines `if` and `if_changed` runs only when both conditions are true.

To express OR logic, define two steps with the same command and distinct keys. The following example runs on `main` or when files in `deploy/` change. The second step excludes `main` so the work does not run twice:

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

For centrally assigned, static configurations, compare this approach with [pipeline templates](/docs/pipelines/governance/templates), an Enterprise plan feature. Static templates can include a generator step when later steps need to vary at runtime.

See how [Hasura.io](https://hasura.io) used [dynamic templates and pipelines](https://hasura.io/blog/what-we-learnt-by-migrating-from-circleci-to-buildkite/#dynamic-pipelines) to replace their YAML configuration with Go and shell scripts.

## Advanced patterns

The patterns in this section build on the bootstrap pattern in [Your first dynamic pipeline](#your-first-dynamic-pipeline) to solve specific problems: replacing the remaining pending steps in a build with a freshly generated set, varying entire pipeline definitions per branch, and investigating infrastructure failures by rerunning work on a different queue. Each pattern is independent—pick the ones that match the problems you face.

### Replacing pending steps with --replace

Some pipelines need a two-phase start: the first step sets build context (for example, environment variables or build meta-data), and the second step generates the real work based on that context. Passing `--replace` to `pipeline upload` removes all pending steps from the build before adding the uploaded ones. Jobs that are already running (including the upload step itself) and jobs that have already completed are not affected, so this is useful when a placeholder or skeleton step needs to be swapped out for the generated work without leaving the original pending steps in the build:

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

To choose the agent pools, queues, and caching behind these routes, see [Buildkite agent reference architectures](/docs/agent/reference-architectures). The patterns explain when to separate workloads and how to combine hosted and self-hosted agents.

### Retrying on different infrastructure

The built-in `retry: automatic` attribute retries on the same queue. To investigate a failure on another queue, a [`pre-exit` hook](/docs/agent/hooks) can upload a diagnostic rerun. The following hook responds to exit status `137` by adding a step on a larger queue. This status can indicate an out-of-memory kill, but confirm the cause before choosing a different queue. This example does not recover the build: the original job remains failed even if the diagnostic rerun succeeds.

```bash
if [[ "$BUILDKITE_COMMAND_EXIT_STATUS" == "137" && "${FALLBACK_RETRY:-false}" != "true" ]]; then
  echo "Job exited with status 137. Adding a diagnostic rerun on the memory-optimized queue."
  buildkite-agent pipeline upload <<YAML
steps:
  - label: "\:repeat\: Diagnostic rerun ${BUILDKITE_LABEL} (memory-optimized)"
    command: "${BUILDKITE_COMMAND}"
    agents:
      queue: "memory-optimized"
    env:
      FALLBACK_RETRY: "true"
    retry:
      automatic:
        - exit_status: 137
          limit: 1
YAML
fi
```
{: codeblock-file=".buildkite/hooks/pre-exit"}

The `FALLBACK_RETRY` flag prevents the diagnostic job and its automatic retry from uploading another diagnostic job. The `limit: 1` value caps automatic retries of that step; it does not limit new steps created by uploads.

## Testing dynamic pipelines

With a static pipeline, the YAML lives in the repository and can be reviewed before it runs. With a dynamic pipeline, the output only exists at runtime. Start with [local validation](#your-first-dynamic-pipeline-validate-the-generated-steps), then capture the generated definition on every build so you can inspect it later.

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

When a build produces unexpected steps, retrieve the YAML the script actually uploaded rather than re-running the script locally and guessing. Use the [step uploads REST API](/docs/apis/rest-api/step-uploads) to list uploads for a build and fetch the rendered YAML for a specific upload, for builds within their maximum lifetime. For older builds, download a pipeline artifact captured when the build ran. To retain these artifacts for future builds or replay an upload locally with `--dry-run`, configure the artifact-capture approach in [Production validation with artifact capture](#testing-dynamic-pipelines-production-validation-with-artifact-capture), then use [`buildkite-agent artifact download`](/docs/agent/cli/reference/artifact#downloading-artifacts).

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

Any running job can call `pipeline upload` to add steps to the current build. If a forked repository modifies `.buildkite/` scripts, those scripts run on your agents and can upload arbitrary steps. The [Security checklist](/docs/platform/security/checklist) recommends [disabling fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for pipelines with secrets.

For native GitHub pipelines that accept fork builds, place any approval [block step](/docs/pipelines/configure/step-types/block-step) in pipeline settings before jobs that check out or run repository code. Use `if: build.pull_request.repository.fork == true` to identify fork pull requests. Don't generate the gate in a repository-controlled pipeline generator script: its job has already checked out fork code, and repository hooks can run before the script. Approval doesn't restrict secret access or make fork code trusted. GitHub Actions pipeline triggers [reject fork pull requests before creating a build](/docs/pipelines/migration/run-github-actions-workflows/security#fork-pull-requests). A block step can't enable them.

The Buildkite agent rejects pipeline uploads that contain values from the agent process environment whose variable names match the default secret-name patterns:

<%= render_markdown partial: 'pipelines/configure/default_redacted_vars' %>

The agent also checks values assigned to matching variables in pipeline-level, step-level, and trigger-step `build` environment maps. Pure runtime substitutions and values shorter than six bytes are not treated as secrets. To deliberately upload a pipeline containing a detected secret, pass the insecure `--allow-secrets` flag or set `BUILDKITE_AGENT_PIPELINE_UPLOAD_ALLOW_SECRETS=true`. Agent v3 does not run this check by default—pass the `--reject-secrets` flag to `pipeline upload` to enable it. See [Secrets management](/docs/platform/security/checklist#secrets-management) for related guidance.

[Pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) prevents unsigned steps from being injected using `pipeline upload`. For dynamic pipelines, both the pipeline generator script and the steps it produces must be signed.

In Kubernetes environments, `pipeline upload` can inject steps that run with higher-privilege service accounts, creating a privilege escalation path. Audit which steps can call `pipeline upload` and what service accounts those steps run under.

## Next steps

- **Build and test a monorepo**: Follow [Creating dynamic pipelines and build annotations using Bazel](/docs/pipelines/tutorials/dynamic-pipelines-and-annotations-using-bazel) for a complete example that resolves dependencies and generates steps.
- **Organize generated steps**: Use [group steps](/docs/pipelines/configure/step-types/group-step) to keep related jobs together on the build page.
- **Protect a production pipeline**: Follow [Secure your first production pipeline](/docs/platform/security/first-production-pipeline) to configure and verify access controls.
