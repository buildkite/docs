# Artifact retention

Artifact retention controls how long artifacts remain available after upload to Buildkite-managed storage. Organization administrators can choose a shorter retention period to reduce storage usage and charges.

The setting applies to every pipeline in your organization and is separate from [build retention](/docs/pipelines/configure/build-retention). No pipeline or agent configuration changes are needed.

## Retention periods

Available retention periods are 7, 30, or 90 days, depending on your plan. See [Buildkite plans](https://buildkite.com/pricing) for plan details. Unless you choose a shorter period, artifacts follow your plan's default retention period.

## Changing your retention period

Organization administrators on plans with a maximum retention period of 90 days or less can choose a shorter period:

1. Select **Settings** > **Pipelines** > **Storage**.
1. Choose a **Retention period**, then select **Save artifact retention**.

<%= image "artifact-retention-settings.png", width: 1740/2, height: 1060/2, alt: "Storage settings showing the artifact retention period and what happens when it changes" %>

Choose your plan's maximum to use its default retention period.

If Buildkite has set a fixed retention period for your organization, the **Storage** page is read-only. Contact support at support@buildkite.com to request a change.

Changes take effect at 00:00 UTC the following day and apply to existing and new artifacts. Retention is measured from each artifact's upload date:

- Shortening retention expires artifacts older than the new period when the change takes effect.
- Increasing retention keeps unexpired artifacts available for longer. Expired artifacts can't be downloaded or restored.

### Example

On October 19, you change retention from 30 days to 7 days. The change takes effect at 00:00 UTC on October 20:

- **Artifact A**, uploaded on October 10, is older than 7 days. It expires when the change takes effect and can no longer be downloaded.
- **Artifact B**, uploaded on October 18, is less than 7 days old. It remains available under the new 7-day retention period.

Expired artifacts no longer count toward storage usage or charges. Physical deletion from storage may happen later. See [Artifacts billing](/docs/platform/artifact-storage-and-transfer-billing) for usage calculations.

## Retaining artifacts for longer

To keep artifacts for longer, use [your own private Amazon S3 bucket](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket) or another [self-managed storage provider](/docs/pipelines/configure/artifacts#storage-providers-encryption-and-retention). You manage retention for artifacts stored there; Buildkite-managed retention periods don't apply.
