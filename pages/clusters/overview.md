# Clusters overview

>📘 Clusters
> Clusters will be enabled for all organizations on February 26 2024.

Clusters is a Buildkite feature used to manage and organize agents and queues, which:

- allows teams to self-manage their Buildkite agent pools,
- allows admins to create isolated sets of agents and pipelines within the one Buildkite organization,
- helps make agents and queues more discoverable across your organization, and
- provides easily accessible queue metrics.

The following diagram shows the architecture with cluster enabled.

<%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %>

Clusters encapsulate groups of agents and pipelines, enabling the following:

- Clusters are viewable to your entire Buildkite organization, allowing engineers to better understand the agents and queues available for their pipelines.
- Individual users or teams can maintain their own clusters. Cluster maintainers can manage queues and agent tokens, and add and remove pipelines.
- Pipelines can be assigned to a cluster, ensuring their builds run only on the agents connected to this cluster. These pipelines can also trigger builds only on other pipelines in the same cluster.

## Clusters and Queues best practice

>📘 Clusters Pipelines
> Pipelines defined in a cluster cannot trigger pipelines in another cluster

### How should I structure my clusters

The most common patterns we see for clusters are per stage, type of work or product.

- Stage setup: DEV, TEST, PROD clusters
- Type of work: Open source vs everything else
- Type of build: Docker, Android, Mac, ML etc
- Per product line: For companies with multiple products we see them have a cluster per each individual product.

You can create as many clusters as your require for your setup.

### How should I structure my queues

Queues should mimic your infrastructure. The most common queue attributes we see customers use are:

- Architecture (x86, arm64 etc)
- Size of agents (small, medium, large)
- Type of machine (Mac, GPU, Linux, Windows)

So an example queue would be `small_mac_silicon`.

Having individual queues according to these breakdowns allows you to scale your agents that all look the same and Buildkite will report on these

## Queue metrics

Clusters provides additional, easy to access queue metrics that are available only for queues within a cluster. Learn more in [Cluster queue metrics](/docs/pipelines/cluster-queue-metrics).

## Accessing clusters and agents

The release of clusters changes how your agents are accessed through the Buildkite interface.

If you only have one Cluster with one Queue selecting _Agents_ in the global navigation will take you to your single queue.

If you have multiple clusters, or unclustered pipelines and agents, selecting _Agents_ in the global navigation will take you to the _Agent Clusters_ page. Once on this page, you can navigate to your agents by selecting the cluster the agents are part of, or _Unclustered_ for agents that were not created as part of a cluster.

## Enabling clusters before the release date

Any Buildkite administrator can enable clusters for an organization. Once you enable clusters, you can only disable them by contacting support.

Enabling clusters also changes access to agent tokens. Rather than being available in the Buildkite dashboard, agent tokens are only visible upon creation, ensuring greater security for your applications.

To enable clusters:

1. Securely save any existing agent tokens you need because these won't be available after enabling clusters.
1. Navigate to your [organization’s pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In _Clusters_, select _Enable Clusters_.

_Clusters_ will now appear in the global navigation.

### Use clusters alongside unclustered agents and pipelines

Enabling clusters will not impact any of your existing agents or pipelines, nor will you require any workflow-breaking changes for you to try clusters.

Once clusters is enabled, selecting _Agents_ in the global navigation shows all your available clusters, as well as any _Unclustered_ agents and pipelines.

Any agents or pipelines not associated with a cluster are called _unclustered_. To view and manage your unclustered agents, agent tokens, and pipelines, select _Unclustered_.






