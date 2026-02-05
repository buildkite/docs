---
toc: false
---

# Internal job API

Exposes a local/internal API for the currently running job, to query and mutate the state of this job through environment variables. This lets you write scripts, hooks, and plugins in languages other than Bash, using them to interact with the agent.

This API uses a Unix domain socket, whose path is exposed to running jobs with the `BUILDKITE_AGENT_JOB_API_SOCKET` environment variable. Calls are authenticated using the Bearer HTTP Authorization scheme made available through a token in the `BUILDKITE_AGENT_JOB_API_TOKEN` environment variable.

The API provides the following endpoints:

- `GET /api/current-job/v0/env`: Returns a JSON object of all environment variables for the current job.

- `PATCH /api/current-job/v0/env`: Accepts a JSON object of environment variables to set for the current job.

- `DELETE /api/current-job/v0/env`: Accepts a JSON array of environment variable names to unset for the current job.

An example `curl` call to the internal job API using the `GET` method, would have the following format:

```bash
curl --unix-socket "$BUILDKITE_AGENT_JOB_API_SOCKET" \
  -X GET \
  -H "Authorization: Bearer $BUILDKITE_AGENT_JOB_API_TOKEN" \
  "http://job/api/current-job/v0/env"
```

where `http://job/...` is a placeholder hostname, which is required for the HTTP-over-Unix socket (`--unix-socket`), but is ignored.

This would return a response format similar to the following:

```json
{
  "env": {
    "BUILDKITE_PIPELINE_SLUG": "my-pipeline",
    "BUILDKITE_BUILD_NUMBER": "123",
    "MY_CUSTOM_VAR": "value"
  }
}
```

See the [`payloads.go` file of the `agent` source repository](https://github.com/buildkite/agent/blob/main/jobapi/payloads.go) for the full API request and response definitions.

The internal job API is unavailable on agents running versions of Windows before build 17063, as this was when Windows added Unix Domain Socket support. If you enable this experiment on an unsupported Windows agent, the agent outputs a warning and the API is unavailable.
