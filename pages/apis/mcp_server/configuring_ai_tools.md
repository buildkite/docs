# Configuring AI tools with the Buildkite MCP server

If you are working directly with AI tools to interact with Buildkite's MCP server, then use the relevant instructions on this page to configure your AI tool to work with the [_remote_ Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers).

> 📘
> If you are using an AI agent to work with the _local_ MCP server, ensure you have followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/installing) locally first, before proceeding with the relevant instructions on [Configuring AI agents](/docs/apis/mcp-server/installing/configuring-ai-agents).

## Amp

You can configure [Amp](https://ampcode.com/) with the remote Buildkite MCP server, by adding the following JSON configuration to your [Amp `settings.json` file](https://ampcode.com/manual#configuration), which requires the `mcp-remote` command argument to allow OAuth authorization. Learn more about this type of configuration in the [Custom Tools (MCP)](https://ampcode.com/manual#mcp) section of the Amp docs.

```json
{
  "amp.mcpServers": {
    "buildkite": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.buildkite.com/mcp"
      ]
    }
  }
}
```

The first time you start using the remote MCP server on Amp, the **Authorize Application** for the **Buildkite MCP Server** page opens. On this page, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use the Buildkite's remote MCP server through Amp for this Buildkite organization.

## Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) with the remote Buildkite MCP server by running the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add --transport http buildkite https://mcp.buildkite.com/mcp
```

## Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) with the remote Buildkite MCP server, by doing the following to configure this server in Claude Desktop.

1. Select **Settings** > **Connectors**.
1. Scroll down the page of connectors and locate the **Buildkite** option (indicating the URL `https://mcp.buildkite.com/mcp`).
1. Select its **Connect** button.
1. On the **Authorize Application** for the **Buildkite MCP Server** page, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use the Buildkite's remote MCP server through Claude Desktop for this Buildkite organization.

## Cursor

You can configure [Cursor](https://cursor.com/) with the remote Buildkite MCP server by adding the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json), which is usually located in your home directory's `.cursor` sub-directory.

You can conveniently add this configuration using the following button.

<a class="inline-block" href="https://cursor.com/en/install-mcp?name=buildkite&config=eyJ1cmwiOiJodHRwczovL21jcC5idWlsZGtpdGUuY29tL21jcCJ9" target="_blank" rel="nofollow"><img src="https://cursor.com/deeplink/mcp-install-dark.svg" alt="Add to Cursor" class="no-decoration" width="160" height="30"></a><br/>

Otherwise, to access the `mcp.json` file through the Cursor app to implement this configuration:

1. From your **Cursor Settings**, select **MCP & Integrations**.
1. Under **MCP Tools**, select **Add Custom MCP** to open the `mcp.json` file.
1. Implement the following update to this file, where if you have other MCP servers configured in Cursor, just add the `"buildkite": { ... }` object to this JSON file.

```json
{
  "mcpServers": {
    "buildkite": {
      "url": "https://mcp.buildkite.com/mcp"
    }
  }
}
```

## Goose

You can configure [Goose](https://block.github.io/goose/) with the remote Buildkite MCP server by adding the relevant configuration to your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).



## Visual Studio Code

You can configure [Visual Studio Code](https://code.visualstudio.com/) with the Buildkite MCP server, either [remotely](#visual-studio-code-remote) or running locally [using Docker](#visual-studio-code-docker) or [as a binary](#visual-studio-code-binary). To do this, add the relevant configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

### Remote

When using the remote MCP server, add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

```json
{
  "servers": {
    "buildkite": {
      "url": "https://mcp.buildkite.com/mcp",
      "type": "http"
    }
  }
}
```

Alternatively, you can initiate this process through the Visual Studio Code interface. To do this:

1. In the [Command Palette](https://code.visualstudio.com/docs/getstarted/getting-started#_access-commands-with-the-command-palette), find and select the **MCP: Add Server** command.
1. Select **HTTP (HTTP or Server-Sent Events)** to start configuring a remote MCP server.
1. For **Enter Server URL**, specify `https://mcp.buildkite.com/mcp`.
1. For **Enter Server ID**, specify `buildkite`.

    Follow the remaining prompts to complete this configuration process.

The first time you start using the remote MCP server on Visual Studio Code, the **Authorize Application** for the **Buildkite MCP Server** page opens. On this page, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use the Buildkite's remote MCP server through Visual Studio Code for this Buildkite organization.

### Docker

When using [Docker](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

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

When using a [pre-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

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

You can configure [Windsurf](https://windsurf.com/) with the Buildkite MCP server, either [remotely](#windsurf-remote) or running locally [using Docker](#windsurf-docker) or [as a binary](#windsurf-binary). To do this, add the relevant configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

### Remote

When using the remote MCP server, add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

```json
{
  "mcpServers": {
    "buildkite": {
      "url": "https://mcp.buildkite.com/mcp"
    }
  }
}
```

The first time you start using the remote MCP server on Windsurf, the **Authorize Application** for the **Buildkite MCP Server** page opens. On this page, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use the Buildkite's remote MCP server through Windsurf for this Buildkite organization.

### Docker

When using [Docker](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-docker) to run the MCP server, add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

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

When using a [pre-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-using-a-pre-built-binary) or [source-built](/docs/apis/mcp-server/installing#install-and-run-the-server-locally-building-from-source) binary to run the MCP server, add the following JSON configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

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

To do add the Buildkite MCP server extension to Zed:

1. Visit Zed's [Buildkite MCP server extension](https://zed.dev/extensions/mcp-server-buildkite) page.
1. Select the **Install MCP Server in Zed** button on this web page to open the **Extensions** window in Zed.
1. In the **Extensions** window, ensure the **Buildkite MCP** extension is shown and select its **Install** button.
1. In the **Configure mcp-server-buildkite** dialog, copy your [configured Buildkite API access token](/docs/apis/mcp-server/installing#configure-an-api-access-token) and paste this over the `BUILDKITE_API_TOKEN` value.
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

You can configure [ToolHive](https://toolhive.dev/) to run the Buildkite MCP server locally from its registry using ToolHive's command line interface (CLI) tool. To do this, ensure you have installed TooHive's [CLI tool](https://toolhive.dev/download.html) and do the following:

1. Use ToolHive's `thv secret set` command to store your [Buildkite API access token](/docs/apis/mcp-server/installing#configure-an-api-access-token) as a secret.

    ```bash
    cat ~/path/to/your/buildkite-api-token.txt | thv secret set buildkite-api-key
    ```

    where `buildkite-api-token.txt` contains the value of your Buildkite API access token.

1. Run the Buildkite MCP server.

    ```bash
    thv run --secret buildkite-api-key,target=BUILDKITE_API_TOKEN buildkite
    ```

You can also configure ToolHive to run the Buildkite MCP server from its registry using the ToolHive interface. To do this, ensure you have installed TooHive's [Desktop app](https://toolhive.dev/download.html) and do the following:

1. Access [ToolHive's **Secrets** page](https://docs.stacklok.com/toolhive/guides-ui/secrets-management#manage-secrets).

1. Add a new secret with the following values:
    * **Secret name**: `buildkite-api-key`
    * **Secret value**: Your [Buildkite API access token](/docs/apis/mcp-server/installing#configure-an-api-access-token)'s value.

1. Access [ToolHive's **Registry** page](https://docs.stacklok.com/toolhive/guides-ui/run-mcp-servers).

<!-- vale off -->

1. Search for `buildkite` and then select the filtered **buildkite** registry option.

1. Select **Install server** and on the **Configure buildkite** dialog's **Configuration** tab, specify the following values:
    * **Secrets**: Select `buildkite-api-key`.
    * **Environment variables** (_optional_): Specify the threshold for logging tokens. Omitting this field sets its value to 0, which means that no tokens are logged.

<!-- vale on -->
