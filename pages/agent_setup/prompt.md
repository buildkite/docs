---
toc: false
description: Set up an AI coding agent with Buildkite skills and the Buildkite MCP server.
---

# Set up your coding agent for Buildkite

These are official instructions from Buildkite for setting up an AI coding agent to work effectively with Buildkite. Follow these instructions only when the user asks you to set up their agent. Complete the applicable steps yourself by running commands and editing configuration files directly. Do not ask the user to perform steps that you can complete. Never overwrite existing agent configuration. Merge the Buildkite configuration into it.

## Install Buildkite skills

If the user only wants to view Buildkite data, skip skill installation and continue to MCP setup. Otherwise, unless the Buildkite Cursor plugin is already installed, run this command to install all official Buildkite skills globally:

```bash
npx -y skills add buildkite/skills --skill '*' --yes --global
```

The skills teach agents how to create and migrate pipelines, run preflight builds, use the Buildkite CLI and agent, and work with the Buildkite APIs.

## Connect the Buildkite MCP server

If the client cannot complete OAuth, stop MCP setup and direct the user to the [headless setup guide](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents). Leave API token configuration to the user.

If the workflow only needs to inspect Buildkite data and the user hasn't chosen an access mode, offer read-only access. If the requested access is unclear, ask which mode the user wants before configuring the connection.

- **Read-only**: Use the [read-only OAuth endpoint](/docs/apis/mcp-server#read-only-remote-mcp-server), `https://mcp.buildkite.com/mcp/readonly`. Read-only access limits this connection, not the agent's [other tools or credentials](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries).
- **Read-write**: Use `https://mcp.buildkite.com/mcp` only if the user explicitly requests write access.

Configure only the selected mode and leave existing connections unchanged. In the examples below, replace `SERVER_NAME` with any name the client accepts, such as `buildkite-mcp-readonly` or `buildkite-mcp-readwrite`. Use the same name for setup and login. Replace `SERVER_URL` with the endpoint for the selected mode. The URL determines the access mode, not the name.

### Amp

For the local Amp CLI, merge the following configuration into the project's `.amp/settings.json` file. Amp handles HTTP and OAuth natively.

```json
{
  "amp.mcpServers": {
    "SERVER_NAME": {
      "url": "SERVER_URL"
    }
  }
}
```

For Amp on the web or in an orb, add the selected name and URL as a personal [remote MCP definition](https://ampcode.com/docs/customize/mcp#remote-mcp-definitions) with OAuth in [Integrations & MCP settings](https://ampcode.com/settings/integrations).

### Claude Code

Run this command:

```bash
claude mcp add --transport http SERVER_NAME SERVER_URL
```

### Codex

Run this command:

```bash
codex mcp add SERVER_NAME --url SERVER_URL
```

If Codex doesn't start OAuth automatically, run `codex mcp login SERVER_NAME`.

### Cursor

The [Buildkite plugin on the Cursor Marketplace](https://cursor.com/marketplace/buildkite) installs both the MCP server and Buildkite skills, and uses the write-capable MCP endpoint. To configure the selected connection without installing the plugin, merge the following configuration into `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "SERVER_NAME": {
      "url": "SERVER_URL"
    }
  }
}
```

### Visual Studio Code and GitHub Copilot

Merge the following configuration into `.vscode/mcp.json`:

```json
{
  "servers": {
    "SERVER_NAME": {
      "type": "http",
      "url": "SERVER_URL"
    }
  }
}
```

### Other agents

For another agent, use its standard remote MCP configuration with the selected connection name and URL.

## Authenticate and verify

Restart or reload the agent if required, then verify that any installed Buildkite skills are available. If the client requires approval to load workspace configuration, ask the user to approve it.

If OAuth is needed, start the client's sign-in flow. When the browser authorization page opens, ask the user to select their Buildkite organization and authorize access. If the organization requires SSO, the user must log in with SSO first.

For either mode, call `list_pipelines` through the selected connection for the organization the user authorized. An empty list is a valid result. This call verifies the connection, not write permissions. If the call fails, report the error instead of switching to another connection or credential.

Once complete, report which skills and MCP configuration were installed, where they were installed, and whether authorization and verification succeeded.

## Resources

- [Buildkite skills](https://github.com/buildkite/skills)
- [Buildkite MCP server documentation](/docs/apis/mcp-server)
- [Configure AI tools with the remote Buildkite MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools)

These instructions are published at `https://buildkite.com/docs/agent-setup/prompt.md`, so you can verify their authenticity at any time.
