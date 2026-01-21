# Builds API

A build is a single run of a pipeline. You can trigger a build in various ways, including through the dashboard, API, as the result of a webhook, on a schedule, or even from another pipeline using a trigger step.

## Build number vs build ID

All builds have a _build ID_ (for example, `01908131-7d9f-495e-a17b-80ed31276810`), which is a unique value throughout the entire Buildkite platform, as well as a _build number_ (for example, `27`). A build number is unique to a pipeline, and its value is incremented with each build, although there may be occasional gaps.

Note that some API request types on this page, especially those involving only a single build, require using a build number rather than a build ID.

## Build data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>UUID of the build</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the build</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the build</td></tr>
  <tr><th><code>web_url</code></th><td>URL of the build on Buildkite</td></tr>
  <tr><th><code>number</code></th><td>Build number within the pipeline (unique per pipeline, may have gaps)</td></tr>
  <tr><th><code>state</code></th><td>Current state of the build: <code>scheduled</code>, <code>running</code>, <code>passed</code>, <code>failed</code>, <code>blocked</code>, <code>canceled</code>, <code>canceling</code>, <code>skipped</code>, <code>not_run</code>, <code>waiting</code>, or <code>waiting_failed</code></td></tr>
  <tr><th><code>blocked</code></th><td>Whether the build is blocked waiting on a block step (<code>true</code>, <code>false</code>)</td></tr>
  <tr><th><code>cancel_reason</code></th><td>Reason provided when the build was canceled (if applicable)</td></tr>
  <tr><th><code>message</code></th><td>Commit message or custom message for the build</td></tr>
  <tr><th><code>commit</code></th><td>Git commit SHA being built</td></tr>
  <tr><th><code>branch</code></th><td>Git branch being built</td></tr>
  <tr><th><code>env</code></th><td>Environment variables passed to the build</td></tr>
  <tr><th><code>source</code></th><td>How the build was triggered: <code>webhook</code>, <code>api</code>, <code>ui</code>, <code>trigger_job</code>, or <code>schedule</code></td></tr>
  <tr><th><code>creator</code></th><td>User who created the build</td></tr>
  <tr><th><code>jobs</code></th><td>Array of <a href="#job-data-model">Job</a> objects in the build</td></tr>
  <tr><th><code>created_at</code></th><td>When the build was created</td></tr>
  <tr><th><code>scheduled_at</code></th><td>When the build was scheduled</td></tr>
  <tr><th><code>started_at</code></th><td>When the build's first job was started by an agent</td></tr>
  <tr><th><code>finished_at</code></th><td>When the build finished (passed, failed, canceled)</td></tr>
  <tr><th><code>meta_data</code></th><td>Key-value metadata associated with the build</td></tr>
  <tr><th><code>pull_request</code></th><td>Pull request information if applicable</td></tr>
  <tr><th><code>rebuilt_from</code></th><td>Build this was rebuilt from (if applicable)</td></tr>
  <tr><th><code>pipeline</code></th><td>Pipeline the build belongs to</td></tr>
</tbody>
</table>

## Job data model

