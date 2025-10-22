# Caching

Caching makes builds faster and cheaper by reusing work across jobs and builds. This guide distills Buildkite’s current capabilities and emerging patterns into practical recommendations with examples you can copy‑paste.

Efficient caching: optimize Dockerfile layering to maximize [cache reuse](https://docs.docker.com/build/cache/).

## What to cache

- Dependency directories for your language or build tool
- Docker build layers when applicable
- Large files repeatedly downloaded from the internet
- Git mirrors on hosted agents are handled for you and benefit from [caching automatically](/docs/pipelines/hosted-agents/cache-volumes)

Do not cache:

- Final build artifacts that you publish elsewhere
- Test outputs whose validity depends on the current code

Why: The greatest wins come from restoring dependency trees and Docker layers, not test results or end products.

## Choose the right caching mechanism

- Hosted agent cache volumes

    * Best for simple, fast, shared caching within a pipeline
    * High‑performance NVMe on Linux and sparse bundle images on macOS
    * Best‑effort attachment, shared across steps, scoped to a pipeline
    * Updated only on successful job completion and forked per job for safe concurrency.

- Plugins and registries
    * Use official or community plugins to cache Docker layers externally when needed
    * Example: docker‑ecr‑cache plugin for layer reuse in [ECR/GCR](https://github.com/seek-oss/docker-ecr-cache-buildkite-plugin)

Recommendation: Prefer hosted cache volumes for most hosted‑agent pipelines. Layer in key‑based cache where determinism and cross‑build control matter most (for example, lockfile‑keyed dependency caches).

## Caching strategies that don’t compromise reproducibility

- Git checkout:
    * Use mirrors or shallow clones on persistent workers to speed up fetches
    * Validate commit SHAs to avoid checkout surprises
- Dependency caches:
    * Key off the lockfile hash and platform
    * Separate build vs test caches if they diverge
- Docker layer caching:
    * Order Dockerfile so immutable layers (OS packages, core `deps`) come first
    * Copy lockfiles before install to maximize cache hits
- Artifact caching:
    * Store heavyweight build outputs as artifacts between steps instead of re-building
- Beware hidden state:
    * Clean workspaces where hermetic guarantees matter
    * Prefer “cache or clean” over “hope” patterns

## Tools for caching

- Bazel cache, local NPM cache, and usage of Redis alongside S3 for reducing the number of GitHub API calls and dependency retrieval overhead.
- Bazel: Buildkite sends Bazel target commands to the build form which distributed compilation is handled, leveraging Bazel's remote execution framework.
- Caching "hack" (Android + cache plugin + cache volumes).
- Docker + BuildKit, short-lived cache registries, and GCS for distributing precomputed seed data across globally scaled agents.
- Enhanced caching strategy: writing custom plugin(s) to cache Docker images, source code, and build artifacts + Kubernetes can be added for improved job allocation.
- Retain Docker images to avoid 4–5 minute pulls. Try storing the working directory in S3 (custom plugins and scripts), and cache database schemas and GraphQL outputs to speed up builds.
- Offload compilation from the build client to the build farm based on software checksum and versioning.

## Caching via artifacts

Buildkite artifacts could be used to "cache" common data between steps.

## Further work on this page

To do:

Bazel caching
Artifact caching
git mirror to be enabled in the agent (can also go in the agent section under something like speed up builds)
Git Large File Storage (LFS) caching (many customers use VMs due to LFS)
hosted agent caching
