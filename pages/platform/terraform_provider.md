# Terraform provider

The [Buildkite Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) lets you manage your Buildkite organization's resources using [Terraform](https://www.terraform.io/) infrastructure-as-code workflows. With this provider, you can define and version-control your pipelines, teams, clusters, and other Buildkite resources alongside your application infrastructure.

The provider is open source and available on [GitHub](https://github.com/buildkite/terraform-provider-buildkite). It is listed on the [Terraform Registry](https://registry.terraform.io/providers/buildkite/buildkite/latest) and supports Terraform 1.0 and later.

## Managed resources

The Buildkite Terraform provider supports the following resource types:

- **Pipelines**: Create and configure [pipelines](/docs/pipelines/create-your-own), including their [steps](/docs/pipelines/configure/defining-steps) in a [pipeline template](/docs/pipelines/governance/templates), [repository settings](/docs/pipelines/source-control), repository webhooks (for [GitHub](/docs/pipelines/configure/defining-steps#getting-started-webhooks-for-github) or [other repository providers](/docs/pipelines/configure/defining-steps#getting-started-webhooks-for-other-repository-providers)), [team access](/docs/pipelines/security/permissions#manage-teams-and-permissions), and [schedules](/docs/pipelines/configure/workflows/scheduled-builds). See [Before you start](#before-you-start) and [Getting started with managing pipelines in Terraform](#getting-started-with-managing-pipelines-in-terraform) for more information.

- **Clusters and queues**: Manage [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), cluster agent tokens, and cluster secrets.

- **Teams**: Create and manage [teams](/docs/platform/team-management) and their members.

- **Organizations**: Configure organization-level settings, rules, and banners.

- **Test suites**: Set up [Test Engine](/docs/test-engine) test suites and manage team access.

- **Package registries**: Manage [Package Registries](/docs/package-registries) resources.

- **Agent tokens**: Create and manage agent tokens for self-hosted agents.

## Before you start

The Terraform provider requires the following Buildkite configuration values:

- **API access token**: A [Buildkite API access token](/docs/apis/managing-api-tokens) (`BUILDKITE_API_TOKEN`) with `write_pipelines` and `read_pipelines` [REST API scopes and GraphQL API access](/docs/apis/managing-api-tokens#token-scopes) enabled. You can generate a token from your [API Access Tokens](https://buildkite.com/user/api-access-tokens) page.

    **Note:** You can also add the `write_suites` REST API scope to this token, although this is only required if you plan to manage [Buildkite Test Engine](/docs/test-engine) test suites using the Terraform provider.

- **Buildkite organization slug**: Your Buildkite organization slug, which you can find in your Buildkite URL: `https://buildkite.com/<your-buildkite-org-slug>`.

- **Cluster name/s**: Required so that Terraform can determine which [Buildkite cluster/s](/docs/pipelines/security/clusters) your pipelines are associated with.

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

    **Warning:** Avoid storing your Buildkite API access token directly in Terraform configuration files. Use an environment variable for `BUILDKITE_API_TOKEN` or manage it through a secrets manager instead, which is the recommended approach if you're using a Buildkite pipeline to orchestrate this process.

    If you're running this process at the command line, and you wish to use your Terraform configuration to temporarily store your token's value for this procedure, you can do so by creating the following files, although _ensure you delete them_ at the end of this procedure:

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

In the following example, two pipelines are defined (**Frontend pipeline** and **Backend pipeline**), which will be part of the pre-existing Buildkite cluster (**Default cluster**), and a pre-existing team, whose name is **Engineering** (along with all of its members) will be made the initial owner of these pipelines. The steps for both of these pipelines use those from a pipeline template definition named **Standard pipeline**.

The configuration settings for all pipeline-related resources in this example are accessible in the Buildkite interface through the URL path portions (appended to `https://buildkite.com/<your-buildkite-org-slug>/`), indicated in the comments of the pipeline template (**Standard pipeline**) and first pipeline (named **Frontend pipeline**) of this `pipelines.tf` example.

```hcl
# Data source for existing cluster (name) to assign pipelines to
data "buildkite_cluster" "default" {
  name = "Default cluster"
}

# Data source for existing team (name) to assign as the initial pipeline owner
data "buildkite_team" "engineering" {
  name = "Engineering"
}

# Define a reusable pipeline template (through 'pipeline-templates')
resource "buildkite_pipeline_template" "standard" {
  name          = "Standard pipeline"
  description   = "Default step configuration for all pipelines."
  configuration = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML
}

# Define the frontend pipeline
resource "buildkite_pipeline" "frontend" {

  # General and infrastructure (through 'frontend-pipeline/settings')
  name                 = "Frontend pipeline"
  description          = "Builds and tests the frontend application."
  default_branch       = "main"
  emoji                = "\:react\:"
  color                = "#6B6B6B"
  cluster_id           = data.buildkite_cluster.default.id
  pipeline_template_id = buildkite_pipeline_template.standard.id

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
  name                 = "Backend pipeline"
  description          = "Builds and tests the backend server."
  default_branch       = "main"
  emoji                = "\:gear\:"
  color                = "#4A4A4A"
  cluster_id           = data.buildkite_cluster.default.id
  pipeline_template_id = buildkite_pipeline_template.standard.id

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

Learn more about the following Terraform provider components used above from the official documentation:

- Resources for pipelines in the [`buildkite_pipeline` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline) documentation, as well as the equivalent for pipeline templates in the [`buildkite_pipeline_template` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline_template) documentation.

- Data sources for clusters in the [`buildkite_cluster` data source](http://registry.terraform.io/providers/buildkite/buildkite/latest/docs/data-sources/cluster), as well as teams in the [`buildkite_team` data source](http://registry.terraform.io/providers/buildkite/buildkite/latest/docs/data-sources/cluster).

> 📘
> In the pipeline examples above, the actual pipeline YAML steps for each pipeline are uploaded to Buildkite Pipelines from the `.buildkite/pipeline.yml` file in each pipeline's respective repository, which is the recommended approach for storing and managing your pipeline steps as code.
> If you did want to manage some of these pipeline steps through your pipelines' `https://buildkite.com/<your-buildkite-org-slug>/<pipeline-slug>/settings/steps` pages in the Buildkite interface, you'd need to include these steps in `steps` definition blocks (containing your `YAML` steps) of the respective pipelines in your `pipelines.tf` file. However, this approach is not recommended.

### Add your repository provider settings

Add the required `provider_settings` blocks for each pipeline definition in this file.

For example, assuming both pipelines are configured to build a repository in GitHub with the following **GitHub Settings** accessed through `https://buildkite.com/<your-buildkite-org-slug>/<pipeline-slug>/settings/repository`, of which the last two are not shown in this screenshot:

<%= image "github-settings.png", alt: "Example GitHub Settings for a Buildkite pipeline" %>

Add the following `repository_provider` blocks to each pipeline of your `pipelines.tf` file:

```hcl
...

# Define the frontend pipeline
resource "buildkite_pipeline" "frontend" {

  ...

  # Repository (through 'frontend-pipeline/settings/repository')
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

### Add required repository webhooks

Add the required repository webhooks to trigger builds of these pipelines automatically (that is, when changes are pushed to these repositories). This is done using `buildkite_pipeline_webhook` resource blocks.

In this example, add the following `buildkite_pipeline_webhook` resource blocks to each pipeline of your `pipelines.tf` file, bearing in mind that the Terraform identifiers you use in these blocks (that is, `frontend` and `backend`) must match their respective `buildkite_pipeline` pipeline Terraform identifiers:

```hcl
...

# Define the frontend pipeline
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

### Add any other teams to your pipelines

Add any other teams who need access to these pipelines and define their permissions on these pipelines. This is done using `buildkite_pipeline_team` resource blocks.

In this example, the pre-existing **Design team** in your Buildkite organization is (also) granted full access to **Frontend pipeline**, which is the same level of access as the pipeline's initial owner team (**Engineering**).

To do this, add the following `buildkite_team` data source and `buildkite_pipeline_team` resource blocks for this team, and apply it to the `frontend` pipeline in your `pipelines.tf` file.
Bear in mind that the Terraform identifiers for the `buildkite_pipeline` resource and `buildkite_team` data source blocks (that is, `frontend` and `design_team`, respectively) must match those you use for the `pipeline_id` and `team_id` argument values in your  `buildkite_pipeline_team` resource block. Therefore, the syntax for referencing these values would be `data.buildkite_team.design_team.id` and `buildkite_pipeline.frontend.id`, respectively, where the team's `access_level` of `MANAGE_BUILD_AND_READ` grants full access to the pipeline:

```hcl
...

# Data source for existing team (name) to assign pipeline access
data "buildkite_team" "design_team" {
  name = "Design team"
}

...

# Define the frontend pipeline
resource "buildkite_pipeline" "frontend" {

  ...

}

...

# Additional team with full access to 'frontend'
resource "buildkite_pipeline_team" "design" {
  pipeline_id  = buildkite_pipeline.frontend.id
  team_id      = data.buildkite_team.design_team.id
  access_level = "MANAGE_BUILD_AND_READ"
}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  ...

}

...
```

Learn more about this Terraform provider resource in the [`buildkite_pipeline_team` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline_team) documentation.

### Add appropriate schedules to your pipelines

It might be sufficient that your pipelines are built using [repository webhooks](#getting-started-with-managing-pipelines-in-terraform-add-required-repository-webhooks) only. However, you may wish to run a regular scheduled build of your pipeline, for example, to ensure its project's own resources are kept up to date, with dynamically run steps that create a new pull- or merge-request with updated resources.

In this example, add a daily re-build of the **Backend pipeline** that runs at midnight on the backend project's default branch (that is, `main`, which can be accessed through `default_branch` of the pipeline's Terraform resource).

To do this, add the following `buildkite_pipeline_schedule` resource block for this schedule, and apply it to the `backend` pipeline in your `pipelines.tf` file. Bear in mind that the Terraform identifier for the `buildkite_pipeline` resource block (that is, `backend`) must match that of the `pipeline_id` argument value in your `buildkite_pipeline_schedule` resource block. Therefore, the syntax for referencing this value would be `buildkite_pipeline.backend.id`.

```hcl
...

# Define the frontend pipeline
resource "buildkite_pipeline" "frontend" {

  ...

}

...


# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  ...

}

...

# Schedule a build of the 'backend' pipeline at midnight every day
resource "buildkite_pipeline_schedule" "nightly" {
  pipeline_id = buildkite_pipeline.backend.id
  label       = "Nightly build"
  cronline    = "@midnight"
  branch      = buildkite_pipeline.backend.default_branch
}
```

Learn more about this Terraform provider resource in the [`buildkite_pipeline_schedule` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline_schedule) documentation.

### Verify your completed pipelines.tf file

Confirm that your Terraform pipeline resources configuration (`pipelines.tf`) file is now complete:

```hcl
# Data source for existing cluster (name) to assign pipelines to
data "buildkite_cluster" "default" {
  name = "Default cluster"
}

# Data source for existing team (name) to assign as the initial pipeline owner
data "buildkite_team" "engineering" {
  name = "Engineering"
}

# Data source for existing team (name) to assign access to pipelines
data "buildkite_team" "design_team" {
  name = "Design team"
}

# Define a reusable pipeline template (through 'pipeline-templates')
resource "buildkite_pipeline_template" "standard" {
  name          = "Standard pipeline"
  description   = "Default step configuration for all pipelines."
  configuration = <<-YAML
    steps:
      - label: "\:pipeline\:"
        command: "buildkite-agent pipeline upload"
  YAML
}

# Define the frontend pipeline
resource "buildkite_pipeline" "frontend" {

  # General and infrastructure (through 'frontend-pipeline/settings')
  name                 = "Frontend pipeline"
  description          = "Builds and tests the frontend application."
  default_branch       = "main"
  emoji                = "\:react\:"
  color                = "#6B6B6B"
  cluster_id           = data.buildkite_cluster.default.id
  pipeline_template_id = buildkite_pipeline_template.standard.id

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

# Additional team with full access to the 'frontend' pipeline
resource "buildkite_pipeline_team" "design" {
  pipeline_id  = buildkite_pipeline.frontend.id
  team_id      = data.buildkite_team.design_team.id
  access_level = "MANAGE_BUILD_AND_READ"
}

# Define the backend pipeline
resource "buildkite_pipeline" "backend" {

  # General and infrastructure
  name                 = "Backend pipeline"
  description          = "Builds and tests the backend server."
  default_branch       = "main"
  emoji                = "\:gear\:"
  color                = "#4A4A4A"
  cluster_id           = data.buildkite_cluster.default.id
  pipeline_template_id = buildkite_pipeline_template.standard.id

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

# Schedule a build of the 'backend' pipeline at midnight every day
resource "buildkite_pipeline_schedule" "nightly" {
  pipeline_id = buildkite_pipeline.backend.id
  label       = "Nightly build"
  cronline    = "@midnight"
  branch      = buildkite_pipeline.backend.default_branch
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
> To improve maintainability, however, you can import your existing pipeline configurations into Terraform, which will account for all current updates made to these pipeline configurations. See [Import existing Buildkite resources to Terraform](/docs/platform/terraform-provider/import-existing-resources) for details.

## Further reference

For the full list of supported resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
