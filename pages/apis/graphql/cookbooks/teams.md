# Teams

A collection of common tasks with teams using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

## Create a team

Create a new team.

First, get the organization ID:

```graphql
query getOrganizationId {
  organization(slug: "organization-slug") {
    id
  }
}
```

Then use the ID to create a new team within the organization:

```graphql
mutation CreateTeam {
  teamCreate(input: {
    organizationID: "organization-id",
    name: "team-name",
    privacy: SECRET,
    isDefaultTeam: false,
    defaultMemberRole: MEMBER
  }) {
    organization {
      uuid
      teams(first: 1, order: RECENTLY_CREATED) {
        count
        edges {
          node {
            name
          }
        }
      }
    }
  }
}
```

## Add an existing organization user to a team

Add an organization member to a team. This does not create a new user.

First, get a list of teams in the organization, to get the team ID:

```graphql
query getOrgTeams {
  organization(slug: "organization-slug") {
    teams(first: 500) {
      edges {
        node {
          name
          id
        }
      }
    }
  }
}
```

Then, add a team member. You can get the `user-id` using the example in [Search for organization members](/docs/apis/graphql/cookbooks/organizations#search-for-organization-members).

>📘
> <code>clientMutationId</code> is null when the mutation is successful.


```graphql
mutation addTeamMember{
  teamMemberCreate(input: {teamID: "team-id", userID: "user-id"}) {
    clientMutationId
  }
}
```

## Remove a team member

This deletes a user from a team, but not from the organization.

First, get a list of teams and members, to get the team IDs and current memberships:

```graphql
query TeamMembersQuery {
  organization(slug: "organization-slug") {
    teams(first: 500) {
      edges {
        node {
          name
          id
          members(first: 100) {
            edges {
              node {
                role
                id
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
    }
  }
}
```

Then delete a team member. Check that you have the team member ID and not the user ID:

>📘
> <code>clientMutationId</code> is null when the mutation is successful.

```graphql
mutation deleteTeamMember {
  teamMemberDelete(input: {id: "team-member-id"}) {
    clientMutationId
  }
}
```

## Get pipelines by team

To get the first 100 pipelines managed by the first 100 teams, use the following query.

```graphql
query getPipelinesByTeam {
  organization(slug: "organization-slug") {
    id
    name
    teams(first: 100) {
      pageInfo {
        hasNextPage
        endCursor
      }
      edges {
        node {
          name
          pipelines(first: 100) {
            pageInfo {
              hasNextPage
              endCursor
            }
            edges {
              node {
                pipeline {
                  name
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

If you have more than 100 teams or more than 100 pipelines per team, use the pagination information in `pageInfo` to get the next results page.

## Get members from a specific team

This query will display members of a team with their roles.

```graphql
query GetTeamMember {
  organization(slug:"organization-slug") {
    teams(first:1, search:"team-slug") {
      edges {
        node {
          members(first:200) {
            edges {
              node {
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
    }
  }
}
```

## Set teams' pipeline edit access to READ_ONLY or BUILD_AND_READ

Remove edit access from existing teams. This is helpful when you want to centralize pipeline edit permissions to a single system user, controlled by an organization admin.

First, walk through all teams:

```graphql
query Teams {
  organization(slug: "organization-slug") {
    teams(first: 500) {
      edges {
        node {
          slug
        }
      }
    }
  }
}
```

Then, get the team pipeline IDs from the team slugs. Use the `id` returned here as the `team-pipeline-id` in the next step.

```graphql
query TeamPipelineIDs {
  team(slug: "organization-slug/team-slug") {
    pipelines(first: 500) {
      edges {
        node {
          id
        }
      }
    }
  }
}
```

Finally, update all pipelines in a team to have either READ_ONLY or BUILD_AND_READ access:

```graphql
mutation UpdateTeamPipelineReadonly {
  teamPipelineUpdate(input: {
    id: "team-pipeline-id",
    accessLevel: BUILD_AND_READ
  }) {
    teamPipeline {
      permissions {
        teamPipelineDelete {
          allowed
          code
          message
        }
        teamPipelineUpdate {
          allowed
          code
          message
        }
      }
    }
    clientMutationId
  }
}
```
