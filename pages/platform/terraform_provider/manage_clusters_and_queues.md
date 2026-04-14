# Manage clusters and queues

The [Buildkite Terraform provider](/docs/platform/terraform-provider) supports managing [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), [agent tokens](/docs/agent/self-hosted/tokens), default queues, [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster), and [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) as Terraform resources. This page covers how to define and configure these resources in your Terraform configuration files.

## Define your cluster resources

Define resources for the [clusters](/docs/pipelines/security/clusters) in your Buildkite organization that you want to manage in Terraform, in HCL (for example, `clusters.tf`).

The  `buildkite_cluster` resource is used to define, create and manage clusters. Each cluster requires a `name` argument and can optionally include `description`, `emoji`, and `color` arguments.

In the following example, the **Primary cluster** will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster" "primary" {
  name        = "Primary cluster"
  description = "Runs monolith builds and deployments."
  emoji       = "\:rocket\:"
  color       = "#BADA55"
}
```

The optional arguments for each cluster are:

- `description`: A description for the cluster that helps identify its purpose, such as its usage or region.
- `emoji`: An emoji to display with the cluster, set using either `\:buildkite\:` notation or the emoji character itself (for example, 🚀).
- `color`: A color for the cluster, specified as a hex code (for example, `#BADA55`).

If you don't have a pre-existing cluster in your Buildkite organization but want to associate a pipeline in your [pipeline resources (`pipelines.tf` file)](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#define-your-initial-pipeline-resources) with a new cluster managed by the Terraform provider, you can define the new cluster in your cluster resources (`clusters.tf`) file and reference it from the pipeline resource's `cluster_id` argument.

