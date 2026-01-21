# Agents API

The Buildkite Agents are small, reliable cross-platform build runners. Their main responsibilities are polling buildkite.com for work, running build jobs, reporting back the status code and output log of the job, and uploading the job's artifacts.

## Agent data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>UUID of the agent</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the agent</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the agent</td></tr>
  <tr><th><code>web_url</code></th><td>URL of the agent on Buildkite</td></tr>
  <tr><th><code>name</code></th><td>Name of the agent</td></tr>
  <tr><th><code>connection_state</code></th><td>Connection state: <code>connected</code>, <code>disconnected</code>, <code>stopping</code>, or <code>stopped</code></td></tr>
  <tr><th><code>hostname</code></th><td>Hostname of the machine running the agent</td></tr>
  <tr><th><code>ip_address</code></th><td>IP address of the agent</td></tr>
  <tr><th><code>user_agent</code></th><td>User agent string identifying the agent version and platform</td></tr>
  <tr><th><code>version</code></th><td>Version of the Buildkite Agent</td></tr>
  <tr><th><code>creator</code></th><td>User or token that registered the agent</td></tr>
  <tr><th><code>created_at</code></th><td>When the agent was registered</td></tr>
  <tr><th><code>job</code></th><td>Current job the agent is running (if any)</td></tr>
  <tr><th><code>last_job_finished_at</code></th><td>When the agent last finished a job</td></tr>
  <tr><th><code>priority</code></th><td>Priority value for job assignment</td></tr>
  <tr><th><code>meta_data</code></th><td>Array of agent tags in <code>key=value</code> format</td></tr>
</tbody>
</table>

