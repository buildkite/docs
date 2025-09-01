# Configuring the Buildkite MCP server for AI tools

Once you have established which Buildkite MCP server to use ([remote or local](/docs/apis/mcp-server#types-of-mcp-servers)), you can then use the instructions on this page to configure your AI tool to work with this MCP server.

> 📘
> If you are using a _local_ MCP server, ensure you have followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/installing) locally first, before proceeding with the instructions on this page.

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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

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
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value" 
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

- `job-log-token-threshold-value` is ?

## Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) (as a command line tool) with the Buildkite MCP server, either [remotely](#claude-code-remote-mcp-server) or running locally [using Docker](#claude-code-mcp-server-using-docker) or [as a local binary](#claude-code-mcp-server-as-a-local-binary). To do this, run the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

### Remote MCP server



### MCP server using Docker

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite -- docker run --pull=always -q --rm -i -e BUILDKITE_API_TOKEN=bkua_xxxxx buildkite/mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

### MCP server as a local binary

Run the following Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add buildkite --env BUILDKITE_API_TOKEN=bkua_xxxxx -- buildkite-mcp-server stdio
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

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
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value"
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

- `job-log-token-threshold-value` is ?

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
      ],
      "env": { "BUILDKITE_API_TOKEN": "bkua_xxxxx" }
    }
  }
}
```

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

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
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value"
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

- `job-log-token-threshold-value` (_optional_) is ?

## Goose

You can configure [Goose](https://block.github.io/goose/) with the Buildkite MCP server, either [remotely](#goose-remote-mcp-server) or running locally [using Docker](#goose-mcp-server-using-docker) or [as a local binary](#goose-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

### Remote MCP server


### MCP server using Docker

Add the following YAML configuration to your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

### MCP server as a local binary

Add the following YAML configuration to your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

```yaml
extensions:
  fetch:
    name: Buildkite
    cmd: buildkite-mcp-server
    args: [stdio]
    enabled: true
    envs: |
      {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx",
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value"
      }
    type: stdio
    timeout: 300
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

- `job-log-token-threshold-value` is ?

## Visual Studio Code

You can configure [Visual Studio Code](https://code.visualstudio.com/) with the Buildkite MCP server, either [remotely](#visual-studio-code-remote-mcp-server) or running locally [using Docker](#visual-studio-code-mcp-server-using-docker) or [as a local binary](#visual-studio-code-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

### Remote MCP server

### MCP server using Docker

Add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

```json
{
  "inputs": [
    {
      "id": "BUILDKITE_API_TOKEN",
      "type": "promptString",
      "description": "Enter your Buildkite API access token",
      "password": true
    }
  ],
  "servers": {
    "buildkite": {
      "command": "docker",
      "args": [
        "run", "--pull=always", "-q", "-i", "--rm", "-e", "BUILDKITE_API_TOKEN",
        "buildkite/mcp-server",
        "stdio"
      ],
      "env": { "BUILDKITE_API_TOKEN": "${input:BUILDKITE_API_TOKEN}" }
    }
  }
}
```

### MCP server as a local binary

Add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

```json
{
  "inputs": [
    {
      "id": "BUILDKITE_API_TOKEN",
      "type": "promptString",
      "description": "Enter your Buildkite API access token",
      "password": true
    }
  ],
  "servers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "${input:BUILDKITE_API_TOKEN}",
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value"
      }
    }
  }
}
```

where `job-log-token-threshold-value` (_optional_) is ?

## Windsurf

You can configure [Windsurf](https://code.visualstudio.com/) with the Buildkite MCP server, either [remotely](#windsurf-remote-mcp-server) or running locally [using Docker](#windsurf-mcp-server-using-docker) or [as a local binary](#windsurf-mcp-server-as-a-local-binary). To do this, add the relevant configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

### Remote MCP server

### MCP server using Docker

Add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

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

where `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

### MCP server as a local binary

Add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

```json
{
  "mcpServers": {
    "buildkite": {
      "command": "buildkite-mcp-server",
      "args": ["stdio"],
      "env": {
        "BUILDKITE_API_TOKEN": "bkua_xxxxx",
        "JOB_LOG_TOKEN_THRESHOLD": "job-log-token-threshold-value"
      }
    }
  }
}
```

where:

- `bkua_xxxxx` is the value of your Buildkite API access token, set with [your required scopes](/docs/apis/mcp-server/installing#configure-an-api-access-token).

- `job-log-token-threshold-value` is ?

## ToolHive

You can configure [ToolHive](https://toolhive.dev/) to run the Buildkite MCP server from its registry. To do this:

1. Use ToolHive's `thv secret set` command to store your [Buildkite API access token](/docs/apis/mcp-server/installing#configure-an-api-access-token) as a secret.

    ```bash
    cat ~/path/to/your/buildkite-api-token.txt | thv secret set buildkite-api-key
    ```
1. Run the Buildkite MCP server.

    ```bash
    thv run --secret buildkite-api-key,target=BUILDKITE_API_TOKEN buildkite
    ```