Jobs are the individual units of work within a build.

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>UUID of the job</td></tr>
  <tr><th><code>graphql_id</code></th><td><a href="/docs/apis/graphql-api#graphql-ids">GraphQL ID</a> of the job</td></tr>
  <tr><th><code>type</code></th><td>Type of job: <code>script</code>, <code>waiter</code>, <code>manual</code>, or <code>trigger</code></td></tr>
  <tr><th><code>name</code></th><td>Display name of the job (may include emoji)</td></tr>
  <tr><th><code>step_key</code></th><td>Key identifier for the step if specified in the pipeline</td></tr>
  <tr><th><code>step</code></th><td>Step information including signature details</td></tr>
  <tr><th><code>agent_query_rules</code></th><td>Agent query rules used to route this job</td></tr>
  <tr><th><code>state</code></th><td>Current state: <code>pending</code>, <code>waiting</code>, <code>waiting_failed</code>, <code>blocked</code>, <code>blocked_failed</code>, <code>unblocked</code>, <code>unblocked_failed</code>, <code>scheduled</code>, <code>assigned</code>, <code>accepted</code>, <code>running</code>, <code>passed</code>, <code>failed</code>, <code>timed_out</code>, <code>timing_out</code>, <code>canceled</code>, <code>canceling</code>, <code>skipped</code>, <code>broken</code>, <code>expired</code>, or <code>limited</code></td></tr>
  <tr><th><code>web_url</code></th><td>URL of the job on Buildkite</td></tr>
  <tr><th><code>log_url</code></th><td>API URL for the job's log</td></tr>
  <tr><th><code>raw_log_url</code></th><td>API URL for the job's raw log text</td></tr>
  <tr><th><code>command</code></th><td>Command executed by the job</td></tr>
  <tr><th><code>soft_failed</code></th><td>Whether the job soft-failed (<code>true</code>, <code>false</code>)</td></tr>
  <tr><th><code>exit_status</code></th><td>Exit code of the command (integer)</td></tr>
  <tr><th><code>artifact_paths</code></th><td>Glob patterns for artifact upload</td></tr>
  <tr><th><code>agent</code></th><td>Agent that ran the job (if assigned)</td></tr>
  <tr><th><code>created_at</code></th><td>When the job was added to the build</td></tr>
  <tr><th><code>scheduled_at</code></th><td>When the job was scheduled for execution</td></tr>
  <tr><th><code>runnable_at</code></th><td>When the job became ready to be accepted by an agent</td></tr>
  <tr><th><code>started_at</code></th><td>When the job was started by an agent</td></tr>
  <tr><th><code>finished_at</code></th><td>When the job finished</td></tr>
  <tr><th><code>retried</code></th><td>Whether this job was retried (<code>true</code>, <code>false</code>)</td></tr>
  <tr><th><code>retried_in_job_id</code></th><td>UUID of the retry job (if retried)</td></tr>
  <tr><th><code>retries_count</code></th><td>Number of retries for this job</td></tr>
  <tr><th><code>retry_type</code></th><td>Type of retry if applicable</td></tr>
  <tr><th><code>parallel_group_index</code></th><td>Index within a parallel group (if parallel job)</td></tr>
  <tr><th><code>parallel_group_total</code></th><td>Total jobs in the parallel group (if parallel job)</td></tr>
  <tr><th><code>matrix</code></th><td>Matrix configuration values (if matrix job)</td></tr>
  <tr><th><code>cluster_id</code></th><td>UUID of the cluster (if using clusters)</td></tr>
  <tr><th><code>cluster_queue_id</code></th><td>UUID of the cluster queue (if using clusters)</td></tr>
</tbody>
</table>

## Timestamp attributes

There are several different timestamps relating to timing for builds and jobs. There are four main time values which are available on both build and job API calls.

The timestamps are available using both the GraphQL and REST APIs. They differ slightly between the build and job objects.

Each <em>build</em> is provided with the following timestamps:

<table>
<tbody>
  <tr>
    <th><code>scheduled_at</code></th>
    <td>The time the build was created. All builds from a <code>pipeline upload</code> have a <code>scheduled_at</code> copied from the job that did the uploading</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>The time the build was created.  For uploaded pipelines it is when the <code>pipeline upload</code> was run.</td>
  </tr>
  <tr>
    <th><code>started_at</code></th>
    <td>The time the build's first job was started by an agent</td>
  </tr>
  <tr>
    <th><code>finished_at</code></th>
    <td>The time the build is marked as finished (passed, failed, paused, canceled)</td>
  </tr>
</tbody>
</table>

Each <em>job</em> is provided with the same timestamps, but their values differ from those on each build:

<table>
<tbody>
  <tr>
    <th><code>scheduled_at</code></th>
    <td>The time when the scheduler process processes the job. If a job was created after the build, the job's <code>scheduled_at</code> value will inherit the build's <code>created_at</code> value, because of this it can be earlier than the job's <code>created_at</code> timestamp.</td>
  </tr>
  <tr>
    <th><code>created_at</code></th>
    <td>The time when the job was added to the build</td>
  </tr>
  <tr>
    <th><code>runnable_at</code></th>
    <td>The time when a job was ready to be accepted by an agent</td>
  </tr>
  <tr>
    <th><code>started_at</code></th>
    <td>The time the job was started by an agent</td>
  </tr>
  <tr>
    <th><code>finished_at</code></th>
    <td>The time the job is marked as finished (passed, failed, paused, canceled)</td>
  </tr>
</tbody>
</table>

## List all builds

