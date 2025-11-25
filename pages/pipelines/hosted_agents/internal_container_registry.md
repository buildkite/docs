# Internal container registry

The _internal container registry_ is a feature of [Buildkite hosted agents](/docs/pipelines/hosted-agents), which allows you to house Docker images built by your pipelines.

## Internal container registry overview

Once a [Buildkite cluster has been set up](/docs/pipelines/clusters/manage-clusters#setting-up-clusters), and its first [hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue) has been created, an internal container registry is created for this cluster, which you can use to manage [Open Container Initiative (OCI)](https://opencontainers.org/) images built by your pipelines on Buildkite hosted agents.

To use the internal container registry, you'll need to reference the pre-defined environment variable `$BUILDKITE_HOSTED_REGISTRY_URL` for the registry in Docker commands you use in your pipelines. The value of this environment variable defines the location for your cluster's internal container registry.

The main advantage of using your internal container registry over [cache volumes](/docs/pipelines/hosted-agents/cache-volumes) is that unlike cache volumes, the internal cache volume's storage is _deterministic_, which means that any commands you use in your pipelines to interact with this registry will interact directly with the relevant data stored in this registry. This is in contrast to the [non-deterministic nature of cache volumes](/docs/pipelines/hosted-agents/cache-volumes#lifecycle-non-deterministic-nature), where commands to retrieve data from your cache volume may instead retrieve it from a different source.

You can use built-in tools in your Buildkite hosted agents, such as [Docker Engine](https://docs.docker.com/engine/), as well as those you can include in an [agent image](/docs/pipelines/hosted-agents/linux#agent-images) through a Dockerfile for Linux hosted agents, such as [Crane](https://michaelsauter.github.io/crane/index.html) or [skopeo](https://github.com/containers/skopeo), or to interact with your internal container registry.

## Using your internal container registry

The following example pipeline demonstrates how build and push a custom Docker image (customized using a `.buildkite/Dockerfile.build` file) to your internal container registry. Once the built image has been pushed up to this registry, the pipeline then uses this image as the base image for its next step, [parallelized](/docs/pipelines/best-practices/parallel-builds#parallel-jobs) into three jobs.

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
    # Use the agent image specified in the queue settings for this step
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

  - key: use_custom_base_image
    label: ":package: Use custom base image"
    parallelism: 3
    depends_on: create_custom_base_image
    command: |
      echo "Using ${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest built from Build #$(cat /build-number-marker)"
```
{: codeblock-file=".buildkite/pipeline.yml"}
