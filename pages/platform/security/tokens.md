# Token security

Use this page to compare Buildkite token types, manage token access, identify tokens by their prefixes, and understand how leaked tokens are detected. For controls beyond tokens, see the [Security overview](/docs/platform/security).

If a token may have been exposed, follow [Incident response](/docs/platform/security/incident-response#contain-the-incident-revoke-compromised-tokens) immediately. Don't wait for a secret scanning notification.

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

## Manage the token lifecycle

Choose the token type your workflow needs, grant only the required access, and plan how to replace or revoke it:

- **Create and scope API access tokens:** Follow [Creating and editing API access tokens](/docs/apis/managing-api-tokens#creating-and-editing-api-access-tokens), and select only the [token scopes](/docs/apis/managing-api-tokens#token-scopes) the workflow requires.
- **Set expiry and rotate credentials:** Set a **Token Expiry** when creating an API access token with the **Token** credential type, and follow the [rotation guidance](/docs/apis/managing-api-tokens#api-token-security-rotation). For agent tokens, use the API to [set an expiration date](/docs/agent/self-hosted/tokens#agent-token-lifetime); tokens created in the Buildkite interface don't expire.
- **Manage agent tokens:** [Create a token](/docs/agent/self-hosted/tokens#create-a-token) in the cluster that needs it, review its [scope of access](/docs/agent/self-hosted/tokens#scope-of-access), and [revoke it](/docs/agent/self-hosted/tokens#revoke-a-token) when no longer needed. Revocation prevents new connections but doesn't disconnect existing agents.
- **Review and remove API token access:** [Audit tokens](/docs/apis/managing-api-tokens#auditing-tokens) regularly. Organization administrators can [remove their organization from a token](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token); token owners can [revoke the token entirely](/docs/apis/managing-api-tokens#faqs-can-i-delete-a-token).
- **Prefer short-lived credentials where supported:** Use [OAuth Token Exchange](/docs/apis/oauth-token-exchange) for services or [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens) for ephemeral agents, rather than distributing long-lived tokens to them.

## Detect leaked tokens

Buildkite is a member of the [GitHub secret scanning program
](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program).

If you have enabled [GitHub Secret Protection](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security#github-secret-protection) for [repositories](https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features/enabling-secret-scanning-for-your-repository) in your GitHub organization, GitHub will automatically scan these _private_ or _public_ repositories within your GitHub organization for Buildkite tokens and notify you if any are found.

In the case of [Buildkite API access tokens](#supported-buildkite-tokens-api-access-tokens) (`bkua_`) leaked on _public_ repositories, GitHub will notify Buildkite directly and any valid tokens will be automatically revoked and their owner's and associated organizations notified.

If you are notified of any other tokens, please contact Buildkite support.

## Supported Buildkite tokens

The following Buildkite tokens are supported by this program.

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
