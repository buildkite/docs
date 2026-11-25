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

If the user requests read-only access, use the [read-only OAuth endpoint](/docs/apis/mcp-server#read-only-remote-mcp-server) at `https://mcp.buildkite.com/mcp/readonly`. If the workflow only needs to inspect Buildkite data and the user hasn't chosen an access mode, offer this option. The examples below show read-only setup. Read-only access limits this connection, not the agent's [other tools or credentials](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries).

If the user explicitly requests write access, follow the [remote MCP configuration guide](/docs/apis/mcp-server/remote/configuring-ai-tools) to configure a separate write-capable connection. If the requested access is unclear, ask which mode the user wants before configuring the connection.

For read-only setup when the client cannot complete OAuth, use `https://mcp.buildkite.com/direct/readonly` with a pre-provisioned Buildkite API access token for the intended organization. The token must have only the read scopes required by the task, including `read_pipelines` for verification. The endpoint does not narrow the token's scopes.

Follow the [headless setup instructions](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents) to send the bearer token in the `Authorization` header using the client's secret configuration. If no suitable token is available, report that setup is blocked.

### Amp

For the local Amp CLI, merge the following configuration into the project's `.amp/settings.json` file. Amp handles HTTP and OAuth natively.

```json
{
  "amp.mcpServers": {
    "buildkite-read-only": {
      "url": "https://mcp.buildkite.com/mcp/readonly"
    }
  }
}
```

For Amp on the web or in an orb, add the same name and URL as a personal [remote MCP definition](https://ampcode.com/docs/customize/mcp#remote-mcp-definitions) with OAuth in [Integrations & MCP settings](https://ampcode.com/settings/integrations).

### Claude Code

Run this command:

```bash
claude mcp add --transport http buildkite-read-only https://mcp.buildkite.com/mcp/readonly
```

### Codex

Run this command:

```bash
codex mcp add buildkite-read-only --url https://mcp.buildkite.com/mcp/readonly
```

If Codex doesn't start OAuth automatically, run `codex mcp login buildkite-read-only`.

### Cursor

The [Buildkite plugin on the Cursor Marketplace](https://cursor.com/marketplace/buildkite) installs both the MCP server and Buildkite skills, and uses the write-capable MCP endpoint. For read-only access, merge the following configuration into `.cursor/mcp.json` instead:

```json
{
  "mcpServers": {
    "buildkite-read-only": {
      "url": "https://mcp.buildkite.com/mcp/readonly"
    }
  }
}
```

### Visual Studio Code and GitHub Copilot

Merge the following configuration into `.vscode/mcp.json`:

```json
{
  "servers": {
    "buildkite-read-only": {
      "type": "http",
      "url": "https://mcp.buildkite.com/mcp/readonly"
    }
  }
}
```

### Other agents

For another agent, use its standard remote MCP configuration to register a server named `buildkite-read-only` with the URL `https://mcp.buildkite.com/mcp/readonly`.

## Authenticate and verify

Restart or reload the agent if required, then verify that any installed Buildkite skills are available. If the client requires approval to load workspace configuration, ask the user to approve it.

If OAuth is needed, start the client's sign-in flow. When the browser authorization page opens, ask the user to select their Buildkite organization and authorize access. If the organization requires SSO, the user must log in with SSO first.

For read-only setup, call `list_pipelines` through the `buildkite-read-only` connection for the organization the user authorized or the token was provisioned for. An empty list is a valid result. If the call fails, report the error instead of switching to another connection or credential.

Once complete, report which skills and MCP configuration were installed, where they were installed, and whether authorization and verification succeeded.

## Resources

- [Buildkite skills](https://github.com/buildkite/skills)
- [Buildkite MCP server documentation](/docs/apis/mcp-server)
- [Configure AI tools with the remote Buildkite MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools)

These instructions are published at `https://buildkite.com/docs/agent-setup/prompt.md`, so you can verify their authenticity at any time.
