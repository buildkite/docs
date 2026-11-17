# Internal container registry

The _internal container registry_ is a feature of [Buildkite hosted agents](/docs/agent/buildkite-hosted), which allows you to house Docker images built by your pipelines.

## Internal container registry overview

Once a [Buildkite cluster has been set up](/docs/pipelines/security/clusters/manage#setting-up-clusters), and its first [hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) has been created, an internal container registry is created for this cluster, which you can use to manage [Open Container Initiative (OCI)](https://opencontainers.org/) images built by your pipelines on Buildkite hosted agents.

To use the internal container registry, you'll need to reference the pre-defined environment variable `$BUILDKITE_HOSTED_REGISTRY_URL` for the registry in Docker commands you use in your pipelines. The value of this environment variable defines the location for your cluster's internal container registry.

The main advantage of using your internal container registry over [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) is that unlike cache volumes, the internal container registry's storage is _deterministic_, which means that any commands you use in your pipelines to interact with this registry will interact directly with the relevant data stored in this registry. This is in contrast to the [non-deterministic nature of cache volumes](/docs/agent/buildkite-hosted/cache-volumes#lifecycle-non-deterministic-nature), where commands to retrieve data from your cache volume may instead retrieve it from a different source.

You can use built-in tools in your Buildkite hosted agents, such as [Docker Engine](https://docs.docker.com/engine/), as well as those you can include in an [agent image](/docs/agent/buildkite-hosted/linux#agent-images) through a Dockerfile for Linux hosted agents, such as [Crane](https://michaelsauter.github.io/crane/index.html) or [skopeo](https://github.com/containers/skopeo) to interact with your internal container registry.

## Using your internal container registry

Build and push images from your pipeline with Docker, using `BUILDKITE_HOSTED_REGISTRY_URL` as the registry URL. Jobs on Buildkite hosted agents can access their cluster's internal container registry without logging in.

For a complete Dockerfile and pipeline example that builds, pushes, and runs jobs with a custom image, see [Create an agent image](/docs/agent/buildkite-hosted/linux/custom-agent-images#create-an-agent-image).

## Using your internal container registry as a Docker layer cache

Your internal container registry can also store a Docker layer cache, so that image builds that use Docker's `default` builder on your hosted agent instances reuse unchanged layers between jobs. Learn more in [Keep the layer cache](/docs/agent/buildkite-hosted/linux/remote-docker-builders#building-docker-images-on-the-buildkite-hosted-agent-keep-the-layer-cache).
