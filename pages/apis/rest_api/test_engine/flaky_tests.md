# Flaky tests API

> 🚧 This section documents a deprecated Buildkite API endpoint
> Flaky tests should be accessed via the [list tests endpoint](/docs/apis/rest-api/test-engine/tests#list-tests) using the `label=flaky` query parameter.


The flaky test API endpoint provides information about tests detected as flaky in a test suite.

## List all flaky tests

Returns a [paginated list](<%= paginated_resource_docs_url %>) of the flaky tests detected in a test suite. Please note that the `last_resolved_at` field represents a deprecated feature in Test Engine and should not be relied upon.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/flaky-tests"
```

```json
[
  {
    "id": "01867216-8478-7fde-a55a-0300f88bb49b",
    "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_name/tests/01867216-8478-7fde-a55a-0300f88bb49b",
    "scope": "User#email",
    "name": "is correctly formatted",
    "location": "./spec/models/user_spec.rb:42",
    "file_name": "./spec/models/user_spec.rb",
    "instances": 1,
    "latest_occurrence_at": "2024-07-15T00:07:02.547Z",
    "most_recent_instance_at": "2024-07-15T00:07:02.547Z",
    "last_resolved_at": null,
    "ownership_team_ids": ["4c15a4c7-6674-4585-b592-4adcc8630383", "d30fd7ba-82d8-487f-9d98-6e1a057bcca8"]
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/test_engine/flaky_tests_query_strings' %>

Required scope: `read_suites`

Success response: `200 OK`
