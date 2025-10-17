# Pipeline triggers

A _pipeline trigger_ is a type of incoming webhook that creates new builds of a Buildkite pipeline, based on events from external systems.

To trigger pipelines from source control events, see [Source control](/docs/pipelines/source-control) for a list of source control systems that Buildkite supports and integrates with.

Pipeline triggers are HTTP endpoints that create builds when they receive POST requests. Each pipeline trigger has a unique URL that accepts JSON payloads, making them ideal for integrating Buildkite with the other tools you use.

A pipeline trigger is scoped to a specific Buildkite pipeline, and can be used to trigger builds from monitoring alerts, deployment systems, or any service that can send outbound webhooks.

> 📘 Customer preview feature
> The pipeline triggers feature is currently in customer preview as it is still undergoing development. To provide feedback, please contact Buildkite's Support team at [support@buildkite.com](mailto:support@buildkite.com).

## Create a new pipeline trigger

To create a new pipeline trigger using the Buildkite interface:

1. From your [Buildkite dashboard](https://buildkite.com/~), ensure that **Pipelines** is selected in the global navigation, and then select your pipeline.

1. Select your pipeline's **Settings** button > **Triggers**.

1. On the **Triggers** page, select the **New Trigger** button to create a new pipeline trigger.

1. Configure your pipeline trigger, by completing its fields, noting that the **Description**, **Branch**, and **Commit** fields are required to generate a unique endpoint.
    <table class="responsive-table">
      <tbody>
        <tr>
          <th>Description</th>
          <td>The description for the pipeline trigger, which is its name in the list of existing triggers on the <strong>Triggers</strong> page.</td>
        </tr>
        <tr>
          <th>Build message</th>
          <td>The message for your triggered build, which appears on the <a href="/docs/pipelines/dashboard-walkthrough#pipeline-page">pipeline page</a> as part of its build history. If none is specified, this value defaults to <strong>Triggered build</strong>.</td>
        </tr>
        <tr>
          <th>Commit</th>
          <td>
            The commit ref the triggered build will run against. If none is specified, this value defaults to <code>HEAD</code>.
          </td>
        </tr>
        <tr>
          <th>Branch</th>
          <td>
            The branch the triggered build will run against. If none is specified, this value defaults to <code>main</code>.
          </td>
        </tr>
        <tr>
          <th>Environment variables</th>
          <td>
            Optional environment variables to set for the build. Each new environment variable should be entered on a new line.<br/>
            <em>Example:</em> <code>FOO=bar<br/>BAZ=quux</code>
          </td>
        </tr>
        <tr>
          <th>Enabled</th>
          <td>Ensure this checkbox is selected to make the pipeline trigger active.</td>
        </tr>
      </tbody>
    </table>

1. After completing these fields, select **Create Trigger** to create the pipeline trigger.

    <%= image "pipeline-trigger-create.png", width: 2028/2, height: 880/2, class: "invertible", alt: "Successful creation of a pipeline trigger" %>

1. In the **Trigger created successfully!** message, follow the instructions to copy and save your webhook trigger's URL to a secure location, as you won't be able to see its value again through the Buildkite interface. The new webhook trigger appears in the list of existing triggers on the **Triggers** page.

That's it! You've completed creating your pipeline trigger. See the following section on [Endpoint](#create-a-new-pipeline-trigger-endpoint) to learn more about the pipeline trigger and how it works, and you're now ready to [invoke your trigger](#invoke-a-pipeline-trigger).

### Endpoint

Each pipeline trigger has a unique endpoint with the following URL structure:

```
https://webhook.buildkite.com/deliver/bktr_************
```

All requests sent to this endpoint must be `HTTP POST` requests with `application/json` encoded bodies.

#### Response

A successful trigger request returns a `201 Created` response with details about the created build:

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983"
}
```

#### Error responses

<table class="responsive-table">
  <tbody>
    <tr><th><code>400 Bad request</code></th><td><code>{ "message": "Invalid pipeline trigger token" }</code></td></tr>
    <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Pipeline trigger is disabled" }</code></td></tr>
    <tr><th><code>404 Not Found</code></th><td><code>{ "message": "Pipeline trigger not found" }</code></td></tr>
  </tbody>
</table>

## Invoke a pipeline trigger

To create a build using a webhook pipeline trigger, send an HTTP POST request to the trigger URL.
Each trigger accepts a JSON payload, which is accessible to all build steps (see [Accessing pipeline trigger data](#invoke-a-pipeline-trigger-accessing-pipeline-trigger-data) for details).

Here's an example using `curl`:

```bash
curl -H "Content-Type: application/json" \
  -X POST "https://webhook.buildkite.com/deliver/bktr_************" \
  -d '{
    "id": "P2LA89X",
    "message": "A fix for this incident is being developed",
    "trimmed": false,
    "type": "incident_status_update",
    "incident": {
      "html_url": "https://acme.pagerduty.com/incidents/PGR0VU2",
      "id": "PGR0VU2",
      "self": "https://api.pagerduty.com/incidents/PGR0VU2",
      "summary": "A little bump in the road",
      "type": "incident_reference"
    }
  }'
