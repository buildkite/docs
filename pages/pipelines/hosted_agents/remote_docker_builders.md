# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> The remote Docker builders feature is available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and becomes automatically available to existing customers who upgrade to this plan, as well as all new Buildkite customers who sign up to the Enterprise plan.

## Remote Docker builders overview

When using the remote Docker builders feature, any `docker build` commands within your pipeline are directed to and run on an external [BuildKit](https://docs.docker.com/build/buildkit/) builder service (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates and streams the build context to the remote BuildKit service, the BuildKit service builds the images and returns the completed images and metadata to the agent. Learn more about this in [Step-by-step remote Docker builder process](#step-by-step-remote-docker-builder-process).

Remote Docker builders can maintain their own [cache of image layers](https://docs.docker.com/build/cache/) (in your [container cache volume](/docs/pipelines/hosted-agents/cache-volumes#container-cache)), from which the resulting images are streamed back to the Buildkite hosted agents making the request, which in turn, speeds up your overall pipeline builds, since these agents are free to build your pipeline and conduct other work. Docker images streamed back from your container cache volume in this manner do not need to be re-built or re-downloaded to the agent.

When using remote Docker builders, the first few builds of a pipeline might typically require between 2-4 minutes to complete. However, once subsequent builds are able to receive their Docker images, streamed back from your container cache volume, these subsequent builds are typically completed within 5-10 seconds.

## Step-by-step remote Docker builder process

The following steps outlines this remote Docker builder process in more detail:

1. A Buildkite hosted agent encounters a `docker build` command in one of its pipeline jobs, and then the agent runs [`docker buildx`](https://docs.docker.com/reference/cli/docker/buildx/) with cache settings to target the remote BuildKit service.
1. The remote BuildKit service executes stages in parallel where possible, reusing unchanged layers in your container cache volume and rebuilding images from only new layers that are needed.
1. The build outputs are delivered based on flags: pushed to a registry, exported to an OCI archive, or loaded back to the agent if requested.

## Benefits of using remote Docker builders

This section provides more details about the benefits provided by remote Docker builders.

### Faster builds

Remote Docker builders run on remote dedicated machines, which have been optimized for BuildKit. Therefore, CPU-bound stages are completed much more rapidly.

Your container cache volume is both shared and persistent. Therefore, incremental builds reliably skip unchanged image layers, which often yields two to 40 times build speed increases.

### Smaller agents with a simple setup

Using remote Docker builders means that you can maintain smaller Buildkite hosted agents with a simpler setup, since Docker images are built through the remote Docker builder.

### Improved cache hit rates and reproducibility

BuildKit's distributed cache handling and consistent environment improves the reuse of image layers, and complements Git mirrors.
