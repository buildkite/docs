# Debian

Buildkite Packages provides registry support for Debian-based (deb) packages for Debian and Ubuntu operating system variants.

Once your Debian registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry via the `curl` command presented on your Debian registry's details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Debian registry on this page.
1. Select **Publish a Debian Package** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and submit it to publish a package to your Debian registry.

This command provides:

- The specific URL to publish a package to your specific Debian registry in Buildkite.
- The API write token required to publish packages to your Debian registry.
- The Debian package file to be published.

## Publish a package

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a package to your Debian registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/debian_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Debian registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'packages/path_to_file' %>

For example, to upload the file `my-deb-package_1.0-2_amd64.deb` from the current directory to the **My-Debian-packages** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-debian-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_MY_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-deb-package_1.0-2_amd64.deb"
```

## Access a package's details

A Debian (deb) package's details can be accessed from this registry using the **Packages** section of your Debian registry page.

To access your deb package's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Debian registry on this page.
1. On your Debian registry page, select the package to display its details page.

<%= render_markdown partial: 'packages/package_details_page_sections' %>

### Downloading a package

A Debian (deb) package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Debian package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Installation instructions** section is displayed.
1. For each required command set in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and submit it.

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

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) used to download packages from your Debian registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/debian_registry_slug' %>

If your registry is _private_ (that is, the default registry configuration), stash the private registry credentials into `apt`'s `auth.conf.d` directory:

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
