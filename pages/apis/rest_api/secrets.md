# Secrets

[Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) is an encrypted key-value store secrets management service. Secrets are scoped within a [cluster](/docs/pipelines/clusters) and can be accessed by agents within that cluster using the [`buildkite-agent secret get` command](/docs/agent/v3/cli-secret) or by defining `secrets` within a pipeline YAML configuration. Access to secrets is controlled through [access policies](/docs/pipelines/security/secrets/buildkite-secrets/access-policies).

## Secret data model

<table>
<tbody>
  <tr><th><code>id</code></th><td>ID of the secret</td></tr>
  <tr><th><code>graphql_id</code></th><td>GraphQL ID of the secret</td></tr>
  <tr><th><code>key</code></th><td>A unique identifier for the secret</td></tr>
  <tr><th><code>value</code></th><td>The encrypted secret value. This field is never returned by the API</td></tr>
  <tr><th><code>description</code></th><td>Description of the secret</td></tr>
  <tr><th><code>policy</code></th><td>YAML policy defining access rules for the secret</td></tr>
  <tr><th><code>url</code></th><td>Canonical API URL of the secret</td></tr>
  <tr><th><code>cluster_url</code></th><td>API URL of the cluster this secret belongs to</td></tr>
  <tr><th><code>created_at</code></th><td>When the secret was created</td></tr>
  <tr><th><code>created_by</code></th><td>User who created the secret</td></tr>
  <tr><th><code>updated_at</code></th><td>When the secret was last updated</td></tr>
  <tr><th><code>updated_by</code></th><td>User who last updated the secret</td></tr>
  <tr><th><code>last_read_at</code></th><td>When the secret was last accessed by a build</td></tr>
  <tr><th><code>organization</code></th><td>Organization this secret belongs to</td></tr>
</tbody>
</table>

## List secrets

Returns a [paginated list](<%= paginated_resource_docs_url %>) of a cluster's secrets.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets"
```

```json
[
  {
    "id": "9bf7650d-52ba-40e6-a18e-7a34a109f8bc",
    "key": "MY_SECRET",
    "description": "My secret description",
    "policy": "- pipeline_slug: my-pipeline\n  build_branch: main",
    "created_at": "2025-10-01T06:51:21.067Z",
    "created_by": {
      "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
      "name": "Staff",
      "email": "test+staff@example.com"
    },
    "updated_at": "2025-10-01T06:51:21.173Z",
    "updated_by": null,
    "last_read_at": null,
    "url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/9bf7650d-52ba-40e6-a18e-7a34a109f8bc",
    "cluster_url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}",
    "organization": {
      "id": "0198e45b-c0d5-4a0b-8e37-e140af750d2d",
      "slug": "my-org",
      "url": "http://api.buildkite.com/v2/organizations/my-org",
      "web_url": "http://buildkite.com/my-org"
    }
  }
]
```

Required scope: `read_secret_details`

Success response: `200 OK`

## Get a secret

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/{id}"
```

```json
{
  "id": "9bf7650d-52ba-40e6-a18e-7a34a109f8bc",
  "key": "MY_SECRET",
  "description": "My secret description",
  "policy": "- pipeline_slug: my-pipeline\n  build_branch: main",
  "created_at": "2025-10-01T06:51:21.067Z",
  "created_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "updated_at": "2025-10-01T06:51:21.173Z",
  "updated_by": null,
  "last_read_at": null,
  "url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/9bf7650d-52ba-40e6-a18e-7a34a109f8bc",
  "cluster_url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}",
  "organization": {
    "id": "0198e45b-c0d5-4a0b-8e37-e140af750d2d",
    "slug": "my-org",
    "url": "http://api.buildkite.com/v2/organizations/my-org",
    "web_url": "http://buildkite.com/my-org"
  }
}
```

Required scope: `read_secret_details`

Success response: `200 OK`

## Create a secret

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "MY_SECRET",
    "value": "secret-value",
    "description": "My secret description",
    "policy": "- pipeline_slug: my-pipeline\n  build_branch: main"
  }'
