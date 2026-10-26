# Workflows API

Use the workflows API to create and manage [workflows](/docs/pipelines/configure/tests/workflows) for a Buildkite Test Engine [test suite](/docs/pipelines/configure/tests/test-suites). Each workflow has one monitor, optional execution tag filters, and actions to run when a test alarms or recovers.

The API enforces the same [plan availability and per-suite limits](/docs/pipelines/configure/tests/workflows#plan-availability-and-limits) as the workflow interface. The current Pro plan allows one transition count workflow per suite with add-label and remove-label actions. Other monitor and action types require the corresponding plan entitlements.

In every endpoint, `{org.slug}` is the organization slug, `{suite.slug}` accepts a suite slug or UUID, and `{workflow.id}` is a workflow UUID.

> 📘
> These endpoints require an [API access token](/docs/apis/managing-api-tokens). OIDC tokens are not accepted.

## Create a workflow

This example creates a transition count workflow that adds the `flaky` label when a test alarms and removes it when the test recovers:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/workflows" \
  -H "Content-Type: application/json" \
  -d '{
    "monitor": {
      "type": "transition_count",
      "window_size": 100,
      "alarm_threshold": 0.1,
      "recover_threshold": 0.05
    },
    "filters": [
      { "key": "scm.branch", "operator": "is", "value": "main" }
    ],
    "alarm_actions": [
      { "type": "add_label", "label": "flaky" }
    ],
    "recover_actions": [
      { "type": "remove_label", "label": "flaky" }
    ]
  }'
```

```json
{
  "id": "01234567-89ab-4cde-8fab-0123456789ab",
  "url": "https://api.buildkite.com/v2/analytics/organizations/example-org/suites/example-suite/workflows/01234567-89ab-4cde-8fab-0123456789ab",
  "web_url": "https://buildkite.com/organizations/example-org/analytics/suites/example-suite/workflows/01234567-89ab-4cde-8fab-0123456789ab/events",
  "monitor": {
    "type": "transition_count",
    "window_size": 100,
    "alarm_threshold": 0.1,
    "recover_threshold": 0.05
  },
  "filters": [
    { "key": "scm.branch", "operator": "is", "value": "main" }
  ],
  "alarm_actions": [
    { "type": "add_label", "label": "flaky" }
  ],
  "recover_actions": [
    { "type": "remove_label", "label": "flaky" }
  ],
  "created_at": "2026-10-19T01:00:00.000Z",
  "updated_at": "2026-10-19T01:00:00.000Z",
  "created_by": null
}
```

Required [request body properties](/docs/apis/rest-api#request-body-properties):

Property | Description
-------- | -----------
`monitor` | An object containing a `type` and all configuration fields for that [monitor type](#monitor-configuration). The API does not supply monitor defaults.
{: class="responsive-table"}

Optional request body properties:

Property | Description
-------- | -----------
`filters` | An array of up to four [tag filters](#filter-configuration). Defaults to `[]`. The API does not add a default branch filter.
`alarm_actions` | An array of up to seven [actions](#action-configuration) to run when a test alarms. Defaults to `[]`.
`recover_actions` | An array of up to seven actions to run when a test recovers. Defaults to `[]`. Must be empty for a `new_test` monitor.
{: class="responsive-table"}

Required scope: `write_suites`

Success response: `201 Created`

## List workflows

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a suite's workflows, newest first. Each item has the [workflow data model](#workflow-data-model) fields.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/workflows"
```

Required scope: `read_suites`

Success response: `200 OK`

## Get a workflow

