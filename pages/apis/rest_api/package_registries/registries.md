# Registries API

The registries API endpoint lets you [create and manage registries](/docs/package-registries/registries/manage) in your organization.

## Create a registry

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my registry",
    "ecosystem": "ruby",
    "description": "registry containing ruby gems",
    "team_ids": [
      "team-one-uuid", "team-two-uuid"
    ],
    "oidc_policy": [
      {
        "iss": "https://agent.buildkite.com",
        "claims": {
          "organization_slug": "my-org",
          "pipeline_slug": {
            "in": ["my-pipeline", "my-other-pipeline"]
          }
        }
      }
    ]
  }'
```

```json
{
  "id": "0191df84-85e4-77aa-83ba-6579084728eb",
  "graphql_id": "UmVnaXN0cnktLS0wMTkxZGY4NC04NWU0LTc3YWEtODNiYS02NTc5MDg0NzI4ZWI=",
  "slug": "my-registry",
  "url": "https://api.buildkite.com/v2/packages/organizations/my-org/registries/my-registry",
  "web_url": "https://buildkite.com/organizations/my-org/registries/my-registry",
  "name": "my registry",
  "ecosystem": "ruby",
  "description": "registry containing ruby gems",
  "emoji": null,
  "color": null,
  "public": false,
  "oidc_policy": null
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>name</code></th><td>Name of the new registry.<br><em>Example:</em> <code>"my registry"</code>.</td></tr>
  <tr><th><code>ecosystem</code></th><td>Registry ecosystem based on the <a href="/docs/package-registries#get-started">package ecosystem</a> for the new registry.<br><em>Example:</em> <code>"ruby"</code>.</td></tr>
  <tr><th><code>team_ids</code></th><td>The IDs of one or more teams who will be granted access to this registry.<br>Required only when the <a href="/docs/platform/team-management/permissions">teams feature</a> has been enabled.<br><em>Example:</em> <code>[ "2a1ac413-a56c-4aaa-aede-dc49bb46d00f", "5916fed1-1fbb-4a8d-9791-5b3fa0b5d269" ]</code>.</td></tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>description</code></th><td>Description of the registry.<br><em>Default value:</em> <code>null</code>.</td></tr>
    <tr><th><code>emoji</code></th><td>Emoji for the registry using the <a href="/docs/apis/rest-api/emojis">emoji syntax</a>.<br><em>Example:</em> <code>"\:sunflower\:"</code>.</td></tr>
    <tr><th><code>color</code></th><td>Color hex code for the registry.<br><em>Example:</em> <code>"#f0ccff"</code>.</td></tr>
    <tr><th><code>oidc_policy</code></th><td>A policy matching a <a href="/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry-basic-oidc-policy-format">basic</a> or <a href="/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example">more complex</a> OIDC policy format. Can be either stringified YAML, or a JSON array of policy statements.<br><em>Default value:</em> <code>null</code>.</td></tr>
  </tbody>
</table>

Required scope: `write_registries`

Success response: `200 OK`

## List all registries

Returns a list of an organization's registries.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries"
```

```json
[
  {
    "id": "0191df84-85e4-77aa-83ba-6579084728eb",
    "graphql_id": "UmVnaXN0cnktLS0wMTkxZGY4NC04NWU0LTc3YWEtODNiYS02NTc5MDg0NzI4ZWI=",
    "slug": "my-registry",
    "url": "https://api.buildkite.com/v2/packages/organizations/my-org/registries/my-registry",
    "web_url": "https://buildkite.com/organizations/my-org/packages/registries/my-registry",
    "name": "my registry",
    "ecosystem": "ruby",
    "description": "registry containing ruby gems",
    "emoji": null,
    "color": null,
    "public": false,
    "oidc_policy": null
  }
]
```

Required scope: `read_registries`

Success response: `200 OK`

## Get a registry

Returns the details for a single registry, looked up by its slug.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}"
```

```json
{
  "id": "0191df84-85e4-77aa-83ba-6579084728eb",
  "graphql_id": "UmVnaXN0cnktLS0wMTkxZGY4NC04NWU0LTc3YWEtODNiYS02NTc5MDg0NzI4ZWI=",
  "slug": "my-registry",
  "url": "https://api.buildkite.com/v2/packages/organizations/my-org/registries/my-registry",
  "web_url": "https://buildkite.com/organizations/my-org/registries/my-registry",
  "name": "my registry",
  "ecosystem": "ruby",
  "description": "registry containing ruby gems",
  "emoji": null,
  "color": null,
  "public": false,
  "oidc_policy": null
}
```

Required scope: `read_registries`

Success response: `200 OK`

## Update a registry

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my registry",
    "description": "registry containing ruby gems",
    "oidc_policy": [
      {
        "iss": "https://agent.buildkite.com",
        "claims": {
          "organization_slug": "my-org",
          "pipeline_slug": {
            "in": ["my-pipeline"]
          }
        }
      }
    ]
  }'
```

```json
{
  "id": "0191df84-85e4-77aa-83ba-6579084728eb",
  "graphql_id": "UmVnaXN0cnktLS0wMTkxZGY4NC04NWU0LTc3YWEtODNiYS02NTc5MDg0NzI4ZWI=",
  "slug": "my-registry",
  "url": "https://api.buildkite.com/v2/packages/organizations/my-org/registries/my-registry",
  "web_url": "https://buildkite.com/organizations/my-org/registries/my-registry",
  "name": "my registry",
  "ecosystem": "ruby",
  "description": "registry containing ruby gems",
  "emoji": null,
  "color": null,
  "public": false,
  "oidc_policy": null
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>name</code></th><td>Name of the registry.<br><em>Example:</em> <code>my registry</code>.</td></tr>
    <tr><th><code>description</code></th><td>Description of the registry.<br><em>Example:</em> <code>registry containing ruby gems</code>.</td></tr>
    <tr><th><code>oidc_policy</code></th><td>A policy matching a <a href="/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry-basic-oidc-policy-format">basic</a> or <a href="/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example">more complex</a> OIDC policy format. Can be either stringified YAML, or a JSON array of policy statements. Be aware that if you are modifying an existing OIDC policy, the entire revised OIDC policy needs to be re-posted in this update request.<br><em>Default value:</em> <code>null</code>.</td></tr>
  </tbody>
</table>

Required scope: `write_registries`

Success response: `200 OK`

## Delete a registry

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}"
```

Required scope: `delete_registries`

Success response: `200 OK`
