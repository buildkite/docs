# Slack Workspace

The Slack Workspace notification service in Buildkite lets you receive notifications about your builds in your [Slack](https://slack.com/) workspace.

[Adding a **Slack Workspace** notification service](https://buildkite.com/organizations/-/services/slack_workspace/new) will authorize access for your entire Slack app for a given Slack workspace. You only need to set up this integration once per Slack workspace, after which, you can then configure notifications within your YAML pipelines to be sent to any Slack channels or users.

Setting up a Workspace requires Buildkite organization admin access.

## Adding a workspace notification service

<%= image "buildkite-add-slack-workspace.png", width: 1458/2, height: 142/2, alt: "Screenshot of the 'Add' button for adding a Slack workspace service to Buildkite" %>

Click the **Add to Slack** button:

<%= image "buildkite-add-to-slack-workspace.png", width: 1458/2, height: 358/2, alt: "Screenshot of 'Add Slack workspace service' screen on Buildkite. It shows an 'Add to Slack workspace' button" %>

This will take you to Slack. Log in, and grant Buildkite the ability to post across your workspace. Once you have granted access, you can then use the `notify` attribute in the YAML syntax of your pipelines to [configure specific notifications](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages).

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#general"
        - "buildkite-community#announcements"
```

## Configuring notifications


### Mentions in build notifications

Mentions occur when there's a corresponding Slack account using one of the emails connected to the Buildkite account that triggered a build.

Provide the Slack user ID, which you can access via User > More options > Copy member ID.

```yaml
notify:
  - slack: "U123ABC456"
```

### Notify in private channels

You can notify individuals in private channels by inviting the Buildkite Builds Slack App into the channel with `/add Buildkite Builds`.

Build-level notifications:

```yaml
notify:
  # Notify private channel
  - slack: "buildkite-community#private-channel"
```

## Conditional notifications

Use the `notify` YAML attribute in your `pipeline.yml` file to configure conditional notifications.

See the [Slack channel message](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages) section of the Notifications guide for the configuration information.

### Conditional notifications with pipeline states

You can control conditional notifications using `pipeline.started_passing` and `pipeline.started_failing` in the `if` attribute of the `notify` key of your `pipeline.yml`. With the previous Slack integration this was done in the UI.

See [Conditional Slack notifications](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages-conditional-slack-notifications) for more examples.

#### Privacy policy

For more details on how we handle your information, please check our [Privacy Policy](https://buildkite.com/about/legal/privacy-policy/).
