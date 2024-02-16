# Manage clusters

This page provides details on how to manage clusters within your Buildkite organization. For details on how to set up queues within a cluster, refer to [Manage queues](/docs/clusters/manage-queues).

## Setting up clusters

When you create a new Buildkite organization, a single default cluster (initially named _Default cluster_) is created.

For smaller organizations, working on smaller projects, this default cluster may be sufficient. However, if you your organization develops projects that require different:

- Staged environments, for example, development, test, staging/pre-production and production,
- Source code visibility, such as open-source versus closed-source code projects,
- Target platforms, such as Linux, Android, macOS, Windows, etc, and
- Multiple projects, for example, different product lines,

Then it is more convenient to manage these in separate clusters.

Once your clusters are set up, you can set up one or more [queues](/docs/clusters/manage-queues) within them.

## Create a new cluster

New clusters can be created either using the [_Agent Clusters_ page](#create-a-new-cluster-using-the-buildkite-interface), or via the [REST API's create agent token](#create-a-new-cluster-using-the-rest-api) feature.

### Using the Buildkite interface

To create a new cluster:

1. Select _Agents_ to access the _Agent Clusters_ page.
1. Select _Create a Cluster_.
1. On the _New Cluster_ page, enter the mandatory _Name_ for the new cluster.
1. Enter an optional _Description_ for the cluster. This description appears under the name of cluster's tile on the _Agent Clusters_ page.
1. Enter an optional _Emoji_ and _Color_ using the recommended syntax.
1. Select _Create Cluster_.

### Using the REST API



## Connect agents to a cluster

Agents are associated with a cluster through the cluster’s agent tokens.

To connect an agent:

1. Navigate to the cluster's _Agent tokens_.
1. Select _New Token_.
1. Enter a description.
1. Select _Create Token_.
1. Select _Copy to Clipboard_ and save the token somewhere secure.
1. Select _Okay, I'm done!_
1. [Use the token](/docs/agent/v3/tokens#using-and-storing-tokens) with the relevant agents, along with [the key from the relevant cluster queue](/docs/agent/v3/queues#setting-an-agents-queue).

You can also create, edit, and revoke other agent tokens from the cluster’s _Agent tokens_.

## Add pipelines to a cluster

Add a pipeline to a cluster to ensure the pipeline’s builds run only on agents connected to that cluster.

To add a pipeline to a cluster:

1. Navigate to the _Pipeline Settings_ for the pipeline.
1. Under _Cluster Settings_, select the relevant cluster.

## Add maintainers to a cluster

Only Buildkite administrators or users with the [_change organization_ permission](/docs/team-management/permissions) can create clusters.

You can assign other users or teams as a cluster’s maintainers to permit them to manage the cluster. Cluster maintainers can:

* Update or delete the cluster.
* Manage cluster agent tokens.
* Add or remove pipelines to the cluster.

To add a maintainer to a cluster:

1. Navigate to the cluster’s _Maintainers_.
1. Select a user or team.
1. Click _Add Maintainer_.

## Restrict access for an agent token by IP address

Each agent token can be locked down so that only agents with an allowed IP address can use them to register.

You can set the _Allowed IP Addresses_ when creating a token, or you can modify existing tokens:

1. Navigate to the cluster's _Agent Tokens_.
1. Select the token to which you wish to restrict access.
1. Select _Edit_.
1. Update the _Allowed IP Addresses_ setting, using space-separated [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing).
1. Select _Save Token_.

Modifying the _Allowed IP Addresses_ forcefully disconnects any existing agents with IP addresses outside the updated value. This prevents the completion of any jobs in progress on those agents.

Note the following limitations:

* This setting does not restrict access to the [Metrics API](/docs/apis/agent-api/metrics) for the given agent token.
* There is a maximum of 24 CIDR blocks per agent token.
* IPv6 is currently not supported.

## Migrate to clusters

If you migrate all your existing agents over to clusters, make sure to add all your pipelines to the relevant clusters. Otherwise, any builds for those pipelines will never find agents to run them.
