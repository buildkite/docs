---
keywords: docs, pipelines, AI agents, Claude, MCP server, skills, LLM, getting started
---

# Getting started with agents

AI coding agents like [Claude Code](https://claude.ai/code), Cursor, and GitHub Copilot can help you build, debug, and maintain Buildkite Pipelines more effectively. This page covers three ways to give your AI agent the context and tools it needs to work with Buildkite.

## Install Buildkite skills

[Buildkite skills](https://github.com/buildkite/skills) encode the judgment an experienced Buildkite user applies—not just documentation, but patterns, best practices, and common solutions. Installing them into your AI coding agent gives it deep Buildkite expertise without you having to re-explain conventions in every session.

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

- **Journey skills**: Pipelines and Migration cover end-to-end workflows.
- **Cross-cutting skills**: Preflight, Agent Runtime, CLI, and API cover specific capabilities you reach for throughout development.

To install skills, follow the instructions in the [Buildkite skills repository](https://github.com/buildkite/skills).

## Connect to the MCP server

The [Buildkite MCP server](/docs/apis/mcp) uses the Model Context Protocol (MCP) to give your AI agent live access to Buildkite's REST API features—build logs, pipeline configuration, cluster state, and more. This means your agent can inspect running builds, diagnose failures, and iterate on configuration using real data.

With the MCP server connected, your agent can:

- Fetch build logs and identify root causes of failures
- Query pipeline configuration and suggest improvements
- Trigger new builds and monitor their progress
- Access cluster and queue state to debug job routing issues

To set up the MCP server, see the [MCP server](/docs/apis/mcp) documentation.

## Use Buildkite docs as context

Every Buildkite documentation page is available in Markdown format—append `.md` to any URL. For example, [`/docs/pipelines/getting-started.md`](/docs/pipelines/getting-started.md). Pass these URLs directly to your AI agent as focused context when working on a specific topic.

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

Use a section's `llms.txt` as a starting point to give your agent a comprehensive overview of that area, then pass individual `.md` pages for deeper context on specific tasks.

## Next steps

Once you're set up, explore how to run AI agents directly inside your CI pipeline steps in [AI agents in Pipelines](/docs/platform/ai-agents).
