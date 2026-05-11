---
keywords: docs, platform, AI agents, model providers, MCP server, skills, LLM, Claude, plugins, agentic steps
---

# AI agents in Pipelines

Buildkite supports AI agents in two complementary ways: you can use agents to _build and maintain_ your pipelines, and you can run agents _inside_ your CI pipeline steps.

## Build with agents

Give your AI coding agent the context and tools it needs to work with Buildkite effectively.

### Skills

[Buildkite skills](https://github.com/buildkite/skills) encode expert knowledge about Buildkite—YAML configuration patterns, migration strategies, CLI usage, and API patterns—in a format optimized for AI coding agents like [Claude Code](https://claude.ai/code), Cursor, and GitHub Copilot.

Install them to avoid re-explaining Buildkite conventions in every session. Available skills cover:

- Pipeline configuration and step types
- Migrating from other CI platforms
- Running [preflight builds](/docs/platform/cli/preflight) against local changes
- Agent runtime commands
- The Buildkite CLI and REST/GraphQL APIs

See [Getting started with agents](/docs/pipelines/getting-started-with-agents#install-buildkite-skills) for the full skill list and installation instructions.

### MCP server

The [Buildkite MCP server](/docs/apis/mcp) uses the Model Context Protocol (MCP) to connect your AI agent to the Buildkite REST API in real time. Your agent can inspect build state, read logs, trigger runs, and iterate on pipeline configuration using live data.

### Docs as context

Every Buildkite docs page is available in Markdown format—append `.md` to any URL (for example, `/docs/pipelines/getting-started.md`). Per-section `llms.txt` files are available for loading entire topic areas into your agent's context at once.

See [Getting started with agents](/docs/pipelines/getting-started-with-agents#use-buildkite-docs-as-context) for the full list of `llms.txt` URLs.

## Use agents in CI

Run AI agents as steps in your pipelines to automate analysis, summarize failures, and connect AI capabilities to your build workflows.

### Agentic steps with model providers

[Model providers](/docs/apis/model-providers) connect LLMs directly into pipeline steps, giving agents access to build logs, artifacts, security policies, and real-time pipeline data. This is Buildkite's native approach to running agentic steps.

Agent steps authenticate using the existing `$BUILDKITE_AGENT_ACCESS_TOKEN`—no separate API key is required when using a [Buildkite hosted token](/docs/apis/model-providers#buildkite-hosted-token) (available on Pro and Enterprise plans). Teams that manage their own credentials can use [Bring Your Own Token](/docs/apis/model-providers#bring-your-own-token) instead.

```yaml
steps:
  - label: "\:anthropic\: Analyze test failures"
    command: |
      curl "$BUILDKITE_AGENT_ENDPOINT/ai/anthropic" \
        -H "Authorization: Bearer $BUILDKITE_AGENT_ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "model": "claude-opus-4-5",
          "messages": [{"role": "user", "content": "Analyze these test failures and suggest fixes..."}]
        }'
```

> 📘 Supported models
> Only Anthropic models are currently supported via model providers. See [Model providers](/docs/apis/model-providers) for the full configuration reference, including usage tracking in **Organization Settings > Usage > Model Providers**.

### Plugins

For quick AI integration without custom scripting, Buildkite plugins can add failure analysis and log summarization to any pipeline step:

| Plugin | LLM provider | Description |
|---|---|---|
| [claude-summarize](https://buildkite.com/resources/plugins/buildkite-plugins/claude-summarize-buildkite-plugin/) | Anthropic Claude | Analyzes build failures, identifies root causes, and posts suggested fixes as build annotations |
| [bedrock-summarize](https://buildkite.com/resources/plugins/buildkite-plugins/bedrock-summarize-buildkite-plugin/) | AWS Bedrock | Same failure analysis pattern using AWS Bedrock LLMs; supports injecting project context via `agent_file` |
| [chatgpt-analyzer](https://buildkite.com/resources/plugins/buildkite-plugins/chatgpt-analyzer-buildkite-plugin/) | OpenAI | Build log analysis and summarization using OpenAI models |
{: class="responsive-table"}

All three plugins support `trigger: on-failure` to run only when a step fails, `analysis_level: step` or `build` to scope the analysis, and `custom_prompt` to add project-specific context.

**Example using the `bedrock-summarize` plugin:**

```yaml
steps:
  - label: ":test_tube: Run tests"
    command: "bundle exec rspec"
    plugins:
      - buildkite/bedrock-summarize#v1.0.0:
          trigger: on-failure
          analysis_level: step
          model: "anthropic.claude-3-5-sonnet-20241022-v2:0"
          custom_prompt: "This is a Ruby on Rails app. Focus on database and authentication errors."
```

> 📘 claude-summarize deprecation
> The `claude-summarize` plugin is no longer actively maintained. For Anthropic model integration, Buildkite recommends using [model providers](/docs/apis/model-providers) instead.
