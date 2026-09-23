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

> 🚧 Cluster `token` field deprecation
> The `token` field of the [ClusterToken](/docs/apis/graphql/schemas/object/clustertoken) object has been deprecated to improve security. Please use the `tokenValue` field from the [ClusterAgentTokenCreatePayload](/docs/apis/graphql/schemas/object/clusteragenttokencreatepayload) object instead after creating a token.

## List cache registries

> 📘 Public preview
> The cache registries API is available to all Buildkite customers in public preview.

Get the first ten [cache registries](/docs/pipelines/configure/cache#manage-cache-registries) for a particular cluster, specifying the cluster's UUID as the `id` argument of the `cluster` query:

```graphql
query getCacheRegistries {
  organization(slug: "organization-slug") {
    id
    cluster(id: "cluster-uuid") {
      id
      cacheRegistries(first: 10) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          node {
            id
            uuid
            slug
            name
            description
          }
        }
      }
    }
  }
}
```

Results are ordered by slug. If `hasNextPage` is `true`, pass `endCursor` as the `after` argument to `cacheRegistries` to fetch the next page.

Listing and managing cache registries requires organization administrator or [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) permissions. Mutations also require a token with write access to the GraphQL API.

The query returns both Relay global IDs (`id`) and UUIDs (`uuid`). Use the organization, cluster, and registry `id` values in the mutations below, not their UUIDs or slugs. Unlike the mutations, `organization.cluster(id:)` takes the cluster UUID.

See the [CacheRegistry reference](/docs/apis/graphql/schemas/object/cacheregistry) for all available fields. This API manages registry metadata and policies, not cache entries or agent save and restore operations. Use the web interface to configure cache stores or select a cluster's default registry.

## Create agent token with an expiration date

Create an agent token with an expiration date. The expiration date is displayed in the Buildkite interface and cannot be changed using another Buildkite API call.

```graphql
mutation createToken {
  clusterAgentTokenCreate(input: {
    organizationId: "organization-id",
    description: "A token with an expiration date",
    clusterId:"cluster-id",
    expiresAt: "2026-01-01T00:00:00Z"
  }) {
    tokenValue
  }
}
```

## Revoke an agent token

First, get the agent token's ID from your [list of agent tokens](#list-agent-tokens), followed by your [Buildkite organization's ID](/docs/apis/graphql/cookbooks/organizations#get-organization-id). Then, use these ID values to revoke the agent token:

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

Create a new _self-hosted queue_ in a cluster, which are queues created for agents that you host yourself.

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

Learn more about how to create a Buildkite hosted queue in [Create a Buildkite hosted queue](/docs/apis/graphql/cookbooks/hosted-agents#create-a-buildkite-hosted-queue) of the [Hosted agents](/docs/apis/graphql/cookbooks/hosted-agents) page of this cookbook.

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

Learn more about how to update a Buildkite hosted queue's instance shape in [Change the instance shape of a Buildkite hosted queue's agents](/docs/apis/graphql/cookbooks/hosted-agents#change-the-instance-shape-of-a-buildkite-hosted-queues-agents) of the [Hosted agents](/docs/apis/graphql/cookbooks/hosted-agents) page of this cookbook.

## Delete a queue

Deletes an existing queue using the queue's ID.

```graphql
mutation {
  clusterQueueDelete(input: {
    organizationId: "organization-id",
    id: "queue-id"
  }) {
    deletedClusterQueueId
  }
}
```

## Create a cache registry

Create another [cache registry](/docs/pipelines/configure/cache#manage-cache-registries) in a cluster, specifying the cluster's ID as the `clusterId` argument:

```graphql
mutation createCacheRegistry {
  cacheRegistryCreate(input: {
    organizationId: "organization-id",
    clusterId: "cluster-id",
    name: "Build cache",
    description: "Compiler output cache"
  }) {
    cacheRegistry {
      id
      uuid
      slug
      name
      description
      cluster {
        id
        uuid
      }
    }
  }
}
```

New registries use agent-managed storage. The cache store can't be set through this API.

Set the `policy` argument to a JSON-encoded string of the structured policy document described in [Configure a cache policy](/docs/pipelines/configure/cache#configure-a-cache-policy). For example, add this argument to the create input to allow both saves and restores:

```graphql
policy: "{\"save\":{\"scopes\":{}},\"restore\":{\"scopes\":[{}]},\"rules\":[{\"effect\":\"allow\",\"action\":\"save\"},{\"effect\":\"allow\",\"action\":\"restore\"}]}"
```

The GraphQL `JSON` type accepts a JSON-encoded string, not an object literal or authored YAML. The API validates and normalizes the policy. The returned `policy` field is also a JSON-encoded string, with rule actions normalized to arrays.

When creating a registry, omit `policy` or set it to `null` to use the default unrestricted policy.

## Update a cache registry

Update an existing cache registry's attributes, specifying the registry's Relay global ID as the `id` argument. Omitted attributes are left unchanged:

```graphql
mutation updateCacheRegistry {
  cacheRegistryUpdate(input: {
    organizationId: "organization-id",
    id: "cache-registry-id",
    description: "Updated compiler output cache"
  }) {
    cacheRegistry {
      id
      uuid
      slug
      name
      description
    }
  }
}
```

Supplying `policy` replaces the entire policy rather than merging its nested properties. Set `policy` to `null` to clear it, which denies saves and restores. Unlike creation, updating with `null` doesn't apply the default unrestricted policy.

Changing `name` regenerates the registry's slug. Set `description`, `emoji`, or `color` to `null` to clear them. The registry's UUID and cache store can't be changed through this API.

## Delete a cache registry

Delete an existing cache registry using the registry's GraphQL ID:

```graphql
mutation deleteCacheRegistry {
  cacheRegistryDelete(input: {
    organizationId: "organization-id",
    id: "cache-registry-id"
  }) {
    deletedCacheRegistryId
  }
}
```

You can't delete a cluster's default cache registry. [Select another default registry](/docs/pipelines/configure/cache#manage-cache-registries) in the web interface first.

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