Returns a [paginated list](<%= paginated_resource_docs_url %>) of all builds across all the user's organizations and pipelines.
If using token-based authentication the list of builds will be for the authorized organizations only.
Builds are listed in the order they were created (newest first).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/builds"
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/builds_list_query_strings' %>

Required scope: `read_builds`

Success response: `200 OK`

## List builds for an organization

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's builds across all of an organization's pipelines.
Builds are listed in the order they were created (newest first).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/builds"
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/builds_list_query_strings' %>

Required scope: `read_builds`

Success response: `200 OK`

## List builds for a pipeline

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a pipeline's builds.
Builds are listed in the order they were created (newest first).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds"
```

```json
[
  {
    "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
    "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
    "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
    "number": 1,
    "state": "passed",
    "cancel_reason": "reason for a canceled build",
    "blocked": false,
    "message": "Bumping to version 0.2-beta.6",
    "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
    "branch": "main",
    "env": { },
    "source": "webhook",
    "creator": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "name": "Keith Pitt",
      "email": "keith@buildkite.com",
      "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
      "created_at": "2015-05-22T12:36:45.309Z"
    },
    "jobs": [
      {
        "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
        "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
        "type": "script",
        "name": "RSpec",
        "step_key": "rspec",
        "group_key": "tests",
        "step": {
          "id": "018c0f56-c87c-47e9-95ee-aa47397b4496",
          "signature": {
            "value": "eyJhbGciOiJFUzI1NiIsImtpZCI6InlvdSBzbHkgZG9nISB5b3UgY2F1Z2h0IG1lIG1vbm9sb2d1aW5nISJ9..m9LBvNgbzmO5JuZ4Bwoheyn7uqLf3TN1EdFwv_l_nMT2qh0_2EVs30SAEc-Ajjkq18MQk3cgU36AodLPl3_hBg",
            "algorithm": "EdDSA",
            "signed_fields": [
              "command",
              "env",
              "matrix",
              "plugins",
              "repository_url"
            ]
          }
        },
        "agent_query_rules": ["*"],
        "state": "passed",
        "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
        "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
        "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
        "command": "bundle exec rspec",
        "soft_failed": false,
        "exit_status": 0,
        "artifact_paths": "",
        "agent": {
          "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
          "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
          "name": "my-agent-123"
        },
        "created_at": "2015-05-09T21:05:59.874Z",
        "scheduled_at": "2015-05-09T21:05:59.874Z",
        "runnable_at": "2015-05-09T21:06:59.874Z",
        "started_at": "2015-05-09T21:07:59.874Z",
        "finished_at": "2015-05-09T21:08:59.874Z",
        "retried": false,
        "retried_in_job_id": null,
        "retries_count": null,
        "retry_type": null,
        "parallel_group_index": null,
        "parallel_group_total": null,
        "matrix": null,
        "cluster_id": null,
        "cluster_url": null,
        "cluster_queue_id": null,
        "cluster_queue_url": null
      }
    ],
    "created_at": "2015-05-09T21:05:59.874Z",
    "scheduled_at": "2015-05-09T21:05:59.874Z",
    "started_at": "2015-05-09T21:05:59.874Z",
    "finished_at": "2015-05-09T21:05:59.874Z",
    "meta_data": { },
    "pull_request": { },
    "rebuilt_from": null,
    "pipeline": {
      "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
      "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
      "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline",
      "name": "great-pipeline",
      "slug": "great-pipeline",
      "repository": "git@github.com:my-great-org/my-pipeline",
      "branch_configuration": null,
      "default_branch": "main",
      "provider": {
        "id": "github",
        "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
        "settings": {
          "trigger_mode": "code",
          "build_pull_requests": true,
          "pull_request_branch_filter_enabled": false,
          "skip_pull_request_builds_for_existing_commits": true,
          "build_pull_request_forks": false,
          "prefix_pull_request_fork_branch_names": true,
          "build_tags": false,
          "publish_commit_status": true,
          "publish_commit_status_per_step": false,
          "publish_blocked_as_pending": false,
          "repository": "my-great-org/my-pipeline"
        },
      },
      "skip_queued_branch_builds": false,
      "skip_queued_branch_builds_filter": null,
      "cancel_running_branch_builds": false,
      "cancel_running_branch_builds_filter": null,
      "builds_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds",
      "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_builds_count": 0,
      "running_builds_count": 0,
      "scheduled_jobs_count": 0,
      "running_jobs_count": 0,
      "waiting_jobs_count": 0
    }
  }
]
```

> 📘 Webhook URL
> The response only includes a webhook URL in `pipeline.provider.webhook_url` if the user has edit permissions for the pipeline. Otherwise, the field returns with an empty string.

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/builds_list_query_strings' %>

Required scope: `read_builds`

Success response: `200 OK`

## Get a build

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}"
```

