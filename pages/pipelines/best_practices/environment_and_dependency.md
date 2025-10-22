# Environment and dependency management

Design build environments to be reproducible, secure, and fast. Favor hermetic, containerized builds with explicit dependency versions, consistent injection of configuration, and layered caching strategies. Ground these practices in Buildkite concepts like agents, queues, plugins, and dynamic pipelines.

## Containerize builds for consistency

- Prefer Docker-based steps for isolation and repeatability. Use the Docker and Docker Compose plugins to match your app’s needs.
    * Single container: docker plugin
    * Multi-service or compose-first repositories: docker-compose plugin
- [Multi-stage Dockerfiles](https://docs.docker.com/build/building/multi-stage/) to keep images small and secure while supporting complex builds.
- Pin base images and tags. Avoid latest to prevent upstream drift.
- Align development, CI, and prod images to improve parity. Build once, run everywhere to reduce environment drift.
- Keep images deterministic:
    * Pin OS packages by version
    * Avoid apt-get upgrade without pinning
    * Record build arguments and labels for provenance (e.g., `vcs ref`, pipeline URL)
- Manage image pull reliability and cost:
    * Use a private registry or ECR/GCR with regional mirrors
    * Authenticate pulls with OIDC rather than static keys where possible
    * Consider Docker Hub rate limits and local caching strategies on agents

## Handle dependencies reliably

- Lock versions:
    * Commit lockfiles (`npm`/`yarn`/`pnpm`, `pip-tools`/`poetry`/`uv`, Bundler, `go.mod`, `cargo`, etc.)
    * Pin plugin versions in pipelines to avoid breaking changes
- Cache packages appropriately:
    * Language-level caches scoped to the repo and dependency hash
    * Separate cache keys for prod vs development dependencies
    * Invalidate caches on lockfile changes
- Verify integrity:
    * Enable checksums or signatures for package managers
    * Generate and keep SBOMs for artifacts
- Ensure reproducibility:
    * Normalize locale, timezone, and CPU features where relevant
    * Avoid nondeterministic build steps and time-based versioning
- Constrain concurrency for non-thread-safe tools to avoid flakiness. Prefer parallel fan-out across hermetic steps instead.

## Don’t hard‑code environment values

Inject configuration via environment variables, secrets managers, and pipeline metadata rather than hard-coding in scripts or Dockerfiles.

```yaml
# ❌ Bad
command: "[deploy.sh](http://deploy.sh) https://api.myapp.com/prod"

# ✅ Good
command: "[deploy.sh](http://deploy.sh) $API_ENDPOINT"
env:
  API_ENDPOINT: "https://api.myapp.com/prod"
```

- Use step-level env, pipeline env, or hooks to set values.
- Keep secrets out of pipeline.yml and repositories. Use a secrets manager or Buildkite Secrets and inject at runtime with least privilege.
- Be aware of OS limits for environment size and `argv` preferences; prefer files for very large payloads.

## Secure secrets and cloud access

- Prefer short‑lived credentials and OIDC federation for cloud access instead of long‑lived keys.
- Scope secrets to the minimal set of steps and queues that need them.
- Rotate regularly, log access, and audit usage paths.

## Optimize agent hosts and queues for environment needs

- Create queues that map to specific environments: OS, CPU/RAM, GPU, network access, trust boundary.
- Keep system dependencies off the host when possible; move them into containers.
- If host-level tooling is required, pin versions and manage via IaC.
- Use ephemeral agents for untrusted workloads. Persist only what is necessary for caches within the correct trust boundary.

## Language-specific notes

- Node.js: Commit package-lock.json or yarn.lock. Use corepack or pinned npm/yarn versions. Consider pnpm for monorepos.
- Python: Prefer pinned virtual environments via uv/pip-tools/poetry. Build wheels in a consistent manylinux image if shipping native code.
- Ruby: Commit Gemfile.lock. Use Bundler with deployment flags to ensure locked resolution.
- Go: Rely on `go.mod` and `checksum db`. For `cgo`, standardize the build image and toolchain.
- Java/Scala: Pin toolchains via SDKMAN/asdf or containerize. Cache Maven/Gradle directories keyed by lockfiles and JDK version.
- Rust: Pin `rustup` toolchain. Cache cargo registry and target directories keyed by Cargo.lock and target triple.

## Build script hygiene

- Use strict Bash flags in scripts run by Buildkite to catch errors early:
    * set `-euo pipefail`
    * Consider set -x only for debug
- Don’t assume shell init files; explicitly configure shell behavior and dependencies in your [build scripts](/docs/pipelines/configure/writing-build-scripts)
- Fail fast with clear exit codes. Surface summaries via annotations for quick feedback.

## Reproducible Docker builds in pipelines

- Keep RUN steps idempotent and pinned
- Avoid copying host-specific files that can change in an uncontrolled manner
- Use build arguments only when necessary and pin their values in CI
- Label images with source commit, pipeline URL, and build timestamp for traceability

Example compose step:

```yaml
steps:
  - label: ":docker: Build"
    plugins:
      - docker-compose#v5.5.0:
          build: app
          image-repository: "registry.local/your-team/app"
          push: true
          config: [docker-compose.ci](http://docker-compose.ci).yml
    env:
      APP_VERSION: "${BUILDKITE_COMMIT}"
```

Reference the official Docker and Docker Compose plugins when choosing the right approach for your repo shape.

## Environment configuration patterns

- Centralize shared environment defaults at the pipeline or queue level
- Override per step only when necessary to keep intent obvious
- Use metadata and inputs to thread environment choices through dynamic pipelines
- Validate required variables at step start and fail with actionable messages
- Document the minimal env contract for each step

### Governance and compliance touch points

- Sign and verify artifacts as part of the build
- Generate SBOMs and attach to artifacts
- Gate promotions on policy checks and required reviews

## Observability for environments

- Emit key build-time environment facts as annotations:
    * Image digest and source
    * Toolchain versions
    * Cache hit ratios
- Track queue wait time, build time by step, cache effectiveness, and flake rate. Use this data to adjust caching and parallelism.

## When to avoid containers

- Some macOS or device-bound builds require host access. In those cases:
    * Isolate via queues
    * Pin Xcode/SDK versions explicitly
    * Keep host images or AMIs reproducible and versioned
    * Minimize host-level state and rely on artifacts
