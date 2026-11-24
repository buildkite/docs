# Spend alerts

Spend alerts notify your organization's billing contacts and show an in-product banner when the estimated next invoice reaches a threshold you set. Spend alerts don't limit spending, stop usage, or prevent further charges.

> 📘 Pro plan feature
> Spend alerts are available to organizations on a monthly Pro plan that renews automatically. Legacy Buildkite Pipelines Pro plans are not supported.

## Set up a spend alert

You need billing administration permissions to configure a spend alert.

To set up a spend alert:

1. Select **Settings** > **Billing**.
1. In the **Spend Alert** row, select **Set spend alert**.
1. Select **Enable spend alert**.
1. Enter an **Invoice threshold (USD)**.
1. **Optional:** select **Add my email to billing contacts**.
1. Select **Save spend alert**.

To change the threshold or disable the alert, select **Manage spend alert** in the **Spend Alert** row.

## How spend alerts work

When the estimate reaches the threshold, billing contacts receive an email and billing administrators see a banner. Buildkite sends one alert email per billing period. If no billing contact is configured when the threshold is first reached, no email is sent for that billing period, even if you add a contact later.

Invoice estimates are based on usage reported so far and can be delayed. The estimate shown when an alert is sent may differ from the final invoice.
