# Token security

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

Buildkite Agent [session tokens](/docs/agent/v3/self-hosted/tokens#additional-agent-tokens-session-tokens) are also known as _Buildkite Agent access_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkaa_`
- Example: `bkaa_***************************************************************************`

_Applies to agent session tokens created after: January, 2025_

### Agent job tokens

Buildkite Agent [job tokens](/docs/agent/v3/self-hosted/tokens#additional-agent-tokens-job-tokens) form the acronym for the prefix of their values.

- Prefix: `bkaj_`
- Example: `bkaj_*********************************************************************************************************************************************************************************************************************************************************************************************************************************************`

### Unclustered agent tokens

Buildkite [unclustered agent tokens](/docs/agent/v3/self-hosted/unclustered-tokens) are also known as _Buildkite Agent registration_ tokens, whose acronym forms the prefix for these types of tokens.

- Prefix: `bkar_`
- Example: `bkar_*************************************************************************`

_Applies to unclustered agent tokens created after: April, 2025_

### Agent tokens

Buildkite [agent tokens](/docs/agent/v3/self-hosted/tokens) are also known as _Buildkite cluster tokens_, whose acronym forms the prefix for these types of tokens.

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
