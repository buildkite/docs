# Helm

Buildkite Package Registries provides Helm registry support for distributing Helm charts. While this page is for standard Helm source registry publishing instructions, you can alternatively publish to an [Helm OCI-based source registry](/docs/package-registries/ecosystems/helm-oci).

Once your Helm source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload charts (generated from `helm package` to create the package) to this registry.

## Publish a chart

You can use two approaches to publish a chart to your Helm source registry—[`curl`](#publish-a-chart-using-curl) or the [Buildkite CLI](#publish-a-chart-using-the-buildkite-cli).

### Using curl

The **Publish Instructions** tab of your Helm source registry includes a `curl` command you can use to upload a chart to this registry. To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Helm source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the chart to this source registry.

This command provides:

- The specific URL to publish a chart to your specific Helm source registry in Buildkite.
- A temporary API access token to publish charts to this source registry.
- The Helm chart (`.tgz`) to be published.

You can also create this command yourself using the following `curl` command (which you'll need to modify as required before submitting):

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/helm/chart.tgz"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/helm_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload charts to your Helm source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish charts and other package types to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Helm source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_helm_chart' %>

For example, to upload the file `my-helm-chart-0.1.2.tgz` from the current directory to the **My Helm Charts** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-helm-charts/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-helm-chart-0.1.2.tgz"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish a chart to your Helm source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/helm/chart.tgz
```

where:

- `registry-slug` is the slug of your Helm source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Helm source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_helm_chart' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a chart's details

A Helm chart's details can be accessed from its source registry through the **Releases** (tab) section of your Helm registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Helm source registry on this page.
1. On your Helm source registry page, select the chart to display its details page.

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

### Downloading a chart

A Helm (tgz) chart can be downloaded from the chart's details page. To do this:

1. [Access the chart's details](#access-a-charts-details).
1. Select **Download**.

#### Registry configuration

If your Helm source registry is _private_ (the default configuration for source registries), configure your Helm registry locally for repeated use:

```bash
helm repo add {registry.slug} https://packages.buildkite.com/{org.slug}/{registry.slug}/helm \
  --username buildkite \
  --password registry-read-token
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download charts from your Helm registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download charts and other package types from any registry your user account has access to within your Buildkite organization.

> 📘
> This step is not required for public Helm registries.

#### Chart installation

Use the following `helm install` command to download the chart:

```bash
helm install "chart-release" "{registry.slug}/{chart-name}" --version {version}
```

where:

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `chart-release` is the unique release name for the Helm chart—this value must contain no `.` and be in lowercase. Learn more about chat name naming conventions in the [Chart Names section of the General Conventions](https://helm.sh/docs/chart_best_practices/conventions/#chart-names) page in the Helm documentation.

- `chart-name` is the name of your chart.

- `version` (optional) the version of the chart to download. Without this option, the latest chart version is downloaded.
