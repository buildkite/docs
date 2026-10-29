# User and team permissions

Teams control access to pipelines, test suites, and registries in your Buildkite organization. Teams are available on every [Buildkite plan](https://buildkite.com/pricing).

To enable teams and assign permissions, follow [Manage teams and permissions](#manage-teams-and-permissions).

For related authentication, token, and infrastructure controls, see the [Security overview](/docs/platform/security).

## Manage teams and permissions

Use _teams_ to assign permissions to groups of users. Each team can have access to pipelines, test suites, registries, or a combination of these resources.

A _Buildkite organization administrator_ must enable teams before you can manage team access. The following roles determine who can manage permissions:

Role | Access management
--- | ---
Organization administrator | Manage all teams and resource permissions throughout the organization.
Team maintainer | Manage their team's members and settings. Changing a resource's permissions requires [**Full Access**](#manage-teams-and-permissions-team-level-permissions) to that resource.
Team member | Use resources at the access level assigned to their team. Team members cannot manage the team.
{: class="two-column"}

To access or enable the teams feature for your organization, or both:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Teams** to access your organization's [**Teams**](https://buildkite.com/organizations/~/teams) page.

1. If the teams feature is not enabled, select **Enable Teams** to activate this feature.

<%= image "enable-teams.png", width: 1645/2, height: 1566/2, alt: "Enabling Teams for an organization" %>

When you first enable the teams feature, a team is automatically created for your organization called **Everyone**, which includes all users. This maintains existing access to pipelines for all the users in your Buildkite organization.

Without the **Teams** feature activated, all users are able to access all items within your Buildkite organization.

### Organization-level permissions

A _Buildkite organization administrator_ can manage all teams and their resource permissions. Select **Settings** in the global navigation to open the [**Organization Settings** page](https://buildkite.com/organizations/~/settings).

From **Settings** > **Teams**, administrators can:

- Create a team using **New Team**.
- Manage [team](#manage-teams-and-permissions-team-level-permissions), [pipeline](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions), [test suite](/docs/pipelines/security/permissions#manage-teams-and-permissions-test-suite-level-permissions), and [registry](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions) settings across the organization.
- Delete a team by selecting the team > **Settings** > **Delete Team**.
- [Enable or re-enable teams](#manage-teams-and-permissions).
- Disable teams using **Disable Teams**, after deleting every team, including **Everyone**.

> 📘 Registry settings
> Registry settings are available after [Buildkite Package Registries has been enabled](/docs/package-registries/security/permissions#enabling-buildkite-packages).

Administrators can also configure organization settings for Buildkite Pipelines and Buildkite Package Registries, manage [integrations](/docs/pipelines/integrations), and view usage reports and [audit logs](/docs/platform/audit-log).

### Team-level permissions

A _team maintainer_ manages a team's members, resource access, and settings. A **Team Member** can use the team's resources but cannot manage the team.

To open a team, select **Teams** in the global navigation > **Teams**, then select the team. If you are also an organization administrator, use **Settings** > **Teams** instead, as described in [Organization-level permissions](#manage-teams-and-permissions-organization-level-permissions).

#### Manage team members

Use the **Members** tab to:

- Add an existing organization user using **Add Member**.
- Filter by role using **Everyone**, **Team Member**, or **Team Maintainer** in the role dropdown.
- Remove a user using their **Remove** button.

#### Set resource permissions

Select the resource's tab, then its permission level. These permissions apply to all members of the team:

Resource | Tab | Permission levels
--- | --- | ---
[Pipeline](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions) | **Pipelines** | **Full Access**, **Build & Read**, **Read Only**
[Test suite](/docs/pipelines/security/permissions#manage-teams-and-permissions-test-suite-level-permissions) | **Test Suites** | **Full Access**, **Read Only**
[Registry](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions) | **Package Registries** | **Full Access**, **Read & Write**, **Read Only**
{: class="responsive-table"}

Registry permissions are available after [Buildkite Package Registries has been enabled](/docs/package-registries/security/permissions#enabling-buildkite-packages).

All team members receive the same access to each resource through that team. Create separate teams when groups need different access levels.

> 📘 Pipeline-level permissions override team member permissions
> A user receives the highest pipeline-level permission granted by any of their teams. For example, **Read Only** through Team A and **Full Access** through Team B gives the user **Full Access**. They can edit pipeline settings, create builds, and manage access.

Check your own access before reducing a team's permissions:

> 🚧 Changing **Full Access** permissions on pipelines, test suites and registries
> Changing a resource away from **Full Access** can remove your ability to manage its permissions. You lose that ability if no other team gives you **Full Access** to the resource.
> Ask a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions) to restore access if needed.

#### Configure team settings

Use the team's **Settings** tab to configure:

- **Visibility**: Control the team's visibility.
- **Automatically add new users to this team**: Add new organization members to the team.
- **Default Member Role**: Choose **Member** or **Maintainer** for new team members.
- **Team Member Permissions**: Allow any combination of **Create pipelines**, **Create test suites**, **Create registries**, **Delete registries**, and **Delete packages**.

Team maintainers can still create and add pipelines, test suites, and registries when these team member permissions are removed.

The **Create test suites** permission appears only when your plan includes Test Engine. Otherwise, the setting is hidden. Any saved value is restored if Test Engine becomes available again.

To delete the team, use **Delete** on the **Settings** tab.

### Programmatically managing teams

You can programmatically manage your teams using our GraphQL API.
If you're creating pipelines programmatically using the REST API, you can add them directly to teams using the team's UUID. More information about creating pipelines can be found in our [REST API documentation](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

You can also restrict agents to specific teams with the `BUILDKITE_BUILD_CREATOR_TEAMS` environment variable. Using agent hooks, you can allow or disallow builds based on the creator's team memberships.

> 🚧 Unverified commits
> Note that GitHub accepts <a href="https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification">unsigned commits</a>, including information about the commit author and passes them along to webhooks, so you should not rely on these for authentication unless you are confident that all of your commits are trusted.

For example, the following [`environment` hook](/docs/agent/hooks#job-lifecycle-hooks)
prevents anyone from outside of the ops team from running a build on the agent:

```bash
set -euo pipefail

if [[ ":$BUILDKITE_BUILD_CREATOR_TEAMS:" != *":ops:"* ]]; then
  echo "You must be in the ops team to run a job on this agent"
  exit 1
fi
```

### Frequently asked questions

#### Is there a limit to the number of teams an organization can have?

Yes, Buildkite has a limit of _250 teams per organization_. If you are an [Enterprise](https://buildkite.com/pricing/) plan customer and require additional teams, please contact support@buildkite.com.

#### Will users (and API tokens) still have access to their pipelines?

When you enable the teams feature, a default team called "Everyone" is created, containing all your users and pipelines. This ensures that users, and their API tokens, will still have access to their pipelines.

#### How does Teams work with SSO?

When a user joins the organization using SSO, they'll be automatically added to any teams that have the "Automatically add new users to this team" setting enabled.

#### Can I delete the "Everyone" team?

Yes, you can delete or edit the "Everyone" team. To ensure uninterrupted access to pipelines we recommend creating new teams before deleting the "Everyone" team.

#### Can I set separate permissions specifically on rebuilds?

No, rebuilds are in the same category with builds. Therefore, all team members with permissions to run builds on a certain pipeline are also able to perform rebuilds.

#### Once enabled, can I disable teams?

Yes, you can disable teams by deleting all your teams, and then selecting "Disable Teams".

#### Can I automate the removal of users from Buildkite?

Yes. Use the GraphQL API with a [GraphQL API token](https://buildkite.com/user/api-access-tokens) to remove organization members.

1. Find your organization's slug in [**Organization Settings**](https://buildkite.com/organizations/-/settings).
1. Confirm the user's name or email in their [team](https://buildkite.com/organizations/-/teams).
1. Run the query below. Replace `your-organization-slug` with your organization's slug and `Jane Doe` with the user's name or email. Verify the result before removing the user.

```graphql
query FindOrganizationMember {
  organization(slug: "your-organization-slug") {
    members(first: 1, search: "Jane Doe") {
      edges {
        node {
          id # You will need to use this info on the next step as OrganizationMember.id
          user {
            # Double check that this is the right user you are about to remove
            name
            email
          }
        }
      }
    }
  }
}
```

Copy the user ID you've received into the following mutation and run it to remove the user from your Buildkite organization:

```graphql
mutation RemoveOrganizationMember {
  organizationMemberDelete(input: { id: "user-ID-you-copied-goes-here" }) {
    deletedOrganizationMemberID
  }
}
```

## Removing users during a security incident

Remove a suspected compromised user from your Buildkite organization immediately to revoke their access to organization data. If you use SSO, also [disable their access at the identity provider](#removing-users-during-a-security-incident-removing-users-from-an-organization-with-enabled-sso) to prevent them from rejoining.

For the wider response, including token revocation, secret rotation, investigation, and recovery, follow [Incident response](/docs/platform/security/incident-response).

You can remove a user in your organization's **Settings** in the Buildkite interface.

<%= image "remove-user.png", width: 1572/2, height: 1302/2, alt: "A button to remove a user from an organization" %>

A Buildkite organization administrator can also delete organization members using GraphQL. To do this:

1. Find the `id` for the user to be deleted (in this example `Jane Doe`):

    ```graphql
    query {
      organization(slug: "your-organization-slug") {
        members(search: "Jane Doe", first: 10) {
          edges {
            node {
              role
              user {
                name
              }
              id
            }
          }
        }
      }
    }
    ```

1. Use the `id` from the previous query in a mutation:

    ```graphql
    mutation deleteOrgMember {
      organizationMemberDelete(input: { id: "abc123" }) {
        organization {
          name
        }
        deletedOrganizationMemberID
        user {
          name
        }
      }
    }
    ```

### Security guarantees of removing a user

Removing a user blocks their active sessions from reading or changing your organization's data through the web interface or APIs. The user can still access their personal settings and any other organizations they belong to.

Organization administrators cannot end a user's account-wide sessions. Buildkite accounts belong to individuals and can span multiple organizations.

If you cannot work with the affected user, or several accounts are compromised, send the affected user IDs to [support@buildkite.com](mailto:support@buildkite.com). Ask Buildkite support to end all sessions for those users.

> 📘 Enterprise plan
> As a part of the Buildkite SLA, customers on the [Enterprise](https://buildkite.com/pricing/) plan have an emergency email available for operational and security incidents. Contact your Customer Success Manager for more information.

If the affected user can help, ask them to log out and [reset their password](https://buildkite.com/forgot-password) to reset all active sessions. Verify that their account is secure before adding them back to your organization.

Password reset may not be available to SSO users who have no Buildkite password.

### Removing users from an organization with enabled SSO

Disable or remove the compromised account at your SSO provider as well as in Buildkite. Otherwise, an attacker with SSO access can log in again and create a new organization membership.

Rejoining does not restore revoked authorizations or authorize other existing sessions. However, a new SSO login can grant access under your organization's default SSO permissions.

If the attacker controls your SSO provider, changes in Buildkite alone cannot resolve the incident.

### Disabling and re-enabling SSO

The other control you have is the organization membership's SSO mode. If the membership requires SSO, the user will only have access to your organization in the particular sessions authenticated through your SSO provider.

> 🚧
> Before you proceed, make sure that you have at least one user with SSO as an optional log in requirement in your organization to make it possible for someone to log back in!

Disabling an SSO provider revokes its active SSO authorizations, including the administrator's. The administrator must log back in using a non-SSO method. After the provider is re-enabled, members required to use it must re-authorize.

You can [disable](/docs/platform/sso/sso-setup-with-graphql#disabling-an-sso-provider) and [re-enable](/docs/platform/sso/sso-setup-with-graphql#setting-up-saml-google-cloud-identity-okta-onelogin-adfs-and-others-step-4) the SSO using GraphQL or the Buildkite UI.

An attacker with an authenticated session may have created API tokens, which are not subject to SSO requirements. Resetting SSO authorizations is not a substitute for removing the compromised user from your Buildkite organization.
