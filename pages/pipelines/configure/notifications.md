# Triggering notifications

The `notify` attribute allows you to trigger build notifications to different services. You can also choose to conditionally send notifications based on pipeline events like build state.

Add notifications to your pipeline with the `notify` attribute. This sits at the same level as `steps` in your pipeline YAML.

For example, to send a notification email every time a build is created:

```yaml
steps:
  - command: "tests.sh"

notify:
  - email: "dev@acmeinc.com"
```
{: codeblock-file="pipeline.yml"}

Available notification types:

* [Email](#email): Send an email to the specified email address.
* [Basecamp](#basecamp-campfire-message): Post a message to a Basecamp Campfire. Requires a Basecamp Chatbot to be configured in your Basecamp organization.
* [Slack](#slack-channel-and-direct-messages): Post a message to the specified Slack Channel. Requires a Slack Workspace or individual Slack notification services to be enabled for each channel.
* [Webhooks](#webhooks): Send a notification to the specified webhook URL.
* [PagerDuty](#pagerduty-change-events)

These types of notifications are available at the following levels.

<table>
<thead>
  <tr><th>Build</th><th>Step</th></tr>
</thead>
<tbody>
  <tr>
    <td>Slack</td>
    <td>Slack</td>
  </tr>
  <tr>
    <td>Email</td>
    <td></td>
  </tr>
  <tr>
    <td>Basecamp</td>
    <td></td>
  </tr>
  <tr>
    <td>Webhook</td>
    <td></td>
  </tr>
  <tr>
    <td>PagerDuty</td>
    <td></td>
  </tr>
</table>

## Conditional notifications

To only trigger notifications under certain conditions, add the `if` attribute.

For example, the following email notification will only be triggered if the build passes:

```yaml
steps:
  - command: "tests.sh"

notify:
  - email: "dev@acmeinc.com"
    if: build.state == "passed"
```
{: codeblock-file="pipeline.yml"}

See [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables) for more conditional variables that can be used in the `if` attribute.

> 🚧
> To trigger conditional notifications to a Slack channel, you will first need to configure [Conditional notifications for Slack](/docs/pipelines/integrations/other/slack#conditional-notifications).

## Email

Add an email notification to your pipeline using the `email` attribute of the `notify` YAML block:

```yaml
notify:
  - email: "dev@acmeinc.com"
```
{: codeblock-file="pipeline.yml"}

You can only send email notifications on entire pipeline [events](/docs/apis/webhooks#events), specifically upon `build.failing` and `build.finished`.

Restrict notifications to finished builds by adding a [conditional](#conditional-notifications):

```yaml
notify:
  - email: "dev@acmeinc.com"
    if: build.state != "failing"
```
{: codeblock-file="pipeline.yml"}


The `email` attribute accepts a single email address as a string. To send notifications to more than one address, add each address as a separate email notification attribute:

```yaml
steps:
  - command: "tests.sh"

notify:
  - email: "dev@acmeinc.com"
  - email: "sre@acmeinc.com"
  - email: "qa@acmeinc.com"
```
{: codeblock-file="pipeline.yml"}

## Basecamp Campfire message

To send notifications to a Basecamp Campfire, you'll need to set up a chatbot in Basecamp as well as adding the notification to your `pipeline.yml` file. Basecamp admin permission is required to setup your chatbot.

> 🚧
> Campfire messages can only be sent using Basecamp 3.</p>

1. Add a [chatbot](https://m.signalvnoise.com/new-in-basecamp-3-chatbots/) to the Basecamp project or team that you'll be sending notifications to.
1. Set up your chatbot with a name and an optional URL. If you'd like to include an image, you can find the Buildkite logo in our [Brand assets](https://buildkite.com/brand-assets).
1. On the next page of the chatbot setup, copy the URL that Basecamp provides in the `curl` code snippet
1. Add a Basecamp notification to your pipeline using the `basecamp_campfire` attribute of the `notify` YAML block and the URL copied from your Basecamp chatbot:

```yaml
steps:
  - command: "tests.sh"

notify:
  - basecamp_campfire: "https://3.basecamp.com/1234567/integrations/qwertyuiop/buckets/1234567/chats/1234567/lines"
```
{: codeblock-file="pipeline.yml"}

The `basecamp_campfire` attribute accepts a single URL as a string.

Basecamp notifications happen at the following [events](/docs/apis/webhooks#events), unless you restrict them using [conditionals](/docs/pipelines/configure/notifications#conditional-notifications):

* `build created`
* `build started`
* `build blocked`
* `build finished`
* `build skipped`

## Slack channel and direct messages

You can set notifications:

* On step status and other non-build events, by extending your Slack or Slack Workspace notification service with the `notify` attribute in your `pipeline.yml`.
* On build status events in the Buildkite interface, by using your Slack notification service's **Build state filtering** settings.

Before adding a `notify` attribute to your `pipeline.yml`, ensure a Buildkite organization admin has set up either the [Slack Workspace](/docs/pipelines/integrations/other/slack-workspace) notification service (a once-off configuration for each workspace), or the required [Slack](/docs/pipelines/integrations/other/slack) notification services, to send notifications to a channel or a user. Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan can also select the [**Manage Notifications Services**](https://buildkite.com/organizations/~/security/pipelines) checkbox to allow their users to create, edit, or delete notification services.

* The _Slack Workspace_ notification service requires a once-off configuration (only one per Slack workspace) in Buildkite, and then allows you to notify specific Slack channels or users, or both, directly within relevant pipeline steps.

* The _Slack_ notification service requires you to first configure one or more of these services for a channel or user, along with the pipelines, branches and build states that these channels or users receive notifications for. Once configured, your pipelines will generate automated notifications whenever the conditions in these notification services are met. You can also use the `notify` attribute in your `pipeline.yml` file for more fine grained control, by mentioning specific channels and users in these attributes, as long as Slack notification services have been created for these channels and users. If you mention any channels or users in a pipeline `notify` attribute for whom a Slack notification service has not yet been configured, the notification will not be sent. For a simplified configuration experience, use the [Slack Workspace](/docs/pipelines/integrations/other/slack-workspace) notification service instead.

Learn more about these different [Slack Workspace](/docs/pipelines/integrations/other/slack-workspace) and [Slack](/docs/pipelines/integrations/other/slack) notification services within [Other integrations](/docs/pipelines/integrations).

Once a Slack channel or workspace has been configured in your organization, add a Slack notification to your pipeline using the `slack` attribute of the `notify` YAML block.

> 🚧
> When using only a channel name, you must specify it in quotes. Otherwise, the `#` will cause the channel name to be treated as a comment.
> When using an individual notification service, rather than a workspace, if you rename or modify the Slack channel for which the integration was set up, for example if you change it from public to private, you need to set up a new integration.

### Notify a channel in all workspaces

You can notify a channel in all workspaces by providing the channel name in the `pipeline.yml`.

Build-level notifications to the `#general` channel of all configured workspaces:

```yaml
steps:
  - command: "tests.sh"

notify:
  - slack: "#general"
```
{: codeblock-file="pipeline.yml"}

Step-level notifications to the `#general` channel of all configured workspaces:

```yaml
steps:
  - label: "Example Test - pass"
    command: echo "Hello!"
    notify:
      - slack: "#general"
```
{: codeblock-file="pipeline.yml"}

> 📘 Step-level vs build-level notifications
> A step-level notify step will ignore the requirements of a build-level notification. If a build-level notification condition is that it runs only on `main`, a step-level notification without branch conditionals will run on all branches.

### Notify a user in all workspaces

You can notify a user in all workspaces configured through your Slack or Slack Workspace notification services by providing their username or user ID, respectively, in the `pipeline.yml`.

Build-level notifications to user `@someuser` in all workspaces configured through your [Slack notification services](/docs/pipelines/integrations/other/slack). For example:

```yaml
notify:
  - slack: "@someuser"
```
{: codeblock-file="pipeline.yml"}

or:

```yaml
notify:
  - slack:
      channels: ["@someuser"]
```

or:

```yaml
notify:
  - slack:
      channels:
        - "@someuser"
```

When using the [Slack Workspace notification service](/docs/pipelines/integrations/other/slack-workspace), specify their user ID instead of the `@someuser` syntax. For example:

```yaml
notify:
  - slack: "U12AB3C456D"
```
{: codeblock-file="pipeline.yml"}

or:

```yaml
notify:
  - slack:
      channels: ["U12AB3C456D"]
```

or:

```yaml
notify:
  - slack:
      channels:
        - "U12AB3C456D"
```

Step-level notifications to user `@someuser` in all workspaces through configured your Slack notification services:

```yaml
steps:
  - label: "Example Test - pass"
    command: echo "Hello!"
    notify:
      - slack: "@someuser"
```
{: codeblock-file="pipeline.yml"}

When using the Slack Workspace notification service, specify their user ID (for example, `U12AB3C456D`) instead of the `@someuser` syntax.

> 📘
> Unlike Slack notification service notifications, which are sent directly to the user's Slack account, the Slack Workspace notification service sends notifications to the user's "Workspace name Builds" app in Slack, where "Workspace name" is the name of the Slack workspace configured for the notification service.

### Notify a channel in one workspace

You can notify one particular workspace and channel or workspace and user by specifying the workspace name.

Build-level notifications:

```yaml
steps:
  - command: "tests.sh"

notify:
  # Notify channel
  - slack: "buildkite-community#general"
  # Notify user - this no longer appears to work
  - slack: "buildkite-community@someuser"
```
{: codeblock-file="pipeline.yml"}

Step-level notifications:

```yaml
steps:
  - label: "Example Test - pass"
    command: echo "Hello!"
    notify:
      # Notify channel
      - slack: "buildkite-community#general"
      # Notify user - this no longer appears to work
      - slack: "buildkite-community@someuser"
```
{: codeblock-file="pipeline.yml"}

### Notify multiple teams and channels

You can specify multiple teams and channels by listing them in the `channels` attribute.

Build-level notifications:

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#sre"
        - "buildkite-community#announcements"
        - "buildkite-team#monitoring"
        - "#general"
```
{: codeblock-file="pipeline.yml"}

Step-level notifications:

```yaml
steps:
  - label: "Example Test - pass"
    command: echo "Hello!"
    notify:
      - slack:
          channels:
            - "buildkite-community#sre"
            - "buildkite-community#announcements"
            - "buildkite-team#monitoring"
            - "#general"
```
{: codeblock-file="pipeline.yml"}

### Custom messages

You can define a custom message to send in the notification using the `message` attribute.

Build-level notifications:

```yaml
notify:
  - slack:
      channels:
        - "buildkite-community#sre"
      message: "SRE related information here..."
  - slack:
      channels:
        - "buildkite-community#announcements"
      message: "General announcement for the team here..."
```
{: codeblock-file="pipeline.yml"}

Step-level notifications:

```yaml
steps:
  - label: "Example Test - pass"
    command: echo "Hello!"
    notify:
      - slack:
          channels:
            - "buildkite-community#sre"
          message: "SRE related information here..."
      - slack:
          channels:
            - "buildkite-community#announcements"
          message: "General announcement for the team here..."
```
{: codeblock-file="pipeline.yml"}

Be aware that unlike [sending a specific user a notification in all workspaces](#slack-channel-and-direct-messages-notify-a-user-in-all-workspaces) about a pipeline run, at either the build or step level, it is not possible to directly send a user custom messages. However, [mentioning a user within custom messages](#slack-channel-and-direct-messages-custom-messages-with-user-mentions) is supported.

### Custom messages with user mentions

To mention a specific user in a custom message within a notification, use the `<@user-id>` annotation, substituting `userid` with the Slack user ID of the person to mention. See the [Slack documentation on mentioning users](https://api.slack.com/reference/surfaces/formatting#mentioning-users) for more details, including how to find a particular user's user ID. You can even mention user groups using the `<!subteam^$subteam-id>` annotation (where the first `subteam` is literal text)! See the [Slack documentation on mentioning user groups](https://api.slack.com/reference/surfaces/formatting#mentioning-groups) for more information.

Build-level notifications:

```yaml
notify:
  - slack:
      channels:
        - "#general"
      message: "This message will ping the user with ID U024BE7LH <@U024BE7LH>!"
```
{: codeblock-file="pipeline.yml"}

Step-level notifications:

```yaml
steps:
  - label: "Slack mention"
    command: echo "Sending a notification with a mention"
    notify:
      - slack:
          channels:
            - "#general"
          message: "This message will ping the group with ID SAZ94GDB8 <!subteam^SAZ94GDB8>!"
```
{: codeblock-file="pipeline.yml"}

> 🚧 Build creator environment variable
> You cannot substitute `user` with the build creator environment variable value.

### Conditional Slack notifications

You can also add [conditionals](/docs/pipelines/configure/notifications#conditional-notifications) to restrict the events on which notifications are sent:

```yaml
notify:
  - slack: "#general"
    if: build.state == "passed"
```
{: codeblock-file="pipeline.yml"}

See [Supported variables](/docs/pipelines/configure/conditionals#variable-and-syntax-reference-variables) for more conditional variables that can be used in the `if` attribute.

You are able to use `pipeline.started_passing` and `pipeline.started_failing` in your if statements if you are using the [Slack Workspace](/docs/pipelines/integrations/other/slack-workspace) integration.

Slack notifications happen at the following [event](/docs/apis/webhooks#events):

* `build finished`

An example to deliver slack notification when a step is soft-failed:

```yaml
steps:
  - command: exit -1
    soft_fail: true
    key: 'step1'
  - wait: ~
  - command: |
      if [ $(buildkite-agent step get "outcome" --step "step1") == "soft_failed" ]; then
         cat <<- YAML | buildkite-agent pipeline upload 
         steps:
           - label: "Notify slack about soft failed step"
             command: echo "Notifying slack about the soft_failed step"
             notify:
               - slack:
                   channels:
                     - "#general"
                   message: "Step1 has soft failed."
      YAML
      fi
```
{: codeblock-file="pipeline.yml"}

### Notify only on first failure

You can filter build notifications to only trigger on the first failure using `started_failing`.

Build-level notifications:

```yaml
notify:
  - slack: "#builds"
    if: build.branch == "main" && pipeline.started_failing
```

### Notify only on first pass

You can filter build notifications to only trigger on the first pass after a previous failed build using `started_passing`. `pipeline.started_passing` is the successor to `build.fixed`, which is deprecated, but remains available to use for backwards compatibility.

Build-level notifications:

```yaml
notify:
  - slack: "#builds"
    if: build.branch == "main" && pipeline.started_passing
```

### Notify on all failures and first successful pass

You can filter build notifications to only trigger when a pipeline:

* Starts failing
* Continues to fail
* Starts passing after a failure

Build-level notifications:

```yaml
notify:
  - slack: "#builds"
    if: build.state == failed || pipeline.started_passing
```

## Webhooks

Send a notification to a webhook URL from your pipeline using the `webhook` attribute of the `notify` YAML block:

```yaml
steps:
  - command: "tests.sh"

notify:
  - webhook: "https://webhook.site/32raf257-168b-5aca-9067-3b410g78c23a"
```
{: codeblock-file="pipeline.yml"}

The `webhook` attribute accepts a single webhook URL as a string. To send notifications to more than one endpoint, add each URL as a separate webhook attribute:

```yaml
steps:
  - command: "tests.sh"

notify:
  - webhook: "https://webhook.site/82n740x6-168b-5aca-9067-3b410g78c23a"
  - webhook: "https://webhook.site/32raf257-81b6-9067-5aca-78s09m6102b4"
  - webhook: "https://webhook.site/27f518bw-9067-5aca-b681-102c847j917z"
```
{: codeblock-file="pipeline.yml"}

Webhook notifications happen at the following [events](/docs/apis/webhooks#events), unless you restrict them using [conditionals](/docs/pipelines/configure/notifications#conditional-notifications):

* `build created`
* `build started`
* `build blocked`
* `build finished`

## PagerDuty change events

If you've set up a [PagerDuty integration](/docs/pipelines/integrations/other/pagerduty) you can send change events from your pipeline using the `pagerduty_change_event` attribute of the `notify` YAML block:

```yaml
steps:
  - command: "tests.sh"

notify:
  - pagerduty_change_event: "636d22Yourc0418Key3b49eee3e8"
```
{: codeblock-file="pipeline.yml"}

Email notifications happen at the following [event](/docs/apis/webhooks#events):

* `build finished`

Restrict notifications to passed builds by adding a [conditional](#conditional-notifications):

```yaml
steps:
  - command: "tests.sh"

notify:
  - pagerduty_change_event: "636d22Yourc0418Key3b49eee3e8"
    if: "build.state == 'passed'"
```
{: codeblock-file="pipeline.yml"}

## Build states

<%= render_markdown partial: 'pipelines/configure/build_states' %>

See the full [build states diagram](/docs/pipelines/configure/defining-steps#build-states) for more information on how builds transition between states.

## Job states

<%= render_markdown partial: 'pipelines/configure/job_states' %>

See the full [job states diagram](/docs/pipelines/configure/defining-steps#job-states) for more information on how jobs transition between states.
