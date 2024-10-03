---
toc: false
---

# Export from JFROG Artifactory

To migrate from JFrog Artifactory, you have to download all your packages from Artifactory locally before importing them to Buildkite Packages. There is currently no direct process to export an Artifactory repository directly to Buildkite Packages.

## Downloading packages via Artifactory UI

You can download packages via a specific version or a complete folder of packages.
   * To download packages from a specific package version, follow the Artifactory documentation on [Downloading Package Versions](https://jfrog.com/help/r/jfrog-artifactory-documentation/downloading-package-versions)
   * To download a complete folder of packages from an Artifactory repository, follow their documentation on [Downloading Packages by Folder](https://jfrog.com/help/r/jfrog-artifactory-documentation/download-a-folder). You might need to configure folder download from the administrator settings.

## Downloading packages via the CLI

The JFrog CLI allows more options on downloading packages.

### Setup the jfrog-cli

1. Start with installing the cli. You can choose multiple platforms and pick your [download preference](https://jfrog.com/getcli/). 
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