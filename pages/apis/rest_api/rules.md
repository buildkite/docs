# Rules API

The rules API endpoint lets you create and manage rules in your organization.

## Rules

[_Rules_](/docs/pipelines/security/clusters/rules) is a Buildkite feature that can do the following:

<%= render_markdown partial: 'pipelines/security/clusters/rules_summary' %>

### List rules

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's rules.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/rules"
```

```json
[
  {
    "uuid": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
    "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
    "url": "http://api.buildkite.com/v2/organizations/acme-inc/rules/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
    "type": "pipeline.trigger_build.pipeline",
    "source_type": "pipeline",
    "source_uuid": "16f3b56f-4934-4546-923c-287859851332",
    "target_type": "pipeline",
    "target_uuid": "d07d5d84-d1bd-479c-902c-ce8a01ce5aac",
    "effect": "allow",
    "action": "trigger_build",
    "created_at": "2024-08-26T03:22:45.555Z",
    "created_by": {
      "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
      "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
      "name": "Sam Kim",
      "email": "sam@example.com",
      "avatar_url": "https://www.gravatar.com/avatar/example",
      "created_at": "2013-08-29T10:10:03.000Z"
    }
  }
]
```

Required scope: `read_rules`

Success response: `200 OK`

### Get a rule

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/rules/{uuid}"
```

```json
{
  "uuid": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/rules/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "type": "pipeline.trigger_build.pipeline",
  "source_type": "pipeline",
  "source_uuid": "16f3b56f-4934-4546-923c-287859851332",
  "target_type": "pipeline",
  "target_uuid": "d07d5d84-d1bd-479c-902c-ce8a01ce5aac",
  "effect": "allow",
  "action": "trigger_build",
  "created_at": "2024-08-26T03:22:45.555Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

Required scope: `read_rules`

Success response: `200 OK`

### Create a rule

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/rules" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "pipeline.trigger_build.pipeline",
    "value": {
      "source_pipeline": "16f3b56f-4934-4546-923c-287859851332",
      "target_pipeline": "d07d5d84-d1bd-479c-902c-ce8a01ce5aac"
    }
  }'
```

```json
{
  "uuid": "42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "graphql_id": "Q2x1c3Rlci0tLTQyZjFhN2RhLTgxMmQtNDQzMC05M2Q4LTFjYzdjMzNhNmJjZg==",
  "organization_uuid": "f02d6a6f-7a0e-481d-9d6d-89b427aec48d",
  "url": "http://api.buildkite.com/v2/organizations/acme-inc/rules/42f1a7da-812d-4430-93d8-1cc7c33a6bcf",
  "type": "pipeline.trigger_build.pipeline",
  "source_type": "pipeline",
  "source_uuid": "16f3b56f-4934-4546-923c-287859851332",
  "target_type": "pipeline",
  "target_uuid": "d07d5d84-d1bd-479c-902c-ce8a01ce5aac",
  "effect": "allow",
  "action": "trigger_build",
  "created_at": "2024-08-26T03:22:45.555Z",
  "created_by": {
    "id": "3d3c3bf0-7d58-4afe-8fe7-b3017d5504de",
    "graphql_id": "VXNlci0tLTNkM2MzYmYwLTdkNTgtNGFmZS04ZmU3LWIzMDE3ZDU1MDRkZQo=",
    "name": "Sam Kim",
    "email": "sam@example.com",
    "avatar_url": "https://www.gravatar.com/avatar/example",
    "created_at": "2013-08-29T10:10:03.000Z"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>type</code></th>
    <td>The rule type. Must match one of the <a href="/docs/pipelines/security/clusters/rules#rule-types">available rule types</a>.<br>
    <em>Example:</em>
      <ul>
        <li><code>"pipeline.trigger_build.pipeline"</code><br/>or</li>
        <li><code>"pipeline.artifacts_read.pipeline"</code></li>
    </td>
  </tr>
  <tr>
    <th><code>value</code></th>
    <td>A JSON object containing the value fields for the rule. <code>source_pipeline</code> and <code>target_pipeline</code> fields accept either a pipeline UUID or a pipeline slug.<br>
    <em>Example:</em> <code>{"source_pipeline": "16f3b56f-4934-4546-923c-287859851332", "target_pipeline": "d07d5d84-d1bd-479c-902c-ce8a01ce5aac"}</code></td>
  </tr>
</tbody>
</table>

Required scope: `write_rules`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason for failure" }</code></td></tr>
</tbody>
</table>

### Delete a rule

Delete a rule.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/rules/{uuid}"
```

Required scope: `write_rules`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
<tbody>
  <tr><th><code>422 Unprocessable Entity</code></th><td><code>{ "message": "Reason the rule couldn't be deleted" }</code></td></tr>
</tbody>
</table>

