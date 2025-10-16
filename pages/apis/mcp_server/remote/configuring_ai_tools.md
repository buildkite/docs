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

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Amp](#amp), you can implement the following headers to this configuration, for example:

```json
{
  "amp.mcpServers": {
    "buildkite-read-only-toolsets": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://mcp.buildkite.com/mcp",
        "--header",
        "X-Buildkite-Toolsets: user,pipelines,builds",
        "--header",
        "X-Buildkite-Readonly: true"
      ]
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>

## Claude Code

You can configure [Claude Code](https://www.anthropic.com/claude-code) with the remote Buildkite MCP server by running the relevant Claude Code command, after [installing Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview).

```bash
claude mcp add --transport http buildkite https://mcp.buildkite.com/mcp
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Claude Code for this Buildkite organization.

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Claude Code](#claude-code), you can add the following header configurations to this command, for example:

```bash
claude mcp add --transport http buildkite-read-only-toolsets https://mcp.buildkite.com/mcp --header "X-Buildkite-Toolsets: user,pipelines,builds" --header "X-Buildkite-Readonly: true" 
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>

## Claude Desktop

You can configure [Claude Desktop](https://claude.ai/download) with the remote Buildkite MCP server, by creating a custom connector for this MCP server in Claude Desktop.

> 📘
> This process assumes you are on an Enterprise or Team plan (with either the Owner or Primary Owner role), or a Pro or Max plan for Claude Desktop.

1. Select **Settings** > **Connectors**.

    **Note:** If you're on an Enterprise or Team plan, select **Admin settings** > **Connectors** instead.

1. Towards the end of the **Connectors** page, select the **Add custom connector** button.
1. In the **Add custom connector** dialog, for the **Name** field, specify **Buildkite**.
1. For the **Remote MCP server URL** field, specify `https://mcp.buildkite.com/mcp`.
1. Select **Add** to complete the configuration.
1. On the **Settings** > **Connectors** page, select the **Connect** button for **Buildkite** to connect to the remote MCP server.

    **Note:** If you are on the Enterprise or Team plan, to access this **Connect** button, you may need to select the **Your connectors** tab first.

If you need a new OAuth token, the **Authorize Application** for the **Buildkite MCP Server** page appears. If so, scroll down and select your Buildkite organization in **Authorize for organization**, followed by **Authorize**.

You're now ready to use Buildkite's remote MCP server through Claude Desktop for this Buildkite organization.

If you need more assistance with this process, follow Anthropic's guidelines for [Getting Started with Custom Connectors](https://support.anthropic.com/en/articles/11175166-getting-started-with-custom-connectors-using-remote-mcp#h_3d1a65aded).

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Claude Desktop](#claude-desktop), follow this [create custom connector procedure](#claude-desktop) by implementing the [URL extension approach](/docs/apis/mcp-server/tools/toolsets#configuring-the-remote-mcp-server-using-a-url-extension) when enabling the toolset, with the following updates:

- For the **Name** field, specify a name that better describes the customer connector. For example, **Buildkite - pipelines toolset** for the `pipelines` toolset.
- For the **Remote MCP server URL** field, specify the enabled toolset for the remote MCP server. For example, `https://mcp.buildkite.com/mcp/x/pipelines`.

    **Note:** If you also want to enforce read-only access for the tools in this toolset, append `/readonly` to this URL, for example, `https://mcp.buildkite.com/mcp/x/pipelines/readonly`.

Repeat this process for each toolset you want to enable. You'll end up with multiple custom connectors for the Buildkite MCP server, and to use them together, you'll need to connect to each one you want to use during your Claude Desktop sessions.

## Cursor

You can configure [Cursor](https://cursor.com/) with the remote Buildkite MCP server by adding the relevant configuration to your [Cursor's `mcp.json` file](https://docs.cursor.com/en/context/mcp#using-mcpjson), which is usually located in your home directory's `.cursor` sub-directory.

<!--

You can conveniently add this configuration using the following button, and then select **Install** on the **MCP & Integrations** page of the Cursor interface.

<a class="inline-block" href="https://cursor.com/en/install-mcp?name=buildkite&config={base64.encoded.config}" target="_blank" rel="nofollow"><img src="https://cursor.com/deeplink/mcp-install-dark.svg" alt="Add to Cursor" class="no-decoration" width="160" height="30"></a><br/>

Otherwise, to access the `mcp.json` file through the Cursor app to implement this configuration:

See https://cursor.com/docs/context/mcp/install-links for details.
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

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Cursor](#cursor), you can implement the following headers to this configuration, for example:

```json
{
  "mcpServers": {
    "buildkite-read-only-toolsets": {
      "url": "https://mcp.buildkite.com/mcp",
      "headers": {
        "X-Buildkite-Toolsets": "user,pipelines,builds",
        "X-Buildkite-Readonly": "true"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>

## Goose

[Goose](https://block.github.io/goose/) is a local AI tool and agent that can be configured with different [LLM (AI model) providers](https://block.github.io/goose/docs/getting-started/providers).

You can configure Goose with the remote Buildkite MCP server by adding the relevant configuration to the `extensions:` section of your [Goose `config.yaml` file](https://block.github.io/goose/docs/getting-started/using-extensions/#config-entry).

```yaml
extensions:
  buildkite:
    enabled: true
    type: streamable_http
    name: buildkite
    uri: https://mcp.buildkite.com/mcp
    envs: {}
    env_keys: []
    headers: {}
    description: ''
    timeout: 300
    bundled: null
    available_tools: []
```

<%= render_markdown partial: 'apis/mcp_server/buildkite_oauth_token' %>

You're now ready to use Buildkite's remote MCP server through Goose for this Buildkite organization.

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Goose](#goose), you can implement the following headers to this configuration, for example:

```yaml
extensions:
  buildkitereadonlytoolsets:
    enabled: true
    type: streamable_http
    name: buildkitereadonlytoolsets
    uri: https://mcp.buildkite.com/mcp
    envs: {}
    env_keys: []
    headers:
      X-Buildkite-Toolsets: user,pipelines,builds
      X-Buildkite-Readonly: 'true'
    description: ''
    timeout: 300
    bundled: null
    available_tools: []
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>

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

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Visual Studio Code](#visual-studio-code), you can implement the following headers to your `mcp.json` configuration file, for example:

```json
{
  "servers": {
    "buildkite-read-only-toolsets": {
      "url": "https://mcp.buildkite.com/mcp",
      "type": "http",
      "headers": {
        "X-Buildkite-Toolsets": "user,pipelines,builds",
        "X-Buildkite-Readonly": "true"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>

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

### Using toolsets and read-only access

To enable [toolsets](/docs/apis/mcp-server/tools/toolsets) or [configure read-only access](/docs/apis/mcp-server#read-only-remote-mcp-server), or both, for the remote MCP server with [Windsurf](#windsurf), you can implement the following headers to your `mcp_config.json` configuration file, for example:

```json
{
  "mcpServers": {
    "buildkite-read-only-toolsets": {
      "url": "https://mcp.buildkite.com/mcp",
      "headers": {
        "X-Buildkite-Toolsets": "user,pipelines,builds",
        "X-Buildkite-Readonly": "true"
      }
    }
  }
}
```

<%= render_markdown partial: 'apis/mcp_server/remote/mcp_server_toolset_config_additions' %>
