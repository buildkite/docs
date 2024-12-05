---
toc: false
---

# Database migration

## Introduction

In early 2024, Buildkite successfully completed an initial phase of work to begin migrating Buildkite Pipelines from using a single, very large PostgreSQL database, over to smaller, multiple database shards. Migrating customers from one large database to a series for smaller multiple shards allows Buildkite Pipelines' database access to be distributed across multiple entry points, thereby improving the performance of Buildkite Pipelines for all customers.

This initial phase of work involved migrating some of Buildkite's largest customers (accounting for approximately half of the load on this original single database) over to smaller multiple shards, which greatly improved overall Buildkite Pipelines performance.

From December 2024 to February 2025, Buildkite will migrate all remaining customers on this original single database over to smaller database shards. There will be migration windows from 07:00 – 09:00 UTC each Sunday during this period.

## The migration process

Within your organization's two hour migration window, _you can expect approximately 30 minutes of downtime_.

<%= image "stages.png", size: "#{2110/2}x#{1308/2}", class: "invertible", alt: "Diagram showing the stages of the migration process" %>

## Notifications and other communications

To prepare for this migration process, Buildkite Pipelines customers will receive advance notice by email about this database migration process for their Buildkite organization.

When the scheduled date for this process is nearing commencement, Buildkite will also send out email updates before, during, and after the migration process to all Buildkite organization administrators. A database migration settings page will also become available prior to this process commencing. Once available, you can use this page to nominate additional email addresses as recipients of these notifications. For example, you may choose to specify the email address for a [Slack](https://slack.com/intl/en-au/help/articles/206819278-Send-emails-to-Slack) or [Teams](https://support.microsoft.com/en-au/office/send-an-email-to-a-channel-in-microsoft-teams-d91db004-d9d7-4a47-82e6-fb1b16dfd51e) channel, to surface automatic notifications to your organization.

In addition to automated updates, Buildkite will use these same email addresses for any further manual communications.

## Frequently asked questions

### Will I need to restart my agents after the downtime period?

No, your agents will automatically reconnect once the downtime is lifted for your Buildkite organization.

### What will happen to builds that are running at the start of the downtime period?

Any running builds will be canceled immediately before your organization's downtime begins.

### How can people in my Buildkite organization be updated on the status of the migration?

You can provide a list of email addresses for notifications related to this migration process on the database migration settings page, once it becomes available. These addresses, along with all Buildkite organization administrators, will receive email status updates about the migration process before it begins, once the downtime period begins, once this process ends, and when restoration of the remaining build history (referred to as "backfill" in the diagram above) is completed.

### How can Buildkite guarantee the integrity of my data during and after migration?

These migrations will use the same mechanisms that Buildkite utilized when migrating its largest customers over to smaller multiple database shards in early 2024. The process validates the migrated data at multiple stages, and is able to safely unwind the migration if any discrepancies in your data are detected.

### In case something unexpected occurs during the migration process, how can I reach a Buildkite engineer?

Buildkite will have dedicated staff on call during and after each migration window. If you experience any unexpected and time-sensitive events during or soon after the migration, please email support@buildkite.com.

### Who can I contact if I have any other questions?

Reach out to support@buildkite.com, or your organization contact.
