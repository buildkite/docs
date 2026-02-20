# Installing Buildkite Agent on Linux

You can install Buildkite Agent on most Linux based systems (including macOS).


## Installation

Run the following script (<a href="https://raw.githubusercontent.com/buildkite/agent/main/install.sh">view the source</a>), which will download and install the correct binary for your system and architecture (you will need your [agent token](/docs/agent/self-hosted/tokens)):

```shell
TOKEN="INSERT-YOUR-AGENT-TOKEN-HERE" bash -c "`curl -sL https://raw.githubusercontent.com/buildkite/agent/main/install.sh`"
```

Then, start the agent:

```shell
~/.buildkite-agent/bin/buildkite-agent start
```

Alternatively you can follow the [manual installation instructions](/docs/agent/self-hosted/install#manual-installation).

## SSH key configuration

SSH keys should be copied to (or generated into) `~/.ssh/` for the user the agent is running as. For example, to generate a new private key which you can add to your source code host:

```bash
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t rsa -b 4096 -C "build@myorg.com"
```

See the [Buildkite agent code access](/docs/agent/self-hosted/code-access) documentation for more details.

## File locations

* Configuration: `~/.buildkite-agent/buildkite-agent.cfg`
* Agent Hooks: `~/.buildkite-agent/hooks`
* Builds: `~/.buildkite-agent/builds`
* SSH keys: `~/.ssh`
* Logs, depending on your system:
  - `journalctl -f -u buildkite-agent` (when started with `systemd`)
  - logs only go to stdout and do not persist (when started with `buildkite-agent start`)

## Configuration

The configuration file is located at `~/.buildkite-agent/buildkite-agent.cfg`. See the [configuration documentation](/docs/agent/self-hosted/configure) for an explanation of each configuration setting.

## Which user the agent runs as

When running an agent installed using the manual Linux installation method, all commands run as the invoking user.

## Upgrading

Rerun the install script.
