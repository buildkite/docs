# Build matrix

Build matrices help you simplify complex build configurations by expanding a step template and array of matrix elements into multiple jobs.

The following [command step](/docs/pipelines/configure/step-types/command-step) attributes can contain matrix values for interpolation:

* [environment variables](/docs/pipelines/configure/environment-variables)
* [labels](/docs/pipelines/configure/step-types/command-step#label)
* [commands](/docs/pipelines/configure/step-types/command-step#command-step-attributes)
* [plugins](/docs/pipelines/configure/step-types/command-step#plugins)
* [agents](/docs/pipelines/configure/step-types/command-step#agents)

You can't use matrix values in other attributes, including step keys and [concurrency groups](/docs/pipelines/configure/workflows/controlling-concurrency#concurrency-groups).

For example, instead of writing three separate jobs for builds on macOS, Linux, and Windows, like the following build configuration (which does not use a build matrix):

```yaml
steps:
  - label: "macOS build"
    command: "GOOS=darwin go build"
  - label: "Linux build"
    command: "GOOS=linux go build"
  - label: "Windows build"
    command: "GOOS=windows go build"
```
{: codeblock-file="pipeline.yml"}

Use a build matrix to expand a single step template into three steps by interpolating the matrix values into the following build configuration:

```yaml
steps:
  - label: "{{matrix}} build"
    command: "GOOS={{matrix}} go build"
    env:
      os: "{{matrix}}"
    matrix:
      - "darwin"
      - "Linux"
      - "Windows"
```
{: codeblock-file="pipeline.yml"}


All jobs created by a build matrix are marked with the **Matrix** badge in the Buildkite interface.

> 📘 Matrix and Parallel steps
> Matrix builds are not compatible with explicit [parallelism in steps](/docs/pipelines/tutorials/parallel-builds#parallel-jobs). You can use a `matrix` and `parallelism` in the same build, as long as they are on separate steps.

For more complex builds, add multiple dimensions to `matrix.setup` instead of the `matrix` array:

```yaml
steps:
- label: "💥 Matrix Build"
  command: "echo {{matrix.os}} {{matrix.arch}} {{matrix.test}}"
  agents:
    queue: "builder-{{matrix.arch}}"
  matrix:
    setup:
      arch:
        - "amd64"
        - "arm64"
      os:
        - "windows"
        - "linux"
      test:
        - "A"
        - "B"
```
{: codeblock-file="pipeline.yml"}

Each dimension you add is multiplied by the other dimensions, so two architectures (`matrix.setup.arch`), two operating systems (`matrix.setup.os`), and two tests (`matrix.setup.test`) create an eight job build (`2 * 2 * 2 = 8`):

<%= image "matrix_build.jpg", width: 1155/2, height: 814/2, alt: "Screenshot of an eight job matrix" %>

If you're using `matrix.setup`, you can also use the `adjustments` key to change specific entries in the build matrix, or add new combinations. You can set the `skip` attribute to exclude them from the matrix, or `soft_fail` attributes to allow them to fail without breaking the build.

```yaml
steps:
- label: "💥 Matrix build with adjustments"
  command: "echo {{matrix.os}} {{matrix.arch}} {{matrix.test}}"
  matrix:
    setup:
      arch:
        - "amd64"
        - "arm64"
      os:
        - "windows"
        - "linux"
      test:
        - "A"
        - "B"
    adjustments:
      - with:
          os: "windows"
          arch: "arm64"
          test: "B"
        soft_fail: true
      - with:
          os: "linux"
          arch: "arm64"
          test: "B"
        skip: true
```
{: codeblock-file="pipeline.yml"}

## Adding combinations to the build matrix

To add an extra combination that isn't present in the `matrix.setup`, use the `adjustments` key and make sure to define all of the elements in the matrix. For example, to add a build for [Plan 9](https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs) (on `arm64`, and test suite `B`) to the previous example, use:

```yaml
    adjustments:
      - with:
          os: "Plan 9"
          arch: "arm64"
          test: "B"
```
{: codeblock-file="pipeline.yml"}


This results in nine jobs, (`2 * 2 * 2 + 1 = 9`).

## Excluding combinations from the build matrix

To exclude a combination from the matrix, add it to the `adjustments` key and set `skip: true`:

```yaml
    adjustments:
      - with:
          os: "linux"
          arch: "arm64"
          test: "B"
        skip: true
```
{: codeblock-file="pipeline.yml"}

## Matrix limits

Each build matrix has the following limits:

* **6 dimensions** maximum
* **25 elements** per dimension
* **128 bytes** maximum size for each individual matrix element (both keys and values)
* **12 adjustments** total
* **50 jobs** created per `matrix` configuration on a `command` step

## Grouping matrix elements

If you're using the [new build page experience](/docs/pipelines/build-page), matrix jobs are automatically grouped under the matrix step you define in your pipeline. This makes them easier to use and work with. However, if you're using the classic build page with many matrix jobs, then you may want to consider [grouping](/docs/pipelines/configure/step-types/group-step) them together manually with a group step, for a tidier view.

<%= image "grouped.jpg", width: 497/2, height: 331/2, alt: "Screenshot of an eight job matrix inside a group step" %>

To do that, indent the matrix steps inside a [group step](/docs/pipelines/configure/step-types/group-step):

```yaml
steps:
  - group: "📦 Build"
    steps:
      - label: "💥 Matrix build with adjustments"
        command: "echo {{matrix.os}} {{matrix.arch}} {{matrix.test}}"
        matrix:
          setup:
            arch:
              - "amd64"
              - "arm64"
            os:
              - "windows"
              - "linux"
            test:
              - "A"
              - "B"
```