```

You've just created your first build using a pipeline trigger.

> 📘
> Be aware that the presence of a `"message": "Any value"` field in the JSON payload does not override the value of the **Build message** set when [creating the pipeline trigger](#create-a-new-pipeline-trigger). All such values in the payload form part of the [pipeline trigger's data](#invoke-a-pipeline-trigger-accessing-pipeline-trigger-data).

### Accessing pipeline trigger data

JSON payloads sent to a pipeline trigger URL are accessible in all steps of the triggered build.
You can retrieve the webhook payload using the Buildkite Agent CLI command [`buildite-agent meta-data`](/docs/pipelines/configure/build-meta-data).

#### Example

The following sample JSON payload is obtained from the response to closing a GitHub pull request:

```json
{
  "action": "closed",
  "number": 123,
  "organization": "Buildkite"
  "pull_request": {
    "url": "https://www.github.com/buildkite/dummy-repo",
    "id": 456,
    "number": 123,
    "state": "closed",
    "title": "Integrate into Buildkite pipeline triggers",
    "closed_at": "2025-10-14T02:14:39Z"
    "merged_at": null
  }
}

```

Accessing the JSON payload posted to your pipeline trigger endpoint can be done using the [`buildkite:webhook` meta-data key](/docs/pipelines/configure/build-meta-data#special-meta-data-buildkite-webhook), which is a [special Buildkite meta-data key](/docs/pipelines/configure/build-meta-data#special-meta-data):

```yaml
steps:
  - command: |
      WEBHOOK="$(buildkite-agent meta-data get buildkite:webhook)"
      ACTION="$(jq -r '.action' <<< "$WEBHOOK")"
      MERGED="$(jq -r '.pull_request.merged' <<< "$WEBHOOK")"

      if [[ "$ACTION" == "closed" && "$MERGED" == "false" ]]; then
        echo "PR was manually closed"
      fi
```

The `buildkite:webhook` meta-data itself is only available to builds triggered by any incoming webhook, and only for as long as the webhook data remains cached, which is typically for 7 days.

## Limitations

The following limitations apply to pipeline triggers:

- The authenticity of a pipeline trigger's webhook cannot be verified (for example, using HMAC signatures).
- A pipeline trigger's URL cannot be rotated. If the trigger's `bkpt_` value has been compromised, you'll need to delete and create a new trigger with the same attributes.
- Build attributes only support static values and cannot be mapped from webhook payload values.
- Pipeline triggers don't support filtering build creation based on webhook content.
- Pipeline triggers don't have API support for management operations.
- There is no Buildkite interface or API support for listing builds created from a pipeline trigger.
- Unlike JSON payloads, HTTP headers are not accessible to pipelines in requests to pipeline triggers.
- A pipeline trigger's webhook cannot be restricted by IP address.
- A pipeline trigger's JSON payload is limited to a maximum size of 5MB.
- Trigger URL endpoints have a request limit of [TBC].
- Webhook metadata payload retrieval is rate limited to 10 requests per minute per build.
- Webhook delivery has a timeout of 10 seconds.
- Each pipeline is limited to 10 triggers.

## Further reading

- [Accessing build meta-data](/docs/pipelines/configure/build-meta-data#special-meta-data)
- [`buildkite-agent meta-data` cli command](/docs/agent/v3/cli-meta-data)
- [Incoming webhook security overview](docs/pipelines/security/incoming-webhooks#what-kind-of-information-on-incoming-webhooks-is-logged-by-buildkite)
