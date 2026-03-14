# Terraform

Buildkite Package Registries provides registry support for Terraform modules.

Once your Terraform source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload modules (generated from your application's build) to this registry.

## Publish a module

You can use two approaches to publish a module to your Terraform source registry—[`curl`](#publish-a-module-using-curl) or the [Buildkite CLI](#publish-a-module-using-the-buildkite-cli). The [SemVer-style](https://semver.org/) `major.minor.patch` must be included in the filename of the `.tgz` package and be unique, or Package Registries will return an error. The format of the filename must also be in accordance with [Terraform developer documentation](https://developer.hashicorp.com/terraform/registry/modules/publish#requirements).

### Using curl

The **Publish Instructions** tab of your Terraform source registry includes a `curl` command you can use to upload a module to this registry. To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Terraform source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the module to this source registry.

This command provides:

- The specific URL to publish a module to your specific Terraform source registry in Buildkite.
- A temporary API access token to publish modules to this source registry.
- The Terraform module file to be published.

You can also create this command yourself using the following `curl` command (which you'll need to modify as required before submitting):

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/terraform/terraform-{provider}-{module}-{major.minor.patch}.tgz"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Terraform registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of your Terraform registry name, and can be obtained after accessing **Package Registries** in the global navigation > your Terraform registry from the **Registries** page.

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload modules to your Terraform source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish modules and other package types to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Terraform source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_terraform_module' %>

For example, to upload the file `terraform-buildkite-pipeline-1.0.0.tgz` from the current directory to the **My Terraform modules** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-terraform-modules/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@terraform-buildkite-pipeline-1.0.0.tgz"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish a module to your Terraform source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/terraform/terraform-{provider}-{module}-{major.minor.patch}.tgz
```

where:

- `registry-slug` is the slug of your Terraform source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your file source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_terraform_module' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a module's details

A Terraform module's details can be accessed from this registry through the **Releases** (tab) section of your Terraform source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Terraform source registry on this page.
1. On your Terraform source registry page, select the module within the **Releases** (tab) section. The module's details page is displayed.

The module's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-modules-details-installing-a-module).
- **Contents** (tab, where available): a list of directories and files contained within the module.
- **Details** (tab): a list of checksum values for this module—MD5, SHA1, SHA256, and SHA512.
- **About this version**: a brief (metadata) description about the module.
- **Details**: details about:

    * the name of the module (typically the file name excluding any version details and extension).
    * the module version.
    * the source registry the module is located in.
    * the module's visibility (based on its registry's visibility)—whether the module is **Private** and requires authentication to access, or is publicly accessible.
    * the distribution name / version.
    * additional optional metadata contained within the module, such as a homepage, licenses, etc.

- **Pushed**: the date when the last module was uploaded to the source registry.
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
1. If your Terraform source registry is private (the default configuration for source registries), copy the top section of the code snippet, and paste it into your `~/.terraformrc` configuration file. This code snippet is based on the format:

    ```config
    credentials "packages.buildkite.com" {
      token = "registry-read-token"
    }
    ```

    where `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download modules from your Terraform registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download modules and other package types from any registry your user account has access to within your Buildkite organization.

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
