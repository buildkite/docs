# Flaky tests API

The Flaky test API endpoint provides information about tests detected as flaky in a test suite.

{:toc}

## List all flaky tests

Returns a [paginated list](<%= paginated_resource_docs_url %>) of the flaky tests detected in a test suite.

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/flaky-tests"
```

```json
[
  {
    "id": ":test_id",
    "web_url": "/organizations/my_great_org/analytics/suites/my_suite_name/tests/:test_id",
    "scope": "My test scope",
    "name": "My test name",
    "location": null,
    "file_name": null,
    "instances": 1,
    "most_recent_instance_at": "2023-02-14T23:19:03.223Z"
  }
]
```

Required scope: `read_flaky_tests`

Success response: `200 OK`
