# Packages API

The packages API endpoint lets you create and manage packages in a registry.

## Publish a package

The following type of `curl` syntax for publishing to registries will work across [all package ecosystems supported by Buildkite Package Registries](/docs/package-registries/ecosystems), with the `file` form-field modified accordingly.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages" \
  -F 'file=@path/to/debian/package/banana_1.1-2_amd64.deb
```

However, this type of REST API call is just recommended for:

- [Alpine (apk)](/docs/package-registries/alpine#publish-a-package) packages
- [Debian/Ubuntu (deb)](/docs/package-registries/debian#publish-a-package) packages
- [Files (generic)](/docs/package-registries/files#publish-a-file)
- [Helm (Standard)](/docs/package-registries/helm#publish-a-chart) charts
- [Python (PyPI)](/docs/package-registries/python#publish-a-package) packages
- [Red Hat (RPM)](/docs/package-registries/red-hat#publish-a-package) packages
- [Terraform](/docs/package-registries/terraform#publish-a-module) modules

For other supported package ecosystems, it is recommended that you use their native tools to publish to registries in your Buildkite Package Registries organization. These ecosystems' native tools are for:

- [Container (Docker)](/docs/package-registries/container#publish-an-image) images
- [Helm (OCI)](/docs/package-registries/helm-oci#publish-a-chart) charts
- Java ([Maven](/docs/package-registries/maven#publish-a-package) or [Gradle leveraging the Maven Publish Plugin](/docs/package-registries/gradle#publish-a-package)) packages
- [JavaScript (npm)](/docs/package-registries/javascript#publish-a-package) packages
- [Ruby (RubyGems)](/docs/package-registries/ruby#publish-a-package) packages

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
