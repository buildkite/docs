# Pipeline triggers API

The pipeline triggers API lets you manage a pipeline's [pipeline triggers](/docs/apis/webhooks/incoming/pipeline-triggers). Pipeline triggers are incoming webhook endpoints that create builds from external systems such as generic webhooks, GitHub, and Linear.

> 📘 Public preview feature
> The pipeline triggers feature, including this API, is currently in public preview. To provide feedback, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

Buildkite Pipelines doesn't support rotating a pipeline trigger's endpoint credentials in place. To replace a compromised endpoint, create a new pipeline trigger, point the sending system at its endpoint URL, then delete the old pipeline trigger.

## Pipeline trigger data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL of the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>type</code></th>
    <td>Type of pipeline trigger. One of <code>webhook</code>, <code>github</code>, or <code>linear</code>.</td>
  </tr>
  <tr>
    <th><code>label</code></th>
    <td>Label describing the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline trigger is enabled and accepting incoming webhook requests.</td>
  </tr>
  <tr>
    <th><code>build</code></th>
    <td>Build configuration used for builds created by this pipeline trigger. Contains <code>message</code>, <code>commit</code>, <code>branch</code>, and <code>environment_variables</code>. The <code>environment_variables</code> array contains configured variable names, but not their values.</td>
  </tr>
  <tr>
    <th><code>filter</code></th>
    <td>Filter expression that controls which incoming webhook deliveries create a build, or <code>null</code> if no filter is configured. Contains <code>expression</code>.</td>
  </tr>
  <tr>
    <th><code>verification</code></th>
    <td>Webhook signature verification configuration, or <code>null</code> if verification isn't configured. Contains <code>strategy</code>, which is currently always <code>hmac</code>, and <code>secret_hint</code>, a masked version of the configured secret.</td>
  </tr>
  <tr>
    <th><code>endpoint_url_hint</code></th>
    <td>A masked version of the pipeline trigger's endpoint URL that is safe to display or log.</td>
  </tr>
  <tr>
    <th><code>endpoint_url</code></th>
    <td>The full endpoint URL that receives incoming webhook deliveries, including its plaintext token. Only present in the response from <a href="#create-a-pipeline-trigger">Create a pipeline trigger</a>.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>When the pipeline trigger was created.</td>
  </tr>
  <tr>
    <th><code>created_by</code></th>
    <td><a href="/docs/apis/rest-api/user">User</a> who created the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>updated_at</code></th>
    <td>When the pipeline trigger was last updated.</td>
  </tr>
  <tr>
    <th><code>updated_by</code></th>
    <td><a href="/docs/apis/rest-api/user">User</a> who last updated the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>pipeline</code></th>
    <td>Reference to the parent pipeline, including its <code>id</code>, <code>slug</code>, and API <code>url</code>.</td>
  </tr>
</tbody>
</table>

## List pipeline triggers

