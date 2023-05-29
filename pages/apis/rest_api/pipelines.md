# Pipelines API


## List pipelines

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's pipelines.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines"
```

```json
[
  {
    "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
    "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
    "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
    "web_url": "https://buildkite.com/acme-inc/my-pipeline",
    "name": "My Pipeline",
    "slug": "my-pipeline",
    "repository": "git@github.com:acme-inc/my-pipeline.git",
    "branch_configuration": null,
    "default_branch": "main",
    "provider": {
      "id": "github",
      "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
      "settings": {
        "publish_commit_status": true,
        "build_pull_requests": true,
        "build_pull_request_forks": false,
        "build_tags": false,
        "publish_commit_status_per_step": false,
        "repository": "acme-inc/my-pipeline",
        "trigger_mode": "code"
      }
    },
    "skip_queued_branch_builds": false,
    "skip_queued_branch_builds_filter": null,
    "cancel_running_branch_builds": false,
    "cancel_running_branch_builds_filter": null,
    "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds",
    "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Keith Pitt",
      "email": "keith@buildkite.com",
      "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
      "created_at": "2013-08-29T10:10:03.000Z"
    },
    "created_at": "2013-09-03 13:24:38 UTC",
    "archived_at": null,
    "scheduled_builds_count": 0,
    "running_builds_count": 0,
    "scheduled_jobs_count": 0,
    "running_jobs_count": 0,
    "waiting_jobs_count": 0,
    "visibility": "private",
    "steps": [
      {
        "type": "script",
        "name": "Test :white_check_mark:",
        "command": "script/test.sh",
        "artifact_paths": "results/*",
        "branch_configuration": "main feature/*",
        "env": { },
        "timeout_in_minutes": null,
        "agent_query_rules": [ ]
      }
    ],
    "env": {
    }
  }
]
```

Required scope: `read_pipelines`

Success response: `200 OK`

## Get a pipeline

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}"
```

```json
{
  "id": "849411f9-9e6d-4739-a0d8-e247088e9b52",
  "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline",
  "name": "My Pipeline",
  "description": "This pipeline is amazing! :tada:",
  "slug": "my-pipeline",
  "repository": "git@github.com:acme-inc/my-pipeline.git",
  "branch_configuration": null,
  "default_branch": "main",
  "provider": {
    "id": "github",
    "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
    "settings": {
      "publish_commit_status": true,
      "build_pull_requests": true,
      "build_pull_request_forks": false,
      "build_tags": false,
      "publish_commit_status_per_step": false,
      "repository": "acme-inc/my-pipeline",
      "trigger_mode": "code"
    }
  },
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds",
  "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Keith Pitt",
    "email": "keith@buildkite.com",
    "avatar_url": "https://www.gravatar.com/avatar/e14f55d3f939977cecbf51b64ff6f861",
    "created_at": "2013-08-29T10:10:03.000Z"
  },
  "created_at": "2013-09-03 13:24:38 UTC",
  "archived_at": null,
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private"
  "steps": [
    {
      "type": "script",
      "name": "Test :white_check_mark:",
      "command": "script/test.sh",
      "artifact_paths": "results/*",
      "branch_configuration": "main feature/*",
      "env": { },
      "timeout_in_minutes": null,
      "agent_query_rules": [ ]
    }
  ],
  "env": {
  }
}
```

Required scope: `read_pipelines`

Success response: `200 OK`


## Create a YAML pipeline

YAML pipelines are the recommended way to [manage your pipelines](https://buildkite.com/docs/tutorials/pipeline-upgrade). To create a YAML pipeline using this endpoint, set the `configuration` key in your json request body to an the YAML you want in your pipeline.

For example, to create a pipeline called `"My Pipeline"` containing the following command step

```yaml
steps:
 - command: "script/release.sh"
   name: "Build \:package\:"
```

make the following POST request, substituting your organization slug instead of `{org.slug}`. Make sure to escape the quotes (`"`) in your YAML, and  to replace line breaks with `\n`:

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
  -H "Content-Type: application/json" \
  -d '{
      "name": "My Pipeline X",
      "repository": "git@github.com:acme-inc/my-pipeline.git",
      "configuration": "env:\n \"FOO\": \"bar\"\nsteps:\n - command: \"script/release.sh\"\n   \"name\": \"Build :package:\""
    }'