Following on from the [pipeline resources example](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#define-your-initial-pipeline-resources), if you wanted to make the **Frontend pipeline** use this **Primary cluster** instead of **Default cluster**, you would change this pipeline resource's `cluster_id` argument's value to `data.buildkite_cluster.primary.id`. Furthermore, if no pipelines under Terraform management use **Default cluster**, you could remove its data source from your pipeline resources `pipelines.tf` file.

Learn more about this resource in the [`buildkite_cluster` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster) documentation.

## Define your queue resources

Define resources for the [queues](/docs/agent/queues) of Buildkite [clusters](#define-your-cluster-resources) that you want to manage in Terraform, within your cluster resources HCL file (for example, `clusters.tf`).

The `buildkite_cluster_queue` resource is used to define, create and manage queues within a cluster. Each queue requires a `cluster_id` and a `key` argument to uniquely identify the queue, and can optionally include a `description` argument.

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

For each of your Buildkite [clusters](#define-your-cluster-resources) (managed in Terraform) with more than one queue, define the default queue as a resource—one for each of these clusters, within your cluster resources HCL file (for example, `clusters.tf`).

Use the `buildkite_cluster_default_queue` resource to determine which queue (referenced by its `queue_id` argument) in a cluster (referenced by `cluster_id`) receives jobs whose pipeline steps don't specify a queue.

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s [self-hosted queue with the key **default**](#define-your-queue-resources-self-hosted-queues) will be made the default queue with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster_default_queue" "primary" {
  cluster_id = buildkite_cluster.primary.id
  queue_id   = buildkite_cluster_queue.default.id
}
```

Learn more about this resource in the [`buildkite_cluster_default_queue` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_default_queue) documentation.

## Define your agent tokens

For each of your Buildkite [clusters](#define-your-cluster-resources) managed in Terraform, define and create an [agent token](/docs/agent/self-hosted/tokens)—at least one for each of these clusters with [self-hosted agents](/docs/agent/self-hosted), within your cluster resources HCL file (for example, `clusters.tf`).

Use the `buildkite_cluster_agent_token` resource to define, create and manage an agent token (named by its `description` argument) that a self-hosted agent uses to connect to a cluster (referenced by `cluster_id`).

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s **Default agent token** will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_cluster_agent_token" "default" {
  description = "Default agent token"
  cluster_id  = buildkite_cluster.primary.id
}
```

You can optionally restrict which IP addresses are allowed to use a token by specifying `allowed_ip_addresses` with a list of CIDR-notation IPv4 addresses:

```hcl
resource "buildkite_cluster_agent_token" "restricted" {
  description          = "Token restricted to internal network"
  cluster_id           = buildkite_cluster.primary.id
  allowed_ip_addresses = ["192.0.2.0/24"]
}
```

The generated agent token value is stored in Terraform state and can be accessed through the resource's `token` attribute. To retrieve this value, you can either:

- Define a sensitive [Terraform output](https://developer.hashicorp.com/terraform/language/values/outputs), using the **Default agent token** example above:

    ```hcl
    output "agent_token" {
      value     = buildkite_cluster_agent_token.default.token
      sensitive = true
    }
    ```

    and retrieve the agent token's value from the command line:

    ```bash
    terraform output -raw agent_token
    ```

- Pass the agent token's value directly to a secrets manager resource within your Terraform configuration, such as [AWS Secrets Manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) or [HashiCorp Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_secret).

Learn more about this resource in the [`buildkite_cluster_agent_token` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_agent_token) documentation.

## Define cluster maintainers

For each of your Buildkite [clusters](#define-your-cluster-resources) managed in Terraform, define a [cluster maintainer](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster)—aim for at least one for each of these clusters, within your cluster resources HCL file (for example, `clusters.tf`). Otherwise, a cluster with no cluster maintainers can only be administered by a Buildkite organization administrator.

Use the `buildkite_cluster_maintainer` resource to grant users or teams permission to manage a cluster (referenced by its `cluster_uuid` argument). Specify either a Buildkite [user (referenced by `user_uuid`)](#define-cluster-maintainers-obtain-a-user-uuid) or [team (referenced by `team_uuid`)](#define-cluster-maintainers-obtain-a-team-uuid), but not both.

In the following example, the Buildkite team with UUID `01234567-89ab-cdef-0123-456789abcdef` will be made a maintainer of the [**Primary cluster**](#define-your-cluster-resources), with `terraform plan` and `terraform apply`.

```hcl
# Add a team as a cluster maintainer
resource "buildkite_cluster_maintainer" "platform_team" {
  cluster_uuid = buildkite_cluster.primary.uuid
  team_uuid    = "01234567-89ab-cdef-0123-456789abcdef"
}
```

Learn more about this resource in the [`buildkite_cluster_maintainer` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_maintainer) documentation.

### Obtain a user UUID

To find the `user_uuid` for use in a `buildkite_cluster_maintainer` resource, run the following [GraphQL](/docs/apis/graphql) query, replacing `your-buildkite-org-slug` with your Buildkite organization's slug:

```graphql
query {
  organization(slug: "your-buildkite-org-slug") {
    members(first: 100) {
      edges {
        node {
          user {
            name
            uuid
          }
        }
      }
    }
  }
}
```

### Obtain a team UUID

To find the `team_uuid` for use in a `buildkite_cluster_maintainer` resource, run the following [GraphQL](/docs/apis/graphql) query, replacing `your-buildkite-org-slug` with your Buildkite organization's slug:

```graphql
query {
  organization(slug: "your-buildkite-org-slug") {
    teams(first: 100) {
      edges {
        node {
          name
          uuid
        }
      }
    }
  }
}
```

For more GraphQL queries related to teams, see the [Teams cookbook](/docs/apis/graphql/cookbooks/teams).

## Define Buildkite secrets

For each of your Buildkite [clusters](#define-your-cluster-resources) managed in Terraform, define a [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) for the pipelines that require them, within your cluster resources HCL file (for example, `clusters.tf`).

Use the `buildkite_cluster_secret` resource to define, create and manage an encrypted key-value pair accessible by agents within a [Buildkite cluster](/docs/pipelines/security/clusters) (referenced by its `cluster_id` argument, which actually requires a cluster UUID value).

This resource requires the following arguments:

- `key`: This value is what you use to reference this secret from within your pipeline configurations. See [Create a secret](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) for more information.

- `value`: The secret's actual value. You could also implement the secret's value in a temporary `terraform.tfvars` file and define its variable in `variables.tf`, similar to your Buildkite API access token when [defining the Buildkite provider for your Terraform configuration](/docs/platform/terraform-provider#define-the-buildkite-provider-for-your-terraform-configuration).

This resource also accepts the following optional arguments:

- `description`: The secret's description, which appears just under the secret's key value on the main **Secrets** page.

- `policy`: The access policy for the Buildkite secret, use this argument to define an access policy in YAML, to control which pipelines and branches can access the secret. See [Access policies for Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) for more information.

In the following example, the [**Primary cluster**](#define-your-cluster-resources)'s `DATABASE_PASSWORD` Buildkite secret (with description **Production database password**) will be created with `terraform plan` and `terraform apply`, where this secret can only be used by the `backend` pipeline on the `main` branch of its repository.

```hcl
resource "buildkite_cluster_secret" "database_password" {
  cluster_id  = buildkite_cluster.primary.uuid
  key         = "DATABASE_PASSWORD"
  value       = var.database_password
  description = "Production database password"
  policy      = <<-EOT
    - pipeline_slug: backend
      build_branch: main
  EOT
}
```

The secret's value is stored temporarily in the `terraform.tfvars` file:

```hcl
database_password = "your-database-password-value"
```

and is defined by its variable in the `variables.tf` file:

```hcl
variable "database_password" {
  type      = string
  sensitive = true
}
```

> 🚧 Secret values are write-only to the Buildkite platform
> Secret values cannot be retrieved using the Buildkite API. If you import an existing Buildkite secret resource to Terraform, you must manually set its `value` attribute in your configuration to match the actual secret value, as Terraform will not be able to read this value from the Buildkite API.

Learn more about this resource in the [`buildkite_cluster_secret` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/cluster_secret) documentation.

## Verify your completed clusters.tf file configuration

The following example shows a complete cluster configuration with a single Buildkite cluster, two self-hosted queues (including a default), an agent token, a team maintainer, and a Buildkite secret:

```hcl
# Define the 'primary' cluster
resource "buildkite_cluster" "primary" {
  name        = "Primary cluster"
  description = "Runs the monolith build and deploy."
  emoji       = "\:rocket\:"
  color       = "#BADA55"
}

# Define its self-hosted queues
resource "buildkite_cluster_queue" "default" {
  cluster_id = buildkite_cluster.primary.id
  key        = "default"
}

resource "buildkite_cluster_queue" "deployment" {
  cluster_id  = buildkite_cluster.primary.id
  key         = "deployment"
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

## Applying the configuration

Once your `clusters.tf` file is complete, it is ready to be [applied to your Buildkite organization](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#applying-the-configuration).

## Further reference

For the full list of cluster and queue resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
