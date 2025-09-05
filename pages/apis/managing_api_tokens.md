# Managing API access tokens

Buildkite API access tokens are issued to individuals not organizations. You can create and edit API access tokens in your [personal settings](https://buildkite.com/user/api-access-tokens).

On the [API Access Audit](https://buildkite.com/organizations/~/api-access-audit) page, organization admins can view all tokens that have been created with access to their organization data. As well as auditing user tokens and what access they have, you can also remove a token's access to your organization data if required.

## Token scopes

When you create a token, select the organizations it grants access to, and for REST APIS the scope of the access. GraphQL tokens cannot be limited by scope.

> 📘 Note for contributors to public and open-source projects
> You need to be a member of the Buildkite organization to be able to generate and use an API token for it.

REST API scopes are very granular, you can select some or all of the following:

- **Read Agents** (`read_agents`): Permission to list and retrieve details of agents.
- **Write Agents** (`write_agents`): Permission to stop agents. To register agents, use an [Agent token] instead.
- **Read Clusters** (`read_clusters`): Permission to list and retrieve details of clusters.
- **Write Clusters** (`write_clusters`): Permission to create, update and delete clusters.
- **Read Teams** (`read_teams`): Permission to list teams.
- **Write Teams** (`write_teams`): Permission to create, update and delete teams.
- **Read Artifacts** (`read_artifacts`): Permission to retrieve build artifacts.
- **Write Artifacts** (`write_artifacts`): Permission to delete build artifacts.
- **Read Builds** (`read_builds`): Permission to list and retrieve details of builds.
- **Write Builds** (`write_builds`): Permission to create new builds.
- **Read Job Environment Variables** (`read_job_env`): Permission to retrieve job environment variables.
- **Read Build Logs** (`read_build_logs`): Permission to retrieve build logs.
- **Write Build Logs** (`write_build_logs`): Permission to delete build logs.
- **Read Organizations** (`read_organizations`): Permission to list and retrieve details of organizations.
- **Read Pipelines** (`read_pipelines`): Permission to list and retrieve details of pipelines.
- **Write Pipelines** (`write_pipelines`): Permission to create, update and delete pipelines.
- **Read Pipeline Templates** (`read_pipeline_templates`): Permission to list and retrieve details of pipeline templates.
- **Write Pipeline Templates** (`write_pipeline_templates`): Permission to create, update and delete pipeline templates.
- **Read Rules** (`read_rules`): Permission to list and retrieve details of rules.
- **Write Rules** (`write_rules`): Permission to create or delete rules.
- **Read User** (`read_user`): Permission to retrieve basic details of the user.
- **Read Suites** (`read_suites`): Permission to list and retrieve details of test suites; including runs,
  tests, executions, etc.
- **Write Suites** (`write_suites`): Permission to create, update and delete test suites.
- **Read Test Plan** (`read_test_plan`): Permission to retrieve test plan information.
- **Write Test Plan** (`write_test_plan`): Permission to create test plan.
- **Read Portals** (`read_portals`): Permission to list and retrieve details of portals.
- **Write Portals** (`write_portals`): Permission to create, update, and delete portals.
- **Read Registries** (`read_registries`): Permission to list and retrieve details of registries.
- **Write Registries** (`write_registries`): Permission to create and update registries.
- **Delete Registries** (`delete_registries`): Permission to delete registries.
- **Read Packages** (`read_packages`): Permission to list and retrieve details of packages.
- **Write Packages** (`write_packages`): Permission to create packages.
- **Delete Packages** (`delete_packages`): Permission to delete packages.

When creating API access tokens, you can also restrict which network address are allowed to use them, using [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing).

## Auditing tokens

Viewing the **API Access Audit** page requires Buildkite organization administrator privileges. The page can be found in the **Audit** section of the Buildkite organization's **Settings** in the global navigation.

All tokens that currently have access to your organization's data will be listed. The table includes the scope of each token, how long ago they were created, and how long since they've been used.

From the **API Access Audit** page, navigate through to any token to see more detailed information about its scopes and the most recent request.

<%= image "all-tokens-view.png", width: 1820/2, height: 1344/2, alt: "Screenshot of the API Access Audit page displaying a list of all tokens" %>

The list of tokens can be filtered by username, scopes, IP address, or whether the user has admin privileges.

 <%= image "filter-graphql-view.png", width: 1792/2, height: 1202/2, alt: "Screenshot of the API Access Audit page displaying a filtered list of tokens that have the GraphQL scope" %>

## Removing an organization from a token

If you have old API access tokens that should no longer be used, or need to prevent such a token from performing further actions, Buildkite organization administrators can remove the token's access to organization data.

From the [**API Access Audit** page](#auditing-tokens), find the API token whose access you want to remove. You can search for tokens using usernames, token scopes, full IP addresses, admin privileges, or the value of the token itself.

<%= image "token-view.png", width: 1788/2, height: 2288/2, alt: "Screenshot of the API access token page with the Revoke Access button at the bottom of the screen" %>

From the **API Access Audit** page, navigate through to the token you'd like to remove, then select **Remove Organization from Token**.

Removing access from a token sends a notification email to the token's owner, who cannot re-add your organization to the token's scope.

## Limiting API access by IP address

If you'd like to limit an API token's access to your organization by IP address, you can create an allowlist of IP addresses in the [organization's API security settings](https://buildkite.com/organizations/~/security/api).

You can also manage the allowlist with the [`organizationApiIpAllowlistUpdate`](/docs/apis/graphql/schemas/mutation/organizationapiipallowlistupdate) mutation in the GraphQL API.

## Inactive API tokens revocation

> 📘 Enterprise feature
> Revoking inactive API tokens automatically is only available on an [Enterprise](https://buildkite.com/pricing) plan.

To enable the inactive API access tokens revocation feature, navigate to your [organization's security settings](https://buildkite.com/organizations/~/security) and specify the maximum timeframe for inactive tokens to remain valid.

An _inactive API access token_ refers to one that has not been used within the specified duration. When an API token surpasses the configured setting, Buildkite will automatically revoke the token's access to your organization.

Upon token revocation, Buildkite will notify the owner of their change in access.

## Programmatically managing tokens

The `access-token` REST API endpoint can be used to retrieve or revoke an API access token. See the [REST API access token](/docs/apis/rest-api/access-token) page for further information.

## API token lifecycle

Buildkite's API access tokens have the following lifecycle characteristics:

- API access tokens are issued for users within a Buildkite organization. The tokens are stored in the Buildkite database (linked to the user ID) and by the user for which they're issued.

- The tokens are associated with a specific user and can only be revoked by that user. Buildkite organization administrators can remove a user from an organization, which prevents the user from accessing any organization resources and pipelines, and prevents access using any API access token associated with that user.

## API token security

This section explains risk mitigation strategies which you can implement, and others which are in place, to prevent your Buildkite API access tokens being compromised.

### Rotation

Buildkite's API access tokens have no built-in expiration date. The best practices regarding regular credential rotation recommended by [OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html#key-lifetimes-and-rotation) suggest rotating the tokens at least once a year. In case of a security compromise or breach, it is strongly recommended that the old tokens are [invalidated](/docs/apis/managing-api-tokens#removing-an-organization-from-a-token) or inactive ones [revoked](#inactive-api-tokens-revocation), and new tokens are issued.

### GitHub secret scanning program

Buildkite is a member of the [GitHub secret scanning program](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program).
This service [alerts](https://docs.github.com/en/code-security/secret-scanning/secret-scanning-partnership-program/secret-scanning-partner-program#the-secret-scanning-process) us when a Buildkite personal API access token has been leaked on GitHub in a public repository.

Once Buildkite receives a notification of a publicly leaked token from GitHub, Buildkite will:

- Revoke the token immediately.
- Email the user who generated the token to let them know it has been revoked.
- Email the organizations associated with the token to let them know it has been revoked.

You can also:

- Enable GitHub secret scanning for [private repositories](https://docs.github.com/en/code-security/secret-scanning/enabling-secret-scanning-features/enabling-secret-scanning-for-your-repository).

- Generate a new [access token for your Buildkite user account](https://buildkite.com/user/api-access-tokens).

## FAQs

### Can I view an existing token?

No, you can change the scope and description of a token, or revoke it, but you can't view the actual token after creating it

### Can I re-add my organization to a token?

No. If an organization has revoked a token, it cannot be re-added to the token. The token owner would have to create a new token with access to your organization.

### Can I delete a token?

Yes. If you need to delete a token entirely, you can use the [REST API `access-token` endpoint](/docs/apis/rest-api/access-token#revoke-the-current-token). You will need to know the full token value.

If you own the token, you can revoke your token from the [API access token page](https://buildkite.com/user/api-access-tokens) in your Personal Settings.

### What happens if I remove the access for a token that's currently in use?

The token will lose access to the organization data. Any future API requests will no longer successfully authorize.

[Agent token]: /docs/agent/v3/tokens