```

>📘
> When setting pipeline configuration using the API, you must pass in a string that Buildkite parses as valid YAML, escaping quotes and line breaks.
> To avoid writing an entire YAML file in a single string, you can place a <code>pipeline.yml</code> file in a <code>.buildkite</code> directory at the root of your repo, and use the <code>pipeline upload</code> command in your configuration to tell Buildkite where to find it. This means you only need the following:
>
<code>
"configuration": "steps:\n - command: \"buildkite-agent pipeline upload\""
</code>


The response contains information about your new pipeline:

```json
{
  "id": "ad93b461-96ab-4a1e-9281-260ead506a0e",
  "graphql_id": "UGlwZWxpbmUtLS1hZDkzYjQ2MS05NmFiLTRhMWUtOTI4MS0yNjBlYWQ1MDZhMGU=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline-x",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline-x",
  "name": "My Pipeline X",
  "description": null,
  "slug": "my-pipeline-x",
  "repository": "git@github.com:acme-inc/my-pipeline.git",
  "cluster_id": null,
  "branch_configuration": null,
  "default_branch": "main",
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "allow_rebuilds": true,
  "provider": {
    "id": "github",
    "settings": {
      "trigger_mode": "code",
      "build_pull_requests": true,
      "pull_request_branch_filter_enabled": false,
      "skip_builds_for_existing_commits": false,
      "skip_pull_request_builds_for_existing_commits": true,
      "build_pull_request_ready_for_review": false,
      "build_pull_request_labels_changed": false,
      "build_pull_request_forks": false,
      "prefix_pull_request_fork_branch_names": true,
      "build_branches": true,
      "build_tags": false,
      "cancel_deleted_branch_builds": false,
      "publish_commit_status": true,
      "publish_commit_status_per_step": false,
      "separate_pull_request_statuses": false,
      "publish_blocked_as_pending": false,
      "use_step_key_as_commit_status": false,
      "filter_enabled": false,
      "repository": "acme-inc/my-pipeline"
    },
    "webhook_url": "https://webhook.buildkite.com/deliver/fe08e0f823297a158fc4ca2bfddd6ea3ced92b5167a658a0bb"
  },
  "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline-x/builds",
  "badge_url": "https://badge.buildkite.com/05bf6d997d16c993ae6180ed7d85d29c9be8f8d8f37ac96477.svg",
  "created_by": {
    "id": "3cc415b8-3d63-4b9a-acb0-c120dbcb231c",
    "graphql_id": "VXNlci0tLTNjYzQxNWI4LTNkNjMtNGI5YS1hY2IwLWMxMjBkYmNiMjMxYw==",
    "name": "Sam Wright",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/3536621b97b6d9d39488202709317051",
    "created_at": "2020-02-14T16:57:23.153Z"
  },
  "created_at": "2021-05-06T14:54:21.088Z",
  "archived_at": null,
  "env": {
    "FOO": "bar"
  },
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private",
  "tags": null,
  "configuration": "env:\n \"FOO\": \"bar\"\n\"steps\":\n - command: \"script/release.sh\"\n   \"name\": \"Build :package:\"",
  "steps": [{
    "type": "script",
    "name": "Build :package:",
    "command": "script/release.sh",
    "artifact_paths": null,
    "branch_configuration": null,
    "env": {},
    "timeout_in_minutes": null,
    "agent_query_rules": [],
    "concurrency": null,
    "parallelism": null
  }]
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>name</code></th>
    <td>The name of the pipeline.<p class="Docs__api-param-eg"><em>Example:</em> <code>"New Pipeline"</code></p></td>
  </tr>
  <tr>
    <th><code>repository</code></th>
    <td>The repository URL.<p class="Docs__api-param-eg"><em>Example:</em> <code>"git@github.com:acme-inc/my-pipeline.git"</code></p></td>
  </tr>
  <tr>
    <th><code>configuration</code></th>
    <td>
      The YAML pipeline that consists of the build pipeline steps.<p class="Docs__api-param-eg"><em>Example:</em> <code>"steps:\n - command: \"script/release.sh\"\n"</code>
    </td>
  </tr>
  </tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#pipeline-level-branch-filtering">branch filter pattern</a> to limit which pushed branches trigger builds on this pipeline.</p>
      <p><em>Example:</em> <code>"main feature/*"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds</code></th>
    <td>
      <p>Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.</p>
      <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
    </td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds_filter</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build cancelling applies to.</p>
      <p><em>Example:</em> <code>"develop prs/*"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>default_branch</code></th>
    <td>
      <p>The name of the branch to prefill when new builds are created or triggered in Buildkite. It is also used to filter the builds and metrics shown on the Pipelines page.</p>
      <p><em>Example:</em> <code>"main"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>
      <p>The pipeline description.</p>
      <p><em>Example:</em> <code>":package: A testing pipeline"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>provider_settings</code></th>
    <td>
      <p>The source provider settings. See the <a href="#provider-settings-properties">Provider Settings</a> section for accepted properties.</p>
      <p><em>Example:</em> <code>{ "publish_commit_status": true, "build_pull_request_forks": true }</code></p>
    </td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds</code></th>
    <td>
      <p>Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.</p>
      <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
    </td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds_filter</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build skipping applies to.</p>
      <p><em>Example:</em> <code>"!main"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>teams</code></th>
    <td>
      <p>An array of team UUIDs to add this pipeline to. Allows you to specify the access level for the pipeline in a team. The available access level options are:
      <ul>
        <li><code>read_only</code></li>
        <li><code>build_and_read</code></li>
        <li><code>manage_build_and_read</code></li>
      </ul>
      You can find your team's UUID either using the <a href="/docs/apis/graphql-api">GraphQL API</a>, or on the Settings page for a team. This property is only available if your organization has enabled Teams. Once your organization enables Teams, only administrators can create pipelines without providing team UUIDs. Replaces deprecated <code>team_uuids</code> parameter.</p>
      <p><em>Example:</em></p>
      <%= render_markdown text: %{
```javascript
teams: {
  "14e9501c-69fe-4cda-ae07-daea9ca3afd3": "read_only"
  "3f195bcd-28f2-4e1a-bcff-09f3543e5abf": "build_and_read"
  "5b6c4a01-8e4f-49a3-bf88-be0d47ef9c0a": "manage_build_and_read"
}
```} %>
    </td>
  </tr>
  <tr>
    <th><code>visibility</code></th>
    <td>
      <p>Whether the pipeline is visible to everyone, including users outside this organization. <p class="Docs__api-param-eg"><em>Example:</em> <code>"public"</code><br><em>Default:</em> <code>"private"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>cluster_id</code></th>
    <td>The ID of the <a href="/docs/agent/clusters">cluster</a> the pipeline should run in. Set to <code>null</code> to remove the pipeline from a cluster.<br />You'll need to <a href="/docs/agent/clusters#enable-clusters">enable clusters</a> for your organization to use this feature. <p class="Docs__api-param-eg"><em>Example:</em> <code>"42f1a7da-812d-4430-93d8-1cc7c33a6bcf"</code></p>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation Failed", "errors": [ ... ] }</code></td></tr>
</tbody>
</table>

## Create a visual step pipeline

YAML pipelines are the recommended way to [manage your pipelines](https://buildkite.com/docs/tutorials/pipeline-upgrade) but if you're still using visual steps you can add them by setting the `steps` key in your json request body to an array of steps:

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Pipeline",
    "repository": "git@github.com:acme-inc/my-pipeline.git",
    "steps": [
      {
        "type": "script",
        "name": "Build \:package\:",
        "command": "script/release.sh"
      },
      {
        "type": "waiter"
      },
      {
        "type": "script",
        "name": "Test \:wrench\:",
        "command": "script/release.sh",
        "artifact_paths": "log/*"
      },
      {
        "type": "manual",
        "label": "Deploy"
      },
      {
        "type": "script",
        "name": "Release \:rocket\:",
        "command": "script/release.sh",
        "branch_configuration": "main",
        "env": {
          "AMAZON_S3_BUCKET_NAME": "my-pipeline-releases"
        },
        "timeout_in_minutes": 10,
        "agent_query_rules": ["aws=true"]
      },
      {
        "type": "trigger",
        "label": "Deploy \:ship\:",
        "trigger_project_slug": "deploy",
        "trigger_commit": "HEAD",
        "trigger_branch": "main",
        "trigger_async": true
      }
    ]
  }'
```

The response contains information about your new pipeline:

```json
{
  "id": "14e9501c-69fe-4cda-ae07-daea9ca3afd3",
  "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline",
  "name": "My Pipeline",
  "description": null,
  "slug": "my-pipeline",
  "repository": "git@github.com:acme-inc/my-pipeline.git",
  "branch_configuration": null,
  "default_branch": "main"
  "provider": {
    "id": "github",
    "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
    "settings": {
      "publish_commit_status": true,
      "build_pull_requests": true,
      "build_pull_request_forks": false,
      "build_tags": false,
      "publish_commit_status_per_step": false,
      "repository": "acme-inc/my-pipeline",
      "trigger_mode": "code"
    }
  },
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "builtype": "script",
      "name": "Build \:package\:",
      "command": "script/release.sh",
      "artifact_paths": null,
      "branch_configuration": null,
      "env": {},
      "timeout_in_minutes": null,
      "agent_query_rules": [],
      "concurrency": null,
      "parallelism": null
    },
    {
      "type": "waiter"
    },
    {
      "type": "script",
      "name": "Test \:wrench\:",
      "command": "script/release.sh",
      "artifact_paths": "log/*",
      "branch_configuration": null,
      "env": {},
      "timeout_in_minutes": null,
      "agent_query_rules": [

      ],
      "concurrency": null,
      "parallelism": null
    },
    {
      "type": "manual",
      "label": "Deploy"
    },
    {
      "type": "script",
      "name": "Release \:rocket\:",
      "command": "script/release.sh",
      "artifact_paths": null,
      "branch_configuration": "main",
      "env": {
        "AMAZON_S3_BUCKET_NAME": "my-pipeline-releases"
      },
      "timeout_in_minutes": 10,
      "agent_query_rules": [
        "aws=true"
      ],
      "concurrency": null,
      "parallelism": null
    },
    {
      "type": "trigger",
      "label": "Deploy \:ship\:",
      "pipeline": "deploy",
      "build": {
        "message": null,
        "branch": "main",
        "commit": "HEAD",
        "env": null
      },
      "async": true,
      "branch_configuration": null,
      "concurrency": null,
      "parallelism": null
    }
  ],
  "env": {
  },
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private"
}
```

The resulting pipeline:

<%= image 'pipeline-example.png', alt: 'Image of the pipeline steps that are created in the Buildkite UI', width: 974/2, height: 90/2 %>

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>name</code></th>
    <td>The name of the pipeline.<p class="Docs__api-param-eg"><em>Example:</em> <code>"New Pipeline"</code></p></td>
  </tr>
  <tr>
    <th><code>repository</code></th>
    <td>The repository URL.<p class="Docs__api-param-eg"><em>Example:</em> <code>"git@github.com:acme-inc/my-pipeline.git"</code></p></td>
  </tr>
  <tr>
    <th><code>steps</code></th>
    <td>
      An array of the build pipeline steps.<p class="Docs__api-param-eg"><em>Script:</em> <code>{ "type": "script", "name": "Script", "command": "command.sh" }</code></p><p class="Docs__api-param-eg"><em>Wait for all previous steps to finish:</em> <code>{ "type": "waiter" }</code></p><p class="Docs__api-param-eg"><em>Block pipeline (see the <a href="/docs/apis/rest-api/jobs#unblock-a-job">job unblock API</a>):</em> <code>{ "type": "manual" }</code>
    </td>
  </tr>
  </tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#pipeline-level-branch-filtering">branch filter pattern</a> to limit which pushed branches trigger builds on this pipeline.</p>
      <p><em>Example:</em> <code>"main feature/*"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds</code></th>
    <td>
      <p>Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.</p>
      <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
    </td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds_filter</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build cancelling applies to.</p>
      <p><em>Example:</em> <code>"develop prs/*"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>default_branch</code></th>
    <td>
      <p>The name of the branch to prefill when new builds are created or triggered in Buildkite. It is also used to filter the builds and metrics shown on the Pipelines page.</p>
      <p><em>Example:</em> <code>"main"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>
      <p>The pipeline description.</p>
      <p><em>Example:</em> <code>":package: A testing pipeline"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>env</code></th>
    <td>
      <p>The pipeline environment variables.</p>
      <p><em>Example:</em> <code>{"KEY":"value"}</code></p>
    </td>
  </tr>
  <tr>
    <th><code>provider_settings</code></th>
    <td>
      <p>The source provider settings. See the <a href="#provider-settings-properties">Provider Settings</a> section for accepted properties.</p>
      <p><em>Example:</em> <code>{ "publish_commit_status": true, "build_pull_request_forks": true }</code></p>
    </td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds</code></th>
    <td>
      <p>Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.</p>
      <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
    </td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds_filter</code></th>
    <td>
      <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build skipping applies to.</p>
      <p><em>Example:</em> <code>"!main"</code><br><em>Default:</em> <code>null</code></p>
    </td>
  </tr>
  <tr>
    <th><code>teams</code></th>
    <td>
      <p>An array of team UUIDs to add this pipeline to. Allows you to specify the access level for the pipeline in a team. The available access level options are:
      <ul>
        <li><code>read_only</code></li>
        <li><code>build_and_read</code></li>
        <li><code>manage_build_and_read</code></li>
      </ul>
      You can find your team's UUID either using the <a href="/docs/apis/graphql-api">GraphQL API</a>, or on the Settings page for a team. This property is only available if your organization has enabled Teams. Once your organization enables Teams, only administrators can create pipelines without providing team UUIDs. Replaces deprecated <code>team_uuids</code> parameter.</p>
      <p><em>Example:</em></p>
      <%= render_markdown text: %{
```javascript
teams: {
  "14e9501c-69fe-4cda-ae07-daea9ca3afd3": "read_only",
  "5b6c4a01-8e4f-49a3-bf88-be0d47ef9c0a": "manage_build_and_read"
}
```} %>
    </td>
  </tr>
  <tr>
    <th><code>cluster_id</code></th>
    <td>The ID of the <a href="/docs/agent/clusters">cluster</a> the pipeline should run in. Set to <code>null</code> to remove the pipeline from a cluster.<br />You'll need to <a href="/docs/agent/clusters#enable-clusters">enable clusters</a> for your organization to use this feature. <p class="Docs__api-param-eg"><em>Example:</em> <code>"42f1a7da-812d-4430-93d8-1cc7c33a6bcf"</code></p>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation Failed", "errors": [ ... ] }</code></td></tr>
</tbody>
</table>

## Update a pipeline

Updates one or more properties of an existing pipeline.

To update a pipeline's YAML steps, make a PATCH request to the `pipelines` endpoint, passing the `configuration` attribute in the request body:


```bash
curl -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}" \
  -H "Content-Type: application/json" \
  -d '{
    "repository": "git@github.com:acme-inc/new-repo.git",
    "configuration": "steps:\n  - command: \"new.sh\"\n    agents:\n    - \"myqueue=true\""
  }'
