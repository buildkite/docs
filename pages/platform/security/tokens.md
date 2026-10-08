# Token security

Use this page to compare Buildkite token types, manage token access, identify tokens by their prefixes, and understand how leaked tokens are detected. For controls beyond tokens, see the [Security overview](/docs/platform/security).

If a token may have been exposed, follow [Incident response](/docs/platform/security/incident-response#contain-the-incident-revoke-compromised-tokens) immediately. Don't wait for a secret scanning notification.

## Token reference

The following table summarizes how each Buildkite token is used, what it can access, and how long it remains valid. Tokens marked as internal are generated and managed by the Buildkite agent, and you don't create them yourself.

| Token | Prefix | How it's used | Scope | Lifetime |
| ----- | ------ | ------------- | ----- | -------- |
| [API access token](/docs/apis/managing-api-tokens) | `bkua_` | Users and scripts call the REST and GraphQL APIs with a bearer token. | The selected [REST API scopes](/docs/apis/managing-api-tokens#token-scopes) and optional GraphQL access, for the selected Buildkite organizations. GraphQL access is not further scoped. | The **Token Expiry** selected at creation, which defaults to seven days. Tokens with the **Public Key** credential type don't expire. |
| [OAuth Token Exchange token](/docs/apis/oauth-token-exchange) | `bktx_` | Services exchange a signed JWT assertion for a token, and call the APIs on behalf of a user. | The requested scopes, limited to the Token Exchange App's grantable scopes. | Up to the app's **Max Token TTL**, which defaults to one hour and can be set between 30 seconds and 24 hours. |
| [Agent token](/docs/agent/self-hosted/tokens) | `bkct_` | Self-hosted agents register with a cluster using `BUILDKITE_AGENT_TOKEN`. | Any queue in one cluster. | No expiry when created in the Buildkite interface. An optional expiry, at least 10 minutes in the future, can be set when created using the API. |
| [Unclustered agent token](/docs/agent/self-hosted/tokens#working-with-unclustered-agent-tokens) | `bkar_` | Agents register with unclustered queues. | Any unclustered queue in the Buildkite organization. | No expiry. Revoke manually. |
| [Job acquisition token](/docs/agent/self-hosted/job-acquisition-tokens) | `bkjat_` | A stack controller issues the token to an ephemeral agent, which registers and acquires one reserved job. | One reserved job. | 15 minutes by default, up to one hour, or until the job reservation expires, whichever is first. |
| [Agent session token](/docs/agent/self-hosted/tokens#additional-agent-tokens-session-tokens) (internal) | `bkaa_` | Issued to an agent when it registers, and used to poll for and start jobs. | The registered agent's connection. | Until the agent disconnects. |
| [Agent job token](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens) (internal) | `bkaj_` | Exposed to each job as `BUILDKITE_AGENT_ACCESS_TOKEN`, and used by agent CLI commands such as `annotate`, `artifact`, and `meta-data`. | The job, plus metadata, annotations, and artifacts of other jobs in the same cluster. | Until the job finishes. |
| [Registry token](/docs/package-registries/registries/manage#configure-registry-tokens) | `bkpt_` | Package managers download and install packages from a private registry. | Read-only access to one registry. | No expiry. Delete manually. |
| Package Registries temporary token | `bkpt_` | Included in the publish and install commands shown on a registry's pages. | Publishing to, or installing from, one registry. | A few minutes. |
| [Portal long-lived service token](/docs/apis/graphql/portals) | `bkpat_` | Services call a portal's endpoint with a bearer token. | The portal's GraphQL operations, run with administrator-level permissions. | No expiry. Replace it from the portal's **Security** page. |
| [Ephemeral portal token](/docs/apis/graphql/portals/ephemeral-portal-tokens) | `bkpat_` | Services exchange a portal secret for a token. | The portal's GraphQL operations, run with administrator-level permissions. | Up to one hour, or shorter if requested. |
| [User-invoked portal token](/docs/apis/graphql/portals/user-invoked-portals) | `bkpat_` | A user authorizes a token code to generate the token. | The portal's GraphQL operations, limited to the user's own permissions. | 12 hours by default, or shorter if requested. |
| [Portal secret](/docs/apis/graphql/portals/ephemeral-portal-tokens#generating-a-secret) | `bkps_` | Services use the secret to request ephemeral portal tokens. | One portal. | No expiry. Each portal can have two secrets, so that you can rotate them. |

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

- Prefix: `bkua_`
- Example: `bkua_*****************************************************`

_Applies to API access tokens created after:  March, 2023_

### Agent session tokens

Buildkite agent [session tokens](/docs/agent/self-hosted/tokens#additional-agent-tokens-session-tokens) are also known as _Buildkite agent access_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkaa_`
- Example: `bkaa_***************************************************************************`

_Applies to agent session tokens created after: January, 2025_

### Agent job tokens

Buildkite agent [job tokens](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens) form the acronym for the prefix of their values.

- Prefix: `bkaj_`
- Example: `bkaj_*********************************************************************************************************************************************************************************************************************************************************************************************************************************************`

### Unclustered agent tokens

Buildkite [unclustered agent tokens](/docs/agent/self-hosted/tokens#working-with-unclustered-agent-tokens) are also known as _Buildkite agent registration_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkar_`
- Example: `bkar_*************************************************************************`

_Applies to unclustered agent tokens created after: April, 2025_

### Agent tokens

Buildkite [agent tokens](/docs/agent/self-hosted/tokens) are also known as _Buildkite cluster tokens_, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkct_`
- Example: `bkct_*************************************************************************`

_Applies to agent tokens created after: April, 2025_

### Registry tokens

Buildkite [registry tokens](/docs/package-registries/registries/manage#configure-registry-tokens), are a type of Buildkite Package (Registries) token, whose acronym forms the prefix for these tokens.

- Prefix: `bkpt_`
- Example: `bkpt_*******************************************************************************************************************************************************************************************************`

### Package Registries temporary tokens

Buildkite Package Registries temporary tokens, which are presented on a registry's pages for either publishing packages to the registry or installing specific packages from them. See the relevant [Package ecosystem](/docs/package-registries/ecosystems) pages to learn more about these types of tokens, which are a type of Buildkite Package (Registries) token, whose acronym forms the prefix for these tokens.

- Prefix: `bkpt_`
- Example: `bkpt_*******************************************************************************************************************************************************************************************************`

### Portal tokens

Buildkite portal tokens cover the following types of tokens:

- _Long-lived service tokens_, generated when a [new portal is created](/docs/apis/graphql/portals#creating-a-portal), as well as [through the portal's **Security** page](/docs/apis/graphql/portals#authentication).
- [Ephemeral portal tokens](/docs/apis/graphql/portals/ephemeral-portal-tokens), which requires a [portal secret](#supported-buildkite-tokens-portal-secrets) to be [generated](/docs/apis/graphql/portals/ephemeral-portal-tokens#requesting-an-ephemeral-portal-token).
- [Portal tokens](/docs/apis/graphql/portals/user-invoked-portals#short-lived-portal-token-generating-a-portal-token) that are [user-invoked and scoped](/docs/apis/graphql/portals/user-invoked-portals).

These types of tokens are also known as _Buildkite portal access tokens_, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkpat_`
- Example: `bkpat_******************************************************`

### Portal secrets

Buildkite [portal secrets](/docs/apis/graphql/portals/ephemeral-portal-tokens#generating-a-secret), whose acronym forms the prefix to their values, are used to generate [ephemeral portal tokens](/docs/apis/graphql/portals/ephemeral-portal-tokens#requesting-an-ephemeral-portal-token), which are a type of [portal token](#supported-buildkite-tokens-portal-tokens).

- Prefix: `bkps_`
- Example: `bkps_****************************************************************`

## Other Buildkite tokens

Buildkite also issues short-lived tokens for specific workflows.

### Job acquisition tokens

Buildkite [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens) allow an ephemeral agent to register and acquire one reserved job without receiving the long-lived agent token held by its stack controller.

- Prefix: `bkjat_`
- Example: `bkjat_*****************************************************`

By default, job acquisition tokens expire 15 minutes after issuance. A stack can request a lifetime of up to one hour, but the token expires earlier if the job reservation expires first.

### OAuth Token Exchange tokens

Buildkite [OAuth Token Exchange](/docs/apis/oauth-token-exchange) tokens are short-lived API tokens that a service obtains by exchanging a signed JSON Web Token (JWT) assertion, instead of using a long-lived API access token tied to a user.

- Prefix: `bktx_`

These tokens expire no later than the **Max Token TTL** configured on the Token Exchange App, which defaults to one hour and can be set between 30 seconds and 24 hours.
