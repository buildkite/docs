# Export from JFrog Artifactory

To migrate your packages from JFrog Artifactory to Buildkite Package Registries, you'll need to export/download packages from a JFrog Artifactory repository before importing them to your Buildkite registry.

## Download packages via JFrog Artifactory interface

You can download a complete folder of packages or a specific version:

- To download a complete folder of packages from a JFrog Artifactory repository, follow JFrog's [Download a Folder](https://jfrog.com/help/r/jfrog-artifactory-documentation/download-a-folder) guide. You might need to configure folder download from the administrator settings.

- To download specific versions of packages, follow JFrog's [Downloading Package Versions](https://jfrog.com/help/r/jfrog-artifactory-documentation/downloading-package-versions) guidance.

## Download packages via the JFrog CLI

The [JFrog CLI](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli) allows more options on [downloading packages from JFrog Artifactory repositories](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/generic-files#downloading-files).

### Setting up the JFrog CLI

1. First, [download and install the JFrog CLI](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/install). You can install the latest version of the JFrog CLI from JFrog's [Install the Latest Version of JFrog CLI](https://jfrog.com/getcli/) page on their website.

1. Use the `jf c add` command to authenticate your JFrog Artifactory login credentials to access the repository whose package/s need to be downloaded. Learn more about how to do this from the [Authentication page of the JFrog CLI](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/authentication) documentation.

1. Use the `jfrog rt dl` command to [download the required packages](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/generic-files#downloading-files) from your JFrog Artifactory repository.

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
