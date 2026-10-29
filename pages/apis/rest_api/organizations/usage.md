# Organization usage API

Use the organization usage API to retrieve active-user counts and product usage summaries for a Buildkite organization.

Any organization member can use this endpoint. The [API access token](/docs/apis/managing-api-tokens) must include the `read_organizations` scope and grant access to the requested organization.

## Get organization usage

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/usage"
```

Success response: `200 OK`. The following response excerpts omit other fields and metrics.

Concurrent agents:

```json
{
  "reporting_period": { "from": "2026-10-01", "to": "2026-10-27" },
  "pipelines": {
    "self_hosted_concurrent_agents_p95": {
      "value": 52,
      "unit": "agents",
      "definition": "95th percentile of the daily sums of each organization's peak self-hosted agent count."
    }
  }
}
```

Test executions:

```json
{
  "reporting_period": { "from": "2026-10-01", "to": "2026-10-27" },
  "test_engine": {
    "test_executions": {
      "value": 120000,
      "unit": "executions",
      "definition": "Total recorded test executions."
    }
  }
}
```

## Response fields

Each product metric includes a `value`, a `unit`, and a readable `definition`. Usage figures do not represent charges or included limits.

Field | Meaning
----- | -------
`description` | Short description of recorded organization usage and inclusive UTC dates.
`active_users_count` | Distinct active users across included organizations during `reporting_period`.
`active_users_count_definition` | The active-user `unit`, `definition`, and `period`. Its dates match `reporting_period`.
`reporting_period` | Inclusive UTC `from` and `to` dates for all metrics, including active users, formatted as `YYYY-MM-DD`.
`generated_at` | UTC computation time. Responses are cached for five minutes; this is not an ingestion timestamp.
`scope` | `organization`, or `organization_and_billing_children` for a parent and its direct billing children. Child requests exclude parents and siblings.
`pipelines` | [Buildkite Pipelines](/docs/pipelines) self-hosted job minutes, hosted virtual CPU minutes by platform, and concurrency statistics.
`test_engine` | [Buildkite Test Engine](/docs/pipelines/configure/tests) executions and managed tests: the sum of per-suite 90th-percentile (P90) daily distinct-test counts across included organizations.
`packages` | [Buildkite Package Registries](/docs/package-registries) peak storage and transfer bytes.
`artifacts` | [Artifact](/docs/pipelines/configure/artifacts) upload and download bytes, plus the latest storage snapshot within the reporting period. Storage is `null` if no snapshot is available.
{: class="responsive-table"}

## Usage period

All metrics default to calendar month to date. For example, on October 27, the reporting period is October 1–27. All boundaries use UTC, and today's figures are partial.

Supply optional `from` and `to` query parameters together, for example, `?from=2026-09-15&to=2026-10-14`. Both use `YYYY-MM-DD` dates and apply to all metrics, including `active_users_count`.

- `from` must be no earlier than today minus three calendar months.
- `to` must be on or after `from` and no later than today.
- The latest `to` is one calendar month after `from`, preserving month-end alignment, minus one day.

Users active in more than one included organization count once across the selected reporting period, including ranges that cross a calendar-month boundary.

To compare the response with the organization's [**Usage** page](https://buildkite.com/organizations/~/usage), select the same dates on both. Cached responses and ongoing ingestion can cause temporary differences. Use a completed date range that excludes today to reduce those differences.

## Error responses

Status | Meaning
------ | -------
`400 Bad Request` | Incomplete or invalid custom date range.
`403 Forbidden` | The token lacks the `read_organizations` scope.
`404 Not Found` | The organization does not exist, or the user or token cannot access it.
`503 Service Unavailable` | Usage is temporarily unavailable. Retry the request; no partial summary is returned.
{: class="responsive-table"}
