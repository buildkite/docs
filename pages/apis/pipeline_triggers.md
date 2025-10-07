# Pipeline triggers

Buildkite _pipeline triggers_ provide a simple way to trigger builds on a pipeline. Pipeline triggers can be created by pipeline administrators, are stored by Buildkite, and are accessible through a unique URL endpoint.

Pipeline triggers work well for automated build triggering from external systems, CI/CD integrations, and scheduled workflows, since they're scoped to a specific pipeline and use dedicated tokens that aren't tied to individual user accounts.

## Getting started

To get started with pipeline triggers, access the **Pipeline Triggers** feature to begin creating a trigger:

1. Navigate to your pipeline settings by selecting **Pipelines**, then selecting your pipeline.

1. Select **Pipeline Triggers** from the pipeline settings menu.

1. Select the **New Trigger** button to create a new pipeline trigger.

    At a minimum, a pipeline trigger requires a **Label**, **Branch**, and **Commit** to generate a unique endpoint and authentication token.

1. Configure your pipeline trigger:

    - **Label**: A descriptive name for this trigger (for example, **Deploy to production**)
    - **Branch**: The branch to build (for example, **main**)
    - **Commit**: The commit to build (for example, **HEAD**)
    - **Message**: Optional build message
    - **Environment Variables**: Optional environment variables to set for the build.

1. After completing these fields, select **Create Trigger** to create the pipeline trigger.

    A new HTTP endpoint is generated, including a _pipeline trigger token_.

1. Save this trigger URL to somewhere secure, as you won't be able to access its value again through the Buildkite interface.

1. Make a request to your new endpoint using the following `curl` command, replacing the organization slug, pipeline slug, and trigger ID with your own:

    ```sh
    curl -H "Content-Type: application/json" \
      -d '{}' \
      -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{trigger.id}"
    ```

Voila! You've just created your first build with a pipeline trigger.

## Endpoint

Each pipeline trigger has a unique endpoint with the following URL structure:

```
https://webhook.buildkite.com/deliver/bktr
```

All requests must be `HTTP POST` requests with `application/json` encoded bodies.

## Authentication

Pipeline triggers are authenticated with the associated trigger token generated for a given trigger.

For example:

```sh
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}' \
  -X POST "https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/triggers/01234567-89ab-cdef-0123-456789abcdef"
```

> 📘
> If you need to generate a new trigger URL (to replace an older or suspected compromised one), you can delete the existing trigger and create a new one, which will generate a new token.

The environment variables from the request body will be available to all steps in the triggered build.

## Response

A successful trigger request returns a `201 Created` response with details about the created build:

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
}
```

Error responses:

<table>
<tbody>
  <tr><th><code>401 Unauthorized</code></th><td><code>{ "message": "Invalid or missing authentication token" }</code></td></tr>
  <tr><th><code>404 Not Found</code></th><td><code>{ "message": "Trigger not found" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation error message" }</code></td></tr>
</tbody>
</table>
