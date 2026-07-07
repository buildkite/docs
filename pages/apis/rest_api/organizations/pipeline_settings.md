# Pipeline settings API

The pipeline settings API endpoint lets organization administrators read and update organization-level pipeline settings. These settings correspond to the options available in the Buildkite **Pipeline Settings** page for your organization.

Both read and write operations require organization administrator privileges (the `change_organization` permission).

## Get pipeline settings

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings"
```

```json
{
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipeline-settings",
  "default_branch": "main",
  "default_cluster_id": "3f4b6df0-1234-5678-abcd-9e0a1b2c3d4e",
  "default_timeout_in_minutes": 60,
  "maximum_timeout_in_minutes": 120,
  "scheduled_job_expiry_in_minutes": null,
  "hosted_agents_terminal_access": {
    "enabled": true,
    "enabled_at": "2024-06-01T12:00:00.000Z",
    "enabled_by": {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "name": "Sam Kim"
    }
  },
  "public_pipeline_creation": {
    "enabled": false,
    "enabled_at": null,
    "enabled_by": null
  },
  "advanced_queue_metrics": {
    "enabled": false,
    "enabled_at": null,
    "enabled_by": null,
    "disable_supported": false
  },
  "build_exports": {
    "available": true,
    "enabled": true,
    "location": "my-export-bucket",
    "strategy_id": "s3",
    "supported_strategies": ["s3", "gcs"]
  }
}
```

Required scope: `read_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>read_organization_settings</code> scope, or the authenticated user does not have organization administrator privileges.</td>
  </tr>
</tbody>
</table>

## Update pipeline settings

Updates one or more simple pipeline settings for the organization. Only the fields you include in the request body are changed.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings" \
  -d '{
    "default_branch": "main",
    "default_timeout_in_minutes": 60
  }'
```

```json
{
  "url": "https://api.buildkite.com/v2/organizations/my-great-org/pipeline-settings",
  "default_branch": "main",
  "default_cluster_id": null,
  "default_timeout_in_minutes": 60,
  "maximum_timeout_in_minutes": 120,
  "scheduled_job_expiry_in_minutes": null,
  "hosted_agents_terminal_access": {
    "enabled": false,
    "enabled_at": null,
    "enabled_by": null
  },
  "public_pipeline_creation": {
    "enabled": false,
    "enabled_at": null,
    "enabled_by": null
  },
  "advanced_queue_metrics": {
    "enabled": false,
    "enabled_at": null,
    "enabled_by": null,
    "disable_supported": false
  },
  "build_exports": {
    "available": true,
    "enabled": false,
    "location": null,
    "strategy_id": null,
    "supported_strategies": ["s3", "gcs"]
  }
}
```

Required scope: `write_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>A field value failed validation—for example, a <code>default_cluster_id</code> that is not a syntactically valid UUID, a cluster that belongs to another organization, or a value that fails the organization's own validations.</td>
  </tr>
</tbody>
</table>

### Request body fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>default_branch</code></th>
    <td>The default branch name for new pipelines in the organization.</td>
  </tr>
  <tr>
    <th><code>default_cluster_id</code></th>
    <td>The UUID of the cluster to use as the default for new pipelines. Pass <code>null</code> to clear the default cluster.</td>
  </tr>
  <tr>
    <th><code>default_timeout_in_minutes</code></th>
    <td>The default job timeout in minutes for new pipelines.</td>
  </tr>
  <tr>
    <th><code>maximum_timeout_in_minutes</code></th>
    <td>The maximum job timeout in minutes that can be set on any pipeline in the organization.</td>
  </tr>
  <tr>
    <th><code>scheduled_job_expiry_in_minutes</code></th>
    <td>The number of minutes after which scheduled jobs expire if they have not started.</td>
  </tr>
</tbody>
</table>

## Enable hosted agents terminal access

Enables SSH terminal access for hosted agents in the organization. Records who enabled it and when.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/hosted-agents-ssh"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

## Disable hosted agents terminal access

Disables SSH terminal access for hosted agents in the organization.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/hosted-agents-ssh"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

## Enable public pipeline creation

Allows organization members to create public pipelines.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/public-pipelines"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

## Disable public pipeline creation

Prevents organization members from creating public pipelines.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/public-pipelines"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

## Enable advanced queue metrics

Enables advanced queue metrics for clusters in the organization. This is a one-way operation. Once enabled, it cannot be disabled via the API (the `disable_supported` field in the response will be `false`). To disable advanced queue metrics, contact Buildkite support.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/advanced-queue-metrics"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

