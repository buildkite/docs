# Custom agent images

Custom agent images let you control which packages, tools, and security patches run in your [Linux hosted agent](/docs/agent/buildkite-hosted/linux) environment. A custom agent image is recommended for production workloads.

In Buildkite Pipelines, you can build and push custom images to your cluster's [internal container registry](/docs/agent/buildkite-hosted/internal-container-registry), then use the `image` attribute in your pipeline YAML to run jobs with those images.

## Create an agent image

Define a Dockerfile with the tools your jobs need, then add a pipeline step to build and push the image. A later step can use that image by setting its `image` attribute.

1. Create a `.buildkite/Dockerfile.build` file in your repository. The following example installs the [required tools](#requirements-within-the-image) and `make`:

    ```dockerfile
    FROM ubuntu:24.04

    RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        git \
        make \
        && rm -rf /var/lib/apt/lists/*
    ```
    {: codeblock-file=".buildkite/Dockerfile.build"}

1. Add the following steps to your pipeline. Replace `linux-small` with your Linux AMD64 hosted queue's key. Buildkite hosted agents set `BUILDKITE_HOSTED_REGISTRY_URL` to the URL of the current cluster's internal container registry.

    ```yaml
    agents:
      queue: "linux-small"

    steps:
      - key: create_custom_base_image
        label: "Build custom agent image"
        command: |
          docker buildx build \
            --file .buildkite/Dockerfile.build \
            --platform linux/amd64 \
            --tag "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest" \
            --progress plain \
            --push .

      - key: use_custom_base_image
        label: "Use custom agent image"
        image: "${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest"
        parallelism: 3
        depends_on: create_custom_base_image
        command: |
          echo "Using ${BUILDKITE_HOSTED_REGISTRY_URL}/base:latest"
    ```
    {: codeblock-file=".buildkite/pipeline.yml"}

    The first step builds and pushes the image using the queue's default agent image. The second step waits for the image to be pushed, then uses it to run three [parallel jobs](/docs/pipelines/best-practices/parallel-builds#parallel-jobs).

Build the image for the architecture of the queue that will run it. For a Linux ARM64 hosted queue, change `--platform linux/amd64` to `--platform linux/arm64` and set `queue` to that queue's key. Keep the build and consuming steps in the same [cluster](/docs/pipelines/security/clusters). Each internal container registry belongs to a single cluster.

### Using agent hooks

You can embed [job lifecycle hooks](/docs/agent/hooks#job-lifecycle-hooks) in your custom agent image. Supported hooks are `environment`, `pre-checkout`, `checkout`, `post-checkout`, `pre-command`, `command`, `post-command`, `pre-artifact`, `post-artifact`, and `pre-exit`. The `pre-bootstrap` hook and [agent lifecycle hooks](/docs/agent/hooks#agent-lifecycle-hooks) are not supported on Buildkite hosted agents.

Set `BUILDKITE_ADDITIONAL_HOOKS_PATHS` in your Dockerfile and copy your hooks into that directory:

```dockerfile
ENV BUILDKITE_ADDITIONAL_HOOKS_PATHS=/custom/hooks
COPY ./hooks/*.sh /custom/hooks/
```

This example copies `.sh` files from your repository's `hooks` directory into `/custom/hooks` in the image. Build and push the updated image, then use it in your pipeline.

> 📘 Hook directory
> Buildkite hosted agents use `/buildkite/agent/hooks` as the global hooks location. This path is fixed and read-only when a job starts. Do not set `BUILDKITE_ADDITIONAL_HOOKS_PATHS` to this path, because files copied there are overwritten when the job starts.

## Use an agent image

Use the `image` attribute to select a custom image for an entire pipeline or an individual command step. The image must be publicly available or stored in your cluster's internal container registry.

### Specify an image in your pipeline YAML

In Buildkite Pipelines, use the `image` attribute at the pipeline root or directly on a command step, alongside the `command` attribute. Do not put the `image` attribute under the `agents` attribute, which configures [agent query rules](/docs/agent/cli/reference/start#agent-targeting) such as the queue to use.

The value must be a container image reference, such as `registry.example.com/image-name:tag`.

The following examples assume you have already pushed the referenced images to your internal container registry and installed the [required tools](#requirements-within-the-image) in them.

To set a default image for all steps in a pipeline, add the `image` attribute at the pipeline root, alongside the `agents` and `steps` attributes. This overrides the queue's default image:

```yaml
image: "${BUILDKITE_HOSTED_REGISTRY_URL}/build:latest"

agents:
  queue: "hosted-linux"

steps:
  - label: "Build"
    command: "make build"
```
{: codeblock-file="pipeline.yml"}

To override the pipeline's default image for an individual step, add the `image` attribute directly to that step. Steps without an `image` attribute use the pipeline's default image, or the queue's default image if the pipeline does not define a default:

```yaml
image: "${BUILDKITE_HOSTED_REGISTRY_URL}/build:latest"

agents:
  queue: "hosted-linux"

steps:
  # Uses the pipeline's default image
  - label: "Build"
    command: "make build"

  # Overrides the pipeline's default image for this step
  - label: "Run integration tests"
    command: "make integration-test"
    image: "${BUILDKITE_HOSTED_REGISTRY_URL}/integration-test:latest"

  # Uses the pipeline's default image
  - label: "Deploy"
    command: "make deploy"
```
{: codeblock-file="pipeline.yml"}

## Requirements within the image

Buildkite Linux hosted agents supply the `buildkite-agent` and `docker` binaries when a job runs. You do not need to install or maintain these binaries or their configurations in your custom image.

Install the following tools in every custom agent image:

- `git`
- `ca-certificates`
- `bash`

Make Bash available as an executable within the image. You can use any Linux distribution that provides these tools. The image's architecture must match the queue that runs the job.

> 📘 Image user
> Buildkite Linux hosted agents do not support changing `USER` within the Dockerfile or setting the `GID` and `UID` environment variables.

## Issues with starting a job

If a job does not start successfully, check the following:

- The image reference and tag exist in the registry. If a pipeline builds the image, use `depends_on` to ensure the consuming step waits for the build and push to finish.
- Images in an internal container registry are only available within that registry's cluster. Build and use the image in the same cluster.
- The image's architecture matches the queue's architecture.
- The required tools are installed. Without `ca-certificates`, the agent cannot communicate with the Buildkite platform.
- A public registry may rate-limit image downloads. Mirror the image in your internal container registry to avoid this issue.
