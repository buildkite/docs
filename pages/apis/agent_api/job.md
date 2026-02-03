---
toc: false
---

# Job API

Exposes a local API to introspect and mutate the state of a running job through environment variables. This lets you write scripts, hooks, and plugins in languages other than Bash, using them to interact with the agent.

Promoted in v3.64.0.

The API uses a Unix Domain Socket, whose path is exposed to running jobs with the BUILDKITE_AGENT_JOB_API_SOCKET environment variable. Calls are authenticated using the Bearer HTTP Authorization scheme made available through a token in the BUILDKITE_AGENT_JOB_API_TOKEN environment variable.

The API provides the following endpoints:

GET /api/current-job/v0/env - Returns a JSON object of all environment variables for the current job.

PATCH /api/current-job/v0/env - Accepts a JSON object of environment variables to set for the current job.

DELETE /api/current-job/v0/env - Accepts a JSON array of environment variable names to unset for the current job.

See the agent repo for the full API request and response definitions.

The job API is unavailable on agents running versions of Windows before build 17063, as this was when Windows added Unix Domain Socket support. If you enable this experiment on an unsupported Windows agent, the agent outputs a warning and the API is unavailable.