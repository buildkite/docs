# NuGet

Buildkite Package Registries provides registry support for NuGet-based (.NET) packages.

Once your NuGet source registry has been [created](/docs/package-registries/manage-registries#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via a single command, or by configuring your `nuget.config` file with the code snippets presented on your NuGet registry's details page.

To view and copy the required command or `nuget.config` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your NuGet source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of each respective code box to copy the its snippet and paste it into your command line tool or the appropriate file.

## Publish a package

The following subsections describe the processes in the code boxes above, serving the following use cases:

- [Single command](#publish-a-package-single-command)—for rapid NuGet package publishing, using a temporary token.
- [Ongoing publishing](#publish-a-package-ongoing-publishing)—implements configurations for a more permanent NuGet package publishing solution.

### Single command

The first code box provides a quick mechanism for uploading a NuGet package to your NuGet registry.

```bash
dotnet nuget push *.nupkg --api-key "temporary-write-token-that-expires-after-5-minutes" \
  --source "https://packages.buildkite.com/{org.slug}/{registry.slug}/nuget/package"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/nuget_registry_slug' %>

Since the `temporary-write-token-that-expires-after-5-minutes` expires quickly, it is recommended that you just copy this command directly from the **Publish Instructions** page.

### Ongoing publishing

The remaining code boxes on the **Publish Instructions** page provide configurations for a more permanent solution for ongoing NuGet uploads to your NuGet registry.

1. Create a `nuget.config` file in your project (if one doesn't already exist):

    ```bash
    dotnet new nugetconfig
    ```

1. Add the Buildkite registry to your `nuget.config` with your API Access Token:

    ```bash
    dotnet nuget add source https://packages.buildkite.com/{org.slug}/{registry.slug}/nuget/index.json \
      --name {registry.slug} \
      --username _ \
      --password $TOKEN \
      --store-password-in-clear-text \
      --configfile ./nuget.config \
    ```

    where:
    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/nuget_registry_slug' %>
    <%= render_markdown partial: 'package_registries/nuget_registry_write_token' %>

    **Note:** This step only needs to be conducted once for the life of your NuGet source registry.

1. Publish your NuGet package:

    ```bash
    dotnet nuget push *.nupkg --source {registry.slug} --api-key $TOKEN
    ```

## Access a package's details

A NuGet package's details can be accessed from this registry through the **Releases** (tab) section of your NuGet source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your NuGet source registry on this page.
1. On your NuGet source registry page, select the package within the **Releases** (tab) section. The package's details page is displayed.

<%= render_markdown partial: 'package_registries/package_details_page_sections' %>

### Downloading a package

A NuGet package can be downloaded from the package's details page.

To download a package:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A NuGet package can be installed using code snippet details provided on the package's details page.

To install a package:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. Copy the command in the code snippet, paste it into your terminal, and run it.

This code snippet is based on this format:

```bash
dotnet add package package-name -v version.number \
  --source "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/nuget/index.json"
```

where:

- `package-name` is the name of your NuGet package.

- `version.number` is the version of your NuGet package.

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#configure-registry-tokens) used to download packages to your NuGet registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the name of your NuGet registry.
