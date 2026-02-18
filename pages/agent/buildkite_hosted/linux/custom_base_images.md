# Custom base images

Creating a custom agent image requires you to define a Dockerfile that installs the tools and utilities you require. You can [create a custom base image](#create-an-agent-image) using the [Buildkite interface](#create-an-agent-image-using-the-buildkite-interface), [agent hooks](#create-an-agent-image-using-agent-hooks) or the [internal container registry](/docs/pipelines/hosted-agents/internal-container-registry).

## Requirements within the image

Buildkite Linux hosted agents have the `buildkite-agent` and `docker` binaries layered dynamically into the job running environment. This means that any base image being used does not need to install or maintain these versions or their configurations. Several tools are required for the `buildkite-agent` to successfully acquire and run a job. These are:

- `git`
- `ca-certificates`
- `bash`

There is also no requirement into which Linux flavor this image is based on. The default Buildkite Linux hosted agents image is based on Ubuntu, with other Linux flavors such as Alpine or CentOS being perfectly acceptable.

> 📘
> Buildkite Linux hosted agents do not support changing the `USER` within the `Dockerfile`, nor setting the `GID` and `UID` environment variables.

## Create an agent image

Creating an agent image requires you to define a Dockerfile that installs the tools and utilities you require. This Dockerfile should be based on the [Buildkite hosted agent base image](https://hub.docker.com/r/buildkite/hosted-agent-base/tags).

An example Dockerfile that installs the `awscli` and `kubectl`:

```dockerfile
# Set the environment variable to avoid interactive prompts during awscli installation
ENV DEBIAN_FRONTEND=noninteractive

# Install AWS CLI
RUN apt-get update && apt-get install -y awscli

# Install kubectl using pkgs.k8s.io
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/
```

### Using the Buildkite interface

To create an agent image using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to create the new agent image.

    **Note:** Before continuing, ensure you have created a Buildkite hosted queue (based on Linux architecture) within this cluster. Learn more about how to do this in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).

1. Select **Agent Images** to open the **Agent Images** page.
1. Select **New Image** to open the **New Agent Image** dialog.
1. Enter the **Name** for your agent image.
1. In the **Dockerfile** field, enter the contents of your Dockerfile.

    **Notes:**
    * The top of the Dockerfile contains the required `FROM` instruction, which cannot be changed. This instruction obtains the required Buildkite hosted agent base image.
    * Ensure any modifications you make to the existing Dockerfile content are correct before creating the agent image, since mistakes cannot be edited or corrected once the agent image is created.

1. Select **Create Agent Image** to create your new agent image.

<%= image "hosted-agents-create-image.png", width: 1516, height: 478, alt: "Buildkite hosted agents create image form displayed in the Buildkite interface" %>

### Using agent hooks

You can [create a custom agent image](#create-an-agent-image) and modify its Dockerfile to embed the following types of [job lifecycle hooks](/docs/agent/hooks#job-lifecycle-hooks) as [agent hooks](/docs/agent/hooks#hook-locations-agent-hooks):

`environment`, `pre-checkout`, `checkout`, `post-checkout`, `pre-command`, `command`, `post-command`, `pre-artifact`, `post-artifact`, and `pre-exit`.

Be aware that the `pre-bootstrap` job lifecycle hook and [agent lifecycle hooks](/docs/agent/hooks#agent-lifecycle-hooks) operate outside of a job's execution itself, and are therefore not supported within a Buildkite hosted agent context.

To embed hooks in your agent image's Dockerfile:

1. Follow the [Create an agent image](#create-an-agent-image) instructions to begin creating your hosted agent within its Linux architecture-based Buildkite hosted queue.

    As part of this process, modify the agent image's Dockerfile to:
    1. Add the `BUILDKITE_ADDITIONAL_HOOKS_PATHS` environment variable whose value is the path to where the hooks will be located.
    1. Add any specific hooks to the path defined by this variable.

    An example excerpt from a `Dockerfile` that would include your own hooks:

    ```Dockerfile
    ENV BUILDKITE_ADDITIONAL_HOOKS_PATHS=/custom/hooks
    COPY ./hooks/*.sh /custom/hooks/
    ```

    This results in an agent image with the directory `/custom/hooks` that includes any `.sh` files located at `./hooks/` from where the image is created.

1. Follow the [Use an agent image](#use-an-agent-image) instructions to apply this new agent image to your Buildkite hosted queue.

> 📘
> Buildkite hosted agents run with the `BUILDKITE_HOOKS_PATH` value of `/buildkite/agent/hooks`, which is the global agent hooks location. This path is fixed and is read-only when a job starts. Therefore, avoid setting the value of `BUILDKITE_ADDITIONAL_HOOKS_PATHS` to this path in your agent image's Dockerfile, as any files you copy across to this location will be overwritten when the job commences.

## Use an agent image

Once you have [created an agent image](#create-an-agent-image), you can use it by doing either of the following:

- [Setting it as the default image for a queue](#use-an-agent-image-set-a-default-image-for-a-queue) in the Buildkite interface.
- [Specifying the image in your pipeline YAML](#use-an-agent-image-specify-an-image-in-your-pipeline-yaml), which allows different steps to use different images within the same queue.

### Set a default image for a queue

You can set an agent image as the default for a [Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) based on Linux architecture. Any agents in the queue will use this image in new jobs, unless overridden in the pipeline YAML.

To set a Buildkite hosted queue to use a custom Linux agent image:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the Linux architecture-based Buildkite hosted queue whose agent image requires configuring.
1. On the **Queues** page, select the Buildkite hosted queue based on Linux architecture.
1. Select the **Base Image** tab to open its settings.
1. In the **Agent image** dropdown, select your agent image.
1. Select **Save settings** to save this update.

<%= image "hosted-agents-queue-image.png", width: 1760, height: 436, alt: "Buildkite hosted agents queue image setting displayed in the Buildkite interface" %>

### Specify an image in your pipeline YAML

You can specify an agent image directly in your pipeline YAML using the `image` attribute under `agents`. The image name must match the name of an [agent image you have created](#create-an-agent-image) in the cluster.

To set a default image for all steps in a pipeline, add the `image` attribute at the root level:

```yaml
agents:
  queue: "hosted-linux"
  image: "DevOps Agent Image"

steps:
  - label: "Build"
    command: "make build"
```
{: codeblock-file="pipeline.yml"}

You can also override the image for individual steps, allowing different steps to use different images within the same queue:

```yaml
agents:
  queue: "hosted-linux"
  image: "DevOps Agent Image"

steps:
  # Uses "DevOps Agent Image" from root-level agents
  - label: "Build"
    command: "make build"

  # Overrides root-level image
  - label: "Run integration tests"
    command: "make integration-test"
    agents:
      image: "Default Agent Image"

  # Uses "DevOps Agent Image" from root-level agents
  - label: "Deploy"
    command: "make deploy"
```
{: codeblock-file="pipeline.yml"}

## Issues with starting a job

There are several scenarios where a job may not start successfully, and various reasons why this might happen. The following is a non-exhaustive list of common reasons why jobs may not be starting:

- The specified base image configured on the Buildkite hosted queue cannot be found. This could be due to the full URL or a specific tag for that image not being available - in particular, note that images are bound to a single cluster, and can't be used by agents in other clusters. It's also possible that this could be a timing issue, where the tag being requested is not available _yet_ and waiting may be sufficient.
- When the image is a publicly available one, especially when using a registry other than [Docker Hub](https://hub.docker.com/), Buildkite may be rate-limited when attempting to retrieve it. It is highly recommended using the [internal container registry](/docs/agent/buildkite-hosted/internal-container-registry) to mirror the image and avoid this issue.
- The [required packages](#requirements-within-the-image) have not been installed within the image. This is especially the case for `ca-certificates`, as this package will prevent the `buildkite-agent` from being able to communicate with the Buildkite platform.

## Delete an agent image

To delete a [previously created agent image](#create-an-agent-image), it must not be [used by any Buildkite hosted queues](#use-an-agent-image).

To delete an agent image:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to delete the agent image.
1. Select **Agent Images** to open the **Agent Images** page.
1. Select the agent image to delete > **Delete**.

    **Note:** If you are prompted that the agent image is currently in use, follow the link/s to each Buildkite hosted queue on the **Delete Image** message to change the queue's **Agent image** (from the **Base Image** tab) to another agent image.

1. On the **Delete Image** message, select **Delete Image** and the agent image is deleted.

<%= image "hosted-agents-delete-image.png", width: 1760, height: 436, alt: "Buildkite hosted agents delete image form displayed in the Buildkite interface" %>
