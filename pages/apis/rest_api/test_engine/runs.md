# Runs API

## List all runs

Returns a [paginated list](<%= paginated_resource_docs_url %>) of runs in a test suite.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs"
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
    "build_id": "89c02425-7712-4ee5-a694-c94b56b4d54c",
    "created_at": "2023-06-25T05:32:53.228Z"
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/test_engine/runs_list_query_strings' %>

Required scope: `read_suites`

Success response: `200 OK`

## Get a run

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs/{run.id}"
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
  "build_id": "89c02425-7712-4ee5-a694-c94b56b4d54c",
  "created_at": "2023-06-25T05:32:53.228Z"
}
```

Required scope: `read_suites`

Success response: `200 OK`

Runs are created with a `state` of `running` and proceed to `finished` when all uploads have been processed. The run may return to `running` if additional results are uploaded.

Run `result` starts as `pending` and will proceed to `passed` or `failed` when at least one test result has been processed.  The presence of a `passed` or `failed` result does not indicate that the run has finished processing. `result` may change from `passed` to `failed` if additional results are uploaded. The `result` is `failed` when there is at least one failing test in the run, and it is not possible for `result` to change from `failed`. If a run receives no results within a reasonable time period its `result` will proceed to `stale`.

## Get failed execution data

Returns a [paginated list](<%= paginated_resource_docs_url %>) of failed executions for a run.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs/{run.id}/failed_executions"
```

```json
[
  {
    "execution_id": "60f0e64c-ae4b-870e-b41f-5431205caf06",
    "run_id": "075bbcd9-662c-86f5-9d40-adfa6549eff1",
    "test_id": "f6cb6c43-df94-8b60-81ed-14f9db7bbfd8",
    "run_name": "075bbcd9-662c-86f5-9d40-adfa6549eff1",
    "commit_sha": "1c3214fcceb2c14579a2c3c50cd78f1442fd8936",
    "created_at": "2025-02-03T05:32:53.228Z",
    "branch": "main",
    "failure_reason": "it didn't work",
    "duration": 3.79073,
    "location": "./spec/models/user.rb:23",
    "test_name": "Deploy should be available",
    "run_url": "https:://buildkite.com/organizations/buildkite/analytics/suites/my-test-suite/runs/075bbcd9-662c-86f5-9d40-adfa6549eff1",
    "test_url": "https:://buildkite.com/organizations/buildkite/analytics/suites/my-test-suite/tests/f6cb6c43-df94-8b60-81ed-14f9db7bbfd8",
    "test_execution_url": "https:://buildkite.com/organizations/buildkite/analytics/suites/my-test-suite/tests/f6cb6c43-df94-8b60-81ed-14f9db7bbfd8?execution_id=60f0e64c-ae4b-870e-b41f-5431205caf06",
  }
]
```

Required scope: `read_suites`

Success response: `200 OK`