Returns a paginated list of the pipeline triggers for a pipeline, with the most recently created first.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers"
```

```json
{
  "items": [
    {
      "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
      "type": "webhook",
      "label": "Deploy production",
      "enabled": true,
      "build": {
        "message": "Deploying production",
        "commit": "HEAD",
        "branch": "main",
        "environment_variables": ["DEPLOY_ENV"]
      },
      "filter": null,
      "verification": null,
      "endpoint_url_hint": "https://webhook.buildkite.com/deliver/bktr_XXXXXXXXXXXXXXXXXXXXet",
      "created_at": "2026-08-11T10:15:32.000Z",
      "created_by": {
        "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
        "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
        "name": "Sam Kim",
        "email": "sam@example.com",
        "avatar_url": "https://www.gravatar.com/avatar/example",
        "created_at": "2013-05-03T04:17:55.867Z"
      },
      "updated_at": "2026-08-11T10:15:32.000Z",
      "updated_by": {
        "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
        "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
        "name": "Sam Kim",
        "email": "sam@example.com",
        "avatar_url": "https://www.gravatar.com/avatar/example",
        "created_at": "2013-05-03T04:17:55.867Z"
      },
      "pipeline": {
        "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
        "slug": "my-pipeline",
        "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
      }
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers?after=...&per_page=30"
  }
}
```

This endpoint uses cursor-based pagination. The response body is a JSON object with an `items` array and a `links` object. Use the `next` URL from `links` to fetch the next page. Follow that URL instead of constructing cursor values.

Full endpoint URLs, environment variable values, and verification secrets aren't included in list responses. Use `endpoint_url_hint` to identify a pipeline trigger without exposing its credentials.

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>per_page</code></th>
    <td>How many results to return per page.
      <p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p>
      <p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Return results after this cursor value. Mutually exclusive with <code>before</code>.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Return results before this cursor value. Mutually exclusive with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `read_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>Invalid <code>per_page</code> or cursor value, or both <code>after</code> and <code>before</code> supplied</td>
  </tr>
</tbody>
</table>

## Get a pipeline trigger

Returns the details for a single pipeline trigger.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{id}"
```

```json
{
  "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "type": "github",
  "label": "GitHub pull requests",
  "enabled": true,
  "build": {
    "message": null,
    "commit": "HEAD",
    "branch": "main",
    "environment_variables": ["DEPLOY_ENV"]
  },
  "filter": {
    "expression": "webhook.headers[\"HTTP_X_GITHUB_EVENT\"] == \"pull_request\""
  },
  "verification": {
    "strategy": "hmac",
    "secret_hint": "XXXXXXXXXXXXXXXXXXXXet"
  },
  "endpoint_url_hint": "https://webhook.buildkite.com/deliver/bktr_XXXXXXXXXXXXXXXXXXXXet",
  "created_at": "2026-08-11T10:15:32.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "updated_at": "2026-08-11T10:15:32.000Z",
  "updated_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "pipeline": {
    "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
    "slug": "my-pipeline",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
  }
}
```

The response doesn't include the full endpoint URL, environment variable values, or verification secret.

Required scope: `read_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `200 OK`

Error response: `404 Not Found` when no pipeline trigger matches the given ID for this pipeline.

## Filter webhook deliveries

Pipeline trigger filters use [Common Expression Language (CEL)](https://cel.dev/). A filter must evaluate to `true` for an incoming webhook delivery to create a build.

Filter configuration is available only to organizations with webhook filtering enabled. Filter expressions have the following constraints:

- Expressions can contain a maximum of 256 bytes.
- Expressions can only reference the `webhook` variable.
- CEL comprehensions such as `all`, `exists`, and `map` aren't supported.
- The result must be a Boolean value. A delivery isn't run if its filter returns another type or fails to evaluate.

The `webhook` variable contains the following values:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>webhook.id</code></th>
    <td>Identifier of the incoming webhook delivery.</td>
  </tr>
  <tr>
    <th><code>webhook.created_at</code></th>
    <td>Time when the incoming webhook delivery was received, as an ISO 8601 string.</td>
  </tr>
  <tr>
    <th><code>webhook.payload</code></th>
    <td>Parsed JSON payload of the incoming webhook delivery.</td>
  </tr>
  <tr>
    <th><code>webhook.headers</code></th>
    <td>HTTP headers of the incoming webhook delivery. Header names use Rack-style keys, such as <code>HTTP_X_GITHUB_EVENT</code>.</td>
  </tr>
</tbody>
</table>

For example, the following expression creates builds only for GitHub pull request events with an `opened` action:

```text
webhook.headers["HTTP_X_GITHUB_EVENT"] == "pull_request" && webhook.payload.action == "opened"
```

Use the [pipeline trigger deliveries API](/docs/apis/rest-api/pipeline-trigger-deliveries) to inspect whether a delivery matched its filter.

## Create a pipeline trigger

Creates a new pipeline trigger.

> 📘 Endpoint URL visibility
> The `endpoint_url` field contains the pipeline trigger's plaintext token and is only included in the response for this request. Save it to a secure location. Subsequent responses only include the masked `endpoint_url_hint`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "webhook",
    "label": "Deploy production",
    "enabled": true,
    "build": {
      "message": "Deploying production",
      "commit": "HEAD",
      "branch": "main",
      "environment": {
        "DEPLOY_ENV": "production"
      }
    }
  }'
