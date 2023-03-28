# `buildkite-agent oidc request-token`

The Buildkite Agent's `oidc request-token` command allows you to request an OIDC token representing the current job. These tokens can be exchanged with federated systems like AWS.

See the [OpenID Connect Core documentation](https://openid.net/specs/openid-connect-core-1_0.html#IDToken) for more information about how OIDC tokens are constructed and how to extract and use claims.


<%= render "agent/v3/help/oidc_request_token" %>

## OIDC endpoints
* OpenID Connect Discovery URL: https://agent.buildkite.com/.well-known/openid-configuration
* JWKS URI: https://agent.buildkite.com/.well-known/jwks

## Example token contents

OIDC tokens are JSON Web Tokens — [JWTs](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-json-web-token) — and contain several claims like the following:

```json
{
  "iss": "https://agent.buildkite.com",
  "sub": "organization:acme-inc:pipeline:super-duper-app:ref:refs/heads/main:commit:9f3182061f1e2cca4702c368cbc039b7dc9d4485:step:build",
  "aud": "https://buildkite.com/acme-inc",
  "kid": "sup3rs3cr3tk3y",
  "iat": 1669014898,
  "nbf": 1669014898,
  "exp": 1669015198,
  "organization_slug": "acme-inc",
  "pipeline_slug": "super-duper-app",
  "build_number": 1,
  "build_branch": "main",
  "build_commit": "9f3182061f1e2cca4702c368cbc039b7dc9d4485",
  "step_key": "build",
  "job_id": "0184990a-477b-4fa8-9968-496074483cee",
  "agent_id": "0184990a-4782-42b5-afc1-16715b10b8ff"
}
```
