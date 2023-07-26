# Controlling user permissions

Customers on the Buildkite [Business and Enterprise](https://buildkite.com/pricing) plans can manage permissions using [Teams](#permissions-with-teams). Enterprise customers can set fine-grained user permissions for their organization with the [member Permissions](#member-permissions) page.


## Permissions with teams

Enabling Teams for your organizations gives you control over each pipeline's permissions in one place. Teams can be enabled from your Organization Settings in the Teams section.

<%= image "enable-teams.png", width: 1645/2, height: 1566/2, alt: "Enabling Teams for an organization" %>

When you first enable Teams, a team is automatically created for your organization called “Everyone” that contains all users. This maintains existing access to pipelines for all the users in your organization.

You can see the teams that you're a member of on the Teams page in your Buildkite settings. From this page, you can add new teams or edit existing ones. By clicking on a team, you can view the members, pipelines, and team specific settings.

### Organization-level permissions

Users who are organization admins can:

* Enable and disable teams for their organization
* Create new teams

### Team-level permissions

Users who are team maintainers can:

* Add users to existing teams, of which they are the maintainer
* Remove users from their teams
* Set read, write, and edit permissions for users on pipelines in their team

All users in a team have the same level of access to the pipelines in their team. If you need to have more fine grained control over the pipelines in a team, you can create more teams with different permissions.

### Pipeline-level permissions

You can grant teams the following permissions on a pipeline:

* Full Access (`MANAGE_BUILD_AND_READ`):
  - Can view and create builds or rebuilds.
  - Can edit pipeline settings.
* Build & Read (`BUILD_AND_READ`):
  - Can view and create builds or rebuilds.
  - Can _not_ edit pipeline settings.
* Read Only (`READ_ONLY`):
  - Can view builds.
  - Can _not_ create builds or issue rebuilds.
  - Can _not_ edit pipeline settings.

### User-level permissions

Any user can create a new pipeline. If you have read, write, and edit permissions on a pipeline, you can also provide access to others. You can give access to a team that you're in, or a team that has been marked as 'visible'.

### Programmatically managing teams

You can programmatically manage your teams using our GraphQL API.
If you're creating pipelines programmatically using the REST API, you can add them directly to teams using the team's UUID. More information about creating pipelines can be found in our [REST API documentation](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline).

You can also restrict agents to specific teams with the `BUILDKITE_BUILD_CREATOR_TEAMS` environment variable. Using agent hooks, you can allow or disallow builds based on the creator's team memberships.

>🚧 Unverified commits
> Note that GitHub accepts <a href="https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification">unsigned commits</a>, including information about the commit author and passes them along to webhooks, so you should not rely on these for authentication unless you are confident that all of your commits are trusted.

For example, the following [`environment` hook](/docs/agent/v3/hooks#job-lifecycle-hooks)
prevents anyone from outside of the ops team from running a build on the agent:

```bash
set -euo pipefail

if [[ ":$BUILDKITE_BUILD_CREATOR_TEAMS:" != *":ops:"* ]]; then
  echo "You must be in the ops team to run a job on this agent"
  exit 1
fi
```

### Frequently asked questions

#### Will users (and API tokens) still have access to their pipelines?
When you enable Teams we'll create a default team called “Everyone”, containing all your users and pipelines. This ensures that users, and their API tokens, will still have access to their pipelines.

#### How does Teams work with SSO?
When a user joins the organization using SSO, they'll be automatically added to any teams that have the “Automatically add new users to this team” setting enabled.

#### Can I delete the “Everyone” team?
Yes, you can delete or edit the “Everyone” team. To ensure uninterrupted access to pipelines we recommend creating new teams before deleting the “Everyone” team.

#### Once enabled, can I disable Teams?
Yes, you can disable teams by deleting all your teams, and then selecting “Disable Teams”.

#### Can I automate the removal of users from Buildkite?
Yes, you can automatically remove users using the GraphQL API. You'll need a [GraphQL API token](https://buildkite.com/user/api-access-tokens) to do it.
You'll need to look up your organization's slug in the [Organization Settings](https://buildkite.com/organizations/-/settings) and check the name or email of the user you want to remove in the [team](https://buildkite.com/organizations/-/teams) that this user belongs to. Next, use the first query to get the user ID (make sure to replace `your-organization-slug` with your Buildkite organization's slug and `Jane Doe` with the name or email of the user you want to remove), and then run the RemoveOrganizationMember mutation with the user ID to remove the user:

```bash
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

```bash
mutation RemoveOrganizationMember {
  organizationMemberDelete(input: { id: "user-ID-you-copied-goes-here" }) {
    deletedOrganizationMemberID
  }
}
```

## Member permissions

Enterprise customers can control user permissions for selected pipeline actions. These permissions can be used both with or without Teams enabled.

User-level permissions are managed by organization administrators, and can be found in the Organization Settings under Member Permissions.

From the Member Permissions page, organization admins can toggle whether or not users can:

* Create new pipelines
* Delete pipelines
* Make an existing private pipeline public
* Create, edit, and delete notification services
* Create, edit, and delete agent registration tokens
* Stop (disconnect) agents

If your organization has teams enabled, the pipeline creation permissions are managed at a team level. Pipeline creation permission controls can be found on the Teams Settings page. Without teams enabled, the pipeline creation permission control can be found on the Member Permissions page.

Note:  The Team-Level permissions on a given pipeline, will override the lower priviledge member permisions in the team settings.

Organization admin can delete organization members. To delete organization members using GraphQL, the admin needs to:

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

2. Use the `id` from the previous query in a mutation:

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

## Removing users during a security incident

If you believe that a user account has been compromised, the recommended incident response is to remove such a user from your Buildkite organization immediately. This will entirely remove their ability to impact your organization and protect you from any further actions that the user could take.

You can remove a user in your organization's _Settings_ in the Buildkite UI.

<%= image "remove-user.png", width: 1572/2, height: 1302/2, alt: "A button to remove a user from an organization" %>

### Security guarantees of removing a user

When you remove a user from your organization, the active session tokens belonging to this user cannot make calls to the product that will return (or make changes to) any of the data available using the web UI, API, etc. So removing a compromised or rogue user is as effective as killing all sessions by the user.

Within Buildkite's access model, organizations don't own users, so they can't control users' sessions because users represent individuals who may be members of multiple organizations.

Removing a compromised user from your organization immediately protects all the organization's resources from that user. The user will technically still be able to view their personal settings page.

In case of a non-responsive or rogue user, or if multiple accounts are compromised, you can send a list of impacted user IDs to [support@buildkite.com](mailto:support@buildkite.com) and ask the Buildkite support to log out the specific user or all the users out of all sessions.

>📘 Enterprise plan
> As a part of the Buildkite SLA, customers on the Enterprise plan have an emergency email available for operational and security incidents. Contact your Customer Success Manager for more information.

If you suspect or have already detected a security breach, and the affected user is cooperative, they can also log out and [reset](https://buildkite.com/forgot-password) their password, which will automatically reset all of their active sessions. Then you can work with the affected user to ensure their account is safe and re-add them to your Buildkite organization.

Note that resetting a password might not always be an option. If you have SSO enabled for your organization, the user in question may not even have a dedicated password for their Buildkite account.

### Removing users from an organization with enabled SSO

If you're using SSO, you also need to protect against the attackers regaining organization membership by logging in again with SSO. This _will not_ renew the revoked authorizations and _does not_ authorize any other sessions that might still be active for the user, as a new organization member will be created. However, if the attacker has access to a Buildkite session, they may also have access to a regular session with the permissions granted for your SSO session defaults. So it is important to disable or remove such a compromised user account from your SSO.

If the attacker has control of the SSO, the scope of the security incident is beyond what could be remediated using Buildkite's tools only.

### Disabling and re-enabling SSO

The other control you have is the organization membership's SSO mode. If the membership requires SSO, the user will only have access to your organization in the particular sessions authenticated through your SSO provider.

>🚧
> Before you proceed, make sure that you have at least one user with SSO as an optional log in requirement in your organization to make it possible for someone to log back in!

Admins of your Buildkite organization can disable and then re-enable the SSO, which will force all users in your organization to re-authorize with SSO. When you disable an SSO provider, it rescinds all active SSO authorizations for all users _including the admin who disables the SSO_! The admin will need to log back into the organization by using a non-SSO method.

You can [disable](/docs/integrations/sso/sso-setup-with-graphql#disabling-an-sso-provider) and [re-enable](/docs/integrations/sso/sso-setup-with-graphql#setting-up-saml-google-cloud-identity-okta-onelogin-adfs-and-others-step-4) the SSO using GraphQL or the Buildkite UI.

Remember that if an attacker had a fully authenticated session, they've potentially configured API tokens, which will not be subject to SSO requirements. Therefore, the only truly safe response is still to remove the compromised user from your Buildkite organization.
