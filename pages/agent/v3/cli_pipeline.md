# buildkite-agent pipeline

The Buildkite Agent's `pipeline` command allows you to add and replace build steps in the running build. The steps are defined using YAML or JSON and can be read from a file or streamed from the output of a script.

See the [Defining your pipeline steps](/docs/pipelines/configure/defining-steps) guide for a step-by-step example and list of step types.

## Uploading pipelines

> 🚧 Processing of a single pipeline file
> In versions of the Buildkite Agent prior to 3.104.0, the `buildkite-agent pipeline upload` command only processes a single pipeline file. If multiple files are passed into a command (including using a wildcard `*` in the filename), only the first pipeline file will be processed, and any additional pipeline files provided as arguments are ignored. Later versions of the Buildkite Agent do support multiple pipeline file uploads. See [Uploading multiple pipelines](/docs/agent/v3/cli_pipeline#uploading-multiple-pipelines) for more information.

<%= render 'agent/v3/help/pipeline_upload' %>

## Pipeline format

The pipeline can be written as YAML or JSON, but YAML is more common for its readability. There are three top-level properties you can specify:

* The `agents` attribute - a map of agent characteristics such as `os` or `queue` that restrict what agents the command will run on.
* The `env` attribute - a map of [environment variables](/docs/pipelines/configure/environment-variables) to apply to all steps.
* The `steps` attribute - an array of [build pipeline steps](/docs/pipelines/configure/defining-steps).

## Insertion order

Steps are inserted immediately following the job performing the pipeline upload. Note that if you perform multiple uploads from a single step, they can appear to be in reverse order, because the later uploads are inserted earlier in the pipeline.

## Environment variable substitution

The `pipeline upload` command supports environment variable substitution using the syntax `$VAR` and `${VAR}`.

For example, the following pipeline substitutes a number of [Buildkite's default environment variables](/docs/pipelines/configure/environment-variables) into a [trigger step](/docs/pipelines/configure/step-types/trigger-step):

```yaml
- trigger: "app-deploy"
  label: "\:rocket\: Deploy"
  branches: "main"
  async: true
  build:
    message: "${BUILDKITE_MESSAGE}"
    commit: "${BUILDKITE_COMMIT}"
    branch: "${BUILDKITE_BRANCH}"
```

If you want an environment variable to be evaluated at runtime (for example, using the step's environment variables), ensure you escape the `$` character using `$$` or `\$`. For example:

```yaml
- command: "deploy.sh $$SERVER"
  env:
    SERVER: "server-a"
```

### Escaping the $ character

If you need to prevent substitution, you can escape the `$` character by using `$$` or `\$`.

For example, using `$$USD` and `\$USD` will both result in the same value: `$USD`.

### Disabling interpolation

You can disable interpolation with the `--no-interpolation` flag, which was added in v3.1.1.

### Requiring environment variables

You can set required environment variables using the syntax `${VAR?}`. If `VAR` is not set, the `pipeline upload` command will print an error and exit with a status of 1.

For example, the following step will cause the pipeline upload to error if the `SERVER` environment variable has not been set:

```yaml
- command: "deploy.sh \"${SERVER?}\""
```

You can set a custom error message after the `?` character. For example, the following prints the error message `SERVER: is not set. Please specify a server` if the environment variable has not been set:

```yaml
- command: "deploy.sh \"${SERVER?is not set. Please specify a server}\""
```

### Default, blank, and missing values

If an environment variable has not been set it will evaluate to a blank string. You can set a fallback value using the syntax `${VAR:-default-value}`.

For example, the following step will run the command `deploy.sh staging`:

```yaml
- command: "deploy.sh \"${SERVER:-staging}\""
```

<table class="responsive-table">
  <thead>
    <tr><th>Environment Variables</th><th>Syntax</th><th>Result</th></tr>
  </thead>
  <tbody>
    <tr><td><code></code></td><td><code>"${SERVER:-staging}"</code></td><td><code>"staging"</code></td></tr>
    <tr><td><code>SERVER=""</code></td><td><code>"${SERVER:-staging}"</code></td><td><code>"staging"</code></td></tr>
    <tr><td><code>SERVER="staging-5"</code></td><td><code>"${SERVER:-staging}"</code></td><td><code>"staging-5"</code></td></tr>
  </tbody>
</table>

If you need to substitute environment variables containing empty strings, you can use the syntax `${VAR-default-value}` (notice the missing `:`).

<table class="responsive-table">
  <thead>
    <tr><th>Environment Variables</th><th>Syntax</th><th>Result</th></tr>
  </thead>
  <tbody>
    <tr><td><code></code></td><td><code>"${SERVER-staging}"</code></td><td><code>"staging"</code></td></tr>
    <tr><td><code>SERVER=""</code></td><td><code>"${SERVER-staging}"</code></td><td><code>""</code></td></tr>
    <tr><td><code>SERVER="staging-5"</code></td><td><code>"${SERVER-staging}"</code></td><td><code>"staging-5"</code></td></tr>
  </tbody>
</table>

### Extracting character ranges

You can substitute a subset of characters from an environment variable by specifying a start and end range using the syntax `${VAR:start:end}`.

For example, the following step will echo the first 7 characters of the `BUILDKITE_COMMIT` environment variable:

```yaml
- command: "echo \"Short commit is: ${BUILDKITE_COMMIT:0:7}\""
```

If the environment variable has not been set, the range will return a blank string.

## Uploading multiple pipelines

From version 3.104.0 of the Buildkite Agent, multiple pipelines can be uploaded by passing them as arguments to a single command:

```bash
buildkite-agent pipeline upload .buildkite/pipeline1.yml .buildkite/pipeline2.yml
````

Shell glob expansions, which are expanded by the shell into a list of files, can also be used:

```bash
buildkite-agent pipeline upload .buildkite/pipeline*.yml
````

Older agent versions only process a single file. Different approaches are available for handling the upload of multiple pipeline files for processing.

### Multiple sequential uploads

You can call `buildkite-agent pipeline upload` multiple times within the same step to upload multiple pipeline files:

```bash
buildkite-agent pipeline upload .buildkite/pipeline1.yml
buildkite-agent pipeline upload .buildkite/pipeline2.yml
```

### Pass multiple files to command

Using the `find` command, you can pipe `|` multiple file paths into the `buildkite-agent pipeline upload` command:

```bash
find .buildkite/ -type f -iname '*.yaml' -print0 | xargs -0 -n1 buildkite-agent pipeline upload
```

### Combine multiple pipeline files

Since the `buildkite-agent pipeline upload` command is also able to accept pipeline YAML, you can emit the contents of multiple pipeline files and have this combined output be processed directly from STDIN.

> 🚧 Processing of multiple pipeline files
> When passing multiple pipeline files into the pipeline upload command, include a `---` on the first line of each pipeline file to indicate the beginning of each new pipeline YAML file. This is required to ensure the `buildkite-agent` is able to correctly process multiple files that have been combined into a single input stream.

Using the following three example pipeline files:

```yaml
---
steps:
  - label: "Start of the build"
    command: ./scripts/build-start.sh
```
{: codeblock-file="pipeline-start.yml"}

```yaml
---
steps:
  - label: "Middle of the build"
    command: ./scripts/build-middle.sh
```
{: codeblock-file="pipeline-middle.yml"}

```yaml
---
steps:
  - label: "End of the build"
    command: ./scripts/build-end.sh
```
{: codeblock-file="pipeline-end.yml"}

Pass the contents of all the pipeline files that are matching the wildcard `*` file pattern into the pipeline upload command:

```bash
cat .buildkite/pipeline-*.yml | buildkite-agent pipeline upload
```

Alternatively, you can explicitly list each pipeline file to be passed into the pipeline upload command:

```bash
cat .buildkite/pipeline-start.yml .buildkite/pipeline-middle.yml .buildkite/pipeline-end.yml | buildkite-agent pipeline upload
```

## Troubleshooting

Here are some common issues that can occur when uploading a pipeline.

### Common errors

Pipeline uploads can be rejected if certain criteria are not met. Here are explanations for why your pipeline upload might be rejected.

<table class="responsive-table">
  <thead>
    <tr><th>Error</th><th>Reason</th></tr>
  </thead>
  <tbody>
    <tr><td><code>The key "duplicate-key-name" has already <br>been used by another step in this build</code></td><td>This error occurs when you try to upload a pipeline step with a <code>key</code> attribute that matches the <code>key</code> attribute of an existing step in the pipeline. <code>key</code> attributes must be unique for all steps in a build. To resolve this error, either remove the duplicate <code>key</code> or change it to a unique value.</td></tr>
    <tr><td><code>You can only change the pipeline of a <br>running build</code></td><td>This error occurs when you attempt to upload a pipeline to a build that has already finished. This typically happens when using the <code>--job</code> option with the upload command. To resolve this, ensure the build is still running before uploading, or start a new build.</td></tr>
  </tbody>
</table>
