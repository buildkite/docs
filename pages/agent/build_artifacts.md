# Build Artifacts

The Buildkite Agent’s `artifact` command provides support for uploading and downloading of build artifacts, allowing you to share binary data between build steps no matter the machine or network.

See the [Using Build Artifacts](/docs/guides/artifacts) guide for a step-by-step example.

<%= toc %>

## Uploading Artifacts

Use this command in your build scripts to store artifacts for accessing via the web interface or downloading in future build steps. Alternatively you can configure the agent to automatically upload artifacts based on a file pattern (see the [Using Build Artifacts guide](/docs/guides/artifacts) for details).

```
Usage:

   buildkite-agent artifact upload <pattern> <destination> [arguments...]

Description:

   Uploads files to a job as artifacts.

   You need to ensure that the paths are surrounded by quotes otherwise the
   built-in shell path globbing will provide the files, which is currently not
   supported.

Example:

   $ buildkite-agent artifact upload "log/**/*.log"

   You can also upload directly to Amazon S3 if you'd like to host your own artifacts:

   $ export BUILDKITE_S3_ACCESS_KEY_ID=xxx
   $ export BUILDKITE_S3_SECRET_ACCESS_KEY=yyy
   $ export BUILDKITE_S3_DEFAULT_REGION=eu-central-1 # default is us-east-1
   $ export BUILDKITE_S3_ACL=private # default is public-read
   $ buildkite-agent artifact upload "log/**/*.log" s3://name-of-your-s3-bucket/$BUILDKITE_JOB_ID`

Options:

   --job                Which job should the artifacts be uploaded to [$BUILDKITE_JOB_ID]
   --agent-access-token          The access token used to identify the agent [$BUILDKITE_AGENT_ACCESS_TOKEN]
   --endpoint 'https://agent.buildkite.com/v3'  The agent API endpoint [$BUILDKITE_AGENT_ENDPOINT]
   --debug              Enable debug mode [$BUILDKITE_AGENT_DEBUG]
   --no-color              Don't show colors in logging [$BUILDKITE_AGENT_NO_COLOR]
```

## Downloading Artifacts

Use this command in your build scripts to download artifacts.

```
Usage:

   buildkite-agent artifact download [arguments...]

Description:

   Downloads artifacts from Buildkite to the local machine.

   Note: You need to ensure that your search query is surrounded by quotes if
   using a wild card as the built-in shell path globbing will provide files,
   which will break the download.

Example:

   $ buildkite-agent artifact download "pkg/*.tar.gz" . --build xxx

   This will search across all the artifacts for the build with files that match that part.
   The first argument is the search query, and the second argument is the download destination.

   If you're trying to download a specific file, and there are multiple artifacts from different
   steps, you can target the particular step you want to download the artifact from:

   $ buildkite-agent artifact download "pkg/*.tar.gz" . --step "tests" --build xxx

   You can also use the steps job id (provided by the environment variable $BUILDKITE_JOB_ID)

Options:

   --step               Used to target a specific step to download artifacts from
   --build              Which build should the artifacts be downloaded from [$BUILDKITE_BUILD_ID]
   --agent-access-token          The access token used to identify the agent [$BUILDKITE_AGENT_ACCESS_TOKEN]
   --endpoint 'https://agent.buildkite.com/v3'  The agent API endpoint [$BUILDKITE_AGENT_ENDPOINT]
   --debug              Enable debug mode [$BUILDKITE_AGENT_DEBUG]
   --no-color              Don't show colors in logging [$BUILDKITE_AGENT_NO_COLOR]
```

## Downloading Artifacts Outside a Running Build

The `buildkite-agent artifact download` command only works within the context of a running build.

If you want to download an artifact from outside a build use our [Artifact Download API](/docs/api/artifacts#download-an-artifact).

## Fetching the SHA of an artifact

Use this command in your build scripts to verify downloaded artifacts against the original SHA-1 of the file.

```
Usage:

   buildkite-agent artifact shasum [arguments...]

Description:

   Prints to STDOUT the SHA-1 for the artifact provided. If your search query
   for artifacts matches multiple agents, and error will be raised.

   Note: You need to ensure that your search query is surrounded by quotes if
   using a wild card as the built-in shell path globbing will provide files,
   which will break the download.

Example:

   $ buildkite-agent artifact shasum "pkg/release.tar.gz" --build xxx

   This will search for all the files in the build with the path "pkg/release.tar.gz" and will
   print to STDOUT it's SHA-1 checksum.

   If you would like to target artifacts from a specific build step, you can do
   so by using the --step argument.

   $ buildkite-agent artifact shasum "pkg/release.tar.gz" --step "release" --build xxx

   You can also use the steps job id (provided by the environment variable $BUILDKITE_JOB_ID)

Options:

   --step                Used to target a specific step to download artifacts from
   --build              Which build should the artifacts be downloaded from [$BUILDKITE_BUILD_ID]
   --agent-access-token          The access token used to identify the agent [$BUILDKITE_AGENT_ACCESS_TOKEN]
   --endpoint 'https://agent.buildkite.com/v3'  The agent API endpoint [$BUILDKITE_AGENT_ENDPOINT]
   --debug              Enable debug mode [$BUILDKITE_AGENT_DEBUG]
   --no-color              Don't show colors in logging [$BUILDKITE_AGENT_NO_COLOR]
```

## Using your own S3 bucket

If you’d like to upload artifacts to your own Amazon S3 bucket simply export the following environment variables using an [environment agent hook](/docs/agent/hooks):

```bash
export BUILDKITE_S3_ACCESS_KEY_ID=xxx
export BUILDKITE_S3_SECRET_ACCESS_KEY=yyy
export BUILDKITE_S3_DEFAULT_REGION=eu-central-1 # default is us-east-1
export BUILDKITE_S3_ACL=private # default is public-read
export BUILDKITE_ARTIFACT_UPLOAD_DESTINATION=s3://name-of-your-s3-bucket/$BUILDKITE_JOB_ID
```

The agent will recognize the `s3://` prefix in the `BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` environment variable and upload the artifacts to S3 to the bucket name `name-of-your-s3-bucket`. If you upload artifacts to your own S3 bucket, you can further secure your artifacts by [restricting access to specific IP addresses](https://docs.aws.amazon.com/AmazonS3/latest/dev/AccessPolicyLanguage_UseCases_s3_a.html).
