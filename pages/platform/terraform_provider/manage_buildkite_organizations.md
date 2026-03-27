# Manage Buildkite organizations

The [Buildkite Terraform provider](/docs/platform/terraform-provider) supports managing Buildkite organization-level settings, [rules](/docs/pipelines/security/clusters/rules), and [system banners](/docs/platform/team-management/system-banners) as Terraform resources. This page covers how to define and configure these resources in your Terraform configuration files.

> 📘
> The user of your [API access token](/docs/platform/terraform-provider#before-you-start) must be a Buildkite organization administrator to manage organization settings.

## Configure Buildkite organization settings

Define resources for your Buildkite organization settings that you want to manage in Terraform, in HCL (for example, `organization.tf`).

The `buildkite_organization` resource is used to manage organization-level settings, such as [enforcing two-factor authentication (2FA)](/docs/platform/team-management/enforce-2fa) with the `enforce_2fa` argument, [restricting API access to specific IP addresses](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address) with the `allowed_api_ip_addresses` argument, or both.

In the following example, 2FA is enforced for all organization members and API access is restricted to a range of IP addresses between `192.0.2.0` to `192.0.2.255`, with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_organization" "settings" {
  enforce_2fa              = true
  allowed_api_ip_addresses = ["192.0.2.0/24"]
}
```

The optional arguments for this resource are:

- `enforce_2fa` with a value of `true` to require [two-factor authentication](/docs/platform/team-management/enforce-2fa) for all organization members.

- `allowed_api_ip_addresses` with a list of CIDR-notation IP addresses to restrict which network addresses can access the Buildkite API for your organization.

    **Note:** [Restricting API access by IP address](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address) is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

Learn more about this resource in the [`buildkite_organization` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/organization) documentation.

## Define organization rules

Use the `buildkite_organization_rule` resource to define explicit rules between two Buildkite resources and the desired effect or action. Rules control interactions between pipelines, such as which pipelines can trigger builds on other pipelines or read artifacts from other pipelines.

> 🚧 Early access feature
> Rules is a feature that is currently in development and enabled on an opt-in basis for early access. Contact [Buildkite support](https://buildkite.com/support) to have this enabled for your organization.

Each rule requires a `type` and a `value` argument, and can optionally include a `description`.

In the following example, a rule is created that allows the **app-deploy** pipeline to trigger builds on the **app-test** pipeline, with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_organization_rule" "trigger_build" {
  type        = "pipeline.trigger_build.pipeline"
  description = "Allow app-deploy to trigger app-test builds"
  value = jsonencode({
    source_pipeline = buildkite_pipeline.app_deploy.uuid
    target_pipeline = buildkite_pipeline.app_test.uuid
  })
}
```

You can also define rules with conditions to further restrict when the rule applies:

```hcl
resource "buildkite_organization_rule" "trigger_build_main" {
  type        = "pipeline.trigger_build.pipeline"
  description = "Allow app-deploy to trigger app-test builds on main only"
  value = jsonencode({
    source_pipeline = buildkite_pipeline.app_deploy.uuid
    target_pipeline = buildkite_pipeline.app_test.uuid
    conditions      = ["source.build.branch == 'main'"]
  })
}
```

Learn more about this resource in the [`buildkite_organization_rule` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/organization_rule) documentation, and about rules in the [Rules overview](/docs/pipelines/security/clusters/rules).

## Define organization banners

Use the `buildkite_organization_banner` resource to create and manage [system banners](/docs/platform/team-management/system-banners) displayed to all organization members at the top of each page in the Buildkite interface.

> 📘 Enterprise plan feature
> System banners are only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

Each banner requires a `message` argument.

In the following example, a maintenance notification banner will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_organization_banner" "maintenance" {
  message = "Scheduled maintenance this Saturday 02:00–04:00 UTC."
}
```

Learn more about this resource in the [`buildkite_organization_banner` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/organization_banner) documentation.

## Further reference

For the full list of organization resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
