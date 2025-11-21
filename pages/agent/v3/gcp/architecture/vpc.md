# VPC design for the Elastic CI Stack for GCP

Agent orchestration deployments on GCP require a Virtual Private Cloud (VPC) network.

Your VPC needs to provide routable access to the `buildkite.com` service to allow `buildkite-agent` processes to connect and retrieve the jobs assigned to them.

## Network architecture

The Elastic CI Stack for GCP creates a custom VPC network with:

- **Custom VPC**: `10.0.0.0/16` CIDR block
- **Subnet 0**: `10.0.1.0/24` primary subnet
- **Subnet 1**: `10.0.2.0/24` secondary subnet for high availability
- **Cloud NAT**: outbound internet access without external IPs
- **Cloud Router**: dynamic routing

Both subnets have Private Google Access enabled, allowing instances to access Google APIs without external IP addresses.

## Firewall rules

The stack creates several firewall rules:

- **Internal communication** - allows all traffic between instances (`10.0.0.0/16`).
- **SSH access** (optional) - is controlled by `enable_ssh_access` and `ssh_source_ranges`.
- **Health checks** - allows Google health check probes (`35.191.0.0/16`, `130.211.0.0/22`).
- **Identity-Aware Proxy** (optional) - when `enable_iap_access = true`, it enables secure SSH via IAP (`35.235.240.0/20`).

## Network security options

It is recommended to use private instances with IAP access:

```hcl
enable_ssh_access = false
enable_iap_access = true
```

Alternatively, you can restrict SSH to specific IPs:

```hcl
enable_ssh_access = true
ssh_source_ranges = ["111.222.0.1/24"]  # Your desired IP range, for example, the IP range of your office
```

## Private Google access

Be aware that both subnets have Private Google Access enabled, allowing instances without external IPs to access:

- Cloud Storage
- Secret Manager
- Cloud Logging
- Cloud Monitoring
- Artifact Registry

Traffic stays within Google's network, providing better network performance than when using resource external to the VPC, and no egress charges.
