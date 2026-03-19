# Job log archiving

> 📘 Enterprise plan feature
> Custom job log archiving is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

By default, Buildkite stores job logs in its own infrastructure. With job log archiving, organization administrators can configure a custom Amazon S3 bucket to store job logs, giving your organization full control over where job log data resides.

> 📘
> Job log archiving currently supports Amazon S3 buckets in the `us-east-1` region only. Google Cloud Storage and Azure Blob Storage are currently not supported.

## How it works

When job log archiving is enabled, Buildkite writes job logs to your specified S3 bucket instead of its default storage location. Each job's log output is stored as an object in your bucket, and Buildkite reads from this location when users view job logs in the Buildkite dashboard or through the API.

## Configure job log archiving

To configure job log archiving for your organization, you need to prepare an Amazon S3 bucket and then enable archiving in Buildkite.

### Prepare your Amazon S3 bucket

- Read and understand [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html).
- Your bucket must be located in Amazon's `us-east-1` region.
- Your bucket must have a policy allowing cross-account read and write access from Buildkite's AWS account `032379705303`.
- Your bucket should use modern S3 security features and configurations, for example (but not limited to):
    * [Block public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) to prevent accidental misconfiguration leading to data exposure.
    * [ACLs disabled with bucket owner enforced](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html) to ensure your AWS account owns the objects written by Buildkite.
    * [Server-side data encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html) (`SSE-S3` is enabled by default).
    * [S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) to help recover objects from accidental deletion or overwrite.
- You may want to use [Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) to manage storage class and object expiry.

### Enable job log archiving

To enable job log archiving, contact [Buildkite support](mailto:support@buildkite.com) with your S3 bucket name and organization details. The Buildkite team will configure the archive location for your organization.

## Related pages

- [Build exports](/docs/pipelines/governance/build-exports) for exporting historical build data to your own storage
- [Managing log output](/docs/pipelines/configure/managing-log-output) for controlling how job logs are displayed
