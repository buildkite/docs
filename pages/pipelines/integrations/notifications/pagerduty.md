# PagerDuty

The [PagerDuty](http://pagerduty.com/) integration in Buildkite can send [change events](https://support.pagerduty.com/docs/change-events) to PagerDuty when your builds finish.

<%= image "overview.png", width: 2202/2, height: 638/2, alt: "Screenshot of the recent events in PagerDuty" %>

## Generating a PagerDuty integration API key

Before using the integration you'll need to generate a PagerDuty Integration API Key.

In [PagerDuty](http://pagerduty.com/), go to the **Service Directory**:

<%= image "menu.png", width: 854/2, height: 324/2, alt: "Screenshot of the Service Directory link in the menu" %>

Then choose the service you'd like Buildkite to send change events to:

<%= image "service-item.png", width: 2842/2, height: 412/2, alt: "Screenshot of the chosen service in the Service Directory" %>

Navigate to the **Integrations** tab and choose **Add a new integration**:

<%= image "add-integration.png", width: 2088/2, height: 686/2, alt: "Screenshot of the Add Integration button in PagerDuty" %>

Under **Integration Name**, choose a memorable name for this integration. A good example could be the name of the Buildkite pipeline you intend to add this integration to.

For **Integration Type**, choose **Buildkite**.

Once you've filled out this form, select **Add Integration**.

Copy the **Integration Key** from your Integrations list and use it in [Sending change events from your pipeline](#sending-change-events-from-your-pipeline).

<%= image "integration-with-key.png", width: 2262/2, height: 822/2, alt: "Screenshot of the Buildkite integration in PagerDuty" %>

## Sending change events from your pipeline

By default, after you've added an Integration API Key, Buildkite will send PagerDuty a Change Event every build regardless of whether the build passed or failed.

Add the PagerDuty [Integration API Key](#generating-a-pagerduty-integration-api-key) to the [`notify` attribute](/docs/pipelines/configure/notifications) of your build configuration.

Make sure that you're using a secure secrets management solution to handle the PagerDuty Integration key, and never commit it in plaintext to source control in a YAML file. See [Managing pipeline secrets](/docs/pipelines/security/secrets/managing) for more information on safely handling secrets within your infrastructure.

```yaml
steps:
  - command: "tests.sh"
  - wait
  - command: "deploy.sh"

notify:
  - pagerduty_change_event: "${PAGER_DUTY_API_KEY}"
```
{: codeblock-file="pipeline.yml"}

<%= image "change-event.png", width: 2304/2, height: 1096/2, alt: "Screenshot of a Change Event inside PagerDuty sent from Buildkite" %>

To send change events only when the build passes, add a [condition](/docs/pipelines/configure/conditionals) to your build configuration:

```yaml
notify:
  - pagerduty_change_event: "${PAGER_DUTY_API_KEY}"
    if: "build.state == 'passed'"
```

## Support

For those of you coming from [the PagerDuty website](https://pagerduty.com) looking for assistance on this integration please reach out to us at [support@buildkite.com](mailto:support@buildkite.com?subject=PagerDuty%20Change%20Events%20Integration).
