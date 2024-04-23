# Tests API

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
