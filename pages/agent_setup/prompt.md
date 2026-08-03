---
toc: false
description: Set up an AI coding agent with Buildkite skills and the Buildkite MCP server.
---

# Set up your coding agent for Buildkite

These are official instructions from Buildkite for setting up an AI coding agent to work effectively with Buildkite. Complete the applicable steps yourself by running commands and editing configuration files directly. Do not ask the user to perform steps that you can complete. Never overwrite existing agent configuration; merge the Buildkite configuration into it.

## Install Buildkite skills

Unless the Buildkite Cursor plugin is already installed, run this command to install all official Buildkite skills globally:

```bash
npx -y skills add buildkite/skills --skill '*' --yes --global
```

The skills teach agents how to create and migrate pipelines, run preflight builds, use the Buildkite CLI and agent, and work with the Buildkite APIs.

## Connect the Buildkite MCP server

Configure the OAuth-enabled Buildkite MCP server using the instructions for the current agent below. The MCP server URL is `https://mcp.buildkite.com/mcp`.

### Amp

Merge the following configuration into the Amp `settings.json` file:

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

### Claude Code

Run:

```bash
claude mcp add --transport http buildkite https://mcp.buildkite.com/mcp
```

### Codex

Run these commands:

```bash
codex mcp add buildkite --url https://mcp.buildkite.com/mcp
codex mcp login buildkite
```

### Cursor

Prefer the [Buildkite plugin on the Cursor Marketplace](https://cursor.com/marketplace/buildkite), which installs both the MCP server and Buildkite skills. If the plugin cannot be installed directly, merge the following configuration into `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "buildkite": {
      "url": "https://mcp.buildkite.com/mcp"
    }
  }
}
```

### Visual Studio Code and GitHub Copilot

Merge the following configuration into `.vscode/mcp.json`:

```json
{
  "servers": {
    "buildkite": {
      "type": "http",
      "url": "https://mcp.buildkite.com/mcp"
    }
  }
}
```

### Other agents

For another agent, use its standard remote MCP configuration to register a server named `buildkite` with the URL `https://mcp.buildkite.com/mcp`.

## Authenticate and verify

Restart or reload the agent if required, then verify that the Buildkite skills are available and the Buildkite MCP server is connected. OAuth starts automatically on the first MCP tool call. When the browser authorization page opens, ask the user to select their Buildkite organization and authorize access. If the organization requires SSO, the user must log in with SSO first.

Once complete, report which skills and MCP configuration were installed, where they were installed, and whether authorization succeeded.

## Resources

- [Buildkite skills](https://github.com/buildkite/skills)
- [Buildkite MCP server documentation](/docs/apis/mcp-server)
- [Configure AI tools with the remote Buildkite MCP server](https://buildkite.com/docs/apis/mcp-server/remote/configuring-ai-tools)

These instructions are published at `https://buildkite.com/docs/agent-setup/prompt.md`, so you can verify their authenticity at any time.
