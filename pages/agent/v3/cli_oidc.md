# `buildkite-agent oidc request-token`

The Buildkite Agent's `oidc request-token` command allows you to request an OIDC token representing the current job. These tokens can be exchanged with federated systems like AWS.

See the [OpenID Connect Core documentation](https://openid.net/specs/openid-connect-core-1_0.html#IDToken) for more information about how OIDC tokens are constructed and how to extract and use claims.

<%= render "agent/v3/help/oidc_request_token" %>

## OIDC URLs

If using a plugin, such as the [AWS assume-role-with-web-identity](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) plugin, you'll need to provide an OpenID provider URL. You should set the provider URL to: https://agent.buildkite.com.

For specific endpoints for OpenID or JWKS, use:

- **OpenID Connect Discovery URL:** https://agent.buildkite.com/.well-known/openid-configuration
- **JWKS URI:** https://agent.buildkite.com/.well-known/jwks

## Token contents

<table data-attributes data-attributes-required>
  <thead>
    <tr>
      <th>Token</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>iss</code></td>
    <td>
      Issuer. Identifies the entity that issued the JWT.
      <em>Example:</em> <code>Example: https://agent.buildkite.com</code><br>
    </td>
  </tr>
   <tr>
    <td><code>sub</code></td>
    <td>
      Subject. Identifies the subject of the JWT, typically representing the user or entity being authenticated.
      The format is <code>organization:{organization.slug}:pipeline:{pipeline.slug}:ref:{ref}:commit:{build.commit}:step:{step.key}</code>. <code>{ref}</code> is <code>refs/tags/{tag}</code> if the build has a tag, otherwise is <code>refs/heads/{branch}</code>.
      <br>
      <em>Example:</em> <code>organization:acme-inc:pipeline:super-duper-app:ref:refs/heads/main:commit:9f3182061f1e2cca4702c368cbc039b7dc9d4485:step:build</code><br>
    </td>
  </tr>
   <tr>
    <td><code>aud</code></td>
    <td>
      Audience. Identifies the intended audience for the JWT. Defaults to <code>https://buildkite.com/{organization.slug}</code> but can be overridden using the <code>--audience</code> flag
    </td>
  </tr>
   <tr>
    <td><code>exp</code></td>
    <td>
      Expiration Time. Specifies the expiration time of the JWT, after which the token is no longer valid. Set to 5 minutes in the future at generation.<br>
      Can be changed with the <code>--lifetime</code> flag.<br>
      <em>Example:</em> <code>1669015898</code><br>
    </td>
  </tr>
   <tr>
    <td><code>nbf</code></td>
    <td>
      Not Before. Specifies the time before which the JWT must not be accepted for processing. Set to the current timestamp at generation. <br>
      <em>Example:</em> <code>1669014898</code><br>
    </td>
  </tr>
   <tr>
    <td><code>iat</code></td>
    <td>
      Issued At. Specifies the time at which the JWT was issued. Set to the current timestamp at generation.<br>
      <em>Example:</em> <code>1669014898</code>
    </td>
  </tr>
   <tr>
    <td><code>organization_slug</code></td>
    <td>
      The slug of your organization in the Buildkite platform.
      <em>Example:</em> <code>acme-inc</code><br>
    </td>
  </tr>
   <tr>
    <td><code>pipeline_slug</code></td>
    <td>
      The slug of your pipeline in the Buildkite platform.
      <em>Example:</em> <code>super-duper-app</code><br>
    </td>
  </tr>
   <tr>
    <td><code>build_number</code></td>
    <td>
      The unique number of your build.
      <em>Example:</em> <code>1</code><br>
    </td>
  </tr>
   <tr>
    <td><code>build_branch</code></td>
    <td>
      The repository branch used in your build.
      <em>Example:</em> <code>main</code><br>
    </td>
  </tr>
  <tr>
    <td><code>build_tag</code></td>
    <td>
      The tag of the build if enabled in Buildkite. This claim is only included if the tag is set.
      <em>Example:</em> <code>1</code><br>
    </td>
  </tr>
  <tr>
    <td><code>build_commit</code></td>
    <td>
      The SHA commit from the repository.
      <em>Example:</em> <code>9f3182061f1e2cca4702c368cbc039b7dc9d4485</code><br>
    </td>
  </tr>
  <tr>
    <td><code>step_key</code></td>
    <td>
      The <code>key</code> attribute of the step from the pipeline. If the key is not set for the step, <code>nil</code> will be returned.
      <em>Example:</em> <code>build_step</code><br>
    </td>
  </tr>
  <tr>
    <td><code>job_id</code></td>
    <td>
      The job UUID.
      <em>Example:</em> <code>0184990a-477b-4fa8-9968-496074483cee</code><br>
    </td>
  </tr>
  <tr>
    <td><code>agent_id</code></td>
    <td>
      The agent UUID.
      <em>Example:</em> <code>0184990a-4782-42b5-afc1-16715b10b8ff</code><br>
    </td>
  </tr>
  </tbody>
</table>

### Optional claims

Generate these additional claims by adding `--claims` to the `buildkite-agent oidc request-token` command.

<table data-attributes data-attributes-required>
  <thead>
    <tr>
      <th>Token</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>organization_id</code></td>
    <td>
      The organization UUID.
      <em>Example:</em> <code>0184990a-477b-4fa8-9968-496074483k77</code><br>
    </td>
  </tr>
  <tr>
    <td><code>pipeline_id</code></td>
    <td>
      The pipeline UUID.
      <em>Example:</em> <code>0184990a-4782-42b5-afc1-16715b10b1l0</code><br>
    </td>
  </tr>
  </tbody>
</table>

## Example token contents

OIDC tokens are JSON Web Tokens — [JWTs](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-json-web-token) — and the following is a complete example:

```json
{
  "iss": "https://agent.buildkite.com",
  "sub": "organization:acme-inc:pipeline:super-duper-app:ref:refs/heads/main:commit:9f3182061f1e2cca4702c368cbc039b7dc9d4485:step:build",
  "aud": "https://buildkite.com/acme-inc",
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
