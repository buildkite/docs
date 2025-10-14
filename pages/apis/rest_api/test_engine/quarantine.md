# Quarantine API

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can access Buildkite Test Engine's quarantine feature.

Before using the API calls on this page, ensure that test state management has been enabled for your suite (through your test suite's **Settings** > **Test state** page), and that the relevant **Lifecycle** states have been selected on this page.

## Update test state

### Skip test

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/{test.id}/skip"
```

```json
{
  "id":"80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "url":"http://api.buildkite.com/v2/analytics/organizations/buildkite/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "web_url":"http://buildkite.com/organizations/buildkite/analytics/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "scope":"Flaky test",
  "name":"passes only on the second try on BK CI",
  "location":"./spec/flaky_spec.rb:6",
  "file_name":"./spec/flaky_spec.rb"
}
```

Required scope: `write_suites`

Success response: `200 OK`

### Mute test

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/{test.id}/mute"
```

```json
{
  "id":"80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "url":"http://api.buildkite.com/v2/analytics/organizations/buildkite/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "web_url":"http://buildkite.com/organizations/buildkite/analytics/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "scope":"Flaky test",
  "name":"passes only on the second try on BK CI",
  "location":"./spec/flaky_spec.rb:6",
  "file_name":"./spec/flaky_spec.rb"
}
```

Required scope: `write_suites`

Success response: `200 OK`

### Enable test

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/{test.id}/enable"
```

```json
{
  "id":"80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "url":"http://api.buildkite.com/v2/analytics/organizations/buildkite/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "web_url":"http://buildkite.com/organizations/buildkite/analytics/suites/my-sample-suite/tests/80b455d3-d197-8c6d-a7bf-09d252c1bf6e",
  "scope":"Flaky test",
  "name":"passes only on the second try on BK CI",
  "location":"./spec/flaky_spec.rb:6",
  "file_name":"./spec/flaky_spec.rb"
}
```

Required scope: `write_suites`

Success response: `200 OK`

## List quarantined tests
A list of skipped tests or muted tests can be retrieved via the following APIs. You can use this list to configure your test runner to skip or ignore failures for these tests.

### Muted tests

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/muted"
```

```json
[
  {
    "id":"160988e4-836e-88ab-af45-22170a169e23",
    "url":"http://api.buildkite.com/v2/analytics/organizations/buildkite/suites/my-sample-suite/tests/160988e4-836e-88ab-af45-22170a169e23",
    "web_url":"http://buildkite.com/organizations/buildkite/analytics/suites/my-sample-suite/tests/160988e4-836e-88ab-af45-22170a169e23",
    "scope":"Flaky test",
    "name":"passes only on the second try on BK CI",
    "location":"flaky.spec.js:1",
    "file_name":"flaky.spec.js"
  }
]
```

Required scope: `read_suites`

Success response: `200 OK`

### Skipped tests

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/tests/skipped"
```

```json
[
  {
    "id":"160988e4-836e-88ab-af45-22170a169e23",
    "url":"http://api.buildkite.com/v2/analytics/organizations/buildkite/suites/my-sample-suite/tests/160988e4-836e-88ab-af45-22170a169e23",
    "web_url":"http://buildkite.com/organizations/buildkite/analytics/suites/my-sample-suite/tests/160988e4-836e-88ab-af45-22170a169e23",
    "scope":"Flaky test",
    "name":"passes only on the second try on BK CI",
    "location":"flaky.spec.js:1",
    "file_name":"flaky.spec.js"
  }
]
```

Required scope: `read_suites`

Success response: `200 OK`
