# Configuring the Buildkite MCP server for AI tools

Once you have chosen which Buildkite MCP server (remote or local) to use, you can then use the instructions on this page to configure your AI tool to work with this MCP server.

For instructions on how to set up and install a _local_ Buildkite MCP server, see [Installing the Buildkite MCP server locally](/docs/apis/mcp-server/installing-locally).

## Amp

You can configure [Amp](https://ampcode.com/) with the Buildkite MCP server, either [remotely](#amp-remote-mcp-server) or running locally [using Docker](#amp-mcp-server-using-docker) or [as a local binary](#amp-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

### Remote MCP server

### MCP server using Docker

Add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

### MCP server as a local binary

Add the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": { 
        "BUILDKITE_API_TOKEN": "bkua_xxxxx", 
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value" 
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

- `job-log-token-threashold-value` is ?

## Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) (as a command line tool) with the Buildkite MCP server, either [remotely](#claude-code-remote-mcp-server) or running locally [using Docker](#claude-code-mcp-server-using-docker) or [as a local binary](#claude-code-mcp-server-as-a-local-binary). To do this, run the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

### Remote MCP server



### MCP server using Docker

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite -- docker run --pull=always -q --rm -i -e BUILDKITE_API_TOKEN=bkua_xxxxx buildkite/mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

### MCP server as a local binary

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite --env BUILDKITE_API_TOKEN=bkua_xxxxx -- buildkite-mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

## Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) with the Buildkite MCP server, either [remotely](#claude-desktop-remote-mcp-server) or running locally [using Docker](#claude-desktop-mcp-server-using-docker) or [as a local binary](#claude-desktop-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop).

### Remote MCP server

### MCP server using Docker

Add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

```json
{
  "mcpServers": {
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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

### MCP server as a local binary

Add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx",
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value"
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

- `job-log-token-threashold-value` is ?

## Cursor

You can configure [Cursor](https://cursor.com/) with the Buildkite MCP server, either [remotely](#cursor-remote-mcp-server) or running locally [using Docker](#cursor-mcp-server-using-docker) or [as a local binary](#cursor-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

### Remote MCP server

### MCP server using Docker

Add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q", "-i", "--rm", "-e", "BUILDKITE_API_TOKEN",
        "buildkite/mcp-server",
        "stdio"
      ]
    }
  }
}
```

### MCP server as a local binary

Add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxxxxx",
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threashold-value"
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes).

- `job-log-token-threashold-value` (_optional_) is ?

## Goose

You can configure [Goose](https://block.github.io/goose/) with the Buildkite MCP server, either [remotely](#goose-remote-mcp-server) or running locally [using Docker](#goose-mcp-server-using-docker) or [as a local binary](#goose-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json).

### Remote MCP server


### MCP server using Docker



### MCP server as a local binary


