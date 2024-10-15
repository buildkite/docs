# Import exported packages to Package Registries

After exporting your packages from your old repository, you are now ready to import them to your Buildkite Package Registry!

## Importing via CLI

Ensure that you have installed the [bk cli](https://github.com/buildkite/cli?tab=readme-ov-file#bk---the-buildkite-cli) tool and configured your organization name and token (using the `bk configure` command).

To push a package to your registry, simply run the command `bk package push`. Ensure that the packages to be imported belong to the supported package ecosystems that are listed [here](/docs/packages#get-started). Refer to the bk cli [usage](https://github.com/buildkite/cli?tab=readme-ov-file#usage) for the command options or run `bk package push --help`.

### Example to import a single package

```bash
bk package push my-registry my-package.tar.gz
```

### Example to bulk import files from a folder

The following script will import all files to a specified registry and file type found in the folder where the script is executed. This script will expect a registry name and a file type when executed.

```bash
#!/bin/bash

for FILE in $(ls *.$2); do
  bk package push $1 $FILE
done
```

## Importing via the Rest API

To import a package via Rest API, use the endpoint to publish a package as specified in our API docs [here](/docs/apis/rest-api/package-registries/packages#publish-a-package). Examples of the usage of these APIs can also be found on the different package ecosystems like [publishing an alpine package](/docs/package-registries/alpine#publish-a-package).
