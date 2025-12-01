# Terraform setup for the Elastic CI Stack for GCP

This guide helps you to get started with the [Elastic CI Stack for GCP](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp) using [Terraform](https://www.terraform.io/).

Elastic CI Stack for GCP allows you to launch a private, autoscaling [Buildkite Agent cluster](/docs/pipelines/clusters) in your own GCP project.

## Before you start

Before deploying the Elastic CI Stack for GCP, review the prerequisites, required skills, and billable services to ensure you have the necessary tools, knowledge, and budget planning in place.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) version >= 1.0
- [Buildkite Account](https://buildkite.com/signup)
- [GCP Account](https://cloud.google.com/) with a project
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) configured

### Required and recommended skills

The Elastic CI Stack for GCP does not require familiarity with the underlying GCP services to deploy it. However, to run builds, some familiarity with the following GCP services is recommended:

- [Google Compute Engine](https://cloud.google.com/products/compute) (to select a `machine_type` appropriate for your workload)
- [Google Cloud Storage](https://cloud.google.com/storage) (for storing build artifacts)
- [Secret Manager](https://cloud.google.com/security/products/secret-manager) (for storing the Buildkite Agent token securely)

Elastic CI Stack for GCP provides defaults and pre-configurations suited for most use cases without the need for additional customization. Still, you'll benefit from familiarity with VPCs, Cloud NAT, and firewall rules for custom instance networking.

For post-deployment diagnostic purposes, deeper familiarity with Compute Engine is recommended to be able to access the instances launched to execute Buildkite jobs over SSH or [Identity-Aware Proxy](https://cloud.google.com/iap/docs).

### Billable services

The Elastic CI Stack for GCP template deploys several billable GCP services that do not require upfront payment and operate on a pay-as-you-go principle, with the bill proportional to usage.

| Service name     | Purpose                                         | Required |
| ---------------- | ----------------------------------------------- | -------- |
| Compute Engine   | Deployment of VM instances                      | ☑️       |
| Persistent Disk  | Root disk storage of VM instances               | ☑️       |
| Cloud Functions  | Publishing queue metrics for autoscaling        | ☑️       |
| Secret Manager   | Storing the Buildkite agent token (recommended) | ☑️       |
| Cloud Logging    | Logs for instances and Cloud Function           | ☑️       |
| Cloud Monitoring | Metrics for autoscaling                         | ☑️       |
| Cloud NAT        | Outbound internet access for instances          | ☑️       |
| Cloud Storage    | Build artifacts storage (if enabled)            | ❌       |

Buildkite services are billed according to your [plan](https://buildkite.com/pricing).

### What's on each machine?

When using the default Debian 12 base image, each machine includes:

- [Debian 12 (Bookworm)](https://www.debian.org/releases/bookworm/)
- [The Buildkite Agent](/docs/agent/v3)
- [Git](https://git-scm.com/)
- [gcloud CLI](https://cloud.google.com/sdk/gcloud) - useful for performing any ops-related tasks
- [jq](https://stedolan.github.io/jq/) - useful for manipulating JSON responses from CLI tools

> 🚧 Manual VM configuration may be required
> The default base image is minimal and may require additional manual configuration on the VM instances after deployment. For production use, build a [custom Packer image](#custom-images) that includes Docker, Docker Compose, and any other tools your builds require. Custom images ensure all required tools and configurations are present before instance launch and prevent instances from losing manual changes when agents restart.

When using a custom Packer image, each machine also includes:

- [Docker](https://www.docker.com)
- [Docker Compose v2](https://docs.docker.com/compose/)
- [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)

For more details on what versions are installed, see the corresponding [Packer templates](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/tree/main/packer).

The Buildkite agent runs as user `buildkite-agent`.

### Supported builds

This stack is designed to run your builds in a shared-nothing pattern similar to the [12 factor application principles](http://12factor.net):

- Each project should encapsulate its dependencies through Docker and Docker Compose.
- Build pipeline steps should assume no state on the machine (and instead rely on the [build meta-data](/docs/pipelines/build-meta-data), [build artifacts](/docs/pipelines/artifacts), or Cloud Storage).
- Secrets are configured using environment variables exposed using Secret Manager.

By following these conventions, you get a scalable, repeatable, and source-controlled CI environment that any team within your organization can use.

## Custom images

> 📘 Recommended for production
> Building a custom image is recommended for production deployments. Custom images ensure that your agents have all required tools and configurations before instance launch, preventing the need for manual VM configuration after deployment. This also prevents instances from reverting to the base image state when agents restart, which would lose any manual changes made during run time.

### Requirements

To use the Packer templates provided, you will need to install the following installed on your system:

- Docker
- Make
- gcloud CLI

The following GCP IAM permissions are required for building custom images using the provided Packer templates:

```json
{
  "title": "Packer Image Builder",
  "description": "Permissions required to build VM images with Packer",
  "includedPermissions": [
    "compute.disks.create",
    "compute.disks.delete",
    "compute.disks.get",
    "compute.disks.use",
    "compute.images.create",
    "compute.images.delete",
    "compute.images.get",
    "compute.images.useReadOnly",
    "compute.instances.create",
    "compute.instances.delete",
    "compute.instances.get",
    "compute.instances.setMetadata",
    "compute.instances.setServiceAccount",
    "compute.machineTypes.get",
    "compute.networks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.zones.get",
    "iam.serviceAccounts.actAs"
  ]
}
```

It is also recommended that you have a base knowledge of:

- [Packer](https://developer.hashicorp.com/packer/docs/intro)
- [HashiCorp Configuration Language (HCL)](https://github.com/hashicorp/hcl)
- Bash scripting

### Creating an image

To create a custom image with Docker support (recommended for production):

```bash
cd packer
./build --project-id your-gcp-project-id
```

This builds a Debian 12-based image with:

- Pre-installed Buildkite Agent
- Docker Engine with Compose v2 and Buildx
- Multi-architecture build support
- Automated Docker garbage collection
- Disk space monitoring and self-protection
- Centralized logging with Ops Agent

For more details, see [packer/README.md](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/blob/main/packer/README.md).

## Deploying the stack

This section walks through the deployment process step by step, from obtaining your agent token to initializing and applying your Terraform configuration.

> 🚧 Post-deployment configuration
> After deploying the stack with Terraform, you may need to manually configure the VM instances with additional tools or settings required for your builds. The default base image includes only the Buildkite Agent and basic tools. For production deployments, consider building a [custom Packer image](#custom-images) with all required tools pre-installed to avoid manual configuration.

### Step 1: Get your Buildkite agent token

Go to the [Agents page](https://buildkite.com/organizations/-/agents) in the Buildkite Pipelines web interface and click **Reveal Agent Token**:

The agent token is used to register agents with your Buildkite organization.

### Step 2: Store the token in Secret Manager (recommended)

For production deployments, store the token in Secret Manager:

```bash
echo -n "your-agent-token" | gcloud secrets create buildkite-agent-token \
  --data-file=- \
  --project=your-project-id

# Verify the secret was created
gcloud secrets describe buildkite-agent-token --project=your-project-id
```

### Step 3: Create your Terraform configuration

Create a new directory for your Terraform configuration:

```bash
mkdir buildkite-gcp-stack
cd buildkite-gcp-stack
```

Create a `main.tf` file:

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0, < 8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # Required
  project_id                  = var.project_id
  buildkite_organization_slug = var.buildkite_organization_slug
  buildkite_agent_token_secret = "projects/${var.project_id}/secrets/buildkite-agent-token/versions/latest"

  # Stack configuration
  stack_name      = "buildkite"
  buildkite_queue = "default"
  region          = var.region

  # Scaling configuration
  min_size = 0
  max_size = 10

  # Instance configuration
  machine_type = "e2-standard-4"
}
```

Create a `variables.tf` file:

```hcl
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "buildkite_organization_slug" {
  description = "Buildkite organization slug"
  type        = string
}
```

Create a `terraform.tfvars` file:

```hcl
project_id                  = "your-gcp-project-id"
region                      = "us-central1"
buildkite_organization_slug = "your-org-slug"
```

Create an `outputs.tf` file (optional):

```hcl
output "network_name" {
  description = "Name of the VPC network"
  value       = module.buildkite_stack.network_name
}

output "instance_group_name" {
  description = "Name of the managed instance group"
  value       = module.buildkite_stack.instance_group_manager_name
}

output "agent_service_account_email" {
  description = "Email of the agent service account"
  value       = module.buildkite_stack.agent_service_account_email
}
```

### Step 4: Initialize and deploy

- Authenticate with GCP:

```bash
gcloud auth application-default login
```

- Initialize Terraform:

```bash
terraform init
```

- Review the planned changes:

```bash
terraform plan
```

- Deploy the stack:

```bash
terraform apply
```

- Type `yes` when prompted to confirm the deployment.

The module will create:

- VPC network with Cloud NAT
- IAM service accounts with appropriate permissions
- Managed instance group with Buildkite agents
- Cloud Function for autoscaling metrics
- Health checks and autoscaling based on queue depth

## Advanced configuration

This section covers some of the configurations you might want to use for a deeper customization of your stack.

### Using a custom VM image

If you built a custom Packer image with Docker support:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  # Use custom image family
  image = "buildkite-ci-stack"
}
```

### Configuring agent tags

Target specific agents in your pipeline steps using tags:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  buildkite_agent_tags = "docker=true,os=linux,environment=production"
}
```

Then in your `pipeline.yml`, set the following:

```yaml
steps:
  - command: echo "hello from production"
    agents:
      queue: "default"
      environment: "production"
```

For more information, see [Buildkite Agent job queues](/docs/agent/v3/queues).

### Multiple queues

To create multiple agent pools with different configurations, deploy multiple stacks with different queue names:

```hcl
# Production stack
module "buildkite_stack_production" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  stack_name      = "buildkite-production"
  buildkite_queue = "production"
  machine_type    = "e2-standard-4"
  max_size        = 20

  # ... other configuration ...
}

# Build stack for larger builds
module "buildkite_stack_builds" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  stack_name      = "buildkite-builds"
  buildkite_queue = "builds"
  machine_type    = "n1-standard-8"
  max_size        = 10

  # ... other configuration ...
}
```

### Enabling Cloud Storage access

If your builds need to upload/download artifacts to Cloud Storage:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  enable_storage_access = true
}
```

### Using IAP for secure SSH access

Enable Identity-Aware Proxy for secure SSH access without external IPs:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  enable_iap_access = true
}
```

Then connect to instances:

```bash
gcloud compute ssh INSTANCE_NAME \
  --zone ZONE \
  --tunnel-through-iap \
  --project PROJECT_ID
```

### Restricting SSH access

Restrict SSH access to specific IP ranges:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  enable_ssh_access  = true
  ssh_source_ranges  = ["203.0.113.0/24"]  # Your office IP range
}
```

### Adding resource labels

Add labels for cost tracking and organization:

```hcl
module "buildkite_stack" {
  source  = "buildkite/elastic-ci-stack-for-gcp/buildkite"
  version = ">= 0.1.0"

  # ... other configuration ...

  labels = {
    team        = "platform"
    environment = "production"
    cost-center = "engineering"
  }
}
```

## Updating the stack

To update your stack configuration:

- Modify your Terraform configuration files
- Review the changes:

```bash
terraform plan
```

- Apply the changes:

```bash
terraform apply
```

Terraform will automatically perform rolling updates to minimize disruption:

- New instances will be created with the updated configuration
- Old instances will be drained and terminated
- The process of updating the stack respects `max_surge` and `max_unavailable` settings

## Destroying the stack

To tear down the entire stack, use:

```bash
terraform destroy
```

## Additional information

To gain a better understanding of how Elastic CI Stack for GCP works and how to use it most effectively and securely, check out the following resources:

- [GitHub repo for Elastic CI Stack for GCP](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp)
- [Configuration parameters for Elastic CI Stack for GCP](/docs/agent/v3/gcp/elastic-ci-stack/configuration-parameters)
