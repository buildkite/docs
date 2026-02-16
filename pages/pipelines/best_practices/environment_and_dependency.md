# Environment and dependency management

This page covers best practices for containerized builds, dependency management, handling of secrets, and environment configuration using [Buildkite Agents](/docs/agent/v3), [queues](/docs/agent/v3/queues), [plugins](/docs/pipelines/integrations/plugins), and [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

## Build containerization for consistency

Containerization provides isolation and repeatability, ensuring that your builds run the same way across all environments. Use Docker-based steps to eliminate issues where something works locally but doesn't scale (a "works on my machine" kind of issue) and maintain strict control over build dependencies. It's further recommended to:

- Use the [Docker plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin) for single containers or [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin) for multi-service builds.
- Use [multi-stage Dockerfiles](https://docs.docker.com/build/building/multi-stage/) to keep images small and secure.
- Pin base images and tags and avoid using `latest` to prevent upstream drift.
- Align development, CI, and production images to reduce environment drift.
- Manage image pull reliability:
    * Use a [private registry](/docs/package-registries) or [Amazon Elastic Container Registries (ECR)](https://aws.amazon.com/ecr/)/[Google Container Registries (or Artifact Registries)](https://docs.cloud.google.com/artifact-registry/docs/transition/transition-from-gcr) with regional mirrors
    * Authenticate pulls with [OIDC](/docs/package-registries/security/oidc) rather than static keys
    * Account for [Docker Hub rate limits](https://docs.docker.com/docker-hub/usage/) and use local caching on agents

You can learn more in [Containerized builds with Docker](/docs/pipelines/best-practices/docker-containerized-builds).

## Dependency handling

Consistent dependency management prevents build failures and ensures reproducibility across environments. It's recommended that you lock all dependencies, cache intelligently, and verify integrity to maintain build stability.

- Lock versions:
    * Commit lockfiles (`package-lock.json`, `poetry.lock`, `Gemfile.lock`, `go.mod`, `Cargo.lock`).
    * Pin plugin versions in pipelines to avoid breaking changes.
- Cache packages appropriately:
    * Scope caches to repository and dependency hash.
    * Use separate cache keys for production vs development dependencies.
    * Invalidate caches on lockfile changes.
- Verify integrity:
    * Enable checksums or signatures for package managers.
    * Generate and keep [software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_supply_chain) for artifacts.
- Constrain [concurrency](/docs/pipelines/configure/workflows/controlling-concurrency) when necessary:
    * For non-thread-safe tools, prefer parallel fan-out across isolated steps.

## Handling environment values

Don't hard-code environment values. Inject configurations at runtime rather than hard-coding values in scripts or Dockerfiles. This improves flexibility, security, and the possibility to reuse configurations across environments. For example, here is a sample configuration with a non-recommended and recommended approach:

```yaml
# ❌ Non-recommended
command: "deploy.sh https://api.myapp.com/prod"

# ✅ Recommended
command: "deploy.sh $API_ENDPOINT"
env:
  API_ENDPOINT: "https://api.myapp.com/prod"
```

- Use step-level `env`, pipeline `env`, or [hooks](/docs/agent/v3/hooks) to set values.
- Keep secrets out of `pipeline.yml` and repositories—use a secrets manager or [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets).
- Be aware of the OS's limits for environment size; opt for using files instead of variables for large payloads.

## Optimizing agent hosts and queues for environment needs

- Match your agent infrastructure to your environment requirements by creating specialized [queues](/docs/agent/v3/queues) and minimizing host-level dependencies.
- Create queues that map to specific environments, for example the OS, CPU/RAM, GPU, network access, trust boundary, and so on.
- Keep system dependencies in containers when possible.
- If host-level tooling is required, pin versions and manage via [infrastructure-as-code (IaC)](https://aws.amazon.com/what-is/iac/) approach.
- Use [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent) for untrusted workloads.
- Persist only necessary caches within the correct trust boundary.

## Build script hygiene

Proper script hygiene prevents silent failures and makes debugging easier. Write robust build scripts that [fail fast](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs) and provide clear error messages.

- Use strict Bash flags in scripts to catch errors early:
    * `set -euo pipefail`
    * Consider only using `set -x` for debugging
- Don't assume shell init files; explicitly configure shell behavior in your [build scripts](/docs/pipelines/configure/writing-build-scripts).
- [Fail fast](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs) with clear exit codes.
- Surface summaries via [Buildkite annotations](/docs/agent/v3/cli/reference/annotate) for quick feedback.

## Reproducible Docker builds in pipelines

Ensure Docker builds are consistent and traceable by pinning dependencies and labeling images with build metadata.

- Keep `RUN` steps idempotent and pinned.
- Avoid copying host-specific files that can change uncontrollably.
- Use build arguments only when necessary and pin their values in CI.
- Label images with source commit, pipeline URL, and build timestamp for traceability.

Example Docker Compose step:

```yaml
steps:
  - label: "Docker :rocket:"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          image-repository: "registry.local/your-team/app"
          push: true
          config: docker-compose.ci.yml
    env:
      APP_VERSION: "${BUILDKITE_COMMIT}"
```

For more best practices for using Docker, see [Containerized builds with Docker](/docs/pipelines/best-practices/docker-containerized-builds).

## Environment configuration patterns

Establish clear patterns for managing environment configuration across your pipelines. Centralized defaults with targeted overrides reduce complexity and improve maintainability. It's recommended to:

- Centralize shared environment defaults at the pipeline or queue level.
- Use metadata and inputs to thread environment choices through [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).
- Validate required variables at step start and fail with actionable messages.

### Governance and compliance touch points

Integrate security and compliance checks directly into your build process to ensure artifacts meet organizational standards before deployment.

- Sign and verify artifacts as part of the build.
- Generate SBOMs and attach to artifacts.
- Gate promotions on policy checks and required reviews.

See more on governance in [Governance overview](/docs/pipelines/governance).

## Observability for environments

Monitor and measure your build environments to identify optimization opportunities and track performance over time.

- Emit key build-time environment facts as [annotations](/docs/agent/v3/cli/reference/annotate):
    * Image digest and source
    * Toolchain versions
    * Cache hit ratios
- Track [queue metrics](/docs/pipelines/insights/queue-metrics), build time by step, and [flake rates](/docs/test-engine).
- Use this data to adjust caching and [parallelism](/docs/pipelines/configure/workflows/controlling-concurrency#concurrency-and-parallelism).
