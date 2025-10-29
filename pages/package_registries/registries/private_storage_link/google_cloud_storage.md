# Google Cloud Storage

This page details on how to link your own Google Cloud Storage (GCS) bucket to Buildkite Package Registries, through a [private storage link](/docs/package-registries/registries/private-storage-link).

By default, Buildkite Package Registries provides its own storage (called *Buildkite storage*). However, linking your own GCS bucket to Package Registries lets you:

- Keep packages and artifacts close to your geographical region for faster downloads.
- Retain full sovereignty over your packages and artifacts, while Buildkite continues to manage their metadata and indexing.

## Google Cloud's Workload Identity Federation feature

Each time Buildkite Package Registries uploads, downloads, or signs an object, the Buildkite platform presents its own OIDC token to Google Cloud's [Security Token Service](https://cloud.google.com/iam/docs/reference/sts/rest) (STS). The STS swaps this OIDC token for a short-lived access token representing your configured Google Cloud service account. This exchange is part of Google Cloud's [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) feature, and allows Package Registries to perform its required actions inside your GCS bucket without the need for any storage of long-lived credentials.

Key security benefits of Workload Identity Federation:

- No long-lived [service account keys](https://cloud.google.com/iam/docs/service-account-creds#key-types)—tokens are generated when they're required and expire automatically.

- Least-privilege access—Buildkite Package Registries only requires these Google Cloud Identity and Access Management (IAM) roles:
    * `roles/storage.bucketViewer` on the GCS bucket, to allow Package Registries to read the bucket's metadata.
    * `roles/storage.objectUser` on the GCS bucket to allow Package Registries to create, read, update, delete, and tag objects.
    * `roles/iam.serviceAccountTokenCreator` on the Google Cloud service account so it can create signed URLs.
You can audit or revoke these at any time.

- Full audit history—every token exchange and object access is recorded in Google Cloud service's audit logs.

## Before you start

Before you begin, you'll need a GCS bucket in a Google Cloud project that Buildkite can access.

Learn more about:

- Google Cloud Storage from its main [Cloud Storage](https://cloud.google.com/storage) page.

- How to create a GCS bucket from Google's [Create a bucket](https://cloud.google.com/storage/docs/creating-buckets) guide.
    * As part of creating your GCS bucket, learn more about the [requirements for naming your bucket](https://cloud.google.com/storage/docs/naming-buckets), especially for creating ones with globally-unique names.

- How to keep your GCS bucket private by default from Google's [Public access prevention](https://cloud.google.com/storage/docs/public-access-prevention) guide.

- How to protect again accidental object deletion from Google's [Object Versioning](https://cloud.google.com/storage/docs/object-versioning) guide.

Once you have a bucket, the Buildkite wizard will guide you through:

1. **Creating (or selecting) a service account** for Buildkite to impersonate.
1. **Creating a Workload Identity _Pool_ and _Provider_**.
1. **Granting IAM roles** to wire everything together.

## Link your private GCS bucket to Buildkite Package Registries

To link your private Google Cloud Storage (GCS) bucket to Package Registries:

1. As a [Buildkite organization administrator](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions), select **Settings** in the global navigation to open the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Add private storage link** to start the private storage configuration process.

1. On the **Provide your storage's details** (page) > **Step 1: Select your storage provider**, select **GCS**.

1. In **Step 2: Create or locate your Google Cloud bucket**, select **Open Google Cloud** to open the list of GCS buckets in your Google Cloud account, to either retrieve your existing empty GCS bucket, or create a new one if you [haven't already done so](#before-you-start).

    **Notes:**
    * If you are already familiar with using Google Cloud Storage and need to create a new GCS bucket, expand the **Create a new bucket** section for quick instructions to start this process.
    * Ensure you are in the correct Google Cloud _organization_ and _project_ in which to create your GCS bucket.
    * For the fastest outcome, you can also copy the command line interface (CLI) code snippet and modify its following values before pasting the modified code snippet into your [Cloud Shell Terminal](https://cloud.google.com/storage/docs/discover-object-storage-gcloud) and submitting it:
        - `BUCKET`: the name of your new GCS bucket, for example, `my-gcs-bucket`.
        - `--location`: A location that's geographically closest to your current location, or the location closest to where this bucket's packages will most frequently be accessed from.

1. Back on the Buildkite interface, in **Step 3: Enter your Google Cloud bucket details**, specify the **Bucket name** (for example, `my-gcs-bucket`) for your GCS bucket configured in the previous step, then select **Continue**.

1. On the **Connect Buildkite to Google** page, you'll be configuring a [Google Cloud (GC) service account](https://cloud.google.com/iam/docs/service-account-overview) and [Workload Identity Pool and Provider (WIPP)](https://cloud.google.com/iam/docs/workload-identity-federation#providers) using the CLI code snippets on this page, which you can modify if required and paste into your [Cloud Shell Terminal](https://cloud.google.com/storage/docs/discover-object-storage-gcloud).
    * To create a new GC service account and WIPP, copy the **Create New** CLI code snippet and if required, modify its following **Setup** values before pasting the modified code snippet into your Cloud Shell Terminal and submitting it:
        - `SERVICE_ACCOUNT_NAME`: The name of your GC service account, which appears before the `@` symbol of your resulting GC service account's email address.
        - `POOL_ID`: The ID for your [workload identity pool](https://cloud.google.com/iam/docs/workload-identity-federation#pools), which must be a unique value for both active and deleted pools.
        - `PROVIDER_ID`: The ID for your [workload identity pool provider](https://cloud.google.com/iam/docs/workload-identity-federation#providers).
    * To find an existing GC service account and WIPP:
        1. Scroll down the page and expand the **Find Existing** section.
        1. Copy this CLI code snippet and if necessary, modify its `POOL_ID` and `PROVIDER_ID` values to those for the WIPP you want to use.
        1. Paste this modified code snippet into your Cloud Shell Terminal and submit it.

1. From your Cloud Shell Terminal output:
    * If you created a new GC service account and WIPP:
        1. Copy the **Service account created** value (from the Cloud Shell Terminal output, for example, `buildkite-storage-link@my-google-cloud-project.iam.gserviceaccount.com`), and paste it into the **Service account email** field on the **Connect Buildkite to Google** page of the Buildkite interface. This email address has the format<br/>
        `service-account-name@google-cloud-project-name.iam.gserviceaccount.com`.
        1. Copy the **Workload Identity Provider** value (from the Cloud Shell Terminal output, for example, `projects/123456789012/locations/global/workloadIdentityPools/bk-pool/providers/buildkite`), and paste it into the **Workload Identity Provider (full resource name)** field on the **Connect Buildkite to Google** page of the Buildkite interface. This resource name has the format<br/>
        `projects/project-id/locations/global/workloadIdentityPools/pool-id/providers/provider-id`.
    * If you are using an existing GC service account and WIPP:
        1. Copy the relevant **EMAIL** value (from the Cloud Shell Terminal output, for example `buildkite-storage-link@my-google-cloud-project.iam.gserviceaccount.com`), and paste it into the **Service account email** field on the **Connect Buildkite to Google** page of the Buildkite interface.
        1. Copy the relevant **Workload Identity Provider resource name** value (from the Cloud Shell Terminal output, for example, `projects/123456789012/locations/global/workloadIdentityPools/bk-pool/providers/buildkite`), and paste it into the **Workload Identity Provider (full resource name)** field on the **Connect Buildkite to Google** page of the Buildkite interface.

1. Select **Next**.

1. On the next **Connect Buildkite to Google** page's **Allow Buildkite to impersonate service account** section of the Buildkite interface, copy and paste this CLI code snippet into your [Cloud Shell Terminal](https://cloud.google.com/storage/docs/discover-object-storage-gcloud) and submit it. This allows the Buildkite platform to impersonate your GC service account.

1. In the next **Grant bucket access to the service account** section of the Buildkite interface, copy and paste this CLI code snippet into your [Cloud Shell Terminal](https://cloud.google.com/storage/docs/discover-object-storage-gcloud) and submit it. This grants your GC service account the `roles/storage.objectUser` and `roles/storage.bucketViewer` roles on your bucket so the Buildkite platform can manage package objects and read bucket metadata.

1. Select **Run diagnostic**. Buildkite uploads, downloads, and tags a test object to confirm it can:
    * publish (`PUT`)
    * download (`GET`)
    * generate a signed URL (`signBlob`)
    * tag with metadata (to allow lifecycle rules to delete)
    * delete (`DELETE`)

1. When all tests pass, select **Create Private Storage Link** to finish.

You're returned to the **Private Storage Link** page where you can:

- [Set the default Buildkite Package Registries storage for your organization](/docs/package-registries/registries/private-storage-link#set-the-default-buildkite-package-registries-storage).
- [Choose storage per registry](/docs/package-registries/registries/manage#update-a-source-registry-configure-registry-storage).

## Deleting packages

Buildkite does **not** delete objects straight away. When a package is removed it:

- Adds a metadata tag of `buildkite:deleted=<ISO8601_timestamp>`.
- Sets the object’s `customTime` field to the same timestamp.

| Metadata key       | Value (UTC) |
|--------------------|-------------|
| `buildkite:deleted`| ISO 8601 timestamp |

Create a [Lifecycle rule](https://cloud.google.com/storage/docs/lifecycle) that removes objects a set number of days after their `customTime`. For example, to purge 30 days after deletion:

```json
{
  "rule": [
    {
      "action": { "type": "Delete" },
      "condition": { "daysSinceCustomTime": 30 }
    }
  ]
}
```
