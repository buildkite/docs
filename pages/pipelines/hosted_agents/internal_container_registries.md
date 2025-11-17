# Internal container registries

_Internal container registries_ is a feature of [Buildkite hosted agents](/docs/pipelines/hosted-agents), which allows you to house Docker images built by your pipelines.

## Internal container registries overview

Once a [Buildkite cluster has been set up](/docs/pipelines/clusters/manage-clusters#setting-up-clusters), and its first [hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) has been started, an internal container registry is created for this cluster, which you can use to manage Open Container Initiative (OCI) images built by your pipelines on Buildkite hosted agents.

To use the internal container registry, you'll need to reference the pre-defined environment variable `$BUILDKITE_HOSTED_REGISTRY_URL` for the registry in Docker commands you use in your pipelines. The value of this environment variable defines the location for your cluster's internal container registry.

The main advantage of using your internal container registry over [cache volumes](/docs/pipelines/hosted-agents/cache-volumes) is that unlike cache volumes, the internal cache volume's storage is _deterministic_, which means that any commands you use in your pipelines to interact with this registry will interact directly with the relevant data stored in this registry. This is in contrast to the [non-deterministic nature of cache volumes](/docs/pipelines/hosted-agents/cache-volumes#lifecycle-non-deterministic-nature), where commands to retrieve data from your cache volume may instead retrieve it from a different source.

You can use built-in tools to your Buildkite hosted agents, such as [Docker Engine](https://docs.docker.com/engine/), as well as those you can add as an [agent image](/docs/pipelines/hosted-agents/linux#agent-images) through a Dockerfile for Linux hosted agents, such as ..., to interact with your internal container registry.

## Using your internal container registry

This section provides Docker Engine-based examples on how to upload and retrieve container images from your internal container registry.

### Building and uploading a container image

The following example pipeline demonstrates how build and push a custom Docker image (customized using a `.buildkite/Dockerfile.build` file) to your internal container registry.

```yaml
# Use the latest custom built image from the internal registry
# for all steps which don't specify an alternative image
image: "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest"

agents:
  # Must run on a hosted queue
  queue: "linux-small"

steps:
  - key: create_custom_base_image
    label: "\:docker\: Create custom base image"
    # Optionally only build on main branch
    # if: build.branch == "main"
    if_changed:
      - ".buildkite/Dockerfile.build"
      - ".buildkite/pipeline.yml"
    # Use the image specified in the queue settings for this step
    image: ~
    # Build and push a new image to the internal registry
    # Optionally add --no-cache to rebuild from scratch
    # without using cached layers
    command: |
      docker buildx build \
        --file .buildkite/Dockerfile.build \
        --build-arg BUILDKITE_BUILD_NUMBER="$$BUILDKITE_BUILD_NUMBER" \
        --platform linux/amd64 \
        --tag "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest" \
        --progress plain \
        --push .
```
{: codeblock-file=".buildkite/pipeline.yml"}

### Retrieving a container image

The following example pipeline demonstrates how pull a Docker image that you'd [previously customized](#using-your-internal-container-registry-building-and-uploading-a-container-image) to your internal container registry.

```yaml
# Use the latest custom built image from the internal registry
# for all steps which don't specify an alternative image
image: "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest"

agents:
  # Must run on a hosted queue
  queue: "linux-small"

steps:
  - key: pull_custom_base_image
    label: "\:docker\: Pull custom base image"
    # Optionally only build on main branch
    # if: build.branch == "main"
    # Use the image specified in the queue settings for this step
    image: ~
    # Pull the previously pushed custom container image from the
    # internal container registry
    command: |
      docker pull \
        --platform linux/amd64 \
        --tag "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest" \
```
{: codeblock-file=".buildkite/pipeline.yml"}
