# Cache registries

Use these endpoints to list, inspect, create, update, and delete a cluster's [cache registries](/docs/pipelines/configure/cache#manage-cache-registries).

> 📘 Public preview
> The cache registries API is available to all Buildkite customers in public preview. This availability applies to registry administration only. Saving and restoring cache entries with Buildkite Cache remains in private preview and requires access as described in the [Buildkite Cache guide](/docs/pipelines/configure/cache).

This API manages cache registry metadata and policy only—cache entries and agent save and restore operations aren't exposed. Use the web interface to configure a registry's cache store or change a cluster's default registry.

Member endpoints (get, update, and delete) accept only the cache registry's `uuid` as the `{id}` path parameter. The `slug` returned in responses is informational and can't be used to look up or modify a cache registry.

Policy documents must be JSON objects, not YAML or JSON-encoded strings. The API validates and normalizes each policy, so authored YAML comments and formatting aren't preserved. The create and update sections describe how omitted or `null` policies behave.

## Cache registry data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>uuid</code></th>
      <td>UUID of the cache registry. Use this value as the <code>{id}</code> path parameter for the get, update, and delete endpoints.</td>
    </tr>
    <tr>
      <th><code>slug</code></th>
      <td>Slug generated from the cache registry's name. Informational only, and not accepted as an identifier.</td>
    </tr>
    <tr>
      <th><code>name</code></th>
      <td>Name of the cache registry.</td>
    </tr>
    <tr>
      <th><code>description</code></th>
      <td>Description of the cache registry, or <code>null</code>.</td>
    </tr>
    <tr>
      <th><code>emoji</code></th>
      <td>Emoji for the cache registry using the <a href="/docs/pipelines/emojis">emoji syntax</a>, or <code>null</code>.</td>
    </tr>
    <tr>
      <th><code>color</code></th>
      <td>Color hex code for the cache registry, or <code>null</code>.</td>
    </tr>
    <tr>
      <th><code>policy</code></th>
      <td>Normalized <a href="/docs/pipelines/configure/cache#manage-cache-registries-configure-a-cache-policy">cache policy</a> that controls which jobs can save and restore entries in this registry, or <code>null</code>.</td>
    </tr>
    <tr>
      <th><code>created_at</code></th>
      <td>When the cache registry was created.</td>
    </tr>
    <tr>
      <th><code>updated_at</code></th>
      <td>When the cache registry was last updated.</td>
    </tr>
    <tr>
      <th><code>url</code></th>
      <td>Canonical API URL of the cache registry.</td>
    </tr>
    <tr>
      <th><code>cluster_url</code></th>
      <td>API URL of the parent cluster.</td>
    </tr>
  </tbody>
</table>

## List cache registries

