# Suites API
## Get a suite

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}"
```

```json

  {
    "slug":"my_suite_slug",
    "name":"My suite name",
    "url":"https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug",
    "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug",
    "default_branch":"main"
  }

```

Required scope: `read_suites`

Success response: `200 OK`
