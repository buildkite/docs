# Auto-create build triggers

By default, when a user creates a new pipeline in Buildkite Pipelines using the new pipeline form and connects a GitHub repository, the form automatically enables two build triggers. One trigger is for code pushes, and the other is for pull requests. Buildkite Pipelines also creates a webhook on the GitHub repository.

Organization administrators can disable this default using the **Auto-create Build Triggers** setting. When disabled, new pipelines do not have build triggers enabled by default. No webhook is automatically created. Users can still manually enable build triggers for individual new pipelines when creating them.

This setting only affects new pipelines created through the Buildkite web UI. Pipeline creation using the REST or GraphQL APIs never auto-creates webhooks, regardless of this setting.

## Enable or disable auto-create build triggers

Only organization administrators can change this setting.

To access the setting:

1. Select **Settings** in the global navigation.
1. Select **Pipelines** > **Settings**.
1. Scroll to the **Auto-create Build Triggers** section.
1. Select **Enable Auto-create Build Triggers** or **Disable Auto-create Build Triggers**.

A confirmation dialog appears before the change is applied. The settings page records who made the change and when.

## Behavior

<table class="responsive-table">
<tbody>
  <tr>
    <th>Setting</th>
    <th>Effect on new pipelines</th>
  </tr>
  <tr>
    <td>Enabled (default)</td>
    <td>The <strong>Build Triggers</strong> section on the new pipeline form defaults to 2 triggers (code pushed to a branch, pull request opened). A webhook is created on the connected repository automatically.</td>
  </tr>
  <tr>
    <td>Disabled</td>
    <td>The <strong>Build Triggers</strong> section defaults to 0 triggers. No webhook is created automatically. Users can still enable build triggers manually during pipeline creation.</td>
  </tr>
</tbody>
</table>

Existing pipelines and their webhooks are not affected by changes to this setting.

> 📘 Webhook limits
> If your organization creates many pipelines against the same GitHub repository, disabling this setting helps avoid hitting GitHub's per-repository webhook limit. You can still create webhooks explicitly for individual pipelines by enabling build triggers during pipeline creation.
