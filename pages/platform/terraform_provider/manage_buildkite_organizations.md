# Manage Buildkite organizations

The [Buildkite Terraform provider](/docs/platform/terraform-provider) supports managing Buildkite organization-level settings, and [system banners](/docs/platform/team-management/system-banners) as Terraform resources. This page covers how to define and configure these resources in your Terraform configuration files.

> 📘
> The user of your [API access token](/docs/platform/terraform-provider#before-you-start) must be a Buildkite organization administrator to manage organization settings.

## Configure Buildkite organization settings

Define a resource for the Buildkite organization settings you want to manage in Terraform, in HCL (for example, `organization.tf`). These settings include [enforcing two-factor authentication (2FA)](/docs/platform/team-management/enforce-2fa), or [restricting API access to specific IP addresses](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address), or both.

The `buildkite_organization` resource is used to manage these organization-level settings for 2FA (referenced by the `enforce_2fa` argument) and restricting API access to specific IP addresses (referenced by `allowed_api_ip_addresses`).

In the following example, 2FA is enforced for all organization members and API access is restricted to a range of IP addresses between `192.0.2.0` to `192.0.2.255`, with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_organization" "settings" {
  enforce_2fa              = true
  allowed_api_ip_addresses = ["192.0.2.0/24"]
}
```

The optional arguments for this resource are:

- `enforce_2fa` with a value of `true` to require [two-factor authentication](/docs/platform/team-management/enforce-2fa) for all organization members.

- `allowed_api_ip_addresses` with a list of space-separated IP addresses or [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) for a range of IP addresses, or a combination of both, to restrict which IP addresses can access the Buildkite API for your organization.

    **Note:** [Restricting API access by IP address](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address) is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

Learn more about this resource in the [`buildkite_organization` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/organization) documentation.

## Define a system banner

A system banner (also known as organization banner) is not typically managed in Terraform, and is usually [configured through the Buildkite interface](/docs/platform/team-management/system-banners). The system banner is displayed to all members of your organization, at the top of each page in the Buildkite interface.

> 📘 Enterprise plan feature
> System banners are only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

If you do want to manage a system banner in Terraform, define a resource for the system banner, within your organization resources HCL file (for example, `organization.tf`).

The `buildkite_organization_banner` resource to create and manage a system banner, whose `message` argument contains the Markdown content for this banner.

In the following example, a maintenance notification banner will be created with `terraform plan` and `terraform apply`.

```hcl
resource "buildkite_organization_banner" "maintenance" {
  message = "Scheduled maintenance this Saturday 02:00–04:00 UTC."
}
```

Learn more about this resource in the [`buildkite_organization_banner` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/organization_banner) documentation.

## Applying the configuration

Once your `organization.tf` file is complete, it is ready to be [applied to your Buildkite organization](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#applying-the-configuration).

## Further reference

For the full list of organization resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
