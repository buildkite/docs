# Auto-create build triggers

By default, when a user creates a pipeline from a [GitHub repository](/docs/pipelines/source-control/github) on the **New Pipeline** page, Buildkite Pipelines enables two options in the **Build Triggers** section. One option triggers builds for code pushes, and the other triggers builds for pull requests. Buildkite Pipelines also creates a webhook on the GitHub repository.

Organization administrators can disable this default using the **Auto-create Build Triggers** setting. When disabled, new pipelines do not have build triggers enabled by default, and Buildkite Pipelines does not create a webhook. Users can still enable build triggers when they create a pipeline.

This setting only affects new pipelines created in the Buildkite interface. Creating a pipeline using the [REST API](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline) or [GraphQL API](/docs/apis/graphql-api) does not automatically create a webhook, regardless of this setting.

## Enable or disable auto-create build triggers

Only organization administrators can change this setting.

To access the setting:

1. Select **Settings** in the global navigation.
1. Select **Pipelines** > **Settings**.
1. Scroll to the **Auto-create Build Triggers** section.
1. Select **Enable Auto-create Build Triggers** or **Disable Auto-create Build Triggers**.

A confirmation dialog appears before the change is applied.

## Behavior

<table class="responsive-table">
<tbody>
  <tr>
    <th>Setting</th>
    <th>Effect on new pipelines</th>
  </tr>
  <tr>
    <td>Enabled (default)</td>
    <td>The <strong>Build Triggers</strong> section on the <strong>New Pipeline</strong> page defaults to two triggers: code pushed to a branch, and pull request opened. Buildkite Pipelines automatically creates a webhook on the connected repository.</td>
  </tr>
  <tr>
    <td>Disabled</td>
    <td>The <strong>Build Triggers</strong> section defaults to no triggers. Buildkite Pipelines does not create a webhook. Users can still enable build triggers when they create a pipeline.</td>
  </tr>
</tbody>
</table>

Existing pipelines and their webhooks are not affected by changes to this setting.

> 📘 Webhook limits
> If your organization creates many pipelines for the same GitHub repository, disabling this setting helps avoid reaching [GitHub's limit for repository webhooks](https://docs.github.com/en/webhooks/types-of-webhooks#repository-webhooks). You can still create a webhook for an individual pipeline by enabling build triggers when you create the pipeline.
