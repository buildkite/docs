# NuGet

Buildkite Package Registries provides registry support for NuGet-based (.NET) packages.

Once your NuGet source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry using a single command, or by configuring your `nuget.config` file.

## Publish a package

The **Publish Instructions** tab of your NuGet source registry includes command/code snippets you can use to configure your environment for publishing packages to this registry. To view and copy the required command or `nuget.config` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your NuGet source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of each respective code box to copy its snippet and paste it into your command line tool or the appropriate file.
1. The following subsections describe the processes in the code boxes above, serving the following use cases:
    * **Quick start** section—for rapid NuGet package publishing, using a temporary token. See [Single command](#publish-a-package-single-command) for detailed instructions on how to configure this command yourself.
    * **Setup** section—implements configurations for a more permanent NuGet package publishing solution. See [Ongoing publishing](#publish-a-package-ongoing-publishing) for detailed instructions on how to configure these commands yourself.

### Single command

The first code box provides a quick mechanism for uploading a NuGet package to your NuGet registry.

```bash
dotnet nuget push *.nupkg --api-key "temporary-write-token-that-expires-after-5-minutes" \
  --source "https://packages.buildkite.com/{org.slug}/{registry.slug}/nuget/package"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/nuget_registry_slug' %>

Since the `temporary-write-token-that-expires-after-5-minutes` expires quickly, it is recommended that you just copy this command directly from the **Publish Instructions** page.

### Ongoing publishing

The remaining code boxes on the **Publish Instructions** page provide configurations for a more permanent solution for ongoing NuGet uploads to your NuGet registry.

1. Create a `nuget.config` file in your project (if one doesn't already exist):

    ```bash
    dotnet new nugetconfig
    ```

1. Copy the following command, paste it and modify as required before running to add the NuGet registry to your `nuget.config` file:

    ```bash
    dotnet nuget add source https://packages.buildkite.com/{org.slug}/{registry.slug}/nuget/index.json \
      --name {org.slug}_{registry.slug} \
      --username _ \
      --password $TOKEN \
      --store-password-in-clear-text \
      --configfile ./nuget.config \
    ```

    where:
    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/nuget_registry_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/nuget_registry_write_token' %>

    **Note:** This step only needs to be conducted once for the life of your NuGet source registry.

1. Publish your NuGet package:

    ```bash
    dotnet nuget push *.nupkg --source {org.slug}_{registry.slug} --api-key $TOKEN
    ```

## Access a package's details

A NuGet package's details can be accessed from its source registry through the **Releases** (tab) section of your NuGet source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your NuGet source registry on this page.
1. On your NuGet source registry page, select the package within the **Releases** (tab) section. The package's details page is displayed.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A NuGet package can be downloaded from the package's details page.

To download a package:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A NuGet package can be installed using code snippet details provided on the package's details page.

To install a package:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** tab is displayed.
1. Follow the relevant section to install the NuGet package, based on your requirements:
    * [Single command](#package-installation-with-a-single-command) (**Quick install** section)—for rapid NuGet package installation, using a temporary token.
    * [Ongoing publishing](#ongoing-package-installation) (**Setup** section)—implements configurations for a more permanent NuGet package installation solution.

<h4 id="package-installation-with-a-single-command">Package installation with a single command</h4>

The **Quick install** code snippet is based on this format:

```bash
dotnet add package package-name -v version.number \
  --source "https://buildkite:temporary-read-token-that-expires-after-5-minutes@packages.buildkite.com/{org.slug}/{registry.slug}/nuget/index.json"
```

where:

- `package-name` is the name of your NuGet package.

- `version.number` is the version of your NuGet package.

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the name of your NuGet registry.

Since the `temporary-read-token-that-expires-after-5-minutes` expires quickly, it is recommended that you just copy this command directly from the **Installation** page.

<h4 id="ongoing-package-installation">Ongoing package installation</h4>

The **Setup** section's instructions are as follows:

1. Create a `nuget.config` file in your project (if one doesn't already exist):

    ```bash
    dotnet new nugetconfig
    ```

1. Copy the following command, paste it and modify as required before running to add the NuGet registry to your `nuget.config` file:

    ```bash
    dotnet nuget add source https://packages.buildkite.com/{org.slug}/{registry.slug}/nuget/index.json \
      --name {registry.slug} \
      --username _ \
      --password $TOKEN \
      --store-password-in-clear-text \
      --configfile ./nuget.config \
      --valid-authentication-types basic
    ```

    where:
    * `$TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#configure-registry-tokens) used to download packages to your NuGet registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This command option and value are not required for registries that are publicly accessible.

    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/nuget_registry_slug' %>

    **Note:** This step only needs to be conducted once for the life of your NuGet source registry.

1. Publish your NuGet package:

    ```bash
    dotnet nuget push *.nupkg --source {registry.slug} --api-key $TOKEN
    ```
