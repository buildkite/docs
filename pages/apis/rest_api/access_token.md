# Access token API

The access token API endpoint allows you to inspect and revoke an API access token. This can be useful if you find a token, can't identify its owner, and you want to revoke it.

> 📘
> All the endpoints expect the token to be provided using the <a href="/docs/apis/rest-api#authentication">Authorization HTTP header</a>.


## Get the current token

Returns details about the API access token that was used to authenticate the request.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/access-token"
```

```json
{
  "scopes": ["read_build"],
  "uuid": "b63254c0-3271-4a98-8270-7cfbd6c2f14e"
}
```

Required scope: none

Success response: `200 OK`

## Revoke the current token

Revokes the API access token that was used to authenticate the request. Once revoked, the token can no longer be used for further requests.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/access-token"
```

Required scope: none

Success response: `204 No Content`
