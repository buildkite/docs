# Export from Cloudsmith

To migrate your packages from Cloudsmith to Buildkite Package Registries, you will need to export/download packages from Cloudsmith repository before importing them to your Buildkite registry.

## Download packages via the Website UI

Cloudsmith offers two options to download packages via UI:
- To download packages using Native Package Manager(such as `npm`  or `gem` packages), follow the guide on [downloading via Native Package Manager](https://help.cloudsmith.io/docs/download-a-package#download-via-native-package-manager).
- To download packages via their website's UI, follow the guide for [downloading public repositories](https://help.cloudsmith.io/docs/download-a-package#public-repositories) and [downloading private repositories](https://help.cloudsmith.io/docs/download-a-package#private-repositories).

## Downloading packages via the API
 
Cloudsmith does not support downloading a package directly via the API or its [CLI tool](https://help.cloudsmith.io/docs/cli). However, a URL can be obtained via the API or CLI that can be used to download a package. When downloading via the CLI, please ensure that the API Key has been setup correctly. Refer to the [CLI documentation](https://help.cloudsmith.io/docs/cli) for full details.
 
To retrieve the download URL of the packages in a repository via the API:
  ```bash
curl -H "X-Api-Key: $CLOUDSMITH_API_KEY" -H 'accept: application/json' -X GET "https://api.cloudsmith.io/v1/packages/{account}/{repository}/"  | jq '.[].cdn_url'
```

To retrieve the download URL of the packages in a repository via the CLI:
  ```bash
cloudsmith ls pkgs {account}/{repository} -F json | jq -r '.data[].cdn_url'
```

The `{account}` refers to your Cloudsmith account name and the `{repository}` refers to your Cloudsmith repository.

### Downloading a single package 

You can download using the `wget` command. 

To download a package from a public repository:
  ```bash
wget {cdn_url}
```

To download a package from a private repository:
  ```bash
wget -d --header="X-Api-Key: $CLOUDSMITH_API_KEY" {cdn_url} 
```
or 
```bash
wget  --http-user=$account --http-password=$token {cdn_url}
```

The `{cdn_url}` is the download url returned from the API or CLI command. 

### Downloading packages in bulk

Cloudsmith documentation has provided examples on how to download packages in bulk. Follow their [Bulk Package Download](https://help.cloudsmith.io/docs/download-a-package#bulk-package-download) guide with example scripts for Linux and Windows.
