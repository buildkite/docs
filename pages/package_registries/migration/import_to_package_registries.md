# Import exported packages to Package Registries

After exporting and downloading your packages, images, and other files from your existing registry or repository provider, you can then import them to your Buildkite registry!

## Use via the Buildkite CLI

The easiest method for importing packages, images, and other files from your existing registry or repository provider is to use the [Buildkite CLI](/docs/cli) tool.

Ensure that:

- You have [installed the Buildkite CLI tool](/docs/cli/installation), and have configured your organization name and token (using the `bk configure` command).

- You have set up a registry whose [supported package ecosystem](/docs/package-registries/ecosystems) matches the package, images, or other files. You downloaded from your existing registry or repository provider.

To push a package to your registry using the Buildkite CLI, run the command `bk package push`. Learn more about how to [use this command](/docs/cli#usage) by running the command option `bk package push --help`.

### Example of importing a single package

The following command is an example of using the Buildkite CLI to import a single Debian package to a Buildkite (Debian) registry named `my-registry`.

```bash
bk package push my-registry my-package.deb
```

### Example of bulk-importing files from a folder

Once made executable, the following shell script imports all files of a specified type found in a specified local folder path to a specified registry.

```bash
#!/bin/bash

for FILE in $(ls $2/*.$3); do
  bk package push $1 $FILE
done
```
{: codeblock-file="bulk-import.sh"}

The following example demonstrates running this script from its current location, to bulk import Debian packages from the local folder `/path/to/my/downloaded/deb/files` to the Buildkite (Debian) registry named `my-registry`.

```bash
./bulk-import.sh my-registry /path/to/my/downloaded/deb/files deb
```

## Importing via the REST API and other methods

To import a package via REST API, use the [publish a package](/docs/apis/rest-api/package-registries/packages#publish-a-package) endpoint.

You can also find other methods for publishing packages to Buildkite registries on the specific package ecosystem pages linked from [Package ecosystems overview](/docs/package-registries/ecosystems).
