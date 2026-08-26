# Caching

Proper caching makes your builds faster and cheaper by reusing data across jobs and builds. This page covers the caching capabilities and recommended patterns for Buildkite Pipelines.

## Choosing a caching approach

Buildkite Pipelines supports several caching approaches. Which ones you can use depends on where your agents run:

Approach | Runs on | How data is addressed | Scope and retention | Availability
--- | --- | --- | --- | ---
[Buildkite Cache](/docs/pipelines/configure/cache) | Buildkite hosted agents and self-hosted agents in a [cluster](/docs/pipelines/security/clusters) | Explicitly, using the `buildkite-agent cache save` and `buildkite-agent cache restore` commands with a cache key you define | Held in a cluster cache registry, with configurable pipeline, branch, and build scopes. Entries expire three days after they're created or last restored by an exact key match | Currently in private preview
[Cache volumes](/docs/agent/buildkite-hosted/cache-volumes) | Buildkite hosted agents only | Implicitly, from the paths you list in the `cache` attribute of your pipeline YAML | Scoped to a pipeline and shared between its steps. Retained for up to 14 days from last use | Generally available
[Build artifacts](/docs/pipelines/configure/artifacts) | Any agent | Explicitly, by uploading and downloading files by path, job, or build | Retained according to your artifact storage policy | Generally available
Plugins and external caches | Any agent | Whatever the plugin or tool implements, such as an Amazon S3 bucket or a Bazel remote cache | You manage the storage and its lifecycle | Generally available
{: class="responsive-table"}

### Buildkite Cache compared with cache volumes

Buildkite Cache and cache volumes have similar names, and both cache data between jobs, but they behave differently:

Behavior | Buildkite Cache | Cache volumes
--- | --- | ---
Determinism | A job restores the entry that matches its cache key, or reports a miss that the build can handle | Volumes are attached on a best-effort basis depending on locality, expiration, and current usage, so what a job finds in one varies between builds
Storage and performance | Entries are archived to an object store, so every save and restore transfers and extracts data. Large caches cost network time in each job that uses them | The volume is a disk attached to the agent instance, using NVMe storage on Linux, so jobs read and write files in place with nothing to transfer
Partial matches | Marking one cache key part with `fallback_limit` lets a restore fall back to the newest entry matching the earlier parts | Not configurable. A job uses whatever the attached volume contains
Access control | Cache registry policies scope entries by pipeline, branch, or build, and rules determine which jobs can save or restore them | No equivalent. Volume access isn't restricted by job, branch, or build
Concurrency | An entry is written once per address. Concurrent first saves to the same address can race | Each job works on a forked copy of the volume, and the volume is updated only after the job completes successfully
Configuration | A `.buildkite/cache.yml` file, plus `buildkite-agent cache save` and `buildkite-agent cache restore` commands in your steps | A list of paths under the `cache` attribute in your pipeline YAML
{: class="responsive-table"}

Use Buildkite Cache when a job needs to restore a known set of dependencies, when your builds run on self-hosted agents, or when untrusted builds share a cluster and cache access needs to be controlled. Use cache volumes for large working data on Buildkite hosted agents, where local disk speed matters more than knowing exactly what a job will find.

Whichever approach you choose, design your builds to succeed after a cache miss.

## What to cache

Cache the following for faster builds:

