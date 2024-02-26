# Clusters overview

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

## Clusters and queues best practices

### How should I structure my clusters

The most common patterns seen for cluster configurations are based on stage setup, type of work, type of platform/build, or product:

- Stage setup: development, test, and production clusters
- Type of work: open source vs everything else
- Type of platform/build: Linux, Android, macOS, Windows, Docker, ML, etc
- Product lines: companies with multiple products often have a cluster configured for each individual product.

You can create as many clusters as your require for your setup.

>📘 Pipeline triggering
> Pipelines associated with one cluster cannot trigger pipelines associated with another cluster

### How should I structure my queues

The most common queue attributes are based on infrastructure set-ups, such as:

- Architecture (x86, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large)
- Type of machine (macOS, Linux, Windows, GPU, etc.)

Therefore, an example queue would be `small_mac_silicon`.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

## Queue metrics

Clusters provides additional, easy to access queue metrics that are available only for queues within a cluster. Learn more in [Cluster queue metrics](/docs/pipelines/cluster-queue-metrics).

## Accessing clusters and agents

If you only have one Cluster with one Queue selecting _Agents_ in the global navigation will take you to your single queue.

If you have multiple clusters, or unclustered pipelines and agents, selecting _Agents_ in the global navigation will take you to the _Clusters_ page. Once on this page, you can navigate to your agents by selecting the cluster the agents are part of, or _Unclustered_ for agents that were not created as part of a cluster.

### Accessing clustered and unclustered agents, and pipelines

Any agents and pipelines which are not associated with a cluster are known as _unclustered agents_ and _pipelines_, respectively.

To view and manage your all of your agents, their (unclustered) agent tokens, and pipelines, select _Agents_ from the global navigation of your Buildkite organization to open the _Clusters_ page. From this page:

- To access a specific cluster's agents, their associated agent tokens, as well as the cluster's queues and pipelines, select the relevant cluster (or its _queue_ or _pipelines_ link) from this page.

- To access your unclustered agents, their associated agent tokens, as well as their pipelines, select _Unclustered_ (or its _pipelines_ link) from this page.
