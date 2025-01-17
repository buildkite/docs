# Linux hosted agents

Linux instances for Buildkite hosted agents are offered with two architectures:

- AMD64 (x64_86)
- ARM64 (AArch64)

To accommodate different workloads, instances are capable of running up to 8 hours. If you require longer running agents, please contact support at support@buildkite.com.

## Sizes

Buildkite offers a selection of Linux instance types (each based on a different combination of size and architecture, known as an _instance shape_), allowing you to tailor your hosted agent resources to the demands of your jobs.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

Extra large instances are available on request. Please contact support@buildkite.com to have them enabled for your account.

## Cache volumes

_Cache volumes_ are external volumes attached to hosted agent instances. These volumes are attached on a best-effort basis depending on their locality, expiration and current usage, and therefore, should not be relied upon as durable data storage.

By default, cache volumes:

- Are disabled, although you can enable them by providing a list of paths to cache at the pipeline- or step-level.
- Are scoped to a pipeline and are shared between all steps in the pipeline.

Cache volumes act as regular disks with the following properties:

- The volumes use NVMe storage, delivering high performance.
- The volumes are formatted as a regular Linux filesystem (e.g. ext4)—therefore, these volumes support any Linux use-cases.

### Cache configuration

Cache paths can be [defined in your `pipeline.yml`](/docs/pipelines/configure/defining-steps) file. Defining cache paths for a step will implicitly create a cache volume for the pipeline.

When cache paths are defined, the cache volume is mounted under `/cache` in the agent instance. The agent links subdirectories of the cache volume into the paths specified in the configuration. For example, defining `cache: "node_modules"` in your `pipeline.yml` file will link `./node_modules` to `/cache/bkcache/node_modules` in your agent instance.

Custom caches can be created by specifying a name for the cache, which allows you to use multiple cache volumes in a single pipeline.

When requesting a cache volume, you can specify a size. The cache volume provided will have a minimum available storage equal to the specified size. In the case of a cache hit (most of the time), the actual volume size is: last used volume size + the specified size.

Defining a top-level cache configuration (as opposed to one within a step) sets the default cache volume for all steps in the pipeline. Steps can override the top-level configuration by defining their own cache configuration.

```yaml
cache:
  paths:
    - "node_modules"
  size: "100g"

steps:
  - command: "yarn run build"
    cache: ".build"

  - command: "yarn run test"
    cache:
      - ".build"

  - command: "rspec"
    cache:
      paths:
        - "vendor/bundle"
      size: 20g
      name: "bundle-cache"
```
{: codeblock-file="pipeline.yml"}

#### Required attributes

<table data-attributes data-attributes-required>
  <tr>
    <td><code>paths</code></td>
    <td>
      A list of paths to cache. Paths are relative to the working directory of the step.<br>
      Absolute references can be provided in the cache paths configuration relative to the root of the instance.<br>
      <em>Example:</em><br>
      <code>- ".cache"</code><br>
      <code>- "/tmp/cache"</code><br>
    </td>
  </tr>
</table>

#### Optional attributes

<table data-attributes data-attributes-required>
  <tr>
    <td><code>name</code></td>
    <td>
      A name for the cache. This allows for multiple cache volumes to be used in a single pipeline.<br>
      <em>Example:</em> <code>"node-modules-cache"</code><br>
    </td>
  </tr>

  <tr>
    <td><code>size</code></td>
    <td>
      The size of the cache volume. The default size is 20 gigabytes, which is also the minimum cache size that can be requested.<br/>Units are in gigabytes, specified as <code>Ng</code>, where <code>N</code> is the size in gigabytes, and <code>g</code> indicates gigabytes.<br>
      <em>Example:</em> <code>"20g"</code><br>
    </td>
  </tr>
</table>

### Lifecycle

At any point in time, multiple versions of a cache volume may be used by different jobs.

The first request creates the first version of the cache volume, which is used as the parent of subsequent _forks_ until a new parent version is committed. A _fork_ in this context is a "moment", or a readable/writable "snapshot", version of the cache volume in time.

When requesting a cache volume, a fork of the previous cache volume version is attached to the agent instance. This is the case for all cache volumes, except for the first request, which starts empty, with no cache volumes attached.

Each job gets its own private copy of the cache volume, as it existed at the time of the last cache commit.

Version commits follow a "last write" model: whenever a job terminates successfully (that is, exits with exit code `0`), cache volumes attached to that job have a new parent committed: the final flushed volume of the exiting agent instance.

Whenever a job fails, the cache volume versions attached to the agent instance are abandoned.

### Billing model

Cache volumes are charged at an initial fixed cost _per pipeline build_ when a cache path (for example, `cache: "node_modules"`) is defined at least once in the pipeline's `pipeline.yml` file. This fixed cost is the same, regardless of the number of times a cache path is defined/used in the `pipeline.yml` file.

An additional (smaller) charge is made per gigabyte of _active cache_, where active cache is defined as any cache volume used in the last 24 hours.

### Git mirror cache

The Git mirror cache is a specialized type of cache volume designed to accelerate Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

Git mirror caching can be enabled on the cluster's cache volumes settings page. Once enabled, the Git mirror cache will be used for all hosted jobs in that cluster. A separate cache volume will be created for each repository.

<%= image "hosted-agents-git-mirror.png", width: 1760, height: 436, alt: "Hosted agents git mirror setting displayed in the Buildkite UI" %>

### Container cache

The container cache can be used to cache Docker images between builds.

Container caching can be enabled on the cluster's cache volumes settings page. Once enabled, a container cache will be used for all hosted jobs in that cluster. A separate cache volume will be created for each pipeline.

<%= image "hosted-agents-container-caching.png", width: 1760, height: 436, alt: "Hosted agents container cache setting displayed in the Buildkite UI" %>

## Agent images

Buildkite provides a Linux agent image pre-configured with common tools and utilities to help you get started quickly. This image also provides tools required for running jobs on hosted agents.

The image is based on Ubuntu 20.04 and includes the following tools:

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

You can [create a custom agent image](#agent-images-create-an-agent-image) and modify its Dockerfile to embed [agent hooks](/docs/agent/v3/hooks#hook-locations-agent-hooks).

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