<%= render_markdown partial: 'apis/rest_api/build_number_vs_build_id' %>

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/2",
  "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/2",
  "number": 2,
  "state": "passed",
  "cancel_reason": null,
  "blocked": false,
  "message": "Bumping to version 0.2-beta.6",
  "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
  "branch": "main",
  "env": { },
  "source": "webhook",
  "creator": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "name": "Keith Pitt",
    "email": "keith@buildkite.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-22T12:36:45.309Z"
  },
  "jobs": [
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
      "type": "script",
      "name": "RSpec",
      "step_key": "rspec",
      "group_key": "tests",
      "step": {
        "id": "018c0f56-c87c-47e9-95ee-aa47397b4496",
        "signature": {
          "value": "eyJhbGciOiJFUzI1NiIsImtpZCI6InlvdSBzbHkgZG9nISB5b3UgY2F1Z2h0IG1lIG1vbm9sb2d1aW5nISJ9..m9LBvNgbzmO5JuZ4Bwoheyn7uqLf3TN1EdFwv_l_nMT2qh0_2EVs30SAEc-Ajjkq18MQk3cgU36AodLPl3_hBg",
          "algorithm": "EdDSA",
          "signed_fields": [
            "command",
            "env",
            "matrix",
            "plugins",
            "repository_url"
          ]
        }
      },
      "agent_query_rules": ["*"],
      "state": "passed",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/2#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/2/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/2/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "command": "bundle exec rspec",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": {
        "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
        "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
        "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
        "web_url": "https://buildkite.com/organizations/my-great-org/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
        "name": "my-agent",
        "connection_state": "connected",
        "hostname": "localhost",
        "ip_address": "144.132.19.12",
        "user_agent": "buildkite-agent/1.0.0 (linux; amd64)",
        "creator": {
          "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
          "name": "Keith Pitt",
          "email": "keith@buildkite.com",
          "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
          "created_at": "2015-05-09T21:05:59.874Z"
        },
        "created_at": "2015-05-09T21:05:59.874Z"
      },
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": "2015-05-09T21:06:59.874Z",
      "started_at": "2015-05-09T21:07:59.874Z",
      "finished_at": "2015-05-09T21:08:59.874Z",
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": 1,
      "retry_source": {
        "job_id": "0194b92a-4d74-46bb-a1bf-61c73c5642af",
        "retry_type": "manual"
      },
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "matrix": null,
      "cluster_id": null,
      "cluster_url": null,
      "cluster_queue_id": null,
      "cluster_queue_url": null
    }
  ],
  "created_at": "2015-05-09T21:05:59.874Z",
  "scheduled_at": "2015-05-09T21:05:59.874Z",
  "started_at": "2015-05-09T21:05:59.874Z",
  "finished_at": "2015-05-09T21:08:59.874Z",
  "meta_data": { },
  "pull_request": { },
  "rebuilt_from": {
    "id": "812135b3-eee7-408c-9f63-760538b96bd5",
    "number": 1,
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1"
  },
  "pipeline": {
    "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
    "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline",
    "name": "Great Pipeline",
    "slug": "great-pipeline",
    "repository": "git@github.com:my-great-org/my-pipeline",
    "provider": {
      "id": "github",
      "webhook_url": "https://webhook.buildkite.com/deliver/xxx"
    },
    "skip_queued_branch_builds": false,
    "skip_queued_branch_builds_filter": null,
    "cancel_running_branch_builds": false,
    "cancel_running_branch_builds_filter": null,
    "builds_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds",
    "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
    "created_at": "2013-09-03 13:24:38 UTC",
    "scheduled_builds_count": 0,
    "running_builds_count": 0,
    "scheduled_jobs_count": 0,
    "running_jobs_count": 0,
    "waiting_jobs_count": 0
  }
}
```

> 📘 Webhook URL
> The response only includes a webhook URL in `pipeline.provider.webhook_url` if the user has edit permissions for the pipeline. Otherwise, the field returns with an empty string.

Unlike [build states](/docs/pipelines/configure/notifications#build-states) for notifications, when a build is blocked, the `state` of a build does not return the value `blocked`. Instead, the build `state` retains its last value (for example, `passed`) and the `blocked` field value will be `true`.

When a job belongs to a [group step](/docs/pipelines/configure/step-types/group-step), the job object includes a `group_key` field. The value corresponds to the group step's `key` attribute, allowing you to identify which jobs belong to which logical groups in your pipeline.

Optional [query string parameters](/docs/api#query-string-parameters):

<table>
<tbody>
  <tr>
    <th><code>include_retried_jobs</code></th>
    <td>Include all retried job executions in each build's jobs list. Without this parameter, you'll see only the most recently run job for each step.<p class="Docs__api-param-eg">
      <em>Example:</em> <code>?include_retried_jobs=true</code></p>
    </td>
  </tr>
  <tr>
    <th><code>include_test_engine</code></th>
    <td>Include all Test Engine-related data for the build in the response. Without this parameter, you'll only see all Buildkite Pipelines-related build data in the response.<p class="Docs__api-param-eg">
      <em>Example:</em> <code>?include_test_engine=true</code></p>
    </td>
  </tr>
</tbody>
</table>

Required scope: `read_builds`

Success response: `200 OK`

## Create a build

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds" \
  -H "Content-Type: application/json" \
  -d '{
    "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
    "branch": "main",
    "message": "Testing all the things \:rocket\:",
    "author": {
      "name": "Keith Pitt",
      "email": "me@keithpitt.com"
    },
    "env": {
      "MY_ENV_VAR": "some_value"
    },
    "meta_data": {
      "some build data": "value",
      "other build data": true
    }
  }'
```

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
  "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
  "number": 1,
  "state": "scheduled",
  "cancel_reason": "reason for a canceled build",
  "blocked": false,
  "message": "Testing all the things \:rocket\:",
  "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
  "branch": "main",
  "env": { },
  "source": "webhook",
  "creator": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "name": "Keith Pitt",
    "email": "keith@buildkite.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-22T12:36:45.309Z"
  },
  "jobs": [
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "type": "script",
      "name": ":package:",
      "step_key": "package",
      "step": {
        "id": "018c0f56-c87c-47e9-95ee-aa47397b4496",
        "signature": {
          "value": "eyJhbGciOiJFUzI1NiIsImtpZCI6InlvdSBzbHkgZG9nISB5b3UgY2F1Z2h0IG1lIG1vbm9sb2d1aW5nISJ9..m9LBvNgbzmO5JuZ4Bwoheyn7uqLf3TN1EdFwv_l_nMT2qh0_2EVs30SAEc-Ajjkq18MQk3cgU36AodLPl3_hBg",
          "algorithm": "EdDSA",
          "signed_fields": [
            "command",
            "env",
            "matrix",
            "plugins",
            "repository_url"
          ]
        }
      },
      "agent_query_rules": ["*"],
      "state": "scheduled",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": {
        "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
        "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
        "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
        "web_url": "https://buildkite.com/organizations/my-great-org/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
        "name": "my-agent",
        "connection_state": "connected",
        "hostname": "localhost",
        "ip_address": "144.132.19.12",
        "user_agent": "buildkite-agent/1.0.0 (linux; amd64)",
        "creator": {
          "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
          "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
          "name": "Keith Pitt",
          "email": "keith@buildkite.com",
          "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
          "created_at": "2015-05-09T21:05:59.874Z"
        },
        "created_at": "2015-05-09T21:05:59.874Z"
      },
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": "2015-05-09T21:06:59.874Z",
      "started_at": "2015-05-09T21:07:59.874Z",
      "finished_at": "2015-05-09T21:08:59.874Z",
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": null,
      "retry_source": null,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "matrix": null,
      "cluster_id": null,
      "cluster_url": null,
      "cluster_queue_id": null,
      "cluster_queue_url": null
    }
  ],
  "created_at": "2015-05-09T21:05:59.874Z",
  "scheduled_at": "2015-05-09T21:05:59.874Z",
  "started_at": "2015-05-09T21:05:59.874Z",
  "finished_at": "2015-05-09T21:05:59.874Z",
  "meta_data": { },
  "pull_request": { },
  "pipeline": {
    "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
    "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline",
    "name": "Great Pipeline",
    "slug": "great-pipeline",
    "repository": "git@github.com:my-great-org/my-pipeline",
    "provider": {
      "id": "github",
      "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
      "settings": {}
    },
    "skip_queued_branch_builds": false,
    "skip_queued_branch_builds_filter": null,
    "cancel_running_branch_builds": false,
    "cancel_running_branch_builds_filter": null,
    "builds_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds",
    "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
    "created_at": "2015-05-09T21:05:59.874Z",
    "scheduled_builds_count": 0,
    "running_builds_count": 0,
    "scheduled_jobs_count": 0,
    "running_jobs_count": 0,
    "waiting_jobs_count": 0
  }
}
```
> 📘 Webhook URL
> The response only includes a webhook URL in `pipeline.provider.webhook_url` if the user has edit permissions for the pipeline. Otherwise, the field returns with an empty string.

Required [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>commit</code></th><td>Ref, SHA or tag to be built.<br><em>Example:</em> <code>"HEAD"</code><br><em>Note:</em>Before running builds on tags, make sure your agent is <a href="/docs/pipelines/source-control/github#running-builds-on-git-tags">fetching git tags</a> .
</td></tr>
  <tr><th><code>branch</code></th><td>Branch the commit belongs to. This allows you to take advantage of your pipeline and step-level branch filtering rules.<br><em>Example:</em> <code>"main"</code></td></tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>author</code></th><td>A JSON object with a <code>"name"</code> and <code>"email"</code> key to show who created this build.<br><em>Default value: the user making the API request</em>.</td></tr>
  <tr><th><code>clean_checkout</code></th><td>Force the agent to remove any existing build directory and perform a fresh checkout.<br><em>Default value:</em> <code>false</code>.</td></tr>
  <tr><th><code>env</code></th><td>Environment variables to be made available to the build.<br><em>Default value:</em> <code>{}</code>.</td></tr>
  <tr><th><code>ignore_pipeline_branch_filters</code></th><td>Run the build regardless of the pipeline's branch filtering rules. Step branch filtering rules will still apply.<br><em>Default value:</em> <code>false</code>.</td></tr>
  <tr><th><code>message</code></th><td>Message for the build.<br><em>Example:</em> <code>"Testing all the things \:rocket\:"</code></td></tr>
  <tr><th><code>meta_data</code></th><td>A JSON object of meta-data to make available to the build.<br><em>Default value:</em> <code>{}</code>.</td></tr>
  <tr><th><code>pull_request_base_branch</code></th><td>For a pull request build, the base branch of the pull request.<br><em>Example:</em> <code>"main"</code></td></tr>
  <tr><th><code>pull_request_id</code></th><td>For a pull request build, the pull request number.<br><em>Example:</em> <code>42</code></td></tr>
  <tr><th><code>pull_request_labels</code></th><td>For a pull request build, a JSON array of labels assigned to the pull request.<br><em>Example:</em> <code>["bug", "ui"]</code></td></tr>
  <tr><th><code>pull_request_repository</code></th><td>For a pull request build, the git repository of the pull request.<br><em>Example:</em> <code>"git://github.com/my-org/my-repo.git"</code></td></tr>
  </tbody>
</table>

Required scope: `write_builds`

Success response: `201 Created`

Error responses:

<table>
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation Failed", "errors": [ ... ] }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason that the build could not be created" }</code></td></tr>
</tbody>
</table>

## Cancel a build

Cancels the build if its state is either `scheduled`, `running`, or `failing`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/cancel"
```

