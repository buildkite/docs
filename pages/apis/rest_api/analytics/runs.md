# Runs API

## List all runs

Returns a [paginated list](<%= paginated_resource_docs_url %>) of runs in a test suite.

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs"
```

```json
[
  {
    "id": "64374307-12ab-4b13-a3f3-6a408f644ea2",
    "branch": "main",
    "commit_sha": "1c3214fcceb2c14579a2c3c50cd78f1442fd8936",
    "state": "finished",
    "result": "passed",
    "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2",
    "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2",
    "created_at": "2023-06-25T05:32:53.228Z"
  }
]
```

Required scope: `read_suites`

Success response: `200 OK`

## Get a run

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs/{run.id}"
```

```json
{
  "id": "64374307-12ab-4b13-a3f3-6a408f644ea2",
  "branch": "main",
  "commit_sha": "1c3214fcceb2c14579a2c3c50cd78f1442fd8936",
  "state": "finished",
  "result": "passed",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2",
  "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2",
  "created_at": "2023-06-25T05:32:53.228Z"
}
```

Required scope: `read_suites`

Success response: `200 OK`

Runs are created with a `state` of `running` and proceed to `finished` when all uploads have been processed. The run may return to `running` if additional results are uploaded.

`result` starts as `pending` and may proceed to `passed` or `failed` once finished. If a run does not complete within a reasonable time period it may also proceed to `stale`. `result` may change back to `pending` or change between `passed` and `failed` if additional results are uploaded.
