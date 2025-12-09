# Configure networking

This page describes a variety of topics relating to networking for Buildkite hosted agents, along with recommendations on how to configure your network to use with Buildkite hosted agents.

## IP address ranges

While [Buildkite hosted agents are ephemeral by nature](/docs/pipelines/hosted-agents#how-buildkite-hosted-agents-work), they connect to the Buildkite platform through an IP address range, which you can use to configure allowlist settings in your network configurations.

### Viewing your hosted agents' IP addresses

To access your hosted agent IP addresses, you can do so from the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.

1. Select the cluster whose Buildkite hosted queues have the hosted agents whose IP addresses you wish to view.

1. Select **Networking** to open the **Network Ranges** page.

    The IP address range of each Buildkite hosted queue's hosted agents are listed on separate lines, which you can copy for your own networking configurations.

> 📘
> Be aware that these IP address ranges are not strictly static, and they may change from time to time. However, Buildkite will inform you of such events ahead of time, so that you can be prepared to update your network configurations accordingly.

## Firewall
