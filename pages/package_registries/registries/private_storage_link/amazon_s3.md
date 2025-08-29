# Amazon S3 storage

This page provides details on how to link your own Amazon Web Services (AWS) Simple Storage Service (S3) bucket (or simply _Amazon S3_ bucket) to Buildkite Package Registries, through a [private storage link](/docs/package-registries/registries/private-storage-link).

By default, Buildkite Package Registries provides its own storage (known as _Buildkite storage_). However, linking your own Amazon S3 bucket to Package Registries lets you:

- Keep packages and artifacts close to your geographical region for faster downloads.
- Retain full sovereignty over your packages and artifacts, while Buildkite continues to manage their metadata and indexing.

Buildkite Package Registries uses [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) to provision its services within your private Amazon S3 storage.

## Before you start

Before you can start linking your private Amazon S3 storage to Buildkite Package Registries, you will need to have created your own empty Amazon S3 bucket.

Learn more about:

- Amazon S3 from the main [Amazon S3](https://aws.amazon.com/s3/) page, as well as the [Amazon S3 documentation](https://docs.aws.amazon.com/s3/).

- How to create an Amazon S3 bucket from Amazon's [Getting started with Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html) guide.

## Link your private Amazon S3 bucket to Buildkite Package Registries

To link your private Amazon S3 bucket to Package Registries:

1. As a [Buildkite organization administrator](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions), select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Add private storage link** start the private storage configuration process.

1. On the **Provide your storage's details** (page) > **Step 1: Select your storage provider**, select **AWS**.

1. In **Step 2: Create or locate your AWS S3 bucket**, select **Open AWS** to open the list of Amazon S3 buckets in your AWS account, to either retrieve your existing empty S3 bucket, or create a new one if you [haven't already done so](#before-you-start).

    **Note:** If you are not already signed in to your AWS account, you may need to navigate to the area listing your S3 buckets.

1. Back on the Buildkite interface, in **Step 3: Enter your AWS S3 bucket details**, specify the **Region** (for example, `us-east-1`) and **Bucket name** for your Amazon S3 bucket, then select **Continue**.

1. On the next **Authorize Buildkite in AWS** page, select **Launch Stack** to open the **Quick create stack** page in the AWS CloudFormation interface.

1. Ensure the the following fields are populated with the correct information:
    * **Template URL**—should be based on:<br/>`https://packages-public-assets.s3.amazonaws.com/cf-templates/byo-storage-bucket-policy-yyyymmdd.yml`
    * **Stack name**—`buildkitePackagesProvisioning` by default, but can be changed if another CloudFormation stack of the same name exists in your AWS account.
    * **BucketName**—the name of your Amazon S3 bucket (specified on the previous **Provide your bucket's details** page in Buildkite).
    * **KeyPrefix**—`{org.uuid}/`, where `{org.uuid}` is the UUID of your Buildkite organization.
    * **IAM role - optional**—specify any **IAM role** **name** or **ARN** to restrict the actions that can be performed on your CloudFormation stack in your S3 bucket.

1. Select **Create stack** to begin creating the CloudFormation stack for your Amazon S3 bucket.

1. Once the stack is created, return to the Buildkite interface and select **Run diagnostic** to verify that Buildkite Package Registries can do the following with packages in your Amazon S3 private storage:
    * publish (`PUT`)
    * download (`GET`)
    * tag (`PUT`)
    * delete (`DELETE`)

1. Once the **Diagnostic Result** page indicates a **Pass** for each of these diagnostic tests, select **Create Private Storage Link** to complete this linking process.

You are returned to the **Private Storage Link** page, where you can:

- [Set the default Buildkite Package Registries storage for your Buildkite organization](/docs/package-registries/registries/private-storage-link#set-the-default-buildkite-package-registries-storage).

- [Set the storage independently for each of your Buildkite registries](/docs/package-registries/registries/manage#update-a-source-registry-configure-registry-storage).

## Deleting packages

When deleting a package, Buildkite Package Registries does not delete the associated objects from your storage. Instead, Package Registries marks them for deletion using Amazon S3 _object tags_. Learn more about these object tags in Amazon's [Categorizing your storage using tags](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-tagging.html) documentation.

An object tagged for deletion by Package Registries has the following key value pair:

| Key                 | Value            |
|---------------------|------------------|
| `buildkite:deleted` | Timestamp in UTC |

Set the expiration on objects from your Amazon S3 bucket by adding an [S3 Lifecycle configuration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-set-lifecycle-configuration-intro.html) that filters on these object tags. For example, to remove objects 30 days after they're tagged, you can implement the following rule:

```json
{
  "Rules": [
    {
      "ID": "BuildkiteDeleteExpired",
      "Status": "Enabled",
      "Filter": {
        "Tag": {
          "Key": "buildkite:deleted",
          "Value": "*"
        }
      },
      "Expiration": { "Days": 30 }
    }
  ]
}
```

Learn more about filter syntax in these lifecycle rules from Amazon's [Lifecycle configuration elements > Filter element](https://docs.aws.amazon.com/AmazonS3/latest/userguide/intro-lifecycle-rules.html#intro-lifecycle-rules-filter) documentation.
