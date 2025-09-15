# Cluster maintainers API

The cluster maintainers API endpoint enables manage maintainer permissions for a cluster.
Cluster maintainer permissions can assigned to either a `User` or `Team`.

## Cluster maintainer data model

## List cluster maintainers

Returns a list of maintainers for a cluster.

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

### Get a cluster maintainer

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

### Create a cluster maintainer

Assign cluster maintainer permissions to a `User` or `Team`.

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

#### Cluster maintainer permission scopes

Cluster maintainer permissions can be scoped to to either a `User` or `Team` by specifying the request body in the following format.

<table class="responsive-table">
  <thead>
    <th>Scope</th>
    <th>Value</th>
    <th>Example request body</th>
  </thead>
  <tbody>
    <tr>
      <td><code>User</code></td>
      <td>UUID of the user</td>
      <td><code>{ "user: "282a043f-4d4f-4db5-ac9a-58673ae02caf" }</code></td>
    </tr>
    <tr>
      <td><code>Team</code></td>
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

### Delete a cluster maintainer

Delete cluster maintainer permissions for a `User` or `Team`.

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
