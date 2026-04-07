# Flaky tests API

To retrieve flaky tests via the API, use the [list tests endpoint](/docs/apis/rest-api/test-engine/tests#list-tests) with the `label=flaky` query parameter:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests?label=flaky"
```

Required scope: `read_suites`

Success response: `200 OK`

## Legacy flaky tests endpoint (deprecated)

> 🚧 This endpoint is deprecated
> Use the [list tests endpoint](/docs/apis/rest-api/test-engine/tests#list-tests) with `?label=flaky` instead.

The legacy flaky tests endpoint is still available but no longer recommended. It does not return the same data as the Test Engine UI.

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