Returns a single workflow with the [workflow data model](#workflow-data-model) fields.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/workflows/{workflow.id}"
```

Required scope: `read_suites`

Success response: `200 OK`

## Update a workflow

Updates the supplied fields and returns the updated workflow. All request body properties are optional. Omitted properties keep their current values, including individual fields within `monitor`. The monitor's `type` cannot be changed.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/workflows/{workflow.id}" \
  -H "Content-Type: application/json" \
  -d '{
    "monitor": {
      "alarm_threshold": 0.2
    },
    "recover_actions": []
  }'
```

This example changes only the alarm threshold and removes all recovery actions. The remaining monitor settings, filters, and alarm actions stay unchanged.

Each supplied `filters`, `alarm_actions`, or `recover_actions` array replaces that entire list. Send `[]` to clear a list. Include every entry you want to retain when replacing a list. Use the same [monitor](#monitor-configuration), [filter](#filter-configuration), and [action](#action-configuration) fields as for creation. Only fields belonging to the workflow's current monitor type are accepted.

Required scope: `write_suites`

Success response: `200 OK`

## Delete a workflow

Deletes the workflow. A subsequent request for the deleted workflow returns `404 Not Found`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}/workflows/{workflow.id}"
```

Required scope: `write_suites`

Success response: `204 No Content`

## Monitor configuration

The `monitor.type` selects the [monitor](/docs/pipelines/configure/tests/workflows/monitors) and its configuration fields. All fields listed for a type are required on creation. Thresholds must be JSON numbers, not strings. Recovery thresholds must be strictly lower than alarm thresholds.

> 📘
> The probabilistic flakiness monitor is only available on [Enterprise](https://buildkite.com/pricing) plans.

Type | Configuration fields
---- | --------------------
`transition_count` | `window_size`: integer from `2` to `1000`. `alarm_threshold` and `recover_threshold`: numbers from `0` to `1`, with up to three decimal places. Requires a nonempty `scm.branch` filter.
`probabilistic_flakiness` | `alarm_threshold`: number from `0.025` to `1`. `recover_threshold`: number from `0` to `1`.
`duration_threshold` | `aggregation`: `"p50"`. `evaluation_window`: integer from `1` to `100`. `alarm_threshold_ms` and `recover_threshold_ms`: integers from `0` to `3600000`, in milliseconds.
`passed_on_retry` | No additional configuration fields.
`new_test` | No additional configuration fields. The suite must have at least one run before creation, and `recover_actions` must be empty.
{: class="responsive-table"}

> 📘 Duration units
> The REST API uses milliseconds for duration thresholds. The workflow interface uses seconds.

## Filter configuration

Each entry in `filters` selects [execution tags](/docs/pipelines/configure/tests/test-suites/tags) to include in the monitor's input. All three fields are required:

Field | Description
----- | -----------
`key` | A nonempty tag key, such as `"scm.branch"`. Must start with a letter, contain only letters, digits, underscores, periods, or hyphens, and be at most 64 bytes. Mutable tags cannot be used for new or changed filters.
`operator` | One of `"is"`, `"is_not"`, or `"starts_with"`.
`value` | A nonempty tag value, at most 128 bytes.
{: class="responsive-table"}

A workflow accepts up to four filters. Keys and values have leading and trailing whitespace removed. Unlike workflows configured in the interface, API-created workflows do not automatically receive a default branch filter. Supply a `scm.branch` filter explicitly when you want to monitor only your default branch.

## Action configuration

Each entry in `alarm_actions` or `recover_actions` requires a `type` and all fields listed for that type. See [Alarm and recover actions](/docs/pipelines/configure/tests/workflows/actions) for action behavior and notification templates.

Type | Configuration fields
---- | --------------------
`add_label` | `label`: a normalized label name, from one to 25 characters. Use lowercase words separated by hyphens. A missing label is created in the suite.
`remove_label` | `label`: the same format as `add_label`.
`change_state` | `state`: `"enabled"`, `"muted"`, or `"skipped"`. Requires test state management and access to the requested state on the suite.
`send_webhook_notification` | `endpoint`: an HTTP or HTTPS URL, up to 2048 characters. For example, `"https://example.com/webhook"`.
`send_slack_notification` | `slack_workspace_id`: the UUID of an enabled Slack workspace notification service in your organization. `channel`: a nonempty channel string. `message_template`: a nonempty Liquid template, up to 1000 characters.
`create_linear_issue` | `linear_team_id`: the UUID of a team accessible to your organization's Linear integration. `title_template` and `description_template`: nonempty Liquid templates. Requires an enabled Linear integration.
{: class="responsive-table"}

Each action list accepts up to seven entries. The `new_test` monitor accepts alarm actions only.

On the current Pro plan, you can configure only `add_label` and `remove_label` actions. All other action types require advanced workflows. See [Plan availability and limits](/docs/pipelines/configure/tests/workflows#plan-availability-and-limits) for details.

## Workflow data model

Create, get, and update operations return a workflow object. List operations return an array of these objects. The [create example](#create-a-workflow) shows the response shape.

Field | Description
----- | -----------
`id` | Workflow UUID. Read-only.
`url` | Canonical API URL. Read-only.
`web_url` | Workflow events URL in the Buildkite interface. Read-only.
`monitor` | Monitor type and configuration.
`filters` | Array of tag filters.
`alarm_actions` | Array of alarm actions.
`recover_actions` | Array of recovery actions.
`created_at` | Creation timestamp in ISO 8601 format. Read-only.
`updated_at` | Last update timestamp in ISO 8601 format. Read-only.
`created_by` | Creator object with `id`, `graphql_id`, `name`, and `email`, or `null`. Read-only.
{: class="responsive-table"}

All fields are present in every workflow response. Send only writable fields in create and update requests. Monitor and action types may be extended, so clients should ignore unknown response fields and handle unknown types.

> 🚧 Webhook endpoint visibility
> Webhook endpoints are returned in full only when the caller can edit the suite. Otherwise, the endpoint is masked after the host, for example, `https://example.com/[REDACTED]`.

## Error responses

Requests reject unknown fields and incorrect JSON types. Validation failures return `422 Unprocessable Entity`, with a JSON Pointer in each error's `field` identifying the invalid request value:

```json
{
  "message": "Validation Failed",
  "errors": [
    {
      "field": "/monitor/recover_threshold",
      "code": "must be less than alarm threshold"
    }
  ]
}
```

Status | Description
------ | -----------
`400 Bad Request` | The request is malformed or pagination values are invalid.
`401 Unauthorized` | Authentication failed.
`403 Forbidden` | The token lacks the required scope, the caller lacks suite permissions, or the plan does not include workflows.
`404 Not Found` | The organization, suite, or workflow was not found.
`422 Unprocessable Entity` | Validation failed, the plan does not include a requested monitor or action type, or the suite has reached its workflow limit.
`503 Service Unavailable` | Linear could not be reached while validating a new Linear action. Retry the request later.
{: class="responsive-table"}
