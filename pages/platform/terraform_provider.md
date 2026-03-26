# Terraform provider

The [Buildkite provider for Terraform](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) lets you manage your Buildkite organization's resources using [Terraform](https://www.terraform.io/) infrastructure-as-code workflows. With this provider, you can define and version-control your pipelines, teams, clusters, and other Buildkite resources alongside your application infrastructure.

The [Buildkite Terraform Provider](https://github.com/buildkite/terraform-provider-buildkite) is open source repository available on GitHub, is listed on the [Terraform Registry](https://registry.terraform.io/providers/buildkite/buildkite/latest), and supports Terraform 1.0 and later.

## Managed resources

Once you have met the prerequisites (see [Before you start](#before-you-start)) and have [defined the Buildkite provider for your Terraform configuration](#define-the-buildkite-provider-for-your-terraform-configuration), you can then use the Buildkite Terraform provider for the following supported resource types:

- **Pipelines**: Create and configure [pipelines](/docs/pipelines/create-your-own), including their [steps](/docs/pipelines/configure/defining-steps) in a [pipeline template](/docs/pipelines/governance/templates), [repository settings](/docs/pipelines/source-control), repository webhooks (for [GitHub](/docs/pipelines/configure/defining-steps#getting-started-webhooks-for-github) or [other repository providers](/docs/pipelines/configure/defining-steps#getting-started-webhooks-for-other-repository-providers)), [team access](/docs/pipelines/security/permissions#manage-teams-and-permissions), and [schedules](/docs/pipelines/configure/workflows/scheduled-builds). See [Getting started with managing pipelines](/docs/platform/terraform-provider/getting-started-with-managing-pipelines) for more information.

- **Clusters and queues**: Manage [clusters](/docs/pipelines/security/clusters), [queues](/docs/agent/queues), [agent tokens](/docs/agent/self-hosted/tokens), default queues, [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster), and [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets). See [Manage clusters and queues](/docs/platform/terraform-provider/manage-clusters-and-queues) for more information.

- **Teams**: Create and manage [teams](/docs/platform/team-management/permissions) and their members. See [Manage teams](/docs/platform/terraform-provider/manage-teams) for more information.

- **Organizations**: Configure organization-level settings, rules, and banners.

- **Test suites**: Set up [Test Engine](/docs/test-engine) test suites and manage team access.

- **Package registries**: Manage [Package Registries](/docs/package-registries) resources.

## Before you start

The Terraform provider requires the following Buildkite configuration values:

- **API access token**: A [Buildkite API access token](/docs/apis/managing-api-tokens) (`BUILDKITE_API_TOKEN`) with `write_pipelines` and `read_pipelines` [REST API scopes and _GraphQL API access_](/docs/apis/managing-api-tokens#token-scopes) enabled. You can generate a token from your [API Access Tokens](https://buildkite.com/user/api-access-tokens) page.

    **Note:** You can also add the `write_suites` REST API scope to this token, although this is only required if you plan to manage [Buildkite Test Engine](/docs/test-engine) test suites using the Terraform provider.

- **Buildkite organization slug**: Your Buildkite organization slug, which you can find in your Buildkite URL: `https://buildkite.com/<your-buildkite-org-slug>`.

## Define the Buildkite provider for your Terraform configuration

To start using the Buildkite Terraform provider to manage your pipelines in Terraform:

1. Define the Buildkite provider for your Terraform configuration, along with your Buildkite API access token configuration, as a file written in HashiCorp Configuration Language (HCL) (for example, `provider.tf`):

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

## Further reference

For the full list of supported resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
