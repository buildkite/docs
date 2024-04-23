# Installing Buildkite Agent on Red Hat Enterprise Linux, CentOS, and Amazon Linux

The Buildkite Agent is supported on Red Hat Enterprise Linux 7 and newer, CentOS 7 and newer, and Amazon Linux 2 and newer using our yum repository.


## Installation

Firstly, add our yum repository for your architecture (run `uname -m` to find your system's arch). The default version of the agent is `stable`, but you can get the beta version by using `unstable` instead of `stable` in the following command, or the agent built from the `main` branch of the repository by using `experimental` instead of `stable`.

For 64-bit (x86_64):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/x86_64/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

For 32-bit (i386):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/i386/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

For ARM 64-bit (aarch64)):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/aarch64/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

Then install the agent:

```shell
sudo yum -y install buildkite-agent
```

Configure your [agent token](/docs/agent/v3/tokens):

```shell
sudo sed -i "s/xxx/INSERT-YOUR-AGENT-TOKEN-HERE/g" /etc/buildkite-agent/buildkite-agent.cfg
```

And then start the agent, and tail the logs:

```shell
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent
sudo tail -f /var/log/messages
```

## SSH key configuration

<%= render_markdown partial: 'agent/v3/ssh_key_with_buildkite_agent_user' %>

See the [Agent SSH keys](/docs/agent/v3/ssh-keys) documentation for more details.

## File locations

* Configuration: `/etc/buildkite-agent/buildkite-agent.cfg`
* Agent Hooks: `/etc/buildkite-agent/hooks/`
* Builds: `/var/buildkite-agent/builds/`
* Logs, depending on your system:
  - `journalctl -f -u buildkite-agent` (systemd)
  - `/var/log/buildkite-agent.log` (older systems)
* Agent user home: `/var/lib/buildkite-agent/`
* SSH keys: `/var/lib/buildkite-agent/.ssh/`

## Configuration

The configuration file is located at `/etc/buildkite-agent/buildkite-agent.cfg`. See the [configuration documentation](/docs/agent/v3/configuration) for an explanation of each configuration setting.

## Which user the agent runs as

On RedHat, the Buildkite agent runs as user `buildkite-agent`.

## Running multiple agents

<%= render_markdown partial: 'agent/v3/linux_multiple_agents' %>

## Upgrading

```shell
sudo yum clean expire-cache && sudo yum update buildkite-agent
```
