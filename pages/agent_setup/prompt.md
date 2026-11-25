---
toc: false
description: Set up an AI coding agent with Buildkite skills and the Buildkite MCP server.
---

# Set up your coding agent for Buildkite

These are Buildkite's instructions for your coding agent. Run the applicable commands and merge new settings into the existing configuration without overwriting existing entries. Start with read-only access to inspect Buildkite resources.

## Install Buildkite skills

Reuse any [Buildkite skills](https://github.com/buildkite/skills) already available. Install a skill only if the user's task needs it and it isn't already available. Install it in the current project. Ask before installing anything globally.

For example, to add the Buildkite Pipelines skill for Claude Code, run this command from the project root. Choose the skill and agent that match your setup.

```bash
npx -y skills add buildkite/skills --skill buildkite-pipelines --agent claude-code --yes
```

## Connect the Buildkite MCP server

For interactive clients, use the [read-only OAuth endpoint](/docs/apis/mcp-server#read-only-remote-mcp-server) at `https://mcp.buildkite.com/mcp/readonly`. Follow the instructions for your client. Use native HTTP and OAuth when the client supports them. Enable write access separately only if the user explicitly requests it.

For unattended clients that cannot complete OAuth, skip the OAuth examples. Use `https://mcp.buildkite.com/direct/readonly` with a pre-provisioned Buildkite API access token for the intended organization. The token must have only the read scopes the task needs, including `read_pipelines` for verification. The endpoint does not narrow the token's scopes.

Follow the [headless configuration instructions](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents) to send the bearer token in the `Authorization` header. Use the client's secret configuration. If no suitable token is available, report that setup is blocked. Do not ask the user to paste credentials into the conversation.

### Amp

For the Amp CLI running locally, add the server to the current workspace:

```bash
amp mcp add --workspace buildkite-read-only https://mcp.buildkite.com/mcp/readonly
```

For Amp on the web or in an orb, use a personal [remote MCP definition](https://ampcode.com/docs/customize/mcp#remote-mcp-definitions), not the settings file on your computer. Add `buildkite-read-only` with the same URL in [Integrations & MCP settings](https://ampcode.com/settings/integrations), or run:

```bash
amp mcp remote --personal add buildkite-read-only https://mcp.buildkite.com/mcp/readonly --auth oauth
```

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

Merge the following configuration into `.cursor/mcp.json`:

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

Use the client's remote MCP configuration to register `buildkite-read-only` with the read-only OAuth URL.

## Authenticate and verify

Reload the client if required. If the client requires approval to load workspace configuration, ask the user to approve it.

If OAuth is needed, start the client's sign-in flow. Ask the user to select the intended Buildkite organization, complete any required single sign-on (SSO), and select **Authorize** on the authorization page. Leave organization selection and consent to the user.

Call `list_pipelines` on the read-only MCP connection with the slug of the organization the user authorized or the token was provisioned for. A successful response, even if the list is empty, verifies the connection. If the call fails, report the error rather than trying a different connection, the CLI, or the API directly.

Report the verified organization, the MCP endpoint and where it was configured, and the names and scope of any skills installed. If you couldn't verify the connection, say what remains blocked.

## Resources

- [Configuring AI tools with the remote Buildkite MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools)
- [Read-only access boundaries](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries)

These instructions are published at `https://buildkite.com/docs/agent-setup/prompt.md`, so you can verify their authenticity at any time.
