# Export from JFrog Artifactory

There is currently no direct process to migrate your packages from JFrog Artifactory to Buildkite Package Registries.

Instead, you'll need to export/download packages from a JFrog Artifactory repository before importing them to your Buildkite registry.

## Downloading packages via JFrog Artifactory interface

You can download a complete folder of packages or a specific version:

- To download a complete folder of packages from a JFrog Artifactory repository, follow JFrog's [Download a Folder](https://jfrog.com/help/r/jfrog-artifactory-documentation/download-a-folder) guide. You might need to configure folder download from the administrator settings.

- To download specific versions of packages, follow JFrog's [Downloading Package Versions](https://jfrog.com/help/r/jfrog-artifactory-documentation/downloading-package-versions) guidance.

## Downloading packages via the JFrog CLI

The [JFrog CLI](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli) allows more options on [downloading packages from JFrog Artifactory repositories](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/generic-files#downloading-files).

### Setting up the jfrog-cli

1. First, [download and install the JFrog CLI](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/install). You can install the latest version of the JFrog CLI from JFrog's [Install the Latest Version of JFrog CLI](https://jfrog.com/getcli/) page on their website.
1. Authenticate your login credentials once using the `jf c add` command. Refer to the cli [guide](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/authentication) on the different means of authentication available.
1. Download the files from Artifactory using the `jfrog rt dl` command.

Here is the usage to the download command:

```bash
jf rt dl [command options] <Source path> [Target path]
jf rt dl --spec=<File Spec path> [command options]
```

Refer to the JFrog application guide for the command to [download](https://docs.jfrog-applications.jfrog.io/jfrog-applications/jfrog-cli/cli-for-jfrog-artifactory/generic-files#usage-1) the files.

Here are examples that can be useful to get started:

To download all packages from a particular repo. The `--flat` option dumps all the packages into the same folder.

```bash
jfrog rt dl {repo-name} --flat
```

To download a particular package type from all repositories into the same folder, specify the package type extension using .deb as an example.

```bash
jfrog rt dl "*/*.deb" --flat
```