```

```json
{
  "id": "30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "key": "MY_SECRET",
  "description": "My secret description",
  "policy": "- pipeline_slug: my-pipeline\n  build_branch: main",
  "created_at": "2025-10-01T07:43:38.648Z",
  "created_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "updated_at": "2025-10-01T07:43:38.708Z",
  "updated_by": null,
  "last_read_at": null,
  "url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "cluster_url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}",
  "organization": {
    "id": "0198e45b-c0d5-4a0b-8e37-e140af750d2d",
    "slug": "my-org",
    "url": "http://api.buildkite.com/v2/organizations/my-org",
    "web_url": "http://buildkite.com/my-org"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>key</code></th><td>A unique identifier for the secret. Must start with a letter and only contain letters, numbers, and underscores. Cannot start with <code>buildkite</code> or <code>bk</code> (case insensitive). Maximum length is 255 characters. Must be unique within the cluster<br><em>Example:</em> <code>"MY_SECRET"</code></td></tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>value</code></th><td>The secret value to encrypt and store. Must be less than 8 kilobytes<br><em>Example:</em> <code>"secret-value"</code></td></tr>
  <tr><th><code>description</code></th><td>A description of the secret<br><em>Example:</em> <code>"My secret description"</code></td></tr>
  <tr><th><code>policy</code></th><td>YAML policy defining access rules. See <a href="/docs/pipelines/security/secrets/buildkite-secrets/access-policies">Access policies for Buildkite secrets</a> for details on policy structure and available claims<br><em>Example:</em> <code>"- pipeline_slug: my-pipeline\n  build_branch: main"</code></td></tr>
</tbody>
</table>

Required scope: `write_secrets`

Success response: `201 Created`

## Update secret details (description and access policy)

Updates the secret's details. To update the secret value, use the [update secret value](#update-secret-value) endpoint.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/{id}" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated description",
    "policy": "- pipeline_slug: my-pipeline\n  build_branch: production"
  }'
```

```json
{
  "id": "30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "key": "MY_SECRET",
  "description": "Updated description",
  "policy": "- pipeline_slug: my-pipeline\n  build_branch: production",
  "created_at": "2025-10-01T07:43:38.648Z",
  "created_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "updated_at": "2025-10-01T07:43:46.949Z",
  "updated_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "last_read_at": null,
  "url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "cluster_url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}",
  "organization": {
    "id": "0198e45b-c0d5-4a0b-8e37-e140af750d2d",
    "slug": "my-org",
    "url": "http://api.buildkite.com/v2/organizations/my-org",
    "web_url": "http://buildkite.com/my-org"
  }
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>description</code></th><td>A description of the secret<br><em>Example:</em> <code>"Updated description"</code></td></tr>
  <tr><th><code>policy</code></th><td>YAML policy defining access rules. See <a href="/docs/pipelines/security/secrets/buildkite-secrets/access-policies">Access policies for Buildkite secrets</a> for details on policy structure and available claims<br><em>Example:</em> <code>"- pipeline_slug: my-pipeline\n  build_branch: production"</code></td></tr>
</tbody>
</table>

Required scope: `write_secrets`

Success response: `200 OK`

Error response: `422 Unprocessable Entity`

<table>
<tbody>
  <tr><th><code>key</code></th><td>Attempting to update the <code>key</code> parameter returns an error: <code>"The key parameter cannot be updated."</code></td></tr>
  <tr><th><code>value</code></th><td>Attempting to update the <code>value</code> parameter returns an error: <code>"The value parameter cannot be updated on this endpoint."</code></td></tr>
</tbody>
</table>

## Update secret value

Updates only the secret's encrypted value. To update other details, use the [update secret](#update-a-secret) endpoint.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/{id}/value" \
  -H "Content-Type: application/json" \
  -d '{"value": "new-secret-value"}'
```

```json
{
  "id": "30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "key": "MY_SECRET",
  "description": "Updated description",
  "policy": "- pipeline_slug: my-pipeline\n  build_branch: production",
  "created_at": "2025-10-01T07:43:38.648Z",
  "created_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "updated_at": "2025-10-01T07:44:09.081Z",
  "updated_by": {
    "id": "01987d6e-44a6-415c-85d1-c247c938e8d5",
    "name": "Staff",
    "email": "test+staff@example.com"
  },
  "last_read_at": null,
  "url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/30f93dd5-bc23-4a14-8ad3-fd1920ea8eb5",
  "cluster_url": "http://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}",
  "organization": {
    "id": "0198e45b-c0d5-4a0b-8e37-e140af750d2d",
    "slug": "my-org",
    "url": "http://api.buildkite.com/v2/organizations/my-org",
    "web_url": "http://buildkite.com/my-org"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table>
<tbody>
  <tr><th><code>value</code></th><td>The new secret value to encrypt and store. Must be less than 8 kilobytes<br><em>Example:</em> <code>"new-secret-value"</code></td></tr>
</tbody>
</table>

Required scope: `write_secrets`

Success response: `200 OK`

## Delete a secret

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/secrets/{id}"
```

Required scope: `write_secrets`

Success response: `204 No Content`
