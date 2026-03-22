# Terraform provider

The [Buildkite Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) lets you manage your Buildkite organization's resources using [Terraform](https://www.terraform.io/) infrastructure-as-code workflows. With this provider, you can define and version-control your pipelines, teams, clusters, and other Buildkite resources alongside your application infrastructure.

The provider is open source and available on [GitHub](https://github.com/buildkite/terraform-provider-buildkite). It is listed on the [Terraform Registry](https://registry.terraform.io/providers/buildkite/buildkite/latest) and supports Terraform 1.0 and later.

## Managed resources

The Buildkite Terraform provider supports the following resource types:

- **Pipelines**: Create and configure [pipelines](/docs/pipelines), including their steps, repository settings, schedules, team access, templates, and webhooks. See [Before you start](#before-you-start) and [Getting started with managing pipelines in Terraform](#getting-started-with-managing-pipelines-in-terraform) for more information.

- **Clusters and queues**: Manage [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), cluster agent tokens, and cluster secrets.

- **Teams**: Create and manage [teams](/docs/platform/team-management) and their members.

- **Organizations**: Configure organization-level settings, rules, and banners.

- **Test suites**: Set up [Test Engine](/docs/test-engine) test suites and manage team access.

- **Package registries**: Manage [Package Registries](/docs/package-registries) resources.

- **Agent tokens**: Create and manage agent tokens for self-hosted agents.

## Before you start

The Terraform provider requires the following Buildkite configuration values:

- **API access token**: A Buildkite API access token (`BUILDKITE_API_TOKEN`) with `write_pipelines`, `read_pipelines`, and `write_suites` REST API scopes and GraphQL API access enabled. You can generate a token from your [API Access Tokens](https://buildkite.com/user/api-access-tokens) page.
- **Buildkite organization slug**: Your Buildkite organization slug, which you can find in your Buildkite URL: `https://buildkite.com/<your-buildkite-org-slug>`.
- **Cluster name/s**: Required so that Terraform can determine which Buildkite cluster/s your pipelines are associated with.
- **Team name/s** (_optional_): Required if [teams is enabled in your Buildkite organization](/docs/platform/team-management/permissions), and so that Terraform can determine which teams should be granted access to your pipelines, along with each team's permissions.

## Getting started with managing pipelines in Terraform

To start using the Buildkite Terraform provider to manage your pipelines in Terraform:

1. Define the Buildkite provider for your Terraform configuration file, along with your Buildkite API access token configuration, written in HashiCorp Configuration Language (HCL) (for example, `provider.tf`):

    ```hcl
    terraform {
      required_providers {
        buildkite = {
          source  = "buildkite/buildkite"
          version = "~> 1.0"
        }
      }
    }

    provider "buildkite" {
      api_token    = "BUILDKITE_API_TOKEN"
      organization = "your-buildkite-org-slug"
    }
    ```

    **Warning:** Avoid storing your Buildkite API access token directly in Terraform configuration files. Use an environment variable for `BUILDKITE_API_TOKEN` or manage it through a secrets manager instead. If you do wish to use your Terraform configuration to temporarily store your token's value for this procedure, you can do so by creating the following files, although _ensure you delete them_ at the end of this procedure:

    1. Configure the following additional HCL configuration file to define a variable for your API access token (for example, `variables.tf`):

        ```hcl
        variable "buildkite_api_token" {
          type      = string
          sensitive = true
        }
        ```

    1. Create the Terraform variable file to hold your API access token value (`terraform.tfvars`):

        ```hcl
        buildkite_api_token = "your-api-access-token-value"
        ```

    1. Change the value of `BUILDKITE_API_TOKEN` to `var.buildkite_api_token` in your `provider.tf` file.

1. Initialize the provider:

    ```bash
    terraform init
    ```

### Define your initial pipeline resources

Define pipeline resources for the pipelines you want to import into your Buildkite organization, again in HCL (for example, `pipelines.tf`).

In the following example, two pipelines are defined, which are part of the **Default cluster**, along with two teams (with names **Engineering** and **Design team**). The other configuration settings for these pipelines are defined through the URL path portions (appended to `https://buildkite.com/<your-buildkite-org-slug>/`), which are indicated in the comments of the first pipeline (named **Frontend pipeline**).

```hcl
# Look up the existing cluster (name) to assign pipelines to
data "buildkite_cluster" "default" {
  name = "Default cluster"
}

# Look up the existing team (name) to assign as the initial pipeline owner
data "buildkite_team" "engineering" {
  name = "Engineering"
}

# Look up the existing team (name) to assign access to pipelines
data "buildkite_team" "design_team" {
  name = "Design team"
}

# Define the frontend pipeline (through 'frontend-pipeline/settings')
resource "buildkite_pipeline" "frontend" {

  # General and infrastructure
  name            = "Frontend pipeline"
  description     = "Builds and tests the frontend application."
  default_branch  = "main"
  emoji           = "\:react\:"
  color           = "#6B6B6B"
  cluster_id      = data.buildkite_cluster.default.id

  # Pipeline steps (through 'frontend-pipeline/settings/steps')
  steps = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML

  # Build behavior (through 'frontend-pipeline/settings/builds')
  cancel_intermediate_builds               = true
  cancel_intermediate_builds_branch_filter = "!main"
  allow_rebuilds                           = true
  default_timeout_in_minutes               = 15
  maximum_timeout_in_minutes               = 30

  # Repository (through 'frontend-pipeline/settings/repository')
  repository      = "git@github.com:my-org/frontend.git"

  # Initial pipeline owner (through 'frontend-pipeline/settings/teams')
  default_team_id = data.buildkite_team.engineering.id
}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  # General and infrastructure
  name            = "Backend pipeline"
  description     = "Builds and tests the backend server."
  default_branch  = "main"
  emoji           = "\:gear\:"
  color           = "#4A4A4A"
  cluster_id      = data.buildkite_cluster.default.id

  # Pipeline steps
  steps = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML

  # Build behavior
  allow_rebuilds             = true
  default_timeout_in_minutes = 30
  maximum_timeout_in_minutes = 60

  # Repository
  repository      = "git@github.com:my-org/backend.git"

  # Initial pipeline owner
  default_team_id = data.buildkite_team.engineering.id
}
```

> 📘
> In the pipeline examples above, the actual pipeline YAML steps for each pipeline are uploaded to Buildkite Pipelines from the `.buildkite/pipeline.yml` file in each pipeline's respective repository. However, if you do manage some or all of these pipeline steps through your pipelines' `https://buildkite.com/<your-buildkite-org-slug>/<pipeline-slug>/settings/steps` pages in the Buildkite interface, you'll need to include these steps in the `steps` definition blocks of the respective pipelines in this `pipelines.tf` file (above).

### Add your repository provider settings

Add the required `provider_settings` blocks for each pipeline definition in this file. For example, assuming both pipelines are configured to build a repository in GitHub with the following **GitHub Settings** accessed through `https://buildkite.com/<your-buildkite-org-slug>/<pipeline-slug>/settings/repository`, of which the last two are not shown:

<%= image "github-settings.png", alt: "Example GitHub Settings for a Buildkite pipeline" %>

Add the following `repository_provider` blocks to each pipeline of your `pipelines.tf` file:

```hcl
...

# Define the frontend pipeline (through 'pipeline-slug/settings')
resource "buildkite_pipeline" "frontend" {

  ...

  # Repository (through 'pipeline-slug/settings/repository')
  repository      = "git@github.com:my-org/frontend.git"

  provider_settings = {
    trigger_mode                                  = "code"
    build_pull_requests                           = true
    skip_pull_request_builds_for_existing_commits = true
    ignore_default_branch_pull_requests           = true
    build_pull_request_ready_for_review           = true
    build_branches                                = true
    publish_commit_status                         = true
  }

  ...

}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  ...

  # Repository
  repository      = "git@github.com:my-org/backend.git"

  provider_settings = {
    trigger_mode                                  = "code"
    build_pull_requests                           = true
    skip_pull_request_builds_for_existing_commits = true
    ignore_default_branch_pull_requests           = true
    build_pull_request_ready_for_review           = true
    build_branches                                = true
    publish_commit_status                         = true
  }

  ...

}
```

Learn more about each available `provider_settings` configuration in the Buildkite Terraform provider's [Nested Schema for `provider_settings`](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline#nestedatt--provider_settings) documentation.

### Add required webhook triggers

Add the required webhook triggers to trigger builds of these pipelines automatically (that is, when changes are pushed to these repositories).

Add the following `buildkite_pipeline_webhook` resource blocks to each pipeline of your `pipelines.tf` file:

```hcl
...

# Define the frontend pipeline (through 'pipeline-slug/settings')
resource "buildkite_pipeline" "frontend" {

  ...

}

# Repository webhook to trigger frontend pipeline builds automatically
resource "buildkite_pipeline_webhook" "frontend" {
  pipeline_id = buildkite_pipeline.frontend.id
  repository  = buildkite_pipeline.frontend.repository
}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  ...

}

# Repository webhook to trigger backend pipeline builds automatically
resource "buildkite_pipeline_webhook" "backend" {
  pipeline_id = buildkite_pipeline.backend.id
  repository  = buildkite_pipeline.backend.repository
}
```

Learn more about this Terraform provider resource in the [`buildkite_pipeline_webhook` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline_webhook) documentation.

### Verify your completed pipelines.tf file

Confirm that your Terraform pipeline resources configuration (`pipelines.tf`) file is now complete:

```hcl
# Look up the existing cluster (name) to assign pipelines to
data "buildkite_cluster" "default" {
  name = "Default cluster"
}

# Look up the existing team (name) to assign as the initial pipeline owner
data "buildkite_team" "engineering" {
  name = "Engineering"
}

# Look up the existing team (name) to assign access to pipelines
data "buildkite_team" "design_team" {
  name = "Design team"
}

# Define the frontend pipeline (through 'pipeline-slug/settings')
resource "buildkite_pipeline" "frontend" {

  # General and infrastructure
  name            = "Frontend pipeline"
  description     = "Builds and tests the frontend application."
  default_branch  = "main"
  emoji           = "\:react\:"
  color           = "#6B6B6B"
  cluster_id      = data.buildkite_cluster.default.id

  # Pipeline steps (through 'pipeline-slug/settings/steps')
  steps = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML

  # Build behavior (through 'pipeline-slug/settings/builds')
  cancel_intermediate_builds               = true
  cancel_intermediate_builds_branch_filter = "!main"
  allow_rebuilds                           = true
  default_timeout_in_minutes               = 15
  maximum_timeout_in_minutes               = 30

  # Repository (through 'pipeline-slug/settings/repository')
  repository      = "git@github.com:my-org/frontend.git"

  provider_settings = {
    trigger_mode                                  = "code"
    build_pull_requests                           = true
    skip_pull_request_builds_for_existing_commits = true
    ignore_default_branch_pull_requests           = true
    build_pull_request_ready_for_review           = true
    build_branches                                = true
    publish_commit_status                         = true
  }

  # Initial pipeline owner (through 'pipeline-slug/settings/teams')
  default_team_id = data.buildkite_team.engineering.id

}

# Repository webhook to trigger frontend pipeline builds automatically
resource "buildkite_pipeline_webhook" "frontend" {
  pipeline_id = buildkite_pipeline.frontend.id
  repository  = buildkite_pipeline.frontend.repository
}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  # General and infrastructure
  name            = "Backend pipeline"
  description     = "Builds and tests the backend server."
  default_branch  = "main"
  emoji           = "\:gear\:"
  color           = "#4A4A4A"
  cluster_id      = data.buildkite_cluster.default.id

  # Pipeline steps
  steps = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML

  # Build behavior
  allow_rebuilds             = true
  default_timeout_in_minutes = 30
  maximum_timeout_in_minutes = 60

  # Repository
  repository      = "git@github.com:my-org/backend.git"

  provider_settings = {
    trigger_mode                                  = "code"
    build_pull_requests                           = true
    skip_pull_request_builds_for_existing_commits = true
    ignore_default_branch_pull_requests           = true
    build_pull_request_ready_for_review           = true
    build_branches                                = true
    publish_commit_status                         = true
  }

  # Initial pipeline owner
  default_team_id = data.buildkite_team.engineering.id

}

# Repository webhook to trigger backend pipeline builds automatically
resource "buildkite_pipeline_webhook" "backend" {
  pipeline_id = buildkite_pipeline.backend.id
  repository  = buildkite_pipeline.backend.repository
}
```

### Applying the configuration

Once your `pipelines.tf` file is completed, you can apply the configuration to your configured Buildkite organization:

```bash
terraform plan
terraform apply
```

> 📘 Deleting your configuration files and improving maintainability
> You can now delete all of your configuration files (and most importantly, your Terraform variable file `terraform.tfvars` that's been temporarily storing your API access token) once Terraform has successfully applied these configurations to your Buildkite organization.
> However, you can maintain a copy of these `.tf` files, should you wish to reapply these pipelines to the same or any other Buildkite organization again in future, bearing in mind that you'll need to manually keep any configuration changes you make to these pipelines in sync with your `pipelines.tf` file/s.
> To make this process easier, however, you can import your existing pipeline configurations into Terraform, which will account for all current updates made to these pipeline configurations. See [Importing existing pipeline resources to Terraform](#importing-existing-pipeline-resources-to-terraform) for details.

## Importing existing pipeline resources to Terraform

You can bring the resources for your existing Buildkite pipelines under Terraform management by defining [import block](https://developer.hashicorp.com/terraform/language/import) files for these resources, and then using `terraform plan` on these files to generate a single configuration. This is the same as _exporting_ your pipeline resources from Buildkite Pipelines to Terraform. All Buildkite Pipelines resources in these import blocks are defined using their GraphQL IDs in your Buildkite organization.

For example, to import an existing pipeline to Terraform:

```hcl
import {
  to = buildkite_pipeline.example
  id = "<graphql-id>"
}
```

Then generate the Terraform configuration:

```bash
terraform plan -generate-config-out=generated.tf
```

> 📘 Attributes not included in generated configuration
> The generated configuration does not include `provider_settings`, the pipeline's `slug`, or `default_team_id`. You need to add these attributes manually after import.

## Further reference

For the full list of supported resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
