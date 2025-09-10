# Configuring AI agents with the Buildkite MCP server

Once you followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing) to install the MCP server locally for your AI agent, you can then use the instructions on this page to configure your AI agent to work with this MCP server.

> 📘
> If you are working directly with an AI tool to configure it with the _remote_ MCP server, proceed with the relevant instructions on [Configuring AI tools](/docs/apis/mcp-server/remote/configuring-ai-tools).

## Amp

You can configure your [Amp](https://ampcode.com/) AI agent to work with your local Buildkite MCP server, running [using Docker](#amp-docker) or [as a binary](#amp-binary). To do this, add the relevant configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q", "-i", "--rm", "-e", "BUILDKITE_API_TOKEN",
        "buildkite/mcp-server",
        "stdio"
      ],
      "env": { "BUILDKITE_API_TOKEN": "bkua_xxxxx" }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

## Claude Code

You can configure your [Claude Code](https://www.anthropic.com/claude-code) AI agent to work with your local Buildkite MCP server, running [using Docker](#claude-code-docker) or [as a binary](#claude-code-binary). To do this, run the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, run the following Claude Code command.

```bash
claude mcp add buildkite -- docker run --pull=always -q --rm -i -e BUILDKITE_API_TOKEN=bkua_xxxxx buildkite/mcp-server stdio
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, run the following Claude Code command.

```bash
claude mcp add buildkite --env BUILDKITE_API_TOKEN=bkua_xxxxx -- buildkite-mcp-server stdio
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

## Goose

You can configure your [Goose](https://block.github.io/goose/) AI agent to work with your local Buildkite MCP server, running [using Docker](#goose-docker) or [as a binary](#goose-binary). To do this, add the relevant configuration the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following YAML configuration the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

```yaml
extensions:
  fetch:
    name: Buildkite
    cmd: docker
    args: ["run", "--pull=always", "-q", "-i", "--rm",
           "-e", "BUILDKITE_API_TOKEN",
           "buildkite/mcp-server",
           "stdio"]
    enabled: true
    envs: { "BUILDKITE_API_TOKEN": "bkua_xxxxx" }
    type: stdio
    timeout: 300
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following YAML configuration the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

```yaml
extensions:
  fetch:
    name: Buildkite
    cmd: buildkite-mcp-server
    args: [stdio]
    enabled: true
    envs: |
      {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx"
      }
    type: stdio
    timeout: 300
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

## ToolHive

You can configure [ToolHive](https://toolhive.dev/) to run your local Buildkite MCP server from its registry using ToolHive's command line interface (CLI) tool. To do this, ensure you have installed TooHive's [CLI tool](https://toolhive.dev/download.html) and do the following:

1. Use ToolHive's `thv secret set` command to store your [Buildkite API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token) as a secret.

    ```bash
    cat ~/path/to/your/buildkite-api-token.txt | thv secret set buildkite-api-key
    ```

    where `buildkite-api-token.txt` contains the value of your Buildkite API access token.

1. Run the Buildkite MCP server.

    ```bash
    thv run --secret buildkite-api-key,target=BUILDKITE_API_TOKEN buildkite
    ```

You can also configure ToolHive to run your local Buildkite MCP server from its registry using the ToolHive interface. To do this, ensure you have installed TooHive's [Desktop app](https://toolhive.dev/download.html) and do the following:

1. Access [ToolHive's **Secrets** page](https://docs.stacklok.com/toolhive/guides-ui/secrets-management#manage-secrets).

1. Add a new secret with the following values:
    * **Secret name**: `buildkite-api-key`
    * **Secret value**: Your [Buildkite API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token)'s value.

1. Access [ToolHive's **Registry** page](https://docs.stacklok.com/toolhive/guides-ui/run-mcp-servers).

<!-- vale off -->

1. Search for `buildkite` and then select the filtered **buildkite** registry option.

1. Select **Install server** and on the **Configure buildkite** dialog's **Configuration** tab, specify the following values:
    * **Secrets**: Select `buildkite-api-key`.
    * **Environment variables** (_optional_): Specify the threshold for logging tokens. Omitting this field sets its value to 0, which means that no tokens are logged.

<!-- vale on -->
