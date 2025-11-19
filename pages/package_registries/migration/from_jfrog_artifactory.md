# Export from JFrog Artifactory

To migrate your packages from JFrog Artifactory to Buildkite Package Registries, you'll need to export/download packages from a JFrog Artifactory repository before importing them to your Buildkite registry.

## Download packages using the JFrog Artifactory interface

You can download a complete folder of packages or a specific package version from a JFrog Artifactory repository through its interface:

- To download a complete folder of packages, follow JFrog's [Download a Folder](https://jfrog.com/help/r/jfrog-artifactory-documentation/download-a-folder) guide. You might need to configure folder download from the administrator settings.

- To download a specific version of a package, follow JFrog's [Downloading Package Versions](https://jfrog.com/help/r/jfrog-artifactory-documentation/downloading-package-versions) guidance.

## Download packages using the JFrog CLI

The [JFrog CLI](https://jfrog.com/help/r/jfrog-applications-and-cli-documentation/jfrog-cli) provides a command line interface (CLI) that allows more options on downloading packages from JFrog Artifactory repositories than what is typically available through the JFrog Artifactory interface. Learn more about this from the **Downloading Files** section of the [Generic Files](https://jfrog.com/help/r/jfrog-applications-and-cli-documentation/generic-files) of the JFrog CLI documentation.

### Setting up the JFrog CLI

1. First, [download and install the JFrog CLI](https://jfrog.com/help/r/jfrog-applications-and-cli-documentation/download-and-install-the-jfrog-cli). You can install the latest version of the JFrog CLI from JFrog's [Install the Latest Version of JFrog CLI](https://jfrog.com/getcli/) page on their website.

1. Use the `jf c add` command to authenticate your JFrog Artifactory login credentials to access the repository whose package/s need to be downloaded. Learn more about how to do this from the [Authentication page of the JFrog CLI](https://jfrog.com/help/r/jfrog-applications-and-cli-documentation/authentication) documentation.

1. Use the `jfrog rt dl` command to download the required packages from your JFrog Artifactory repository. Learn more about this from the **Downloading Files** section of the [Generic Files](https://jfrog.com/help/r/jfrog-applications-and-cli-documentation/generic-files) of the JFrog CLI documentation.

### Example JFrog CLI download commands

The following JFrog CLI download command examples can be used to get you started.

To download all packages from a particular JFrog Artifactory repository, use the `--flat` option download all of these packages into the same folder.

```bash
jfrog rt dl {repo-name} --flat
```

Following on from this, to download a particular package type from all JFrog Artifactory repositories that your API access token provides access to, specify a wildcard package name with a file type extension, such as the following example for `.deb` files.

```bash
jfrog rt dl "*/*.deb" --flat
```

## Next step

Once you have downloaded your packages from your JFrog Artifactory repositories, learn how to [import them into your Buildkite registry](/docs/package-registries/migration/import-to-package-registries).
