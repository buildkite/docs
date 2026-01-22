# Build artifacts

Buildkite can store and retrieve build outputs as _artifacts_.
In this guide, you'll learn what artifacts are, what they're used for, and how to upload and download them.

An artifact is a file's contents and metadata, such as its original file path, an integrity verification hash, and details of the build that uploaded it.
Buildkite agents upload artifacts to a storage service during a build.

You can use artifacts to:

- Pass files from one pipeline step to another.
  For example, you can build a binary in one step, then download and run that binary in a later step.
- Store final assets produced by a pipeline, such as logs, reports, archives, and images.
  For example, you can build a static site, store the result as an archive, and fetch it later for deployment.

You can choose to keep artifacts in a Buildkite-managed storage service or a third-party cloud storage service.

There are several methods you can use to upload and download artifacts, summarized in the table:

<table>
  <thead>
    <tr>
      <th></th>
      <th>Upload</th>
      <th>Download</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Command step</th>
      <td>Yes</td>
      <td>No</td>
    </tr>
    <tr>
      <th scope="row">Buildkite Agent</th>
      <td>Yes</td>
      <td>Yes</td>
    </tr>
    <tr>
      <th scope="row">REST API</th>
      <td>No</td>
      <td>Yes</td>
    </tr>
  </tbody>
</table>

