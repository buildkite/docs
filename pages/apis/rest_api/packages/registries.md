# Registries API

The registries API lets you create and manage registries in your organization.

## Create a registry

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/#{org.slug}/registries" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my registry",
    "ecosystem": "ruby"
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
  "description": null,
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
  <tr><th><code>ecosystem</code></th><td>Registry ecosystem based on the <a href="/docs/packages#get-started">package ecosystem</a> for the new registry.<br><em>Example:</em> <code>"ruby"</code>.</td></tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>description</code></th><td>Description of the registry.<br><em>Default value:</em> <code>null</code>.</td></tr>
  </tbody>
</table>

Required scope: `create_registries`

Success response: `200 OK`

## List all registries

Returns a list of an organization's registries.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/#{org.slug}/registries"
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
    "description": null,
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
  -X GET "https://api.buildkite.com/v2/packages/organizations/#{org.slug}/registries/#{registry.slug}"
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
  "description": null,
  "emoji": null,
  "color": null,
  "public": false,
  "oidc_policy": null
}
```

Required scope: `read_registries`

Success response: `200 OK`
