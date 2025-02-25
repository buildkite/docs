# Cluster insights

The _cluster insights_ dashboard provides real-time visibility into your build infrastructure's performance, helping you monitor and optimize your CI/CD workflows. This guide explains how to use and interpret the dashboard's metrics to improve your build system's efficiency.

(Screenshot: full dashboard overview showing all metrics cards and graphs)

## Before you start

The dashboard is available to all users of your Buildkite organization, but requires your build infrastructure to be managed through [clusters](/docs/pipelines/clusters). If you're using [unclustered agents](/docs/agent/v3/unclustered-tokens) and want to access these insights, contact Buildkite support at support@buildkite.com to discuss migrating your workloads to clusters.

## Access and using the cluster insights dashboard

To access the cluster insights dashboard:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the **View Cluster Insights** button to access the cluster insights dashboard.

## Dashboard overview

The cluster insights dashboard displays the following primary metrics that help you understand your CI system:

- queue wait time
- queued jobs waiting
- agent utilization
- job pass rate

Each metric provides specific insights into your build infrastructure's health and efficiency.

(Screenshot: top-level metrics cards showing the four main indicators)

### View different cluster and queue scopes

The cluster insights dashboard allows you to monitor your build infrastructure at different levels of detail.

By default, the dashboard shows metrics across all clusters within your Buildkite organization. However, you can use the following drop-downs to filter these metrics:

- **All clusters**—select a cluster to show only performance metrics associated with that cluster.
- **All cluster queues**—if a specific cluster is selected, select a queue to show only the statistics and metrics associated with that cluster's queue.

You can also select between **1h** (the default), **24h**, or **7d** to restrict the historical data shown to 1 hour, 24 hours, or 7 days, respectively.

## Queue wait time

The **Queue wait time** tile Monitor agent assignment delays across your clusters. Sustained spikes indicate agent availability constraints. Brief spikes that resolve themselves reveal high job-activity periods with matching agent availability.

## Queued jobs waiting

## Agent utilization

## Active agents

## Running jobs

## Job pass rate
