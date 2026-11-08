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

Get the first ten agent tokens and their scopes for a particular cluster, specifying the cluster's UUID as the `id` argument of the `cluster` query:

```graphql
query getAgentTokens {
  organization(slug: "organization-slug") {
    id
    cluster(id: "cluster-uuid") {
      id
      agentTokens(first: 10) {
        edges {
          node {
            id
            uuid
            description
            allowedIpAddresses
            permissions
            allowAllQueues
            allowedQueueIds
          }
        }
      }
    }
  }
}
```

Use a personal [API access token](/docs/apis/managing-api-tokens) with the `graphql` scope, shown as **Enable GraphQL API Access**. Listing agent tokens requires the `see_cluster_tokens` permission for the cluster. Creating or updating tokens requires `manage_cluster`; creation also requires `see_cluster_tokens`.

The agent token mutations below use [GraphQL global IDs](/docs/apis/graphql-api#graphql-ids) for the organization, cluster, token, and queues. Use the returned `id` values, not REST UUIDs. The `allowedQueueIds` field contains global IDs for `ClusterQueue` objects. Get queue IDs using [List queues](#list-queues).

> 🚧 Cluster `token` field deprecation
> The `token` field of the [ClusterToken](/docs/apis/graphql/schemas/object/clustertoken) object has been deprecated to improve security. Please use the `tokenValue` field from the [ClusterAgentTokenCreatePayload](/docs/apis/graphql/schemas/object/clusteragenttokencreatepayload) object instead after creating a token.

## List cache registries

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

Listing and managing cache registries requires organization administrator or [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster) permissions. Use an API access token with the **Enable GraphQL API Access** permission selected.

The query returns both Relay global IDs (`id`) and UUIDs (`uuid`). Use the organization, cluster, and registry `id` values in the mutations below, not their UUIDs or slugs. Unlike the mutations, `organization.cluster(id:)` takes the cluster UUID.

This API manages registry metadata and policies, not cache entries or agent save and restore operations. Use the web interface to configure cache stores. To select a cluster's default registry, use the web interface or the REST API's [Update a cluster](/docs/apis/rest-api/clusters#clusters-update-a-cluster) endpoint.

## Create agent token with an expiration date

Create an agent token with an expiration date. The expiration date is displayed in the Buildkite interface and cannot be changed using another Buildkite API call.

```graphql
mutation createToken {
  clusterAgentTokenCreate(input: {
    organizationId: "organization-id",
    description: "A token with an expiration date",
    clusterId:"cluster-id",
    expiresAt: "2030-01-01T00:00:00Z"
  }) {
    tokenValue
    clusterAgentToken {
      id
      permissions
      allowAllQueues
      allowedQueueIds
    }
  }
}
```

Omitting `permissions` grants all current Agent API permissions. Omitting both queue fields allows all queues in the cluster. Copy `tokenValue` to secure storage immediately; the API returns this secret only when creating the token.

## Create a scoped agent token

Create a token that allows agents to run jobs, access code repositories through the Agent API, and write build metadata on a selected queue:

```graphql
mutation createScopedAgentToken {
  clusterAgentTokenCreate(input: {
    organizationId: "organization-id",
    clusterId: "cluster-id",
    description: "Windows agents",
    allowedIpAddresses: "192.0.2.0/24",
    permissions: ["run_jobs", "code_repository_access", "write_build_metadata"],
    allowAllQueues: false,
    allowedQueueIds: ["queue-id"]
  }) {
    tokenValue
    clusterAgentToken {
      id
      description
      allowedIpAddresses
      permissions
      allowAllQueues
      allowedQueueIds
    }
  }
}
```

Copy `tokenValue` to secure storage immediately. Subsequent queries and updates do not return the secret.

Each permission grants only its own actions; `run_jobs` does not grant the other permissions. See [Scoped agent tokens](/docs/agent/self-hosted/scoped-agent-tokens) and the [available permissions](/docs/agent/self-hosted/scoped-agent-tokens#available-permissions) to select the actions your agents need.

- Omit `permissions` to grant all current permissions. An explicit array grants only the supplied permissions, with duplicates removed. An empty array grants no permission-controlled actions.
- Omit both queue fields to allow all queues. With `allowAllQueues: false`, supply `allowedQueueIds` containing queues from the same cluster. An empty array then denies all queues.
- With `allowAllQueues: true`, `allowedQueueIds` must be empty.

Unknown permission names, including `read_pipelines` and `modify_steps`, and `null` permissions are rejected. Invalid permission or queue settings reject the mutation without changing the token. Check the response's `errors` array even when the HTTP status is `200 OK`.

## Update a scoped agent token

Use the token's global ID from [List agent tokens](#list-agent-tokens) to replace its permissions and allowed queues:

```graphql
mutation updateScopedAgentToken {
  clusterAgentTokenUpdate(input: {
    organizationId: "organization-id",
    id: "agent-token-id",
    description: "Windows build agents",
    allowedIpAddresses: "192.0.2.0/24",
    permissions: ["run_jobs", "code_repository_access", "write_build_metadata"],
    allowAllQueues: false,
    allowedQueueIds: ["queue-id"]
  }) {
    clusterAgentToken {
      id
      description
      allowedIpAddresses
      permissions
      allowAllQueues
      allowedQueueIds
    }
  }
}
```

The `description` argument is required. Supply the token's existing `allowedIpAddresses` value to preserve its IP restriction, as shown above. Omitting `allowedIpAddresses` clears the restriction.

Omit `permissions`, `allowAllQueues`, or `allowedQueueIds` to preserve the corresponding stored value. Supplied permission and queue arrays replace the existing arrays. To switch a restricted token to all queues, send `allowAllQueues: true` and `allowedQueueIds: []` together. Clearing the array while `allowAllQueues` is `false` denies all queues.

Saved permission changes take effect on subsequent requests from connected agents and running jobs, without re-registration. Queue changes apply to new registrations, including registrations using previously issued [job acquisition tokens](/docs/agent/self-hosted/job-acquisition-tokens), and new stack batch JAT issuance.

Explicit job acquisition also checks current queue bindings. Removing queue access after registration can make the Agent API's `/acquire` endpoint return `404`, including for a JAT-backed agent. Queue edits do not disconnect existing agents or cancel running jobs.

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

Set the `policy` argument to a JSON-encoded string of the structured policy document described in [Configure a cache policy](/docs/pipelines/configure/cache#manage-cache-registries-configure-a-cache-policy). For example, add this argument to the create input to allow both saves and restores:

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

You can't delete a cluster's default cache registry. First, [select another default registry](/docs/pipelines/configure/cache#manage-cache-registries) in the web interface or with the REST API's [Update a cluster](/docs/apis/rest-api/clusters#clusters-update-a-cluster) endpoint.

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
