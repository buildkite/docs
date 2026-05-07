# Dynamic pipelines guide

This guide covers when and how to use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) in Buildkite Pipelines. It walks through building your first dynamic pipeline, common patterns for monorepos and matrix builds, advanced orchestration techniques, and troubleshooting.

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

The generator script can be written in any language that can produce valid YAML or JSON on stdout. The agent does not care what language your script is written in; it pipes the output straight to `pipeline upload`. In production, teams use Bash, Python, Ruby, Node.js, Go, and PHP.

If you want type safety, IDE support, and the ability to unit test your pipeline definitions, the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) supports JavaScript/TypeScript, Python, Go, and Ruby.

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

Each `pipeline upload` call can create up to 500 jobs. A single pipeline build supports up to 500 separate uploads, and up to 4,000 jobs total (including retries). These are default quotas and can be raised by contacting [Buildkite support](/docs/platform/limits). Your organization's current limits are visible in **Organization Settings > Quotas > Service Quotas**.

If your generator produces more than 500 jobs in a single upload, split the output across multiple uploads (see [Upload performance at scale](#upload-performance-at-scale)) or request a quota increase. See [Managing job limits](/docs/pipelines/best-practices/using-dynamic-pipelines#managing-job-limits) for the full set of limits and strategies for staying within them.

#### Secret detection

The agent redacts environment variable values matching certain name patterns (`*_TOKEN`, `*_SECRET`, `*_KEY`, and others) in log output. To also reject pipeline uploads that contain these values, pass the [`--reject-secrets`](/docs/agent/cli/reference/pipeline) flag to `pipeline upload`. This is opt-in (disabled by default). If your generated YAML contains what looks like a secret but isn't one, you may need to adjust your variable naming or the `--redacted-vars` pattern. Learn more in the [`pipeline upload` CLI reference](/docs/agent/cli/reference/pipeline).

## Combining file-change and branch conditions with if_changed

The [`if_changed`](/docs/pipelines/configure/dynamic-pipelines/if-changed) attribute skips or includes steps based on which files changed, without requiring a generator script. See the full [`if_changed` reference](/docs/pipelines/configure/dynamic-pipelines/if-changed) for syntax, agent version requirements, and configuration options.

If you want to combine `if` and `if_changed` with OR logic (for example, "run this step on main OR when these files changed"), you need a generator script. There is no way to express this in a single step definition. The generator checks both conditions and produces the appropriate steps:

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

You can extend this pattern by chaining multiple uploads, where each phase's generator reads results from the previous phase (using [artifacts](/docs/pipelines/configure/artifacts) or [build meta-data](/docs/pipelines/configure/build-meta-data)) to decide what to upload next.

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

## Upload failures

In a static pipeline, a YAML syntax error is caught before the build runs. In a dynamic pipeline, the YAML is generated at build time and uploaded mid-build, so upload failures happen while the build is already running.

When an upload is rejected (invalid YAML, validation error) or fails (system error, timeout), `pipeline upload` exits with a non-zero status. The agent polls the control plane for the result after submitting the upload, and retries with backoff if processing takes longer than expected.

The risk is that your generator script does not propagate that failure. Bash does not exit on errors by default, so a failed `pipeline upload` in the middle of a script will not stop the script or fail the build step. The build continues without the uploaded steps, and nothing in the UI indicates they were expected.

To prevent this, add [`set -euo pipefail`](/docs/pipelines/configure/writing-build-scripts) to the top of your generator script:

```bash
#!/bin/bash
set -euo pipefail

.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload
```

The `e` flag causes the script to exit on any non-zero return. The `pipefail` option means a failure anywhere in a pipe (not just the last command) fails the whole pipe. Together, they ensure that if `pipeline upload` fails for any reason, the build step fails too. See [Writing build scripts](/docs/pipelines/configure/writing-build-scripts) for more on these options.

## Debugging your generator

With a static pipeline, the YAML is in the repository and can be read directly. With a dynamic pipeline, the output only exists at runtime. The approaches below cover local development through to production validation.

**Local validation with `--dry-run`.** The [`--dry-run`](/docs/agent/cli/reference/pipeline#uploading-pipelines) flag parses and interpolates the pipeline definition, then prints the result to stdout instead of uploading it. Use this during development to catch YAML syntax errors and step validation issues before committing:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --dry-run
```

If the YAML is invalid, the agent exits with an error like `buildkite-agent: fatal: pipeline parsing of "(stdin)" failed: <parse error details>`. The parse error might not pinpoint the exact line, so for complex generators, redirecting the output to a file and running it through a YAML linter can be faster. You can also validate pipeline YAML with [`bk pipeline validate`](/docs/platform/cli/reference/pipeline#validate-a-pipeline).

**Production validation with artifact capture.** In production, the generator runs at build time and you need an automated record of what it produced. The following pattern saves the generated YAML as a [build artifact](/docs/pipelines/configure/artifacts), validates it, then uploads it:

```bash
#!/bin/bash
set -euo pipefail

# Generate and save output
.buildkite/generate-pipeline.sh > /tmp/generated-pipeline.yml

# Validate before uploading
buildkite-agent pipeline upload --dry-run < /tmp/generated-pipeline.yml > /dev/null

# Save as artifact for auditing and debugging
buildkite-agent artifact upload /tmp/generated-pipeline.yml

# Upload the validated pipeline
buildkite-agent pipeline upload /tmp/generated-pipeline.yml
```

This gives you three things: the `--dry-run` step catches invalid YAML before it reaches the control plane (and fails the build using `set -e` if it does), the artifact provides a record of what was generated for every build, and `set -euo pipefail` ensures any failure at any stage stops the build (see [Upload failures](#upload-failures)).

The artifact is available on the build page and using [`buildkite-agent artifact download`](/docs/agent/cli/reference/artifact#downloading-artifacts).

## Upload performance at scale

After a `pipeline upload` call, the control plane parses, validates, and merges the uploaded steps into the running build. The agent waits for this processing to complete, polling the control plane for the result with dynamic backoff. For small uploads this takes under a second. For large uploads (hundreds of steps), processing can take significantly longer.

If processing exceeds the server-side timeout, the control plane returns an HTTP 529 status and the agent retries automatically (up to 60 attempts with increasing intervals). With `set -euo pipefail` in your generator script (see [Upload failures](#upload-failures)), the build step fails if the agent exhausts its retries.

For generators that produce large numbers of steps, splitting the output across multiple smaller `pipeline upload` calls reduces the chance of hitting processing timeouts. Each upload is processed independently, so two uploads of 300 steps each will process faster and more reliably than a single upload of 600. The [monorepo best practices](/docs/pipelines/best-practices/working-with-monorepos#tip-for-large-monorepos) page and [`pipeline upload` reference](/docs/agent/cli/reference/pipeline#uploading-pipelines) both recommend this approach for large pipelines.

```bash
#!/bin/bash
set -euo pipefail

# Upload steps per service instead of one large pipeline document.
# Each pipeline upload call is processed independently on the control plane.

for service in api web worker payments notifications search; do
  cat <<YAML | buildkite-agent pipeline upload
steps:
  - label: ":test_tube: Test ${service}"
    command: "make test -C services/${service}"
    key: "test-${service}"
  - label: ":rocket: Deploy ${service}"
    command: "make deploy -C services/${service}"
    depends_on: "test-${service}"
YAML
done
```

Each upload is small enough to process quickly. The same approach works for any generator that iterates over a list of targets: test shards, changed paths, or matrix combinations. Use `depends_on` to control execution order, since multiple uploads from a single step are inserted in reverse order (see [Things to know](#things-to-know)).

For even larger workloads, use [trigger steps](/docs/pipelines/configure/step-types/trigger-step) to fan work out across separate builds. Each triggered build has its own upload and job limits, which avoids large single-build step counts entirely.

## Retrying steps that upload

A step that runs `pipeline upload` can fail and be retried. When it retries, the generator runs again and calls `pipeline upload`, but the steps from the first run are still in the build.

If those steps have `key` values, the second upload fails with a duplicate key error. If they don't have keys, duplicate steps are silently added to the build.

Always set `key` on every step your generator produces. This ensures a retried upload fails with a clear error instead of creating duplicates.

If the upload step is responsible for the entire remaining pipeline, use the `--replace` flag to make retries safe:

```bash
.buildkite/generate-pipeline.sh | buildkite-agent pipeline upload --replace
```

The `--replace` flag removes all pending steps before adding the new ones. Jobs already running are not affected. Learn more in the [`pipeline upload` CLI reference](/docs/agent/cli/reference/pipeline#replace).

Do not use `--replace` when multiple steps each upload their own portion of the build. A retry of one step would remove the steps uploaded by the others.

## Observability for dynamic builds

Dynamic pipelines can produce different steps on every build. A monorepo generator might produce 3 steps on one commit and 47 on the next. To debug failures or compare build times across runs, you need to know which steps the generator produced and why.

For general pipeline monitoring, including fleet health, build lifecycle traces, and queue metrics, see the [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability) page.

For dynamic pipelines, add a step to your generator that records what it decided. Use [build annotations](/docs/pipelines/configure/annotations) to surface a summary on the build page, and [build meta-data](/docs/pipelines/configure/build-meta-data) to store the decision inputs for querying later using the API.

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
  - label: ":test_tube: Test ${service}"
    command: "make test -C services/${service}"
    key: "test-${service}"
YAML
done
```

Use consistent `key` values across builds so you can compare the same logical step across different generator outputs. For example, always using `test-api` as the key for the API test step means you can track that step's duration over time, even when the rest of the pipeline changes.

## Security considerations for dynamic pipelines

Any running job can call `pipeline upload` to add steps to the current build. If a forked repository modifies `.buildkite/` scripts, those scripts run on your agents and can upload arbitrary steps. The [Enforcing security controls](/docs/pipelines/best-practices/security-controls) page recommends [disabling fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for public pipelines. For pipelines that need to accept fork builds, a generator can gate them with a `block` step requiring manual approval:

```bash
#!/bin/bash
set -euo pipefail

if [ "${BUILDKITE_PULL_REQUEST_REPO}" != "" ] && \
   [ "${BUILDKITE_PULL_REQUEST_REPO}" != "${BUILDKITE_REPO}" ]; then
  buildkite-agent pipeline upload <<'YAML'
steps:
  - block: ":lock: Approve fork build"
    prompt: "This build is from a fork. Review the code before allowing it to run on our agents."
YAML
fi

# Upload the main pipeline. Steps appear after the block step if one was added.
buildkite-agent pipeline upload
```

This can also be done with a static `if` conditional on a block step (`if: build.pull_request_repo != "" && build.pull_request_repo != build.repository`). The generator approach is useful when you need more complex logic, such as checking an allowlist of trusted fork repos.

[Pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) prevents unsigned steps from being injected using `pipeline upload`. For dynamic pipelines, this means the generator script and the steps it produces must be signed. See the [signed pipelines](/docs/agent/self-hosted/security/signed-pipelines) documentation for setup.

In Kubernetes environments, `pipeline upload` can be used to inject steps that run with higher-privilege service accounts, creating a privilege escalation path. Audit which steps can call `pipeline upload` and what service accounts those steps run under.
