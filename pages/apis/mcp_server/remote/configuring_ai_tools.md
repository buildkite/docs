# Configuring AI tools with the remote MCP server

This page explains how to configure your AI tool to work with the [_remote_ Buildkite MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server).

> 📘
> The Buildkite MCP server is available both [locally and remotely](/docs/apis/mcp-server#types-of-mcp-servers). This page is about configuring AI tools with the remote MCP server. If you are using an AI tool or agent and would prefer it to work with the _local_ MCP server, ensure you have followed the required instructions on [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing) locally first, before proceeding with the relevant instructions on its [Configuring AI tools](/docs/apis/mcp-server/local/configuring-ai-tools) page.

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Amp for this Buildkite organization.

## Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) with the remote Buildkite MCP server by running the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add --transport http buildkite https://mcp.buildkite.com/mcp
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Claude Code for this Buildkite organization.

## Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) with the remote Buildkite MCP server, by doing the following to configure this server in Claude Desktop.

> 📘
> This process assumes you are on an Enterprise or Team plan (with either the Owner or Primary Owner role), or a Pro or Max plan for Claude Desktop.

1. Select **Settings** > **Connectors**.
1. In the **Connectors** section, and if you are on an Enterprise or Team plan, select the **Organization connectors** tab.
1. Select the **Add custom connector** button.
1. In the **Add custom connector** dialog, for the **Name** field, specify **Buildkite**.
1. For the **Remote MCP server URL** field, specify `https://mcp.buildkite.com/mcp`.
1. Select **Add** to complete the configuration.
1. Back in the **Connectors** section, select the **Connect** button for **Buildkite** to connect to the remote MCP server.

    **Note:** If you are on the Enterprise or Team plan, to access this **Connect** button, you may need to select the **Your connectors** tab first.

If you need a new OAuth token, the **Authorize Application** for the **Buildkite MCP Server** page appears. If so, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use Buildkite's remote MCP server through Claude Desktop for this Buildkite organization.

If you need more assistance with this process, follow Anthropic's guidelines for [Getting Started with Custom Connectors](https://support.anthropic.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp#h_3d1a65aded).

## Cursor

You can configure [Cursor](https://cursor.com/) with the remote Buildkite MCP server by adding the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcp-json), which is usually located in your home directory's `.cursor` sub-directory.

<!--

You can conveniently add this configuration using the following button, and then select **Install** on the **MCP & Integrations** page of the Cursor interface.

<a class="inline-block" href="https://cursor.com/en/install-mcp?name=buildkite&config=eyJ1cmwiOiJodHRwczovL21jcC5idWlsZGtpdGUuY29tL21jcCJ9" target="_blank" rel="nofollow"><img src="https://cursor.com/deeplink/mcp-install-dark.svg" alt="Add to Cursor" class="no-decoration" width="160" height="30"></a><br/>

Otherwise, to access the `mcp.json` file through the Cursor app to implement this configuration:

-->

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Cursor for this Buildkite organization.

## Goose

[Goose](https://block.github.io/goose/) is a local AI tool and agent that can be configured with different [LLM (AI model) providers](https://block.github.io/goose/docs/getting-started/providers).

You can configure Goose with the remote Buildkite MCP server by adding the relevant configuration to the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

```yaml
extensions:
  buildkite:
    available_tools: []
    bundled: null
    description: null
    enabled: true
    env_keys: []
    envs: {}
    headers: {}
    name: Buildkite HTTP
    timeout: 300
    type: streamable_http
    uri: https://mcp.buildkite.com/mcp
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Goose for this Buildkite organization.

## Visual Studio Code

You can configure [Visual Studio Code](https://code.visualstudio.com/) with the remote Buildkite MCP server by adding the relevant configuration to your [Visual Studio Code's `mcp.json` file](https://code.visualstudio.com/docs/copilot/customization/mcp-servers#_add-an-mcp-server).

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

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Visual Studio Code for this Buildkite organization.

## Windsurf

You can configure [Windsurf](https://windsurf.com/) with the remote Buildkite MCP server by adding the relevant configuration to your [Windsurf's `mcp_config.json` file](https://docs.windsurf.com/windsurf/cascade/mcp#mcp-config-json).

```json
{
  "mcpServers": {
    "buildkite": {
      "url": "https://mcp.buildkite.com/mcp"
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Windsurf for this Buildkite organization.
