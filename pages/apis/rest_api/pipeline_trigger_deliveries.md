# Pipeline trigger deliveries API

The pipeline trigger deliveries API provides read-only access to a [pipeline trigger's](/docs/apis/webhooks/incoming/pipeline-triggers) recent deliveries. Use this API to check whether an incoming webhook created a build and, when needed for debugging, inspect the original request that Buildkite Pipelines received.

Buildkite Pipelines retains only a recent history of deliveries for each pipeline trigger. Once a delivery is no longer retained, requests for it return `404 Not Found`.

Use the [pipeline triggers API](/docs/apis/rest-api/pipeline-triggers) to create and manage pipeline triggers.

## Delivery data model

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>id</code></th>
    <td>UUID of the delivery.</td>
  </tr>
  <tr>
    <th><code>url</code></th>
    <td>Canonical API URL of the delivery.</td>
  </tr>
  <tr>
    <th><code>request_url</code></th>
    <td>API URL of the delivery's retained request, which includes its parsed payload and headers. See <a href="#get-a-deliverys-request">Get a delivery's request</a>.</td>
  </tr>
  <tr>
    <th><code>received_at</code></th>
    <td>When the delivery was received.</td>
  </tr>
  <tr>
    <th><code>content_type</code></th>
    <td>Content type of the incoming request, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>external_id</code></th>
    <td>Provider-supplied identifier for the delivery, such as a GitHub delivery ID, or <code>null</code>.</td>
  </tr>
  <tr>
    <th><code>status</code></th>
    <td>Outcome of the delivery. One of:
      <ul>
        <li><code>build_created</code>: One or more builds were created from this delivery.</li>
        <li><code>not_run</code>: The delivery didn't qualify to create a build.</li>
        <li><code>failed</code>: Buildkite Pipelines recorded an error while processing this delivery.</li>
        <li><code>null</code>: No persisted outcome distinguishes a delivery that is still processing from one that completed without creating a build.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th><code>reason</code></th>
    <td>Reason code for a <code>not_run</code> or <code>failed</code> status. The value is <code>null</code> for a created build or when the recorded reason isn't recognized. See <a href="#delivery-reason-codes">Delivery reason codes</a>.</td>
  </tr>
  <tr>
    <th><code>builds</code></th>
    <td>Array of builds created from this delivery. Each build contains <code>id</code>, <code>number</code>, and <code>url</code>. The array is empty when no build was created.</td>
  </tr>
</tbody>
</table>

## Delivery reason codes

The `reason` field for a `failed` delivery is one of the following values:

- `invalid_payload`
- `billing_error`
- `build_creation_failed`

The `reason` field for a `not_run` delivery is one of the following values:

- `ci_skip`
- `branch_mismatch`
- `tag_mismatch`
- `pull_requests_disabled`
- `pull_request_branch_mismatch`
- `branches_disabled`
- `tags_disabled`
- `condition_false`
- `condition_failed_parse`
- `preflight_webhook`
- `filter_mismatch`
- `filter_evaluation_failed`

## List a trigger's deliveries

Returns a paginated list of a pipeline trigger's retained deliveries, newest first.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{trigger.id}/deliveries"
```

```json
{
  "items": [
    {
      "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries/f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
      "request_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries/f62a1b4d-10f9-4790-bc1c-e2c3a0c80983/request",
      "received_at": "2026-08-11T10:15:32.000Z",
      "content_type": "application/json",
      "external_id": "72d3529e-0135-11e8-9bf8-9df34a9db3a0",
      "status": "build_created",
      "reason": null,
      "builds": [
        {
          "id": "0198f2f4-1c33-4e0a-9d5e-3a4a5b6c7d8e",
          "number": 42,
          "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds/42"
        }
      ]
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries?after=...&per_page=30"
  }
}
```

This endpoint uses cursor-based pagination. The response body is a JSON object with an `items` array and a `links` object. Use the `next` URL from `links` to fetch the next page. Follow that URL instead of constructing cursor values.

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
  <tr>
    <th><code>404 Not Found</code></th>
    <td>No trigger matches the given ID for this pipeline</td>
  </tr>
</tbody>
</table>

## Get a delivery

Returns a single retained delivery.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{trigger.id}/deliveries/{delivery.id}"
```

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries/f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "request_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/triggers/9d1d1e9c-5e8f-4f9a-9b0c-1a2b3c4d5e6f/deliveries/f62a1b4d-10f9-4790-bc1c-e2c3a0c80983/request",
  "received_at": "2026-08-11T10:15:32.000Z",
  "content_type": "application/json",
  "external_id": null,
  "status": "not_run",
  "reason": "branch_mismatch",
  "builds": []
}
```

Required scope: `read_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `200 OK`

Error response: `404 Not Found` when no delivery matches the given ID for this trigger, or the delivery is no longer retained.

## Get a delivery's request

Returns the request that Buildkite Pipelines received for a delivery, including its parsed payload and headers.

Header values are allowlisted before they are returned. Only the GitHub event and delivery ID header values are included. Every other header value is redacted, including authorization, cookie, signature, and token headers. Header names are normalized to lowercase, such as `x-github-event`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/triggers/{trigger.id}/deliveries/{delivery.id}/request"
```

```json
{
  "content_type": "application/json",
  "headers": [
    { "name": "authorization", "value": null, "redacted": true },
    { "name": "x-github-delivery", "value": "72d3529e-0135-11e8-9bf8-9df34a9db3a0", "redacted": false },
    { "name": "x-github-event", "value": "pull_request", "redacted": false },
    { "name": "x-hub-signature-256", "value": null, "redacted": true }
  ],
  "payload": {
    "action": "opened",
    "pull_request": {
      "number": 42
    }
  }
}
```

The `headers` value is an empty array when the delivery has no stored headers. The `payload` value isn't redacted and can contain sensitive data from the sending system.

This response is sent with `Cache-Control: private, no-store` and isn't cached.

Required scope: `read_pipelines`

Required permission: **Full Access** to the pipeline

Success response: `200 OK`

Error response: `404 Not Found` when no delivery matches the given ID for this trigger, or the delivery is no longer retained.
