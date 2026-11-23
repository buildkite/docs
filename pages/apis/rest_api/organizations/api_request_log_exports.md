# API request log exports (private preview)

Use these endpoints to request, poll, and download your organization's REST or GraphQL API request logs. For recommended usage, exported fields, and formats, see the [request log exports overview](/docs/apis/request-log-exports).

## Create an API request log export

> 📘 Private preview feature
> API request log exports are currently in private preview. To have them enabled for your Buildkite organization, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

Use an organization administrator's API access token with the `read_api_request_logs` [scope](/docs/apis/managing-api-tokens#token-scopes).

Request an export for one dataset and a period of one to 24 complete UTC hours:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/api_request_log_exports" \
  -d '{
    "dataset": "rest",
    "format": "parquet",
    "from": "2026-11-21T00:00:00Z",
    "to": "2026-11-22T00:00:00Z"
  }'
```

Property | Description
--- | ---
`dataset` | Required. Either `rest` or `graphql`.
`format` | Optional. `parquet` (default), `csv`, or `ndjson`. CSV and NDJSON files are gzip-compressed.
`from` | Optional. Inclusive start, within the last 30 days. Defaults to 24 hours before `to`.
`to` | Optional. Exclusive end, at least 15 minutes ago. Defaults to today's UTC midnight.
{: class="responsive-table"}

Use Parquet and set explicit `from` and `to` values as ISO 8601 timestamps on UTC hour boundaries.

The API returns `201 Created`. The response includes:

```json
{
  "uuid": "019a8200-0000-7000-8000-000000000001",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/api_request_log_exports/019a8200-0000-7000-8000-000000000001",
  "dataset": "rest",
  "format": "parquet",
  "state": "pending",
  "download_url": null
}
```

Use the returned `url` to poll for completion.

## Poll an API request log export

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/api_request_log_exports/{uuid}"
```

The API returns `200 OK`. Repeat this request while `state` is `pending` or `running`. When `state` is `completed`, the response includes the row count and download URL:

```json
{
  "uuid": "019a8200-0000-7000-8000-000000000001",
  "state": "completed",
  "row_count": 12345,
  "download_url": "https://api.buildkite.com/v2/organizations/acme-inc/api_request_log_exports/019a8200-0000-7000-8000-000000000001/download",
  "finished_at": "2026-11-22T00:22:00.000Z",
  "expires_at": "2026-11-23T00:22:00.000Z"
}
```

If `state` is `failed`, check `error_message` and request a new export.

## Download an API request log export

Request the completed export's `download_url` with your API access token:

```bash
curl --location -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/api_request_log_exports/{uuid}/download" \
  --output export.parquet
```

The endpoint returns `302 Found`. The `--location` option follows the signed link and downloads the file. Match the filename to your format: `.parquet`, `.csv.gz`, or `.ndjson.gz`.

Example redirect response:

```http
HTTP/1.1 302 Found
Location: https://example-bucket.s3.amazonaws.com/export.parquet?X-Amz-Expires=600&...
```

Files are available for 24 hours after completion. Signed links last ten minutes; call the download endpoint again for a fresh link.

## Export response fields

Create and poll responses include these fields:

Field | Description
--- | ---
`uuid`, `url` | The export's identifier and API URL.
`dataset`, `format` | The requested dataset and file format.
`state` | `pending`, `running`, `completed`, or `failed`.
`from`, `to` | Inclusive start and exclusive end of the exported period.
`row_count` | Number of rows, set on completion.
`download_url` | Download endpoint URL, available when completed and not expired.
`error_message` | Error description if the export failed.
`created_by_uuid` | UUID of the user who requested the export.
`created_at`, `started_at`, `finished_at` | When the export was requested, started, and finished.
`expires_at` | When the completed export expires.
{: class="responsive-table"}

## Limits

By default, an organization can have five exports in progress and request 60 exports per rolling 24 hours. Completed and failed exports count; polling and downloading don't. See the [overview limits](/docs/apis/request-log-exports#limits).
