# Job minutes

Each [Buildkite plan](https://buildkite.com/pricing) has job minute inclusions, which vary depending on the plan type and the number of users in your organization.

Job minutes are calculated as the total number of minutes run by all `command` jobs in a build. It is calculated per-second, starting from when the agent starts running the job, until the job has completed.

You can find the total job run time for a build on the bottom of the [build page](/docs/pipelines/dashboard-walkthrough#build-page), and your organization's [total usage](#usage-page) in Settings.

<%= image "minutes.png", width: 1530/2, height: 590/2, alt: "Total Job Run Time for a build" %>

Parallelism does not affect how job minutes are calculated, the following situations all use 10 jobs minutes:

* a build that has ten one-minute parallel jobs
* a build that has a single ten-minute job
* a build that has ten one-minute jobs that run consecutively

## Usage page

The [Usage page](https://buildkite.com/organizations/~/usage) is available on every Buildkite plan and shows a breakdown of job minutes and test executions for your organization.

The [Job minutes usage page](https://buildkite.com/organizations/~/usage/job_minutes) graphs the total job minute usage over the organization's billing periods. It includes a breakdown of usage by pipeline and a CSV download of usage over the period.

> 📘 Calculating job minutes usage
> We store job usage data in seconds but charge by summing all the usage and rounding down to the nearest minute. Please keep in mind that when displaying usage data per pipeline in the chart and CSV download, there may be minor discrepancies due to the rounding of each individual pipeline's usage.
