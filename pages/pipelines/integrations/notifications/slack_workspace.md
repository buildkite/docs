# Slack Workspace

The Slack Workspace notification service in Buildkite lets you receive notifications about your builds in your [Slack](https://slack.com/) workspace.

## Configuring notifications
Before configuring notifications, ensure your Slack workspace is [connected to your Buildkite organization](/docs/platform/integrations/slack-workspace).
Once the Slack workspace is connected, you can then use the `notify` attribute in the YAML syntax of your pipelines to [configure specific notifications](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages).

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#general"
        - "buildkite-community#announcements"
```

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
