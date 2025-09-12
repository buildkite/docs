# Slack Workspace

The Slack Workspace integration lets you receive notifications in your [Slack](https://slack.com/) workspace. This integration supports:

- [Pipelines build notifications](/docs/pipelines/integrations/notifications/slack-workspace)
- [Test Engine Workflow Slack notification](/docs/test-engine/workflows/actions#send-slack-notification)

[Adding a **Slack Workspace** notification service](https://buildkite.com/organizations/-/services/slack_workspace/new) will authorize access for your entire Slack app for a given Slack workspace. You only need to set up this integration once per Slack workspace, after which, you can then configure notifications to be sent to any Slack channels or users.

> 📘
> Setting up a Workspace requires Buildkite organization admin access.

## Connect Slack workspace

1. Select **Settings** in the global navigation and select **Notification Services** in the left sidebar.

1. Select the **Add** button on **Slack Workspace**.

    <%= image "buildkite-add-slack-workspace.png", width: 1458/2, height: 142/2, alt: "Screenshot of the 'Add' button for adding a Slack workspace service to Buildkite" %>

1. Select the **Add to Slack** button:

    <%= image "buildkite-add-to-slack-workspace.png", width: 1458/2, height: 358/2, alt: "Screenshot of 'Add Slack workspace service' screen on Buildkite. It shows an 'Add to Slack workspace' button" %>

    This action redirects you to Slack.

1. Log in to Slack and grant Buildkite permission to post across your workspace.

1. After granting access, you can then configure [Pipeline build notifications](/docs/pipelines/integrations/notifications/slack-workspace) and [Test Engine Workflow Slack notifications](/docs/test-engine/workflows/actions#send-slack-notification).

## Privacy policy

For details on how Buildkite handles your information, please see Buildkite's [Privacy Policy](https://buildkite.com/about/legal/privacy-policy/).
