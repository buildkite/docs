# Debian

Buildkite Packages provides repository support for Debian-based packages (deb) in Debian and Ubuntu variants.

Once your deb (Debian and Ubuntu) package repository has been [created](/docs/packages/manage-repositories#create-a-repository), you can publish/upload packages (generated from your application's build) to this repository via the `curl` command presented on your deb package repository's details page.

To view and copy this `curl` command:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select your deb package repository on this page.
1. Select _Publish a Deb Package_ and in the resulting dialog, use the copy icon at the top-right of the code box to copy this curl command and submit it to publish a package to your deb package repository.

This command provides:

- The specific URL to publish a package to your specific deb package repository in Buildkite.
- The API write token (generated by Buildkite Packages) required to publish packages to your deb package repository.

## Publish a package

The following `curl` command (modified accordingly before submitting) describes the process above to publish a package to your deb package repository:

```bash
curl -X POST https://buildkitepackages.com/api/v1/repos/{org.slug}/{repository.name}/packages.json \
  -H "Authorization: Bearer $PACKAGE_REPOSITORY_WRITE_TOKEN" \
  -F "package[package_file]=@<path_to_file>"
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/deb_package_repository_name' %>

- `$PACKAGE_REPOSITORY_WRITE_TOKEN` is the Buildkite Packages-generated API token required to publish/upload packages to your deb package repository.

<%= render_markdown partial: 'packages/path_to_file' %>

For example, to upload the file `my-deb-package_1.0-2_amd64.deb` from the current directory to the _My-Debian-packages_ repository in the _My organization_ Buildkite organization, run the `curl` command:

```bash
curl -X POST https://buildkitepackages.com/api/v1/repos/my-organization/my-debian-packages/packages.json \
  -H "Authorization: Bearer $REPLACE_WITH_MY_PACKAGE_REPOSITORY_WRITE_TOKEN" \
  -F "package[package_file]=@my-deb-package_1.0-2_amd64.deb"
```

## Access a package's details

A Debian (deb) package's details can be accessed from this repository using the _Packages_ section of your deb package repository page.

To access your deb package's details page:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select your deb package repository on this page.
1. Select the package within the _Packages_ section of the deb package repository page. The package's details page is displayed.

<%= render_markdown partial: 'packages/package_details_page_sections' %>

### Downloading a package

A Debian (deb) package can be downloaded from the package's details page.

To download a package:

1. [Access the package's details](#access-a-packages-details).
1. Select _Download_.

### Installing a package

1. [Access the package's details](#access-a-packages-details).
1. Ensure the _Installation_ > _Installation instructions_ section is displayed.
1. Copy the code snippet and paste it into your terminal.

This package code snippet is based on this format:

```bash
apt update
type -p curl >/dev/null || apt install curl -y
type -p gpg >/dev/null || apt install gpg -y
curl -fsSL "https://buildkitepackages.com/{org.slug}/{repository.name}/gpgkey" | gpg --dearmor -o /etc/apt/keyrings/{org.slug}_{repository.name}-archive-keyring.gpg
curl -sfSL "https://buildkitepackages.com/install/repositories/{org.slug}/{repository.name}/config_file.list?source=buildkite&name=${HOSTNAME}" > /etc/apt/sources.list.d/buildkite-{org.slug}-{repository.name}.list
apt update && apt install my-deb-package-name
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/deb_package_repository_name' %>
