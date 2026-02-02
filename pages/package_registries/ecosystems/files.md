
# Files

Buildkite Package Registries provides registry support for generic _files_ to cover some use cases where native package management either isn't required or isn't available.

Once your **Files** source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload files (of any type and extension) to this registry.

## Publish a file

You can use two approaches to publish a file to your file source registry—[`curl`](#publish-a-file-using-curl) or the [Buildkite CLI](#publish-a-file-using-the-buildkite-cli).

> 📘
> Be aware that file name formats must comply with [semantic version](https://semver.org/). Learn more about this in [File name format requirements](#file-name-format-requirements).

### Using curl

The **Publish Instructions** tab of your files source registry includes a `curl` command you can use to upload a file to this registry. To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your file source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate `$FILE` value) to publish the file to this source registry.

This command provides:

- The specific URL to publish a file to your specific file source registry in Buildkite.
- A temporary API access token to publish files to this source registry.
- The file to be published.

You can also create this command yourself using the following `curl` command (which you'll need to modify as required before submitting):

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/file"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your file source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your file source registry from the **Registries** page.

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload files to your file source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish files and other package types to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your file source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_file' %>

For example, to upload the file `my-custom-app-1.0.0.ipa` from the current directory to the **My files** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-files/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-custom-app-1.0.0.ipa"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish a file to your file source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/file
```

where:

- `registry-slug` is the slug of your file source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your file source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_file' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## File name format requirements

Files uploaded to a file source registry must follow a specific naming convention that includes a [semantic version](https://semver.org/):

```
{BASENAME}-{SEMVER}.{EXT}
```

where:

- `{BASENAME}` is the base name of your file, which can contain letters, numbers, and hyphens.
- `{SEMVER}` is a valid semantic version number (for example, `1.0.0`, `2.3.1-beta.1`, or `1.0.0+build.123`).
- `{EXT}` is the file extension.

The following is a list of valid file name examples:

- `my-app-1.0.0.zip`
- `firmware-2.3.1-beta.1.bin`
- `my-custom-app-1.0.0.ipa`

If your file name doesn't match this format, the upload fails with an error:

```
Invalid filename format. Expected: {BASENAME}-{SEMVER}.{EXT}
```

## Access a file's details

The file's details can be accessed from its source registry through the **Releases** (tab) section of your file source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your file source registry on this page.
1. On your file source registry page, select the file to display its details page.

The file's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-files-details-downloading-a-file).
- **Details** (tab): a list of checksum values for this file—MD5, SHA1, SHA256, and SHA512.
- **About this version**: a brief (metadata) description about the file.
- **Details**: details about:

    * the name of the file (typically the file name excluding any version details and extension).
    * the registry the file is located in.
    * the file's visibility (based on its registry's visibility)—whether the file is **Private** and requires authentication to access, or is publicly accessible.

- **Pushed**: the date when the last file was uploaded to the source registry.
- **File size**: the storage size (in bytes) of this file.
- **Downloads**: the number of times this file has been downloaded.

### Downloading a file

The file can be downloaded from the file's details page. To do this:

1. [Access the file's details](#access-a-files-details).
1. Select **Download**.

Alternatively, a file can be downloaded via the command line using code snippet details provided on the file details page. To do this:

1. [Access the file's details](#access-a-files-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Using curl to download the file

```bash
curl -O -L -H "Authorization: Bearer $TOKEN" \
  https://packages.buildkite.com/{org.slug}/{registry.slug}/files/{filename}
```

where:

- `$TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your files source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Files source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Files source registry from the **Registries** page.

- `{filename}` is the name of the file that you want to download.
