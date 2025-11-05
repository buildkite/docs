# Cache volumes

_Cache volumes_ (also known as _volumes_) are external volumes attached to Buildkite hosted agent instances. These volumes are attached on a best-effort basis depending on their locality, expiration and current usage, and therefore, should not be relied upon as durable data storage.

By default, volumes:

- Are disabled, although you can enable them by providing a list of paths containing files and data to temporarily store in these volumes at the pipeline- or step-level.
- Are scoped to a pipeline and are shared between all steps in the pipeline.

Volumes act as regular disks with the following properties on Linux:

- They use NVMe storage, delivering high performance.
- They are formatted as a regular Linux filesystem (for example, ext4)—therefore, these volumes support any Linux use-cases.

Volumes on macOS are a little different, with [sparse bundle disk images](https://en.wikipedia.org/wiki/Sparse_image#Sparse_bundle_disk_images) being utilized, as opposed to the bind mount volumes used by Linux. However, macOS volumes are managed in the same way as they are for Linux volumes.

> 📘 Volume retention
> Volumes are retained for up to 14 days maximum from their last use. Note that 14 days is not a guaranteed retention duration and that the volumes may be removed before this period ends.
> Design your workflows to handle cache misses, as volumes are designed for temporary data storage.

## Cache configuration

Cache paths can be [defined in your `pipeline.yml`](/docs/pipelines/configure/defining-steps) file. Defining cache paths for a step will implicitly create a cache volume for the pipeline.

When cache paths are defined, the cache volume is mounted under `/cache` in the agent instance. The agent links subdirectories of the cache volume into the paths specified in the configuration. For example, defining `cache: "node_modules"` in your `pipeline.yml` file will link `./node_modules` to `/cache/bkcache/node_modules` in your agent instance.

Custom caches can be created by specifying a name for the cache, which allows you to use multiple cache volumes in a single pipeline.

When requesting a cache volume, you can specify a size. The cache volume provided will have a minimum available storage equal to the specified size. In the case of a cache hit (most of the time), the actual volume size is: last used volume size + the specified size.

Defining a top-level cache configuration sets the default cache volume for all steps in the pipeline. Any cache defined within a step will be merged with the top-level definition, with step-level cache size taking precedence when the same cache name is specified at both levels. Paths from both levels will be available when using the same cache name.

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

### Required attributes

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

> 📘
> On [macOS hosted agents](/docs/pipelines/hosted-agents/macos), the instance is a full macOS snapshot, including the standard file system structure. Cache paths cannot be specified on reserved paths, such as `/tmp` and `/private`. However, sub-paths such as `/tmp/cache` are acceptable.

### Optional attributes

<table data-attributes data-attributes-optional>
  <tr>
    <td><code>name</code></td>
    <td>
      A name for the cache. This allows for multiple cache volumes to be used in a single pipeline. If no <code>name</code> is specified, the value of this attribute defaults to the pipeline slug.<br>
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

## Lifecycle

At any point in time, multiple versions of a cache volume may be used by different jobs.

The first request creates the first version of the cache volume, which is used as the parent of subsequent _forks_ until a new parent version is committed. A _fork_ in this context is a "moment", or a readable/writable "snapshot", version of the cache volume in time.

When requesting a cache volume, a fork of the previous cache volume version is attached to the agent instance. This is the case for all cache volumes, except for the first request, which starts empty, with no cache volumes attached.

Each job gets its own private copy of the cache volume, as it existed at the time of the last cache commit.

Version commits follow a "last write" model: whenever a job terminates successfully (that is, exits with exit code `0`), cache volumes attached to that job have a new parent committed: the final flushed volume of the exiting agent instance.

Whenever a job fails, the cache volume versions attached to the agent instance are abandoned.

## Git mirror cache

The Git mirror cache is a specialized type of cache volume designed to accelerate Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

Git mirror caching can be enabled on the cluster's cache volumes settings page. Once enabled, the Git mirror cache will be used for all hosted jobs in that cluster. A separate cache volume will be created for each repository.

<%= image "hosted-agents-git-mirror.png", width: 1760, height: 436, alt: "Hosted agents git mirror setting displayed in the Buildkite UI" %>

## Container cache

The container cache can be used to cache Docker images between builds.

> 📘
> This feature is only available to [Linux hosted agents](/docs/pipelines/hosted-agents/linux).

Container caching can be enabled on the cluster's cache volumes settings page. Once enabled, a container cache will be used for all hosted jobs in that cluster. A separate cache volume will be created for each pipeline.

<%= image "hosted-agents-container-caching.png", width: 1760, height: 436, alt: "Hosted agents container cache setting displayed in the Buildkite UI" %>
