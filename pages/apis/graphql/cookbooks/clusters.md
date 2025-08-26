# Clusters

A collection of common tasks with clusters using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## List clusters

Get the first 10 clusters and their information for an organization:

```graphql
query getClusters {
  organization(slug: "organization-slug") {
    clusters(first: 10) {
      edges {
        node {
          id
          uuid
          color
          description
        }
      }
    }
  }
}
```

## List cluster queues

Get the first 10 cluster queues for a particular cluster, specifying the clusters' UUID as the `id` argument of the `cluster` query:

```graphql
query getClusterQueues {
  organization(slug: "organization-slug") {
    cluster(id: "cluster-uuid") {
      queues(first: 10) {
        edges {
          node {
            id
            uuid
            key
            description
          }
        }
      }
    }
  }
}
```

## List agent tokens

Get the first 10 agent tokens for a particular cluster, specifying the clusters' UUID as the `id` argument of the `cluster` query:

```graphql
query getClusterTokens {
  organization(slug: "organization-slug") {
    cluster(id: "cluster-uuid") {
      agentTokens(first: 10){
        edges{
          node{
            id
            uuid
            description
            allowedIpAddresses
          }
        }
      }
    }
  }
}
```

>🚧 Cluster `token` field deprecation
> The `token` field of the [ClusterToken](/docs/apis/graphql/schemas/object/clustertoken) object has been deprecated to improve security. Please use the `tokenValue` field from the [ClusterAgentTokenCreatePayload](/docs/apis/graphql/schemas/object/clusteragenttokencreatepayload) object instead after creating a token.

## Create agent token with an expiration date

Create an agent token with an expiration date. The expiration date is displayed in the Buildkite interface and cannot be changed using another Buildkite API call.

```graphql
mutation createToken {
  clusterAgentTokenCreate(input: {
    organizationId: "",
    description: "A token with an expiration date",
    clusterId:"",
    expiresAt: "2026-01-01T00:00:00Z"
  }) {
    tokenValue
  }
}
```

## Revoke an agent token

First, get the agent token's ID from your [list of agent tokens](#list-agent-tokens), followed by your [Buildkite organization's ID](/docs/apis/graphql/cookbooks/organizations#get-organization-id).
Then, use these ID values to revoke the agent token:

```graphql
mutation revokeClusterAgentToken {
  clusterAgentTokenRevoke(input: {
    id: "agent-token-id"
    organizationId: "organization-id"
    }) {
    clientMutationId
    deletedClusterAgentTokenId
  }
}
```

## List jobs in a particular cluster queue

To get jobs within a cluster queue, use the `clusterQueue` argument of the `jobs` query, passing in the ID of the cluster queue to filter jobs from:

```graphql
query getClusterQueueJobs {
  organization(slug: "organization-slug") {
    jobs(first: 10, clusterQueue: "cluster-queue-id") {
      edges {
        node {
          ... on JobTypeCommand {
            id
            state
            label
            url
            build {
              number
            }
            pipeline {
              name
            }
          }
        }
      }
    }
  }
}
```

To obtain jobs in a particular state within a cluster queue, specify the cluster queues' ID with the `clusterQueue` argument and one or more [JobStates](/docs/apis/graphql/schemas/enum/jobstates) with the `state` argument in the `jobs` query:

```graphql
query getClusterQueueJobsByJobState {
  organization(slug: "organization-slug") {
    jobs(
      first: 10,
      clusterQueue: "cluster-queue-id",
      state: [WAITING, BLOCKED]
    ){
      edges {
        node {
          ... on JobTypeCommand {
            id
            state
            label
            url
            build {
              number
            }
            pipeline {
              name
            }
          }
        }
      }
    }
  }
}
```


## List agents in a cluster

Get the first 10 agents within a cluster, use the `cluster` argument of the `agents` query, passing in the ID of the cluster:

```graphql
query getClusterAgent {
   organization(slug:"organization-slug") {
    agents(first: 10, cluster: "cluster-id") {
      edges {
        node {
          name
          hostname
          version
          clusterQueue{
            uuid
            id
          }
        }
      }
    }
  }
}
```

## List agents in a cluster queue

Get the first 10 agents in a particular cluster queue, specifying the `clusterQueue` argument of the `agents` query, passing in the ID of the cluster queue:

```graphql
query getClusterQueueAgent {
   organization(slug:"organization-slug") {
    agents(first: 10, clusterQueue: "cluster-queue-id") {
      edges {
        node {
          name
          hostname
          version
          id
          clusterQueue{
            id
            uuid
          }
        }
      }
    }
  }
}
```

## Associate a pipeline with a cluster

First, [get the Cluster ID](#list-clusters) you want to associate the Pipeline with.
Second, [get the Pipeline's ID](/docs/apis/graphql/cookbooks/pipelines#get-a-pipelines-id).
Then, use the IDs to archive the pipelines:

```graphql
mutation AssociatePipelineWithCluster {
  pipelineUpdate(input:{id: "pipeline-id" clusterId: "cluster-id"}) {
    pipeline {
      cluster {
        name
        id
      }
    }
  }
}
```

