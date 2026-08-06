# Tests API

## List tests

Lists the tests in a suite, along with aggregated duration, reliability, and execution metrics for each test over a time range.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Buildkite-Version: 2026-07-23" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests"
```

```json
[
  {
    "id": "01867216-8478-7fde-a55a-0300f88bb49b",
    "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
    "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
    "scope": "User#email",
    "name": "is correctly formatted",
    "location": "./spec/models/user_spec.rb:42",
    "file_name": "./spec/models/user_spec.rb",
    "labels": ["flaky"],
    "reliability": 98.21,
    "duration_avg": 0.213,
    "duration_sum": 23.856,
    "duration_min": 0.108,
    "duration_max": 1.942,
    "executions_count": 112,
    "executions_count_by_result": {
      "passed": 110,
      "failed": 2
    }
  }
]
```

The `Buildkite-Version` request header opts in to the versioned response shown above, which includes the aggregated metrics. Requests made without this header receive a response which contains only the test attributes `id` through `labels`.

The aggregated metrics in each test are calculated over the time range set by the `period`, `min_timestamp`, and `max_timestamp` query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>reliability</code></th>
    <td>The <a href="/docs/pipelines/configure/tests/test-suites#tracking-reliability">reliability</a> of the test, calculated from its passed and failed executions. This is <code>null</code> when the test has no passed or failed executions in the time range.</td>
  </tr>
  <tr>
    <th><code>duration_avg</code></th>
    <td>The average execution duration, in seconds.</td>
  </tr>
  <tr>
    <th><code>duration_sum</code></th>
    <td>The total execution duration, in seconds.</td>
  </tr>
  <tr>
    <th><code>duration_min</code></th>
    <td>The shortest execution duration, in seconds.</td>
  </tr>
  <tr>
    <th><code>duration_max</code></th>
    <td>The longest execution duration, in seconds.</td>
  </tr>
  <tr>
    <th><code>executions_count</code></th>
    <td>The number of executions in the time range.</td>
  </tr>
  <tr>
    <th><code>executions_count_by_result</code></th>
    <td>The number of executions in the time range, broken down by result. The <code>passed</code> and <code>failed</code> counts are always present. The <code>skipped</code>, <code>pending</code>, and <code>unknown</code> counts are only present when they're non-zero.</td>
  </tr>
</tbody>
</table>

### Query string parameters

Some [query string parameters](/docs/api#query-string-parameters) support one or more of the additional operators listed below.

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>!</code></th>
    <td>
      Not equal
      <p class="Docs__api-param-eg"><em>Example:</em> Tests labeled with <code>foo</code> but not <code>bar</code> - <code>labels=foo,!bar</code></p>
    </td>
  </tr>
  <tr>
    <th><code>~</code></th>
    <td>
      Group contains
      <p class="Docs__api-param-eg"><em>Example:</em> tests with one or more failed executions within the requested time period <code>tags=result:~failed</code></p>
    </td>
  </tr>
  <tr>
    <th><code>^</code></th>
    <td>
      Group only
      <p class="Docs__api-param-eg"><em>Example:</em> tests with only failed executions within the requested time period <code>tags=result:^failed</code></p>
    </td>
  </tr>
  <tr>
    <th><code>*</code></th>
    <td>
      Starts with
      <p class="Docs__api-param-eg"><em>Example:</em> tests wth executions on branches with the staging- prefix within the requested time period <code>branch=staging-*</code></p>
    </td>
  </tr>
</tbody>
</table>

<%= render_markdown partial: 'apis/rest_api/test_engine/tests_list_query_strings' %>

Optional request headers:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>Buildkite-Version</code></th>
    <td>
      Request an API version using a date in <code>YYYY-MM-DD</code> format. Set to <code>2026-08-01</code> or a later date to receive test metrics in the response. Without this header, or with a date before <code>2026-08-01</code>, the response uses the legacy format without metrics.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>Buildkite-Version: 2026-08-01</code></p>
    </td>
  </tr>
</tbody>
</table>

> 📘 Invalid format returns an error
> If a non-blank `Buildkite-Version` header value is not in `YYYY-MM-DD` format, the API returns a `400` response with `{"message": "Buildkite-Version must be in format YYYY-MM-DD"}`. A blank value is treated as an omitted header, so the API returns the legacy `200` response instead.

This endpoint is [paginated](/docs/apis/rest-api#pagination).

Required scope: `read_suites`

Success response: `200 OK`

## Get a test

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/{test.id}"
```

```json
{
  "id": "01867216-8478-7fde-a55a-0300f88bb49b",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
  "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
  "scope": "User#email",
  "name": "is correctly formatted",
  "location": "./spec/models/user_spec.rb:42",
  "file_name": "./spec/models/user_spec.rb",
  "labels": ["flaky"]
}
```

Required scope: `read_suites`

Success response: `200 OK`

## Find a test with scope and name

In some situations, you may not have access to UUID to make a call to Test Engine API.
You can locate a test record using its scope and name to retrieve the UUID from the response.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/find" \
  -H "Content-Type: application/json" \
  -d '{
    "scope": "User#email",
    "name": "is correctly formatted"
  }'
```

```json
{
  "id": "01867216-8478-7fde-a55a-0300f88bb49b",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
  "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
  "scope": "User#email",
  "name": "is correctly formatted",
  "location": "./spec/models/user_spec.rb:42",
  "file_name": "./spec/models/user_spec.rb",
}
```

Required scope: `read_suites`

Success response: `200 OK`

## Add or remove labels from a test

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/{test.id}/labels" \
  -H "Content-Type: application/json" \
  -d '{
    "operator": "add",
    "labels": ["flaky", "slow"]
  }'
```

```json
{
    "file_name": "./spec/features/cool_spec.rb",
    "id": "ccd837ee-d484-8864-a6ee-29cfae965bd8",
    "labels": [
        "flaky", "slow"
    ],
    "location": "./spec/features/cool_spec.rb:232",
    "name": "one plus one",
    "scope": "A fancy feature",
    "url": "https://api.buildkite.com/v2/analytics/organizations/acme-inc/suites/acme-suite/tests/ccd837ee-d484-8864-a6ee-29cfae965bd8",
    "web_url": "https://buildkite.com/organizations/acme-inc/analytics/suites/acme-suite/tests/ccd837ee-d484-8864-a6ee-29cfae965bd8"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>operator</code></th>
    <td>The operation that will be apply to labels.<br><code>"add"</code> or <code>"remove"</code>.</td>
  </tr>
  <tr>
    <th><code>labels</code></th>
    <td>The labels that will be added or removed. <br><em>Example:</em> <code>["flaky"]</code>.</td>
  </tr>
</tbody>
</table>

Required scope: `write_suites`

Success response: `200 OK`
