# JavaScript

Buildkite Package Registries provides registry support for JavaScript-based (Node.js npm) packages.

Once your JavaScript source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry by configuring your `~/.npmrc` and application's relevant `package.json` files with the command/code snippets presented on your JavaScript registry's details page.

To view and copy the required command/code snippet for your `~/.npmrc` and `package.json` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your JavaScript source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of each respective code box to copy the its snippet and paste it into your command line tool or the appropriate file.

    These file configurations contain the following:
    * `~/.npmrc`: the URL for your specific JavaScript source registry in Buildkite and the API access token required to publish the package to this registry.
    * `package.json`: the URL for this source registry.

1. You can then run the `npm pack` and `npm publish` commands to publish the package to this source registry.

## Publish a package

The following steps describe the process above:

1. Copy the following `npm` command, paste it into your terminal, and modify as required before running to update your `~/.npmrc` file:

    ```bash
    npm set //packages.buildkite.com/{org.slug}/{registry.slug}/npm/:_authToken registry-write-token
    ```

    where:
    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/javascript_registry_slug' %>
    <%= render_markdown partial: 'package_registries/javascript_registry_write_token' %>

    **Note:**
    * If your `.npmrc` file doesn't exist, this command automatically creates it for you.
    * This step only needs to be performed once for the life of your JavaScript source registry.

1. Copy the following JSON code snippet (or the line of code beginning `"publishConfig": ...`), paste it into your Node.js project's `package.json` file, and modify as required:

    ```json
    {
      ...,
      "publishConfig": {"registry": "https://packages.buildkite.com/{org.slug}/{registry.slug}/npm/"}
    }
    ```

    **Note:** Don't forget to add the separating comma between `"publishConfig": ...` and the previous field.

1. Build and publish your package:

    ```bash
    npm pack
    npm publish
    ```

## Access a package's details

A JavaScript package's details can be accessed from this registry through the **Releases** (tab) section of your JavaScript source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your JavaScript source registry on this page.
1. On your JavaScript source registry page, select the package to display its details page.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A JavaScript package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

<h3 id="access-a-packages-details-installing-a-package"></h3>

### Installing a package from a source registry

A JavaScript package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. If your JavaScript source registry is _private_  (the default configuration for source registries) and you haven't already performed this `.npmrc` configuration step, copy the `npm set` command from the [**Registry Configuration**](#registry-configuration) section, paste it into your terminal, and modify as required before running to update your `~/.npmrc` file.
1. Copy the `npm install ...` command from the [**Package Installation**](#package-installation) section, paste it into your terminal, and modify as required before running it.

<h4 id="registry-configuration">Registry Configuration</h4>

If your JavaScript source registry is _private_, set its authentication details in the `.npmrc` file by running the `npm set` command:

```bash
npm set //packages.buildkite.com/{org.slug}/{registry.slug}/npm/:_authToken registry-read-token
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your JavaScript source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

> 📘
> If your `.npmrc` file doesn't exist, this command automatically creates it for you.
> This step only needs to be performed once for the life of your JavaScript registry, and it is not required for public JavaScript registries.

<h4 id="package-installation">Package Installation</h4>

Install your JavaScript package by running the `npm install` command:

```bash
npm install nodejs-package-name@version.number \
  --registry https://packages.buildkite.com/{org.slug}/{registry.slug}/npm/
```

where:

- `nodejs-package-name` is the name of your Node.js package (that is, the `name` field value from its `package.json` file).

- `version.number` is the version of your Node.js package (that is, the `version` field value from its `package.json` file).

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>
