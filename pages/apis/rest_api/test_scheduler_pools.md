# Test Scheduler pools API

The Test Scheduler pools API provides endpoints for managing test pools. Test pools are scoped to an organization, test suite, pipeline, and build. They are accessed using a suite-scoped [OIDC token](/docs/pipelines/security/oidc).

## List pools

Returns a cursor-paginated list of test pools for the authenticated build, scoped to the organization, suite, pipeline, and build from the OIDC token.

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
    "next": "https://api.buildkite.com/v2/organizations/my-org/test-scheduler/pools?after=..."
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
    <td>Return results after this cursor. Use the <code>links.next</code> URL from the previous response to paginate forward.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Return results before this cursor. Use the <code>links.prev</code> URL from the previous response to paginate backward. Cannot be used together with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Results are ordered newest-first. An empty `items` array is returned when no pools match the request.

Required scope: `read_test_pool`

Success response: `200 OK`

Error responses:

- `400 Bad Request`: Missing or malformed `pipeline_id`, `build_id`, `key`, or pagination parameters.
- `403 Forbidden`: The `pipeline_id` or `build_id` does not match the OIDC token claims, or the token lacks the `read_test_pool` scope.

## Get a pool

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

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  --data '{
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
    <th><code>ttl_seconds</code></th>
    <td>The time-to-live for the pool in seconds. The pool expires and is no longer available after this duration.<br><em>Example:</em> <code>3600</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_test_pool`

Success response: `201 Created`
