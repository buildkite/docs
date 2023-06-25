# GraphQL API cookbook

This page provides recipes for common API tasks. You can test out the Buildkite API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

>📘 Suggest recipes
> Want to suggest a recipe? We welcome pull requests to the [docs repo](https://github.com/buildkite/docs).

## Pipelines

A collection of common tasks with pipelines using the GraphQL API.

### Create a pipeline

Create a pipeline programmatically.

First, get the organization ID and team ID:

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

Then, create the pipeline:

```graphql
mutation createPipeline {
  pipelineCreate(input: {
    organizationId: "organization-id"
    name: "pipeline-name",
    repository: {url: "repo-url"},
    steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" },
    teams: { id: "team-id" }
  }) {
    pipeline {
      id
      name
      teams(first: 10) {
        edges {
          node {
            id
          }
        }
      }
    }
  }
}
```

>📘
When setting pipeline steps using the API, you must pass in a string that Buildkite parses as valid YAML, escaping quotes and line breaks.
> To avoid writing an entire YAML file in a single string, you can place a <code>pipeline.yml</code> file in a <code>.buildkite</code> directory at the root of your repo, and use the <code>pipeline upload</code> command in your pipeline steps to tell Buildkite where to find it. This means you only need the following:
> <code>
steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" }
</code>

### Get a list of recently created pipelines

Get a list of the 500 most recently created pipelines.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      edges {
        node {
          slug
        }
      }
    }
  }
}
```

### Get pipeline metrics

The _Pipelines_ page in Buildkite shows speed, reliability, and builds per week, for each pipeline. You can also access this information through the API.

```graphql
query AllPipelineMetrics {
  organization(slug: "organization-slug") {
    name
    pipelines(first: 50) {
      edges {
        node {
          name
          metrics {
            edges {
              node {
                label
                value
              }
            }
          }
        }
      }
    }
  }
}
```

### Delete a pipeline

First, get the ID of the pipeline you want to delete:

```graphql
query {
  pipeline(slug:"organization-slug/pipeline-slug") {
    id
  }
}
```

Then, use the ID to delete the pipeline:

```graphql
mutation PipelineDelete {
  pipelineDelete(input: {
    id: "pipeline-id"
  })
  {
    deletedPipelineID
  }
}
```

## Builds

A collection of common tasks with builds using the GraphQL API.

### Get build info by ID

Get all the available info from a build while only having its UUID.

```
query GetBuilds {
  build(uuid: "a00000a-xxxx-xxxx-xxxx-a000000000a") {
    id
    number
    url
  }
}
```

### Get all environment variables set on a build

Retrieve all of a job's environment variables for a given build. This is the equivalent of what you see in the _Environment_ tab of each build.

```graphql
query GetEnvVarsBuild {
  build(slug:"organization-slug/pipeline-slug/build-number") {
    message
    jobs(first: 10, state:FINISHED) {
      edges {
        node {
          ... on JobTypeCommand {
            label
            env
          }
        }
      }
    }
  }
}
```

### Get all builds for a pipeline

Retrieve all of the builds for a given pipeline, including each build's ID, number, and URL.

```graphql
query GetBuilds {
  pipeline(slug: "organization-slug/pipeline-slug") {
    builds(first: 10) {
      edges {
        node {
          id
          number
          url
        }
      }
    }
  }
}
```

### Get the creation date of the most recent build in every pipeline

Get the creation date of the most recent build in every pipeline. Use pagination to handle large responses. Buildkite sorts builds by newest first.

Get the first 500:

```graphql
query {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      count
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        node {
          name
          slug
          builds(first: 1) {
            edges {
              node {
                createdAt
              }
            }
          }
        }
      }
    }
  }
}
```

Then, if there are more than 500 results, use the value of `organization.pipelines.pageInfo.endCursor` to get the next page:

```graphql
query {
  organization(slug: "organization-slug") {
    pipelines(first: 500, after: "value-from-organization.pipelines.pageInfo.endCursor") {
      count
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        node {
          name
          slug
          builds(first: 1) {
            edges {
              node {
                createdAt
              }
            }
          }
        }
      }
    }
  }
}
```

### Get number of builds between two dates

This query helps you understand how many job minutes you've used by looking at the number of builds. While not equivalent, there's a correlation between the number of builds and job minutes. So, looking at the number of builds in different periods gives you an idea of how the job minutes would compare in those periods.

```graphql
query PipelineBuildCountForPeriod {
  pipeline(slug: "organization-slug") {
    builds(createdAtFrom:"YYYY-MM-DD", createdAtTo:"YYYY-MM-DD") {
      count
      edges{
        node{
          createdAt
          finishedAt
          id
        }
      }
    }
  }
}
```

### Count the number of builds on a branch

Count how many builds a pipeline has done for a given repository branch.

```graphql
query PipelineBuildCountForBranchQuery {
  pipeline(slug:"organization-slug/pipeline-slug") {
    builds(branch:"branch-name") {
      count
    }
  }
}
```

You can limit the results to a certain timeframe using `createdAtFrom` or `createdAtTo`.

```graphql
query PipelineBuildCountForBranchQuery {
  pipeline(slug:"organization-slug/pipeline-slug") {
    builds(branch:"branch-name", createdAtTo:"DateTime") {
      count
    }
  }
}
```

### Increase the next build number

Set the number for the next build to run in this pipeline.

First, get the pipeline ID:

```graphql
query PipelineId {
  pipeline(slug: "organization-slug/pipeline-slug") {
    id
  }
}
```

Then mutate the next build number. In this example, we set `nextBuildNumber` to 300:

```graphql
mutation PipelineUpdate {
  pipelineUpdate(input: {
  id: "pipeline-id",
  nextBuildNumber: 300
  }) {
    pipeline {
      name 
      nextBuildNumber
    }
  }
}
```

### Get the total build run time

To get the total run time for a build, you can use the following query.

```
query GetTotalBuildRunTime{
  build(slug: "organization-slug/pipeline-slug/build-number") {
    pipeline {
      name
    }
    url
    startedAt
    finishedAt
  }
}
```

## Jobs

A collection of common tasks with jobs using the GraphQL API.

### Get all jobs in a given queue for a given timeframe

Get all jobs in a named queue, created on or after a given date. Note that if you want all jobs in the default queue, you do not need to set a queue name, so you can omit the `agentQueryRules` option.


```graphql
query PipelineRecentBuildLastJobQueue {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      edges {
        node {
          slug
          builds(first: 1) {
            edges {
              node {
                number
                jobs(state: FINISHED, first: 1, agentQueryRules: "queue=queue-name") {
                  edges {
                    node {
                      ... on JobTypeCommand {
                        uuid
                        agentQueryRules
                        createdAt
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

### Get all jobs in a particular concurrency group

To see which jobs are waiting for a concurrency group in case the secret URL fails, you can use the following query.

```
query getConcurrency {
  organization(slug: "{org}") {
    jobs(first:100,concurrency:{group:"name"}, type:[COMMAND], state:[LIMITED,WAITING,ASSIGNED]) {
      edges {
        node {
          ... on JobTypeCommand {
            url
            createdAt
          }
        }
      }
    }
  }
}
```
### Get the last job of an agent

To get the last job of an agent or `null`. You will need to know the UUID of the agent.

```
query AgentJobs {
  agent(slug: "organization-slug/agent-UUID") {
    jobs(first: 10) {
      edges {
        node {
          ... on JobTypeCommand {
            state
            build {
              state
            }
          }
        }
      }
    }
  }
}
```

### Get the job run time per build

To get the run time of each job in a build, you can use the following query.

```
query GetJobRunTimeByBuild{
  build(slug: "organization-slug/pipeline-slug/build-number") {
    jobs(first: 1) {
      edges {
        node {
          ... on JobTypeCommand {
            startedAt
            finishedAt
          }
        }
      }
    }
  }
}
```

## Agents

A collection of common tasks with agents using the GraphQL API.

### Get a list of agent token IDs

Get the first five agent token IDs for an organization.

```graphql
query token {
  organization(slug: "organization-slug") {
    id
    name
    agentTokens(first: 5) {
      edges {
        node {
          id
          description
        }
      }
    }
  }
}
```

### Search for agents in an organization

```graphql
query SearchAgent {
   organization(slug:"organization-slug") {
    agents(first:500, search:"search-string") {
      edges {
        node {
          name
          hostname
          version
        }
      }
    }
  }
}
```

### Revoke an agent token

Revoking an agent token means no new agents can start using the token. It does not affect any connected agents.

First, get the token ID. You can find it in the Buildkite dashboard, in _Agents_ > _Reveal Agent Token_, or you can retrieve a list of agent token IDs using this query:

```graphql
query GetAgentTokenID {
  organization(slug: "organization-slug") {
    agentTokens(first:50) {
      edges {
        node {
          id
          uuid
          description
        }
      }
    }
  }
}
```

Then, using the token ID, revoke the agent token:

```graphql
mutation {
  agentTokenRevoke(input: {
    id: "token-id",
    reason: "A reason"
  }) {
    agentToken {
      description
      revokedAt
      revokedReason
    }
  }
}
```

## Clusters

A collection of common tasks with clusters using the GraphQL API.

### List cluster queues

For the first 10 clusters in an organization, list the key and ID of the first 20 cluster queues.

```graphql
query getClusterQueues {
  organization(slug: "organization-slug") {
    clusters(first:10){
      edges{
        node{
          name
          queues(first:20){
            edges{
              node{
                key
                id
              }
            }
          }
        }
      }
    }
  }
}
```

### List jobs in a cluster queue

List the first 20 jobs as part of a cluster queue in the `RUNNING` [job state](/docs/apis/graphql/schemas/enum/jobstates).

```graphql
query getClusterQueueJobs {
  organization(slug:"organization-slug"){
    jobs(first: 20, clusterQueue:"cluster-queue-id", state:[RUNNING]) {
  	  edges{
        node{
          ... on JobTypeCommand{
            state
            uuid
            build{
              id
              number
              pipeline{
                name
              }
            }
          }  
        }
      }
    }
  }
}
```

## Organizations

A collection of common tasks with organizations using the GraphQL API.

### List organization members

List the first 100 members in the organization.

```graphql
query getOrgMembers{
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

### Search for organization members

Look up organization members using their email address.

```graphql
query getOrgMember{
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

### Get the most recent SSO sign-in for all users

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

### Update the default SSO provider session duration

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

### Pin SSO sessions to IP addresses

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

### Create a user, add them to a team, and set user permissions

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



### Delete an organization member

This deletes a member from an organization. It does not delete their Buildkite user account.

First, find the member's ID:

```graphql
query {
  organization(slug: "organization-slug") {
    members(search: "organization-member-name", first: 10) {
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
```

Then, use the ID to delete the user:

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

## Teams

A collection of common tasks with teams using the GraphQL API.

### Create a team

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

### Add an existing organization user to a team

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

Then, add a team member. You can get the `user-id` using the example in [Search for organization members](#organizations-search-for-organization-members).

>📘
> <code>clientMutationId</code> is null when the mutation is successful.


```graphql
mutation addTeamMember{
  teamMemberCreate(input: {teamID: "team-id", userID: "user-id"}) {
    clientMutationId
  }
}
```

### Remove a team member

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

### Get pipelines by team

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

### Set teams' pipeline edit access to READ_ONLY or BUILD_AND_READ

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
