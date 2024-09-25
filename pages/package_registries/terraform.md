# Terraform

Buildkite Package Registries provides registry support for Terraform modules.

Once your Terraform registry has been [created](/docs/package-registries/manage-registries#create-a-registry), you can publish/upload modules (generated from your application's build) to this registry via the `curl` command presented on your Terraform registry's details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Terraform registry on this page.
1. Select **Publish a Terraform Package** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and run it to publish a module to your Terraform registry.

This command provides:

- The specific URL to publish a module to your specific Terraform registry in Buildkite.
- The API access token required to publish modules to your Terraform registry.
- The Terraform module file to be published.

## Publish a module

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a module to your Terraform registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'package-registries/org_slug' %>

<%= render_markdown partial: 'package-registries/terraform_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload modules to your Terraform registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish modules and packages to any registry your user account has access to within your Buildkite organization.

- `<path_to_file>` is the full path required to the module file. If the file is located in the same directory that this command is running from, then no path is required.

For example, to upload the file `my-terraform-module-1.0.1.tgz` from the current directory to the **My Terraform modules** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-terraform-modules/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-terraform-module-1.0.1.tgz"
```

## Access a module's details

A Terraform module's details can be accessed from this registry using the **Packages** section of your Terraform registry page.

To access your Terraform module's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Terraform registry on this page.
1. On your Terraform registry page, select the module within the **Packages** section. The module's details page is displayed.

The module's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-modules-details-installing-a-module).
- **Contents** (tab, where available): a list of directories and files contained within the module.
- **Details** (tab): a list of checksum values for this module—MD5, SHA1, SHA256, and SHA512.
- **About this version**: a brief (metadata) description about the module.
- **Details**: details about:

    * the name of the module (typically the file name excluding any version details and extension).
    * the module version.
    * the registry the module is located in.
    * the module's visibility (based on its registry's visibility)—whether the module is **Private** and requires authentication to access, or is publicly accessible.
    * the distribution name / version.
    * additional optional metadata contained within the module, such as a homepage, licenses, etc.

- **Pushed**: the date when the last module was uploaded to the registry.
- **Total files**: the total number of files (and directories) within the module.
- **Dependencies**: the number of dependency modules required by this module.
- **Package size**: the storage size (in bytes) of this module.
- **Downloads**: the number of times this module has been downloaded.

### Downloading a module

A Terraform module can be downloaded from the module's details page.

To download a module:

1. [Access the module's details](#access-a-modules-details).
1. Select **Download**.

### Installing a module

A Terraform module can be installed using code snippet details provided on the module's details page.

To install a module:

1. [Access the module's details](#access-a-modules-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. If your Terraform registry is private, copy the top section of the code snippet, and paste it into your `~/.terraformrc` configuration file. This code snippet is based on the format:

    ```config
    credentials "packages.buildkite.com" {
      token = "registry-read-token"
    }
    ```

    where `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#update-a-registry-configure-registry-tokens) used to download modules from your Terraform registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download modules and packages from any registry your user account has access to within your Buildkite organization.

    **Note:** This step only needs to be performed once for the life of your Terraform registry.

1. Copy the lower section of the code snippet, and paste it into your Terraform file. This code snippet is based on the format:

    ```terraform
    module "org_slug___registry_name_module_name" {
      source = "packages.buildkite.com/org-slug---registry-name/ksh/all"
      version = "version.number"
    }
    ```

    where:
    * `org_slug` can be derived from the end of your Buildkite URL (in [snake_case](https://en.wikipedia.org/wiki/Letter_case#Snake_case)), after accessing **Pipelines** in the global navigation of your organization in Buildkite.
    * `registry_slug` is the slug of your Terraform registry (derived from the registry name in snake_case).
    * `module_name` is the name of your Terraform module.
    * `org-slug` can be obtained from the end of your Buildkite URL (in [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case)), after accessing **Pipelines** in the global navigation of your organization in Buildkite.
    * `registry-slug` is the slug of your Terraform registry (derived from the registry name in kebab-case).
    * `version.number` is the version of your Terraform module.

1. Run the Terraform command:

    ```bash
    terraform init
    ```
