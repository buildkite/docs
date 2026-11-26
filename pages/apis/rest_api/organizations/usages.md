# Organization daily usage API

Use `GET /v2/organizations/{org.slug}/usages/{resource}` to retrieve recorded daily usage for one Buildkite organization. Replace `{org.slug}` with the organization slug and `{resource}` with one of the resources listed on this page. Unlike the [organization usage API](/docs/apis/rest-api/organizations/usage), these endpoints return daily measurements, not billing summaries or percentiles.

Any organization member can use these endpoints. The [API access token](/docs/apis/managing-api-tokens#token-scopes-billing) must include the `read_usages` scope and grant access to the requested organization. Resource grants don't filter the usage data returned for that organization.

Each response is a JSON array in ascending date order. Resources with a breakdown can return multiple rows per day, such as one row per suite. The API does not fill in missing days with zeros. If a page has no rows, the API returns `[]`.

## Date range

Supply `from` and `to` together as inclusive dates in `YYYY-MM-DD` format, for example, `?from=2026-11-01&to=2026-11-12`. The `from` date must be within the last two years and cannot be later than `to`. The range can span at most two years.

If you omit both dates, the API uses the default date range shown on the organization's [**Usage** page](https://buildkite.com/organizations/~/usage). The range depends on the organization's subscription.

## Pagination

These endpoints use [page-based pagination](/docs/apis/rest-api#pagination) with these limits:

- `page`: Defaults to `1`. Values below `1` are treated as `1`, and values above `1000000` are capped at `1000000`.
- `per_page`: Defaults to `500` if omitted or blank. Values above `2000` are capped at `2000`. Values that parse to less than `1` return `400 Bad Request`.

Follow `rel="next"` in the `Link` response header until there is no `next` link. Pages after the first also include `prev` and `first` links, even on the final page. The API does not send a `last` link. The URLs preserve any explicit dates and include `per_page` only when it differs from the default:

```http
Link: <https://api.buildkite.com/v2/organizations/{org.slug}/usages/managed_tests?from=2026-11-07&page=2&per_page=2&to=2026-11-10>; rel="next"
```

## Pipelines

Get daily usage for active users, jobs, and concurrent agents in Buildkite Pipelines.

### Get active user usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/active_users?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "active_users": 3 },
  { "date": "2026-11-08", "active_users": 3 }
]
```

Returns the count of distinct active users per day.

### Get self-hosted job usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/self_hosted_jobs?from=2026-11-07&to=2026-11-10"
```

```json
[
  {
    "date": "2026-11-07",
    "pipeline_uuid": "01a20fd8-9232-483a-8958-c82a80e0126d",
    "duration_microseconds": 5400000000,
    "job_count": 42
  }
]
```

Returns job count and total duration in microseconds per day and pipeline, for jobs that ran on self-hosted agents.

The API returns `null` for `pipeline_uuid` if it can no longer resolve the pipeline ID. This also applies to hosted jobs.

### Get hosted job usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/hosted_jobs?from=2026-11-07&to=2026-11-10"
```

```json
[
  {
    "date": "2026-11-07",
    "pipeline_uuid": "01a20fd8-9232-483a-8958-c82a80e0126d",
    "instance_shape": "linux_amd64_2_4",
    "duration_microseconds": 1800000000,
    "job_count": 12
  }
]
```

Returns job count and total duration in microseconds per day, pipeline, and [instance shape](/docs/agent/buildkite-hosted/linux#sizes), for jobs that ran on Buildkite-hosted agents.

### Get self-hosted concurrent agent usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/self_hosted_concurrent_agents?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "agents": 18 }
]
```

Returns the peak number of concurrently connected self-hosted agents per day.

### Get hosted concurrent agent usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/hosted_concurrent_agents?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "agents": 6 }
]
```

Returns the peak number of concurrently running Buildkite-hosted agents per day.

## Test Engine

Get daily usage by suite for Buildkite Test Engine.

### Get managed test usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/managed_tests?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "suite_uuid": "0193a6f2-6c1e-7b9a-9d2f-3f1c2b4a5e61", "managed_tests": 1250 }
]
```

Returns the latest managed test count per day and suite.

### Get test execution usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/test_executions?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "suite_uuid": "0193a6f2-6c1e-7b9a-9d2f-3f1c2b4a5e61", "executions": 48300 }
]
```

Returns the number of test executions per day and suite.

### Get OpenTelemetry ingestion usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/otel_ingestion?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "suite_uuid": "0193a6f2-6c1e-7b9a-9d2f-3f1c2b4a5e61", "bytes": 72200000 }
]
```

