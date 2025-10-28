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

## List queues

Get the first 10 cluster queues for a particular cluster, specifying the clusters' UUID as the `id` argument of the `cluster` query:

```graphql
query getQueues {
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
query getAgentTokens {
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

## Create a self-hosted queue

Create a new self-hosted queue in a cluster. These queues are created for agents that you host yourself.

```graphql
mutation {
  clusterQueueCreate(input: {
    organizationId: "organization-id",
    clusterId: "cluster-id",
    key: "default",
    description: "The default queue for this cluster."
  }) {
    clusterQueue {
      id
      uuid
      key
      description
      hosted
      createdBy {
        id
        uuid
        name
      }
      cluster {
        id
        uuid
        name
      }
    }
  }
}
```

## Create a Buildkite hosted queue

Create a new Buildkite hosted queue in a cluster. These queues are created within Buildkite hosted agents.

```graphql
mutation {
  clusterQueueCreate(input: {
    organizationId: "organization-id",
    clusterId: "cluster-id",
    key: "default",
    description: "The default queue for this cluster.",
    hostedAgents: {
      instanceShape: MACOS_ARM64_M4_6X28
    }
  }) {
    clusterQueue {
      id
      uuid
      key
      description
      hosted
      hostedAgents {
        instanceShape {
          name
          size
          vcpu
          memory
        }
      createdBy {
        id
        uuid
        name
      }
      cluster {
        id
        uuid
        name
      }
    }
  }
}
```

## Update a queue

Update an existing queue.

```graphql
mutation {
  clusterQueueUpdate(input: {
    organizationId: "organization-id",
    id: "cluster-id",
    description: "The default queue for this cluster, but this time with a modified description.",
  }) {
    clusterQueue {
      id
      uuid
      key
      description
      hosted
      createdBy {
        id
        uuid
        name
      }
      cluster {
        id
        uuid
        name
      }
    }
  }
}
```

## Delete a queue

Deletes an existing queue using the queue's ID.

```graphql
mutation {
  clusterQueueDelete(input: {
    organizationId: "organization-id",
    id: ""
  }) {
    deletedClusterQueueId
  }
}
```

## List jobs in a particular queue

To get jobs within a particular queue of a cluster, use the `clusterQueue` argument of the `jobs` query, passing in the ID of the queue to filter jobs from:

```graphql
query getQueueJobs {
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

To obtain jobs in specific states within a particular queue of a cluster, specify the queues' ID with the `clusterQueue` argument and one or more [JobStates](/docs/apis/graphql/schemas/enum/jobstates) with the `state` argument in the `jobs` query:

```graphql
query getQueueJobsByJobState {
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
query getClusterAgents {
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

## List agents in a queue

Get the first 10 agents in a particular queue of a cluster, specifying the `clusterQueue` argument of the `agents` query, passing in the ID of the cluster queue:

```graphql
query getQueueAgents {
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
