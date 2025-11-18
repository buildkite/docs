# VPC design for the Elastic CI Stack for GCP

Agent orchestration deployments on GCP require a Virtual Private Cloud (VPC) network.

Your VPC needs to provide routable access to the buildkite.com service so that `buildkite-agent` processes can connect and retrieve the jobs assigned to them.

## Network architecture

The Elastic CI Stack for GCP creates a custom VPC network with:

- **Custom VPC**: `10.0.0.0/16` CIDR block
- **Subnet 0**: `10.0.1.0/24` - Primary subnet
- **Subnet 1**: `10.0.2.0/24` - Secondary subnet for high availability
- **Cloud NAT**: Provides outbound internet access without external IPs
- **Cloud Router**: Enables dynamic routing

Both subnets have Private Google Access enabled, allowing instances to access Google APIs without external IP addresses.

## Firewall rules

The stack creates several firewall rules:

- **Internal communication** - Allows all traffic between instances (`10.0.0.0/16`)
- **SSH access** (optional) - Controlled by `enable_ssh_access` and `ssh_source_ranges`
- **Health checks** - Allows Google health check probes (`35.191.0.0/16`, `130.211.0.0/22`)
- **Identity-Aware Proxy** (optional) - When `enable_iap_access = true`, enables secure SSH via IAP (`35.235.240.0/20`)

## Network security options

**Recommended**: Private instances with IAP access:

```hcl
enable_ssh_access = false
enable_iap_access = true
```

Or restrict SSH to specific IPs:

```hcl
enable_ssh_access = true
ssh_source_ranges = ["111.222.0.1/24"]  # Your office
```

## Private Google access

Both subnets have Private Google Access enabled, allowing instances without external IPs to access:

- Cloud Storage
- Secret Manager
- Cloud Logging
- Cloud Monitoring
- Artifact Registry

Traffic stays within Google's network, providing better performance and no egress charges.