Returns a paginated list of a cluster's cache registries, ordered by slug.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache-registries?per_page=30"
```

```json
{
  "items": [
    {
      "uuid": "b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
      "slug": "ruby-gems",
      "name": "Ruby gems",
      "description": "Shared Ruby dependencies",
      "emoji": "\:ruby\:",
      "color": "#cc342d",
      "policy": {
        "save": { "scopes": { "branch": true } },
        "restore": { "scopes": [{ "branch": "$current" }] },
        "rules": [
          { "effect": "allow", "action": ["save"] },
          { "effect": "allow", "action": ["restore"] }
        ]
      },
      "created_at": "2026-08-11T10:15:32.000Z",
      "updated_at": "2026-08-11T10:15:32.000Z",
      "url": "https://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/cache-registries/b3a1e9f2-7c4d-4f1a-9e6c-2d8a5f7b1c3d",
      "cluster_url": "https://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf"
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/cache-registries?per_page=30",
    "next": "https://api.buildkite.com/v2/organizations/acme-inc/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/cache-registries?after=...&per_page=30"
  }
}
```

This endpoint uses cursor-based pagination. The response body is a JSON object with an `items` array and a `links` object. Use the `next` URL from `links` to fetch the next page. Follow that URL instead of constructing cursor values.

Optional [query string parameters](/docs/api#query-string-parameters):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>per_page</code></th>
      <td>How many results to return per page.
        <p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p>
        <p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td>
    </tr>
    <tr>
      <th><code>after</code></th>
      <td>Return results after this cursor value. Mutually exclusive with <code>before</code>.</td>
    </tr>
    <tr>
      <th><code>before</code></th>
      <td>Return results before this cursor value. Mutually exclusive with <code>after</code>.</td>
    </tr>
  </tbody>
</table>

Required scope: `read_clusters`

Required permission: permission to manage the cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>400 Bad Request</code></th>
      <td>Invalid <code>per_page</code> or cursor value, or both <code>after</code> and <code>before</code> supplied</td>
    </tr>
    <tr>
      <th><code>404 Not Found</code></th>
      <td>The cluster doesn't exist</td>
    </tr>
  </tbody>
</table>

## Get a cache registry

Returns the details for a single cache registry, looked up by UUID.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache-registries/{id}"
```

The response contains the [cache registry data model](#cache-registry-data-model).

Required scope: `read_clusters`

Required permission: permission to manage the cluster

Success response: `200 OK`

Error response: `404 Not Found` when the cluster doesn't exist, or when no cache registry matches the given UUID in this cluster. Passing a slug instead of a UUID also returns `404 Not Found`.

## Create a cache registry

Creates a new cache registry in a cluster.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache-registries" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ruby gems",
    "description": "Shared Ruby dependencies",
    "emoji": "\:ruby\:",
    "color": "#cc342d",
    "policy": {
      "save": { "scopes": { "branch": true } },
      "restore": { "scopes": [{ "branch": "$current" }] },
      "rules": [
        { "effect": "allow", "action": "save" },
        { "effect": "allow", "action": "restore" }
      ]
    }
  }'
```

The response contains the created [cache registry data model](#cache-registry-data-model).

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>name</code></th>
      <td>Name of the cache registry.
        <p class="Docs__api-param-eg"><em>Example:</em> <code>"Ruby gems"</code></p></td>
    </tr>
  </tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>description</code></th>
      <td>Description of the cache registry.</td>
    </tr>
    <tr>
      <th><code>emoji</code></th>
      <td>Emoji for the cache registry using the <a href="/docs/pipelines/emojis">emoji syntax</a>.</td>
    </tr>
    <tr>
      <th><code>color</code></th>
      <td>Color hex code for the cache registry.</td>
    </tr>
    <tr>
      <th><code>policy</code></th>
      <td>Cache policy as a JSON object that controls which jobs can save and restore entries. See <a href="/docs/pipelines/configure/cache#manage-cache-registries-configure-a-cache-policy">Configure a cache policy</a> for the policy structure. Omit this property or set it to <code>null</code> when creating a registry to use the default unrestricted policy.</td>
    </tr>
  </tbody>
</table>

The cache store can't be set through this API. New cache registries use agent-managed storage.

Required scope: `write_clusters`

Required permission: permission to manage the cluster

Success response: `201 Created`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>400 Bad Request</code></th>
      <td>The request body isn't a valid JSON object</td>
    </tr>
    <tr>
      <th><code>404 Not Found</code></th>
      <td>The cluster doesn't exist</td>
    </tr>
    <tr>
      <th><code>415 Unsupported Media Type</code></th>
      <td>The request doesn't use an <code>application/json</code> content type</td>
    </tr>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td>The request is missing <code>name</code>, contains an unsupported field or invalid policy, or a cache registry with the resulting slug already exists in this cluster</td>
    </tr>
  </tbody>
</table>

## Update a cache registry

Updates a cache registry, looked up by UUID. Properties omitted from the request body are left unchanged. Supplying `policy` replaces the entire policy rather than merging its nested properties.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache-registries/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Ruby gems",
    "description": "Updated description",
    "policy": {
      "save": { "scopes": { "pipeline": true } },
      "restore": { "scopes": [{ "pipeline": "$current" }] },
      "rules": [
        { "effect": "allow", "action": "save" },
        { "effect": "allow", "action": "restore" }
      ]
    }
  }'
```

The response contains the updated [cache registry data model](#cache-registry-data-model).

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>name</code></th>
      <td>Name of the cache registry. Changing the name regenerates the registry's slug.</td>
    </tr>
    <tr>
      <th><code>description</code></th>
      <td>Description of the cache registry. Set to <code>null</code> to clear it.</td>
    </tr>
    <tr>
      <th><code>emoji</code></th>
      <td>Emoji for the cache registry using the <a href="/docs/pipelines/emojis">emoji syntax</a>. Set to <code>null</code> to clear it.</td>
    </tr>
    <tr>
      <th><code>color</code></th>
      <td>Color hex code for the cache registry. Set to <code>null</code> to clear it.</td>
    </tr>
    <tr>
      <th><code>policy</code></th>
      <td>Cache policy as a JSON object that controls which jobs can save and restore entries. See <a href="/docs/pipelines/configure/cache#manage-cache-registries-configure-a-cache-policy">Configure a cache policy</a> for the policy structure. Set to <code>null</code> to clear the policy, which denies saves and restores. Unlike creation, updating with <code>null</code> doesn't apply the default unrestricted policy.</td>
    </tr>
  </tbody>
</table>

The cache registry's `uuid` and cache store can't be changed through this API.

Required scope: `write_clusters`

Required permission: permission to manage the cluster

Success response: `200 OK`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>400 Bad Request</code></th>
      <td>The request body isn't a valid JSON object</td>
    </tr>
    <tr>
      <th><code>404 Not Found</code></th>
      <td>The cluster doesn't exist, or no cache registry matches the given UUID in this cluster</td>
    </tr>
    <tr>
      <th><code>415 Unsupported Media Type</code></th>
      <td>The request doesn't use an <code>application/json</code> content type</td>
    </tr>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td>The request contains an unsupported field, attempts to change the <code>uuid</code> or cache store, contains an invalid policy, or a cache registry with the resulting slug already exists in this cluster</td>
    </tr>
  </tbody>
</table>

## Delete a cache registry

Deletes a cache registry, looked up by UUID. A cluster's default cache registry can't be deleted. First, [open another registry in the web interface](/docs/pipelines/configure/cache#manage-cache-registries) and select **Settings** > **Set as default**.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/cache-registries/{id}"
```

Required scope: `write_clusters`

Required permission: permission to manage the cluster, and permission to destroy the cache registry

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>404 Not Found</code></th>
      <td>The cluster doesn't exist, or no cache registry matches the given UUID in this cluster</td>
    </tr>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td>The cache registry is the cluster's default registry</td>
    </tr>
  </tbody>
</table>
