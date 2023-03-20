# Clusters

Clusters are a new way of managing your Buildkite agents. They allow teams to self-manage their agent pools, let admins create isolated sets of agents and pipelines within the one Buildkite organization, and help to make agents and queues more discoverable across your organization.

You can turn on clusters for your organization if you have an administrator role through Organization Settings >> Pipeline Settings. Once you turn it on, you won’t be able to turn it back off.

## What's changed?

* Clusters are viewable to your entire organization, allowing engineers to understand better what agents and queues are available in their pipelines.
* You can grant cluster-admin access to individual users or teams to allow them to self-administer their own sets of agents. Cluster admins can create and delete queues, access agent tokens, and add and remove pipelines.
* Queues can be created within a cluster and validated when a pipeline's configuration is saved during pipeline upload, and when a new agent connects. This helps to make queues more discoverable to pipeline authors and helps to prevent ghost jobs that never run because they had a typo in their pipeline.yml's queue name.
* Pipelines now belong to a cluster. Pipelines can only schedule jobs on the cluster it belongs to, and can only trigger builds on pipelines in the same cluster.

<!-- <%= image "clusters-architecture.png", alt: "Diagram showing existing architecture and architecture with clusters" %> -->

## Trying it out
We've built clusters in a way that shouldn't affect any of your existing agents or pipelines or require any breaking changes to try out. Once turned on, all members of your organization will see a new clusters tab in the navigation.

Your agents will be shown under their cluster or in the unclustered view:

<!-- <%= image "clusters-views.png", alt: "Image showing clustered and unclustered views" %> -->

You can still access your agent and its count through the agent tab in the left navigation.

Once you create a cluster, copy the auto-generated token for your agents and add it to the agents in the cluster. If you want to use a custom token, edit the token in the Agent Tokens tab:

<!-- <%= image "agent-registration-tokens-views.png", alt: "Image showing Agent Tokens view" %> -->

You can add teams and individual users under Maintainers for that cluster.

Clusters can be created through buildkite.com, the REST API, or the GraphQL API. If you migrate all your existing agents over to clusters, be sure to modify all your pipelines to belong in the cluster. Otherwise, any builds created (either manually, via source code, or schedules) will never find any agents to run their builds.

To add a pipeline to a cluster, navigate to the pipeline settings page and add the pipeline to the relevant cluster under Cluster Settings.
