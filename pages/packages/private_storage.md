# Link private storage

This page provides details on how to link your private Amazon Web Services (AWS) Simple Storage Service (S3) storage to Buildkite Packages within your Buildkite organization. This process can only be conducted by [Buildkite organization administrators](/docs/packages/permissions#manage-teams-and-permissions-organization-level-permissions).

By default, Buildkite Packages provides its own storage to house any packages, container images and modules stored in registries. You can also link your own private AWS S3 bucket to Buildkite Packages, which allows you to:

- Manage Buildkite registry packages, container images and modules stored within your private AWS S3 bucket (that is, your _private storage_). Private storage located closer to your geographical location may provide faster registry access.
- Use Buildkite Package's management and metadata-handling features to manage these files in registries within your private storage.
- Maintain control, ownership and sovereignty over the packages, container images and modules stored within your Buildkite Packages registries.

Buildkite Packages uses [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) to provision its services within your private AWS S3 storage.

To link your private AWS S3 storage to Buildkite Packages:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Add private storage link** to begin configuring your private storage for Buildkite Packages.

1. Read through the process summary and select **Let's go!**

1. On the **Provide your bucket's details** page, specify the **Region** (for example, `us-east-1`) and **Bucket** name for your AWS S3 bucket, followed by selecting **Next**.

1. On the **Authorize Buildkite in AWS** page, select **Launch Stack** to open the **Quick create stack** page in the AWS CloudFormation interface.

1. Ensure the the following fields are populated with the correct information:
    * **Template URL**—this value should be the same as the **Amazon S3 URL** specified on the **Authorize Buildkite in AWS** page.
    * **Stack name**—`buildkitePackagesProvisioning` by default, but can be changed if another CloudFormation stack of the same name exists in your AWS account.
    * **YourBucketName**—the name of your AWS S3 bucket (specified on the previous **Provide your bucket's details** page in Buildkite).
    * **YourBucketPath**—`/` by default.
    * **IAM role - optional**—specify any **IAM role** **name** or **ARN** to restrict the actions that can be performed on your CloudFormation stack in your S3 bucket.

1. Select **Create stack** to begin creating the CloudFormation stack for your S3 bucket.

1. Once the stack is created, return to the Buildkite interface and select **Run diagnostic** to verify that Buildkite Packages can publish (`PUT`), download (`GET`) and delete (`DELETE`) packages to and from your S3 private storage.

1. Once the **Diagnostic Result** page indicates a **Pass** for each of these three tests, select **Create Private Storage Link** complete this linking process.

1. On the **Private Storage Link** package, select **Change** to switch from using **Buildkite-hosted storage** to your private storage (beginning with **s3://...**).

All subsequent packages published to any registries already configured in your Buildkite organization will be stored in your private storage.
