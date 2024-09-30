# Packages API

The packages API endpoint lets you create and manage packages in a registry.

## Publish a package

The following type of `curl` syntax will work across [all package ecosystems supported by Buildkite Packages](/docs/packages/ecosystems) (with the `file` form-field modified accordingly).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages" \
  -F 'file=@path/to/debian/package/banana_1.1-2_amd64.deb
```

This type of REST API call, however, is recommended for:

- [Alpine (apk)](/docs/packages/alpine) packages
- [Debian/Ubuntu (deb)](/docs/packages/debian) packages
- [Files (generic)](/docs/packages/files)
- [Helm (Standard)](/docs/packages/helm#publish-a-chart) charts
- [Python (PyPI)](/docs/packages/python) packages
- [Red Hat (RPM)](/docs/packages/red-hat) packages
- [Terraform](/docs/packages/terraform#publish-a-module) modules

For other supported package ecosystems, it is recommended that you use these ecosystems' native tools to publish to registries in your Buildkite Packages organization. These ecosystems are:

- [Container (Docker)](/docs/packages/container#publish-an-image) images
- [Helm (OCI)](/docs/packages/helm-oci#publish-a-chart) charts
- Java ([Maven](/docs/packages/maven#publish-a-package) or [Gradle leveraging the Maven Publish Plugin](/docs/packages/gradle#publish-a-package)) packages
- [JavaScript (npm)](/docs/packages/javascript#publish-a-package) packages
- [Ruby (RubyGems)](/docs/packages/ruby#publish-a-package) packages

The following type of response is returned by Buildkite upon a successful `curl` publishing event.

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

Required request form-field content:

<table class="responsive-table">
<tbody>
  <tr><th><code>file</code></th><td>Path to the package.<br><em>Example:</em> <code>"file=@path/to/debian/package/banana_1.1-2_amd64.deb"</code>.</td></tr>
</tbody>
</table>

Required scope: `write_packages`

Success response: `200 OK`

## Get a package

Returns the details for a single package.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages/{id}"
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

## Copy a package

Copies a package from a source registry to a destination registry.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{source_registry.slug}/packages/{package.id}/copy?to={destination_registry.slug}"
  -H "Content-Type: application/json"
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

Required [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
<tbody>
  <tr><th><code>to</code></th><td>Destination registry slug.<br><em>Example:</em> <code>"to=my-registry"</code>.</td></tr>
</tbody>
</table>

Required scopes: `read_packages, write_packages`

Success response: `200 OK`

## Delete a package

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages/{id}"
```

Required scope: `delete_packages`

Success response: `200 OK`
