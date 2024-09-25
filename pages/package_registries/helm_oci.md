# Helm OCI

Buildkite Package Registries provides Helm OCI based registry support for distributing Helm charts. Note, this requires [Helm version 3.8.0](https://helm.sh/docs/topics/registries/) or newer.

Once your Helm OCI registry has been [created](/docs/package-registries/manage-registries#create-a-registry), you can publish/upload charts (generated from your application's build) to this registry via relevant `helm` commands presented on your registry's details page.

To view and copy these `helm` commands:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Helm OCI registry on this page.
1. Select **Publish a Helm Chart** and in the resulting dialog, for each required `helm` command set in the relevant code snippets, copy the relevant code snippet (using the icon at the top-right of its code box), paste it into your terminal, and run it.

These Helm commands are used to:

- Log in to your Buildkite Helm OCI registry with an API access token.
- Publish a Helm chart to your registry.

## Publishing a chart

The following steps describe the process above:

1. Copy the following `helm login` command, paste it into your terminal, and modify as required before running to log in to your registry:

    ```bash
    helm registry login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-write-token
    ```

    where:
    * `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload charts to your Helm registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

    <%= render_markdown partial: 'package-registries/org_slug' %>
    <%= render_markdown partial: 'package-registries/helm_registry_slug' %>

1. Copy the following `helm push` command, paste it into your terminal, and modify as required before running to push your Helm chart:

    ```bash
    helm push {chart-filename.tgz} packages.buildkite.com/{org.slug}/{registry.slug}
    ```

    where `{chart-filename.tgz}` is the filename of the chart you wish to push.

## Access a chart's details

A Helm chart's details can be accessed from this registry using the **Packages** section of your Helm registry page.

To access your Helm chart's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Helm  registry on this page.
1. On your Helm registry page, select the chart to display its details page.

The chart's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-charts-details-downloading-a-chart).
- **Details**: details about:

    * the name of the chart (typically the file name excluding any version details and extension).
    * the chart version.
    * the registry type the chart is located in.
    * the chart's visibility (based on its registry's visibility)—whether the chart is **Private** and requires authentication to access, or is publicly accessible.

- **Pushed**: the date when the last chart was uploaded to the registry.
- **Package size**: the storage size (in bytes) of this chart.
- **Downloads**: the number of times this chart has been downloaded.

### Downloading a chart's manifest

The charts OCI manifest can be downloaded from the details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Select **Download**.

### Downloading a chart

A Helm chart can be obtained using code snippet details provided on the chart's details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

If your registry is _private_ (that is, the default registry configuration), log in to the Helm registry containing the chart to obtain with the following `helm login` command:

```bash
helm registry login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-read-token
```

where:

<%= render_markdown partial: 'package-registries/org_slug' %>

<%= render_markdown partial: 'package-registries/helm_registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#update-a-registry-configure-registry-tokens) used to download charts from your Helm registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

> 📘
> This step is not required for public Helm registries.

#### Chart download

Use the following `helm pull` command to download the chart:

```bash
helm pull oci://packages.buildkite.com/{org.slug}/{registry.slug}/chart-name --version {version}
```

where:

<%= render_markdown partial: 'package-registries/org_slug' %>

<%= render_markdown partial: 'package-registries/helm_registry_slug' %>

- `chart-name` is the name of your chart.

- `version` (optional) the version you wish to download. Without this flag it will download the
  latest version.
