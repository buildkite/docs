# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> The remote Docker builders feature is available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and becomes automatically available to existing customers who upgrade to this plan, as well as all new Buildkite customers who sign up to the Enterprise plan.

## Remote Docker builders overview

When using the remote Docker builders feature, any `docker build` commands within your pipeline are directed to and run on an external [builder service](https://docs.docker.com/build/builders/) (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build configuration to the remote builder service, the service itself builds the images and returns the completed images and metadata to the agent. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

Remote Docker builders can maintain a [cache of image layers](https://docs.docker.com/build/cache/) (in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache)), from which the resulting images are streamed back to the Buildkite hosted agents making the request, which in turn, speeds up your overall pipeline builds, since these agents are free to build the rest of your pipeline and conduct other work. Docker images streamed back from your container cache volume in this manner do not need to be re-built or downloaded to the agent.

When using remote Docker builders, the first few builds of a pipeline may require between 2-4 minutes to complete. However, once subsequent pipeline builds can receive their Docker images, streamed back from your container cache volume, these builds can be completed within 5-10 seconds, although often under 5 seconds. Learn more about how remote Docker builders improve the speed and performance of your of your pipeline builds in [Benefits of using remote Docker builders](#benefits-of-using-remote-docker-builders).

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

Using remote Docker builders and your container cache volume also complements Git mirrors.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

The remote Docker builders are dedicated machines with their own local file system that temporarily stores their image layers for 30 minutes from each build. Therefore, during periods of time when frequent image builds occur, the availability of stored relevant image layers on this file system improves the reuse of these layers, leading to a greater environmental consistency.
