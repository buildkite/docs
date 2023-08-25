# Clusters

A collection of common tasks with clusters using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

## List cluster IDs

Get the first 10 clusters and their information for an organization:

```graphql
query getClusters {
  organization(slug: "organization-slug") {
    clusters(first: 10){
      edges{
        node{
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

## List cluster queue IDs

Get the first 10 cluster queues for a particular cluster by specifying its UUID in `cluster-uuid`:

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

## List jobs in a particular cluster queue

To get jobs within a cluster queue, use the `clusterQueue` filter, passing in the ID of the cluster queue to filter jobs from:

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

To obtain jobs within a cluster queue of a particular state, use the `clusterQueue` filter, passing in the ID of the cluster queue to filter jobs from, and the `state` list filter by one or more [JobStates](https://buildkite.com/docs/apis/graphql/schemas/enum/jobstates):

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
