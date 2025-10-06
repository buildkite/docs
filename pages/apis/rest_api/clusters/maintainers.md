# Cluster maintainers

Cluster maintainers permissions can be assigned to a list of [Users or teams](/docs/platform/team-management/permissions), or both. This grants assignees the ability to manage the [Buildkite clusters they maintain](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster).

## Cluster maintainer data model

<table class="responsive-table">
  <tbody>
    <tr><th><code>id</code></th><td>The ID of the cluster maintainer assignment.</td></tr>
    <tr><th><code>actor</code></th><td>Metadata on the assigned User or Team</td></tr>
  </tbody>
</table>

## List cluster maintainers

Returns a list of [maintainers](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) on a [cluster](/docs/pipelines/clusters).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers"
```

```json
[
	{
		"id": "f6cf1097-c9c5-4492-885f-a2d3281a07dd",
		"actor": {
			"id": "01973824-0c57-45ae-a440-638fceb3ec06",
			"graphql_id": "VXNlci0tLTAxOTczODI0LTBjNTctNDVhZS1hNDQwLTYzOGZjZWIzZWMwNg==",
			"name": "Staff",
			"email": "staff@example.com",
			"type": "user"
		}
	},
	{
		"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
		"actor": {
			"id": "0da645b7-9840-428f-bd80-0b92ee274480",
			"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
			"slug": "Developers",
			"type": "team"
		}
	}
]
```

Required scope: `read_clusters`

Success response: `200 OK`

## Get a cluster maintainer

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers/{id}"
```

```json
{
	"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
	"actor": {
		"id": "0da645b7-9840-428f-bd80-0b92ee274480",
		"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
		"slug": "Developers",
		"type": "team"
	}
}
```

Required scope: `read_clusters`

Success response: `200 OK`

## Create a cluster maintainer

Assigns [cluster maintainer](/docs/pipelines/clusters/manage-clusters#manage-maintainers-on-a-cluster) permissions to a [user or team](/docs/platform/team-management/permissions).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/maintainers" \
  -H "Content-Type: application/json" \
  -d '{ "team": "0da645b7-9840-428f-bd80-0b92ee274480" }'
```

```json
{
	"id": "282a043f-4d4f-4db5-ac9a-58673ae02caf",
	"actor": {
		"id": "0da645b7-9840-428f-bd80-0b92ee274480",
		"graphql_id": "VGVhbS0tLTBkYTY0NWI3LTk4NDAtNDI4Zi1iZDgwLTBiOTJlZTI3NDQ4MA==",
		"slug": "Developers",
		"type": "team"
	}
}
```

### Cluster maintainer permission target

Cluster maintainer permissions can be targeted to either a [user or team](/docs/platform/team-management/permissions) by specifying either a `user` or `team` field as the target in the request body, along with the target's UUID for its value.

<table class="responsive-table">
  <thead>
    <th>Target</th>
    <th>Value</th>
    <th>Example request body</th>
  </thead>
  <tbody>
    <tr>
      <td><code>user</code></td>
      <td>UUID of the user</td>
      <td><code>{ "user: "282a043f-4d4f-4db5-ac9a-58673ae02caf" }</code></td>
    </tr>
    <tr>
      <td><code>team</code></td>
      <td>UUID of the team</th>
      <td><code>{ "team: "0da645b7-9840-428f-bd80-0b92ee274480" }</code></td>
    </tr>
  </tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td><code>{ "message": "Validation failed: Reason for failure" }</code></td>
    </tr>
  </tbody>
</table>

## Remove a cluster maintainer

Remove cluster maintainer permissions from a [user or team](/docs/platform/team-management/permissions).

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td><code>{ "message": "Validation failed: Reason cluster maintainer permission could not be deleted" }</code></td>
    </tr>
  </tbody>
</table>
