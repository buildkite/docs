# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> The remote Docker builders feature is available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and becomes automatically available to existing customers who upgrade to this plan, as well as all new Buildkite customers who sign up to the Enterprise plan.

## Remote Docker builders overview

When using the remote Docker builders feature, any `docker build` commands within your pipeline are directed to and run on an external [builder service](https://docs.docker.com/build/builders/) (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build configuration to this remote builder service, the builder service itself builds the images and returns the completed images and metadata to the job that made the `docker build` call on your agent. These completed images are also stored in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache), if you've enabled this feature. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

The remote builder service also maintains a [cache](https://docs.docker.com/build/cache/) of its built image layers (stored in the builder service's local file system, and in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache)). Images already stored in this local file system usually don't need to be re-built upon a `docker build` call, and any images in your container cache volume can be pulled to jobs requesting them, which in turn, speeds up your overall pipeline builds, since your Buildkite hosted agents running these pipelines are free to build the rest of your pipeline and conduct other work.

When using remote Docker builders, your first few pipeline builds will typically require more time to complete. However, once the required layers and their images have been built, any subsequent pipeline builds are completed much more rapidly. Learn more about how remote Docker builders improve the speed and performance of your of your pipeline builds in [Benefits of using remote Docker builders](#benefits-of-using-remote-docker-builders).

## Step-by-step remote Docker builder process

The following steps outlines this remote Docker builder process in more detail:

1. A Buildkite hosted agent encounters a `docker build` command in one of its pipeline jobs, and then the agent generates a [Buildx](https://docs.docker.com/build/concepts/overview/#buildx) configuration with cache settings to target the remote [builder](https://docs.docker.com/build/builders/) service, which uses [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Learn more about Buildx and BuildKit in [Docker Build overview](https://docs.docker.com/build/concepts/overview/).

1. The remote builder service executes stages in parallel where possible, reusing unchanged layers in your container cache volume and rebuilding images from only new layers that are needed.

1. The build outputs from `docker build` are delivered based on flags used on its command, for example, loaded back to the agent with no additional flags, or pushed to a registry or exported to an OCI archive with `--push`.

## Benefits of using remote Docker builders

This section provides more details about the benefits provided by remote Docker builders.

### Faster builds

Remote Docker builders run on remote dedicated machines, which have been optimized for [BuildKit](https://docs.docker.com/build/concepts/overview/#buildkit). Therefore, CPU-bound stages are completed much more rapidly.

Your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache) is both shared and persistent. Therefore, incremental builds reliably skip unchanged image layers, which often yields 2-40 times build speed increases.

Using remote Docker builders with the container cache volume alongside Git mirrors can provide drastic reductions in Job runtimes.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

The remote Docker builders are dedicated machines with their own local file system that temporarily stores their image layers for 30 minutes from each build. Therefore, during periods of time when frequent image builds occur, the availability of stored relevant image layers on this file system improves the reuse of these layers, leading to a greater environmental consistency.
