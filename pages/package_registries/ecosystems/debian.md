# Debian

Buildkite Package Registries provides registry support for Debian-based (deb) packages for Debian and Ubuntu operating system variants.

Once your Debian source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via the `curl` command presented on your Debian registry's details page.

To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Debian source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the package to this source registry.

This command provides:

- The specific URL to publish a package to your specific Debian source registry in Buildkite.
- The API access token required to publish packages to this source registry.
- The Debian package file to be published.

## Publish a package

You can use two approaches to publish a deb package to your Debian source registry—[`curl`](#publish-a-package-using-curl) or the [Buildkite CLI](#publish-a-package-using-the-buildkite-cli).

### Using curl

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a deb package to your Debian source registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/debian/package.deb"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Debian source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Debian source registry from the **Registries** page.

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Debian source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Debian source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_debian_package' %>

For example, to upload the file `my-deb-package_1.0-2_amd64.deb` from the current directory to the **My Debian packages** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-debian-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-deb-package_1.0-2_amd64.deb"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish a deb package to your Debian source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/debian/package.deb
```

where:

- `registry-slug` is the slug of your Debian source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Debian source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_debian_package' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a package's details

A Debian (deb) package's details can be accessed from this registry through the **Releases** (tab) section of your Debian source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Debian source registry on this page.
1. On your Debian source registry page, select the package to display its details page.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A Debian (deb) package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Debian package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command set in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

Update the `apt` database and ensure `curl` or `gpg`, or both, is installed:

```bash
apt update && apt install curl gpg -y
```

Install the registry signing key:

```bash
curl -fsSL "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/gpgkey" | gpg --dearmor -o /etc/apt/keyrings/{org.slug}_{registry.slug}-archive-keyring.gpg
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Debian registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

If your Debian source registry is _private_ (the default configuration for source registries), stash the private registry credentials into `apt`'s `auth.conf.d` directory:

```bash
echo "machine https://packages.buildkite.com/{org.slug}/{registry.slug}/ login buildkite password ${registry.read.token}" > /etc/apt/auth.conf.d/{org.slug}_{registry.slug}.conf; chmod 600 /etc/apt/auth.conf.d/{org.slug}_{registry.slug}.conf
```

Configure the source using the installed registry signing key:

```bash
echo -e "deb [signed-by=/etc/apt/keyrings/{org.slug}_{registry.slug}-archive-keyring.gpg] https://packages.buildkite.com/{org.slug}/{registry.slug}/any/ any main\ndeb-src [signed-by=/etc/apt/keyrings/{org.slug}_{registry.slug}-archive-keyring.gpg] https://packages.buildkite.com/{org.slug}/{registry.slug}/any/ any main" > /etc/apt/sources.list.d/buildkite-{org.slug}-{registry.slug}.list
```

#### Package installation

Update the `apt` database and use `apt` to install the package:

```bash
apt update && apt install package-name
```

where `package-name` is the name of your package.
