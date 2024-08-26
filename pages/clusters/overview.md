# Clusters overview

Clusters is a Buildkite feature used to manage and organize agents and queues, which:

- allows teams to self-manage their Buildkite agent pools
- allows admins to create isolated sets of agents and pipelines within the one Buildkite organization
- helps make agents and queues more discoverable across your organization
- provides easily accessible queue metrics

The following diagram shows the architecture of a Buildkite organization's clusters, along with their pipelines and queues.

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

Learn more about working with clusters in [Manage clusters](/docs/clusters/manage-clusters).

> 📘 Pipeline triggering
> Pipelines associated with one cluster cannot trigger pipelines associated with another cluster, unless a [rule](/docs/pipelines/rules/overview) has been created to explicitly allow triggering between pipelines in different clusters.

### How should I structure my queues

The most common queue attributes are based on infrastructure set-ups, such as:

- Architecture (x86, arm64, Apple silicon, etc.)
- Size of agents (small, medium, large)
- Type of machine (macOS, Linux, Windows, GPU, etc.)

Therefore, an example queue would be `small_mac_silicon`.

Having individual queues according to these breakdowns allows you to scale a set of similar agents, which Buildkite can then report on.

Learn more about working with queues in [Manage queues](/docs/clusters/manage-queues).

## Queue metrics

Clusters provides additional, easy to access queue metrics that are available only for queues within a cluster. Learn more in [Cluster queue metrics](/docs/pipelines/cluster-queue-metrics).

## Accessing your agents and pipelines

If you only have one cluster with one queue, selecting **Agents** in the global navigation takes you directly to your single queue in this cluster. This is typically the case with newly created organizations.

If you have multiple clusters, selecting **Agents** in the global navigation takes you to the **Clusters** page, where you can access your individual clusters and within each one, the details and configurations of the cluster's individual queues, agents tokens, pipelines and other settings.

Any agents and pipelines which are not yet associated with a cluster are known as _unclustered agents_ and _unclustered pipelines_, respectively.

From the **Clusters** page:

- To access a specific cluster's agents, their associated agent tokens, as well as the cluster's queues and pipelines, select the relevant cluster (or its **queue** or **pipelines** link) from this page.

- To access your unclustered agents, their associated agent tokens, as well as their pipelines, select **Unclustered** (or its **pipelines** link) from this page.