<%= render_markdown partial: 'apis/rest_api/build_number_vs_build_id' %>

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
  "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
  "number": 1,
  "state": "canceled",
  "cancel_reason": "reason for a canceled build",
  "blocked": false,
  "message": "Bumping to version 0.2-beta.6",
  "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
  "branch": "main",
  "env": { },
  "source": "webhook",
  "creator": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
    "name": "Keith Pitt",
    "email": "keith@buildkite.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-22T12:36:45.309Z"
  },
  "jobs": [
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": ":package:",
      "step_key": "package",
      "step": {
        "id": "018c0f56-c87c-47e9-95ee-aa47397b4496",
        "signature": {
          "value": "eyJhbGciOiJFUzI1NiIsImtpZCI6InlvdSBzbHkgZG9nISB5b3UgY2F1Z2h0IG1lIG1vbm9sb2d1aW5nISJ9..m9LBvNgbzmO5JuZ4Bwoheyn7uqLf3TN1EdFwv_l_nMT2qh0_2EVs30SAEc-Ajjkq18MQk3cgU36AodLPl3_hBg",
          "algorithm": "EdDSA",
          "signed_fields": [
            "command",
            "env",
            "matrix",
            "plugins",
            "repository_url"
          ]
        }
      },
      "agent_query_rules": ["*"],
      "state": "scheduled",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": {
        "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
        "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
        "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
        "web_url": "https://buildkite.com/organizations/my-great-org/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
        "name": "my-agent",
        "connection_state": "connected",
        "hostname": "localhost",
        "ip_address": "144.132.19.12",
        "user_agent": "buildkite-agent/1.0.0 (linux; amd64)",
        "creator": {
          "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
          "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
          "name": "Keith Pitt",
          "email": "keith@buildkite.com",
          "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
          "created_at": "2015-05-09T21:05:59.874Z"
        },
        "created_at": "2015-05-09T21:05:59.874Z"
      },
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": "2015-05-09T21:06:59.874Z",
      "started_at": "2015-05-09T21:07:59.874Z",
      "finished_at": "2015-05-09T21:08:59.874Z",
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": null,
      "retry_source": null,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "matrix": null,
      "cluster_id": null,
      "cluster_url": null,
      "cluster_queue_id": null,
      "cluster_queue_url": null
    }
  ],
  "created_at": "2015-05-09T21:05:59.874Z",
  "scheduled_at": "2015-05-09T21:05:59.874Z",
  "started_at": "2015-05-09T21:05:59.874Z",
  "finished_at": "2015-05-09T21:05:59.874Z",
  "meta_data": { },
  "pull_request": { },
  "pipeline": {
    "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
    "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline",
    "name": "Great Pipeline",
    "slug": "great-pipeline",
    "repository": "git@github.com:my-great-org/my-pipeline",
    "provider": {
      "id": "github",
      "webhook_url": "https://webhook.buildkite.com/deliver/xxx"
    },
    "skip_queued_branch_builds": false,
    "skip_queued_branch_builds_filter": null,
    "cancel_running_branch_builds": false,
    "cancel_running_branch_builds_filter": null,
    "builds_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds",
    "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
    "created_at": "2013-09-03 13:24:38 UTC",
    "scheduled_builds_count": 0,
    "running_builds_count": 0,
    "scheduled_jobs_count": 0,
    "running_jobs_count": 0,
    "waiting_jobs_count": 0
  }
}
```

> 📘 Webhook URL
> The response only includes a webhook URL in `pipeline.provider.webhook_url` if the user has edit permissions for the pipeline. Otherwise, the field returns with an empty string.

Required scope: `write_builds`

Success response: `200 OK`

Error responses:

<table>
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason why the build could not be canceled" }</code></td></tr>
</tbody>
</table>

## Rebuild a build

Returns the newly created build.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/rebuild"
```

