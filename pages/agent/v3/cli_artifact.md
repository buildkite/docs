# buildkite-agent artifact

The Buildkite Agent's `artifact` command provides support for uploading and
downloading of build artifacts, allowing you to share binary data between build
steps no matter the machine or network.

See the [Using build artifacts](/docs/builds/artifacts) guide for a step-by-step
example.

## Uploading artifacts

You can use this command in your build scripts to store artifacts. Artifacts are accessible using the web interface and can be downloaded by future build steps.
Artifacts can be stored in the Buildkite-managed artifact store, or your own storage location, depending on how you have configured your Buildkite Agent.

Be aware that the Buildkite-managed artifact store has an upload size limit of 5Gb per file/artifact.

For documentation on configuring a custom storage location, see:

- [Using your private AWS S3 bucket](#using-your-private-aws-s3-bucket)
- [Using your private Google Cloud bucket](#using-your-private-google-cloud-bucket)
- [Using your private Azure Blob container](#using-your-private-azure-blob-container)
- [Using your Artifactory instance](#using-your-artifactory-instance)

You can also configure the agent to automatically upload artifacts after your
step's command has completed based on a file pattern (see the
[Using build artifacts guide](/docs/builds/artifacts) for details).


<%= render 'agent/v3/help/artifact_upload' %>


### Artifact upload examples

Uploading a specific file:

```bash
buildkite-agent artifact upload log/test.log
```

Uploading all the jpegs and pngs, in all folders and subfolders:

```bash
buildkite-agent artifact upload "*/**/*.jpg;*/**/*.jpeg;*/**/*.png"
```

Uploading all the log files in the log folder:

```bash
buildkite-agent artifact upload "log/*.log"
```

Uploading all the files and folders inside the `coverage` directory:

```bash
buildkite-agent artifact upload "coverage/**/*"
```

Uploading a file name with special characters, for example, `hello??.html`:

```bash
buildkite-agent artifact upload "hello\?\?.html"
```

### Artifact upload glob syntax

Glob path patterns are used throughout Buildkite for specifying artifact uploads.

The source path you supply to the upload command will be replicated exactly at the destination. If you run:

```bash
buildkite-agent artifact upload log/test.log
```

Buildkite will store the file at `log/test.log`. If you want it to be stored as `test.log` without the full path, then you'll need to change into the file's directory before running your upload command:

```bash
cd log
buildkite-agent artifact upload test.log
```

Learn more about Buildkite's glob syntax from the [Glob pattern syntax](/docs/pipelines/configure/glob-pattern-syntax) page.

<!--alex ignore just-->

## Downloading artifacts

Use this command in your build scripts to download artifacts.

<%= render 'agent/v3/help/artifact_download' %>

### Artifact download examples

Downloading a specific file into the current directory:

```bash
buildkite-agent artifact download build.zip .
```

Downloading a specific file into a specific directory (note the trailing slash):

```bash
buildkite-agent artifact download build.zip tmp/
```

Downloading all the files uploaded to `log` (including all subdirectories) into a local `log` directory (note that local directories will be created to match the uploaded file paths):

```bash
buildkite-agent artifact download "log/*" .
```

Downloading all the files uploaded to `coverage` (including all subdirectories) into a local `tmp/coverage` directory (note that local directories are created to match the uploaded file path):

```bash
buildkite-agent artifact download "coverage/*" tmp/
```

Downloading all images (from any directory) into a local `images/` directory (note that local directories are created to match the uploaded file path, and that you can run multiple download commands into the same directory):

```bash
buildkite-agent artifact download "*.jpg" images/
buildkite-agent artifact download "*.jpeg" images/
buildkite-agent artifact download "*.png" images/
```

### Artifact download pattern syntax

Artifact downloads support pattern-matching using the `*` character.

<!--alex ignore just-->

Unlike artifact upload glob patterns, these operate over the entire path and not just between separator characters. For example, a download path pattern of `log/*` matches all files under the log directory and all subdirectories.

There is no need to escape characters such as `?`, `[` and `]`.

## Downloading artifacts outside a running build

The `buildkite-agent artifact download` command relies on environment variables that are set by the agent while a build is running.

For example, executing the `buildkite-agent artifact download` command on your local machine would return an error about missing environment variables. However, when this command is executed as part of a build, the agent has set the required variables, and the command will be able to run.

If you want to download an artifact from outside a build use our [Artifact Download API](/docs/api/artifacts#download-an-artifact).

## Searching artifacts

Return a list of artifacts that match a query.

<%= render 'agent/v3/help/artifact_search' %>


## Parallelized steps

Currently, Buildkite does not support collating artifacts from parallelized steps under a single key. Thus using the `--step` option with a parallelized step key will return only artifacts from the last completed step.

If you are trying to collate artifacts from parallelized steps, it is best to upload these files with a unique path or name and omit the `--step` flag.

```bash
buildkite-agent artifact <download or search> "artifacts/path/*" . --build $BUILDKITE_BUILD_ID
```

## Fetching the SHA of an artifact

Use this command in your build scripts to verify downloaded artifacts against the original SHA-1 of the file.


<%= render 'agent/v3/help/artifact_shasum' %>


## Using your private AWS S3 bucket

You can configure the `buildkite-agent artifact` command to store artifacts in
your private Amazon S3 bucket. To do so, you'll need to export some artifact
environment variables.

Environment Variable | Required | Default Value | Description
--- | --- | --- | ---
`BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` | Yes | N/A | An S3 scheme URL for the bucket and path prefix, for example, s3://your-bucket/path/prefix/
`BUILDKITE_S3_DEFAULT_REGION` | No | N/A | Which AWS Region to use to locate your S3 bucket, if absent or blank `buildkite-agent` will also consult `AWS_REGION`, `AWS_DEFAULT_REGION`, and finally the EC2 instance metadata service.
`BUILDKITE_S3_ACL` | No | `public-read` | The S3 Object ACL to apply to uploads, one of `private`, `public-read`, `public-read-write`, `authenticated-read`, `bucket-owner-read`, `bucket-owner-full-control`.
`BUILDKITE_S3_SSE_ENABLED` | No | `false` | If `true`, bucket uploads request AES256 server side encryption.
`BUILDKITE_S3_ACCESS_URL` | No | `https://$bucket.s3.amazonaws.com` | If set, overrides the base URL used for the artifact's location stored with the Buildkite API.
`BUILDKITE_S3_ENDPOINT` | No | N/A | URL of the self-hosted S3 compatible endpoint, for example, `https://instance_public_ip:port`. Note that setting this environment variable still requires setting the `BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` environment variable value. However, the `BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` value is ignored during the artifacts upload process, and artifacts will be uploaded to the respective S3 compatible endpoint.
{: class="responsive-table"}

You can set these environment variables from a variety of places. Exporting them
from an [environment hook](/docs/agent/v3/hooks#job-lifecycle-hooks) defined in
your [agent `hooks-path` directory](/docs/agent/v3/hooks#hook-locations-agent-hooks)
ensures they are applied to all jobs:

```bash
export BUILDKITE_ARTIFACT_UPLOAD_DESTINATION="s3://name-of-your-s3-bucket/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID"
export BUILDKITE_S3_DEFAULT_REGION="eu-central-1" # default: us-east-1
```

### Uploading artifacts to multiple AWS S3 buckets in different regions

To upload artifacts to multiple AWS S3 buckets in different regions within a single pipeline, configure the `BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` and `BUILDKITE_S3_DEFAULT_REGION` environment variables at the step level. Defining these variables per step ensures that each upload uses the correct bucket and region. For example, one step can target a bucket in `us-east-1`, while another targets a bucket in `eu-central-1`:

```bash
steps:
  - label: "Upload to us-east-1 bucket"
    command:
      - echo "hello world" > test1.txt
      - buildkite-agent artifact upload test1.txt
    env:
      BUILDKITE_S3_DEFAULT_REGION: "us-east-1"
      BUILDKITE_ARTIFACT_UPLOAD_DESTINATION: "s3://my-bucket-east/"

  - label: "Upload to eu-central-1 bucket"
    command:
      - echo "hello world" > test2.txt
      - buildkite-agent artifact upload test2.txt
    env:
      BUILDKITE_S3_DEFAULT_REGION: "eu-central-1"
      BUILDKITE_ARTIFACT_UPLOAD_DESTINATION: "s3://my-bucket-central/"
```

### IAM permissions

Make sure your agent instances have the following IAM policy to
read and write objects in the bucket, for example:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:GetObjectVersionAcl",
                "s3:ListBucket",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:PutObjectVersionAcl"
            ],
            "Resource": [
               "arn\:aws\:s3:::my-s3-bucket",
               "arn\:aws\:s3:::my-s3-bucket/*"
            ]
        }
    ]
}
```

If you are using the Elastic CI Stack for AWS, provide your bucket name in the
`ArtifactsBucket` template parameter for an appropriate IAM policy to be
included in the instance's IAM role.

### Credentials

`buildkite-agent artifact upload` will use the first available AWS credentials
from the following locations:

- Buildkite environment variables, `BUILDKITE_S3_ACCESS_KEY_ID`, `BUILDKITE_S3_SECRET_ACCESS_KEY`, `BUILDKITE_S3_SESSION_TOKEN`
- AWS environment variables, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
- Web Identity environment variables, `AWS_ROLE_ARN`, `AWS_ROLE_SESSION_NAME`, `AWS_WEB_IDENTITY_TOKEN_FILE`
- EC2 or ECS role, your EC2 instance or ECS task's IAM Role

If your agents are running on an AWS EC2 Instance, adding the
policy above to the instance's [IAM Role](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) and using the instance profile credentials is the
most secure option as there are no long lived credentials to manage.

If your agents are running outside of AWS, or you're unable to use an instance
profile, you can export
[long lived credentials](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
belonging to an IAM user using one of the environment variable groups listed
above. See the [Managing pipeline secrets](/docs/pipelines/security/secrets/managing)
documentation for how to securely set up these environment variables.

### Access control

By default the agent will create objects with the [`public-read` ACL](https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl). This allows the artifact links in the
Buildkite web interface to show the S3 object directly in the browser. You can
set this to `private` instead, exporting a value for the `BUILDKITE_S3_ACL`
environment variable:

```bash
export BUILDKITE_S3_ACL="private"
```

If you set your S3 ACL to `private` you won't be able to click through to the
artifacts in the Buildkite web interface. You can use an authenticating S3 proxy
such as [aws-s3-proxy](https://github.com/pottava/aws-s3-proxy) to provide web
access protected by HTTP Basic authentication, which will allow you to view
embedded assets such as HTML pages with images. To set the access URL for your
artifacts, export a value for the `BUILDKITE_S3_ACCESS_URL` environment
variable:

```bash
export BUILDKITE_S3_ACCESS_URL="https://buildkite-artifacts.example.com/"
```

## Using your private Google Cloud bucket

You can configure the `buildkite-agent artifact` command to store artifacts in
your private Google Cloud Storage bucket. For instructions for how to set this
up, see our [Google Cloud installation guide](/docs/agent/v3/gcloud#uploading-artifacts-to-google-cloud-storage).

## Using your Artifactory instance

You can configure the `buildkite-agent artifact` command to store artifacts in
Artifactory. For instructions for how to set this up, see our
[Artifactory guide](/docs/pipelines/integrations/artifacts-and-packages/artifactory).

## Using your private Azure Blob container

You can configure the `buildkite-agent artifact` command to store artifacts in
your private [Azure Blob Storage container](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction).
Support for uploading artifacts to Azure Blob Storage was added in
[Agent v3.53.0](https://github.com/buildkite/agent/releases/tag/v3.53.0).

### Preparation

Firstly, make sure that each agent has access to Azure credentials.
[By default](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity#readme-defaultazurecredential),
these can be provided using:

- Azure environment variables such as `AZURE_CLIENT_ID`.
- Loaded by a Kubernetes workload identity hook.
- Loaded on a host with Azure Managed Identity enabled.
- Loaded from a user logged in with the Azure CLI.

You can also use an account key or connection string by setting one of these
environment variables:

```shell
# To use an account key:
export BUILDKITE_AZURE_BLOB_ACCESS_KEY='...'

# To use a connection string:
export BUILDKITE_AZURE_BLOB_CONNECTION_STRING='...'
```

Since these can contain access credentials, they are
[redacted from job logs by default](/docs/pipelines/configure/managing-log-output#redacted-environment-variables).

Make sure you have a valid storage account name and container. These can be
created with the Azure web console or Azure CLI.

Make sure the Azure principal for the Azure credential has a role assignment
that permits reading and writing to the container, for example,
[Storage Blob Data Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor).

### Configuration

Configure the agent to target your container by exporting the
`BUILDKITE_ARTIFACT_UPLOAD_DESTINATION` environment variable using an
[environment agent hook](/docs/agent/v3/hooks) (this can not be set using the
Buildkite web interface, API, or during pipeline upload). For example:

```shell
export BUILDKITE_ARTIFACT_UPLOAD_DESTINATION="https://mystorageaccountname.blob.core.windows.net/my-container/$BUILDKITE_PIPELINE_ID/$BUILDKITE_BUILD_ID/$BUILDKITE_JOB_ID"
```

Alternatively, when running `buildkite-agent artifact upload` or `buildkite-agent artifact
download`, you can specify the full upload destination in the form:

```
https://[storageaccountname].blob.core.windows.net/[container]/[path]
```

### Usage

If you have not [explicitly enabled anonymous public access](https://learn.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure?tabs=portal)
to data in your container, you won't have automatic access to your artifacts
through the links in the Buildkite web interface.

To generate SAS (shared access signatures) as part of each artifact URL, which
allow temporary access to your artifacts, you will need to set a token duration
as well as use a shared key for the credential:

```shell
# Provide a token duration; SAS URLs will expire after this length of time.
export BUILDKITE_AZURE_BLOB_SAS_TOKEN_DURATION=1h

# Generating SAS tokens requires an account key.
export BUILDKITE_AZURE_BLOB_ACCOUNT_KEY='...'
```
