# Managing API access tokens

Buildkite API access tokens are issued to individual Buildkite user accounts, not Buildkite organizations. You can create and edit API access tokens in your [personal settings](https://buildkite.com/user/api-access-tokens).

On the [API Access Audit](https://buildkite.com/organizations/~/api-access-audit) page, Buildkite organization administrators can view all tokens that have been created with access to their organization data. As well as auditing user tokens and what access they have, you can also remove a token's access to your organization data if required.

## Token scopes

When an API access token is created, select the Buildkite organization it grants access to, and its scopes of access. GraphQL API access tokens cannot be restricted by scope.

Token scopes are also available to OAuth access tokens, which are issued by the Buildkite platform on behalf of your Buildkite user account for certain processes. However, when these processes occur, while you can select a Buildkite organization you're a member of, which the OAuth token grants access to, the Buildkite platform defines the scopes for these access tokens.

> 📘 Note for contributors to public and open-source projects
> You need to be a member of the Buildkite organization to generate and use an API access token for it.

Token scopes are very granular, and for API access tokens, you can select some or all of the following scopes.

### CI/CD

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Pipelines",
        key: "read_pipelines, write_pipelines",
        description: "List and retrieve details of pipelines; create, update, and delete pipelines.",
        read: true, write: true, delete: false
      },
      {
        name: "Builds",
        key: "read_builds, write_builds",
        description: "List and retrieve details of builds; create new builds.",
        read: true, write: true, delete: false
      },
      {
        name: "Build Logs",
        key: "read_build_logs, write_build_logs",
        description: "Retrieve build logs; delete build logs.",
        read: true, write: true, delete: false
      },
      {
        name: "Job Environment",
        key: "read_job_env",
        description: "Retrieve job environment variables.",
        read: true, write: false, delete: false
      },
      {
        name: "Artifacts",
        key: "read_artifacts, write_artifacts",
        description: "Retrieve build artifacts; delete build artifacts.",
        read: true, write: true, delete: false
      },
      {
        name: "Agents",
        key: "read_agents, write_agents",
        description: "List and retrieve details of agents; stop agents. To register agents, use an [agent token](/docs/agent/v3/self-hosted/tokens) instead.",
        read: true, write: true, delete: false
      },
      {
        name: "Clusters",
        key: "read_clusters, write_clusters",
        description: "List and retrieve details of clusters; create, update, and delete clusters.",
        read: true, write: true, delete: false
      },
      {
        name: "Pipeline Templates",
        key: "read_pipeline_templates, write_pipeline_templates",
        description: "List and retrieve details of pipeline templates; create, update, and delete pipeline templates.",
        read: true, write: true, delete: false
      },
      {
        name: "Rules",
        key: "read_rules, write_rules",
        description: "List and retrieve details of rules; create or delete rules.",
        read: true, write: true, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Organization and users

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Organizations",
        key: "read_organizations",
        description: "List and retrieve details of organizations.",
        read: true, write: false, delete: false
      },
      {
        name: "Teams",
        key: "read_teams, write_teams",
        description: "List teams; create, update, and delete teams.",
        read: true, write: true, delete: false
      },
      {
        name: "User",
        key: "read_user",
        description: "Retrieve basic details of the user.",
        read: true, write: false, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Security

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Secrets",
        key: "read_secrets_details, write_secrets",
        description: "List and retrieve details about secrets; create, update, and delete secrets.",
        read: true, write: true, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Test Engine

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Suites",
        key: "read_suites, write_suites",
        description: "Retrieve suite information; create suites.",
        read: true, write: true, delete: false
      },
      {
        name: "Test Plan",
        key: "read_test_plan, write_test_plan",
        description: "Retrieve test plan information; create test plan.",
        read: true, write: true, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Packages

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Registries",
        key: "read_registries, write_registries, delete_registries",
        description: "List and retrieve details of registries; create and update registries; delete registries.",
        read: true, write: true, delete: true
      },
      {
        name: "Packages",
        key: "read_packages, write_packages, delete_packages",
        description: "List and retrieve details of packages; create packages; delete packages.",
        read: true, write: true, delete: true
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Portals

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Portals",
        key: "read_portals, write_portals",
        description: "List and retrieve details of portals; create, update, and delete portals.",
        read: true, write: true, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

### Events

<table>
  <thead>
    <tr>
      <th style="width:25%">Scope</th>
      <th style="width:55%">Description</th>
      <th style="width:7%">Read</th>
      <th style="width:7%">Write</th>
      <th style="width:6%">Delete</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        name: "Events",
        key: "read_events",
        description: "Access the event log.",
        read: true, write: false, delete: false
      }
    ].each do |scope| %>
      <tr>
        <td><strong><%= scope[:name] %></strong><br><%= scope[:key].split(", ").map { |k| "<code>#{k}</code>" }.join(", ") %></td>
        <td><%= render_markdown(text: scope[:description]) %></td>
        <td><%= scope[:read] ? "✅" : "" %></td>
        <td><%= scope[:write] ? "✅" : "" %></td>
        <td><%= scope[:delete] ? "✅" : "" %></td>
      </tr>
    <% end %>
  </tbody>
</table>

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

> 📘 Enterprise plan feature
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

The [API Access Tokens page](https://buildkite.com/user/api-access-tokens) has a _Duplicate_ button that can be used to create a new token with the same permissions as the existing token.

### GitHub secret scanning program

Learn more about this program in [Token security](/docs/platform/security/tokens).

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

[Agent token]: /docs/agent/v3/self-hosted/tokens
