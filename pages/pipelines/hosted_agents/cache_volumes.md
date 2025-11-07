# Cache volumes

_Cache volumes_ (also known as _volumes_) are external volumes attached to Buildkite hosted agent instances. These volumes are attached on a best-effort basis depending on their locality, expiration and current usage, and therefore, should not be relied upon as durable data storage.

By default, volumes:

- Are disabled, although you can enable them by providing a list of paths containing files and data to temporarily store in these volumes at the pipeline- or step-level.
- Are scoped to a pipeline and are shared between all steps in the pipeline.

Volumes act as regular disks, and have the following properties on Linux:

- They use NVMe storage, delivering high performance.
- They are formatted as a regular Linux filesystem (for example, ext4)—therefore, these volumes support any Linux use-cases.

Volumes on macOS are a little different, with [sparse bundle disk images](https://en.wikipedia.org/wiki/Sparse_image#Sparse_bundle_disk_images) being utilized, as opposed to the bind mount volumes used by Linux. However, macOS volumes are managed in the same way as they are for Linux volumes.

> 📘 Volume retention
> Volumes are retained for up to 14 days maximum from their last use. Note that 14 days is not a guaranteed retention duration and that the volumes may be removed before this period ends.
> Design your workflows to handle volume misses, as volumes are designed for temporary data storage.

## Volume configuration

Volume paths can be [defined in your `pipeline.yml`](/docs/pipelines/configure/defining-steps) file using the `cache` key at either the root level of your pipeline YAML, or as an [attribute on a step](/docs/pipelines/configure/step-types). Defining paths for the `cache` key in your pipeline YAML or attribute on a step will implicitly create a volume for the pipeline.

When volume paths are defined, the volume is mounted under `/cache/bkcache` in the agent instance. The agent links sub-directories of the volume into the paths specified in the configuration. For example, defining `cache: "node_modules"` in your `pipeline.yml` file will link `./node_modules` to `/cache/bkcache/node_modules` in your agent instance.

Volumes can be created by specifying a name for the volume, which allows you to use multiple volumes in a single pipeline.

When requesting a volume, you can specify a size. The volume provided will have a minimum available storage equal to the specified size. In the case of a volume hit (most of the time), the actual volume size is: last used volume size + the specified size.

Defining a top-level volume configuration (using the `cache` key at the root level of your pipeline YAML) sets the default volume for all steps in the pipeline. Any volume defined within a step will be merged with the top-level volume configuration, with step-level volume size taking precedence when the same volume name is specified at both levels. Paths from both levels will be available when using the same volume name.

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
      name: "bundle-volume"
```
{: codeblock-file="pipeline.yml"}

### Required attributes

<table data-attributes data-attributes-required>
  <tr>
    <td><code>paths</code></td>
    <td>
      A list of paths to volume. Paths are relative to the working directory of the step.<br>
      Absolute references can be provided in the <code>cache</code> paths configuration relative to the root of the instance.<br>
      <em>Example:</em><br>
      <code>- ".volume"</code><br>
      <code>- "/tmp/volume"</code><br>
    </td>
  </tr>
</table>

> 📘
> On [macOS hosted agents](/docs/pipelines/hosted-agents/macos), the instance is a full macOS snapshot, including the standard file system structure. Volume paths cannot be specified on reserved paths, such as `/tmp` and `/private`. However, sub-paths such as `/tmp/volume` are acceptable.

### Optional attributes

<table data-attributes data-attributes-optional>
  <tr>
    <td><code>name</code></td>
    <td>
      A name for the volume. This allows for multiple volumes to be used in a single pipeline. If no <code>name</code> is specified, the value of this attribute defaults to the pipeline slug.<br>
      <em>Example:</em> <code>"node-modules-volume"</code><br>
    </td>
  </tr>

  <tr>
    <td><code>size</code></td>
    <td>
      The size of the volume. The default size is 20 gigabytes, which is also the minimum volume size that can be requested.<br/>Units are in gigabytes, specified as <code>Ng</code>, where <code>N</code> is the size in gigabytes, and <code>g</code> indicates gigabytes.<br>
      <em>Example:</em> <code>"20g"</code><br>
    </td>
  </tr>
</table>

## Lifecycle

At any point in time, multiple versions of a volume may be used by different jobs.

The first request creates the first version of the volume, which is used as the parent of subsequent _forks_ until a new parent version is committed. A _fork_ in this context is a "moment", or a readable/writable "snapshot", version of the volume in time.

When requesting a volume, a fork of the previous volume version is attached to the agent instance. This is the case for all volumes, except for the first request, which starts empty, with no volumes attached.

Each job gets its own private copy of the volume, as it existed at the time of the last committed volume version.

Version commits follow a "last write" model—whenever a job terminates successfully (that is, exits with exit code `0`), volumes attached to that job have a new parent committed—the final flushed volume of the exiting agent instance.

Whenever a job fails, the volume versions attached to the agent instance are abandoned.

## Git mirror volume

The Git mirror volume is a specialized type of volume designed to accelerate Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

The Git mirror volume feature can be enabled on the cluster's **Cached Storage** > **Settings** page. Once enabled, the Git mirror volume will be used for all Buildkite hosted agent jobs in that cluster. A separate volume will be created for each repository.

<%= image "hosted-agents-git-mirror.png", width: 1760, height: 436, alt: "Hosted agents git mirror setting displayed in the Buildkite UI" %>

## Container cache

The container cache is a type of volume used to cache Docker images between builds.

> 📘
> This feature is only available to [Linux hosted agents](/docs/pipelines/hosted-agents/linux).

The container caching feature can be enabled on the cluster's **Cached Storage** > **Settings** page. Once enabled, a container cache will be used for all Buildkite hosted agent jobs in that cluster. A separate volume will be created for each pipeline.

<%= image "hosted-agents-container-caching.png", width: 1760, height: 436, alt: "Hosted agents container cache setting displayed in the Buildkite UI" %>
