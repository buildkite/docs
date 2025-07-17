# Private storage link – Google Cloud Storage (GCS)

This page guides you through connecting Google Cloud Storage (GCS) to Buildkite Package Registries. These processes can only be performed by [Buildkite organization administrators](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions). For a high-level overview of Private Storage Links, see the [Overview page](/docs/package-registries/private-storage-link).

By default, Buildkite Package Registries provides its own storage (called *Buildkite storage*). Linking your own GCS bucket lets you:

- Keep packages close to your geographical region for faster downloads.
- Avoid cross-cloud egress costs.
- Retain full sovereignty over your data while Buildkite continues to manage metadata and indexing.

## Securely connected with Workload Identity Federation (WIF)

Each time Buildkite uploads, downloads, or signs a package object it presents its own OIDC identity token to Google Cloud’s [Security Token Service](https://cloud.google.com/iam/docs/reference/sts/rest). STS swaps that token for a short-lived access token on the service account you specify. This exchange is [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation) and allows Buildkite to act inside your bucket without storing any long-lived credentials.

Key security benefits:

- No long-lived service-account keys — tokens are minted just-in-time and expire automatically.
- Least-privilege access — Buildkite needs only these IAM roles:
  + `roles/storage.bucketViewer` on the bucket so Buildkite can read bucket metadata.
  + `roles/storage.objectAdmin` on the bucket to create, read, update, and delete package objects.
  + `roles/iam.serviceAccountTokenCreator` on the service account so it can mint signed URLs.
You can audit or revoke these at any time.
- Full audit history — every token exchange and object access is recorded in Cloud Audit Logs.

## Before you start

Before you begin, you’ll need a GCS bucket in a Google Cloud project that Buildkite can access.

Learn more about:

- [Google Cloud Storage](https://cloud.google.com/storage) – product overview.
- [Creating a bucket](https://cloud.google.com/storage/docs/creating-buckets) – step-by-step guide.
- [Bucket naming requirements](https://cloud.google.com/storage/docs/naming-buckets) – rules for globally-unique names.
- [Public access prevention](https://cloud.google.com/storage/docs/public-access-prevention) – keep data private by default.
- [Object versioning](https://cloud.google.com/storage/docs/object-versioning) – optional protection against accidental deletes.

Once you have a bucket, the Buildkite wizard will guide you through:

1. **Creating (or selecting) a service account** for Buildkite to impersonate.
1. **Creating a Workload Identity _Pool_ and _Provider_**.
1. **Granting IAM roles** to wire everything together.

## Link your private storage to Buildkite Package Registries

To link your private Google Cloud Storage (GCS) bucket to Buildkite Package Registries:

1. Select **Settings** in the global navigation to open the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link**.

1. Click **Add private storage link** to start the wizard.

1. On the **Provide your storage's details** page select **GCS**, then:
    + Click **Open Google Cloud** to locate an existing bucket or create a new one.
    + Enter the **Bucket name** (for example `my-bucket`).

1. Click **Continue**.

1. On the **Connect Buildkite to Google Cloud** page, follow the instructions to provide:
    + **Service account email** – `registry-access@my-project.iam.gserviceaccount.com`.
    + **Workload Identity provider resource** – `projects/<project-number>/locations/global/workloadIdentityPools/<pool>/providers/<provider>`.

1. On the **Authorize Buildkite** page, complete two bindings by following the instructions:
    + **Impersonation** — add the `roles/iam.workloadIdentityUser` role so Buildkite can impersonate the service account.
    + **Bucket access** — grant the service account `roles/storage.objectAdmin` and `roles/storage.bucketViewer` on your bucket so Buildkite can manage package objects and read bucket metadata.

1. Click **Run diagnostic**. Buildkite uploads, downloads, and tags a test object to confirm it can:
    + publish (`PUT`)
    + download (`GET`)
    + generate a signed URL (`signBlob`)
    + tag for deletion (`PATCH`)
    + delete (`DELETE`)

1. When all tests pass, click **Create Private Storage Link** to finish.

You're returned to the **Private Storage Link** page where you can:

- [Set the default Buildkite Package Registries storage for your organization](/docs/package-registries/private-storage-link#set-the-default-buildkite-package-registries-storage).
- [Choose storage per registry](/docs/package-registries/manage-registries#update-a-source-registry-configure-registry-storage).

## Set as default storage (optional)

Once at least one PSL exists you can change the organization’s default storage (this affects newly-created registries):

1. **Organization Settings > Packages > Private Storage Link**.
1. Click **Change** and select the `gs://…` link.

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
