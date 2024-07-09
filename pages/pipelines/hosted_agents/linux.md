# Linux hosted agents

Linux instances for Buildkite hosted agents are offered with two architectures:

- AMD64 (x64_86)
- ARM64 (AArch64)

To accommodate different workloads, instances are capable of running up to 8 hours. If you require longer running agents please contact support.

## Size

Buildkite offers a selection of instance sizes, allowing you to tailor your hosted agents' resources to the demands of your jobs. Below is a breakdown of the available sizes.

<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>2</td><td>4 GB</td></tr>
        <tr><td>Medium</td><td>4</td><td>16 GB</td></tr>
        <tr><td>Large</td><td>8</td><td>32 GB</td></tr>
    </tbody>
</table>

## Image configuration

To configure your Linux instance you can use the [Docker Compose](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) plugin.

## Cache volumes

_Cache volumes_ are external volumes attached to hosted agent instances. These volumes are attached on a best-effort basis depending on their locality, expiration and current usage, and therefore, should not be relied upon as durable data storage.

By default, cache volumes:

- Are disabled, although you can enable them by providing a list of paths to cache at the pipeline- or step-level.
- Are scoped to a pipeline and are shared between all steps in the pipeline.

Cache volumes act as regular disks with the following properties:

- The volumes use NVMe storage, delivering high performance.
- The volumes are formatted as a regular Linux filesystem (e.g. ext4)—therefore, these volumes support any Linux use-cases.

### Cache configuration

Cache paths can be [defined in your `pipeline.yml`](/docs/pipelines/defining-steps) file. Defining cache paths for a step will implicitly create a cache volume for the pipeline.

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

Required attributes:

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

Optional attributes:

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
      The size of the cache volume. The default size is 20 gigabytes. Units are in gigabytes, specified as <code>Ng</code>, where <code>N</code> is the size in gigabytes, and <code>g</code> indicates gigabytes.<br>
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

The Git mirror cache is a special type of cache volume that is used to speed up Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

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

### Creating an agent image

To create an agent image, you need to create a Dockerfile that installs the tools and utilities you require. The Dockerfile should be based on the [Buildkite hosted agent base image](https://hub.docker.com/r/buildkite/hosted-agent-base/tags).

Here is an example Dockerfile that installs the `awscli` and `kubectl`:

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

You can create an agent image in the Buildkite UI by navigating to the `Agent Images` page in a `Cluster`. You must have created a Linux queue. Click on the `Create Image` button and provide the Dockerfile and a name for the agent image.

<%= image "hosted-agents-create-image.png", width: 1760, height: 436, alt: "Hosted agents create image form displayed in the Buildkite UI" %>

### Using an agent image

Once you have created an Agent Image, you can set it as the default image for a queue. Hosted agents in that queue will use the agent image you have created in new jobs.

From the Queues page within a Cluster, select a queue, navigate to the `Base Image` tab and select the agent image you want to use from the dropdown. Click on the `Save settings` button to update the queue image.

<%= image "hosted-agents-queue-image.png", width: 1760, height: 436, alt: "Hosted agents queue image setting displayed in the Buildkite UI" %>

### Deleting an agent image

You can delete an agent image by navigating to the `Agent Images` page in a `Cluster`. Select the agent image, then click on the `Delete` button.

<%= image "hosted-agents-delete-image.png", width: 1760, height: 436, alt: "Hosted agents delete image form displayed in the Buildkite UI" %>

Note that Agent Images cannot be deleted if they are in use by any queue. Please reset the queue to the default image before deleting the agent image.
