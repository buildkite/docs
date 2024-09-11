# Packages API

The packages tokens API lets you create and manage packages in a registry.

## Get a package

Returns the details for a single package.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/#{org.slug}/registries/#{registry.slug}/packages/#{id}"
```

```json
{
  "id": "0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
  "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
  "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
  "name": "banana",
  "organization": {
    "id": "0190e784-eeb7-4ce4-9d2d-87f7aba85433",
    "slug": "my_great_org",
    "url": "https://api.buildkite.com/v2/organizations/my_great_org",
    "web_url": "https://buildkite.com/my_great_org"
  },
  "registry": {
    "id": "0191e238-e0a3-7b0b-bb34-beea0035a39d",
    "graphql_id": "UmVnaXN0cnktLS0wMTkxZTIzOC1lMGEzLTdiMGItYmIzNC1iZWVhMDAzNWEzOWQ=",
    "slug": "my-registry",
    "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry",
    "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry"
  }
}
```

Required scope: `read_packages`

Success response: `200 OK`

## Delete a package

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/packages/organizations/#{org.slug}/registries/#{registry.slug}/packages/#{id}"
```

Required scope: `delete_packages`

Success response: `200 OK`
