# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> The remote Docker builders feature is available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and becomes automatically available to existing customers who upgrade to this plan, as well as all new Buildkite customers who sign up to the Enterprise plan.

## Remote Docker builders overview

When using the remote Docker builders feature, any `docker build` commands within your pipeline are directed to and run on an external [builder service](https://docs.docker.com/build/builders/) (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build configuration to this remote builder service, the builder service itself builds the images and returns the completed images and metadata to the job that made the `docker build` call on your agent. These completed images are also stored in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache), if you've enabled this feature. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

The remote builder service also maintains a [cache](https://docs.docker.com/build/cache/) of its built image layers (stored in the builder service's local file system, and in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache)). Images already stored in this local file system usually don't need to be re-built upon a `docker build` call, and any images in your container cache volume can be pulled to jobs requesting them, which in turn, speeds up your overall pipeline builds, since your Buildkite hosted agents running these pipelines are free to build the rest of your pipeline and conduct other work.

When using remote Docker builders, your first few pipeline builds will typically require more time to complete. However, once the required layers and their images have been built, any subsequent pipeline builds are completed much more rapidly. Learn more about how remote Docker builders improve the speed and performance of your of your pipeline builds in [Benefits of using remote Docker builders](#benefits-of-using-remote-docker-builders).

> 📘 Default feature
> Remote Docker builders is a _default feature_ of the Enterprise plan, which means that this feature is used automatically whenever native `docker build` commands are encountered within Buildkite pipelines. However, you can disable this feature, so that Docker images are built on the Buildkite hosted agents themselves. Learn more about how to do this in [Building Docker images on the Buildkite hosted agent](#building-docker-images-on-the-buildkite-hosted-agent).

## Step-by-step remote Docker builder process

The following steps outlines this remote Docker builder process in more detail:

1. A Buildkite hosted agent encounters a `docker build` command in one of its pipeline jobs, and then the agent generates a [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) configuration to target the remote [builder](https://docs.docker.com/build/builders/) service, which uses [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Learn more about Buildx and BuildKit in [Docker Build overview](https://docs.docker.com/build/concepts/overview/).

1. The remote builder service executes stages in parallel where possible, reusing unchanged image layers in your container cache volume and rebuilding images from only new layers that are needed.

1. The build outputs from `docker build` are delivered based on flags used on its command, for example, loaded back to the agent with no additional flags, or pushed to a registry or exported to an OCI archive with `--push`.

## Benefits of using remote Docker builders

This section provides more details about the benefits provided by remote Docker builders.

### Faster builds

Remote Docker builders run on remote dedicated machines, which have been optimized for [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Therefore, CPU-bound stages are completed much more rapidly.

Your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache) is both shared and persistent, ensuring your job will start and run as quickly as possible. Incremental builds also reliably skip unchanged image layers as they're kept on the dedicated remote Docker builder's local file system, often yielding 2-40 times build speed increases.

Using remote Docker builders with the container cache volume alongside Git mirrors can provide drastic reductions in job runtimes.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

The remote Docker builders are dedicated machines with their own local file system that temporarily stores their image layers for 30 minutes from each build. Therefore, during periods of time when frequent image builds occur, the availability of stored relevant image layers on this file system improves the reuse of these layers, leading to a greater environmental consistency.

## Building Docker images on the Buildkite hosted agent

Since [remote Docker builders](#remote-docker-builders-overview) is a [default feature](#default-feature), when using the `docker build` command in your Buildkite pipelines, you can configure this command to build Docker images on the Buildkite hosted agent itself, by either [disabling BuildKit](#building-docker-images-on-the-buildkite-hosted-agent-disable-buildkit) or [using Buildx and its default local builder](#building-docker-images-on-the-buildkite-hosted-agent-using-buildx-and-its-default-local-builder).

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

### Using Buildx and its default local builder

Using Buildx and its default local builder (with the [`docker buildx use` command](https://docs.docker.com/reference/cli/docker/buildx/use/)) and then the [`docker buildx build` command](https://docs.docker.com/reference/cli/docker/buildx/build/), results in the Docker image being built on the Buildkite hosted agent, using the agent's local Docker builder.

For example:

```yaml
steps:
  - label: "\:docker\: Build Docker image locally"
    command: |
      docker buildx use default
      docker buildx build -t my-image:latest .
```

The `my-image:latest` image will also be built on the Buildkite hosted agent.
