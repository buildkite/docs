# Network security

Companies with VPN requirements typically use IP allowlists to control network access.

This page provides details on how to obtain relevant IP addresses to configure IP allowlists for your firewall or network, so that it can be used with Buildkite hosted agents, as well as other [network security considerations](#network-security-considerations) and best practices.

## Buildkite hosted agent IP address ranges

While [Buildkite hosted agents are ephemeral by nature](/docs/pipelines/hosted-agents#how-buildkite-hosted-agents-work), they connect to the Buildkite platform through an IP address range, which you can use to configure allowlist settings in your network configurations.

### Viewing your hosted agents' IP addresses

To access your hosted agent IP addresses, you can do so from the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.

1. Select the cluster whose Buildkite hosted queues have the hosted agents whose IP addresses you wish to view.

1. Select **Networking** to open the **Network Ranges** page.

    The IP address range of each Buildkite hosted queue's hosted agents are listed on separate lines, which you can copy for your own networking configurations.

> 📘
> Be aware that these IP address ranges are not strictly static, and on rare occasions, these address ranges could change. On such occasions, however, Buildkite will aim to inform you of such events ahead of time, so that you can be prepared to update your network configurations accordingly.
> If you do require dedicated static IP addresses for your hosted agents' IP addresses, contact Support at support@buildkite.com.

## Buildkite platform IP addresses

The Buildkite platform itself has a number of public egress IP addresses, which you may need to configure on your firewall's IP allowlist. Be aware that these egress IP addresses are different from the [IP address ranges of your Buildkite hosted agents](#buildkite-hosted-agent-ip-address-ranges), which originate from a different platform.

To obtain these public egress IP addresses, use the [Meta API endpoint](/docs/apis/rest-api/meta) to obtain their values.

## Network security considerations

When using Buildkite hosted agents, be aware of the following network security considerations:

- Since the infrastructure of Buildkite hosted agents is shared among all Buildkite customers, the IP address ranges for Buildkite hosted agents originate from a common source, and could be shared between different customers' configured hosted agents.

- Buildkite Agents (regardless of whether they are part of a [Buildkite hosted or self-hosted environment and architecture](/docs/pipelines/architecture)) connect to the Buildkite platform through regular public internet connections using HTTPS, through allowlisted IP addresses.

- All communications use TLS encryption for data in transit.

- If using a split tunnel or egress-controlled VPN, or both, keep internal fetches on the VPN, while letting Buildkite hosted agents communicate with the Buildkite platform over the public internet using HTTPS. Use NAT with a small, documented egress range for auditability.

- If you've configured webhooks and allowlists for [source control management (SCM) systems](/docs/pipelines/source-control), such as [GitHub Enterprise Server](/docs/pipelines/source-control/github-enterprise) or similar, set the [Buildkite platform's IP addresses](#buildkite-platform-ip-addresses) in these allowlists for status updates, and allow your SCM to post webhooks to `webhook.buildkite.com`. Alternatively, restrict the Buildkite platform to only accept webhooks from your outbound NAT IP addresses.

- When configuring Buildkite hosted agents to connect to internal services, many customers typically allowlist [Buildkite platform egress IP addresses](#buildkite-platform-ip-addresses) to reach internal Git systems, artifact stores, scanners (for example, static code analysis tools), or provide bridges using VPN or zero-trust tunnel (for example, [Tailscale](https://tailscale.com/) or a connector) which are scoped to specific internal services. These would narrow down the exposure of Buildkite hosted agents to your internal systems, while providing the benefits of network configuration elasticity.

### Network segmentation best practices

Buildkite hosted agents are capable of providing secure build environments that is suitable for building most customers' products, as hosted agents can be more convenient and less expensive to manage than [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture). However, for organizations building products with strict security requirements, the recommendation is to use self-hosted agents to build these products.

Therefore, for the sake of convenience, cost and security, your organization may consist of a blended build environment, where some products are built using Buildkite hosted agents, and other products (where strict networking segmentation is required) are built using [Buildkite Agents](/docs/agent/v3) configured in your own self-hosted environments. Such a setup allows you to:

- Control network security rules directly.

- Implement dedicated VPN connections if required.

- Maintain network boundaries protected by your own security controls.

While Buildkite Agents themselves do not require VPN software (because the agents communicate with the Buildkite platform over HTTPS), your internal systems can be protected behind VPN or firewall rules that only allow connections from allowlisted IP ranges.

If you are running self-hosted agents inside your network, run these Buildkite Agents on subnets behind your VPN or in your virtual private clouds (VPCs). Buildkite Agents only make outbound requests using HTTPS to the `agent.buildkite.com` address, and hence, there is no need to configure inbound connections for such communication. This helps keep code, secrets and internal traffic maintained within your local environments.
