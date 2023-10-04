# Clusters

A collection of common tasks with clusters using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

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

## List cluster tokens

Get the first 10 cluster tokens for a particular cluster, specifying the clusters' UUID as the `id` argument of the `cluster` query:

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
> The `token` field of the [ClusterToken](https://buildkite.com/docs/apis/graphql/schemas/object/clustertoken) object has been deprecated to improve security. Please use the `tokenValue` field from the [ClusterAgentTokenCreatePayload](https://buildkite.com/docs/apis/graphql/schemas/object/clusteragenttokencreatepayload) object instead after creating a token.

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

To obtain jobs in a particular state within a cluster queue, specify the cluster queues' ID with the `clusterQueue` argument and one or more [JobStates](https://buildkite.com/docs/apis/graphql/schemas/enum/jobstates) with the `state` argument in the `jobs` query:

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
