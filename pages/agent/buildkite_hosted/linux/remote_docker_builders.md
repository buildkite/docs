# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/agent/buildkite-hosted), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command and [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) subcommands such as `docker buildx build` and `docker buildx bake`. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> Remote Docker builders are included in the [Enterprise](https://buildkite.com/pricing) plan. On plans without them, Docker images are built on your hosted agent instances. Learn where each build runs and how its layers are cached in [How Docker image builds run](#how-docker-image-builds-run).

## How Docker image builds run

Where a Docker image build runs, and whether it reuses layers from earlier builds, depends on your plan and on the builder your step selects:

| Setup | Where images are built | Layer cache |
| --- | --- | --- |
| Enterprise plan | On [remote Docker builders](#remote-docker-builders-overview) | Kept on the remote Docker builder |
| Plan without remote Docker builders | On the hosted agent instance | Kept on a volume automatically, as described in [Layer caching without remote Docker builders](#layer-caching-without-remote-docker-builders) |
| Any plan, with `BUILDX_BUILDER` set to `default` | On the hosted agent instance | None, unless you [keep the layer cache](#building-docker-images-on-the-buildkite-hosted-agent-keep-the-layer-cache) yourself |

## Remote Docker builders overview

When using the remote Docker builders feature, Docker image builds within your pipeline are directed to and run on an external [builder service](https://docs.docker.com/build/builders/) (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build configuration to this remote builder service, the builder service itself builds the images and returns the completed images and metadata to the job that initiated the build on your agent. These completed images are also stored in your [container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes), if you've enabled this feature. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

The remote builder service maintains a [build cache](https://docs.docker.com/build/cache/) on its local file system, allowing subsequent builds to reuse unchanged layers. Container cache volumes store completed images for jobs to pull, not the builder's build cache.

When using remote Docker builders, your first few pipeline builds will typically require more time to complete. However, once the required layers and their images have been built, any subsequent pipeline builds are completed much more rapidly. Learn more about how remote Docker builders improve the speed and performance of your pipeline builds in [Benefits of using remote Docker builders](#benefits-of-using-remote-docker-builders).

## Step-by-step remote Docker builder process

The following steps outline this remote Docker builder process in more detail:

1. A Buildkite hosted agent runs a Docker image build command in one of its pipeline jobs—for example, `docker build`, `docker buildx build`, or `docker buildx bake`. Because the agent's active [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) builder is pre-configured to target the remote [builder](https://docs.docker.com/build/builders/) service (which uses [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit)), the build is dispatched to the remote builder service. Learn more about Buildx and BuildKit in [Docker Build overview](https://docs.docker.com/build/concepts/overview/).

1. The remote builder service executes stages in parallel where possible, reusing unchanged layers from its local build cache and building only the new layers needed.

1. The build outputs are delivered based on flags used on the command, for example, loaded back to the agent with no additional flags, or pushed to a registry or exported to an OCI archive with `--push`.

## Benefits of using remote Docker builders

This section provides more details about the benefits provided by [remote Docker builders](#remote-docker-builders-overview).

### Faster builds

Remote Docker builders run on remote dedicated machines, which have been optimized for [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Therefore, CPU-bound stages are completed much more rapidly.

Your [container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes) are both shared and persistent, ensuring your job will start and run as quickly as possible. Incremental builds also reliably skip unchanged image layers as they're kept on the dedicated remote Docker builder's local file system, often yielding 2-40 times build speed increases.

Using remote Docker builders with the container cache volumes alongside [Git mirror volumes](/docs/agent/buildkite-hosted/cache-volumes#git-mirror-volumes) can provide drastic reductions in job runtimes.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

The remote Docker builders are dedicated machines with their own local file system cache that temporarily stores their image layers for 30 minutes from each build. Therefore, during periods of time when frequent image builds occur, the availability of stored relevant image layers on this file system improves the reuse of these layers, leading to a greater environmental consistency.

## Building Docker images on the Buildkite hosted agent

On the Enterprise plan, Docker image builds run on [remote Docker builders](#remote-docker-builders-overview) unless you select another builder. To build Docker images on the hosted agent instance that runs the job instead, set the `BUILDX_BUILDER` environment variable to `default` for the step. This selects Docker's default local builder for every build command in the step, including `docker build`, `docker buildx build`, and `docker buildx bake`:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally"
    env:
      BUILDX_BUILDER: "default"
    command: |
      docker buildx build --tag my-image:latest .
```

You can also select this builder by running `docker buildx use default` in the step's command, or by passing the `--builder default` flag to a single command.

> 🚧 The default builder doesn't keep a layer cache
> Each job starts with an empty Docker build cache, so the `default` builder rebuilds every layer in every job. This also applies on plans without remote Docker builders, because selecting the `default` builder bypasses their [layer caching volumes](#layer-caching-without-remote-docker-builders). To reuse unchanged layers between jobs, [keep the layer cache](#building-docker-images-on-the-buildkite-hosted-agent-keep-the-layer-cache) on a cache volume or in your internal container registry.

Setting the `DOCKER_BUILDKIT` environment variable to `0` also builds images on the hosted agent instance, but uses Docker's deprecated legacy builder. The legacy builder doesn't support `--cache-to`, so the [cache export examples below](#building-docker-images-on-the-buildkite-hosted-agent-keep-the-layer-cache) require BuildKit.

### Keep the layer cache

To reuse layers between builds that use the `default` builder, store the layer cache on a [cache volume](/docs/agent/buildkite-hosted/cache-volumes). Add a `cache` attribute to the step and export the cache to a directory on the volume. Each build writes a new copy of the cache and then replaces the old one, so the cache doesn't keep growing:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally with layer cache"
    env:
      BUILDX_BUILDER: "default"
    cache:
      paths:
        - ".docker-cache"
      name: "docker-layer-cache"
    command: |
      docker buildx build \
        --cache-from "type=local,src=.docker-cache/my-image" \
        --cache-to "type=local,dest=.docker-cache/my-image-new,mode=max" \
        --tag my-image:latest \
        .
      rm -rf .docker-cache/my-image
      mv .docker-cache/my-image-new .docker-cache/my-image
```

- The first build reports that the cache wasn't found and continues without it. Later builds reuse every unchanged layer.
- The `mode=max` option also caches the intermediate stages of multi-stage builds, so these stages are reused when a later stage changes. The default mode doesn't cache them.
- Write the cache in every build, including builds that don't push an image, so that pull request builds have a cache to reuse.
- Use a separate cache directory for each image.
- Builds on all branches share the volume, so a build can start from the cache that another branch wrote.

Volumes are [non-deterministic](/docs/agent/buildkite-hosted/cache-volumes#lifecycle-non-deterministic-nature). A volume only keeps the changes from jobs that pass, and a job can start with an empty or older copy of the volume, even right after another job has written to it. If every build needs the cache, store it in your cluster's [internal container registry](/docs/agent/buildkite-hosted/internal-container-registry) instead. Each build then downloads and uploads the cache over the network, and jobs can read from and write to this registry without logging in:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally with layer cache in the registry"
    env:
      BUILDX_BUILDER: "default"
    command: |
      docker buildx build \
        --cache-from "type=registry,ref=$${BUILDKITE_HOSTED_REGISTRY_URL}/buildcache/my-image:cache" \
        --cache-to "type=registry,ref=$${BUILDKITE_HOSTED_REGISTRY_URL}/buildcache/my-image:cache,mode=max" \
        --tag my-image:latest \
        .
```

Use a separate cache reference for each image. When several builds write the same reference, the last build to finish replaces the cache.

For `docker buildx bake`, set the `cache-from` and `cache-to` attributes on each target in your bake file.

## Layer caching without remote Docker builders

If your Buildkite organization's plan doesn't include [remote Docker builders](#remote-docker-builders-overview), `docker build`, `docker buildx build`, and `docker buildx bake` commands run on the hosted agent instance, and reuse unchanged layers from earlier builds without any configuration. The layers are cached on a [volume](/docs/agent/buildkite-hosted/cache-volumes) for each Git repository used by a pipeline.

These volumes appear in your [cluster](/docs/pipelines/security/clusters)'s volumes list. Their names are based on your cloud-based Git service's account and repository name, and begin with "buildkite-local-builder-". For example, **buildkite-local-builder-my-account-my-repository**.

Like other cache volumes, these volumes are [non-deterministic](/docs/agent/buildkite-hosted/cache-volumes#lifecycle-non-deterministic-nature), so some builds start without the cache. Builds that select the `default` builder, for example, by setting `BUILDX_BUILDER` to `default`, don't use these volumes.

You can view all of your current cluster's volumes through its **Cached Storage** > **Volumes** page.
