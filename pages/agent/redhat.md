# Installing Buildkite Agent on Red Hat and CentOS

The Buildkite Agent can be installed on Redhat and CentOS using our yum repository.

<%= toc %>

## Installation

<%= render_agent_setup :yum %>

## SSH Key Configuration

<%= render_markdown 'agent/ssh_key_with_buildkite_agent_user' %>

See the [Agent SSH Keys](/docs/agent/ssh-keys) documentation for more details.

## File Locations

* Configuration: `/etc/buildkite-agent/buildkite-agent.cfg`
* Hooks: `/etc/buildkite-agent/hooks/`
* Builds: `/var/buildkite-agent/builds/`
* Log: `/var/log/messages`
* Agent user home: `/var/lib/buildkite-agent/`
* SSH keys: `/var/lib/buildkite-agent/.ssh/`

## Configuration

The configuration file is located at `/etc/buildkite-agent/buildkite-agent.cfg`. See the [configuration documentation](/docs/agent/configuration) for an explanation of each configuration setting.

## Running multiple agents

You can run as many parallel agents on the one machine as you wish by simply copying the init.d and starting it:

```shell
sudo cp /usr/lib/systemd/system/buildkite-agent.service /usr/lib/systemd/system/buildkite-agent-2.service
sudo systemctl enable buildkite-agent-2 && systemctl start buildkite-agent-2
```

## Upgrading

```shell
sudo yum clean expire-cache && yum update buildkite-agent
```
