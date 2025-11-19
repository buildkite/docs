# Caching

Proper caching makes your builds faster and cheaper by reusing data across jobs and builds. This page covers Buildkite's caching capabilities and recommended patterns.

## What to cache

Cache the following for faster builds:

- Dependency directories for your language or build tool
- Large files repeatedly downloaded from the internet
- Git mirrors by enabling [Git mirrors](/docs/agent/v3/git-mirrors) on your agents
- Docker build layers using plugins like [Docker ECR Cache Buildkite plugin](https://github.com/seek-oss/docker-ecr-cache-buildkite-plugin) for ECR/GCR

> 📘
> Git mirrors on Buildkite hosted agents can be enabled with the help of [cache volumes](/docs/pipelines/hosted-agents/cache-volumes). Additionally, you can also enable [queue images](/docs/pipelines/hosted-agents/linux#agent-images).

Don't cache:

- Final build artifacts that will be published elsewhere
- Test outputs that depend on current code

## Caching strategies

- Git checkout: Use mirrors or shallow clones on persistent workers to speed up fetches
- Dependency caches:

    * Key off the lockfile hash and platform
    * Separate build vs test caches if they diverge

- Docker layer caching:

    * Order Dockerfile so immutable layers (OS packages, core `deps`) come first
    * Copy lockfiles before install to maximize cache hits

- Artifact caching: Store heavyweight build outputs as artifacts between steps instead of re-building.

## Caching via artifacts

Buildkite artifacts are files uploaded by a job that you can download in later steps or later builds. They’re durable and addressable, so you can reuse previously produced files to cache common data between steps instead of re-computing them. Unlike a purpose‑built cache, artifacts are:

- Build outputs with metadata and a download URL
- Retained according to your artifact storage policy
- Retrieved by path patterns, job, build number, or via the Artifacts API

> 📘
> Buildkite’s dedicated cache features and hosted Cache Volumes serve different goals and trade-offs. Artifacts are deterministic and durable; caches/volumes aim for speed with different retention and locality guarantees.

### Using artifacts for caching

1. Produce dependencies into a well-known directory.
1. Compress to a single archive keyed by an identifier that represents inputs, e.g. a lockfile checksum.
1. Upload as an artifact.
1. In later steps/builds, resolve the correct key (same checksum), download, and unpack.

This keeps downloads small and deterministic, and avoids re-installing dependencies when inputs haven’t changed.

## Using cached images

Operating at scale requires cached agent images. In those images, keep only the tooling needed for specific functions—avoid monolithic images. For example, a "security" image with ClamAV, Trivy, and Snyk or "frontend" image with Node.js, npm, and testing frameworks.

It's also recommended to:

- Build images nightly to include system, framework, and image updates.
- Store the images in [Buildkite Packages](https://buildkite.com/packages) or cloud provider registries.
- For hosted agents, use [agent images](/docs/pipelines/hosted-agents/linux#agent-images).

## Bazel caching

Buildkite Pipelines sends Bazel target commands to the build form which distributed compilation is handled, leveraging Bazel's remote execution framework.

There are two main cache layers in Bazel:

- Local cache that lives on the agent machines, great for iterative builds but is not shared across agents.
- Remote cache that shared across machines, persists between builds, and is essential for CI and large monorepos.

### Remote cache options for Bazel

- Object stores as backend: Google Cloud Storage or AWS S3 via Bazel’s HTTP cache flags.
- Managed services: BuildBuddy is a common choice in the field for remote cache and optional remote execution.
- Self‑hosted cache: bazel-remote on AWS (ECS + S3), with example IaC and setup guidance.

### Minimal setup for Bazel caching

In .bazelrc:

```bash
build --remote_cache=https://<your-cache-endpoint>
# If using GCS:
build --google_credentials=/path/to/credentials.json
# If using S3:
build --remote_upload_local_results=true
```

You can also pass `--remote_cache` on the command line per build/test invocation.

### Using Bazel caching on Buildkite

- Hosted agents and self-hosted agents both work; ensure network access to the cache and provide credentials via environment or pre-command hooks.
- Teams commonly layer:
    * Local repos/repository cache in a persistent volume to skip external dependency fetches.
    * Remote cache (e.g., BuildBuddy or bazel-remote) for cross-machine reuse.

#### Best practices for Bazel caching

- Prefer remote cache for CI. Keep local repository cache in a persistent volume when possible to avoid re-downloading external `deps` on ephemeral agents.
- Co-locate cache and compute to reduce latency and cost; cache proximity matters.
- Warm the cache with representative builds. Monitor hit/miss rates using Bazel’s logs and remote-cache debugging guidance.
- Avoid cache poisoning:
    * Separate development and CI caches or treat CI cache as read-mostly “first tier.”
    * Use tags like "no-remote-cache" on sensitive targets if needed.
- Make credentials available at build time via secure secret management and pre-step hooks.

#### Common pitfalls

- Ephemeral agents without persistent volumes lose local caches between jobs; mitigate by using cache volumes and a robust remote cache.
- Cross-platform cache misses due to configuration differences; ensure deterministic toolchains and consistent flags.
- Misconfigured credentials or network egress blocking remote cache access.

## Hosted agents caching

- What to cache:
    * Use cache volumes for “local” tool data that’s expensive to refetch between ephemeral jobs, e.g. Bazel repository cache and custom CLIs.
    * Prefer a remote cache (e.g., BuildBuddy or Bazel-remote on AWS) for cross-machine reuse. Treat local volumes as best‑effort accelerators.
- Patterns that work:
    * Buildkite macOS hosted agents + cache volumes mounted to Bazel’s repository cache path to avoid fetching the external dependency twice.
    * Standardize cache config via a CI ``bazelrc emitted per job, injected alongside secrets in pre‑commands.
    * Use official Cache plugins when you need to persist directories by key to object storage (S3, etc.).

- Hosted agent cache volumes:

    * Best for simple, fast, shared caching within a pipeline
    * High‑performance NVMe on Linux and sparse bundle images on macOS
    * Best‑effort attachment, shared across steps, scoped to a pipeline
    * Updated only on successful job completion and forked per job for safe concurrency.

> 📘
> Field reports show ~30% faster test times on hosted agents when cache volumes are used in combination with a remote cache.

### Practical tips

- Expect some non‑determinism with ephemeral volumes; Bazel will re‑download missing pieces. Keep remote cache as the source of truth.
- Co‑locate compute and cache to reduce latency. Keep images lean; preinstall `Bazelisk` and critical toolchains.
- Manage credentials via BK secrets or your KMS, not hard-coded into `.bazelrc`.

## Git Large File Storage (LFS) caching

Git LFS stores large files outside your repository to keep clone sizes manageable, but downloading these objects during checkout can slow builds significantly. The strategies below help you minimize LFS download times:

- Skip LFS on checkout - set `GIT_LFS_SKIP_SMUDGE=1` during checkout, then run targeted `git lfs fetch` and `git lfs checkout` only for required paths.
- Mirror and prefetch - use [Git mirrors](/docs/agent/v3/git-mirrors) for base clones, then prefetch LFS objects with `git lfs fetch --recent` in a pre-command hook.
- Cache volumes - mount `.git/lfs/objects` (and optionally `.git/lfs/tmp`) in a cache volume to reuse blobs between jobs. Expect cache misses—the remote LFS server remains authoritative.

> 📘
> Use Git mirroring to speed clones and cache volumes to avoid re-downloading large objects.

### Practical tips

- Preinstall git-lfs in your agent image to avoid per-job setup overhead.
- Cache volumes are scoped per pipeline, shared across steps, and retained for 14 days since last use. Design for cache misses after inactivity.
- Cache volumes are locality-aware and non-deterministic. Always fetch from the LFS remote when you need guaranteed up-to-date objects.
