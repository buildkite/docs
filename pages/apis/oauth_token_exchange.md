# OAuth token exchange

> 📘 Public preview feature
> OAuth Token Exchange is currently in public preview and is not yet generally available.

[OAuth Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693) lets you mint short-lived [Buildkite API access tokens](/docs/apis/managing-api-tokens) associated with a user in your organization programmatically, without interactive login flows. Your application signs a JWT assertion with its private key, exchanges it at the token endpoint for a scoped API token, and uses that token to call the Buildkite [REST](/docs/apis/rest-api) or [GraphQL](/docs/apis/graphql-api) API on behalf of a user.

OAuth Token Exchange is ideal for security-conscious workflows where a central service mints tokens on behalf of users, avoiding long-lived tokens stored on individual machines. Common use cases include:

- **Centralized token authority:** A single service issues short-lived tokens from a restricted IP range, reducing the attack surface compared to distributing long-lived API tokens across machines.
- **Non-interactive automation:** Server-side integrations, CI/CD orchestration, and automated tooling that need to act as a Buildkite user without interactive login flows.
- **Least-privilege access:** Each token is scoped to only the [permissions](/docs/apis/managing-api-tokens#token-scopes) required and expires automatically, limiting the potential blast radius of a compromised credential.

## How it works

```
┌────────────┐    1. JWT assertion    ┌──────────────┐
│            │ ─────────────────────▶ │              │
│  Your app  │                        │ Buildkite    │
│            │ ◀───────────────────── │ /oauth/token │
│            │    2. bktx_ token      │              │
│            │                        └──────────────┘
│            │    3. Bearer bktx_...  ┌──────────────┐
│            │ ─────────────────────▶ │ Buildkite    │
│            │ ◀───────────────────── │ REST/GraphQL │
└────────────┘    4. API response     └──────────────┘
```

1. **Sign** a JWT assertion ([RFC 7523](https://datatracker.ietf.org/doc/html/rfc7523)) with your RSA or ECDSA private key.
2. **Exchange** the assertion at `POST /oauth/token` for a short-lived Buildkite API token (prefixed `bktx_`).
3. **Call** the Buildkite REST or GraphQL API with the token in the `Authorization: Bearer` header.
4. **Cache** the token in memory and refresh it before expiry. Do not exchange a new token for every request to prevent exhaustion of your token request rate-limits.

## Setup

To use OAuth Token Exchange, you need:

1. A Token Exchange application configured on the Buildkite's side. Provide the following details for configuration:

- **Name:** A display name for the application.
- **Description:** A description of the application.
- **JWKS:** Your application's public key in [JWKS](https://datatracker.ietf.org/doc/html/rfc7517) format, provided as inline JSON or an `https://` URI (see [Provide your public key as a JWKS](#setup-provide-your-public-key-as-a-jwks)).
- **Grantable scopes:** The [scopes](/docs/apis/managing-api-tokens#token-scopes) that can be set on minted access tokens.
- **Default scopes:** The [scopes](/docs/apis/managing-api-tokens#token-scopes) set on minted access tokens when a token exchange request omits the `scope` parameter.
- **Allowed IP addresses** (optional, **recommended**): Restrict token usage to specific IP addresses.
- **Maximum token TTL** (optional): The maximum token lifetime in seconds. Defaults to 3600 (one hour).

After configuration, you will be provided with a **client ID** for your application.

### Generate a key pair

Generate an RSA or ECDSA key pair. The **private key** stays with your application. The **public key** is registered with Buildkite as a JWKS.

**RSA (2048-bit):**

```bash
openssl genrsa -out private_key.pem 2048
openssl rsa -in private_key.pem -pubout -out public_key.pem
```

**ECDSA (P-256):**

```bash
openssl ecparam -name prime256v1 -genkey -noout -out private_key.pem
openssl ec -in private_key.pem -pubout -out public_key.pem
```

### Provide your public key as a JWKS

Buildkite requires your public key in [JWKS](https://datatracker.ietf.org/doc/html/rfc7517) format — a JSON object containing a `keys` array with one or more JWK entries. You can provide it as inline JSON or as an `https://` URI that serves the JWKS.

If your identity provider publishes a JWKS endpoint, use that directly. If you have a PEM-encoded public key, convert it to JWKS using a standards-compliant library in your language.

> 📘
> Every key in your JWKS must include a `kid` (Key ID). Setting the matching `kid` in your JWT header allows Buildkite to look up the correct key directly. If your JWT omits `kid`, Buildkite tries all keys in the JWKS to verify the signature.

**RSA key example:**

```json
{
  "keys": [
    {
      "kty": "RSA",
      "kid": "my-key-1",
      "use": "sig",
      "alg": "RS256",
      "n": "<base64url-encoded modulus>",
      "e": "AQAB"
    }
  ]
}
```

**EC key example:**

```json
{
  "keys": [
    {
      "kty": "EC",
      "kid": "my-key-1",
      "use": "sig",
      "alg": "ES256",
      "crv": "P-256",
      "x": "<base64url-encoded x coordinate>",
      "y": "<base64url-encoded y coordinate>"
    }
  ]
}
```

All key component values (`n`, `e`, `x`, `y`) must be [base64url](https://datatracker.ietf.org/doc/html/rfc7515#appendix-C)-encoded.

> 📘
> If you provide your JWKS using an HTTPS URI, Buildkite caches it for up to 1 hour. During key rotation, publish both old and new keys together for at least the cache duration.

<!-- vale Buildkite.existence = NO -->

## Token exchange request

Exchange a signed JWT assertion for a Buildkite API token by sending a `POST` request to the token endpoint:

Endpoint: `POST https://buildkite.com/oauth/token`

```
POST /oauth/token HTTP/1.1
Host: buildkite.com
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:token-exchange
&client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer
&client_assertion=eyJhbGciOi...
&subject_token=user@example.com
&subject_token_type=urn\:buildkite\:params:oauth:token-type:user-email
&audience=your-org-slug
&scope=read_pipelines read_builds
```

### Request parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `urn:ietf:params:oauth:grant-type:token-exchange` |
| `client_assertion_type` | Yes | Must be `urn:ietf:params:oauth:client-assertion-type:jwt-bearer` |
| `client_assertion` | Yes | A signed JWT assertion (see [JWT assertion claims](#jwt-assertion-claims)) |
| `subject_token` | Yes | The email address of the Buildkite user to act as |
| `subject_token_type` | Yes | Must be `urn\:buildkite\:params:oauth:token-type:user-email` |
| `audience` | Yes | The Buildkite organization slug (from the URL, not the display name) |
| `scope` | No | Space-delimited list of [scopes](/docs/apis/managing-api-tokens#token-scopes). If omitted, the app's default scopes are used. If the app has no default scopes, omitting this parameter returns an error. |
| `expires_in` | No | Requested token TTL in seconds. Capped by the app's maximum TTL. Defaults to the app's maximum TTL if omitted. |

The subject user must be an active member of the target organization with a verified email address.

> 📘
> The request `audience` parameter and the JWT `aud` claim are different values:
> - `audience` (form parameter) is the Buildkite **organization slug** (for example, `my-org`)
> - `aud` (JWT claim) is the **token endpoint URL** (`https://buildkite.com/oauth/token`)

### Response

A successful response returns a JSON object:

```json
{
  "access_token": "bktx_...",
  "issued_token_type": "urn:ietf:params:oauth:token-type:access_token",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "read_pipelines read_builds"
}
```

| Field | Description |
|-------|-------------|
| `access_token` | The minted API token, prefixed with `bktx_` |
| `issued_token_type` | Always `urn:ietf:params:oauth:token-type:access_token` |
| `token_type` | Always `Bearer` |
| `expires_in` | Token lifetime in seconds |
| `scope` | The scopes granted to the token |

Use the `access_token` value in the `Authorization` header for API requests:

```
Authorization: Bearer bktx_...
```

## JWT assertion claims

The `client_assertion` is a JWT ([RFC 7523](https://datatracker.ietf.org/doc/html/rfc7523)) signed with your application's private key. It must contain these claims:

| Claim | Value |
|-------|-------|
| `iss` | Your application's client ID |
| `sub` | Your application's client ID (must match `iss`) |
| `aud` | The token endpoint URL (`https://buildkite.com/oauth/token`) |
| `iat` | Issued-at timestamp (Unix epoch seconds) |
| `exp` | Expiration timestamp — must be within 5 minutes of `iat` |

**Optional claims:**

| Claim | Value |
|-------|-------|
| `jti` | A unique identifier for the JWT ([RFC 7519 §4.1.7](https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.7)). If present, must be a non-empty string of at most 255 bytes. A UUID is a common format. After a successful token exchange, Buildkite rejects later requests that reuse the same `jti`. By default, JWTs without a `jti` are accepted. |
| `nbf` | Not-before timestamp. If set, must not be in the future. |

**Supported signing algorithms:** RS256 (RSA) and ES256 (ECDSA P-256).

### Example JWT header

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "my-key-1"
}
```

### Example JWT payload

```json
{
  "iss": "0123456789abcdef0123",
  "sub": "0123456789abcdef0123",
  "aud": "https://buildkite.com/oauth/token",
  "iat": 1710849600,
  "exp": 1710849900,
  "jti": "550e8400-e29b-41d4-a716-446655440000"
}
```

## Available scopes

Token exchange tokens support the same scopes as [Buildkite API access tokens](/docs/apis/managing-api-tokens#token-scopes). The scopes granted to a token are limited to the application's configured **grantable scopes**.

## Best practices

Follow these recommendations to keep your OAuth Token Exchange integration secure and reliable.

### Cache and reuse tokens

Do **not** exchange a new token for every API request. This creates unnecessary load on the authentication infrastructure.

Instead, cache the token in memory and reuse it across requests. When the token is close to expiry, refresh it by performing another exchange.

### Thread safety

If your application makes concurrent API calls, ensure your token cache is protected with a mutex or equivalent synchronization primitive.

### Minimize scopes

Request only the [scopes](/docs/apis/managing-api-tokens#token-scopes) your application needs. Use the `scope` parameter to request a subset of the app's grantable scopes, rather than relying on the app's full default scopes.

### Include a JTI claim

Include a unique `jti` (JWT ID) claim in each assertion to reduce replay risk. Use a UUID or another unique value for each request. After a successful token exchange, Buildkite rejects later requests that reuse the same `jti`.

### Use short TTLs

Prefer shorter token lifetimes to limit the blast radius if a token is compromised. The `expires_in` parameter lets you request a TTL shorter than the app's maximum.

## Example client

The [buildkite-token-exchange-example](https://github.com/buildkite/buildkite-token-exchange-example) repository contains a complete Go client that demonstrates the full token exchange flow, including JWT signing, token caching, and API calls.

## Troubleshooting

The token endpoint returns [RFC 6749 §5.2](https://datatracker.ietf.org/doc/html/rfc6749#section-5.2) error responses with an `error` code and optional `error_description`:

```json
{
  "error": "invalid_client",
  "error_description": "Invalid client assertion signature"
}
```

### Common errors

| `error` | `error_description` | Fix |
|---------|---------------------|-----|
| `invalid_client` | "Invalid client assertion signature" | Check that the public key in your JWKS matches the private key used to sign the JWT |
| `invalid_client` | "JWT `aud` claim is invalid" | Set the JWT `aud` claim to `https://buildkite.com/oauth/token` |
| `invalid_client` | "JWT `exp` claim must be in the future" | Check your system clock for skew |
| `invalid_client` | "JWT has already been used (jti)" | The `jti` has already been consumed. Generate a new unique `jti` for each request |
| `invalid_client` | "JWT must contain a \`jti\` claim" | Your organization requires a `jti` claim. Add a unique `jti` (for example, a UUID) to your JWT payload |
| `invalid_request` | "Subject user must be an active member of the organization" | Verify the email address belongs to a member of the target organization |
| `invalid_scope` | "Requested scopes exceed grantable scopes" | Only request scopes that are in the app's configured grantable scopes |
| `invalid_target` | "Invalid audience organization" | Use the organization slug from the URL, not the display name |
| `unsupported_grant_type` | "Token exchange is not enabled for this organization" | The organization must be enrolled in the public preview |

<!-- vale Buildkite.existence = YES -->
