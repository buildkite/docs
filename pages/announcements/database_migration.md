---
toc: false
---

# Database migration

## Introduction

Earlier this year, Buildkite completed the first phase of our work to migrate our Pipeline product from a single, very large PostgreSQL database to multiple smaller database shards. This work saw us smoothly migrate customers accounting for roughly half of the load on our systems, greatly increasing the headroom available on the original database.

From November 2024 to February 2025, Buildkite will be performing database migrations to move all customers who remain on the original database to new database shards. There will be migration windows from 07:00 – 09:00 UTC each Sunday during this period.

## The migration process

Within your organization’s **two hour migration window, you can expect roughly 30 minutes of downtime**.

<%= image "stages.png", size: "#{2110/2}x#{1308/2}", class: "invertible", alt: "Diagram showing the stages of the migration process" %>

## Notifications and other communications

Buildkite will send email updates before, during, and after the migration process to all organization administrators. Once it is available, you may also use the migration settings page to nominate additional email addresses to include as recipients of these notifications. For example, you may choose to specify the email address for a Slack or Teams channel, to surface automatic notifications to your organization.

In addition to automated updates, we will use these same email addresses for any further manual communications.

## Frequently asked questions

### Who can I contact if I have questions?
Reach out to support@buildkite.com, or your organization contact.

### Will we need to restart our agents after the downtime?
No, your agents will automatically reconnect once the downtime is lifted for your organization.

### What will happen to builds that are running at the beginning of downtime?
Any running builds will be canceled immediately before your organization’s downtime begins.

### In the case of something unexpected occurring during the migration, how can I reach a Buildkite engineer?
We will have dedicated staff on call during and after each migration window. If you experience any unexpected and time-sensitive events during or soon after the migration, please email support@buildkite.com.

### How will we be updated on the status of the migration?
You will be able to provide a list of email addresses for notifications related to the migration on the settings page once it is available. These addresses, along with all organization admins, will receive emails before the migration, once the downtime begins, once it ends, and once the backfill is completed.

### How does data migration benefit us?
Migrating customers from one large database to a series for smaller shards provides bulk-heading of load, mitigating the impact of noisy neighbors on the performance of our platform. While it is not a silver bullet for reliability, your organization will be better protected from such incidents.

### How can Buildkite guarantee the integrity of our data during and after migration?
These migrations will utilize the same mechanisms with which Buildkite smoothly migrated our largest customers at the start of the year. The process validates the migrated data at multiple stages, and is able to safely unwind the migration if any discrepancies in the data are detected.
