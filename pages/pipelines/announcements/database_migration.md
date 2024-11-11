---
toc: false
---

# Database migration

## Introduction

Earlier in 2024, Buildkite completed the first phase of work to migrate Buildkite Pipelines from using a single, very large PostgreSQL database over to smaller multiple database shards. This work saw us smoothly migrate customers accounting for roughly half of the load on our systems, greatly increasing the headroom available on the original database.

From November 2024 to February 2025, Buildkite will be performing database migrations to move all customers who remain on the original database to new database shards. There will be migration windows from 07:00 – 09:00 UTC each Sunday during this period.

## The migration process

Within your organization's two hour migration window, _you can expect approximately 30 minutes of downtime_.

<%= image "stages.png", size: "#{2110/2}x#{1308/2}", class: "invertible", alt: "Diagram showing the stages of the migration process" %>

## Notifications and other communications

Buildkite will send email updates before, during, and after the migration process to all Buildkite organization administrators. Once it is available, you may also use the migration settings page to nominate additional email addresses to include as recipients of these notifications. For example, you may choose to specify the email address for a [Slack](https://slack.com/intl/en-au/help/articles/206819278-Send-emails-to-Slack) or [Teams](https://support.microsoft.com/en-au/office/send-an-email-to-a-channel-in-microsoft-teams-d91db004-d9d7-4a47-82e6-fb1b16dfd51e) channel, to surface automatic notifications to your organization.

In addition to automated updates, Buildkite will use these same email addresses for any further manual communications.

## Frequently asked questions

### Who can I contact if I have questions?

Reach out to support@buildkite.com, or your organization contact.

### Will you need to restart our agents after the downtime?

No, your agents will automatically reconnect once the downtime is lifted for your Buildkite organization.

### What will happen to builds that are running at the beginning of downtime?

Any running builds will be canceled immediately before your organization's downtime begins.

### In case something unexpected occurs during the migration, how can I reach a Buildkite engineer?

Buildkite will have dedicated staff on call during and after each migration window. If you experience any unexpected and time-sensitive events during or soon after the migration, please email support@buildkite.com.

### How can people in my Buildkite organization be updated on the status of the migration?

You can provide a list of email addresses for notifications related to this migration process on the settings page once this page is available. These addresses, along with all Buildkite organization administrators, will receive emails before the migration, once the downtime begins, once it ends, and once the backfill is completed.

### How does this database migration process benefit Buildkite?

Migrating customers from one large database to a series for smaller shards provides bulk-heading of load, mitigating the impact of noisy neighbors on the performance of our platform. While it is not a silver bullet for reliability, your Buildkite organization will be better protected from such incidents.

### How can Buildkite guarantee the integrity of your data during and after migration?

These migrations will utilize the same mechanisms that Buildkite used to migrate its largest customers smoothly over to shards at the start of the year. The process validates the migrated data at multiple stages, and is able to safely unwind the migration if any discrepancies in your data are detected.
