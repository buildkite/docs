# Cluster insights

The _cluster insights_ dashboard provides real-time visibility into your build infrastructure's performance, helping you monitor and optimize your CI/CD workflows. This guide explains how to use and interpret the dashboard's metrics to improve your build system's efficiency.

(Screenshot: full dashboard overview showing all metrics cards and graphs)

## Before you start

The dashboard is available to all users of your Buildkite organization, but requires your build infrastructure to be managed through [clusters](/docs/pipelines/clusters). If you're using [unclustered agents](/docs/agent/v3/unclustered-tokens) and want to access these insights, contact Buildkite support at support@buildkite.com to discuss migrating your workloads to clusters.

## Access the cluster insights dashboard

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
- **All cluster queues**—if a specific cluster is selected, select its queue to show only the statistics and metrics associated with that cluster's queue.

You can also select between **1h** (the default), **24h**, or **7d** to restrict the historical data shown to 1 hour, 24 hours, or 7 days, respectively.

## Understanding key metrics

### Queue wait time

(Screenshot: queue wait time graph showing normal spikes and sustained high wait times)

The queue wait time measures how long jobs wait before an agent starts processing them, directly impacting your build times and developer productivity. While brief spikes during high-activity periods are normal, especially as auto-scaling responds, sustained high wait times may indicate underlying issues.

When you notice sustained high wait times, investigate these areas:

- Check agent utilization rates.
- Review agent scaling configurations.
- Consider increasing your base agent count.

For recurring spikes, focus on:

- Analyzing peak usage patterns.
- Adjusting auto-scaling thresholds.
- Reviewing job scheduling strategies.

### Agent utilization

(Screenshot: agent utilization graph showing different utilization patterns)

Agent utilization reveals the percentage of your agent fleet actively running jobs. Consistent utilization above 95% indicates potential capacity issues, and utilization below 70% suggests inefficient resource use.

When facing high utilization (>95%):

- Increase agent capacity.
- Review job distribution across clusters.
- Check for blocked or stalled agents.

For low utilization (<70%):

- Consider reducing agent capacity.
- Review agent scaling settings.
- Analyze job scheduling patterns.

### Active agents and running jobs

(Screenshot: active agents and running jobs graphs side by side)

These metrics provide insight into your build capacity and resource usage. Sudden drops in active agents or misalignment between running jobs and agent utilization often indicate potential issues that need investigation.

When investigating capacity issues, consider:

- Monitor scaling effectiveness.
- Check agent health when seeing unexpected drops.
- Balance job distribution across clusters.

### Job pass rate

(Screenshot: Job pass rate graph showing success patterns and failure dips)

The job pass rate helps identify potential issues across your clusters. Sudden dips or sustained lower pass rates often indicate problems that require immediate attention.

For sudden dips in pass rate:

- Check affected clusters.
- Review recent changes.
- Investigate failed jobs.

When dealing with sustained lower pass rates:

- Analyze patterns by cluster.
- Review agent configurations.
- Check for infrastructure issues.
