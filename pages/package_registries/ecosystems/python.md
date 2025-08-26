# Python

Buildkite Package Registries provides registry support for Python-based (PyPI) packages.

Once your Python source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via the `curl` command presented on your Python registry's details page.

To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the package to this source registry.

This command provides:

- The specific URL to publish a package to your specific Python source registry in Buildkite.
- The API access token required to publish packages to this source registry.
- The Python package file to be published.

## Publish a package

You can use two approaches to publish a Python package to your Python source registry—[`curl`](#publish-a-package-using-curl) or the [Buildkite CLI](#publish-a-package-using-the-buildkite-cli).

### Using curl

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a Python package to your Python source registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/python/package.tar.gz"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Python source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Python source registry from the **Registries** page.

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Python source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Python source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_python_package' %>

For example, to upload the file `my-python-package-0.9.7b1.tar.gz` from the current directory to the **My Python packages** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-python-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-python-package-0.9.7b1.tar.gz"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish a Python package to your Python source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/python/package.tar.gz
```

where:

- `registry-slug` is the slug of your Python source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your file source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_python_package' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a package's details

A Python package's details can be accessed from this registry through the **Releases** (tab) section of your Python source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python source registry on this page.
1. On your Python source registry page, select the package to display its details.

> 📘
> If your Python source registry is an upstream of a [composite registry](/docs/package-registries/registries/manage#composite-registries), you can also access a Python package's details from this composite registry (listed on the **Registries** page) by selecting the relevant Python composite registry > from the **Upstreams** tab, select the relevant Python source registry, then its relevant package.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A Python package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

<h3 id="access-a-packages-details-installing-a-package"></h3>

### Installing a package from a source registry

A Python package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. Copy the relevant code snippet from the [**Registry Configuration**](#registry-configuration-source-registry) section and paste it into either the package installer for Python (pip) configuration (`pip.conf`) file or end of the virtualenv `requirements.txt` file.
1. Run the installation command from the [**Package Installation**](#package-installation-source-registry) section.

<h4 id="registry-configuration-source-registry">Registry Configuration</h4>

The `pip.conf` code snippet is based on this format:

```conf
# Add this to the [global] section in your ~/.pip/pip.conf:
[global]
extra-index-url="https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

or the alternative `requirements.txt` (for virtualenv) code snippet is based on this format:

```ini
# Otherwise if installing on a virtualenv, add this to the bottom of your requirements.txt:
--extra-index-url="https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Python source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

<h4 id="package-installation-source-registry">Package Installation</h4>

Use `pip` to install the package:

```bash
pip install package-name==version-number
```

where:

- `package-name` is the name of your package.

- `version-number` is the version number of this package.

### Installing a package from a composite registry

If your Python source registry is an upstream of a [composite registry](/docs/package-registries/registries/manage#composite-registries), you can install one of its packages using the code snippet details provided on the composite registry's **Setup & Usage** page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python composite registry on this page.
1. Select the **Setup & Usage** tab to display the **Usage Instructions** page.
1. Select either the **pip** or **uv** tab, based on your Python package management tool.
1. Run the relevant installation command from either of the first two code snippets. Learn more about this in [Package installation from a composite registry](#package-installation-from-a-composite-registry), below.

    Alternatively, to run abbreviated installation commands by configuring the composite registry's URL in the relevant package tool config files or environment variables, copy the appropriate code snippet/s from the third (or later) code snippets on the Buildkite interface. Learn more about this in [Composite registry configuration](#composite-registry-configuration), below.

<h4 id="package-installation-from-a-composite-registry">Package installation from a composite registry</h4>

**For pip**, use one of these `pip` commands (with either the [`--index-url`](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-i) or [`--extra-index-url`](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url) options) to install the package:

```bash
pip install --index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple ...
```

or

```bash
pip install --extra-index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple ...
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Python composite registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

**For uv**, use one of these `uv` commands (with either the [`--index-url`](https://docs.astral.sh/uv/reference/settings/#index-url) or [`--extra-index-url`](https://docs.astral.sh/uv/reference/settings/#extra-index-url) options) to ensure your Python project's environment has been updated, along with all of its dependencies:

```bash
uv sync --index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

or

```bash
uv sync --extra-index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

<h4 id="composite-registry-configuration">Composite registry configuration</h4>

**For pip**, modify the following code snippet and add it to the `pip.conf` file:

```conf
[global]
index-url = https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

or for the alternative virtualenv for pip, modify the following code snippet and add it to the `requirements.txt` file:

```ini
--index-url="https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Python composite registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

You can now install Python packages from your composite registry using the abbreviated command `pip install package-name==version.number`.

**For uv**, modify the following code snippet and add it to the `pyproject.toml` file:

```toml
[tool.uv]
index-url = "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

You can now ensure your Python project's environment has been updated, along with all its dependencies, using the abbreviated command `uv sync`.
