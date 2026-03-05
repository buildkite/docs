---
toc: false
---

# Metrics API

The metrics API endpoint provides information on idle and busy agents, jobs, and queues for the [Agent token](/docs/agent/self-hosted/tokens) supplied in the request `Authorization` header.

## Get metrics

Get agent metrics

```bash
curl -H "Authorization: Token $BUILDKITE_AGENT_TOKEN" \
  -X GET "https://agent.buildkite.com/v3/metrics"
```

```json
{
  "agents": {
    "idle": 1,
    "busy": 0,
    "total": 1,
    "queues": {
      "default": {
        "idle": 1,
        "busy": 0,
        "total": 1
      }
    }
  },
  "jobs": {
    "scheduled": 5,
    "running": 0,
    "waiting": 0,
    "total": 5,
    "queues": {
      "default": {
        "scheduled": 5,
        "running": 0,
        "waiting": 0,
        "total": 5
      }
    }
  },
  "organization": {
    "slug": "buildkite"
  }
}
```

Success response: `200 OK`