```

```json
{
  "id": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
  "type": "webhook",
  "label": "Deploy production",
  "enabled": true,
  "build": {
    "message": "Deploying production",
    "commit": "HEAD",
    "branch": "main",
    "environment_variables": ["DEPLOY_ENV"]
  },
  "filter": null,
  "verification": null,
  "endpoint_url": "https://webhook.buildkite.com/deliver/bktr_xxx-yyy-zzz",
  "endpoint_url_hint": "https://webhook.buildkite.com/deliver/bktr_XXXXXXXXXXXXXXXXXXXXzz",
  "created_at": "2026-08-11T10:15:32.000Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "updated_at": "2026-08-11T10:15:32.000Z",
  "updated_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-05-03T04:17:55.867Z"
  },
  "pipeline": {
    "id": "9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f",
    "slug": "my-pipeline",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>type</code></th>
    <td>Type of pipeline trigger to create. One of <code>webhook</code>, <code>github</code>, or <code>linear</code>. This value can't be changed after creation.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"webhook"</code></p></td>
  </tr>
  <tr>
    <th><code>label</code></th>
    <td>Non-empty label describing the pipeline trigger.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"Deploy production"</code></p></td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline trigger is enabled.
      <p class="Docs__api-param-eg"><em>Default:</em> <code>true</code></p></td>
  </tr>
  <tr>
    <th><code>build</code></th>
    <td>Build configuration used when this pipeline trigger creates a build. The object supports <code>message</code>, <code>commit</code>, <code>branch</code>, and <code>environment</code>. The <code>environment</code> value is a JSON object whose values must be strings. Omitted build fields use the pipeline defaults.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>{ "branch": "main", "environment": { "DEPLOY_ENV": "production" } }</code></p></td>
  </tr>
  <tr>
    <th><code>filter</code></th>
    <td>Filter with a required <code>expression</code> value that controls which deliveries create a build. Requires webhook filtering to be enabled for the organization. See <a href="#filter-webhook-deliveries">Filter webhook deliveries</a> for the expression contract.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>{ "expression": "webhook.payload.action == \"opened\"" }</code></p></td>
  </tr>
  <tr>
    <th><code>verification</code></th>
    <td>Webhook signature verification configuration. The object requires <code>strategy</code>, which must be <code>hmac</code>, and a non-empty <code>secret</code>. Supported for <code>github</code> and <code>linear</code> triggers. Generic <code>webhook</code> triggers don't support verification.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>{ "strategy": "hmac", "secret": "your-signing-secret" }</code></p></td>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>400 Bad Request</code></th>
    <td>The request body isn't a valid JSON object</td>
  </tr>
  <tr>
    <th><code>415 Unsupported Media Type</code></th>
    <td>The request doesn't use an <code>application/json</code> content type</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>The request contains an unsupported field, invalid value, unavailable configuration, or the pipeline has reached its trigger limit</td>
  </tr>
</tbody>
</table>

## Update a pipeline trigger

Updates a pipeline trigger. Attributes omitted from the request body are left unchanged.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Updated pull requests",
    "enabled": false,
    "build": {
      "branch": "release"
    }
  }'
```

The response contains the updated [pipeline trigger data model](#pipeline-trigger-data-model). The full endpoint URL, environment variable values, and verification secret aren't returned.

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>label</code></th>
    <td>Non-empty label describing the pipeline trigger.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether the pipeline trigger is enabled.</td>
  </tr>
  <tr>
    <th><code>build</code></th>
    <td>Build fields to update. Set <code>message</code>, <code>commit</code>, or <code>branch</code> to <code>null</code> to restore its default. Set <code>environment</code> to an empty object to remove all environment variables.</td>
  </tr>
  <tr>
    <th><code>filter</code></th>
    <td>Filter with a required <code>expression</code> value. Set <code>filter</code> to <code>null</code> to remove the filter. See <a href="#filter-webhook-deliveries">Filter webhook deliveries</a> for the expression contract.</td>
  </tr>
  <tr>
    <th><code>verification</code></th>
    <td>Verification configuration with a required <code>strategy</code> value. Omit <code>secret</code> to keep the existing secret, or provide a new value to replace it. Set <code>verification</code> to <code>null</code> to remove verification.</td>
  </tr>
</tbody>
</table>

The `type` value can't be changed after a pipeline trigger is created.

Required scope: `write_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `200 OK`

Error responses: `400 Bad Request` for invalid JSON, `404 Not Found` when the trigger doesn't exist for this pipeline, `415 Unsupported Media Type` for a non-JSON content type, and `422 Unprocessable Entity` for invalid configuration.

## Delete a pipeline trigger

Deletes a pipeline trigger. Its endpoint immediately stops accepting incoming webhook deliveries.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{id}"
```

Required scope: `write_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `204 No Content`

Error response: `404 Not Found` when no pipeline trigger matches the given ID for this pipeline.
