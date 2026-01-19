# Organization members API

This endpoint manages members of an [organization](/docs/apis/rest-api/organizations).

The organization members API endpoint allows users to view all members of a Buildkite organization.

## Organization member data model

<table class="responsive-table">
<tbody>
  <tr><th><code>id</code></th><td>UUID of the user</td></tr>
  <tr><th><code>name</code></th><td>Name of the user</tr>
  <tr><th><code>email</code></th><td>Email of the user</td></tr>
</tbody>
</table>

## List organization members

Returns a list of an organization's members.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/members"
```

```json
[
	{
		"id": "0185c636-fcbf-4a6c-b49d-c4048e7b8aea",
		"name": "Scout Finch",
		"email": "scout@example.com"
	},
	{
		"id": "0185dbbf-8447-4f72-ac7e-4ea3c2ec8381",
		"name": "Huck Finn",
		"email": "huck@example.com"
	}
]
```

Required scope: `read_organizations`

Success response: `200 OK`

## Get an organization member

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/members/{user.uuid}"
```

```json
{
  "id": "0185dbbf-8447-4f72-ac7e-4ea3c2ec8381",
  "name": "Victor Frankenstein",
  "email": "vic@example.com"
}
```

Required scope: `read_organizations`

Success response: `200 OK`
