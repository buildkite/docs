# Red Hat

Buildkite Package Registries provides registry support for Red Hat-based (RPM) packages for Red Hat Linux operating systems.

Once your Red Hat source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry.

## Publish a package

You can use two approaches to publish an RPM package to your Red Hat source registry—[`curl`](#publish-a-package-using-curl) or the [Buildkite CLI](#publish-a-package-using-the-buildkite-cli).

### Using curl

The **Publish Instructions** tab of your Red Hat source registry includes a `curl` command you can use to upload a package to this registry. To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Red Hat source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the package to this source registry.

This command provides:

- The specific URL to publish a package to your specific Red Hat source registry in Buildkite.
- A temporary API access token to publish packages to this source registry.
- The Red Hat (RPM) package file to be published.

You can also create this command yourself using the following `curl` command (which you'll need to modify as required before submitting):

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/red-hat/package.rpm"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/red_hat_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Red Hat source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Red Hat source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_red_hat_package' %>

For example, to upload the file `my-red-hat-package_1.0-2.x86_64.rpm` from the current directory to the **My Red Hat packages** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-red-hat-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-red-hat-package_1.0-2.x86_64.rpm"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish an RPM package to your Red Hat source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/red-hat/package.rpm
```

where:

- `registry-slug` is the slug of your Red Hat source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your file source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_red_hat_package' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a package's details

A Red Hat (RPM) package's details can be accessed from this registry through the **Releases** (tab) section of your Red Hat source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Red Hat source registry on this page.
1. On your Red Hat source registry page, select the package to display its details page.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A Red Hat (RPM) package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Red Hat package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

Configure your Red Hat registry as the source for your Red Hat (RPM) packages:

```bash
sudo sh -c 'echo -e "[{registry.slug}]\nname={registry.name}\nbaseurl=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/gpgkey\npriority=1"' > /etc/yum.repos.d/{registry.slug}.repo
```

where:

<%= render_markdown partial: 'package_registries/ecosystems/red_hat_registry_slug' %>

- `{registry.name}` is the name of your Red Hat registry.

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Red Hat registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

#### Package installation

Use `dnf` to install the package:

```bash
dnf install -y package-name
```

where `package-name` is the name of your package, which usually includes the version number and distribution type.
