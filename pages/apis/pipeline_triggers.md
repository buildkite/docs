# Pipeline triggers

Pipeline triggers are webhook endpoints that start builds on a pipeline. Each trigger has a unique URL that accepts HTTP POST requests with JSON payloads, making them ideal for automated workflows and CI/CD integrations.

Unlike user API tokens, pipeline triggers are scoped to a specific pipeline. This makes them well-suited for external systems, scheduled jobs, and integrations that need to trigger builds programmatically.

## Getting started

To set up a pipeline trigger:

1. From your Buildkite dashboard, select a pipeline to configure a trigger for.
2. Select **Pipeline Settings** > **Triggers**.
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

<%= image "pipeline-trigger-creation-success.png", class: "invertible", alt: "Successful creation of a pipeline trigger" %>

That's it - You're all set up and ready to invoke first pipeline trigger.

## Invoke a pipeline trigger

To create a build from a pipeline trigger, simply send a HTTP POST request to the trigger URL.
The endpoint accepts a JSON payload, which is accessible to all steps via your build's metadata.

Here's an example using `curl`:

```sh
curl -H "Content-Type: application/json" \
  -X POST "https://webhook.buildkite.com/deliver/bktr_************" \
  -d '{ "event": "mock-event" }'
```

Voila! You've just created your first build using a pipeline trigger.

> 📘 Example workflows
> See how pipeline triggers work in practice with [common workflow examples](#).

### Endpoint

Each pipeline trigger has a unique endpoint with the following URL structure:

```
https://webhook.buildkite.com/deliver/bktr_************
```

All requests must be `HTTP POST` requests with `application/json` encoded bodies.


### Response

A successful trigger request returns a `201 Created` response with details about the created build:

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983"
}
```

Error responses:

<table>
  <tbody>
    <tr><th><code>401 Unauthorized</code></th><td><code>{ "message": "Invalid pipeline trigger token" }</code></td></tr>
    <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Pipeline trigger is disabled" }</code></td></tr>
    <tr><th><code>404 Not Found</code></th><td><code>{ "message": "Pipeline trigger not found" }</code></td></tr>
    <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation error message" }</code></td></tr>
  </tbody>
</table>
