---
toc: false
---

# Slack notifications
You can receive notifications in your Slack workspace for the following events in Test Engine:

- When a [test's state](/docs/test-engine/glossary#test-state) changes.
- When a [label](/docs/test-engine/test-suites/labels) is added to or removed from a test.

> 📘
> Before configuring notifications, ensure your Slack workspace is [connected to your Buildkite organization](/docs/platform/integrations/slack-workspace).

## Configure a notification

To configure Slack notifications for your test suite:

1. Select **Test Suites** in the global navigation and select your test suite.

1. Select **Settings** and select **Notifications** tab.

1. Select the **Add** button on **Slack**.

1. Choose the **Slack Workspace** and specify the **Slack Channel** for notifications.

1. Select one or more of these **Events** to trigger notifications:
    * **Test state changed**
    * **Test label added**
    * **Test label removed**

1. If [test ownership](/docs/test-engine/test-suites/test-ownership) is configured, you can select one or more **Teams** to filter notifications to tests owned by those teams.

    **Notes:**
    * Selecting **No owner** will send notifications for tests without an owner.
    * If no teams are selected, notifications will be sent for all selected **Events**.

1. Select **Save** to apply your changes.
