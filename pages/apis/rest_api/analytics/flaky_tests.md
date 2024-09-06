# Flaky tests API

The Flaky test API endpoint provides information about tests detected as flaky in a test suite.

## List all flaky tests

Returns a [paginated list](<%= paginated_resource_docs_url %>) of the flaky tests detected in a test suite.

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
    "last_resolved_at": null
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/analytics/flaky_tests_query_strings' %>

Required scope: `read_suites`

Success response: `200 OK`