## Configure build export

Sets the location and strategy for exporting build data. Build export is a plan-gated feature. The `build_exports.available` field in the response indicates whether it is available on your plan.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/build-export" \
  -d '{
    "location": "my-export-bucket",
    "strategy_id": "s3"
  }'
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>Your billing plan does not include build data export.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td><code>location</code> is missing or blank, <code>strategy_id</code> is missing or not a recognized value, a parameter is the wrong type, or Buildkite cannot validate access to the destination bucket. To clear the export location, use <a href="#disable-build-export">disable build export</a> instead.</td>
  </tr>
</tbody>
</table>

### Request body fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>location</code></th>
    <td>Required. The destination bucket name, or a fully qualified URI (for example, <code>s3://my-export-bucket</code>). If a fully qualified URI is provided, the prefix is stripped automatically so it does not get double-applied.</td>
  </tr>
  <tr>
    <th><code>strategy_id</code></th>
    <td>Required. The export strategy to use. Supported values are listed in the <code>build_exports.supported_strategies</code> field of the GET response (for example, <code>s3</code> or <code>gcs</code>).</td>
  </tr>
</tbody>
</table>

## Disable build export

Clears the build export configuration, stopping further build data exports.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/pipeline-settings/build-export"
```

Returns the full pipeline settings resource.

Required scope: `write_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>Your billing plan does not include build data export.</td>
  </tr>
</tbody>
</table>

## Response fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL for this resource.</td>
  </tr>
  <tr>
    <th><code>default_branch</code></th>
    <td>The default branch name for new pipelines in the organization.</td>
  </tr>
  <tr>
    <th><code>default_cluster_id</code></th>
    <td>The UUID of the default cluster for new pipelines, or <code>null</code> if no default cluster is set.</td>
  </tr>
  <tr>
    <th><code>default_timeout_in_minutes</code></th>
    <td>The default job timeout in minutes for new pipelines.</td>
  </tr>
  <tr>
    <th><code>maximum_timeout_in_minutes</code></th>
    <td>The maximum job timeout in minutes that can be set on any pipeline.</td>
  </tr>
  <tr>
    <th><code>scheduled_job_expiry_in_minutes</code></th>
    <td>The number of minutes after which unstarted scheduled jobs expire, or <code>null</code> if not set.</td>
  </tr>
  <tr>
    <th><code>hosted_agents_terminal_access</code></th>
    <td>
      SSH terminal access settings for hosted agents. Contains:
      <ul>
        <li><code>enabled</code> — whether SSH terminal access is currently enabled.</li>
        <li><code>enabled_at</code> — ISO 8601 timestamp when it was enabled, or <code>null</code>.</li>
        <li><code>enabled_by</code> — object with <code>id</code> and <code>name</code> of the user who enabled it, or <code>null</code>.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th><code>public_pipeline_creation</code></th>
    <td>
      Public pipeline creation settings. Contains:
      <ul>
        <li><code>enabled</code> — whether members can create public pipelines.</li>
        <li><code>enabled_at</code> — ISO 8601 timestamp when it was enabled, or <code>null</code>.</li>
        <li><code>enabled_by</code> — object with <code>id</code> and <code>name</code> of the user who enabled it, or <code>null</code>.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th><code>advanced_queue_metrics</code></th>
    <td>
      Advanced queue metrics settings. Contains:
      <ul>
        <li><code>enabled</code> — whether advanced queue metrics are enabled.</li>
        <li><code>enabled_at</code> — ISO 8601 timestamp when it was enabled, or <code>null</code>.</li>
        <li><code>enabled_by</code> — object with <code>id</code> and <code>name</code> of the user who enabled it, or <code>null</code>.</li>
        <li><code>disable_supported</code> — always <code>false</code>; advanced queue metrics cannot be disabled via the API.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <th><code>build_exports</code></th>
    <td>
      Build data export settings. Contains:
      <ul>
        <li><code>available</code> — whether build data export is available on your billing plan.</li>
        <li><code>enabled</code> — whether build data export is currently configured.</li>
        <li><code>location</code> — the destination bucket name, or <code>null</code> if not configured.</li>
        <li><code>strategy_id</code> — the active export strategy (for example, <code>s3</code> or <code>gcs</code>), or <code>null</code>.</li>
        <li><code>supported_strategies</code> — list of strategy IDs accepted by the configure build export endpoint.</li>
      </ul>
    </td>
  </tr>
</tbody>
</table>
