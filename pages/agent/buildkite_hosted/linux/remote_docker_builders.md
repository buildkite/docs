# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/agent/buildkite-hosted), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command and [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) subcommands such as `docker buildx build` and `docker buildx bake`. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Default Enterprise plan feature
> Remote Docker builders is a _default feature_ available to all new and existing Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan. This means that for Enterprise plan customers, this feature is used automatically whenever a `docker build`, `docker buildx build`, or `docker buildx bake` command is encountered within Buildkite pipelines. However, you can disable this feature, so that Docker images are built on the Buildkite hosted agents themselves. Learn more about how to do this in [Building Docker images on the Buildkite hosted agent](#building-docker-images-on-the-buildkite-hosted-agent). If your Buildkite organization doesn't have access to this feature, then [additional volumes](#additional-volumes) are created in your Buildkite clusters.

## Remote Docker builders overview

When using the remote Docker builders feature, Docker image builds within your pipeline are directed to and run on an external [builder service](https://docs.docker.com/build/builders/) (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build configuration to this remote builder service, the builder service itself builds the images and returns the completed images and metadata to the job that initiated the build on your agent. These completed images are also stored in your [container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes), if you've enabled this feature. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

The remote builder service also maintains a [cache](https://docs.docker.com/build/cache/) of its built image layers (stored in the builder service's local file system, and in your [container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes)). Images already stored in this local file system usually don't need to be re-built upon a subsequent build, and any images in your container cache volumes can be pulled to jobs requesting them, which in turn, speeds up your overall pipeline builds, since your Buildkite hosted agents running these pipelines are free to build the rest of your pipeline and conduct other work.

When using remote Docker builders, your first few pipeline builds will typically require more time to complete. However, once the required layers and their images have been built, any subsequent pipeline builds are completed much more rapidly. Learn more about how remote Docker builders improve the speed and performance of your of your pipeline builds in [Benefits of using remote Docker builders](#benefits-of-using-remote-docker-builders).

## Step-by-step remote Docker builder process

The following steps outline this remote Docker builder process in more detail:

1. A Buildkite hosted agent runs a Docker image build command in one of its pipeline jobs—for example, `docker build`, `docker buildx build`, or `docker buildx bake`. Because the agent's active [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) builder is pre-configured to target the remote [builder](https://docs.docker.com/build/builders/) service (which uses [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit)), the build is dispatched to the remote builder service. Learn more about Buildx and BuildKit in [Docker Build overview](https://docs.docker.com/build/concepts/overview/).

1. The remote builder service executes stages in parallel where possible, reusing unchanged image layers in your container cache volumes and rebuilding images from only new layers that are needed.

1. The build outputs are delivered based on flags used on the command, for example, loaded back to the agent with no additional flags, or pushed to a registry or exported to an OCI archive with `--push`.

## Benefits of using remote Docker builders

This section provides more details about the benefits provided by [remote Docker builders](#remote-docker-builders-overview).

### Faster builds

Remote Docker builders run on remote dedicated machines, which have been optimized for [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Therefore, CPU-bound stages are completed much more rapidly.

Your [container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes) is both shared and persistent, ensuring your job will start and run as quickly as possible. Incremental builds also reliably skip unchanged image layers as they're kept on the dedicated remote Docker builder's local file system, often yielding 2-40 times build speed increases.

Using remote Docker builders with the container cache volumes alongside [Git mirror volumes](/docs/agent/buildkite-hosted/cache-volumes#git-mirror-volumes) can provide drastic reductions in job runtimes.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

The remote Docker builders are dedicated machines with their own local file system cache that temporarily stores their image layers for 30 minutes from each build. Therefore, during periods of time when frequent image builds occur, the availability of stored relevant image layers on this file system improves the reuse of these layers, leading to a greater environmental consistency.

## Building Docker images on the Buildkite hosted agent

Since [remote Docker builders](#remote-docker-builders-overview) is a [default Enterprise plan feature](#default-enterprise-plan-feature), when using `docker build`, `docker buildx build`, or `docker buildx bake` commands in your Buildkite pipelines, you can configure these commands to build Docker images on the Buildkite hosted agent itself by either [disabling BuildKit](#building-docker-images-on-the-buildkite-hosted-agent-disable-buildkit) or [using Buildx and its default local builder](#building-docker-images-on-the-buildkite-hosted-agent-use-buildx-and-its-default-local-builder).

The Buildx-based options work for any Buildx subcommand (including `docker buildx build`, `docker buildx bake`, and `docker buildx imagetools`), since they all use the agent's active Buildx builder. You can also override the builder for a single command by passing the `--builder default` flag, or for an entire step by setting the `BUILDX_BUILDER` environment variable to `default`.

### Disable BuildKit

Disabling BuildKit, which can be done by setting the `DOCKER_BUILDKIT` environment variable value to `0` _before_ running the `docker build` command, results in the Docker image being built on the Buildkite hosted agent.

For example:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally"
    command: |
      export DOCKER_BUILDKIT=0
      docker build -t my-image:latest .
```

Or:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally"
    env:
      DOCKER_BUILDKIT: "0"
    command: |
      docker build -t my-image:latest .
```

The `my-image:latest` image will be built on the Buildkite hosted agent.

### Use Buildx and its default local builder

Using Buildx and its default local builder (with the [`docker buildx use` command](https://docs.docker.com/reference/cli/docker/buildx/use/)) and then a Buildx-based command such as [`docker buildx build`](https://docs.docker.com/reference/cli/docker/buildx/build/) or [`docker buildx bake`](https://docs.docker.com/reference/cli/docker/buildx/bake/) also results in the Docker image being built on the Buildkite hosted agent.

For example, with `docker buildx build`:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally"
    command: |
      docker buildx use default
      docker buildx build -t my-image:latest .
```

The `my-image:latest` image will also be built on the Buildkite hosted agent.

This also applies to [`docker buildx bake`](https://docs.docker.com/reference/cli/docker/buildx/bake/), which uses the active Buildx builder in the same way:

```yaml
steps:
  - label: "\:docker\: Build with bake locally"
    command: |
      docker buildx use default
      docker buildx bake --file docker-bake.hcl
```

Alternatively, you can set the `BUILDX_BUILDER` environment variable to `default` for the step, which avoids the need to call `docker buildx use`:

```yaml
steps:
  - label: "\:docker\: Build with bake locally"
    env:
      BUILDX_BUILDER: "default"
    command: |
      docker buildx bake --file docker-bake.hcl
```

## Additional volumes

If your Buildkite organization doesn't have access to the [remote Docker builders](#remote-docker-builders-overview) feature, then new [volumes](/docs/agent/buildkite-hosted/cache-volumes) will appear in your [cluster](/docs/pipelines/security/clusters)'s volumes list—one for each unique Git repository used by a pipeline. The naming convention for these volumes is based on your cloud-based Git service's account and repository name, and begins with "buildkite-local-builder-". For example, **buildkite-local-builder-my-account-my-repository**.

You can view all of your current cluster's volumes through its **Cached Storage > Volumes** page.