```

>🚧
> Patch requests can only update attributes already present in the pipeline YAML.


```json
{
  "id": "14e9501c-69fe-4cda-ae07-daea9ca3afd3",
  "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline",
  "name": "My Pipeline",
  "description": null,
  "slug": "my-pipeline",
  "repository": "git@github.com:acme-inc/new-repo.git",
  "branch_configuration": "main",
  "default_branch": "main"
  "provider": {
    "id": "github",
    "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
    "settings": {
      "publish_commit_status": true,
      "build_pull_requests": true,
      "build_pull_request_forks": false,
      "build_tags": false,
      "publish_commit_status_per_step": false,
      "repository": "acme-inc/new-repo",
      "trigger_mode": "code"
    }
  },
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds",
  "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
  "created_at": "2015-03-01 06:44:40 UTC",
  "archived_at": null,
  "configuration": "steps:\n  - command: \"new.sh\"\n    agents:\n    - \"something=true\"",
  "steps": [
    {
      "type": "script",
      "name": null,
      "command": "new.sh",
      "artifact_paths": null,
      "branch_configuration": null,
      "env": {},
      "timeout_in_minutes": null,
      "agent_query_rules": [
        "myqueue=true"
      ],
      "concurrency": null,
      "parallelism": null
    }
  ],
  "env": {
  },
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private"
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>branch_configuration</code></th>
    <td>A <a href="/docs/pipelines/branch-configuration#pipeline-level-branch-filtering">branch filter pattern</a> to limit which pushed branches trigger builds on this pipeline.<p class="Docs__api-param-eg"><em>Example:</em> <code>"main feature/*"</code><br><em>Default:</em> <code>null</code></p></td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds</code></th>
    <td>Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.<p class="Docs__api-param-eg"><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>cancel_running_branch_builds_filter</code></th>
    <td>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build cancelling applies to. <p class="Docs__api-param-eg"><em>Example:</em> <code>"develop prs/*"</code><br><em>Default:</em> <code>null</code></p></td>
  </tr>
  <tr>
    <th><code>default_branch</code></th>
    <td>The name of the branch to prefill when new builds are created or triggered in Buildkite.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"main"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>description</code></th>
    <td>The pipeline description. <p class="Docs__api-param-eg"><em>Example:</em> <code>":package: A testing pipeline"</code></p></td>
  </tr>
    <tr>
    <th><code>env</code></th>
    <td>The pipeline environment variables. <p class="Docs__api-param-eg"><em>Example:</em> <code>{"KEY":"value"}</code></p></td>
  </tr>
  <tr>
    <th><code>name</code></th>
    <td>The name of the pipeline.<p class="Docs__api-param-eg"><em>Example:</em> <code>"New Pipeline"</code></p></td>
  </tr>
  <tr>
    <th><code>provider_settings</code></th>
    <td>The source provider settings. See the <a href="#provider-settings-properties">Provider Settings</a> section for accepted properties. <p class="Docs__api-param-eg"><em>Example:</em> <code>{ "publish_commit_status": true, "build_pull_request_forks": true }</code></p></td>
  </tr>
  <tr>
    <th><code>repository</code></th>
    <td>The repository URL.<p class="Docs__api-param-eg"><em>Example:</em> <code>"git@github.com/org/repo.git"</code></p></td>
  </tr>
  <tr>
    <th><code>configuration</code></th>
    <td>The YAML pipeline that consists of the build pipeline steps.<p class="Docs__api-param-eg"><em>Example:</em> <code>"steps:\n  - command: \"new.sh\"\n    agents:\n    - \"myqueue=true\""</code></p></td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds</code></th>
    <td>Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.<p class="Docs__api-param-eg"><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>skip_queued_branch_builds_filter</code></th>
    <td>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build skipping applies to. <p class="Docs__api-param-eg"><em>Example:</em> <code>"!main"</code><br><em>Default:</em> <code>null</code></p></td>
  </tr>
  <tr>
    <th><code>visibility</code></th>
    <td>Whether the pipeline is visible to everyone, including users outside this organization. <p class="Docs__api-param-eg"><em>Example:</em> <code>"public"</code><br><em>Default:</em> <code>"private"</code></p></td>
  </tr>
  <tr>
    <th><code>cluster_id</code></th>
    <td>The ID of the <a href="/docs/agent/clusters">cluster</a> the pipeline should run in. Set to <code>null</code> to remove the pipeline from a cluster.<br />You'll need to <a href="/docs/agent/clusters#enable-clusters">enable clusters</a> for your organization to use this feature. <p class="Docs__api-param-eg"><em>Example:</em> <code>"42f1a7da-812d-4430-93d8-1cc7c33a6bcf"</code></p>
  </tr>
</tbody>
</table>

Required scope: `write_pipelines`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Validation Failed", "errors": [ ... ] }</code></td></tr>
</tbody>
</table>

>🚧
> To update a pipeline's teams, please use the <a href="/docs/apis/graphql-api">GraphQL API</a>.

## Archive a pipeline

Archived pipelines are read-only, and are hidden from Pipeline pages by default. Builds, build logs, and artifacts are preserved.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}/archive"
```

```json
{
  "id": "14e9501c-69fe-4cda-ae07-daea9ca3afd3",
  "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline",
  "name": "My Pipeline",
  "description": null,
  "slug": "my-pipeline",
  "repository": "git@github.com:acme-inc/new-repo.git",
  "branch_configuration": "main",
  "default_branch": "main"
  "provider": {
    "id": "github",
    "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
    "settings": {
      "publish_commit_status": true,
      "build_pull_requests": true,
      "build_pull_request_forks": false,
      "build_tags": false,
      "publish_commit_status_per_step": false,
      "repository": "acme-inc/new-repo",
      "trigger_mode": "code"
    }
  },
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds",
  "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
  "created_at": "2015-03-01 06:44:40 UTC",
  "archived_at": "2021-06-01 08:23:35 UTC",
  "configuration": "steps:\n  - command: \"new.sh\"\n    agents:\n    - \"something=true\"",
  "steps": [
    {
      "type": "script",
      "name": null,
      "command": "new.sh",
      "artifact_paths": null,
      "branch_configuration": null,
      "env": {},
      "timeout_in_minutes": null,
      "agent_query_rules": [
        "myqueue=true"
      ],
      "concurrency": null,
      "parallelism": null
    }
  ],
  "env": {
  },
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private"
}
```

Required scope: `write_pipelines`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Forbidden" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Pipeline could not be archived." }</code></td></tr>
</tbody>
</table>

## Unarchive a pipeline

Unarchived pipelines are editable, and are shown on the Pipeline pages.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}/unarchive"
```

