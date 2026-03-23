# Importing existing Buildkite resources to Terraform

## Importing existing pipeline resources

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
