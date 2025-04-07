# Ephemeral portal tokens

When a portal is created in Buildkite, it is assigned a long-lived, admin-level portal token. However, in scenarios where security is a priority, it's advisable to utilize ephemeral portal tokens. These tokens enhance security by being valid only for a short duration.

These ephemeral portal tokens have the same admin-level permissions as the long-lived portal token, providing a secure alternative to manage portal without the long-lived token.

### Generating a secret

Before obtaining an ephemeral portal token, an organization admin must generate a portal secret via the Buildkite UI. This secret is essential for requesting ephemeral portal tokens. Each portal can have up to two secrets, enabling safe rotation practices.

To generate a portal secret:

1. Navigate to the portal's page in the Buildkite UI.

2. Click on the **Security** tab.

3. Click on the **New Secret** button to generate a new secret.

### Requesting an ephemeral portal token

With the portal secret generated, users can request an ephemeral portal token by making a POST request to the portal's token endpoint. This request should include the following parameters:

- `grant_type`: must be set to `client_credentials`.

- `client_id`: The Portal's UUID, which is available on the portal's page.

- `secret`: The previously generated portal secret.

An example curl command for this request is:

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "client_credentials", "client_id": "$CLIENT_ID", "secret": "$SECRET" }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

The response will contain the ephemeral portal token and its expiration timestamp:

```bash
{
  "token": "bkpt_************************",
  "expires_at": "2025-03-12T12:16:44Z"
}
```

### Token validity and custom expiration
By default, ephemeral portal tokens are valid for up to an hour. Optionally, users can request tokens with a shorter duration by specifying the `expires_in` parameter (in minutes) in the token request:

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "client_credentials", "client_id": "$CLIENT_ID", "secret": "$SECRET", "expires_in": $MINUTES }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

### Authentication using the ephemeral token
Once obtained, the ephemeral portal token can be used to authenticate portal APIs by including it in the Authorization header as a Bearer token:

```bash
curl -H "Authorization: Bearer $EPHEMERAL_PORTAL_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}"
```
