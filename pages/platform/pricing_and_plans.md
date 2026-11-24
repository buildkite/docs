# Pricing and plans

Buildkite offers Free, Pro, and Enterprise plans. Plans differ in available features, usage limits, and support.

## Available plans

Buildkite offers the following plans:

- **Free**: For individual developers and small teams.
- **Pro**: For growing teams that need more capacity and features.
- **Enterprise**: For organizations that require advanced security, compliance, and dedicated support.

Compare current features, inclusions, and rates on the [Buildkite pricing page](https://buildkite.com/pricing/). Legacy plans, such as Personal, can have different inclusions and retention limits.

To find out which plan your organization is on or to manage your subscription, select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

## Usage and limits

Each plan has default [service quotas](/docs/platform/limits) that define usage limits across the Buildkite platform. To check your organization's actual limits as an administrator, select [**Organization Settings**](https://buildkite.com/organizations/~/settings) > **Quotas** to open **Service Quotas**.

For how artifact storage and transfer usage in Buildkite-managed artifact storage is calculated and billed, see [Artifacts billing](/docs/platform/artifact-storage-and-transfer-billing).

To get notified when your estimated next invoice reaches a threshold you choose, set up a [spend alert](/docs/platform/spend-alerts).

## Usage overview

Organizations with an active All Access Trial see an **Overview** tab on the [**Usage** page](https://buildkite.com/organizations/~/usage). This tab summarizes how your organization has explored Buildkite so far, and what else is available on your plan.

The **Overview** tab shows:

- The current usage period.
- The days remaining in the trial once the countdown period begins.
- Feature cards grouped into explored and unexplored sections, with a utilization indicator showing how many available features your organization has tried.

Select a feature card to go to that feature.

### Plan limits for Free plan organizations

Organizations on the Free plan without an active trial can see an **Overview** tab showing their usage against the limits included in their plan, grouped by product, for the current usage period.

- Limits with measurable usage, except the user limit, show a progress indicator and how much usage remains before the limit is reached. The user limit shows the current user count and the plan limit.
- Limits that can't be measured against usage, such as concurrent job limits, show the limit only.
- A **Need More?** prompt links to **Billing** to choose a different plan.

### Plan usage for Pro plan organizations

Pro plan organizations that are eligible for a [spend alert](/docs/platform/spend-alerts) can also see an **Overview** tab, showing usage against their plan's inclusions, grouped by product, for the current billing cycle.

The **Overview** tab shows:

- The current billing cycle and the days remaining.
- A table of usage against each plan inclusion, grouped by product, with a progress indicator and the amount over or remaining.

This is the same usage shown on the **Billing** > **Usage & spend** page, without prices or other billing details.

Organizations without an active trial or either plan-specific usage view are taken to the **Platform** tab when they select **Usage**.

## Viewing prepaid inclusions

Managed Enterprise customers with the inclusions report enabled can compare prepaid entitlements with current usage in **Billing**. The report helps you estimate overage charges before invoicing.

To access the inclusions report, you need billing administration permissions for your organization. To view it:

1. Select **Settings** in the global navigation, then select **Billing**.
1. Select the **Inclusions** tab.

The **Inclusions** page shows your included entitlements versus actual usage for the current subscription period. The page displays the subscription period dates and the number of days remaining.

### Monthly resources

The **Monthly resources** section shows metered resources calculated as a three-month rolling average. Columns include usage for each of the last three calendar months, the three-month average, the included amount per month, the amount over the included threshold, the unit price, and an estimated overage charge.

Overage above the included amount is invoiceable.

### Subscription period resources

The **Subscription period resources** section shows resources tracked over the full subscription period. Columns include current usage, the included amount, the amount over the included threshold, the unit price, and an estimated overage charge.

Overage above the included amount is invoiceable.

For hosted agent minutes, you can toggle the view between **vCPU** and **instance shape** using the links above the table.

Resources tracked across both sections include active users, concurrent agents, hosted agent minutes, test executions, artifact storage, artifact downloads, and package storage and transfer. Overage costs shown are estimates.
