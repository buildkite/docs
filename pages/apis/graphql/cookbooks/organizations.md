# Organizations

A collection of common tasks with Buildkite organizations using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Get organization ID

Knowing the ID of a Buildkite organization is a prerequisite for running many other GraphQL queries. Use this query to get the ID of an organization based on the organization's slug.

```graphql
query getOrganizationID {
  organization(slug:"organization-slug") {
    id
  }
}
```

## List organization members

List the first 100 members in the organization.

```graphql
query getOrgMembers {
  organization(slug: "organization-slug") {
    members(first: 100) {
      edges {
        node {
          role
          user {
            name
            email
            id
          }
        }
      }
    }
  }
}
```

## Get the number of organization members

Get the total number of members in the organization. Regardless of the value you enter for `members` in the query, the output of the query will provide the actual number of members in the organization.

```graphql
query getOrgMembersCount {
  organization(slug: "org-slug") {
    members(first:1) {
      count
    }
  }
}
```

## Search for organization members

Look up organization members using their email address.

```graphql
query getOrgMember {
  organization(slug: "organization-slug") {
    members(first: 1, search: "user-email") {
      edges {
        node {
          role
          user {
            name
            email
            id
          }
        }
      }
    }
  }
}
```

## Get the most recent SSO sign-in for all users

Use this to get the last sign-in date for users in your organization, if your organization has SSO enabled.

