# Clusters overview

Clusters are a new way of managing your Buildkite agents. They allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

The following diagram shows the architecture with cluster enabled.

<%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %>

Clusters encapsulate groups of agents and pipelines, enabling the following:

* Clusters are viewable to your entire organization, allowing engineers to better understand the agents and queues available for their pipelines.
* Individual users or teams can maintain their own clusters. Cluster maintainers can manage queues and agent tokens and add and remove pipelines.
* Pipelines can be assigned to a cluster, ensuring their builds run only on the agents connected to this cluster. These pipelines can also trigger builds only on other pipelines in the same cluster.

## Enable clusters

Any Buildkite administrator can enable clusters for an organization. Once you enable clusters, you can only disable them by contacting support.

Enabling clusters also changes access to agent tokens. Rather than being available in the Buildkite dashboard, agent tokens are only visible upon creation, ensuring greater security for your applications.

To enable clusters:

1. Securely save any existing agent tokens you need because these won't be available after enabling clusters.
1. Navigate to your [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.

_Clusters_ will now appear in the global navigation.

### Use clusters alongside unclustered agents and pipelines

Enabling clusters will not impact any of your existing agents or pipelines, nor will you require any workflow-breaking changes for you to try clusters.

Once you’ve enabled clusters, all members of your organization will see _Clusters_ in the global navigation. This will show all your clusters as well as _Unclustered_ agents and pipelines.

Any agents or pipelines not associated with a cluster are called _unclustered_. To view and manage your unclustered agents, agent tokens, and pipelines, select _Unclustered_.

To view all running agents in your organization (in a cluster or not), click on _All agents_ in the sidebar.
