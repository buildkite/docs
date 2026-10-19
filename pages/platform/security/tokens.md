# Token security

Use this page to compare Buildkite token types, manage token access, identify tokens by their prefixes, and understand how leaked tokens are detected. For controls beyond tokens, see the [Security overview](/docs/platform/security).

If a token may have been exposed, follow [Incident response](/docs/platform/security/incident-response#contain-the-incident-revoke-compromised-tokens) immediately. Don't wait for a secret scanning notification.

## Manage the token lifecycle

Choose the token type your workflow needs, grant only the required access, and plan how to replace or revoke it:

- **Create and scope API access tokens:** Follow [Creating and editing API access tokens](/docs/apis/managing-api-tokens#creating-and-editing-api-access-tokens), and select only the [token scopes](/docs/apis/managing-api-tokens#token-scopes) the workflow requires.
- **Set expiry and rotate credentials:** Set a **Token Expiry** when creating an API access token with the **Token** credential type, and follow the [rotation guidance](/docs/apis/managing-api-tokens#api-token-security-rotation). For agent tokens, use the API to [set an expiration date](/docs/agent/self-hosted/tokens#agent-token-lifetime); tokens created in the Buildkite interface don't expire.
- **Manage agent tokens:** [Create a token](/docs/agent/self-hosted/tokens#create-a-token) in the cluster that needs it, review its [scope of access](/docs/agent/self-hosted/tokens#scope-of-access), and [revoke it](/docs/agent/self-hosted/tokens#revoke-a-token) when no longer needed. Revocation prevents new connections but doesn't disconnect existing agents.
- **Review and remove API token access:** [Audit tokens](/docs/apis/managing-api-tokens#auditing-tokens) regularly. Organization administrators can [remove their organization from a token](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token); token owners can [revoke the token entirely](/docs/apis/managing-api-tokens#faqs-can-i-delete-a-token).
- **Prefer short-lived credentials where supported:** Use [OAuth Token Exchange](/docs/apis/oauth-token-exchange) for services or [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens) for ephemeral agents, rather than distributing long-lived tokens to them.
- **Manage OAuth access:** Review [OAuth for remote MCP and the Buildkite CLI](/docs/platform/security/oauth) for refresh behavior, **Connected Apps** revocation, and authorization audit events. Running `bk auth logout` removes local credentials but doesn't revoke the authorization in Buildkite.

## Detect leaked tokens

Buildkite is a member of the [GitHub secret scanning program
](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program).

If you have enabled [GitHub Secret Protection](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security#github-secret-protection) for [repositories](https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features/enabling-secret-scanning-for-your-repository) in your GitHub organization, GitHub will automatically scan these _private_ or _public_ repositories within your GitHub organization for Buildkite tokens and notify you if any are found.

In the case of [Buildkite API access tokens](#supported-buildkite-tokens-api-access-tokens) (`bkua_`) leaked on _public_ repositories, GitHub will notify Buildkite directly and any valid tokens will be automatically revoked and their owner's and associated organizations notified.

If you are notified of any other tokens, please contact Buildkite support.

## Audit this area

SSO and 2FA enforcement, team membership and the API access audit can't be read through the MCP server today. It also can't look up a token you've found, so use the API tab to identify a leaked one.

The [current token API](/docs/apis/rest-api/access-token#get-the-current-token) requires no additional token scope. The team query requires [GraphQL API access](/docs/apis/managing-api-tokens#token-scopes); replace `acme-inc` with your organization slug. Results only include teams and pipelines visible to the token. Follow [GraphQL pagination](/docs/apis/graphql#pagination) for both connections when `hasNextPage` is `true`. Run these commands locally with `jq` installed. Never paste tokens into an AI conversation or save them in logs.

### API

```bash
# Scopes and expiry of the token you're using
curl --fail-with-body -sS \
  -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  https://api.buildkite.com/v2/access-token | jq '{scopes, expires_at}'

# Teams, pipelines, and access levels visible to this token (GraphQL)
curl --fail-with-body -sS \
  -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
  -H "Content-Type: application/json" \
  https://graphql.buildkite.com/v1 \
  --data '{"query":"{ organization(slug: \"acme-inc\") { teams(first: 100) { pageInfo { hasNextPage endCursor } edges { node { name pipelines(first: 100) { pageInfo { hasNextPage endCursor } edges { node { accessLevel pipeline { slug } } } } } } } } }"}' | jq

# Identify an exposed bkua_ token: owner, scopes, and expiry
curl --fail-with-body -sS \
  -H "Authorization: Bearer $LEAKED_TOKEN" \
  https://api.buildkite.com/v2/access-token | jq '{user, scopes, expires_at}'

# Only after confirming the exposed token: permanently revoke it
curl --fail-with-body -sS -X DELETE \
  -H "Authorization: Bearer $LEAKED_TOKEN" \
  https://api.buildkite.com/v2/access-token
```

The final API command [revokes the exposed token](/docs/apis/rest-api/access-token#revoke-the-current-token), not just its access to one organization. Don't run it against a credential you still need. Use a separate token for the team query, rather than an exposed token.

### CLI

```bash
# Inspect the token configured for the Buildkite CLI
curl --fail-with-body -sS \
  -H "Authorization: Bearer $(bk auth token)" \
  https://api.buildkite.com/v2/access-token | jq '{scopes, expires_at}'

# Find files containing possible Buildkite tokens in this directory
# Print filenames only, not the token values
grep -rlE --exclude-dir=.git \
  'bk(ua|tx|ct|ar|aa|aj|jat|pt|pat|ps)_[A-Za-z0-9]+' .
```

The [Buildkite CLI](/docs/platform/cli) must be authenticated. `bk api` uses organization-scoped REST endpoints, so use `bk auth token` with `curl` for the root `/access-token` endpoint. The file search checks the working directory and saved logs, not Git history or remote build logs. Matches are candidates, not proof that a token is valid; review them locally and revoke exposed credentials.

Review [SSO enforcement](/docs/platform/sso), [2FA enforcement](/docs/platform/team-management/enforce-2fa), and the [API access audit](/docs/apis/managing-api-tokens#auditing-tokens) in the Buildkite interface.

### Ask the Buildkite MCP

```text
What scopes does my Buildkite token have, and when does it expire?
Which Buildkite organization am I connected to?

Use only the read-only access_token and user_token_organization tools.
Inspect the MCP connection's token, not a token pasted into this chat.
Report missing expiry information rather than inferring a lifetime.
Do not change anything.
```

Use [read-only MCP access](/docs/apis/mcp-server#read-only-remote-mcp-server) with the [user toolset](/docs/apis/mcp-server/tools#available-mcp-tools-user-authentication-and-buildkite-organization) enabled and the `read_user` and `read_organizations` scopes. The returned metadata describes the credential used by the MCP server to call the Buildkite API. With OAuth, it doesn't establish the MCP client's session or refresh-token expiry. See [OAuth token lifetime and refresh](/docs/platform/security/oauth#token-lifetime-and-refresh).

## Token reference

The following table summarizes how each Buildkite token is used, what it can access, and how long it remains valid. Tokens marked as internal are generated and managed by the Buildkite agent, and you don't create them yourself.

<!-- Token facts in this table and in the prefix and lifetime lists below are stored in data/content/buildkite_tokens.yaml. -->

<% token = ->(key) { BUILDKITE_TOKENS['tokens'].find { |t| t['key'] == key } } -%>
| Token and prefix | How it's used | Scope | Lifetime |
| ---------------- | ------------- | ----- | -------- |
<% BUILDKITE_TOKENS['tokens'].each do |t| -%>
| <%= t['url'] ? "[#{t['name']}](#{t['url']})" : t['name'] %><%= ' (internal)' if t['internal'] %> `<%= t['prefix'] %>` | <%= t['usage'] %> | <%= t['scope'] %> | <%= t['lifetime'] %> |
<% end -%>
{: class="responsive-table"}

## Supported Buildkite tokens

The following Buildkite tokens are supported by the GitHub secret scanning program.

### API access tokens

Buildkite [API access tokens](/docs/apis/managing-api-tokens) are also known as _Buildkite user access_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `<%= token.('api_access_token')['prefix'] %>`
- Example: `<%= token.('api_access_token')['prefix'] %>*****************************************************`

_Applies to API access tokens created after:  March, 2023_

### Agent session tokens

Buildkite agent [session tokens](/docs/agent/self-hosted/tokens#additional-agent-tokens-session-tokens) are also known as _Buildkite agent access_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `<%= token.('agent_session_token')['prefix'] %>`
- Example: `<%= token.('agent_session_token')['prefix'] %>***************************************************************************`

_Applies to agent session tokens created after: January, 2025_

### Agent job tokens

Buildkite agent [job tokens](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens) form the acronym for the prefix of their values.

- Prefix: `<%= token.('agent_job_token')['prefix'] %>`
- Example: `<%= token.('agent_job_token')['prefix'] %>*********************************************************************************************************************************************************************************************************************************************************************************************************************************************`

### Unclustered agent tokens

Buildkite [unclustered agent tokens](/docs/agent/self-hosted/tokens#working-with-unclustered-agent-tokens) are also known as _Buildkite agent registration_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `<%= token.('unclustered_agent_token')['prefix'] %>`
- Example: `<%= token.('unclustered_agent_token')['prefix'] %>*************************************************************************`

_Applies to unclustered agent tokens created after: April, 2025_

### Agent tokens

Buildkite [agent tokens](/docs/agent/self-hosted/tokens) are also known as _Buildkite cluster tokens_, whose acronym forms the prefix for these types of tokens.

- Prefix: `<%= token.('agent_token')['prefix'] %>`
- Example: `<%= token.('agent_token')['prefix'] %>*************************************************************************`

_Applies to agent tokens created after: April, 2025_

### Registry tokens

Buildkite [registry tokens](/docs/package-registries/registries/manage#configure-registry-tokens), are a type of Buildkite Package (Registries) token, whose acronym forms the prefix for these tokens.

- Prefix: `<%= token.('registry_token')['prefix'] %>`
- Example: `<%= token.('registry_token')['prefix'] %>*******************************************************************************************************************************************************************************************************`

### Package Registries temporary tokens

Buildkite Package Registries temporary tokens, which are presented on a registry's pages for either publishing packages to the registry or installing specific packages from them. See the relevant [Package ecosystem](/docs/package-registries/ecosystems) pages to learn more about these types of tokens, which are a type of Buildkite Package (Registries) token, whose acronym forms the prefix for these tokens.

- Prefix: `<%= token.('package_registries_temporary_token')['prefix'] %>`
- Example: `<%= token.('package_registries_temporary_token')['prefix'] %>*******************************************************************************************************************************************************************************************************`

### Portal tokens

Buildkite portal tokens cover the following types of tokens:

- _Long-lived service tokens_, generated when a [new portal is created](/docs/apis/graphql/portals#creating-a-portal), as well as [through the portal's **Security** page](/docs/apis/graphql/portals#authentication).
- [Ephemeral portal tokens](/docs/apis/graphql/portals/ephemeral-portal-tokens), which requires a [portal secret](#supported-buildkite-tokens-portal-secrets) to be [generated](/docs/apis/graphql/portals/ephemeral-portal-tokens#requesting-an-ephemeral-portal-token).
- [Portal tokens](/docs/apis/graphql/portals/user-invoked-portals#short-lived-portal-token-generating-a-portal-token) that are [user-invoked and scoped](/docs/apis/graphql/portals/user-invoked-portals).

These types of tokens are also known as _Buildkite portal access tokens_, whose acronym forms the prefix for these types of tokens.

- Prefix: `<%= token.('portal_long_lived_service_token')['prefix'] %>`
- Example: `<%= token.('portal_long_lived_service_token')['prefix'] %>******************************************************`

### Portal secrets

Buildkite [portal secrets](/docs/apis/graphql/portals/ephemeral-portal-tokens#generating-a-secret), whose acronym forms the prefix to their values, are used to generate [ephemeral portal tokens](/docs/apis/graphql/portals/ephemeral-portal-tokens#requesting-an-ephemeral-portal-token), which are a type of [portal token](#supported-buildkite-tokens-portal-tokens).

- Prefix: `<%= token.('portal_secret')['prefix'] %>`
- Example: `<%= token.('portal_secret')['prefix'] %>****************************************************************`

## Other Buildkite tokens

Buildkite also issues short-lived tokens for specific workflows.

### Job acquisition tokens

Buildkite [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens) allow an ephemeral agent to register and acquire one reserved job without receiving the long-lived agent token held by its stack controller.

- Prefix: `<%= token.('job_acquisition_token')['prefix'] %>`
- Example: `<%= token.('job_acquisition_token')['prefix'] %>*****************************************************`
- Lifetime: <%= token.('job_acquisition_token')['lifetime'] %>

### OAuth Token Exchange tokens

Buildkite [OAuth Token Exchange](/docs/apis/oauth-token-exchange) tokens are short-lived API tokens that a service obtains by exchanging a signed JSON Web Token (JWT) assertion, instead of using a long-lived API access token tied to a user.

- Prefix: `<%= token.('oauth_token_exchange_token')['prefix'] %>`
- Lifetime: <%= token.('oauth_token_exchange_token')['lifetime'] %>
