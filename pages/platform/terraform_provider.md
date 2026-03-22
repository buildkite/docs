# Terraform provider

The [Buildkite Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) lets you manage your Buildkite organization's resources using [Terraform](https://www.terraform.io/) infrastructure-as-code workflows. With this provider, you can define and version-control your pipelines, teams, clusters, and other Buildkite resources alongside your application infrastructure.

The provider is open source and available on [GitHub](https://github.com/buildkite/terraform-provider-buildkite). It is listed on the [Terraform Registry](https://registry.terraform.io/providers/buildkite/buildkite/latest) and supports Terraform 1.0 and later.

## Managed resources

The Buildkite Terraform provider supports the following resource types:

- **Pipelines**: Create and configure [pipelines](/docs/pipelines), including their steps, repository settings, schedules, team access, templates, and webhooks.
- **Clusters and queues**: Manage [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), cluster agent tokens, and cluster secrets.
- **Teams**: Create and manage [teams](/docs/platform/team-management) and their members.
- **Organizations**: Configure organization-level settings, rules, and banners.
- **Test suites**: Set up [Test Engine](/docs/test-engine) test suites and manage team access.
- **Package registries**: Manage [Package Registries](/docs/package-registries) resources.
- **Agent tokens**: Create and manage agent tokens for self-hosted agents.

## Authentication

The provider requires two configuration values:

- **API access token**: A Buildkite API access token with `write_pipelines`, `read_pipelines`, and `write_suites` REST API scopes and GraphQL API access enabled. You can generate a token from your [API Access Tokens](https://buildkite.com/user/api-access-tokens) page.
- **Organization slug**: Your Buildkite organization slug, which you can find in your Buildkite URL: `https://buildkite.com/<org-slug>`.

## Getting started

To start using the Buildkite Terraform provider with pipelines:

1. Define the Buildkite provider for your Terraform configuration file, written in HashiCorp Configuration Language (HCL) (for example, `provider.tf`):

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
      api_token    = "YOUR_API_TOKEN"
      organization = "your-org-slug"
    }
    ```

    **Warning:** Do not store your API token directly in Terraform configuration files. Use environment variables (`BUILDKITE_API_TOKEN` and `BUILDKITE_ORGANIZATION_SLUG`) or a secrets manager instead.

1. Initialize the provider:

    ```bash
    terraform init
    ```

1. Define pipeline resources for the pipelines you want to import into your Buildkite organization, again in HCL (for example, `pipelines.tf`):

    ```hcl
    # Look up the existing cluster (name) to assign pipelines to
    data "buildkite_cluster" "default" {
      name = "Default cluster"
    }

    # Look up the existing team (name) to assign as the initial pipeline owner
    data "buildkite_team" "engineering" {
      name = "Engineering"
    }

    # Define the frontend pipeline
    resource "buildkite_pipeline" "frontend" {

      # General and infrastructure
      name            = "Frontend pipeline"
      description     = "Builds and tests the frontend application."
      default_branch  = "main"
      emoji           = "\:react\:"
      color           = "#6B6B6B"
      cluster_id      = data.buildkite_cluster.default.id

      steps = <<-YAML
        steps:
          - label: "\:pipeline\:"
            command: "buildkite-agent pipeline upload"
      YAML

      # Build behavior
      cancel_intermediate_builds               = true
      cancel_intermediate_builds_branch_filter = "!main"
      allow_rebuilds                           = true
      default_timeout_in_minutes               = 15
      maximum_timeout_in_minutes               = 30

      # Repository
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

      # Initial pipeline owner
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

    **Note:** In the pipeline examples above, the actual pipeline YAML steps for each pipeline are uploaded to Buildkite Pipelines from the `.buildkite/pipeline.yml` file in each pipeline's respective repository.

1. Apply the configuration:

    ```bash
    terraform plan
    terraform apply
    ```

## Importing existing resources to Terraform

You can bring the resources for your existing Buildkite pipelines under Terraform management by defining [import block](https://developer.hashicorp.com/terraform/language/import) files for these resources, and then using `terraform plan` on these files to generate a single configuration. This is the same as _exporting_ your pipeline resources from Buildkite Pipelines. All Buildkite Pipelines resources in these import blocks are defined using their GraphQL IDs in your Buildkite organization.

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