```json
{
  "id": "14e9501c-69fe-4cda-ae07-daea9ca3afd3",
  "graphql_id": "UGlwZWxpbmUtLS1lOTM4ZGQxYy03MDgwLTQ4ZmQtOGQyMC0yNmQ4M2E0ZjNkNDg=",
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline",
  "web_url": "https://buildkite.com/acme-inc/my-pipeline",
  "name": "My Pipeline",
  "description": null,
  "slug": "my-pipeline",
  "repository": "git@github.com:acme-inc/new-repo.git",
  "branch_configuration": "main",
  "default_branch": "main"
  "provider": {
    "id": "github",
    "webhook_url": "https://webhook.buildkite.com/deliver/xxx",
    "settings": {
      "publish_commit_status": true,
      "build_pull_requests": true,
      "build_pull_request_forks": false,
      "build_tags": false,
      "publish_commit_status_per_step": false,
      "repository": "acme-inc/new-repo",
      "trigger_mode": "code"
    }
  },
  "skip_queued_branch_builds": false,
  "skip_queued_branch_builds_filter": null,
  "cancel_running_branch_builds": false,
  "cancel_running_branch_builds_filter": null,
  "builds_url": "https://api.buildkite.com/v2/organizations/acme-inc/pipelines/my-pipeline/builds",
  "badge_url": "https://badge.buildkite.com/58b3da999635d0ad2daae5f784e56d264343eb02526f129bfb.svg",
  "created_at": "2015-03-01 06:44:40 UTC",
  "archived_at": null,
  "configuration": "steps:\n  - command: \"new.sh\"\n    agents:\n    - \"something=true\"",
  "steps": [
    {
      "type": "script",
      "name": null,
      "command": "new.sh",
      "artifact_paths": null,
      "branch_configuration": null,
      "env": {},
      "timeout_in_minutes": null,
      "agent_query_rules": [
        "myqueue=true"
      ],
      "concurrency": null,
      "parallelism": null
    }
  ],
  "env": {
  },
  "scheduled_builds_count": 0,
  "running_builds_count": 0,
  "scheduled_jobs_count": 0,
  "running_jobs_count": 0,
  "waiting_jobs_count": 0,
  "visibility": "private"
}
```

