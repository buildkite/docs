# Test Scheduler pools API

The Test Scheduler pools API lets you manage test pools. Each pool belongs to an organization, test suite, pipeline, and build. Authenticate requests using a suite-scoped [OIDC token](/docs/pipelines/security/oidc).

## List pools

Returns a cursor-paginated list of test pools for the build identified by the OIDC token. Results are limited to the organization, test suite, pipeline, and build associated with the token.

```bash
curl --get "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools" \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Accept: application/json" \
  --data-urlencode "pipeline_id={pipeline.uuid}" \
  --data-urlencode "build_id={build.uuid}"
```

```json
{
  "items": [
    {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "organization_id": "01234567-89ab-cdef-0123-456789abcdef",
      "suite_id": "01234567-89ab-cdef-0123-456789abcdef",
      "pipeline_id": "01234567-89ab-cdef-0123-456789abcdef",
      "build_id": "01234567-89ab-cdef-0123-456789abcdef",
      "key": "my-pool",
      "state": "populating",
      "expires_at": "2025-01-01T00:00:00.000Z",
      "created_at": "2025-01-01T00:00:00.000Z"
    }
  ],
  "links": {
    "next": "https://api.buildkite.com/v2/organizations/my-org/test-scheduler/pools?pipeline_id=01234567-89ab-cdef-0123-456789abcdef&build_id=01234567-89ab-cdef-0123-456789abcdef&after=..."
  }
}
```

Required query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>pipeline_id</code></th>
    <td>The UUID of the pipeline. Must match the <code>pipeline_id</code> claim in the OIDC token.<br><em>Example:</em> <code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <th><code>build_id</code></th>
    <td>The UUID of the build. Must match the <code>build_id</code> claim in the OIDC token.<br><em>Example:</em> <code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
</tbody>
</table>

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>key</code></th>
    <td>Filters results to pools whose key matches this value (case-insensitive). Omitting this parameter returns all pools for the build. A non-blank string value is required if provided.<br><em>Example:</em> <code>my-pool</code></td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>The number of results per page. Must be between 1 and 100. Defaults to 30.<br><em>Example:</em> <code>10</code></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Returns results after this cursor. Use the <code>links.next</code> URL from the previous response to paginate forward.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns results before this cursor. Use the <code>links.prev</code> URL from the previous response to paginate backward. Cannot be used together with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Results are ordered from newest to oldest. The API returns an empty `items` array when no pools match the request.

Required scope: `read_test_pool`

Success response: `200 OK`

Error responses:

- `400 Bad Request`: Missing or malformed `pipeline_id`, `build_id`, `key`, or pagination parameters.
- `403 Forbidden`: The `pipeline_id` or `build_id` does not match the OIDC token claims, or the token lacks the `read_test_pool` scope.

## Get a pool

Returns the details of a test pool.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}" \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Accept: application/json"
```

```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "organization_id": "01234567-89ab-cdef-0123-456789abcdef",
  "suite_id": "01234567-89ab-cdef-0123-456789abcdef",
  "pipeline_id": "01234567-89ab-cdef-0123-456789abcdef",
  "build_id": "01234567-89ab-cdef-0123-456789abcdef",
  "key": "my-pool",
  "state": "populating",
  "expires_at": "2025-01-01T00:00:00.000Z",
  "created_at": "2025-01-01T00:00:00.000Z"
}
```

Required scope: `read_test_pool`

Success response: `200 OK`

## Create a pool

Creates a test pool for a build.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data '{
    "suite": "my-suite",
    "pipeline": "my-pipeline",
    "build_id": "01234567-89ab-cdef-0123-456789abcdef",
    "key": "my-pool",
    "ttl_seconds": 3600
  }'
```

```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "organization_id": "01234567-89ab-cdef-0123-456789abcdef",
  "suite_id": "01234567-89ab-cdef-0123-456789abcdef",
  "pipeline_id": "01234567-89ab-cdef-0123-456789abcdef",
  "build_id": "01234567-89ab-cdef-0123-456789abcdef",
  "key": "my-pool",
  "state": "populating",
  "expires_at": "2025-01-01T01:00:00.000Z",
  "created_at": "2025-01-01T00:00:00.000Z"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>suite</code></th>
    <td>The slug of the test suite.<br><em>Example:</em> <code>my-suite</code></td>
  </tr>
  <tr>
    <th><code>pipeline</code></th>
    <td>The slug of the pipeline.<br><em>Example:</em> <code>my-pipeline</code></td>
  </tr>
  <tr>
    <th><code>build_id</code></th>
    <td>The UUID of the build.<br><em>Example:</em> <code>01234567-89ab-cdef-0123-456789abcdef</code></td>
  </tr>
  <tr>
    <th><code>key</code></th>
    <td>The key used to identify the pool.<br><em>Example:</em> <code>my-pool</code></td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>ttl_seconds</code></th>
    <td>The time-to-live for the pool in seconds. The pool expires and is no longer available after this duration. If omitted, the API uses the default time-to-live.<br><em>Example:</em> <code>3600</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_test_pool`

Success response: `201 Created`
