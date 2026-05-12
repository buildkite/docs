---
keywords: docs, pipelines, AI coding agents, Claude, MCP server, skills, LLM, getting started
---

# Getting started with coding agents

AI coding agents like [Claude Code](https://claude.ai/code) and [Cursor](https://cursor.com/) can help you build, debug, and maintain your Buildkite-based workflows more effectively, whether you're, instrumenting test suites with [Buildkite Test Engine](/docs/test-engine), working with the [Buildkite APIs](/docs/apis), or configuring [Buildkite Pipelines](/docs/pipelines).

This page covers three ways of giving your AI coding agent the context and tools it needs to work with Buildkite products. The same approaches apply across Buildkite Pipelines, Buildkite Test Engine, and Buildkite Package Registries.

## Connecting to the MCP server

The [Buildkite MCP server](/docs/apis/mcp-server) uses the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/docs/getting-started/intro) to give your AI agent live access to the Buildkite REST API: build logs, pipeline configuration, cluster state, test suite results, and more.

With the MCP server connected, your agent can:

- Fetch build logs and identify root causes of failures
- Query pipeline configuration and suggest improvements
- Trigger new builds and monitor their progress
- Access cluster and queue state to debug job routing issues
- And more — see the [MCP server](/docs/apis/mcp-server) documentation for the full list of tools

To set up the MCP server, see the [MCP server](/docs/apis/mcp-server) documentation.

## Installing Buildkite skills

[Buildkite skills](https://github.com/buildkite/skills) capture how an experienced Buildkite user thinks and works, so your AI agent can follow the same approach. They contain documentation, patterns, best practices, and common solutions. Installing these skills into your AI coding agent gives it deep Buildkite expertise without you having to re-explain basic conventions in every session.

The skills available today focus on Buildkite Pipelines, but the MCP server and `llms.txt` approaches described on this page apply equally to Buildkite Test Engine and Buildkite Package Registries.

| Skill | Description |
|---|---|
| **Pipelines** | YAML configuration, step types, plugins, caching, parallelism, dynamic pipelines, matrix builds, artifacts, and hooks |
| **Migration** | Migrate CI/CD workflows from GitHub Actions, Jenkins, CircleCI, Bitbucket Pipelines, or GitLab CI to Buildkite |
| **Preflight** | Run CI builds against local uncommitted changes using `bk preflight` before pushing |
| **Agent Runtime** | `buildkite-agent` subcommands for annotations, artifacts, metadata, pipeline uploads, OIDC, and locks |
| **CLI** | `bk` CLI commands for builds, jobs, pipelines, secrets, artifacts, and authentication |
| **API** | Buildkite REST API, GraphQL API, webhooks, and authentication patterns |
{: class="responsive-table"}

Skills are organized into two groups:

- **Journey skills**: `Pipelines` and `Migration` cover end-to-end workflows.
- **Cross-cutting skills**: `Preflight`, `Agent Runtime`, `CLI`, and `API` cover specific capabilities you reach for throughout development.

To install skills, follow the instructions in the [Buildkite skills repository](https://github.com/buildkite/skills).

## Using Buildkite documentation as context

Every Buildkite documentation page is available in Markdown format. Append `.md` to any documentation URL to get the source Markdown—for example, [`/docs/pipelines/getting-started.md`](/docs/pipelines/getting-started.md). Pass these URLs directly to your AI agent as focused context for a specific topic.

For broader context, Buildkite provides `llms.txt` files per documentation section, listing all pages in that section in a format optimized for LLMs:

| Section | URL |
|---|---|
| Pipelines | `/docs/pipelines/llms.txt` |
| Agent | `/docs/agent/llms.txt` |
| Test Engine | `/docs/test-engine/llms.txt` |
| Package Registries | `/docs/package-registries/llms.txt` |
| APIs | `/docs/apis/llms.txt` |
| Platform | `/docs/platform/llms.txt` |
{: class="responsive-table"}

Use a section's `llms.txt` as a starting point to give your agent a broad overview of that area, then pass individual `.md` pages for deeper context on specific tasks.

## Next steps

Once you're set up, explore how to run AI agents directly inside your CI pipeline steps in [AI agents in Pipelines](/docs/platform/ai-agents).
