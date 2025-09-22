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

- [Alpine (apk)](/docs/package-registries/ecosystems/alpine#publish-a-package) packages
- [Debian/Ubuntu (deb)](/docs/package-registries/ecosystems/debian#publish-a-package) packages
- [Files (generic)](/docs/package-registries/ecosystems/files#publish-a-file)
- [Helm (Standard)](/docs/package-registries/ecosystems/helm#publish-a-chart) charts
- [Python (PyPI)](/docs/package-registries/ecosystems/python#publish-a-package) packages
- [Red Hat (RPM)](/docs/package-registries/ecosystems/red-hat#publish-a-package) packages
- [Terraform](/docs/package-registries/ecosystems/terraform#publish-a-module) modules

For other supported package ecosystems, it is recommended that you use their native tools to publish to registries in your Buildkite Package Registries organization. These ecosystems' native tools are for:

- [OCI (Docker)](/docs/package-registries/ecosystems/oci#publish-an-image) images
- [Helm (OCI)](/docs/package-registries/ecosystems/helm-oci#publish-a-chart) charts
- Java ([Maven](/docs/package-registries/ecosystems/maven#publish-a-package) or [Gradle](/docs/package-registries/ecosystems/gradle-kotlin#publish-a-package)) packages
- [JavaScript (npm)](/docs/package-registries/ecosystems/javascript#publish-a-package) packages
- [Ruby (RubyGems)](/docs/package-registries/ecosystems/ruby#publish-a-package) packages

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

## List all packages

Returns a [paginated list](<%= paginated_resource_docs_url %>) of all packages in a registry.
Packages are listed in the order they were created (newest first).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages"
```

```json
{
  "items": [
    {
      "id": "0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "name": "banana",
      "created_at": "2024-08-22T06:24:53Z",
      "version": "1.0"
    },
    {
      "id": "019178c2-6b08-7d66-a1db-b79b8ba83151",
      "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry/packages/019178c2-6b08-7d66-a1db-b79b8ba83151",
      "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry/packages/019178c2-6b08-7d66-a1db-b79b8ba83151",
      "name": "grapes",
      "created_at": "2024-08-21T06:24:53Z",
      "version": "2.8.3"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry/packages",
  }
}
```

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
  <tbody>
    <tr><th><code>name</code></th><td>Filters the results by the package name.<br><em>Example:</em> <code>?name=banana</code>.</td></tr>
  </tbody>
</table>

Required scope: `read_packages`

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

For some supported [package ecosystems](/docs/package-registries/ecosystems), copies a package from a source registry to a destination registry.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{source_registry.slug}/packages/{package.id}/copy?to={destination_registry.slug}"
  -H "Content-Type: application/json"
```

Currently, this REST API call only supports package types belonging to the following package ecosystems:

- [Alpine (apk)](/docs/package-registries/ecosystems/alpine)
- [Debian/Ubuntu (deb)](/docs/package-registries/ecosystems/debian)
- [Files (generic)](/docs/package-registries/ecosystems/files)
- [JavaScript (npm)](/docs/package-registries/ecosystems/javascript)
- [Python (PyPI)](/docs/package-registries/ecosystems/python)
- [Red Hat (RPM)](/docs/package-registries/ecosystems/red-hat)
- [Ruby (RubyGems)](/docs/package-registries/ecosystems/ruby)

If you wish this feature to be available for package types belonging to other package ecosystems, please contact [support](https://buildkite.com/about/contact/).

The following type of response is returned by Buildkite upon a successful `curl` copying event.

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
