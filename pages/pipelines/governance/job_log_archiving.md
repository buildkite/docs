# Job log archiving

By default, Buildkite Pipelines stores job logs in Buildkite's own infrastructure. With private job log archiving, you can configure your own, private Amazon S3 bucket to store job logs, giving your Buildkite organization full control over where job log data resides.

> 📘 Enterprise plan feature and current limitations
> The private job log archiving feature is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.
> This feature currently only supports Amazon S3 buckets in the `us-east-1` region. Google Cloud Storage and Azure Blob Storage are not supported.

## How it works

When job log archiving is enabled, Buildkite Pipelines writes each job's log output as an object in your S3 bucket, and does not retain a copy. Logs are read from this location whenever users view them in the Buildkite dashboard or through the API.

## Configure private job log archiving

To configure job log archiving for your organization, you need to prepare an Amazon S3 bucket and then enable archiving in Buildkite.

### Prepare your Amazon S3 bucket

Your bucket must meet the following criteria:

- Be located in Amazon's `us-east-1` region (the only region currently supported).
- Have a policy allowing cross-account read and write access from Buildkite's AWS account `032379705303` (see the example bucket policy below).
- Use SSE-S3 for server-side encryption. SSE-KMS encryption is not supported.

Read and understand [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html), and implement modern S3 security features and configurations, such as (but not limited to):

- [Block public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) to prevent accidental misconfiguration leading to data exposure.
- [ACLs disabled with bucket owner enforced](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html) to ensure your AWS account owns the objects written by Buildkite Pipelines.
- [S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) to help recover objects from accidental deletion or overwrite.

You may also want to use [Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) to manage storage class and object expiry.

#### Bucket policy

Use a bucket dedicated to Buildkite Pipelines job logs, since Buildkite Pipelines writes at the bucket root. Attach a bucket policy granting the Buildkite AWS account (`032379705303`) read and write access. Replace the `my-bucket` placeholder with your Amazon S3 bucket name:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BuildkiteJobLogArchivingBucketAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn\:aws\:iam::032379705303:root"
            },
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn\:aws\:s3:::my-bucket"
        },
        {
            "Sid": "BuildkiteJobLogArchivingObjectAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn\:aws\:iam::032379705303:root"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": "arn\:aws\:s3:::my-bucket/*"
        }
    ]
}
```

#### Object naming

Buildkite Pipelines writes each job's log to your bucket using the following folder structure and file format. The format is not customizable:

```text
{ORGANIZATION_UUID}/{BUILDKITE_PIPELINE_ID}/{BUILDKITE_BUILD_ID}/{BUILDKITE_JOB_ID}.log
```

### Enable job log archiving

To enable job log archiving, contact Buildkite support at support@buildkite.com with your S3 bucket name and organization details. The support team will configure the archive location for your organization.

## Related pages

- [Build exports](/docs/pipelines/governance/build-exports) for exporting historical build data to your own storage.
- [Managing log output](/docs/pipelines/configure/managing-log-output) for controlling how job logs are displayed.
