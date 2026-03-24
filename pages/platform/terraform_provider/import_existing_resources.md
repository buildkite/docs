# Import existing Buildkite resources to Terraform

## Importing existing pipeline resources

You can bring the resources for your existing Buildkite pipelines under Terraform management by defining a series of [import blocks](https://developer.hashicorp.com/terraform/language/import) for these resources in a single file (for example, `pipeline-imports.tf`), and then using `terraform plan` on this file to generate a single `pipeline.tf` file containing the configurations for all of these pipelines. This is the same as _exporting_ your pipeline resources from Buildkite Pipelines to Terraform. All Buildkite Pipelines resources in these import blocks are defined using their GraphQL IDs in your Buildkite organization.

To import existing pipelines to Terraform:

1. Get all pipeline GraphQL IDs for all the pipelines you want to import to Terraform, for example:

    ```graphql
    query {
      organization(slug: "your-buildkite-org-slug") {
        pipelines(first: 100) {
          edges {
            node {
              id
              name
              slug
            }
          }
        }
      }
    }
    ```

1. Create a `pipeline-imports.tf` file with a set of `import` blocks, one for each pipeline you want to manage in Terraform. Within each `import` block, define a `to` argument, whose value after `buildkite_pipeline.` is the Terraform identifier for the pipeline, and an `id` argument, whose value is the pipeline's GraphQL ID obtained from the query above.

    ```hcl
    import {
      to = buildkite_pipeline.frontend
      id = "graphql-id-for-this-pipeline"
    }

    import {
      to = buildkite_pipeline.backend
      id = "graphql-id-for-this-pipeline"
    }

    import {
      to = buildkite_pipeline.another_pipeline
      id = "graphql-id-for-this-pipeline"
    }
    ```

1. Next, generate the Terraform configuration file (`pipelines.tf`):

    ```bash
    terraform plan -generate-config-out=pipelines.tf
    ```

    **Note:** The `pipelines.tf` file generated will have many of the arguments and values set for each pipeline resource (`resource "buildkite_pipeline"`) which you would have if you'd [defined this file manually](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources). However, some of these arguments' values are not imported to the generated file and others may need modification. See [Finalizing your `pipelines.tf` configurations](#finalizing-your-pipelines-dot-tf-configurations) for more information.

1. Delete the `pipeline-imports.tf` file you created earlier. If you are [finalizing your `pipelines.tf` file](#finalizing-your-pipelines-dot-tf-configurations), deleting this import file is recommended to avoid accidentally running `terraform plan ...` again, which could overwrite your updates to this file.

1. Once you are satisfied with your `pipelines.tf` file, commit it to source control.

## Finalizing your pipelines.tf configurations

If you [imported existing pipeline resources to Terraform](#importing-existing-pipeline-resources), there are some differences in the resulting `pipelines.tf` file, compared to ones you would [prepare manually](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources).

### Add missing arguments

The `pipelines.tf` file generated using `terraform plan ...` does not include the following arguments:

- **The repository's `provider_settings`**: To include these settings, for each pipeline resource, replace its `provider_settings` argument's `null` value with a map of keys, similar to those in the [manually defined examples](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-add-your-repository-provider-settings). See the Buildkite Terraform provider's [Nested Schema for `provider_settings`](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/pipeline#nestedatt--provider_settings) documentation for more information about these keys.
- **The initial pipeline owner (`default_team_id`)**: To include these settings, for each pipeline resource, replace its `default_team_id` argument's `null` value with team ID of the data source, similar to those in the [manually defined examples](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources).

### Amend arguments with GraphQL ID values if required

The values of following arguments in the generated `pipelines.tf` file reference actual GraphQL IDs as opposed to other Terraform identifiers, which is typically the case for those [defined manually](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources).

- `cluster_id`
- `pipeline_template_id`

If you [imported existing pipelines from a Buildkite organization to Terraform](#importing-existing-pipeline-resources), and you intend to use `terraform apply` on the resulting `pipelines.tf` to import these back to:

- The _same_ Buildkite organization (for example, for disaster recovery purposes), then there is no need to update these arguments' values in `pipelines.tf`, on the assumption that you retain and intend to reuse the same Buildkite cluster/s and pipeline template/s.

- A _different_ Buildkite organization, or _different_ Buildkite cluster/s or pipeline template/s in the _same_ Buildkite organization, then you'll need to amend these arguments' values in `pipelines.tf` to those of the IDs for the new cluster/s or pipeline templates/s associated with these pipelines. Otherwise, you can implement the alternative syntax used when [defining the `pipelines.tf` file manually](/docs/platform/terraform-provider#getting-started-with-managing-pipelines-in-terraform-define-your-initial-pipeline-resources).
