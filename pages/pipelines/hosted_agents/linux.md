# Linux hosted agents

A Buildkite Linux hosted agent is configured as part of a _Buildkite hosted queue_, where the Buildkite hosted agent's machine type is Linux, has a particular [size](#sizes) to efficiently manage jobs with varying requirements, and comes pre-installed with software in the form of [agent images](#agent-images), which can be [customized with other software](#agent-images-create-an-agent-image).

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/clusters).

- Configuring queues in general, in [Manage queues](/docs/pipelines/clusters/manage-queues).

- How to configure a Linux hosted agent in [Create a Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue).

## Sizes

Buildkite offers a selection of Linux instance types (each based on a different combination of size and architecture, known as an _instance shape_), allowing you to tailor your hosted agent resources to the demands of your jobs. The architectures supported include AMD64 (x64_86) and ARM64 (AArch64).

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

Note the following about Linux hosted agent instances.

- Extra large instances are available on request.

- To accommodate different workloads, instances are capable of running up to 8 hours.

If you need extra large instances, or longer running hosted agents (over 8 hours), please contact Support at support@buildkite.com.

### Concurrency



## Agent images

Buildkite provides a Linux agent image pre-configured with common tools and utilities to help you get started quickly. This image also provides tools required for running jobs on hosted agents.

The image is based on Ubuntu 22.04 and includes the following tools:

- docker
- docker-compose
- docker-buildx
- git-lfs
- node
- aws-cli

You can customize the image that your hosted agents use by creating an agent image.

### Create an agent image

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

You can create an agent image:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to create the new agent image.

    **Note:** Before continuing, ensure you have created a Buildkite hosted queue (based on Linux architecture) within this cluster. Learn more about how to do this in [Create a Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue).

1. Select **Agent Images** to open the **Agent Images** page.
1. Select **New Image** to open the **New Agent Image** dialog.
1. Enter the **Name** for your agent image.
1. In the **Dockerfile** field, enter the contents of your Dockerfile.

    **Notes:**
    * The top of the Dockerfile contains the required `FROM` instruction, which cannot be changed. This instruction obtains the required Buildkite hosted agent base image.
    * Ensure any modifications you make to the existing Dockerfile content are correct before creating the agent image, since mistakes cannot be edited or corrected once the agent image is created.

1. Select **Create Agent Image** to create your new agent image.

<%= image "hosted-agents-create-image.png", width: 1516, height: 478, alt: "Hosted agents create image form displayed in the Buildkite UI" %>

### Use an agent image

Once you have [created an agent image](#agent-images-create-an-agent-image), you can set it as the default image for any Buildkite hosted queues based on Linux architecture within this cluster. Once you do this for such a Buildkite hosted queue, any agents in the queue will use this agent image in new jobs.

To set a Buildkite hosted queue to use a custom Linux agent image:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the Linux architecture-based Buildkite hosted queue whose agent image requires configuring.
1. On the **Queues** page, select the Buildkite hosted queue based on Linux architecture.
1. Select the **Base Image** tab to open its settings.
1. In the **Agent image** dropdown, select your agent image.
1. Select **Save settings** to save this update.

<%= image "hosted-agents-queue-image.png", width: 1760, height: 436, alt: "Hosted agents queue image setting displayed in the Buildkite UI" %>

### Delete an agent image

To delete a [previously created agent image](#agent-images-create-an-agent-image), it must not be [used by any Buildkite hosted queues](#agent-images-use-an-agent-image).

To delete an agent image:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to delete the agent image.
1. Select **Agent Images** to open the **Agent Images** page.
1. Select the agent image to delete > **Delete**.

    **Note:** If you are prompted that the agent image is currently in use, follow the link/s to each Buildkite hosted queue on the **Delete Image** message to change the queue's **Agent image** (from the **Base Image** tab) to another agent image.

1. On the **Delete Image** message, select **Delete Image** and the agent image is deleted.

<%= image "hosted-agents-delete-image.png", width: 1760, height: 436, alt: "Hosted agents delete image form displayed in the Buildkite UI" %>

### Using agent hooks

You can [create a custom agent image](#agent-images-create-an-agent-image) and modify its Dockerfile to embed the following types of [job lifecycle hooks](/docs/agent/v3/hooks#job-lifecycle-hooks) as [agent hooks](/docs/agent/v3/hooks#hook-locations-agent-hooks):

`environment`, `pre-checkout`, `checkout`, `post-checkout`, `pre-command`, `command`, `post-command`, `pre-artifact`, `post-artifact`, and `pre-exit`.

Be aware that the `pre-bootstrap` job lifecycle hook and [agent lifecycle hooks](/docs/agent/v3/hooks#agent-lifecycle-hooks) operate outside of a job's execution itself, and are therefore not supported within a Buildkite hosted agent context.

To embed hooks in your agent image's Dockerfile:

1. Follow the [Create an agent image](#agent-images-create-an-agent-image) instructions to begin creating your hosted agent within its Linux architecture-based Buildkite hosted queue.

    As part of this process, modify the agent image's Dockerfile to:
    1. Add the `BUILDKITE_ADDITIONAL_HOOKS_PATHS` environment variable whose value is the path to where the hooks will be located.
    1. Add any specific hooks to the path defined by this variable.

    An example excerpt from a `Dockerfile` that would include your own hooks:

    ```Dockerfile
    ENV BUILDKITE_ADDITIONAL_HOOKS_PATHS=/custom/hooks
    COPY ./hooks/*.sh /custom/hooks/
    ```

    This results in an agent image with the directory `/custom/hooks` that includes any `.sh` files located at `./hooks/` from where the image is created.

1. Follow the [Use an agent image](#agent-images-use-an-agent-image) to apply this new agent image to your Buildkite hosted queue.

> 📘
> Buildkite hosted agents run with the `BUILDKITE_HOOKS_PATH` value of `/buildkite/agent/hooks`, which is the global agent hooks location. This path is fixed and is read-only when a job starts. Therefore, avoid setting the value of `BUILDKITE_ADDITIONAL_HOOKS_PATHS` to this path in your agent image's Dockerfile, as any files you copy across to this location will be overwritten when the job commences.
