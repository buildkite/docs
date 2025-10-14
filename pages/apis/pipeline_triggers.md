# Pipeline triggers
Pipeline triggers create builds based on events from external systems. Custom webhooks are the first supported pipeline trigger.

To trigger pipelines from source control events, see the [source control integrations](/docs/pipelines/source-control) that Buildkite supports.

## Webhook triggers
Webhook triggers are HTTP endpoints that create builds when they receive POST requests. Each trigger has a unique URL that accepts JSON payloads, making them ideal for automated workflows and integrations.

Webhook triggers are scoped to a specific pipeline. Use them to trigger builds from monitoring alerts, deployment systems, or any service that can send outbound webhooks.

> 📘 This feature is currently available in preview.
> The triggers feature is currently in development. To provide feedback, please contact Buildkite's Support team at [support@buildkite.com](mailto:support@buildkite.com).

## Getting started

To create a new pipeline trigger using the Buildkite interface:

1. From your [Buildkite dashboard](https://buildkite.com/~), select your pipeline.
2. Select your pipeline's **Settings** > **Triggers**.
3. Select the **New Trigger** button to create a new pipeline trigger.
4. Configure your pipeline trigger.

    At a minimum, the pipeline trigger will require a **Description**, **Branch**, and **Commit** to generate a unique endpoint.
    <table class="responsive-table">
      <tbody>
        <tr>
          <th>Description</th>
          <td>The description for the pipeline trigger.</td>
        </tr>
        <tr>
          <th>Build message</th>
          <td>An optional message for your build. Defaults to <em>Triggered build</em>.</td>
        </tr>
        <tr>
          <th>Commit</th>
          <td>
            The commit ref the triggered build will run against.<br/>
            <em>Example:</em> <code>HEAD</code>
          </td>
        </tr>
        <tr>
          <th>Branch</th>
          <td>
            The branch the triggered build will run against.<br/>
            <em>Example:</em> <code>main</code>
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
          <td>Whether the pipeline trigger is active.</td>
        </tr>
      </tbody>
    </table>

5. After completing these fields, select **Create Trigger** to create the pipeline trigger.
6. A unique trigger URL will be generated. Save this trigger URL to somewhere secure, as you won't be able to access it again through the Buildkite UI.

    <%= image "pipeline-trigger-create.png", width: 2028/2, height: 880/2, class: "invertible", alt: "Successful creation of a pipeline trigger" %>

That's it - You're all set up and ready to invoke first pipeline trigger.

## Invoke a pipeline trigger

To create a build using a webhook pipeline trigger, simply send a HTTP POST request to the trigger URL.
Each trigger accepts a JSON payload, which is accessible to all build steps (see [Accessing webhook data](#invoke-a-pipeline-trigger-accessing-webhook-data)).

Here's an example using `curl`:

```bash
curl -H "Content-Type: application/json" \
  -X POST "https://webhook.buildkite.com/deliver/bktr_************" \
  -d '{ "event": "mock-event" }'
```

You've just created your first build using a pipeline trigger.

### Endpoint

Each pipeline trigger has a unique endpoint with the following URL structure:

```
https://webhook.buildkite.com/deliver/bktr_************
```

All requests must be `HTTP POST` requests with `application/json` encoded bodies.

##### Response

A successful trigger request returns a `201 Created` response with details about the created build:

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983"
}
```

##### Error responses

<table class="responsive-table">
  <tbody>
    <tr><th><code>400 Bad request</code></th><td><code>{ "message": "Invalid pipeline trigger token" }</code></td></tr>
    <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Pipeline trigger is disabled" }</code></td></tr>
    <tr><th><code>404 Not Found</code></th><td><code>{ "message": "Pipeline trigger not found" }</code></td></tr>
  </tbody>
</table>

### Accessing webhook data

Webhook JSON payloads sent to a pipeline trigger URL are accessible in all steps of the triggered build.
You can retrieve the webhook body using the [`buildkite:webhook`](/docs/pipelines/configure/build-meta-data#special-meta-data-buildkite-webhook) meta-data key.

##### Example:

Sample of a Github pull request closed webhook payload:

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
    "title": "Integrate into buildkite pipeline triggers",
    "closed_at": "2025-10-14T02:14:39Z"
    "merged_at": null
  }
}

```

Accessing the webhook posted to the pipeline trigger URL:

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

`buildkite:webhook` data will only be available to builds triggered by a webhook, and only for as long as the webhook data remains cached — typically for 7 days.
