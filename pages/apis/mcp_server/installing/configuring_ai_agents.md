# Configuring AI agents with the Buildkite MCP server

Once you followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/installing) to install the MCP server locally for your AI agent, you can then use the instructions on this page to configure your AI agent to work with this MCP server.

> 📘
> If you are working directly with an AI tool to configure it with the _remote_ MCP server, proceed with the relevant instructions on [Configuring AI tools](/docs/apis/mcp-server/configuring-ai-tools).

## Amp

You can configure your [Amp](https://ampcode.com/) AI agent to work with your local Buildkite MCP server, running [using Docker](#amp-docker) or [as a binary](#amp-binary). To do this, add the relevant configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

### Docker

When using [Docker](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

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

When using a [pre-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

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

When using [Docker](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, run the following Claude Code command.

```bash
claude mcp add buildkite -- docker run --pull=always -q --rm -i -e BUILDKITE_API_TOKEN=bkua_xxxxx buildkite/mcp-server stdio
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, run the following Claude Code command.

```bash
claude mcp add buildkite --env BUILDKITE_API_TOKEN=bkua_xxxxx -- buildkite-mcp-server stdio
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>
