# Runs API

## Get a run

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/runs/{run.id}"
```

```json
{
  "id": "64374307-12ab-4b13-a3f3-6a408f644ea2",
  "branch": "main",
  "commit_sha": "e32432c045439c95b5af2cb472b4d8be2207685d",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2",
  "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug/runs/64374307-12ab-4b13-a3f3-6a408f644ea2"
}
```

Required scope: `read_suites`

Success response: `200 OK`
