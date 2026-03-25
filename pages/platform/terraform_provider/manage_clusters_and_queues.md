# Manage clusters and queues

The [Buildkite Terraform provider](/docs/platform/terraform-provider) supports managing [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), [agent tokens](/docs/agent/self-hosted/tokens), default queues, and cluster maintainers as Terraform resources. This page covers how to define and configure these resources in your Terraform configuration files.

## Define your cluster resources

Define Buildkite cluster resources for the clusters in your Buildkite organization that you want to manage in Terraform, in HCL (for example, `clusters.tf`).

The  `buildkite_cluster` resource is used to create and manage clusters. Each cluster requires a `name` argument and can optionally include `description`, `emoji`, and `color` arguments.

If you don't have a pre-existing cluster in your Buildkite organization but want to associate a pipeline in your [pipeline resources (`pipelines.tf` file)](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources) with a new cluster managed by the Terraform provider, you can define the new cluster in your cluster resources (`clusters.tf`) file and reference it from the pipeline resource's `cluster_id` argument.

In the following example, the **Primary cluster** will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster" "primary" {
  name        = "Primary cluster"
  description = "Runs monolith builds and deployments."
  emoji       = "\:rocket\:"
  color       = "#BADA55"
}
```

Following on from the [pipeline resources example](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources), if you wanted to make the **Frontend pipeline** use this **Primary cluster** instead of **Default cluster**, you would change this pipeline resource's `cluster_id` argument's value to `data.buildkite_cluster.primary.id`. Furthermore, if no pipelines under Terraform management use **Default cluster**, you could remove its data source from your pipeline resources `pipelines.tf` file.

Learn more about this resource in the [`buildkite_cluster` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster) documentation.

## Define your queue resources

Define Buildkite queue resources for the queues in your [clusters](#define-your-cluster-resources) that you want to manage in Terraform, within your cluster resources HCL file (for example, `clusters.tf`).

The `buildkite_cluster_queue` resource is used to create and manage queues within a cluster. Each queue requires a `cluster_id` and a `key` argument to uniquely identify the queue, and can optionally include a `description` argument.

Learn more about this resource in the [`buildkite_cluster_queue` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_queue) documentation.

### Self-hosted queues

If your Buildkite organization uses [self-hosted agents](/docs/agent/self-hosted), you can configure [self-hosted queues](/docs/agent/queues/managing#create-a-self-hosted-queue) for these agents.

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s **default** and **deployment** queues will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster_queue" "default" {
  cluster_id = buildkite_cluster.primary.id
  key        = "default"
}

resource "buildkite_cluster_queue" "deployment" {
  cluster_id  = buildkite_cluster.primary.id
  key         = "deployment"
  description = "Queue for deployment jobs."
}
```

You can also optionally set the following arguments for self-hosted queues:

- `dispatch_paused` with a value of `true` to pause job dispatch on the queue after creation. This is useful when you want to set up agents before the queue starts accepting jobs. See [Pause and resume an agent](/docs/agent/self-hosted/pausing-and-resuming) for more information about this feature.

- `retry_agent_affinity` with a value of `prefer-warmest` (default) to prefer agents that recently finished jobs, or `prefer-different` to prefer a different agent on retry. See [Retry agent affinity](/docs/agent/self-hosted/prioritization#retry-agent-affinity) for more information about this feature.

### Buildkite hosted queues

If your Buildkite organization uses [Buildkite hosted agents](/docs/agent/buildkite-hosted), you can configure [Buildkite hosted queues](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) for these agents by including the `hosted_agents` attribute with an `instance_shape` value.

#### Linux hosted agents

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s **hosted-linux** queue for a [Linux hosted agent](/docs/agent/buildkite-hosted/linux) will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster_queue" "hosted_linux" {
  cluster_id = buildkite_cluster.primary.id
  key        = "hosted-linux"

  hosted_agents = {
    instance_shape = "LINUX_AMD64_2X4"

    linux = {
      agent_image_ref = "ubuntu:24.04"
    }
  }
}
```

When defining Buildkite hosted queues for Linux hosted agents:

- See the [Sizes section of Linux hosted agents](/docs/agent/buildkite-hosted/linux#sizes) for the available `instance_shape` argument values.

- The optional `linux` argument and its required `agent_image_ref` value relates to the [custom image feature](/docs/agent/buildkite-hosted/linux/custom-agent-images#use-an-agent-image-specify-a-custom-image-for-a-queue) for this queue.

#### macOS hosted agents

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s **hosted-macos** queue for a [macos hosted agent](/docs/agent/buildkite-hosted/macos) will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster_queue" "hosted_macos" {
  cluster_id = buildkite_cluster.primary.id
  key        = "hosted-macos"

  hosted_agents = {
    instance_shape = "MACOS_ARM64_M4_6X28"

    mac = {
      xcode_version = "16.2"
    }
  }
}
```

When defining Buildkite hosted queues for macOS hosted agents:

