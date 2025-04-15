# Private storage link

This page provides details on how to link and configure your private Amazon Web Services (AWS) Simple Storage Service (S3) storage to Buildkite Package Registries within your Buildkite organization. These processes can only be performed by [Buildkite organization administrators](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions).

By default, Buildkite Package Registries provides its own storage (known as _Buildkite storage_) to house any packages, container images and modules stored in source registries. You can also link your own private AWS S3 bucket to Buildkite Package Registries, which allows you to:

- Manage Buildkite registry packages, container images and modules stored within your private AWS S3 bucket (that is, your _private storage_). Private storage:
    * Located closer to your geographical location may provide faster registry access.
    * Mitigates network transmission costs.

- Use Buildkite Package Registries' management and metadata-handling features to manage these files in registries within your private storage. While packages are stored in your own private storage, Buildkite still handles the indexing of these packages.

- Maintain control, ownership and sovereignty over the packages, container images and modules stored within your source registries managed by Buildkite Package Registries.

Buildkite Package Registries uses [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) to provision its services within your private AWS S3 storage.

Regardless of whether you choose to manage your packages in Buildkite storage or in your own storage through a private storage link:

- Both storage and bandwidth are metered in the same manner, with no differences in additional costs.
- Package management, indexing, and access are all routed through the Buildkite API.

The following diagram shows how your private storage link interfaces between the Buildkite Package Registries software-as-a-service (SaaS) _control plane_, consisting of the Buildkite Platform and your (the customer's) teams, operating in your own infrastructure.

<%= image "private-storage-link-overview.png", alt: "Shows how your private storage link fits between the SaaS platform and your own infrastructure" %>

where:

- CDN is content delivery network
- API / CLI is application programming interface / command line interface
- SSO & RBAC is single sign-on & role-based access control

## Before you start

Before you can start linking your private AWS S3 storage to Buildkite Package Registries, you will need to have created your own empty AWS S3 bucket.

Learn more about:

- AWS S3 from the main [Amazon S3](https://aws.amazon.com/s3/) page, as well as the [Amazon S3 documentation](https://docs.aws.amazon.com/s3/).

- How to create an S3 bucket from the [Amazon S3 documentation's Getting started](https://docs.aws.amazon.com/AmazonS3/latest/userguide/GetStartedWithS3.html) guide.

## Link your private storage to Buildkite Package Registries

To link your private AWS S3 storage to Buildkite Package Registries:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Add private storage link** to begin configuring your private storage for Buildkite Package Registries.

1. On the **Provide your storage's details** page, in **Step 2: Create or locate your AWS S3 bucket**, select **Open AWS** to open the list of S3 buckets in your AWS account, to either retrieve your existing empty S3 bucket, or create a new one if you [haven't already done so](#before-you-start).

    **Note:** If you are not already signed in to your AWS account, you may need to navigate to the area listing your S3 buckets.

1. Back on the Buildkite interface, in **Step 3: Enter your AWS S3 bucket details**, specify the **Region** (for example, `us-east-1`) and **Bucket** name for your AWS S3 bucket, then select **Continue**.

1. On the next **Authorize Buildkite in AWS** page, select **Launch Stack** to open the **Quick create stack** page in the AWS CloudFormation interface.

1. Ensure the the following fields are populated with the correct information:
    * **Template URL**—should be based on:<br/>`https://packages-public-assets.s3.amazonaws.com/cf-templates/byo-storage-bucket-policy-yyyymmdd.yml`
    * **Stack name**—`buildkitePackagesProvisioning` by default, but can be changed if another CloudFormation stack of the same name exists in your AWS account.
    * **BucketName**—the name of your AWS S3 bucket (specified on the previous **Provide your bucket's details** page in Buildkite).
    * **KeyPrefix**—`{org.uuid}/`, where `{org.uuid}` is the UUID of your Buildkite organization.
    * **IAM role - optional**—specify any **IAM role** **name** or **ARN** to restrict the actions that can be performed on your CloudFormation stack in your S3 bucket.

1. Select **Create stack** to begin creating the CloudFormation stack for your S3 bucket.

1. Once the stack is created, return to the Buildkite interface and select **Run diagnostic** to verify that Buildkite Package Registries can do the following with packages in your S3 private storage:
    * publish (`PUT`)
    * download (`GET`)
    * tag (`PUT`)
    * delete (`DELETE`)

1. Once the **Diagnostic Result** page indicates a **Pass** for each of these diagnostic tests, select **Create Private Storage Link** to complete this linking process.

You are returned to the **Private Storage Link** page, where you can:

- [Set the default Buildkite Package Registries storage for your Buildkite organization](#set-the-default-buildkite-package-registries-storage).

- [Set the storage independently for each of your Buildkite registries](/docs/package-registries/manage-registries#update-a-source-registry-configure-registry-storage).

## Set the default Buildkite Package Registries storage

By default, your Buildkite organization uses storage provided by Buildkite (known as **Buildkite-hosted storage**).

The _default storage_ is the storage used when a [new source registry is created](/docs/package-registries/manage-registries#create-a-source-registry).

Once you have [configured at least one other private storage link](#link-your-private-storage-to-buildkite-package-registries), you can change the default storage to one of these configured private storage configurations. To do this:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage beginning with **s3://...**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the default storage can also be reverted back to using **Buildkite-hosted storage**.

All [newly created source registries](/docs/package-registries/manage-registries#create-a-source-registry) will automatically use the default private storage location to house packages.

## Deleting packages

When deleting a package, Buildkite does not delete the associated objects from your storage. Instead, Buildkite marks them for deletion using [S3 object tags](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-tagging.html).

Objects tagged for deletion by Buildkite have the following key value pair:

| Key                 | Value            |
|---------------------|------------------|
| `buildkite:deleted` | Timestamp in UTC |

Expire objects from your bucket using an [S3 Lifecycle configuration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-set-lifecycle-configuration-intro.html) set up to filter tagged objects. Learn more about lifecycle rules filters in the [Lifecycle configuration elements > Filter element](https://docs.aws.amazon.com/AmazonS3/latest/userguide/intro-lifecycle-rules.html#intro-lifecycle-rules-filter) section of the [Amazon S3 documentation](https://docs.aws.amazon.com/s3/).
