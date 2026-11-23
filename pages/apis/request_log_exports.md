# API request log exports (private preview)

Download your organization's REST and GraphQL API request logs to investigate API usage and rate limiting.

## Using request log exports

> 📘 Private preview feature
> API request log exports are currently in private preview. To have them enabled for your Buildkite organization, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

An organization administrator with an API access token that has the `read_api_request_logs` [scope](/docs/apis/managing-api-tokens#token-scopes) can request an export, poll for completion, and download the file. Follow the [REST API instructions](/docs/apis/rest-api/organizations/api-request-log-exports) to get started.

Request one Parquet export per dataset each day around 00:20 UTC, setting explicit `from` and `to` timestamps for the previous full UTC day.

```json
{
  "dataset": "rest",
  "format": "parquet",
  "from": "2026-11-21T00:00:00Z",
  "to": "2026-11-22T00:00:00Z"
}
```

## Exported fields

Each file contains the fields listed for its dataset below. Review files before sharing them.

### REST request exports

Field | Description
--- | ---
`request_id` | Unique identifier for the request.
`requested_at` | Time the request was made, in UTC.
`traffic` | The client category: `cli`, `mcp`, or `api` (other API clients).
`http_method` | The HTTP method used, for example `GET` or `POST`.
`response_status` | The HTTP response status code.
`path` | The request path without the query string, for example `/v2/organizations/acme/builds`.
`user_uuid` | UUID of the authenticated user, when available.
`access_token_uuid` | UUID of the access token used to authenticate the request, if any.
`auth_type` | How the request was authenticated, for example `access_token`.
`source_ip` | The IP address the request came from.
`user_agent` | The client-supplied `User-Agent` header.
`applied_limiter` | The rate limiter that blocked the request, or `null` if none blocked it.
{: class="responsive-table"}

Example REST export row:

```json
{
  "request_id": "00000000-0000-4000-8000-000000000001",
  "requested_at": "2026-11-14T10:15:00.000001Z",
  "traffic": "cli",
  "http_method": "GET",
  "response_status": 429,
  "path": "/v2/organizations/acme-inc/builds",
  "user_uuid": "00000000-0000-4000-8000-000000000002",
  "access_token_uuid": "00000000-0000-4000-8000-000000000003",
  "auth_type": "access_token",
  "source_ip": "203.0.113.42",
  "user_agent": "buildkite-cli/3.35.0",
  "applied_limiter": "rest_org"
}
```

### GraphQL request exports

Field | Description
--- | ---
`request_id` | Unique identifier for the request.
`requested_at` | Time the request was made, in UTC.
`traffic` | The client category: `cli`, `mcp`, or `api` (other API clients).
`http_method` | The HTTP method used, usually `POST`.
`response_status` | The HTTP response status code. Check `graphql_error_count` for GraphQL errors, including those returned with `200` responses.
`graphql_operation_type` | The operation type, for example `query` or `mutation`.
`graphql_operation_name` | The client-supplied operation name.
`graphql_error_count` | The number of top-level GraphQL errors returned.
`user_uuid` | UUID of the authenticated user, when available.
`access_token_uuid` | UUID of the access token used to authenticate the request, if any.
`auth_type` | How the request was authenticated, for example `access_token`.
`source_ip` | The IP address the request came from.
`user_agent` | The client-supplied `User-Agent` header.
`applied_limiter` | The rate limiter that blocked the request, or `null` if none blocked it.
{: class="responsive-table"}

Example GraphQL export row:

```json
{
  "request_id": "00000000-0000-4000-8000-000000000004",
  "requested_at": "2026-11-14T10:16:00.000002Z",
  "traffic": "api",
  "http_method": "POST",
  "response_status": 200,
  "graphql_operation_type": "query",
  "graphql_operation_name": "PipelinesList",
  "graphql_error_count": 1,
  "user_uuid": "00000000-0000-4000-8000-000000000002",
  "access_token_uuid": "00000000-0000-4000-8000-000000000003",
  "auth_type": "access_token",
  "source_ip": "203.0.113.42",
  "user_agent": "example-api-client/1.0",
  "applied_limiter": null
}
```

## File formats

Choose Parquet (default, zstd-compressed), CSV, or NDJSON. CSV and NDJSON files are gzip-compressed.

## Limits

- Each export covers one organization and dataset, for one to 24 complete UTC hours within the last 30 days. Allow 15 minutes after the period ends for requests to arrive.
- By default, each organization can have five exports in progress and request 60 exports per rolling 24 hours, including completed and failed exports.
- Completed files are available for 24 hours. Signed download links expire after ten minutes; request a new link while the file is still available.
