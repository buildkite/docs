# Installing Buildkite Agent on Red Hat Enterprise Linux, CentOS, and Amazon Linux

The Buildkite Agent is supported on the following operating systems, using the yum repository:

- Red Hat Enterprise Linux
  + Red Hat Enterprise Linux 7 (RHEL7)
  + Red Hat Enterprise Linux 8 (RHEL8)
  + Red Hat Enterprise Linux 9 (RHEL9)
  + Red Hat Enterprise Linux 10 (RHEL10)
- CentOS
  + CentOS 7
  + CentOS 8
- Amazon Linux
  + Amazon Linux 2 (AL2)
  + Amazon Linux 2023 (AL2023)

## Installation

Start by adding the yum repository for your architecture (if unsure, run `uname -m` to find your system's architecture).

<!-- TODO: Verify if this is still valid for yum repository packages for the agent -->

Buildkite Agent versions come in three release channels:

- **Stable**: Thoroughly tested, production-ready releases recommended for most users.
- **Unstable/Beta**: Newer features that are still being tested, may contain bugs that affect stability.
- **Experimental**: Built directly from the `main` branch, may be incomplete or have unresolved issues.

The default version of the agent is `stable`. You can get the beta version by using `unstable` instead of `stable` or the experimental version by using `experimental` instead of `stable` in the installation commands that follow.

> 📘
> The `repo_gpgcheck=0` parameter is required when additional OS hardening has been enabled to verify the GPG signature of the repository's metadata. Without this extra parameter for disabling metadata signature checking, the package installation will not succeed.

For 64-bit (x86_64):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/x86_64/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

For 32-bit (i386):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/i386/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

For ARM 64-bit (aarch64):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/aarch64/\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

Then install the agent:

```shell
sudo yum -y install buildkite-agent
```

Configure your [agent token](/docs/agent/self-hosted/tokens):

```shell
sudo sed -i "s/xxx/INSERT-YOUR-AGENT-TOKEN-HERE/g" /etc/buildkite-agent/buildkite-agent.cfg
```

After the installation, you can start the agent and tail the logs by using the following command:

```shell
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent
sudo tail -f /var/log/messages
```

## SSH key configuration

<%= render_markdown partial: 'agent/self_hosted/install/ssh_key_with_buildkite_agent_user' %>

See the [Agent SSH keys](/docs/agent/self-hosted/ssh-keys) documentation for more details.

## File locations

- Configuration: `/etc/buildkite-agent/buildkite-agent.cfg`
- Agent Hooks: `/etc/buildkite-agent/hooks/`
- Builds: `/var/buildkite-agent/builds/`
- Logs, depending on your system:
  + `journalctl -f -u buildkite-agent` (systemd)
  + `/var/log/buildkite-agent.log` (older systems)
- Agent user home: `/var/lib/buildkite-agent/`
- SSH keys: `/var/lib/buildkite-agent/.ssh/`

## Configuration

The configuration file is located at `/etc/buildkite-agent/buildkite-agent.cfg`. See the [configuration documentation](/docs/agent/self-hosted/configure) for an explanation of each configuration setting.

## Which user the agent runs as

On Red Hat, the Buildkite Agent runs as user `buildkite-agent`.

## Running multiple agents

<%= render_markdown partial: 'agent/self_hosted/install/linux_multiple_agents' %>

## Upgrading

```shell
sudo yum clean expire-cache && sudo yum update buildkite-agent
```

## Systemd modifications

<%= render_markdown partial: 'agent/self_hosted/install/linux_systemd_modifications' %>
