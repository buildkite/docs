# Manage clusters

This page provides details on how to manage clusters within your Buildkite organization.

Learn more about on how to set up queues within a cluster in [Manage queues](/docs/clusters/manage-queues).

## Setting up clusters

When you create a new Buildkite organization, a single default cluster (initially named _Default cluster_) is created.

For smaller organizations, working on smaller projects, this default cluster may be sufficient. However, it's usually more convenient for organizations to manage projects in separate clusters, when these projects require different:

- Staged environments, for example, development, test, staging/pre-production and production
- Source code visibility, such as open-source versus closed-source code projects
- Target platforms, such as Linux, Android, macOS, Windows, etc.
- Multiple projects, for example, different product lines

Once your clusters are set up, you can set up one or more [queues](/docs/clusters/manage-queues) within each cluster.

## Create a cluster

New clusters can be created using the [_Clusters_ page](#create-a-cluster-using-the-buildkite-interface), as well as the [REST API's](#create-a-cluster-using-the-rest-api) or [GraphQL API's](#create-a-cluster-using-the-graphql-api) create a cluster feature.

### Using the Buildkite interface

To create a new cluster using the Buildkite interface:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select _Create a Cluster_.
1. On the _New Cluster_ page, enter the mandatory _Name_ for the new cluster.
1. Enter an optional _Description_ for the cluster. This description appears under the name of cluster's tile on the _Clusters_ page.
1. Enter an optional _Emoji_ and _Color_ using the recommended syntax. This emoji appears next to the cluster's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji.
1. Select _Create Cluster_.

    The new cluster's page is displayed on its _Queues_ page, indicating the cluster's name and its default queue, named _queue_. From this page, you can set up one or more additional [queues](/docs/clusters/manage-queues) within this cluster.

### Using the REST API

To [create a new cluster](/docs/apis/rest-api/clusters#clusters-create-a-cluster) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```curl
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

You can also create, edit, and revoke other agent tokens from the cluster’s _Agent tokens_.

## Move unclustered agents to a cluster

Unclustered agents are agents associated with the _Unclustered_ area of the _Clusters_ page in a Buildkite organization. Learn more about unclustered agents in [Unclustered agent tokens](/docs/agent/v3/unclustered-tokens).

Moving unclustered agents to a cluster will allow those agents to use [agent tokens](/docs/agent/v3/tokens) that connect to Buildkite via a cluster.

> 📘 Organizations created after February 26, 2024
> Buildkite organizations created after this date will not have an _Unclustered_ area. Therefore, this process is not required for these newer organizations.

To move an unclustered agent across to using a cluster:

1. Stop the unclustered agent (from running). To do this, either terminate the agent's running process (for example, via Ctrl-C on the keyboard) or use the Buildkite interface:

    1. Select _Agents_ in the global navigation to access the _Clusters_ page.
    1. Select _Unclustered_.
    1. From the _Unclustered Agents_ page, select the agent to stop and on its page, select _Stop Agent_.

1. [Create a new agent token](/docs/agent/v3/tokens#create-a-token) for the cluster the agent will be moved to.

1. [Start the Buildkite agent](/docs/agent/v3/cli-start) using the `--token` value is that of the agent token created in the previous step. Alternatively, configure this agent token's value in the [Buildkite agent's configuration file](/docs/agent/v3/configuration) before starting the agent.

If you migrate all your existing agents over to clusters, ensure that all of your pipelines have also been [moved to their relevant clusters](#move-a-pipeline-to-a-specific-cluster). Otherwise, any builds for those pipelines will never find agents to run them.

## Restrict an agent token's access by IP address

As a security measure, each agent token has an optional _Allowed IP Addresses_ setting that can be used to lock down access to the token. When this option is set on an agent token, only agents with an IP address that matches one this agent token's setting can use this token to connect to your Buildkite organization (through your cluster).

An agent token's _Allowed IP Addresses_ setting can be set [when the token is created](/docs/agent/v3/tokens#create-a-token), or this setting can be added to or modified on existing agent tokens, using the [_Agent Tokens_ page of a cluster](#restrict-an-agent-tokens-access-by-ip-address-using-the-buildkite-interface), or the [REST API's update agent token](#restrict-an-agent-tokens-access-by-ip-address-using-the-rest-api) feature.

> 🚧 Changing the _Allowed IP Addresses_ setting
> Modifying an agent token's _Allowed IP Addresses_ setting forcefully disconnects any existing agents (using this token) with an IP address that no longer matches one of the values of this updated setting. This will prevent the completion of any jobs in progress on those agents.

To remove this IP address restriction from an agent's token, explicitly set its _Allowed IP Addresses_ value to its default value of `0.0.0.0/0`.

Be aware that an agent token's _Allowed IP Addresses_ setting also has the following limitations:

- Access to the [Metrics API](/docs/apis/agent-api/metrics) for this agent token is not restricted.
- There is a maximum of 24 CIDR blocks per agent token.
- IPv6 is currently not supported.

### Using the Buildkite interface

To restrict an existing agent token's access by IP address (via the token's _Allowed IP Addresses_ setting) using the Buildkite interface:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster associated with the agent token.
1. Select _Agent Tokens_ and expand the agent token whose _Allowed IP Addresses_ setting is to be added or modified.
1. Select _Edit_.
1. Update the _Allowed IP Addresses_ setting, using space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) to the IP addresses which agents must be accessible through.
1. Select _Save Token_.

### Using the REST API

To restrict an existing agent token's access by IP address using the REST API, run the following example `curl` command to [update this agent token](/docs/apis/rest-api/clusters#agent-tokens-update-a-token):

```curl
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

## Manage maintainers on a cluster

Buildkite administrators or users with the [_change organization_ permission](/docs/team-management/permissions) can create clusters.

As one of these types of users, you can add and manage other users or teams in your Buildkite organization as _maintainers_ of a cluster in the organization. A cluster maintainer can:

- Update or delete the cluster.
- Manage [agent tokens](/docs/agent/v3/tokens) associated with the cluster.
- Manage [queues](/docs/clusters/manage-queues) within the cluster.
- Add pipelines to or remove them from the cluster.

To add a maintainer to a cluster:

1. Select _Agents_ in the global navigation to access the _Clusters_ page.
1. Select the cluster to add a user or team to be a maintainer of the cluster.
1. Select _Maintainers_ > _Add Maintainer_.
1. Select if the maintainer will either be a specific _User_ or _Team_ of users.
1. Select the specific user or team from the drop-down list.
1. Click _Add Maintainer_ and the user or team is listed on the _Maintainers_ page.

To remove a maintainer from a cluster:

1. From the cluster's _Maintainers_ page, select _Remove_ from the user or team to be removed as a maintainer.
1. Select _OK_ to confirm this action.

## Move a pipeline to a specific cluster

Move a pipeline to a specific cluster to ensure the pipeline's builds run only on agents connected to that cluster.

> 📘 Associating pipelines with cluster
> A pipeline can only be associated with one cluster at a time. It is not possible to associate a pipeline with two or more clusters simultaneously.

A pipeline can be moved to a cluster via the pipeline's [_General_ settings page](#move-a-pipeline-to-a-specific-cluster-using-the-buildkite-interface), or the [REST API's update a pipeline](#move-a-pipeline-to-a-specific-cluster-using-the-rest-api) feature.

### Using the Buildkite interface

To move a pipeline to a specific cluster using the Buildkite interface:

1. Select _Pipelines_ in the global navigation to access your organization's list of accessible pipelines.
1. Select the pipeline to be moved to a specific cluster.
1. Select _Settings_ to open the pipeline's _General_ settings page.
1. On this page, select _Change Cluster_ in the _Cluster_ section of this page.
1. Select the specific target cluster in the dialog and select _Change_.

    The pipeline's _General_ settings page indicates the current cluster the pipeline is associated with. The pipeline will also be visible and accessible from the cluster's _Pipelines_ page.

### Using the REST API

To [move a pipeline to a specific cluster](/docs/apis/rest-api/pipelines#update-a-pipeline) using the [REST API](/docs/apis/rest-api), run the following `curl` command:

```curl
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines/{slug}" \
  -H "Content-Type: application/json" \
  -d '{ "cluster_id": "xxx" }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

- `{slug}` can be obtained:

    * From the end of your Buildkite URL, after accessing _Pipelines_ in the global navigation of your organization in Buildkite, then accessing the specific pipeline to be moved to the cluster.

    * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `slug` in the response from the specific pipeline. For example:

        ```curl
        curl -H "Authorization: Bearer $TOKEN" "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines"
        ```

<%= render_markdown partial: 'apis/descriptions/rest_cluster_id_body' %>

<!-- ## Delete a cluster -->