You can upload artifacts [using a pipeline step](#upload-artifacts-with-a-command-step) or by [running the `buildkite-agent artifact upload` command](#upload-artifacts-with-the-buildkite-agent).
When you upload an artifact, Buildkite saves the file's contents, the complete path the file was uploaded from, and details of the build step it originated from, so you can retrieve artifacts by name, path, or build.

You can download artifacts by [running the `buildkite-agent artifact download` command](#download-artifacts-with-the-buildkite-agent) or by [making a request to the artifacts REST API](#download-artifacts-with-the-buildkite-rest-api).

## Upload artifacts with a command step

Set the `artifact_paths` attribute of [a command step](/docs/pipelines/configure/step-types/command-step) to upload artifacts after the command step has finished its work.
The `artifact_paths` attribute can contain an array of file paths or [glob patterns](/docs/agent/v3/cli/reference/artifact#uploading-artifacts-artifact-upload-glob-syntax) to upload.

The following example shows a command step configured to upload all of the files in the `logs` and `coverage` directories and their subdirectories:

```yaml
steps:
  - label: ":hammer: Tests"
    command:
      - "npm install"
      - "tests.sh"
    artifact_paths:
      - "logs/**/*"
      - "coverage/**/*"
```
{: codeblock-file="pipeline.yml"}

## Upload artifacts with the Buildkite agent

Within a build, run the `buildkite-agent artifact upload` command to upload artifacts.
The agent's `upload` command arguments are one or more file paths and [glob patterns](/docs/agent/v3/cli/reference/artifact#uploading-artifacts-artifact-upload-glob-syntax).

The following example uploads a `build.tar.gz` file from the `pkg` directory:

```shell
buildkite-agent artifact upload pkg/build.tar.gz
```

The `buildkite-agent artifact upload` command supports several options and environment variables.
For complete usage instructions, read the [`buildkite-agent artifact upload`](/docs/agent/v3/cli/reference/artifact#uploading-artifacts) documentation.

## Download artifacts with the Buildkite agent

Within a build, run the `buildkite-agent artifact download` command to download artifacts from a script.
The agent's `download` command arguments are a file path or [glob pattern](/docs/agent/v3/cli/reference/artifact#uploading-artifacts-artifact-upload-glob-syntax) and a destination path.

The `buildkite-agent artifact download` command supports several options and environment variables.
For complete usage instructions, read the [`buildkite-agent artifact download`](/docs/agent/v3/cli/reference/artifact#downloading-artifacts) documentation.

> 📘 Pipeline artifact access
> Pipelines associated with one [cluster](/docs/pipelines/glossary#cluster) cannot access artifacts from pipelines associated with another cluster, unless a [rule](/docs/pipelines/security/clusters/rules) has been created to explicitly allow artifact access between pipelines in different clusters.

### Example: download one artifact

The agent's `download` command can fetch another job's artifact and save it to a destination path.

The following example downloads an artifact from a previous job — a file named `build.tar.gz` that was in the job's `pkg` directory — to the destination `archives` directory in the working directory of the current job:

```shell
buildkite-agent artifact download pkg/build.tar.gz archives
```

### Example: download many artifacts

The agent's `download` command can download many artifacts using a glob pattern.
If needed, the agent can mirror the artifact's directory structure in the destination directory.

The following example downloads all of the files uploaded from the `logs` directory to the `local-logs` directory:

```shell
buildkite-agent artifact download 'logs/**' local-logs/
```

### Example: download an artifact from a specific step

By default, the agent downloads the most recent matching artifact, no matter which build step uploaded it.
If you want to get an artifact from a specific build step, use the `--step` option.

The following example downloads `build.zip` from the `build` step:

```shell
buildkite-agent artifact download build.zip tmp/ --step build
```

### Example: download an artifact from a triggering build

To download artifacts from the build that [triggered](/docs/pipelines/configure/step-types/trigger-step) the current build, pass the `$BUILDKITE_TRIGGERED_FROM_BUILD_ID` [environment variable](/docs/pipelines/configure/environment-variables) to the download command:

```shell
buildkite-agent artifact download "*.jpg" images/ --build $BUILDKITE_TRIGGERED_FROM_BUILD_ID
```

## Download artifacts with the Buildkite REST API

If you want to download an artifact from outside the context of a running build or without the use of the Buildkite agent, then use the [artifacts REST API](/docs/apis/rest-api/artifacts) to list and download artifacts.

## Storage providers, encryption, and retention

Buildkite agents upload artifacts directly to artifact storage, where they're encrypted by the storage platform.

If you're using Buildkite-managed artifact storage, then your artifacts are stored in Amazon S3.
At rest, artifacts are AES-256 encrypted with keys managed by AWS Key Management Service.
Buildkite retains artifacts for six months before deletion.

Alternatively, you can use a self-managed storage provider. Read these guides for details:

- [Amazon S3](/docs/agent/v3/cli/reference/artifact#using-your-private-aws-s3-bucket)
- [Google Cloud Storage](/docs/agent/v3/cli/reference/artifact#using-your-private-google-cloud-bucket)
- [Azure Blob Storage](/docs/agent/v3/cli/reference/artifact#using-your-private-azure-blob-container)
- [Artifactory](/docs/agent/v3/cli/reference/artifact#using-your-artifactory-instance)

If you manage your own artifact storage, then you are responsible for encryption and retention planning.

To track the actions of users with access to your artifacts, use the [API Access Audit](https://buildkite.com/organizations/~/api-access-audit).

## Troubleshooting artifacts

The following suggestions resolve common issues with using artifacts.

### Multiple artifacts were found for query

The `buildkite-agent artifact download` command can fail with the following error message:

```
Failed to download artifacts: GET https://agent.buildkite.com/v3/builds/776402f5-90a8-458f-9a2c-57e67c50a888/artifacts/search?query=ambiguous-file-name.txt&state=finished: 400 Multiple artifacts were found for query: `ambiguous-file-name.txt`. Try scoping by the job ID or name.
```

The error occurs when the agent tries to download a specific file by name, but cannot find a unique match.
In other words, the file path was ambiguous and did not identify a single artifact with that name in the current the build.
For example, two previous steps uploaded a file with the same name.

To fix this error, specify the step or build that uploaded the artifact.
Use the `--step` or `--build` options to narrow the search for artifacts.
For an example, read [download an artifact from a specific step](#download-artifacts-with-the-buildkite-agent-example-download-an-artifact-from-a-specific-step).

Alternatively, download the most recent matching file by using a glob pattern.
For an example, read [download many artifacts](#download-artifacts-with-the-buildkite-agent-example-download-many-artifacts).

### Artifacts are missing from retried jobs

Artifacts from retried jobs are excluded by default, so the `buildkite-agent artifact download` command won't find them. To include artifacts from retried jobs in your search results, use `--include-retried-jobs` in the command.
