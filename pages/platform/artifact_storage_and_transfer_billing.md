# Artifact storage and transfer billing

Buildkite Pipelines bills [artifact](/docs/pipelines/configure/artifacts) usage in Buildkite-managed artifact storage based on two measures:

- _Storage_ measures how much artifact data your Buildkite organization keeps over time.
- _Transfer_ measures how much artifact data is downloaded from Buildkite.

This page explains how each is calculated and how to track usage against your allowances.

Artifacts kept in a [self-managed storage provider](/docs/pipelines/configure/artifacts#storage-providers-encryption-and-retention), such as your own Amazon S3, Google Cloud Storage, or Azure Blob Storage bucket, are not billed by Buildkite. Your storage provider bills you directly for those artifacts, and you are responsible for their retention.

## How usage is charged

Each billing period includes an allowance for storage and for downloads. Usage above the allowance is charged at a per-unit overage rate. Uploading artifacts to Buildkite is not charged as transfer, so only downloads count towards the transfer allowance.

The worked examples on this page use the following figures to show how the calculation works:

- **Storage**: 1 TB-month (1,024 GB-months) included, then $0.05 per GB-month.
- **Transfer**: 10 TB (10,240 GB) of downloads included, then $0.10 per GB.

Storage and transfer are measured in whole gigabytes, with any fraction of a gigabyte rounded down and not counted. One GB is 1,024 MB (1,073,741,824 bytes), and one TB is 1,024 GB. Overage is charged only once usage passes the whole-gigabyte allowance. With the example figures, storage is first charged at 1,025 GB-months, and transfer is first charged at 10,241 GB.

> 📘 Example figures only
> The inclusions and overage rates above are examples used to show how the calculation works. Actual inclusions, overage rates, and retention periods vary by plan. You can find the values that apply to your organization on the [Buildkite pricing page](https://buildkite.com/pricing/), on your [**Usage** page](https://buildkite.com/organizations/~/usage), or by contacting the Buildkite sales team at sales@buildkite.com.

## How artifact storage is calculated

Storage is billed in _GB-days_, where one GB-day is one gigabyte kept for one day. Each day, Buildkite records how many bytes your organization is holding. The monthly total is the sum of those daily amounts. For example, holding 100 GB for 10 days is 1,000 GB-days, which is the same as holding 10 GB for 100 days.

A _day_ is a full UTC calendar day. Every upload and delete is bucketed by its UTC date, so the boundary is midnight UTC regardless of the user's timezone. Uploads are billed for a minimum of one day: an upload at 23:30 UTC counts toward that day's storage, and even if it's deleted immediately, the reduction only shows up the next day.

### From events to daily storage

Each day's storage is the artifacts uploaded minus those deleted, with one timing rule that affects the total:

- An upload counts on the day it happens.
- A delete counts on the next UTC day. Every artifact is therefore billed for at least one full day, even one that is uploaded and deleted on the same day.

The following worked example runs over one week, starting from empty storage.

Day | What happened                                        | Counted        | Storage held (GB)
--- | ---------------------------------------------------- | -------------- | -----------------
1   | Uploaded 400 GB                                      | +400           | 400
2   | Uploaded 600 GB                                      | +600           | 1,000
3   | Uploaded 300 GB                                      | +300           | 1,300
4   | Deleted 200 GB (takes effect on day 5)               | —              | 1,300
5   | Uploaded 100 GB, and the day-4 delete is reflected   | +100 −200      | 1,200
6   | Nothing                                              | —              | 1,200
7   | Nothing                                              | —              | 1,200
{: class="responsive-table"}

Adding up the storage held each day gives 7,600 GB-days for the week. The day-4 delete only lowers storage on day 5, because deletes are reflected the next day. If storage then holds steady at 1,200 GB for the remaining 23 days of a 30-day month, that adds another 27,600 GB-days, so the month totals 35,200 GB-days.

### From GB-days to the monthly charge

Dividing the month's GB-days by the number of days in the month gives _GB-months_, which is the average number of gigabytes held. GB-months are rounded down to a whole number, and storage is charged on that value. Using the 35,200 GB-days from the example above, across a 30-day month:

1. Sum every day of the month to get 35,200 GB-days.
1. Divide by the 30 days in the month to get 1,173.33 GB-months, then round down to 1,173 GB-months.
1. Subtract the example 1,024 GB-month allowance to get 149 GB-months, then apply the example $0.05 per GB-month overage rate: `149 × $0.05 = $7.45`.

> 📘 Deleting artifacts
> Because storage is summed over days, deleting an artifact lowers what you are billed going forward, but it does not refund the days the artifact was already stored.

## How artifact transfer is calculated

Transfer is the artifact data that moves out of storage when it is downloaded. Uploads are not counted.

Downloads are counted from the storage access logs. For each UTC day, using the same day boundary as storage, every download is totaled per organization and pipeline. Both full and partial downloads are counted, so the total captures every download, whether it is a complete object fetch, a byte-range request, or a download that is canceled partway through.

Downloads are charged on total gigabytes downloaded across the billing period. For example, an organization that downloads 12 TB (12,288 GB) in a month, against the example 10 TB (10,240 GB) allowance, has 2 TB (2,048 GB) over the allowance. At the example $0.10 per GB overage rate, that is `2,048 × $0.10 = $204.80`.

## Artifact retention

Artifacts are retained for a limited period that depends on your plan. After the retention period, artifacts are deleted and no longer count towards storage. For the retention period that applies to your organization, and other limits across the Buildkite platform, see [Limits](/docs/platform/limits).

## Viewing your usage

The [**Usage** page](https://buildkite.com/organizations/~/usage) shows your artifact storage and transfer usage, the allowances included in your plan, and the projected charges for any usage above those allowances. Reviewing usage during the billing period helps you estimate overage charges before they are invoiced.

For more detail on tracking prepaid entitlements against actual usage, see [Viewing prepaid inclusions](/docs/platform/pricing-and-plans#viewing-prepaid-inclusions).