<%= render_markdown partial: 'apis/rest_api/build_number_vs_build_id' %>

```json
{
  "id": "f62a1b4d-10f9-4790-bc1c-e2c3a0c80983",
  "graphql_id": "QnVpbGQtLS1mYmQ2Zjk3OS0yOTRhLTQ3ZjItOTU0Ni1lNTk0M2VlMTAwNzE=",
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1",
  "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1",
  "number": 2,
  "state": "scheduled",
  "cancel_reason": "reason for a canceled build",
  "blocked": false,
  "message": "Bumping to version 0.2-beta.6",
  "commit": "abcd0b72a1e580e90712cdd9eb26d3fb41cd09c8",
  "branch": "main",
  "env": { },
  "source": "api",
  "creator": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
    "name": "Keith Pitt",
    "email": "keith@buildkite.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2015-05-22T12:36:45.309Z"
  },
  "jobs": [
    {
      "id": "b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "graphql_id": "Sm9iLS0tMTQ4YWQ0MzgtM2E2My00YWIxLWIzMjItNzIxM2Y3YzJhMWFi",
      "type": "script",
      "name": ":package:",
      "step_key": "package",
      "step": {
        "id": "018c0f56-c87c-47e9-95ee-aa47397b4496",
        "signature": {
          "value": "eyJhbGciOiJFUzI1NiIsImtpZCI6InlvdSBzbHkgZG9nISB5b3UgY2F1Z2h0IG1lIG1vbm9sb2d1aW5nISJ9..m9LBvNgbzmO5JuZ4Bwoheyn7uqLf3TN1EdFwv_l_nMT2qh0_2EVs30SAEc-Ajjkq18MQk3cgU36AodLPl3_hBg",
          "algorithm": "EdDSA",
          "signed_fields": [
            "command",
            "env",
            "matrix",
            "plugins",
            "repository_url"
          ]
        }
      },
      "agent_query_rules": ["*"],
      "state": "scheduled",
      "web_url": "https://buildkite.com/my-great-org/my-pipeline/builds/1#b63254c0-3271-4a98-8270-7cfbd6c2f14e",
      "log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log",
      "raw_log_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds/1/jobs/b63254c0-3271-4a98-8270-7cfbd6c2f14e/log.txt",
      "command": "scripts/build.sh",
      "soft_failed": false,
      "exit_status": 0,
      "artifact_paths": "",
      "agent": {
        "id": "0b461f65-e7be-4c80-888a-ef11d81fd971",
        "graphql_id": "QWdlbnQtLS1mOTBhNzliNC01YjJlLTQzNzEtYjYxZS03OTA4ZDAyNmUyN2E=",
        "url": "https://api.buildkite.com/v2/organizations/my-great-org/agents/my-agent",
        "web_url": "https://buildkite.com/organizations/my-great-org/agents/0b461f65-e7be-4c80-888a-ef11d81fd971",
        "name": "my-agent",
        "connection_state": "connected",
        "hostname": "localhost",
        "ip_address": "144.132.19.12",
        "user_agent": "buildkite-agent/1.0.0 (linux; amd64)",
        "creator": {
          "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
          "graphql_id": "VXNlci0tLThmNzFlOWI1LTczMDEtNDI4ZS1hMjQ1LWUwOWI0YzI0OWRiZg==",
          "name": "Keith Pitt",
          "email": "keith@buildkite.com",
          "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
          "created_at": "2015-05-09T21:05:59.874Z"
        },
        "created_at": "2015-05-09T21:05:59.874Z"
      },
      "created_at": "2015-05-09T21:05:59.874Z",
      "scheduled_at": "2015-05-09T21:05:59.874Z",
      "runnable_at": "2015-05-09T21:06:59.874Z",
      "started_at": "2015-05-09T21:07:59.874Z",
      "finished_at": "2015-05-09T21:08:59.874Z",
      "retried": false,
      "retried_in_job_id": null,
      "retries_count": null,
      "retry_source": null,
      "retry_type": null,
      "parallel_group_index": null,
      "parallel_group_total": null,
      "matrix": null,
      "cluster_id": null,
      "cluster_url": null,
      "cluster_queue_id": null,
      "cluster_queue_url": null
    }
  ],
  "created_at": "2015-05-09T21:05:59.874Z",
  "scheduled_at": "2015-05-09T21:05:59.874Z",
  "started_at": "2015-05-09T21:05:59.874Z",
  "finished_at": "2015-05-09T21:05:59.874Z",
  "meta_data": { },
  "pull_request": { },
  "pipeline": {
    "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
    "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
    "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline",
    "name": "Great Pipeline",
    "slug": "great-pipeline",
    "repository": "git@github.com:my-great-org/my-pipeline",
    "provider": {
      "id": "github",
      "webhook_url": "https://webhook.buildkite.com/deliver/xxx"
    },
    "skip_queued_branch_builds": false,
    "skip_queued_branch_builds_filter": null,
    "cancel_running_branch_builds": false,
    "cancel_running_branch_builds_filter": null,
    "builds_url": "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds",
    "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
    "created_at": "2013-09-03 13:24:38 UTC",
    "scheduled_builds_count": 0,
    "running_builds_count": 0,
    "scheduled_jobs_count": 0,
    "running_jobs_count": 0,
    "waiting_jobs_count": 0
  }
}
```

> 📘 Webhook URL
> The response only includes a webhook URL in `pipeline.provider.webhook_url` if the user has edit permissions for the pipeline. Otherwise, the field returns with an empty string.

Required scope: `write_builds`

Success response: `200 OK`
