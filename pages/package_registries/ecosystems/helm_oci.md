# Helm OCI

Buildkite Package Registries provides Helm Open Container Initiative (OCI)-based registry support for distributing Helm charts. [Helm version 3.8.0](https://helm.sh/docs/topics/registries/) or newer is required as these versions provide support for OCI. While this page is for OCI-based Helm source registry publishing instructions, you can alternatively publish to a [standard Helm source registry](/docs/package-registries/ecosystems/helm).

Once your Helm OCI source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload charts (generated from your application's build) to this registry.

## Publish a chart

The **Publish Instructions** tab of your Helm OCI source registry includes `helm` commands you can use to upload a chart to this registry. To view and copy these `helm` commands:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Helm OCI source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, for each required `helm` command in code snippets provided, copy the relevant code snippet (using the icon at the top-right of its code box), paste it into your terminal, and run it with the appropriate values to publish the chart to this source registry.

These commands are used to:

- Log in to your Buildkite Helm OCI source registry with a temporary API access token.
- Publish a Helm chart to this source registry.

You can also run these commands yourself (modifying them as required before running):

1. Copy the following `helm login` command, paste it into your terminal, and modify as required before running to log in to your Helm OCI source registry:

    ```bash
    helm registry login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-write-token
    ```

    where:
    * `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload charts to your Helm OCI source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish charts and other package types to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Helm OCI source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/helm_registry_slug' %>

1. Copy the following `helm push` command, paste it into your terminal, and modify as required before running to publish your Helm chart:

    ```bash
    helm push {chart-filename.tgz} packages.buildkite.com/{org.slug}/{registry.slug}
    ```

    where `{chart-filename.tgz}` is the name of the chart file to be published.

## Access a chart's details

A Helm chart's details can be accessed from its source registry through the **Releases** (tab) section of your Helm registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Helm OCI source registry on this page.
1. On your Helm OCI source registry page, select the chart to display its details page.

The chart's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-charts-details-downloading-a-chart).
- **Details**: details about:

    * the name of the chart (typically the file name excluding any version details and extension).
    * the chart version.
    * the source registry (type) the chart is located in.
    * the chart's visibility (based on its registry's visibility)—whether the chart is **Private** and requires authentication to access, or is publicly accessible.

- **Pushed**: the date when the last chart was uploaded to the source registry.
- **Package size**: the storage size (in bytes) of this chart.
- **Downloads**: the number of times this chart has been downloaded.

### Downloading a chart's manifest

A Helm chart's OCI manifest can be downloaded from the details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Select **Download**.

### Downloading a chart

A Helm chart can be obtained using code snippet details provided on the chart's details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

If your Helm OCI source registry is _private_ (the default configuration for source registries), log in to the Helm registry containing the chart to obtain with the following `helm login` command:

```bash
helm registry login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-read-token
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download charts from your Helm OCI registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download charts and other package types from any registry your user account has access to within your Buildkite organization.

> 📘
> This step is not required for public Helm (OCI) registries.

#### Chart download

Use the following `helm pull` command to download the chart:

```bash
helm pull oci://packages.buildkite.com/{org.slug}/{registry.slug}/chart-name --version {version}
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `chart-name` is the name of your chart.

- `version` (optional) the version of the chart to download. Without this option, the latest chart version is downloaded.
