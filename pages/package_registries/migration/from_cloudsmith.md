# Export from Cloudsmith

To migrate your packages from Cloudsmith to Buildkite Package Registries, you'll need to export and download packages from a Cloudsmith repository before importing them to your Buildkite registry.

## Download packages using the Cloudsmith interface

Cloudsmith offers two options to download specific packages from a Cloudsmith repository through its interface, one of which also involves command execution through a command line interface (CLI):

- To download individual packages, follow Cloudsmith's [Download via Website UI](https://help.cloudsmith.io/docs/download-a-package#download-via-website-ui) guide for either [public](https://help.cloudsmith.io/docs/download-a-package#public-repositories) or [private](https://help.cloudsmith.io/docs/download-a-package#private-repositories) repositories.

- To download packages using native package management tools (for example, `npm`  or `gem`), follow Cloudsmith's [Downloading via Native Package Manager](https://help.cloudsmith.io/docs/download-a-package#download-via-native-package-manager) guide. This guide provides details on how to use the Cloudsmith interface to access specific instructions for each native package management tool. These specific instructions then provide guidance on using the relevant native package management's own CLI tools to download packages from Cloudsmith.

> 📘
> Cloudsmith does not provide a mechanism to download packages in bulk from a repository through its interface. However, scripting-based methods (using the [Cloudsmith CLI](https://help.cloudsmith.io/docs/cli) tool) are available to [download packages in bulk](#download-packages-in-bulk).

## Download packages using the Cloudsmith REST API or CLI tool

Cloudsmith does not support downloading packages directly using its [REST API](https://help.cloudsmith.io/reference/introduction) or [CLI](https://help.cloudsmith.io/docs/cli) tool.

However, download URLs can be obtained using the Cloudsmith REST API or its command line interface (CLI), which in turn can then be used to download packages from a Cloudsmith repository.

> 📘
> If you are using the Cloudsmith CLI to download packages, ensure that your [Cloudsmith API key](https://help.cloudsmith.io/docs/cli#getting-your-api-key) has been set up correctly.

### Retrieving download URLs using the REST API

To retrieve the download URL/s for one or more packages in a Cloudsmith repository [using the Cloudsmith API](https://help.cloudsmith.io/reference/packages_list):

```bash
curl -X GET "https://api.cloudsmith.io/v1/packages/{owner}/{repository}/" \
  -H "X-Api-Key: $CLOUDSMITH_API_KEY" \
  -H 'accept: application/json' | jq '.[].cdn_url'
```

where:

- `{owner}` is your Cloudsmith account or organization name.
- `{repository}` is your Cloudsmith repository name/slug.
- `$CLOUDSMITH_API_KEY` is your [Cloudsmith API key](https://help.cloudsmith.io/docs/api-key).

The `jq '.[].cdn_url` command transforms the JSON response from this Cloudsmith REST API query to list the URLs for individual packages, which can then be used to download them from this repository.

### Retrieving download URLs using the CLI

To retrieve the download URL/s for one or more packages in a Cloudsmith repository [using the Cloudsmith CLI](https://help.cloudsmith.io/docs/search-packages#searching-packages-via-the-cloudsmith-cli):

```bash
cloudsmith list packages {owner}/{repository} -F json | jq -r '.data[].cdn_url'
```

where:

- `{owner}` is your Cloudsmith account or organization name.
- `{repository}` is your Cloudsmith repository name/slug.

The `jq -r '.data[].cdn_url` command transforms the JSON-formatted response from this Cloudsmith CLI command to list the URLs for individual packages, which can then be used to download them from this repository.

> 📘
> The command `cloudsmith list packages` can also be contracted to `cloudsmith ls pkgs`.
> Note that the [Cloudsmith CLI](https://help.cloudsmith.io/docs/cli) tool can also be used to [download packages in bulk](#download-packages-in-bulk).

### Download a package

Once you have obtained the relevant download URLs (using the [REST API](#download-packages-using-the-cloudsmith-rest-api-or-cli-tool-retrieving-download-urls-using-the-rest-api) or [CLI](#download-packages-using-the-cloudsmith-rest-api-or-cli-tool-retrieving-download-urls-using-the-cli)) for packages from your Cloudsmith registry, you can download using the `wget` command to download them.

To download a package from a _public_ repository:

```bash
wget {cdn_url}
```

where `{cdn_url}` is the URL of your package to be downloaded.

To download a package from a _private_ repository:

```bash
wget -d --header="X-Api-Key: $CLOUDSMITH_API_KEY" {cdn_url} 
```

where `$CLOUDSMITH_API_KEY` is your [Cloudsmith API key](https://help.cloudsmith.io/docs/api-key).

Or:

```bash
wget --http-user=$account --http-password=$token {cdn_url}
```

where:

- `$account` is your Cloudsmith account or organization name.
- `$token` is an appropriate [Cloudsmith entitlement token](https://help.cloudsmith.io/docs/entitlements).

## Download packages in bulk

Packages can be downloaded in bulk from a Cloudsmith repository using the [Cloudsmith CLI](https://help.cloudsmith.io/docs/cli) tool, along with some scripting.

Learn more about how to do this from the [Bulk Package Download](https://help.cloudsmith.io/docs/download-a-package#bulk-package-download) section of Cloudsmith's documentation, which provides scripting examples for Linux (bash) and Windows (PowerShell).

## Next step

Once you have downloaded your packages from your Cloudsmith repositories, learn how to [import them into your Buildkite registry](/docs/package-registries/migration/import-to-package-registries).
