# Registries API

The registries API lets you create and manage registries in your organization.

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