- Dependency directories for your language or build tool
- Large files repeatedly downloaded from the Internet
- Git mirrors by enabling [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) on your agents
- Docker build layers using plugins like [Docker ECR Cache Buildkite plugin](https://github.com/seek-oss/docker-ecr-cache-buildkite-plugin) for ECR/GCR

> 📘
> Git mirrors on [Buildkite hosted agents](/docs/agent/buildkite-hosted) can be enabled with the help of [cache volumes](/docs/agent/buildkite-hosted/cache-volumes). Additionally, you can also enable [queue images](/docs/agent/buildkite-hosted/linux#agent-images).

Don't cache:

- Final build artifacts that will be published elsewhere
- Test outputs that depend on current code

## Caching strategies

- For Git checkout caching, use Git mirrors or shallow clones on persistent workers to speed up fetches. Learn more in [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).
- For caching dependencies:

    * Key off the lockfile hash and platform
    * Separate build from test caches if they diverge

- Docker layer caching:

    * Order your Dockerfile's structure in such a way that immutable layers (OS packages and core dependencies) come first
    * Copy lockfiles before installation to maximize cache hits

- For artifact caching, store heavyweight build outputs as artifacts between steps instead of re-building. See more in the following section.

## Using Buildkite Cache

When you cache with [Buildkite Cache](/docs/pipelines/configure/cache), most of the design work is in the cache key:

- Order key parts from coarse to fine. A restore drops optional parts from the end of the key, so put stable values such as the cache name, operating system, and architecture first, and the most specific value, such as a lockfile checksum, last.
- Mark the part immediately before your lockfile checksum with `fallback_limit: true`. A lockfile change then still restores the previous set of dependencies, and the install command reconciles the difference instead of starting from nothing.
- Restore before the command that needs the data, and save after that command has populated the target path. A cache miss exits successfully, so the build carries on either way.
- Change a literal part of the key, such as bumping `v1` to `v2`, when you need to invalidate a cache. An entry is written once per address, so saving again won't refresh an entry that already exists.
- Keep target paths narrow. A restore deletes each target before extracting into it, so cache a dependency directory rather than a whole working directory.
- Expect misses in pipelines that build infrequently. Entries expire three days after they're created or last restored by an exact key match, and a fallback restore doesn't extend that.
- Don't cache secrets, credentials, or the output of untrusted builds. Where untrusted builds share a cluster, configure a cache registry policy before sharing a registry with them.
- Configure a storage lifecycle policy on your own bucket if your agents are self-hosted. Buildkite expires the registry metadata, but it can't delete objects from a store it doesn't manage.

## Using artifacts for caching

Buildkite [build artifacts](/docs/pipelines/configure/artifacts) are files uploaded by a job that you can download in later steps or later builds. Artifacts are durable and addressable, so you can reuse previously produced files to cache common data between steps instead of re-computing them. Unlike a purpose‑built cache, artifacts are:

- Build outputs with metadata and a download URL
- Retained according to your artifact storage policy
- Retrieved by path patterns, job, build number, or using the API

> 📘
> [Buildkite Cache](/docs/pipelines/configure/cache) and [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) serve different goals and trade-offs than artifacts. Cache volumes aim for speed with different retention and locality guarantees. Artifacts are deterministic and durable.

To use artifacts for caching:

1. Produce dependencies into a directory.
1. Compress the dependencies to a single archive keyed by an identifier that represents inputs, for example, a lockfile checksum.
1. Upload the result as an artifact.
1. In the later steps/builds, resolve the correct key (same checksum), download, and unpack.

This way, you keep downloads small and avoid re-installing dependencies when the inputs haven't changed.

## Using cached images

Operating at scale requires cached agent images. In those images, keep only the tooling needed for specific functions and avoid monolithic images. For example, a "security" image with ClamAV, Trivy, and Snyk or "frontend" image with Node.js, npm, and testing frameworks.

It's also recommended to:

- Build images nightly to include system, framework, and image updates.
- Store the images in [Buildkite Packages](https://buildkite.com/packages) or cloud provider registries.
- For hosted agents, use [agent images](/docs/agent/buildkite-hosted/linux#agent-images).

## Bazel caching

Buildkite Pipelines sends Bazel target commands to the build, from which distributed compilation is handled, leveraging Bazel's remote execution framework.

There are two main cache layers in Bazel:

- Local cache that exists on the agent machines and is great for iterative builds but is not shared across agents.
- Remote cache that is shared across machines, persists between builds, and is essential for CI and large monorepos.

### Remote cache options for Bazel

You can use the following approaches for creating and keeping a remote cache with Bazel:

- Object stores as backend - Google Cloud Storage or AWS S3 using Bazel’s HTTP cache flags.
- Managed services - [BuildBuddy](https://www.buildbuddy.io/) is a common choice for remote cache and optional remote execution.
- Self‑hosted cache - [Bazel-remote](https://github.com/buchgr/bazel-remote) on AWS (using ECS with S3 backend).

### Minimal setup for Bazel caching

In `.bazelrc`, set the following:

```bash
build --remote_cache=https://<your-cache-endpoint>
# If using GCS:
build --google_credentials=/path/to/credentials.json
# If using S3:
build --remote_upload_local_results=true
```

You can also pass `--remote_cache` on the command line per build/test invocation.

### Using Bazel caching with Buildkite

- Using Bazel caching works both with hosted agents and self-hosted agents - but you need to ensure network access to the cache and provide credentials using the environment or pre-command [hooks](/docs/agent/hooks).
- Teams commonly layer:
    * Local repository/repository cache in a persistent volume to skip external dependency fetches
    * Remote cache (for example, BuildBuddy or Bazel-remote) for cross-machine reuse

#### Best practices for Bazel caching

- Prefer remote cache for CI. Keep local repository cache in a persistent volume when possible to avoid re-downloading external dependencies on ephemeral agents.
- Co-locate cache and compute to reduce latency and cost as cache proximity matters.
- Warm the cache with representative builds. Monitor hit/miss rates using Bazel’s logs and remote-cache debugging guidance.
- Avoid cache poisoning:
    * Separate development and CI caches or treat CI cache as read-mostly “first tier”
    * Use tags like "no-remote-cache" on sensitive targets if needed
- Make credentials available at build time using secure secret management and pre-step hooks.

> 📘
> Ephemeral agents without persistent volumes lose local caches between jobs. You can mitigate this by using [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) and a robust remote cache.

## Hosted agents caching

[Cache volumes](/docs/agent/buildkite-hosted/cache-volumes) on [Buildkite hosted agents](/docs/agent/buildkite-hosted) are:

- Best‑effort attachment, shared across steps, scoped to a pipeline
- Well-suited for simple, fast, shared caching
- High‑performance NVMe on Linux and sparse bundle images on macOS
- Updated only on successful job completion and forked per job for safe concurrency.

> 📘 Non-deterministic behavior
> Cache volumes on Buildkite hosted agents are [non-deterministic by nature](/docs/agent/buildkite-hosted/cache-volumes#lifecycle-non-deterministic-nature) and allow for dependency caching and Git mirror caching.
> For deterministic caching in your pipeline, use Docker images with [remote Docker builders](/docs/agent/buildkite-hosted/linux/remote-docker-builders) which allow you to have fast Docker builds and the [internal container registry](/docs/agent/buildkite-hosted/internal-container-registry).

- What to cache:
    * Use cache volumes for local tool data that's expensive to refetch between ephemeral jobs, for example, Bazel repository cache and custom CLIs.
    * Prefer a remote cache (for example, BuildBuddy or Bazel-remote on AWS) for cross-machine reuse. Treat local volumes as best‑effort accelerators.
- Recommended caching patterns:
    * Use Buildkite hosted agents with cache volumes mounted to Bazel's repository cache path to avoid fetching the external dependencies twice.
    * Standardize cache config using a CI `bazelrc` emitted per job, injected alongside secrets in pre‑commands.
    * Use the [official Buildkite plugins](/docs/pipelines/integrations/plugins/directory) for caching (for example, the [Cache Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/)) when you need to persist directories by key to object storage (for example, S3).

> 📘
> Field reports show ~30% faster test times on hosted agents when cache volumes are used in combination with a remote cache.

### Practical tips

- Expect some non‑determinism with ephemeral volumes; Bazel will re‑download missing pieces. Keep remote cache as the source of truth.
- Co‑locate compute and cache to reduce latency.
- Keep images lean; preinstall `Bazelisk` and critical toolchains.
- Manage credentials using [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or your KMS - do not hard-code them into `.bazelrc`.

## Git Large File Storage (LFS) caching

Git LFS stores large files outside your repository in a separate storage location to keep clone sizes manageable, but downloading these objects during checkout can slow builds significantly. The strategies below help you minimize LFS download times:

- Skip LFS on checkout - set `GIT_LFS_SKIP_SMUDGE=1` during checkout, then run targeted `git lfs fetch` and `git lfs checkout` only for required paths.
- Mirror and prefetch - use [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) for base clones, then prefetch LFS objects with `git lfs fetch --recent` in a pre-command hook.
- Cache volumes - mount `.git/lfs/objects` (and optionally `.git/lfs/tmp`) in a cache volume to reuse blobs between jobs. Expect occasional cache misses; the remote LFS server remains authoritative.

> 📘
> Use Git mirrors to speed up clones and cache volumes to avoid re-downloading large objects.

### Practical tips

- Preinstall git-lfs in your agent image to avoid per-job setup overhead.
- Cache volumes are scoped per pipeline, shared across steps, and retained for 14 days since last use. Design for cache misses after inactivity.
- Cache volumes are locality-aware and non-deterministic. Always fetch from the LFS remote when you need guaranteed up-to-date objects.

To find out more about optimizing Buildkite Pipelines for handling Git LFS, see [Understanding the difference in default checkout behaviors](/docs/pipelines/migration/from-githubactions#understand-the-differences-the-difference-in-default-checkout-behaviors).
