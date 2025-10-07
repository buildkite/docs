# Tests API

## List tests

```bash
curl -H "Authorization: Bearer $TOKEN" \
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
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/test_engine/tests_list_query_strings' %>

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
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{suite.uuid}/tests/{test.id}/labels" \
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
  <tr><th><code>operator</code></th><td>The operation that will be apply to labels.<br><code>"add"</code> or <code>"remove"</code>.</td></tr>
  <tr><th><code>labels</code></th><td>The labels that will be added or removed. <br><em>Example:</em> <code>["flaky"]</code>.</td></tr>
</tbody>
</table>

Required scope: `write_suites`

Success response: `200 OK`
