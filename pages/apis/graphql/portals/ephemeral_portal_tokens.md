# Ephemeral portal tokens

When a Buildkite portal is created, it is assigned a long-lived, [admin-level portal token](/docs/apis/graphql/portals#getting-started). However, in scenarios where security is a priority, it's advisable to utilize _ephemeral portal tokens_. These tokens enhance security, since they are only valid for a short duration.

Since ephemeral portal tokens have the same admin-level permissions as long-lived admin-level portal tokens, ephemeral portal tokens provide a secure alternative to managing portals.

## Generating a secret

Before obtaining an ephemeral portal token, a Buildkite organization administrator must generate a _portal secret_ via the Buildkite interface. This secret is essential for requesting ephemeral portal tokens. Each portal can have up to two secrets, enabling safe rotation practices.

To generate a portal secret for an [existing portal](/docs/apis/graphql/portals#getting-started):

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Integrations > Portals** to access your organization's [**Portals**](https://buildkite.com/organizations/~/portals) page.

1. Select the portal for which a portal secret will be generated, followed by the portal's **Security** tab.

1. Select the **New Secret** button to generate a new secret.

1. Save this portal secret to somewhere secure, as you won't be able to access its value again through the Buildkite interface.

## Requesting an ephemeral portal token

With the portal secret generated, users can request an ephemeral portal token by making a POST request to the portal's token endpoint. This request should include the following parameters:

- `grant_type`: must be set to `client_credentials`.

- `client_id`: The Portal's UUID, which is available on the portal's page.

- `secret`: The previously generated portal secret.

An example `curl` command for this request is:

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "client_credentials", "client_id": "$CLIENT_ID", "secret": "$SECRET" }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

The response will contain the ephemeral portal token and its expiration timestamp:

```bash
{
  "token": "bkpat_************************",
  "expires_at": "2025-10-12T12:16:44Z"
}
```

## Token validity and custom expiration

By default, ephemeral portal tokens are valid for up to an hour. Optionally, users can request tokens with a shorter duration by specifying the `expires_in` parameter (in minutes) in the token request:

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "client_credentials", "client_id": "$CLIENT_ID", "secret": "$SECRET", "expires_in": $MINUTES }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

## Authentication using the ephemeral token

Once obtained, the ephemeral portal token can be used to authenticate portal APIs by including it in the authorization header as a bearer token:

```bash
curl -H "Authorization: Bearer $EPHEMERAL_PORTAL_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}"
```
