# Build tests API

## List tests for a build

Returns a [paginated list](<%= paginated_resource_docs_url %>) of tests that ran in a Buildkite Pipelines build. Each test includes execution metrics aggregated over the build's time window. The response includes tests from every Test Engine suite associated with the build that the API token can access.

The build identifier must be the build UUID, not the pipeline build number.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/builds/{build.id}/tests"
```

```json
[
  {
    "id": "a915535c-a8f1-4e1a-bd6a-a5589e09f349",
    "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_name/tests/a915535c-a8f1-4e1a-bd6a-a5589e09f349",
    "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_name/tests/a915535c-a8f1-4e1a-bd6a-a5589e09f349",
    "scope": "User#email",
    "name": "is correctly formatted",
    "location": "./spec/models/user_spec.rb:42",
    "file_name": "./spec/models/user_spec.rb",
    "labels": ["flaky"],
    "reliability": 0.98,
    "duration_avg": 0.213,
    "duration_sum": 23.856,
    "duration_min": 0.108,
    "duration_max": 1.942,
    "executions_count": 113,
    "executions_count_by_result": {
      "passed": 110,
      "failed": 2,
      "skipped": 1
    }
  }
]
```

The aggregation window starts when the build is created, unless the organization's maximum Test Engine time window requires a later start. It ends when the build finishes. For a running build, the window ends at the current time. The window cannot extend beyond 24 hours after the build was created.

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>reliability</code></th>
    <td>The reliability of the test, calculated from its passed and failed executions and expressed as a decimal fraction. This is <code>null</code> when the test has no passed or failed executions in the build.</td>
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
    <td>The number of executions in the build.</td>
  </tr>
  <tr>
    <th><code>executions_count_by_result</code></th>
    <td>The number of executions in the build, broken down by result. The <code>passed</code> and <code>failed</code> counts are always present. The <code>skipped</code>, <code>pending</code>, and <code>unknown</code> counts are only present when they're non-zero.</td>
  </tr>
</tbody>
</table>

### Query string parameters

Some [query string parameters](/docs/api#query-string-parameters) support one or more of the additional operators listed below.

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>!</code></th>
    <td>Excludes the specified value.</td>
  </tr>
  <tr>
    <th><code>*</code></th>
    <td>Matches values that start with the specified value.</td>
  </tr>
  <tr>
    <th><code>~</code></th>
    <td>Returns groups that contain at least one matching execution. This operator is only available for the <code>result</code> tag.</td>
  </tr>
  <tr>
    <th><code>^</code></th>
    <td>Returns groups where every execution matches. This operator is only available for the <code>result</code> tag.</td>
  </tr>
</tbody>
</table>

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>labels</code></th>
    <td>
      <span>Filters the results by a comma-separated list of test labels.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?labels=flaky,!slow</code></p>
      <p><em>Supported operators:</em> <code>!</code></p>
    </td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td>
      <span>Only aggregates executions from branches that match the specified value. Use at most one operator.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?branch=feature*</code></p>
      <p><em>Supported operators:</em> <code>! *</code></p>
    </td>
  </tr>
  <tr>
    <th><code>owners</code></th>
    <td>
      <span>Filters the results by a comma-separated list of test owner slugs.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?owners=payments,!platform</code></p>
      <p><em>Supported operators:</em> <code>!</code></p>
    </td>
  </tr>
  <tr>
    <th><code>state</code></th>
    <td>
      <span>Filters the results by test state. Valid values are <code>enabled</code>, <code>muted</code>, and <code>skipped</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?state=muted</code></p>
    </td>
  </tr>
  <tr>
    <th><code>tags</code></th>
    <td>
      <span>Filters the results by a comma-separated list of execution tags, using <code>key:value</code> syntax. A <code>build.id</code> filter cannot override the build UUID in the request path.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?tags=framework:!rspec,scm.branch:feature*,result:^passed</code></p>
      <p><em>Supported operators:</em> <code>! *</code>. The <code>result</code> tag also supports <code>^ ~</code>.</p>
    </td>
  </tr>
  <tr>
    <th><code>sort_by</code></th>
    <td>
      <span>The metric to sort the results by. Valid values are <code>duration_avg</code>, <code>duration_sum</code>, <code>duration_min</code>, <code>duration_max</code>, and <code>reliability</code>. The default value is <code>duration_avg</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?sort_by=reliability</code></p>
    </td>
  </tr>
  <tr>
    <th><code>order</code></th>
    <td>
      <span>The direction to sort the results in. Valid values are <code>asc</code> and <code>desc</code>. The default value is <code>desc</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?order=asc</code></p>
    </td>
  </tr>
</tbody>
</table>

This endpoint is [paginated](/docs/apis/rest-api#pagination).

Required scope: `read_suites`

Success response: `200 OK`
