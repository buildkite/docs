# Securing your Buildkite Agent

In cases where a Buildkite Agent is being deployed into a sensitive environment there are a few default settings and techniques which may be adjusted.

<%= toc %>

## Disabling Auto SSH Fingerprint Verification

By default the agent will auto-verify the SSH host using `ssh-keyscan` when doing the first checkout on a new agent host. Once you disable this functionality you'll need to manually perform your first checkout, or ensure the SSH fingerprint of your source code host is already present on your build machine.

Automatic SSH fingerprint verification can be disable with one of the following by setting `no-automatic-ssh-fingerprint-verification` the following ways:

* Environment variable: `BUILDKITE_NO_AUTOMATIC_SSH_FINGERPRINT_VERIFICATION=1`
* Command line flag: `--no-automatic-ssh-fingerprint-verification`
* Configuration setting: `no-automatic-ssh-fingerprint-verification=true`

## Disabling Command Eval

By default the agent allows you to run any command on the build server (e.g. `make test`). You can disable command evaluation and allow only the execution of scripts (with no ability to pass command line flags). Once disabled your build steps will need to be checked into your repository as scripts, and the only way to pass arguments is via environment variables.

To disable command line evaluation use one of the following settings:

* Environment variable: `BUILDKITE_NO_COMMAND_EVAL=1`
* Command line flag: `--no-command-eval`
* Configuration setting: `no-command-eval=true`

## Creating a Command Whitelist

You can limit the commands an agent can run on your server by creating a [pre-command hook](hooks) that checks against of allowed commands to run. The following is an example of a pre-command hook that allows only the `script/deploy` command:

```
#!/bin/bash

set -eu

if [[ "$BUILDKITE_COMMAND" == "script/deploy" ]]; then
  echo "$BUILDKITE_COMMAND not allowed"
  exit 1
fi
```

## Using Environment Hooks for Secrets

The agent’s [global enviroment hook](hooks) is a convenient place for making secrets available to the build scripts. Once the environment hook exports the secret as an environment variable it will then be available to the build script. For example:

```bash
#!/bin/bash

set -eu

echo '--- \:house_with_garden\: Setting up the environment'

export GITHUB_RELEASE_ACCESS_KEY='xxx'
```

If you want to control which build steps have which secrets exposed you can check the value of `$BUILDKITE_COMMAND` before exporting it, for example:

```bash
#!/bin/bash

set -eu

echo '--- \:house_with_garden\: Setting up the environment'

if [[ "$BUILDKITE_COMMAND" == "script/release" ]]; then
  export RELEASE_KEY=`vault get release-key`
fi
```