## List agents

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's agents. The list only includes connected agents - agents in a disconnected state are not returned.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/agents"
```

```json
[
  {
    "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
    "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
    "web_url": "https://buildkite.com/organizations/my-great-org/clusters/78088c9a-6e72-4896-848d-e6f479f50c24/queues/c109939f-3b71-4cd3-b175-8eb79d2eb38e/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
    "name": "my-agent",
    "connection_state": "connected",
    "hostname": "some.server",
    "ip_address": "144.132.19.12",
    "user_agent": "buildkite-agent/2.1.0 (linux; amd64)",
    "version": "2.1.0",
    "creator": {
      "id": "2eba97bc-7cc7-427f-8feb-1008c72aa1d8",
      "name": "Keith Pitt",
      "email": "me@keithpitt.com",
      "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
      "created_at": "2015-05-09T21:05:59.874Z"
    },
    "created_at": "2014-02-24T22:33:45.263Z",
    "job": {
      "id": "cd164055-9649-452b-8d8e-28fe67370a1e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": "rspec",
      "agent_query_rules": ["*"],
      "state": "passed",
      "build_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50",
      "web_url": "https://buildkite.com/my-great-org/sleeper/builds/50#cd164055-9649-452b-8d8e-28fe67370a1e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/log.txt",
      "artifacts_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/artifacts",
      "script_path": "sleep 1",
      "command": "sleep 1",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "*",
      "agent": null,
      "created_at": "2015-07-30T12:58:22.942Z",
      "scheduled_at": "2015-07-30T12:58:22.935Z",
      "started_at": "2015-07-30T12:58:34.000Z",
      "finished_at": "2015-07-30T12:58:37.000Z"
    },
    "last_job_finished_at": null,
    "priority": null,
    "meta_data": ["key1=val1","key2=val2"]
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<table>
<tbody>
  <tr><th><code>name</code></th><td>Filters the results by the given agent name<p class="Docs__api-param-eg"><em>Example:</em> <code>?name=ci-agent-1</code></p></td></tr>
  <tr><th><code>hostname</code></th><td>Filters the results by the given hostname<p class="Docs__api-param-eg"><em>Example:</em> <code>?hostname=ci-box-1</code></p></td></tr>
  <tr><th><code>version</code></th><td>Filters the results by the given exact version number<p class="Docs__api-param-eg"><em>Example:</em> <code>?version=2.1.0</code></p></td></tr>
</tbody>
</table>

Required scope: `read_agents`

Success response: `200 OK`

## Get an agent

Returns the details for a single agent, looked up by unique ID. Any valid agents can be returned, including running and disconnected agents.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}"
```

```json
{
  "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
  "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
  "web_url": "https://buildkite.com/organizations/my-great-org/clusters/78088c9a-6e72-4896-848d-e6f479f50c24/queues/c109939f-3b71-4cd3-b175-8eb79d2eb38e/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
  "name": "my-agent",
  "connection_state": "connected",
  "hostname": "some.server",
  "ip_address": "144.132.19.12",
  "user_agent": "buildkite-agent/2.1.0 (linux; amd64)",
  "version": "2.1.0",
  "creator": {
    "id": "2eba97bc-7cc7-427f-8feb-1008c72aa1d8",
    "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
    "name": "Keith Pitt",
    "email": "me@keithpitt.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-09T21:05:59.874Z"
  },
  "created_at": "2015-05-09T21:05:59.874Z",
  "job": {
    "id": "cd164055-9649-452b-8d8e-28fe67370a1e",
    "graphql_id": "Sm9iLS0tZGM5YTg5MmQtM2I5Ny00MzgyLWEzYzItNWJhZmU5M2RlZWI1",
    "type": "script",
    "name": "rspec",
    "agent_query_rules": ["*"],
    "state": "passed",
    "build_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50",
    "web_url": "https://buildkite.com/my-great-org/sleeper/builds/50#cd164055-9649-452b-8d8e-28fe67370a1e",
    "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/log",
    "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/log.txt",
    "artifacts_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/sleeper/builds/50/jobs/cd164055-9649-452b-8d8e-28fe67370a1e/artifacts",
    "script_path": "sleep 1",
    "command": "sleep 1",
    "soft_failed": false,
    "exit_status": 0,
    "artifact_paths": "*",
    "agent": null,
    "created_at": "2015-07-30T12:58:22.942Z",
    "scheduled_at": "2015-07-30T12:58:22.935Z",
    "started_at": "2015-07-30T12:58:34.000Z",
    "finished_at": "2015-07-30T12:58:37.000Z"
  },
  "last_job_finished_at": null,
  "priority": null,
  "meta_data": ["key1=val1","key2=val2"]
}
```

Required scope: `read_agents`

Success response: `200 OK`

## Stop an agent

> 📘 Required permissions
> To stop an agent you need either:
> - An Admin user API token with `write_agents` [scope](/docs/apis/managing-api-tokens#token-scopes).
> - Or, if you're using the Buildkite organization's [security for pipelines](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines) feature, a user token with the **Stop Agents** permission.

Instruct an agent to stop accepting new build jobs and shut itself down.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}/stop" \
  -H "Content-Type: application/json" \
  -d '{
    "force": true
  }'
```

Optional [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>force</code></th><td>If the agent is currently processing a job, the job and the build will be canceled.<p class="Docs__api-param-eg"><em>Default:</em> <code>true</code></p></td></tr>
</tbody>
</table>

Required scope: `write_agents`

Success response: `204 No Content`

Error responses:

<table>
<tbody>
  <tr><th><code>400 Bad Request</code></th><td><code>{ "message": "Can only stop connected agents" }</code></td></tr>
</tbody>
</table>

## Pause an agent

> 📘 Required permissions
> To pause an agent you need either:
> - An Admin user API token with `write_agents` [scope](/docs/apis/managing-api-tokens#token-scopes).
> - Or, if you're using the Buildkite organization's [security for pipelines](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines) feature, a user token with the **Stop Agents** permission.

Prevent dispatching jobs to an agent, and instruct the agent (which would otherwise exit when the job either is completed or times out) to remain running after finishing its current job.

```bash
curl -H "Authorization: Bearer ${TOKEN}" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}/pause" \
  -H "Content-Type: application/json" \
  -d '{
    "note": "A short note explaining why this agent is being paused",
    "timeout_in_minutes": 60
  }'
```

Required scope: `write_agents`

Success response: `204 No Content`

Error responses:

<table>
<tbody>
  <tr><th><code>404 Not Found</code></th><td><code>{ "message": "No agent found" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Agent is already paused" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Only connected agents may be paused" }</code></td></tr>
</tbody>
</table>


## Resume an agent

> 📘 Required permissions
> To resume a paused agent you need either:
> - An Admin user API token with `write_agents` [scope](/docs/apis/managing-api-tokens#token-scopes).
> - Or, if you're using the Buildkite organization's [security for pipelines](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines) feature, a user token with the **Stop Agents** permission.

Resume dispatching jobs to an agent, and instruct the agent to resume normal operation.

```bash
curl -H "Authorization: Bearer ${TOKEN}" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}/resume" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Required scope: `write_agents`

Success response: `204 No Content`

Error responses:

<table>
<tbody>
<tr><th><code>404 Not Found</code></th><td><code>{ "message": "No agent found" }</code></td></tr>
<tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Agent is not paused" }</code></td></tr>
</tbody>
</table>


## Agent tokens

Agent tokens are created through the [clusters REST API endpoint](/docs/apis/rest-api/clusters/agent-tokens).
