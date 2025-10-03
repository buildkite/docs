# Configuring AI tools with the local MCP server

Once you followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing) to install the MCP server locally for your AI tool or agent, you can then use the instructions on this page to configure your AI tool or agent to work with this [_local_ Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers-local-mcp-server).

All the Docker instructions on this page implement the `--pull=always` option to ensure that the latest MCP server version is obtained when the container is started. If you are installing the Buildkite MCP server locally as a binary, then you are responsible for manually upgrading it.

> 📘
> The Buildkite MCP server is available both [locally and remotely](/docs/apis/mcp-server#types-of-mcp-servers). This page is about configuring AI tools with the local MCP server. If you are working directly with an AI tool and would prefer it to use the _remote_ MCP server, proceed with the relevant instructions on its [Configuring AI tools](/docs/apis/mcp-server/remote/configuring-ai-tools) page.

## Amp

You can configure your [Amp](https://ampcode.com/) AI tool or agent to work with your local Buildkite MCP server, running [in Docker](#amp-docker) or [as a binary](#amp-binary). To do this, add the relevant configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration).

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

You can configure your [Claude Code](https://www.anthropic.com/claude-code) AI tool or agent to work with your local Buildkite MCP server, running [in Docker](#claude-code-docker) or [as a binary](#claude-code-binary). To do this, run the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

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

## Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) to work with your local Buildkite MCP server, running [in Docker](#claude-desktop-docker) or [as a binary](#claude-desktop-binary). To do this, add the relevant configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following configuration to your [Claude Desktop's `claude_desktop_config.json` file](https://modelcontextprotocol.io/quickstart/server#testing-your-server-with-claude-for-desktop), which you can access from Claude Desktop's **Settings** > **Developer** > **Edit Config** button on the **Local MCP servers** page.

```json
{
  "mcpServers": {
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

## Cursor

You can configure [Cursor](https://cursor.com/) to work with your local Buildkite MCP server, running [in Docker](#cursor-docker) or [as a binary](#cursor-binary). To do this, add the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcpjson), which is usually located in your home directory's `.cursor` sub-directory.

To access the `mcp.json` file through the Cursor app to implement this configuration:

1. From your **Cursor Settings**, select **MCP & Integrations**.
1. Under **MCP Tools**, select **Add Custom MCP** to open the `mcp.json` file.
1. Implement one of the following required updates to this file, where if you have other MCP servers configured in Cursor, just add the `"buildkite": { ... }` object to this JSON file.

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcpjson).

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Cursor `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcpjson).

```json
{
  "mcpServers": {
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

## Goose

You can configure your [Goose](https://block.github.io/goose/) AI tool or agent to work with your local Buildkite MCP server, running [in Docker](#goose-docker) or [as a binary](#goose-binary). To do this, add the relevant configuration the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

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

## Visual Studio Code

You can configure [Visual Studio Code](https://code.visualstudio.com/) to work with your local Buildkite MCP server, running [in Docker](#visual-studio-code-docker) or [as a binary](#visual-studio-code-binary). To do this, add the relevant configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

Alternatively, you can initiate this process through the Visual Studio Code interface. To do this:

1. In the [Command Palette](https://code.visualstudio.com/docs/getstarted/getting-started#_access-commands-with-the-command-palette), find and select the **MCP: Add Server** command.
1. Select **Docker image** to start configuring your local MCP server running in Docker.
1. For **Enter Docker Image Name**, specify `buildkite/mcp-server`, and **Allow** it to be installed.
1. For **Enter your Buildkite API Access Token**, enter your configured Buildkite API access token.
1. For **Enter Server ID**, specify `buildkite`.

    Follow the remaining prompts to complete this configuration process.

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

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
        "BUILDKITE_API_TOKEN": "${input:BUILDKITE_API_TOKEN}"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

## Windsurf

You can configure [Windsurf](https://windsurf.com/) to work with your local Buildkite MCP server, running [in Docker](#windsurf-docker) or [as a binary](#windsurf-binary). To do this, add the relevant configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

### Docker

When using [Docker](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

### Binary

When using a [pre-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

```json
{
  "mcpServers": {
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

## Zed

You can configure the [Zed](https://zed.dev/) code editor with the Buildkite MCP server as a locally running binary using the Zed Buildkite MCP extension.

To add the Buildkite MCP server extension to Zed:

1. Visit Zed's [Buildkite MCP server extension](https://zed.dev/extensions/mcp-server-buildkite) page.
1. Select the **Install MCP Server in Zed** button on this web page to open the **Extensions** window in Zed.
1. In the **Extensions** window, ensure the **Buildkite MCP** extension is shown and select its **Install** button.
1. In the **Configure mcp-server-buildkite** dialog, copy your [configured Buildkite API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token) and paste this over the `BUILDKITE_API_TOKEN` value.
1. Select **Configure Server** to save the changes.

    Your configuration should be saved to the [Zed's main `settings.json` file](http://zed.dev/docs/configuring-zed#settings-files), which is usually located within your home directory's `.config/zed/` folder.

Alternatively, you can copy and paste the following configuration as a new entry to [Zed's main `settings.json` file](http://zed.dev/docs/configuring-zed#settings-files), bearing in mind that if you had previously configured an MCP server in Zed, add just the `"mcp-server-buildkite"` object within the existing `"context_servers"` object of this file.

```json
{
  "context_servers": {
    "mcp-server-buildkite": {
      "settings": {
        "buildkite_api_token": "bkua_xxxxx"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_api_access_token' %>

## ToolHive

[ToolHive](https://toolhive.dev/) is a tool that allows you to abstract the API access token handling processes for your local Buildkite MCP server, away from your other AI tool infrastructure and the Buildkite platform.

You can configure ToolHive to run your local Buildkite MCP server from its registry using ToolHive's command line interface (CLI) tool. To do this, ensure you have installed TooHive's [CLI tool](https://toolhive.dev/download) and do the following:

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