```graphql
query getRecentSignOn {
  organization(slug: "organization-slug") {
    members(first: 100) {
      edges {
        node {
          user {
            name
            email
          }
          sso {
            authorizations(first: 1) {
              edges {
                node {
                  createdAt
                  expiredAt
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Update the default SSO provider session duration

You can control how long the session can go before the user must revalidate with your SSO. By default that's indefinite, but you can reduce it down to hours or days.

```graphql
mutation UpdateSessionDuration {
  ssoProviderUpdate(input: { id: "ID", sessionDurationInHours: 2 }) {
    ssoProvider {
      sessionDurationInHours
    }
  }
}
```

## Update inactive API token revocation

On the Enterprise plan, you can control when inactive API tokens are revoked. By default, they are never (`NEVER`) revoked, but you can set your token revocation to either 30, 60, 90, 180, or 365 days.

```graphql
mutation UpdateRevokeInactiveTokenPeriod {
  organizationRevokeInactiveTokensAfterUpdate(input: {
    organizationId: "organization-id",
    revokeInactiveTokensAfter: DAYS_30
  }) {
    organization {
      revokeInactiveTokensAfter
    }
  }
}
```

## Pin SSO sessions to IP addresses

You can require users to re-authenticate with your SSO provider when their IP address changes with the following call, replacing `ID` with the GraphQL ID of the SSO provider:

```graphql
mutation UpdateSessionIPAddressPinning {
  ssoProviderUpdate(input: { id: "ID", pinSessionToIpAddress: true }) {
    ssoProvider {
      pinSessionToIpAddress
    }
  }
}
```

## Enforce two-factor authentication (2FA) for your organization

Require users to have two-factor authentication enabled before they can access your organization's Buildkite dashboard.

```graphql
mutation EnableEnforced2FA {
  organizationEnforceTwoFactorAuthenticationForMembersUpdate(
    input: {
      organizationId: "organization-id",
      membersRequireTwoFactorAuthentication: true
    }
  ) {
    organization {
      id
      membersRequireTwoFactorAuthentication
      uuid
    }
  }
}
```

## Create a user, add them to a team, and set user permissions

Invite a new user to the organization, add them to a team, and set their role.

First, get the organization and team ID:

```graphql
query getOrganizationAndTeamId {
  organization(slug: "organization-slug") {
    id
    teams(first:500) {
      edges {
        node {
          id
          slug
        }
      }
    }
  }
}
```

Then invite the user and add them to a team, setting their role to 'maintainer':

```graphql
mutation CreateUser {
  organizationInvitationCreate(input: {
    organizationID: "organization-id",
    emails: ["user-email"],
    role: MEMBER,
    teams: [
      {
        id: "team-id",
        role: MAINTAINER
      }
    ]
  }) {
    invitationEdges {
      node {
        email
        createdAt
      }
    }
  }
}
```

## Get the creation timestamp for an organization member

Use this to find out when the user was added to the organization.

```graphql
query getOrganizationMemberCreation {
  organization(slug: "organization-slug") {
    id
    members(search: "organization-member-name", first: 10) {
      edges {
        node {
          id
          createdAt
          user {
            id
            name
            email
          }
        }
      }
    }
  }
}
```

## Update an organization member's role

This updates an organization member's role to either `USER` or `ADMIN`.

First, find the organization member's ID (`organization-member-id`) using their email address, noting that this ID value is not the same as the user's ID (`user-id`).

```graphql
query getOrgMemberID{
  organization(slug: "organization-slug") {
    members(first: 1, search: "user-email") {
      edges {
        node {
          role
          user {
            name
            email
            id
          }
        }
      }
    }
  }
}
```

Then, use this `organization-member-id` value (retrieved from the query above) to update the organization member's role.

```graphql
mutation UpdateOrgMemberRole {
  organizationMemberUpdate (input:
    {id:"organization-member-id", role:ADMIN}) {
    organizationMember {
      id
      role
      user {
        name
      }
    }
  }
}
```

## Delete an organization member

This deletes a member from an organization. This action does not delete their Buildkite user account.

First, find the organization member's ID (`organization-member-id`) using their email address, noting that this ID value is not the same as the user's ID (`user-id`).

```graphql
query getOrgMemberID{
  organization(slug: "organization-slug") {
    members(first: 1, search: "user-email") {
      edges {
        node {
          id
          role
          user {
            name
            email
          }
        }
      }
    }
  }
}
```

Then, use this `organization-member-id` value (retrieved from the query above) to delete the user from the organization.

```graphql
mutation deleteOrgMember {
  organizationMemberDelete(input: { id: "organization-member-id" }){
    organization{
      name
    }
    deletedOrganizationMemberID
    user{
      name
    }
  }
}
```

## Get organization audit events

Query your organization's audit events. Audit events are only available to Enterprise customers.

```graphql
query getOrganizationAuditEvents {
  organization(slug:"organization-slug"){
    auditEvents(first: 500){
      edges{
        node{
          type
          occurredAt
          actor{
            name
          }
          subject{
            name
            type
          }
        }
      }
    }
  }
}
```

To get all audit events in a given period, use the `occurredAtFrom` and `occurredAtTo` filters like in the following query:

```graphql
query getTimeScopedOrganizationAuditEvents {
  organization(slug:"organization-slug"){
    auditEvents(first: 500, occurredAtFrom: "2023-01-01T12:00:00.000", occurredAtTo: "2023-01-01T13:00:00.000"){
      edges{
        node{
          type
          occurredAt
          actor{
            name
          }
          subject{
            name
            type
          }
        }
      }
    }
  }
}
```

## Get organization audit events of a specific user

Query audit events from within an organization of a specific user. Audit events are only available to Enterprise customers.

```graphql
query getActorRefinedOrganizationAuditEvents {
  organization(slug:"organization-slug"){
    auditEvents(first: 500, actor: "user-id"){
      edges{
        node{
          type
          occurredAt
          actor{
            name
          }
          subject{
            name
            type
          }
        }
      }
    }
  }
}
```

To find the actor's `user-id` for the query above, the following query can be run: replacing the `search` term with the name/email of the user:

```graphql
query getActorID {
  organization(slug:"organization-slug"){
    members(first:50, search: "search term"){
      edges{
        node{
          user{
            name
            email
            id
          }
        }
      }
    }
  }
}
```

## Create & delete system banners (enterprise only)

Create & delete system banners via the `organizationBannerUpsert` & `organizationBannerDelete` mutations.

To create a banner call `organizationBannerUpsert` with the organization's GraphQL id and message.

```graphql
mutation OrganizationBannerUpsert {
  organizationBannerUpsert(input: {
    organizationId: "organization-id",
    message: "**Change to 2FA**: On October 1st ECommerce Inc will require 2FA to be set to access all Pipelines. \r\n\r\n---\r\n\r\nIf you have not set already setup 2FA please go to: [https://buildkite.com/user/two-factor](https://buildkite.com/user/two-factor) and setup 2FA now. ",
  }) {
    clientMutationId
    banner {
      id
      message
      uuid
    }
  }
}
```

To remove the banner call `organizationBannerDelete` with the organization's GraphQL id.

```graphql
mutation OrganizationBannerDelete {
  organizationBannerDelete(input: {
    organizationId: "organization-id"
  }) {
    deletedBannerId
  }
}
```

