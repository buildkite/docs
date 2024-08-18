# Helm

Buildkite Packages provides Helm registry support for distributing Helm charts.

This page is for standard helm publishing instructions, alternatively you can also publish to an [OCI-based registry](/docs/packages/helm-oci).

Once your Helm registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload charts (generated from `helm package` to create the package) to this registry via the relevant `curl` command presented on your Helm registry's details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Helm registry on this page.
1. Select **Publish a Helm Chart** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and run it to publish your chart to your Helm registry.

This command provides:

- The specific URL to publish a package to your specific Helm registry in Buildkite.
- The API access token required to publish packages to your Helm registry (if private registry).
- The Helm package (`.tgz`) to be published.

## Publishing a chart

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a Helm chart to your Helm registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/helm_registry_slug' %>

<%= render_markdown partial: 'packages/path_to_file' %>

For example, to upload the file `my-helm-chart-0.1.2.tgz` from the current directory to the **My Helm Charts** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-helm-charts/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-helm-chart-0.1.2.tgz"
```

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

### Downloading a chart

A Helm (tgz) package can be downloaded from the package's details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Select **Download**.

#### Registry configuration

If your registry is _private_ (that is, the default registry configuration), configure your Helm registry locally for repeated use:

```bash
helm repo add {registry.slug} https://packages.buildkite.com/{org.slug}/{registry.slug}/helm \
    --username buildkite \
    --password registry-read-token
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/helm_registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/packages/manage-registries#update-a-registry-configure-registry-tokens) used to download charts from your Helm registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

> 📘
> This step is not required for public Helm registries.


#### Chart installation

Use the following `helm install` command to download the chart:

```bash
helm install "chart-release" "{registry.slug}/{chart-name}" --version {version}
```

where:

<%= render_markdown partial: 'packages/helm_registry_slug' %>

- `chart-release` is the unique release name for the Helm chart - must have no `.` in name and be in lowercase. [General conventions](https://helm.sh/docs/chart_best_practices/conventions/#chart-names).

- `chart-name` is the name of your chart.

- `version` (optional) the version you wish to download. Without this flag it will download the latest version.
