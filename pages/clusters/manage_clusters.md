# Manage clusters

This page provides details on how to manage clusters within your Buildkite organization.

Learn more about on how to set up queues within a cluster in [Manage queues](/docs/clusters/manage-queues).

## Setting up clusters

When a new Buildkite organization is created, a single default cluster (initially named **Default cluster**) is also created.

For smaller organizations, working on smaller projects, this default cluster may be sufficient. However, it's usually more convenient for organizations to manage projects in separate clusters, when these projects require different:

- Staged environments, for example, development, test, staging/pre-production and production
- Source code visibility, such as open-source versus closed-source code projects
- Target platforms, such as Linux, Android, macOS, Windows, etc.
- Multiple projects, for example, different product lines

Once your clusters are set up, you can set up one or more [queues](/docs/clusters/manage-queues) within each cluster.

## Create a cluster

New clusters can be created by a [cluster maintainer](#manage-maintainers-on-a-cluster) using the [**Clusters** page](#create-a-cluster-using-the-buildkite-interface), as well as the [REST API's](#create-a-cluster-using-the-rest-api) or [GraphQL API's](#create-a-cluster-using-the-graphql-api) create a cluster feature.

### Using the Buildkite interface

To create a new cluster using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select **Create a Cluster**.
1. On the **New Cluster** page, enter the mandatory **Name** for the new cluster.
1. Enter an optional **Description** for the cluster. This description appears under the name of the cluster in its tile on the **Clusters** page.
1. Enter an optional **Emoji** and **Color** using the recommended syntax. This emoji appears next to the cluster's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji.
1. Select **Create Cluster**.

    The new cluster's page is displayed on its **Queues** page, indicating the cluster's name and its default queue, named **queue**. From this page, you can set up one or more additional [queues](/docs/clusters/manage-queues) within this cluster.

### Using the REST API

To [create a new cluster](/docs/apis/rest-api/clusters#clusters-create-a-cluster) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
  -H "Content-Type: application/json" \
  -d '{ 
    "name": "Open Source",
    "description": "A place for safely running our open source builds",
    "emoji": "\:technologist\:",
    "color": "#FFE0F1"
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/common_create_cluster_fields' %>

### Using the GraphQL API

To [create a new cluster](/docs/apis/graphql/schemas/mutation/clustercreate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  clusterCreate(
    input: {
      organizationId: "organization-id"
      name: "Open Source"
      description: "A place for safely running our open source builds"
      emoji: "\:technologist\:"
      color: "#FFE0F1"
    }
  ) {
    cluster {
      id
      uuid
      name
      description
      emoji
      color
      defaultQueue {
        id
      }
      createdBy {
        id
        uuid
        name
        email
        avatar {
          url
        }
      }
    }
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/common_create_cluster_fields' %>

## Connect agents to a cluster

Agents are associated with a cluster through the cluster's agent tokens. Learn more about this in [Agent tokens](/docs/agent/v3/tokens).

Once you have [created your required agent token/s](/docs/agent/v3/tokens#create-a-token), [use them](/docs/agent/v3/tokens#using-and-storing-tokens) with the relevant agents, along with an optional [tag representing the relevant queue in your cluster](/docs/agent/v3/queues#setting-an-agents-queue).

You can also create, edit, and revoke other agent tokens from the cluster’s **Agent tokens**.

## Move unclustered agents to a cluster

Unclustered agents are agents associated with the **Unclustered** area of the **Clusters** page in a Buildkite organization. Learn more about unclustered agents in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

Moving unclustered agents to a cluster will allow those agents to use [agent tokens](/docs/agent/v3/tokens) that connect to Buildkite via a cluster, and requires at least [cluster maintainer](#manage-maintainers-on-a-cluster) privileges.

> 📘 Organizations created after February 26, 2024
> Buildkite organizations created after this date will not have an **Unclustered** area. Therefore, this process is not required for these newer organizations.

To move an unclustered agent across to using a cluster:

1. Stop the unclustered agent (from running). To do this, either terminate the agent's running process (for example, via Ctrl-C on the keyboard) or use the Buildkite interface:

    1. Select **Agents** in the global navigation to access the **Clusters** page.
    1. Select **Unclustered**.
    1. From the **Unclustered Agents** page, select the agent to stop and on its page, select **Stop Agent**.

1. [Create a new agent token](/docs/agent/v3/tokens#create-a-token) for the cluster the agent will be moved to.

1. [Start the Buildkite agent](/docs/agent/v3/cli-start) using the `--token` value is that of the agent token created in the previous step. Alternatively, configure this agent token's value in the [Buildkite agent's configuration file](/docs/agent/v3/configuration) before starting the agent.

If you migrate all your existing agents over to clusters, ensure that all of your pipelines have also been [moved to their relevant clusters](#move-a-pipeline-to-a-specific-cluster). Otherwise, any builds for those pipelines will never find agents to run them.

## Restrict an agent token's access by IP address

As a security measure, each agent token has an optional **Allowed IP Addresses** setting that can be used to lock down access to the token. When this option is set on an agent token, only agents with an IP address that matches one this agent token's setting can use this token to connect to your Buildkite organization (through your cluster).

An agent token's **Allowed IP Addresses** setting can be set [when the token is created](/docs/agent/v3/tokens#create-a-token), or this setting can be added to or modified on existing agent tokens by a [cluster maintainer](#manage-maintainers-on-a-cluster), using the [**Agent Tokens** page of a cluster](#restrict-an-agent-tokens-access-by-ip-address-using-the-buildkite-interface), as well as the [REST API's](#restrict-an-agent-tokens-access-by-ip-address-using-the-rest-api) or [GraphQL API's](#restrict-an-agent-tokens-access-by-ip-address-using-the-graphql-api) update agent token feature.

For these API requests, the _cluster ID_ value submitted in the request is the target cluster the token is associated with.

> 🚧 Changing the **Allowed IP Addresses** setting
> Modifying an agent token's **Allowed IP Addresses** setting forcefully disconnects any existing agents (using this token) with an IP address that no longer matches one of the values of this updated setting. This will prevent the completion of any jobs in progress on those agents.

To remove this IP address restriction from an agent's token, explicitly set its **Allowed IP Addresses** value to its default value of `0.0.0.0/0`.

Be aware that an agent token's **Allowed IP Addresses** setting also has the following limitations:

- Access to the [Metrics API](/docs/apis/agent-api/metrics) for this agent token is not restricted.
- There is a maximum of 24 CIDR blocks per agent token.
- IPv6 is currently not supported.

### Using the Buildkite interface

To restrict an existing agent token's access by IP address (via the token's **Allowed IP Addresses** setting) using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster associated with the agent token.
1. Select **Agent Tokens** and expand the agent token whose **Allowed IP Addresses** setting is to be added or modified.
1. Select **Edit**.
1. Update the **Allowed IP Addresses** setting, using space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) to the IP addresses which agents must be accessible through.
1. Select **Save Token**.

### Using the REST API

To restrict an existing agent token's access by IP address using the REST API, run the following example `curl` command to [update this agent token](/docs/apis/rest-api/clusters#agent-tokens-update-a-token):

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}" \
  -H "Content-Type: application/json" \
  -d '{ "allowed_ip_addresses": "192.0.2.0/24 198.51.100.12" }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id' %>

<%= render_markdown partial: 'apis/descriptions/rest_agent_token_id' %>

- `allowed_ip_addresses` is/are the IP addresses which agents must be accessible through to access this agent token and be able to connect to Buildkite via your cluster. Use space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) to enter IP addresses for this field value.

### Using the GraphQL API

To restrict an existing agent token's access by IP address using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation to [update this agent token](/docs/apis/graphql/schemas/mutation/clusteragenttokenupdate):

```graphql
mutation {
  clusterAgentTokenUpdate(
    input: {
      organizationId: "organization-id"
      id: "token-id"
      description: "A description"
      allowedIpAddresses: "202.144.0.0/24 198.51.100.12"
    }
  ) {
    clusterAgentToken {
      id
      uuid
      description
      allowedIpAddresses
      cluster {
        id
        uuid
        organization {
          id
          uuid
        }
      }
      createdBy {
        id
        uuid
        email
      }
    }
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_agent_token_id' %>

- <%= render_markdown partial: 'apis/descriptions/common_agent_token_description_required' %>

    If you do not need to change the existing `description` value, specify the existing field value in the request.

- `allowedIpAddresses` is/are the IP addresses which agents must be accessible through to access this agent token and be able to connect to Buildkite via your cluster. Use space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) to enter IP addresses for this field value.

## Manage maintainers on a cluster

Buildkite administrators or users with the [_change organization_ permission](/docs/team-management/permissions) can create clusters.

As one of these types of users, you can add and manage other users or teams in your Buildkite organization as _maintainers_ of a cluster in the organization. A cluster maintainer can:

- Update or delete the cluster.
- Manage [agent tokens](/docs/agent/v3/tokens) associated with the cluster.
- Manage [queues](/docs/clusters/manage-queues) within the cluster.
- Add pipelines to or remove them from the cluster.

To add a maintainer to a cluster:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster whose user or team is to be added as a maintainer of this cluster.
1. Select **Maintainers** > **Add Maintainer**.
1. Select if the maintainer will either be a specific **User** or **Team** of users.
1. Select the specific user or team from the drop-down list.
1. Click **Add Maintainer** and the user or team is listed on the **Maintainers** page.

To remove a maintainer from a cluster:

1. From the cluster's **Maintainers** page, select **Remove** from the user or team to be removed as a maintainer.
1. Select **OK** to confirm this action.

## Move a pipeline to a specific cluster

Move a pipeline to a specific cluster to ensure the pipeline's builds run only on agents connected to that cluster.

> 📘 Associating pipelines with cluster
> A pipeline can only be associated with one cluster at a time. It is not possible to associate a pipeline with two or more clusters simultaneously.

A pipeline can be moved to a cluster by a [cluster maintainer](#manage-maintainers-on-a-cluster) via the pipeline's [**General** settings page](#move-a-pipeline-to-a-specific-cluster-using-the-buildkite-interface), as well as the [REST API's](#move-a-pipeline-to-a-specific-cluster-using-the-rest-api) or [GraphQL API's](#move-a-pipeline-to-a-specific-cluster-using-the-graphql-api) update a pipeline feature.

For these API requests, the _cluster ID_ value submitted in the request is the target cluster the pipeline is being moved to.

### Using the Buildkite interface

To move a pipeline to a specific cluster using the Buildkite interface:

1. Select **Pipelines** in the global navigation to access your organization's list of accessible pipelines.
1. Select the pipeline to be moved to a specific cluster.
1. Select **Settings** to open the pipeline's **General** settings page.
1. On this page, select **Change Cluster** in the **Cluster** section of this page.
1. Select the specific target cluster in the dialog and select **Change**.

    The pipeline's **General** settings page indicates the current cluster the pipeline is associated with. The pipeline will also be visible and accessible from the cluster's **Pipelines** page.

### Using the REST API

To [move a pipeline to a specific cluster](/docs/apis/rest-api/pipelines#update-a-pipeline) using the [REST API](/docs/apis/rest-api), run the following `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}" \
  -H "Content-Type: application/json" \
  -d '{ "cluster_id": "xxx" }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

- `{slug}` can be obtained:

    * From the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be moved to the cluster.

    * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \
          - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines"
        ```

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id_body' %>

### Using the GraphQL API

To [move a pipeline to a specific cluster](/docs/apis/graphql/schemas/mutation/pipelineupdate) using the [GraphQL API](/docs/apis/graphql-api), run the following mutation:

```curl
mutation {
  pipelineUpdate(
    input: {
      id: "pipeline-id"
      clusterId: "cluster-id"
    }
  ) {
    pipeline {
      id
      uuid
      name
      description
      slug
      createdAt
      cluster {
        id
        uuid
        name
        description
      }
    }
  }
}
```

where:

- `id` (required) is that of the pipeline to be moved, whose value can be obtained:

    * From the pipeline's **General** settings page. To do this:
        1. Select **Pipelines** in the global navigation > the specific pipeline to be moved to the cluster > **Settings**.
        1. Copy the **ID** shown in the **GraphQL API Integration** section of this page, which is this `id` value.

    * By running the `getCurrentUsersOrgs` GraphQL API query to obtain the organization slugs for the current user's accessible organizations, [getOrgPipelines](/docs/apis/graphql/schemas/query/organization) query to obtain the pipeline's `id` in the response. For example:

        Step 1. Run `getCurrentUsersOrgs` to obtain the organization slug values in the response for the current user's accessible organizations:

        ```graphql
        query getCurrentUsersOrgs {
          viewer {
            organization {
              edges {
                node {
                  name
                  slug
                }
              }
            }
          }
        }
        ```

        Step 2. Run `getOrgPipelines` with the appropriate slug value above to obtain this organization's `id` in the response:

        ```graphql
        query getOrgPipelines {
          organization(slug: "organization-slug") {
            pipelines(first: 100) {
              edges {
                node {
                  id
                  uuid
                  name
                }
              } 
            }
          }
        }
        ```

<%= render_markdown partial: 'apis/descriptions/graphql_cluster_id' %>

<!-- ## Delete a cluster -->