Returns decoded OpenTelemetry trace bytes ingested per day and suite, excluding test-result span bytes.

### Get OpenTelemetry storage usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/otel_storage?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "suite_uuid": "0193a6f2-6c1e-7b9a-9d2f-3f1c2b4a5e61", "spans": 912000 }
]
```

Returns the number of OpenTelemetry spans stored per day and suite, excluding test-result spans.

## Artifacts

Get daily storage, upload, and download usage by pipeline.

### Get artifact storage usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/artifact_storage?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "pipeline_uuid": "01a20fd8-9232-483a-8958-c82a80e0126d", "bytes": 52428800000 }
]
```

Returns the latest [artifact](/docs/pipelines/configure/artifacts) storage snapshot in bytes per day and pipeline.

### Get artifact upload usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/artifact_uploads?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "pipeline_uuid": "01a20fd8-9232-483a-8958-c82a80e0126d", "bytes": 1073741824 }
]
```

Returns artifact bytes uploaded per day and pipeline.

### Get artifact download usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/artifact_downloads?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "pipeline_uuid": "01a20fd8-9232-483a-8958-c82a80e0126d", "bytes": 3221225472 }
]
```

Returns artifact bytes downloaded per day and pipeline.

## Package Registries

Get daily storage and transfer usage by registry, including Packagecloud registries.

### Get package storage usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/package_storage?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "registry_uuid": "0193a6f2-8e44-7c10-a1b3-5d7e9f0a2c84", "bytes": 8589934592 }
]
```

Returns the latest storage snapshot in bytes per day and [registry](/docs/package-registries).

### Get package transfer usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/package_transfer?from=2026-11-07&to=2026-11-10"
```

```json
[
  { "date": "2026-11-07", "registry_uuid": "0193a6f2-8e44-7c10-a1b3-5d7e9f0a2c84", "bytes": 2147483648 }
]
```

Returns package transfer bytes per day and registry.

## Cache

Get daily Buildkite Cache usage by cluster.

### Get cache usage

> 📘 Requires hosted cache usage to be enabled
> This endpoint returns `404 Not Found` if hosted cache usage isn't enabled for your organization.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/cache?from=2026-11-07&to=2026-11-10"
```

```json
[
  {
    "date": "2026-11-07",
    "cluster_uuid": "0193a6f2-a1d0-7e55-b6c2-8e4f1a3d5b97",
    "reads_bytes": 21474836480,
    "storage_gb_minutes": 72000
  }
]
```

Returns [Buildkite Cache](/docs/pipelines/configure/cache) read bytes and storage, in GB-minutes, per day and cluster.

## Hosted models

Get daily token and request counts by provider, model, and hosting type.

### Get Anthropic token usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/anthropic_tokens?from=2026-11-07&to=2026-11-10"
```

```json
[
  {
    "date": "2026-11-07",
    "model": "claude-sonnet-4-6",
    "self_hosted": 0,
    "input_tokens": 182000,
    "output_tokens": 24500,
    "cache_read_input_tokens": 0,
    "ephemeral_5m_input_tokens": 9000,
    "ephemeral_1h_input_tokens": 0,
    "web_search_requests": 0,
    "request_count": 1
  }
]
```

Returns token and request counts per day, model, and hosting, for the [Anthropic model provider](/docs/apis/model-providers/anthropic). `self_hosted` is `1` when the request used your own Anthropic credentials, and `0` when it used Buildkite-hosted access.

### Get OpenAI token usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usages/openai_tokens?from=2026-11-07&to=2026-11-10"
```

```json
[
  {
    "date": "2026-11-07",
    "model": "gpt-5",
    "self_hosted": 0,
    "input_tokens": 96000,
    "output_tokens": 18000,
    "cached_tokens": 41000,
    "reasoning_tokens": 6200,
    "request_count": 1
  }
]
```

Returns token and request counts per day, model, and hosting, for the [OpenAI model provider](/docs/apis/model-providers/openai). `self_hosted` is `1` when the request used your own OpenAI credentials, and `0` when it used Buildkite-hosted access.

## Error responses

Status | Meaning
------ | -------
`400 Bad Request` | Only one date was supplied, the date range is invalid, or `per_page` parses to less than `1`.
`403 Forbidden` | The token lacks the `read_usages` scope.
`404 Not Found` | The organization doesn't exist or isn't accessible to the caller. For `cache`, this status also means hosted cache usage isn't enabled for the organization.
{: class="responsive-table"}
