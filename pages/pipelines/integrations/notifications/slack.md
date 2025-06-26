# Slack

The [Slack](https://slack.com/) notification service in Buildkite lets you receive notifications about your builds and jobs in your Slack workspace.

Configuring a Slack notification service will authorize access for a required channel or user. By default, notifications will be sent to all Slack channels and users you've [added and configured as separate Slack notification services](#adding-a-notification-service) through the Buildkite interface.

Setting up a notification service requires Buildkite organization admin access.

> 📘
> You can use the [Slack Workspace](/docs/pipelines/integrations/notifications/slack-workspace) notification service to set up Slack notifications as a once-off process for each workspace, after which, you can then configure notifications within your YAML pipelines to be sent to any Slack channels or users.

## Adding a notification service

In your [Buildkite organization's **Notification Services** settings](https://buildkite.com/organizations/-/services), add a Slack notification service:

<%= image "buildkite-add-slack.png", width: 1458/2, height: 142/2, alt: "Screenshot of the 'Add' button for adding a Slack service to Buildkite" %>

Click the **Add to Slack** button:

<%= image "buildkite-add-to-slack.png", width: 1458/2, height: 358/2, alt: "Screenshot of 'Add Slack Service' screen on Buildkite. It shows an 'Add to Slack' button, as well as the option to switch to a custom Webhook URL." %>

Once logged in to Slack, choose a workspace, and grant Buildkite the ability to post in your chosen channel or user:

<%= image "buildkite-slack-oauth-screen.png", width: 1458/2, height: 1101/2, alt: "Screenshot of Slack's OAuth prompt, with Buildkite requesting access to your Slack workspace. It shows that Buildkite needs to know some information about you and your workspace, and asks you to choose a channel for Buildkite to post in." %>

Once you have granted access to your chosen channel or user in your Slack workspace, use the following fields to configure when automated Slack notifications are sent:

- **Description** to give this notification service a name.
- **Message theme** to choose how the notifications should be displayed.
- **Pipelines** to choose which pipelines are allowed to send notifications.
- **Branch filtering** to specify [patterns for branches](/docs/pipelines/configure/workflows/branch-configuration#branch-pattern-examples) (each separated by a space), whose builds will trigger when notifications can be sent.
- **Build state filtering** to choose the conditions for which build states send notifications.

<%= image "buildkite-slack-connected.png", width: 1458/2, height: 1540/2, alt: "Screenshot of Buildkite Slack Notification Settings, requesting a description, your choice of text or emoji message themes, which pipelines and branches to include, and which build states should trigger a notification" %>

> 🚧
> There is a default maximum number of 50 Slack notification services that can be added to your Buildkite organization. If you are an Enterprise customer and need more Slack notification services than this limit, please contact support@buildkite.com. Alternatively, you can use a [Slack Workspace](/docs/pipelines/integrations/notifications/slack-workspace) notification service, which only requires you to configure a single service for your Slack workspace.

Once your Slack notification services have been configured, notifications will automatically be sent at the pipeline level, but not on the outcomes of individual steps.

The **Choose notifications to send > When a build passes > After a failure ("Fixed")** option ensures you're notified when a build next passes after the selected **When a build is** states.

> 🚧
> If you're also using the [`notify` YAML attribute](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages) in your pipelines for more fine grained control over your Slack notifications, ensure you've selected the **Only Some Pipelines...** option, and have excluded these pipelines from receiving the automatic notifications (that is, leave these pipelines' checkboxes clear).

## Changing channels and users

Once a Slack notification service has been [added](#adding-a-notification-service), its Slack channel, user and workspace cannot be changed. To post to a different channel, user or workspace, you'll need to add a new Slack notification service. Alternatively, you can use the [Slack Workspace](/docs/pipelines/integrations/notifications/slack-workspace) notification service to set up Slack notifications as a once-off process for each workspace, after which, you can then configure notifications within your YAML pipelines to be sent to any Slack channels or users.

## Conditional notifications

By default, notifications are sent to all configured Slack channels. For more control over when each channel receives notifications, use the `notify` YAML attribute in your `pipeline.yml` file.

See the [Slack channel message](/docs/pipelines/configure/notifications#slack-channel-and-direct-messages) section of the Notifications guide for the configuration information.

## Upgrading a legacy Slack service

Slack stopped accepting notifications from legacy Buildkite services on January 10th, 2020.

If you have Slack set up with a legacy service or are no longer receiving notifications, add a new Slack notification service in your [Buildkite organization's **Notification Services** settings](https://buildkite.com/organizations/-/services).

### Identify where your existing services post notifications

Compare the webhook URLs from your Buildkite notification service with your Slack integration to find your existing notification settings.

Finding your Buildkite webhook URL: Click on the Slack notification service in Buildkite, the webhook URL will be listed here.

Finding your Slack integration's webhook URL:

1. In your Slack workspace's App Directory, click the **Manage** button and find the Buildkite app.
1. Click through the Buildkite app, then click the pencil button to edit your configuration.
1. The webhook URL will be listed under **Integration Settings**.

### Confirm which pipelines, and which events, are posted

Once you've found the matching Buildkite service and Slack app, confirm where and what you're posting to Slack. Take note of the events and pipelines so that you can set up a new notification service.

### Create a new Slack notification service which posts

Using the instructions above, [add a new Buildkite notification service](/docs/pipelines/integrations/notifications/slack#adding-a-notification-service) with the same settings as the legacy integration.

## Privacy policy

For details on how Buildkite handles your information, please see Buildkite's [Privacy Policy](https://buildkite.com/about/legal/privacy-policy/).
