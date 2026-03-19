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

To start using the Buildkite Terraform provider:

1. Add the provider to your Terraform configuration:

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

    > 🚧 Protect your API token
    > Do not store your API token directly in Terraform configuration files. Use environment variables (`BUILDKITE_API_TOKEN` and `BUILDKITE_ORGANIZATION_SLUG`) or a secrets manager instead.

1. Initialize the provider:

    ```bash
    terraform init
    ```

1. Define a resource, such as a pipeline:

    ```hcl
    resource "buildkite_pipeline" "example" {
      name       = "My Pipeline"
      repository = "git@github.com:my-org/my-repo.git"

      steps = <<-YAML
        steps:
          - label: ":pipeline:"
            command: "buildkite-agent pipeline upload"
      YAML
    }
    ```

1. Apply the configuration:

    ```bash
    terraform plan
    terraform apply
    ```

## Importing existing resources

You can bring existing Buildkite resources under Terraform management using `terraform import` or [import blocks](https://developer.hashicorp.com/terraform/language/import). Resources are imported using their GraphQL ID.

For example, to import an existing pipeline:

```hcl
import {
  to = buildkite_pipeline.example
  id = "<graphql-id>"
}
```

Then generate the configuration:

```bash
terraform plan -generate-config-out=generated.tf
```

## Further reference

For the full list of supported resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
