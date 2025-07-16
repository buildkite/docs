# Private Storage Link – Google Cloud Storage (GCS)

> **Audience** — Buildkite organization administrators.

This guide connects a **Google Cloud Storage (GCS)** bucket to Buildkite Package Registries. The flow mirrors the S3 instructions but uses Google-native IAM and Workload Identity Federation for stronger security.

<%# Hero graphic placeholder %>
<%= image "psl-gcs-overview.png", alt: "GCS Private Storage Link architecture" %>

## Why GCS PSL is different

| Feature | GCS | S3 |
| ------- | --- | --- |
| Workload Identity Federation | ✔︎ (no long-lived IAM keys) | ✖︎ |
| Signed downloads | V4 signed URLs generated on demand via **IAMCredentials signBlob** | CloudFront/S3 signed URLs |
| Object deletion tagging | _Coming soon_ | ✔︎ |

## Before you start

> **Terminology refresher** — *Workload Identity Federation (WIF)* lets an external OIDC identity (Buildkite) exchange a token for a short-lived Google Cloud access token **without** creating or storing service-account keys.

The high-level steps you need outside Buildkite are:

1. **Create a bucket** (or choose an existing one).
1. **Create a Workload Identity _Pool_ and _Provider_** that trusts your Buildkite organization’s OIDC issuer.
1. **Create (or select) a service account** for Buildkite to impersonate.
1. **Grant IAM roles** to wire everything together.

### Create the Workload Identity pool and provider

Replace `PROJECT_ID` and `ORG_UUID` with real values:

```bash
PROJECT_ID=my-project
ORG_UUID=123e4567-e89b-12d3-a456-426614174000   # find in Organization Settings → General
POOL_ID=buildkite-psl
PROVIDER_ID=buildkite-oidc

# Create the pool
 gcloud iam workload-identity-pools create $POOL_ID \
   --project=$PROJECT_ID --location=global \
   --display-name="Buildkite PSL"

# Create the OIDC provider within the pool
 gcloud iam workload-identity-pools providers create-oidc $PROVIDER_ID \
   --project=$PROJECT_ID --location=global --workload-identity-pool=$POOL_ID \
   --display-name="Buildkite OIDC" \
   --issuer-uri="https://idp.buildkite.com/$ORG_UUID" \
   --attribute-mapping="google.subject=assertion.sub" \
   --allowed-audiences="//iam.googleapis.com/*"

WIF_RESOURCE="projects/$(gcloud projects describe $PROJECT_ID --format=value(projectNumber))/locations/global/workloadIdentityPools/$POOL_ID/providers/$PROVIDER_ID"
```

The **issuer URI** is unique per organization (`https://idp.buildkite.com/<org_uuid>`). Buildkite’s IdP issues tokens where `sub` is `organization:<org_uuid>`, so the simple attribute mapping above works out of the box.

### Create or choose the bucket

```bash
gsutil mb -p $PROJECT_ID -c STANDARD -l us-central1 gs://my-bucket
# Optional hardening
gsutil uniformbucketlevelaccess set on gs://my-bucket
gsutil bucketpolicyonly set on gs://my-bucket
```

### Create the service account

```bash
gcloud iam service-accounts create registry-access \
  --project=$PROJECT_ID \
  --display-name="Buildkite Package Registry access"
SA_EMAIL=registry-access@$PROJECT_ID.iam.gserviceaccount.com
```

### Grant IAM roles

```bash
# Bucket access
 gcloud storage buckets add-iam-policy-binding gs://my-bucket \
   --member="serviceAccount:$SA_EMAIL" \
   --role="roles/storage.objectAdmin"

# Allow Buildkite (via WIF) to impersonate the service account
 for ROLE in roles/iam.workloadIdentityUser roles/iam.serviceAccountTokenCreator; do
   gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
     --member="principalSet://iam.googleapis.com/$WIF_RESOURCE/subjects/*" \
     --role="$ROLE"
 done
```

With the groundwork done, continue in the Buildkite UI.

1. **Bucket** — create or identify a GCS bucket in the project that will hold your packages.
2. **Service account** — create / choose a service account that will access the bucket.
3. **Workload Identity Federation provider** — Buildkite issues OIDC tokens; you must create a Workload Identity Pool + Provider that trusts `https://idp.buildkite.com`.
4. **IAM roles** — grant:
   * `roles/storage.objectAdmin` on the bucket to the *service account*.
   * `roles/iam.workloadIdentityUser` **and** `roles/iam.serviceAccountTokenCreator` on the service account to the *principal set* of your WIF provider.

> The *Token Creator* role lets Buildkite use **IAMCredentials signBlob** to mint short-lived signatures for download URLs without storing a private key.

## Link your GCS bucket

1. **Organization Settings > Packages > Private Storage Link > Add private storage link**.
1. Choose **Google Cloud Storage** and fill:
   * **Region** — drop-down list.
   * **Bucket name** — `my-bucket`.
1. Click **Continue**.
1. Provide:
   * **Service account email** — `registry-access@my-project.iam.gserviceaccount.com`.
   * **Workload Identity provider resource** — `projects/<project-number>/locations/global/workloadIdentityPools/<pool>/providers/<provider>`.
1. Follow the on-screen *Authorize Buildkite* commands, reproduced below for reference:

```bash
# Grant bucket access
BUCKET=my-bucket
SA=registry-access@my-project.iam.gserviceaccount.com
WIF="projects/123/locations/global/workloadIdentityPools/buildkite/providers/oidc"

gcloud storage buckets add-iam-policy-binding gs://$BUCKET \
  --member="serviceAccount:$SA" \
  --role="roles/storage.objectAdmin"

gcloud iam service-accounts add-iam-policy-binding $SA \
  --member="principalSet://iam.googleapis.com/$WIF/subjects/*" \
  --role="roles/iam.workloadIdentityUser"

gcloud iam service-accounts add-iam-policy-binding $SA \
  --member="principalSet://iam.googleapis.com/$WIF/subjects/*" \
  --role="roles/iam.serviceAccountTokenCreator"
```

1. Click **Run diagnostic**. Buildkite uploads and downloads a test object; tagging deletion is skipped.
1. When the diagnostic passes, click **Create Private Storage Link**.

## Signed downloads

When a client requests a package:

1. Buildkite creates a short-lived OIDC ID-token for the organization.
1. The token is exchanged via **Security Token Service** and **IAMCredentials** to impersonate the service account.
1. The process calls `signBlob` to generate a V4 signed URL.
1. The client downloads directly from `https://storage.googleapis.com/<bucket>/<object>` by using the signed URL.

<%# Placeholder – sequence diagram of signed download %>
<%= image "psl-gcs-signed-url-sequence.png", alt: "Signed-URL download sequence" %>

## Deleting packages

Until tagging support lands, Buildkite marks package metadata as deleted but **does not** modify the GCS object. Add [Lifecycle Rules](https://cloud.google.com/storage/docs/lifecycle) that expire objects under the prefix `org-uuid/*` after the desired retention period.

## Set as default storage (optional)

Same process as S3: **Organization Settings > Packages > Private Storage Link > Change** and select the `gs://…` link.