Required scope: `write_pipelines`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Forbidden" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Pipeline could not be unarchived." }</code></td></tr>
</tbody>
</table>

## Delete a pipeline

```bash
curl -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}"
```

Required scope: `write_pipelines`

Success response: `204 No Content`

## Add a webhook

Create an GitHub webhook for an existing pipeline that is configured using our GitHub App. Pushes to the linked GitHub repository will trigger builds.

```bash
curl -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}/webhook"
```

Required scope: `write_pipelines`

Success response: `201 CREATED`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>403 Forbidden</code></th><td><code>{ "message": "Forbidden" }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Auto-creating webhooks is not supported for your repository." }</code></td></tr>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Webhooks could not be created for your repository." }</code></td></tr>
</tbody>
</table>

## Provider settings properties

The [Create a YAML pipeline](#create-a-yaml-pipeline) and [Update pipeline](#update-a-pipeline) endpoints accept a `provider_settings` property, which allows you to configure how the pipeline is triggered based on source code provider events. Each pipeline provider's supported settings are below.

Properties available for all providers:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>filter_enabled</code></th>
    <td>
      Whether filter conditions are used for this pipeline.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>filter_condition</code></th>
    <td>
      The conditions under which this pipeline will trigger a build. See the <a href="/docs/pipelines/conditionals">Using conditionals</a> guide for more information.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"build.pull_request.base_branch =~ /main/"</code></p>
    </td>
  </tr>
</tbody>
</table>

Bitbucket Cloud, Bitbucket Server, GitHub, and GitHub Enterprise all have optional `provider_settings`.

Properties available for Bitbucket Server:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>build_pull_requests</code></th>
    <td>
      Whether to create builds for commits that are part of a Pull Request.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>build_tags</code></th>
    <td>
      Whether to create builds when tags are pushed.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
</tbody>
</table>

Properties available for Bitbucket Cloud, GitHub, and GitHub Enterprise:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>build_pull_requests</code></th>
    <td>
      Whether to create builds for commits that are part of a Pull Request.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p>
    </td>
  </tr>
  <tr>
    <th><code>pull_request_branch_filter_enabled</code></th>
    <td>
      Whether to limit the creation of builds to specific branches or patterns.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p>
  </tr>
  <tr>
    <th><code>pull_request_branch_filter_configuration</code></th>
    <td>
      The branch filtering pattern. Only pull requests on branches matching this pattern will cause builds to be created.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>"features/*"</code></p>
    </td>
  </tr>
  <tr>
    <th><code>skip_pull_request_builds_for_existing_commits</code></th>
    <td>
      Whether to skip creating a new build for a pull request if an existing build for the commit and branch already exists.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>build_tags</code></th>
    <td>
      Whether to create builds when tags are pushed.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>publish_commit_status</code></th>
    <td>
      Whether to update the status of commits in Bitbucket or GitHub.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  <tr>
    <th><code>publish_commit_status_per_step</code></th>
    <td>
      Whether to create a separate status for each job in a build, allowing you to see the status of each job directly in Bitbucket or GitHub.
      <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
  </tr>
  </tbody>
</table>

Additional properties available for GitHub:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>trigger_mode</code></th>
      <td>
        What type of event to trigger builds on. <code>Code</code> will create builds when code is pushed to GitHub. <code>Deployment</code> will create builds when a deployment is created with the <a href="https://developer.github.com/v3/repos/deployments/">GitHub Deployments API</a>. <code>Fork</code> will create builds when the GitHub repository is forked. <code>None</code> will not create any builds based on GitHub activity.
        <p class="Docs__api-param-eg"><em>Values:</em> <code>code</code>, <code>deployment</code>, <code>fork</code>, <code>none</code></p></td>
    </tr>
    <tr>
      <th><code>build_pull_request_forks</code></th>
      <td>
        Whether to create builds for pull requests from third-party forks.
        <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
    </tr>
    <tr>
      <th><code>prefix_pull_request_fork_branch_names</code></th>
      <td>
        Prefix branch names for third-party fork builds to ensure they don't trigger branch conditions. For example, the <code>main</code> branch from <code>some-user</code> will become <code>some-user:main</code>.
        <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
    </tr>
    <tr>
      <th><code>separate_pull_request_statuses</code></th>
      <td>
        Whether to create a separate status for pull request builds, allowing you to require a passing pull request build in your <a href="https://help.github.com/en/articles/enabling-required-status-checks">required status checks</a> in GitHub.
        <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
    </tr>
    <tr>
      <th><code>publish_blocked_as_pending</code></th>
      <td>
        The status to use for blocked builds. <code>Pending</code> can be used with <a href="https://help.github.com/en/articles/enabling-required-status-checks">required status checks</a> to prevent merging pull requests with blocked builds.
        <p class="Docs__api-param-eg"><em>Values:</em> <code>true</code>, <code>false</code></p></td>
    </tr>
  </tbody>
</table>
