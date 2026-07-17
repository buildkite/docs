# Execution tags API

The execution tags endpoint permits modification of mutable tags with the `mut.` prefix on executions.

The endpoint is designed for bulk insert. It has a low rate limit but supports a large number of executions per request.

All mutable tags for a given execution are replaced with those in the payload. To delete all mutable tags for an execution, send an empty tag set - `"tags: {}"`.


- Default rate limit is 1 request per minute.
- Default execution limit per request is 100,000.
- Default maximum mutable tags per execution is 10.
- All tags in the payload must begin with the `mut.` prefix.

## Update execution tags

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -d @payload.json
  -X PUT "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/execution-tags"
```

```json
{
  "executions": [
    {
      "id":"019eddd0-3d40-7582-a010-7eb1967c61d9",
      "tags": {
        "mut.classification":"infrastructure",
        "mut.reason":"api_timeout"
      }
    },
    {
      "id":"01867216-8478-7fde-a55a-0300f88bb49b",
      "tags": {
        "mut.label":"flaky"
      }
    }
  ]
}
```

Required scope: `write_suites`

Success response: `200 OK`