- See the [Sizes section of macos hosted agents](/docs/agent/buildkite-hosted/macos#sizes) for the available `instance_shape` argument values.

- The optional `mac` argument and its required `xcode_version` value relates to the experimental feature to select macOS agents based on the [Xcode version](/docs/agent/buildkite-hosted/macos#macos-instance-software-support) they support.

## Define your default queue resources

If your Buildkite clusters have more than one queue, define your default queue for each such cluster as separate default queue resources for the [clusters](#define-your-cluster-resources) you want to manage in Terraform, in HCL (for example, `clusters.tf`).

Use the `buildkite_cluster_default_queue` resource to designate which queue in a cluster receives jobs whose pipeline steps don't specify a queue.



```hcl
resource "buildkite_cluster_default_queue" "primary" {
  cluster_id = buildkite_cluster.primary.id
  queue_id   = buildkite_cluster_queue.default.id
}
```

Learn more about this resource in the [`buildkite_cluster_default_queue` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_default_queue) documentation.

## Create agent tokens

Use the `buildkite_cluster_agent_token` resource to create [agent tokens](/docs/agent/self-hosted/tokens) that self-hosted agents use to connect to a cluster.

```hcl
resource "buildkite_cluster_agent_token" "default" {
  description = "Default agent token"
  cluster_id  = buildkite_cluster.primary.id
}
```

You can restrict which IP addresses are allowed to use a token by specifying `allowed_ip_addresses` with a list of CIDR-notation IPv4 addresses:

```hcl
resource "buildkite_cluster_agent_token" "restricted" {
  description          = "Token restricted to internal network"
  cluster_id           = buildkite_cluster.primary.id
  allowed_ip_addresses = ["192.0.2.0/24"]
}
```

Learn more about this resource in the [`buildkite_cluster_agent_token` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_agent_token) documentation.

## Manage cluster maintainers

Use the `buildkite_cluster_maintainer` resource to grant users or teams permission to manage a cluster. Specify either a `user_uuid` or `team_uuid`, but not both.

```hcl
# Add a team as a cluster maintainer
resource "buildkite_cluster_maintainer" "platform_team" {
  cluster_uuid = buildkite_cluster.primary.uuid
  team_uuid    = "01234567-89ab-cdef-0123-456789abcdef"
}
```

Learn more about this resource in the [`buildkite_cluster_maintainer` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_maintainer) documentation.

## Manage cluster secrets

Use the `buildkite_cluster_secret` resource to create encrypted key-value pairs accessible by agents within a cluster. You can define a YAML access policy to control which pipelines and branches can access each secret.

```hcl
resource "buildkite_cluster_secret" "database_password" {
  cluster_id  = buildkite_cluster.primary.uuid
  key         = "DATABASE_PASSWORD"
  value       = var.database_password
  description = "Production database password"
  policy      = <<-EOT
    - pipeline_slug: backend-pipeline
      build_branch: main
  EOT
}
```

> 🚧 Secret values are write-only
> Secret values cannot be retrieved from the Buildkite API. When importing an existing cluster secret, you must manually set the `value` attribute in your configuration to match the actual secret value, as Terraform cannot read it from the API.

Learn more about this resource in the [`buildkite_cluster_secret` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_secret) documentation.

## Verify your completed configuration

The following example shows a complete cluster configuration with a cluster, two queues (including a default), an agent token, a team maintainer, and a secret:

```hcl
# Define the cluster
resource "buildkite_cluster" "primary" {
  name        = "Primary cluster"
  description = "Runs the monolith build and deploy."
  emoji       = "\:rocket\:"
  color       = "#BADA55"
}

# Define queues
resource "buildkite_cluster_queue" "default" {
  cluster_id = buildkite_cluster.primary.id
  key        = "default"
}

resource "buildkite_cluster_queue" "deploy" {
  cluster_id  = buildkite_cluster.primary.id
  key         = "deploy"
  description = "Queue for deployment jobs."
}

# Set the default queue
resource "buildkite_cluster_default_queue" "primary" {
  cluster_id = buildkite_cluster.primary.id
  queue_id   = buildkite_cluster_queue.default.id
}

# Create an agent token
resource "buildkite_cluster_agent_token" "default" {
  description = "Default agent token"
  cluster_id  = buildkite_cluster.primary.id
}

# Add a team as a cluster maintainer
resource "buildkite_cluster_maintainer" "platform_team" {
  cluster_uuid = buildkite_cluster.primary.uuid
  team_uuid    = "01234567-89ab-cdef-0123-456789abcdef"
}

# Define a cluster secret
resource "buildkite_cluster_secret" "database_password" {
  cluster_id  = buildkite_cluster.primary.uuid
  key         = "DATABASE_PASSWORD"
  value       = var.database_password
  description = "Production database password"
  policy      = <<-EOT
    - pipeline_slug: backend-pipeline
      build_branch: main
  EOT
}
```

## Further reference

For the full list of cluster and queue resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
