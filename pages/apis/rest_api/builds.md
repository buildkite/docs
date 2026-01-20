# Builds API

## Build number vs build ID

All builds have a _build ID_ (for example, `01908131-7d9f-495e-a17b-80ed31276810`), which is a unique value throughout the entire Buildkite platform, as well as a _build number_ (for example, `27`). A build number is unique to a pipeline, and its value is incremented with each build, although there may be occasional gaps.

Note that some API request types on this page, especially those involving only a single build, require using a build number rather than a build ID.

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
