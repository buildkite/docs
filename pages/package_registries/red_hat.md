# Red Hat

Buildkite Package Registries provides registry support for Red Hat-based (RPM) packages for Red Hat Linux operating systems.

Once your Red Hat registry has been [created](/docs/package-registries/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry via the relevant `curl` command presented on your Red Hat registry's details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Red Hat registry on this page.
1. Select **Publish an RPM Package** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and run it to publish a package to your Red Hat registry.

This command provides:

- The specific URL to publish a package to your specific Red Hat registry in Buildkite.
- The API access token required to publish packages to your Red Hat registry.
- The Red Hat (RPM) package file to be published.

## Publish a package

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish an RPM package to your Red Hat registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'package-registries/org_slug' %>

<%= render_markdown partial: 'package-registries/red_hat_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Red Hat registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package-registries/path_to_file' %>

For example, to upload the file `my-red-hat-package_1.0-2.x86_64.rpm` from the current directory to the **My Red Hat packages** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-red-hat-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-red-hat-package_1.0-2.x86_64.rpm"
```

## Access a package's details

A Red Hat (RPM) package's details can be accessed from this registry using the **Packages** section of your Red Hat registry page.

To access your RPM package's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Red Hat registry on this page.
1. On your Red Hat registry page, select the package to display its details page.

<%= render_markdown partial: 'package-registries/package_details_page_sections' %>

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

<%= render_markdown partial: 'package-registries/red_hat_registry_slug' %>

- `{registry.name}` is the name of your Red Hat registry.

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#update-a-registry-configure-registry-tokens) used to download packages from your Red Hat registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package-registries/org_slug' %>

#### Package installation

Use `dnf` to install the package:

```bash
dnf install -y package-name
```

where `package-name` is the name of your package, which usually includes the version number and distribution type.
