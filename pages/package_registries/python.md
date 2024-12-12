# Python

Buildkite Package Registries provides registry support for Python-based (PyPI) packages.

Once your Python source registry has been [created](/docs/package-registries/manage-registries#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via the `curl` command presented on your Python registry's details page.

To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python source registry on this page.
1. Select **Publish a Python Package** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and run it to publish a package to your Python registry.

This command provides:

- The specific URL to publish a package to your specific Python source registry in Buildkite.
- The API access token required to publish packages to your Python source registry.
- The Python package file to be published.

## Publish a package

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a Python package to your Python source registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/python_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Python source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any source registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/path_to_file' %>

For example, to upload the file `my-python-package-0.9.7b1.tar.gz` from the current directory to the **My Python packages** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-python-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-python-package-0.9.7b1.tar.gz"
```

## Access a package's details

A Python package's details can be accessed from this registry through the **Releases** (tab) section of your Python source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python source registry on this page.
1. On your Python source registry page, select the package to display its details.

> 📘
> If your Python source registry is an upstream of a [composite registry](/docs/package-registries/manage-registries#composite-registries), you can also access a Python package's details from this composite registry (listed on the **Registries** page) by selecting the relevant Python composite registry > from the **Upstreams** tab, select the relevant Python source registry, then its relevant package.

<%= render_markdown partial: 'package_registries/package_details_page_sections' %>

### Downloading a package

A Python package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

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

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#configure-registry-tokens) used to download packages from your Python source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/registry_slug' %>

The alternative `requirements.txt` (for virtualenv) code snippet is based on this format:

```ini
# Otherwise if installing on a virtualenv, add this to the bottom of your requirements.txt:
--extra-index-url="https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

<h4 id="package-installation-source-registry">Package Installation</h4>

Use `pip` to install the package:

```bash
pip install package-name==version-number
```

where:

- `package-name` is the name of your package.

- `version-number` is the version number of this package.

### Installing a package from a composite registry

If your Python source registry is an upstream of a [composite registry](/docs/package-registries/manage-registries#composite-registries), you can install one of its packages using the code snippet details provided on the composite registry's **Setup & Usage** page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Python composite registry on this page.
1. Select the **Setup & Usage** tab to reveal the **Usage Instructions** page.
1. Select either the **pip** or **uv** tab, based on your Python package management tool.
1. Run the relevant installation command from either of the first two code snippets. Learn more about this in [Package installation from a composite registry](#package-installation-from-a-composite-registry), below.
1. Copy the relevant code snippet/s from the third (or later) code snippets and for:
    * The package installer for Python (pip), paste this code snippet into either the `pip.conf` configuration file or the end of the virtualenv `requirements.txt` file.
    * The uv Python package management tool, paste this code snippet into the `pyproject.toml` configuration file.

    Learn more about this in [Composite registry configuration](#composite-registry-configuration), below.

<h4 id="package-installation-from-a-composite-registry">Package installation from a composite registry</h4>

For pip, use one of these `pip` commands (with either the [`--index-url`](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-i) or [`--extra-index-url`](https://pip.pypa.io/en/stable/cli/pip_install/#cmdoption-extra-index-url) options) to install the package:

```bash
pip install --index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple ...
```

or

```bash
pip install --extra-index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple ...
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#configure-registry-tokens) used to download packages from your Python composite registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/registry_slug' %>

Likewise, for uv, use one of these `uv` commands (with either the [`--index-url`](https://docs.astral.sh/uv/reference/settings/#index-url) or [`--extra-index-url`](https://docs.astral.sh/uv/reference/settings/#extra-index-url) options) to install the package:

```bash
uv sync --index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

or

```bash
uv sync --extra-index-url=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

<h4 id="composite-registry-configuration">Composite registry configuration</h4>

For pip, modify the following code snippet and add it to the `pip.conf` file:

```conf
[global]
index-url = https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#configure-registry-tokens) used to download packages from your Python composite registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/registry_slug' %>

As an alternative virtualenv for pip, modify the following code snippet and add it to the `requirements.txt` file:

```ini
--index-url="https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```

For uv, modify the following code snippet and add it to the `pyproject.toml` file:

```toml
[tool.uv]
index-url = "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/pypi/simple"
```
