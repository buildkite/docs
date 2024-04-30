# Linux hosted agents

Linux instances for Buildkite hosted agents are offered with two architectures:

- ARM
- AMD64 (x64_86)

To accommodate different workloads, instances are capable of running up to 8 hours. If you require longer running agents please contact support.

## Size

Buildkite offers a selection of instance sizes, allowing you to tailor your hosted agents' resources to the demands of your jobs. Below is a breakdown of the available sizes.

<table>
    <thead>
        <tr><th>Size</th><th>vCPU</th><th>RAM</th></tr>
    </thead>
    <tbody>
        <tr><td>Small</td><td>2</td><td>4 GB</td></tr>
        <tr><td>Medium</td><td>4</td><td>8 GB</td></tr>
        <tr><td>Large</td><td>8</td><td>32 GB</td></tr>
    </tbody>
</table>

## Image configuration

To configure your Linux instance you can use the [Docker Compose](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) plugin.

## Cache volumes

Cache Volumes are external volumes attached to hosted agent instances. Cache Volumes are attached on a best-effort basis depending on their locality, expiration and current usage (so they should not be relied upon as durable data storage).

Cache volumes are disabled by default and can be enabled by providing a list of paths to cache at the pipeline level or the step level. Cache volumes are scoped to a pipeline and are shared between all steps in a pipeline by default.

Cache volumes act as regular disks with the following properties:

- They're backed by local NVMe storage. You can expect high performance.
- A Cache Volume is formatted as a regular Linux filesystem (e.g., ext4), so you can expect them to support any use-case you have that Linux supports.

### Cache paths

Cache volumes are mounted into user-specified paths. Cache paths will be mounted relative to the builds working directory. Absolute references can be provided in the cache paths configuration relative to the root of the instance (for example `/etc/cache`).

```yaml
# Mount the node_modules directory on all steps in the pipeline. This will use the default cache volume for the pipeline.
cache:
  paths:
    - "node_modules"

steps:
  - command: "npm install"

  - command: "bundle install"
    # Mount the vendor/bundle directory to the cache volume.
    # This will use the default cache volume for the pipeline.
    cache:
      paths:
        - "vendor/bundle"
```

### Lifecycle

At any point in time, multiple versions of a Cache Volume may be used by different jobs.

The first request creates the first version of the Cache Volume, which is used as the parent of subsequent forks until a new parent version is committed.

When requesting a Cache Volume, a "fork" of the previous cache volume version is attached to the agent instance (all but the first one, which starts empty).

Each job gets its own private copy of the Cache Volume, as it existed at the time of the last cache commit.

Version commits follow a "last write" model: whenever a job terminates successfully (e.g. exits with exit code 0), Cache Volumes attached to that job have a new parent committed: the final flushed volume of the exiting agent instance.

Whenever a job fails, the Cache Volume versions attached to the agent instance are abandoned.

### Custom caches

Custom caches can be created by specifying a name for the cache. This allows for multiple cache volumes to be used in a single pipeline.

```yaml
# Mount the node_modules directory on all steps. This will use the default cache volume for the pipeline.
cache:
  paths:
    - "node_modules"

steps:
  - command: "npm install"

  - command: "bundle install"
    # Mount the vendor/bundle directory to a dedicated bundle cache volume. One bundle cache volume will be created for the pipeline.
    cache:
      name: "bundle-cache"
      paths:
        - "vendor/bundle"
```

### Sizing

When requesting a Cache Volume you can specify a size. When requesting x GB, a volume will be provided that has at least x GB free. In the case of a cache hit (most of the time), the actual volume size is: last used volume size + x.

The default size for the dependency cache is 20 gigabytes. This can be customized with the `size` option. Units are in gigabytes specified as a `Ng`, where N is the size in gigabytes.

```yaml
cache:
  size: "30g"
  paths:
    - "node_modules"
steps:
  - command: "npm install"
```

### Git mirror cache

The Git mirror cache is a special type of Cache Volume that is used to speed up Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

Git mirror caching can be enabled on the Cluster's Cache Volumes settings page. Once enabled, the Git mirror cache will be used for all hosted jobs in that cluster. A separate cache volume will be created for each repository.

<%= image "hosted-agents-cache-settings.png", width: 1760, height: 436, alt: "Job groups displayed in the Buildkite UI" %>
