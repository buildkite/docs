# Configure networking

Companies with VPN requirements typically use IP allowlists to control network access.

This page provides details on how to obtain relevant IP addresses to configure IP allowlists for your firewall or network, so that it can be used with Buildkite hosted agents.

## Buildkite hosted agent IP address ranges

While [Buildkite hosted agents are ephemeral by nature](/docs/pipelines/hosted-agents#how-buildkite-hosted-agents-work), they connect to the Buildkite platform through an IP address range, which you can use to configure allowlist settings in your network configurations.

### Viewing your hosted agents' IP addresses

To access your hosted agent IP addresses, you can do so from the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.

1. Select the cluster whose Buildkite hosted queues have the hosted agents whose IP addresses you wish to view.

1. Select **Networking** to open the **Network Ranges** page.

    The IP address range of each Buildkite hosted queue's hosted agents are listed on separate lines, which you can copy for your own networking configurations.

> 📘
> Be aware that these IP address ranges are not strictly static, and on occasion, they could change. However, Buildkite will inform you of such events ahead of time, so that you can be prepared to update your network configurations accordingly. If you do require dedicated static IP addresses for your hosted agents' IP addresses, contact Support at support@buildkite.com.

## Buildkite platform IP addresses

The Buildkite platform has a number of public egress IP addresses, which you may need to configure on your firewall's IP allowlist. Be aware that these egress IP addresses are different from the [IP address ranges of your Buildkite hosted agents](#buildkite-hosted-agent-ip-address-ranges), which originate from a different platform.

To obtain these public egress IP addresses, use the [Meta API endpoint](/docs/apis/rest-api/meta) to obtain their values.

## Network security considerations

