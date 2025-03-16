# User invoked Portal

User invoked Portal allows organization users to execute GraphQL operations from a portal and ensure operations run under their own permissions and identity. This approach is suitable when the acting principal of an operation must be explicitly identified, or when user-specific permissions must be enforced.

User invoked Portal allow users to authorize and generate short-lived tokens, providing a secure mechanism to execute API actions without requiring API tokens to be stored on a developer's machine.

## Short-lived Portal token

To use User invoked Portal, organization admins must explicitly configure portals to be user-invokable. This provides admins control over which portals allow user-invoked operations while restricting other from being user-invokable.

Once a portal is marked as user-invokable, users can request a token code, authorize it, and retrieve a token for executing portal operations.

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
Token codes expire after 5 minutes. Users must authorize the code and generate a token before expiration.

### Authorizing using web interface

To complete authorization, users must navigate to the provided authorization URL and approve the token code. Once authorized, the user may close the browser tab.

Requirements:

- The user must be authenticated.
- The user must be a member of the organization.

### Generating a Portal token

Once the token code is authorized, users can obtain a portal token by making a `POST` request to the portal’s token endpoint, including the code and secret from the previous step:

```bash
curl -H "Content-Type: application/json" \
  -d "{ "code": "$CODE", "secret": "$SECRET" }" \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```
The response contains the generated token and its expiration timestamp:

```json
{
  "token": "bkpt_************************",
  "expires_at": "2025-03-12T12:16:44Z"
}
```

Token Usage and Expiry:

- Each token code can generate only a single token.
- Portal tokens are valid for 12 hours by default.
- Users can request token for a shorter duration if needed.
- The generated token can be used to execute operations in portal that was authorized by the user.

### Custom expiry duration

Optionally, expiry duration can be specified (in minutes) if a shorter expiry is needed:

```bash
curl -H "Content-Type: application/json" \
  -d "{ "code": "$CODE", "secret": "$SECRET", "expires_in": $MINUTES }" \
  -X POST "https://portal.buildkite.com/organizations/{org.slug}/portals/{portal.slug}/tokens"
```

By leveraging User invoked Portals, organizations can provide a flexible and secure mechanism for user scoped GraphQL operations while maintaining strict access control.
