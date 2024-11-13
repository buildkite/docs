# Slack Workspace

The [Slack Workspace](https://slack.com/) Notification Service in Buildkite lets you receive notifications about your builds and jobs in your Slack workspace.

Configuring a Slack Workspace notification service will authorize access for your entire Slack app. You can then configure notifications using YAML to be sent to any Slack channels.

Setting up a Workspace requires Buildkite organization admin access.

## Adding a workspace notification service

<%= image "buildkite-add-slack-workspace.png", width: 1458/2, height: 142/2, alt: "Screenshot of the 'Add' button for adding a Slack workspace service to Buildkite" %>

Click the **Add to Slack** button:

<%= image "buildkite-add-to-slack-workspace.png", width: 1458/2, height: 358/2, alt: "Screenshot of 'Add Slack workspace service' screen on Buildkite. It shows an 'Add to Slack workspace' button" %>

This will take you to Slack. Log in, and grant Buildkite the ability to post across your workspace. Once you have granted access, you can then use the `notify` attribute to edit the YAML of your pipelines and [configure notifications](/docs/pipelines/notifications).

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#general"
        - "buildkite-community#announcements"
```

## Conditional notifications

Use the `notify` YAML attribute in your `pipeline.yml` file to configure conditional notifications.

See the [Slack channel message](/docs/pipelines/notifications) section of the Notifications guide for the configuration information.

#### Slack Privacy Policy
For more details, please checkout the [Slack Marketplace Privacy Policy](https://api.slack.com/slack-marketplace/guidelines#privacy)
