# Build exports

> 📘 Enterprise feature
> Build exports is only available on an [Enterprise](https://buildkite.com/pricing) plan, which has a [build retention](/docs/pipelines/build-retention) period of 12 months.

If you need to retain build data beyond the [retention period](/docs/pipelines/build-retention) in your [Buildkite plan](https://buildkite.com/pricing), you can use the build exports feature.

Build exports enables you to configure your own S3 bucket for Buildkite to export your build data to.

If you do not configure an S3 bucket, the exported build data will be stored for 18 months by Buildkite in case you need it. You cannot access this build data using the Buildkite UI or API, but you can request them from us by contacting support.

## How it works
Builds older than the build retention limit will be automatically exported as JSON to the S3 bucket you have configured. If you haven't configured a build export bucket, Buildkite will store that build data as JSON in our own S3 bucket for a further 18 months in case you need it.

<%= image "build-exports-flow-chart.png", alt: "Simplified flow chart of the build exports process" %>

You are able to configure you own S3 bucket in the UI. See [Enabling build exports](#enabling-build-exports) below.

Buildkite exports each build as multiple gzipped JSON files which include the following data:

```
buildkite/build-exports/org={UUID}/date={YYYY-MM-DD}/pipeline={UUID}/build={UUID}/
    annotations.json.gz
    artifacts.json.gz
    build.json.gz
    step-uploads.json.gz
    jobs/
        job-{UUID}.json.gz
        job-{UUID}.log
```

The files will be stored in the following formats: [Annotations](https://buildkite.com/docs/apis/rest-api/annotations#list-annotations-for-a-build), [Artifacts](https://buildkite.com/docs/apis/rest-api/artifacts#list-artifacts-for-a-build), [Builds](https://buildkite.com/docs/apis/rest-api/builds#get-a-build) (but without `jobs` as they are stored in separate files), and Jobs (as would be embedded in a [Build via the REST API](https://buildkite.com/docs/apis/rest-api/builds#get-a-build)).


## Preparing your S3 bucket

+ Read and understand [Security best practices for Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html).
+ Your bucket must be located in Amazon's `us-east-1` region.
+ Your bucket must have a policy allowing cross-account access as described here and demonstrated in the example below¹.
  * Allow Buildkite's AWS account `032379705303` to `s3:GetBucketLocation`.
  * Allow Buildkite's AWS account `032379705303` to `s3:PutObject` keys matching `buildkite/build-exports/org=YOUR-BUILDKITE-ORGANIZATION-UUID/*`.
  * Do *not* allow AWS account `032379705303` to `s3:PutObject` keys outside that prefix.
+ Your bucket should use modern S3 security features and configurations, for example (but not limited to):
  * [Block public access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html) to prevent accidental misconfiguration leading to data exposure.
  * [ACLs disabled with bucket owner enforced](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html) to ensure your AWS account owns the objects written by Buildkite.
  * [Server-side data encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html) (`SSE-S3` is enabled by default but you may want to consider `SSE-KMS`).
  * [S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) to help recover objects from accidental deletion or overwrite.
+ You may want to use [Amazon S3 Lifecycle](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) to manage storage class and object expiry.

¹ Your S3 bucket policy should look like this, with `YOUR-BUCKET-NAME-HERE` and
`YOUR-BUILDKITE-ORGANIZATION-UUID` substituted with your details:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "BuildkiteGetBucketLocation",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn\:aws\:iam::032379705303:root"
            },
            "Action": "s3:GetBucketLocation",
            "Resource": "arn\:aws\:s3:::YOUR-BUCKET-NAME-HERE"
        },
        {
            "Sid": "BuildkitePutObject",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn\:aws\:iam::032379705303:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn\:aws\:s3:::YOUR-BUCKET-NAME-HERE/buildkite/build-exports/org=YOUR-BUILDKITE-ORGANIZATION-UUID/*"
        }
    ]
}
```

Your Buildkite Organization ID (UUID) can be found on the settings page described in the next section.

## Enabling build exports

To enable build exports:

1. Navigate to your [organization's pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In the _Export Build Data to S3_ section, enter your Amazon S3 bucket name to use.
1. Select _Enable Export_.
