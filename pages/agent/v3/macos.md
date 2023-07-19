# Installing Buildkite Agent on macOS

The Buildkite Agent is supported on macOS 10.12 or newer using Homebrew or our installer script, and supports pre-release versions of both macOS and Xcode.


## Installation

We recommend installing the agent using [Homebrew](http://brew.sh/) so you can use the [Buildkite formula repository](https://github.com/buildkite/homebrew-buildkite). If you don't use Homebrew you should follow the [Linux](/docs/agent/v3/linux) install instructions.

To install the agent using Homebrew:

1. On the command line, install the agent by running:

    ```shell
    brew tap buildkite/buildkite && brew install buildkite/buildkite/buildkite-agent
    ```

1. Add your [agent token](/docs/agent/v3/tokens) to authenticate the agent by replacing `INSERT-YOUR-AGENT-TOKEN-HERE` with your agent token and running:

    ```shell
    sed -i '' "s/xxx/INSERT-YOUR-AGENT-TOKEN-HERE/g" "$(brew --prefix)"/etc/buildkite-agent/buildkite-agent.cfg
    ```

1. Start the agent by running:

    ```shell
    buildkite-agent start
    ```

## SSH key configuration

SSH keys should be copied to (or generated into) the `.ssh` directory in the users' home directory (for example, `/Users/alice/.ssh`). For example, to generate a new private key which you can add to your source code host:

```bash
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t rsa -b 4096 -C "build@myorg.com"
```

See the [Agent SSH keys](/docs/agent/v3/ssh-keys) documentation for more details.

## File locations

File locations depend on your installation method and Mac hardware.

### Homebrew installation

To see the paths to the agent's configuration, hooks, builds, and logs on your system, run `brew info buildkite-agent`.

The typical paths for [Mac computers with Apple silicon](https://support.apple.com/en-gb/HT211814) (such as M1 chips) are:

* Configuration: `/opt/homebrew/etc/buildkite-agent/buildkite-agent.cfg`
* Agent Hooks: `/opt/homebrew/etc/buildkite-agent/hooks`
* Builds: `/opt/homebrew/buildkite-agent/builds`
* Log: `/opt/homebrew/var/log/buildkite-agent.log`

The typical paths for Mac computers with Intel processors are:

* Configuration: `/usr/local/etc/buildkite-agent/buildkite-agent.cfg`
* Agent Hooks: `/usr/local/etc/buildkite-agent/hooks`
* Builds: `/usr/local/var/buildkite-agent/builds`
* Log: `/usr/local/var/log/buildkite-agent.log`

### Linux installer script on macOS

* Configuration: `~/.buildkite-agent/buildkite-agent.cfg`
* Agent Hooks: `~/.buildkite-agent/hooks`
* Builds: `~/.buildkite-agent/builds`

## Configuration

See the [configuration documentation](/docs/agent/v3/configuration) for an explanation of each configuration setting.

## Which user the agent runs as

On macOS, the Buildkite agent runs as the user who started the `launchd` service.

## Starting on login

If you installed the agent using Homebrew you can run the following command to get instructions on how to install the correct plist and have buildkite-agent start on login:

```bash
brew info buildkite-agent
```

If you installed the buildkite-agent using the [Linux install script](linux) then you'll need to install the plist yourself using the following commands:

```bash
# Download the launchd config to ~/Library/LaunchAgents/
curl -o ~/Library/LaunchAgents/com.buildkite.buildkite-agent.plist https://raw.githubusercontent.com/buildkite/agent/main/templates/launchd_local_with_gui.plist

# Set buildkite-agent to be run as the current user (a full user, created using System Prefs)
sed -i '' "s/your-build-user/$(whoami)/g" ~/Library/LaunchAgents/com.buildkite.buildkite-agent.plist

# Create the agent's log directory with the correct permissions
mkdir -p ~/.buildkite-agent/log && sudo chmod 775 ~/.buildkite-agent/log

# Start the agent
launchctl load ~/Library/LaunchAgents/com.buildkite.buildkite-agent.plist

# Check the logs
tail -f ~/.buildkite-agent/log/buildkite-agent.log
```

> 🚧 Troubleshooting: <code>launchctl</code> fails with "Could not find domain for"
> Ensure that you have a user logged in to the macOS host, then re-run:<br><code>launchctl load ~/Library/LaunchAgents/com.buildkite.buildkite-agent.plist</code>

## Running multiple agents

Launching and managing multiple agents can be done using `launchd`.

If you need the same configuration on each agent, either configure the `launchd` service to use the [`--spawn` flag](/docs/agent/v3/cli-start#starting-an-agent-options) on the `buildkite-agent`, or the [`spawn` setting](/docs/agent/v3/configuration#spawn) in the `buildkite-agent.cfg` file.

Using the existing agent `plist`, add the spawn flag to the `ProgramArguments` and change the number to how many agents you want to run.

The below example will start five agents each time the service is started:

```xml
<key>ProgramArguments</key>
<array>
  <string>/Users/your-build-user/.buildkite-agent/bin/buildkite-agent</string>
  <string>start</string>
  <string>--spawn=5</string>
</array>
```

If your agents each need different configuration, you can create multiple `launchd` services:

1. Find your agent's `plist`. If you installed the agent with Homebrew you can find the `plist` in your user's `~/Library/LaunchAgents` directory. If you installed with the Linux script, you can take a copy of the [template plist](https://raw.githubusercontent.com/buildkite/agent/main/templates/launchd_local_with_gui.plist) from the Agent's GitHub repository.

2. Make as many copies of the plist as you require, one per configuration, ensuring that each has a unique label.

3. Once you've edited your plist/s with your custom config, make sure that all the referenced paths exist and have the correct permissions. See the [Starting on Login](#starting-on-login) section above for an example of how to check directories and permissions.

4. Load each `plist` into `launchd` using `launchctl`.

## Upgrading

If you installed the agent using Homebrew you can use the standard brew upgrade command to update the agent:

```shell
brew update && brew upgrade buildkite-agent
```

If you installed the buildkite-agent using the [Linux install script](linux) then you should run the installer script again and it will update your agent.
