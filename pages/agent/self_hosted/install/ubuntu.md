# Installing Buildkite Agent on Ubuntu

The Buildkite Agent is supported on Ubuntu versions 18.04 and above using our signed apt repository.

## Installation

First, add our signed apt repository. Buildkite Agent versions come in three release channels:

- **Stable**: Thoroughly tested, production-ready releases recommended for most users.
- **Unstable/Beta**: Newer features that are still being tested, may contain bugs that affect stability.
- **Experimental**: Built directly from the `main` branch, may be incomplete or have unresolved issues.

The default version of the agent is `stable`. You can get the beta version by using `unstable` instead of `stable` or the experimental version by using `experimental` instead of `stable` in the installation commands that follow.

Start by downloading the Buildkite PGP key to a directory that is only writable by `root` (create the directory before running the following command if it doesn't already exist):

```shell
curl -fsSL https://keys.openpgp.org/vks/v1/by-fingerprint/32A37959C2FA5C3C99EFBC32A79206696452D198 | sudo gpg --dearmor -o /usr/share/keyrings/buildkite-agent-archive-keyring.gpg
```

> 📘 Is [keys.openpgp.org](https://keys.openpgp.org) down?
> If you get a 404 or other error from `curl` in the previous command, see the [Alternative keyservers](#alternative-keyservers) section.

Then add the signed source to your list of apt sources:

```shell
echo "deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main" | sudo tee /etc/apt/sources.list.d/buildkite-agent.list
```

And install the Buildkite agent:

```shell
sudo apt-get update && sudo apt-get install -y buildkite-agent
```

Configure your [agent token](/docs/agent/self-hosted/tokens):

```shell
sudo sed -i "s/xxx/INSERT-YOUR-AGENT-TOKEN-HERE/g" /etc/buildkite-agent/buildkite-agent.cfg
```

And then start the agent:

```shell
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent
```

You can view the logs at:

```shell
sudo journalctl -f -u buildkite-agent
```

## Updating keys installed using apt-key

If you've previously installed keys using `apt-key`, move the Buildkite agent key from `/etc/apt/trusted.gpg` or `/etc/apt/trusted.gpg.d/` to `/usr/share/keyrings/buildkite-agent-archive-keyring.gpg`, making sure that both that file and directory are only writable by `root`.

Update your Buildkite agent entries in `/etc/apt/sources.list.d/buildkite-agent.list` to:

```shell
deb [signed-by=/usr/share/keyrings/buildkite-agent-archive-keyring.gpg] https://apt.buildkite.com/buildkite-agent stable main
```

## SSH key configuration

<%= render_markdown partial: 'agent/self_hosted/install/ssh_key_with_buildkite_agent_user' %>

See the [Buildkite agent code access](/docs/agent/self-hosted/code-access) documentation for more details.

## File locations

<%= render_markdown partial: 'agent/self_hosted/install/apt_locations' %>

## Configuration

<%= render_markdown partial: 'agent/self_hosted/install/apt_configuration' %>

## Default operating system user running the agent

On Ubuntu, the Buildkite agent runs as the `buildkite-agent` operating system user account.

You can override this default user through a [systemd modification](#systemd-modifications).

## Running multiple agents

<%= render_markdown partial: 'agent/self_hosted/install/linux_multiple_agents' %>

## Upgrading

<%= render_markdown partial: 'agent/self_hosted/install/apt_upgrading' %>

## Alternative keyservers

<%= render_markdown partial: 'agent/self_hosted/install/alternative_keyservers' %>

## Systemd modifications

<%= render_markdown partial: 'agent/self_hosted/install/linux_systemd_modifications' %>
