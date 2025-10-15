# User-invoked portals

User-invoked portals allow users within a Buildkite organization (also known as _Buildkite organization members_) to:

- Execute GraphQL operations from a portal, and ensures that such operations are run under their own permissions and identity. This approach is suitable when the user conducting such portal operations need to be identified, or when user-specific permissions for such operations must be enforced.

- Authorize and generate short-lived tokens, providing a secure mechanism to execute API actions through these portals, without requiring API tokens to be stored on a developer's machine.

## Short-lived portal token

To use a user-invoked portal, Buildkite organization administrators must explicitly configure portals to be _user-invokable_. This provides these administrators control over which portals allow user-invoked operations while restricting other from being user-invokable.

Once a portal is marked as user-invokable, users can request a _token code_ and authorize it to retrieve a _user-specific portal token_ for executing portal operations.

Unlike [admin-level portal tokens](/docs/apis/graphql/portals#getting-started), these types of _portal tokens_ are referred to as _user-specific_ ones, since they only grant privileges to what this user has access to within the Buildkite organization.

### Generating token codes

Users can generate a token code by making a `POST` request to the portal's code endpoint:

```bash
curl -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/codes"
```

```json
{
  "code": "{code}",
  "secret": "{secret}",
  "authorization_url": "{authorization_url}",
  "expires_at": "2025-03-12T08:21:22Z"
}
```

Token codes expire after 5 minutes. Users must authorize the token code before it expires, to generate a portal token.

### Authorizing using web interface

To complete authorization, users must navigate to the authorization URL (provided by the `authorization_url` value when [generating token codes](#short-lived-portal-token-generating-token-codes)) and approve the token codes in the request. Once authorized, the user may close the browser tab.

For this authorization process to succeed, the user must be both:

- a member of the Buildkite organization
- authenticated to Buildkite

### Generating a portal token

Once the token codes are authorized, users can obtain a portal token by making a `POST` request to the portal's token endpoint. The request body must contain `grant_type` as `device_code` along with the `code` and `secret` obtained from [generating token codes](#short-lived-portal-token-generating-token-codes):

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "device_code", "code": "$CODE", "secret": "$SECRET" }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

The response contains the generated user-specific portal token and its expiration timestamp:

```json
{
  "token": "bkpat_************************",
  "expires_at": "2025-10-12T12:16:44Z"
}
```

Token usage and expiration:

- Each set of token codes can generate only a single user-specific portal token.
- Portal tokens are valid for 12 hours by default.
- Users can request their own portal tokens with a shorter duration if needed.
- The portal token generated can be used to execute operations with the portal that was authorized by the user.

### Custom expiration duration

Optionally, expiration duration can be specified (in minutes) if a shorter expiration is needed:

```bash
curl -H "Content-Type: application/json" \
  -d '{ "grant_type": "device_code", "code": "$CODE", "secret": "$SECRET", "expires_in": $MINUTES }' \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

By leveraging user-invoked portals, administrators of Buildkite organizations can provide a flexible and secure mechanism for user-scoped GraphQL operations while maintaining strict access control.
