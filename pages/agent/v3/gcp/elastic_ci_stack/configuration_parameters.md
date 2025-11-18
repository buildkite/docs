# Configuration parameters

The Elastic CI Stack for GCP can be configured using Terraform variables. This page provides a complete reference of all available configuration options.

The following tables list all of the available configuration parameters as Terraform variables in the [root module](https://github.com/buildkite/elastic-ci-stack-for-gcp).

Note that you must provide values for the required parameters (`project_id`, `buildkite_organization_slug`, and `buildkite_agent_token` or `buildkite_agent_token_secret`) to use the stack. All other parameters are optional and have sensible defaults.

## Required configuration

| Variable | Type | Description |
|----------|------|-------------|
| `project_id` | `string` | GCP project ID where the Elastic CI Stack will be deployed. Must be 6-30 characters, start with a letter, contain only lowercase letters, numbers, and single hyphens, and cannot contain the word 'google'. |
| `buildkite_organization_slug` | `string` | Buildkite organization slug (from your Buildkite URL: `https://buildkite.com/<org-slug>`). Used for metrics namespacing. Must contain only lowercase letters, numbers, and hyphens. |
| `buildkite_agent_token` | `string` (sensitive) | Buildkite agent registration token from your Buildkite organization. Get this from: Buildkite Dashboard → Agents → Reveal Agent Token. Leave empty if using `buildkite_agent_token_secret`. |

## Stack configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `stack_name` | `string` | `"buildkite"` | Name prefix for all resources in this stack. Used to identify and organize resources. Must be a valid GCP resource name: lowercase letters, numbers, and hyphens only. |
| `region` | `string` | `"us-central1"` | GCP region where resources will be deployed (for example, 'us-central1', 'europe-west1'). |
| `zones` | `list(string)` | `null` | List of availability zones within the region for high availability. If not specified, uses all zones in the region. |

## Buildkite configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `buildkite_agent_token_secret` | `string` | `""` | Alternative to `buildkite_agent_token`: GCP Secret Manager secret name containing the Buildkite agent token (for example, 'projects/PROJECT_ID/secrets/buildkite-agent-token/versions/latest'). Recommended for production. |
| `buildkite_queue` | `string` | `"default"` | Buildkite queue name that agents will listen to. Agents in this stack will only pick up jobs targeting this queue. |
| `buildkite_agent_tags` | `string` | `""` | Additional tags for Buildkite agents (comma-separated key=value pairs, for example, 'docker=true,os=linux'). Use these to target specific agents in pipeline steps. |
| `buildkite_agent_release` | `string` | `"stable"` | Buildkite agent release channel. **Allowed values**: `stable` (recommended), `beta`, `edge`. |
| `buildkite_api_endpoint` | `string` | `"https://agent.buildkite.com/v3"` | Buildkite API endpoint URL. Only change if using a custom endpoint. |

## Instance configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `machine_type` | `string` | `"e2-standard-4"` | GCP machine type for agent instances (for example, 'e2-standard-4', 'n1-standard-2', 'c2-standard-4'). See: [GCP Machine Types](https://cloud.google.com/compute/docs/machine-types). Must be a valid GCP machine type. |
| `image` | `string` | `"debian-cloud/debian-12"` | Source image for boot disk. Use a custom Packer-built image or a public Debian image. |
| `root_disk_size_gb` | `number` | `50` | Size of the root disk in GB. Increase for larger Docker images or build artifacts. **Range**: 10-65536 GB. |
| `root_disk_type` | `string` | `"pd-balanced"` | Type of root disk. **Allowed values**: `pd-standard` (cheaper, slower), `pd-balanced` (recommended), `pd-ssd` (fastest). |

## Scaling configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `min_size` | `number` | `0` | Minimum number of agent instances. Set to 0 to scale to zero when idle (cost-effective) or higher for always-available capacity. Must be ≥ 0. |
| `max_size` | `number` | `10` | Maximum number of agent instances. Controls cost ceiling and maximum parallelization. Must be ≥ 1. |
| `enable_autoscaling` | `bool` | `true` | Enable autoscaling based on Buildkite job queue metrics. Requires buildkite-agent-metrics Cloud Function to be deployed. |
| `cooldown_period` | `number` | `60` | Cooldown period in seconds between autoscaling actions to prevent flapping. Must be ≥ 30. |
| `autoscaling_jobs_per_instance` | `number` | `1` | Target number of Buildkite jobs per instance for autoscaling. Lower values = more parallelization, higher cost. Must be ≥ 1. |

## Networking configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `network_name` | `string` | `"elastic-ci-stack"` | Name of the VPC network to create. The stack will create a new VPC with this name. Must be a valid GCP resource name: lowercase letters, numbers, and hyphens only. |
| `enable_ssh_access` | `bool` | `true` | Enable SSH access to instances via firewall rule. Set to false for additional security. |
| `ssh_source_ranges` | `list(string)` | `["0.0.0.0/0"]` | CIDR blocks allowed to SSH to instances. Restrict to your IP for security (for example, ['203.0.113.0/24']). Only used if `enable_ssh_access` is true. All values must be valid CIDR blocks. |
| `instance_tag` | `string` | `"elastic-ci-agent"` | Network tag applied to instances for firewall targeting. Generally no need to change. Must be a valid GCP network tag. |
| `enable_iap_access` | `bool` | `false` | Enable Identity-Aware Proxy (IAP) for secure SSH without external IPs or VPN. |
| `enable_secondary_ranges` | `bool` | `false` | Enable secondary IP ranges for future GKE support. |

## IAM configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `agent_service_account_id` | `string` | `"elastic-ci-agent"` | ID for the Buildkite agent service account. Generally no need to change. Must be 6-30 characters, lowercase letters, digits, and hyphens only. |
| `metrics_service_account_id` | `string` | `"elastic-ci-metrics"` | ID for the metrics function service account. Generally no need to change. Must be 6-30 characters, lowercase letters, digits, and hyphens only. |
| `agent_custom_role_id` | `string` | `"elasticCiAgentInstanceMgmt"` | ID for the custom IAM role for agent instance management. Generally no need to change. Must be 3-64 characters, letters, numbers, underscores, and periods only. |
| `metrics_custom_role_id` | `string` | `"elasticCiMetricsAutoscaler"` | ID for the custom IAM role for metrics autoscaling. Generally no need to change. Must be 3-64 characters, letters, numbers, underscores, and periods only. |
| `enable_secret_access` | `bool` | `true` | Grant agents access to Secret Manager. Enable if your builds need to access secrets. |
| `enable_storage_access` | `bool` | `false` | Grant agents access to Cloud Storage. Enable if your builds need to upload/download artifacts. |

## Health check configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_autohealing` | `bool` | `true` | Enable automatic replacement of unhealthy instances. |
| `health_check_port` | `number` | `22` | Port for health checks (22 for SSH, or custom port if running health endpoint). **Range**: 1-65535. |
| `health_check_interval_sec` | `number` | `30` | How often (in seconds) to perform health checks. Must be ≥ 1. |
| `health_check_timeout_sec` | `number` | `10` | How long (in seconds) to wait for health check response before marking as failed. Must be ≥ 1. |
| `health_check_healthy_threshold` | `number` | `2` | Number of consecutive successful health checks before marking instance healthy. Must be ≥ 1. |
| `health_check_unhealthy_threshold` | `number` | `3` | Number of consecutive failed health checks before marking instance unhealthy. Must be ≥ 1. |
| `health_check_initial_delay_sec` | `number` | `300` | Time (in seconds) to wait after instance start before beginning health checks. Must be ≥ 0. |

## Update policy configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `max_surge` | `number` | `3` | Maximum number of instances that can be created above target size during rolling updates. Must be ≥ 0. |
| `max_unavailable` | `number` | `0` | Maximum number of instances that can be unavailable during rolling updates. Must be ≥ 0. |

## Security configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_secure_boot` | `bool` | `false` | Enable Secure Boot for shielded VM instances (additional security, slight performance overhead). |
| `enable_vtpm` | `bool` | `true` | Enable virtual Trusted Platform Module for shielded VM instances (recommended). |
| `enable_integrity_monitoring` | `bool` | `true` | Enable integrity monitoring for shielded VM instances (recommended). |

## Additional configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `labels` | `map(string)` | `{}` | Additional labels to apply to all resources for organization and billing. |

## Example configuration

Here's an example `terraform.tfvars` file with commonly used parameters:

```hcl
# Required
project_id                  = "my-gcp-project"
buildkite_organization_slug = "my-org"
buildkite_agent_token_secret = "buildkite-agent-token" # Secret Manager secret name

# Stack identification
stack_name = "buildkite-production"
region     = "us-central1"

# Buildkite configuration
buildkite_queue      = "default"
buildkite_agent_tags = "docker=true,os=linux,environment=production"

# Instance configuration
machine_type      = "e2-standard-4"
root_disk_size_gb = 100
root_disk_type    = "pd-balanced"

# Scaling
min_size = 1
max_size = 20

# Security
enable_ssh_access  = true
ssh_source_ranges  = ["203.0.113.0/24"]  # Your office IP range
enable_iap_access  = true

# Permissions
enable_secret_access  = true
enable_storage_access = true

# Labels for cost tracking
labels = {
  team        = "platform"
  environment = "production"
  cost-center = "engineering"
}
```

## Using Secret Manager for Agent token

For production deployments, it's recommended to store the Buildkite agent token in Secret Manager:

1. Create a secret in Secret Manager:

```bash
echo -n "your-agent-token" | gcloud secrets create buildkite-agent-token \
  --data-file=- \
  --project=your-project-id
```

2. Configure the stack to use the secret:

```hcl
# In terraform.tfvars
buildkite_agent_token_secret = "projects/your-project-id/secrets/buildkite-agent-token/versions/latest"
```

## Module-specific parameters

For more detailed configuration options at the module level, see:

- [Networking Module Variables](https://github.com/buildkite/elastic-ci-stack-for-gcp/tree/main/modules/networking#inputs)
- [IAM Module Variables](https://github.com/buildkite/elastic-ci-stack-for-gcp/tree/main/modules/iam#inputs)
- [Compute Module Variables](https://github.com/buildkite/elastic-ci-stack-for-gcp/tree/main/modules/compute#inputs)
- [Buildkite Agent Metrics Module Variables](https://github.com/buildkite/elastic-ci-stack-for-gcp/tree/main/modules/buildkite-agent-metrics#inputs)
