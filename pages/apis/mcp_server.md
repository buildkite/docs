# Buildkite MCP server

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect AI tools and models to a variety of other systems and data sources.

Buildkite provides its own MCP server to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, as well as from test data for Test Engine) for AI tools, editors and other products to interact with.

## Types of MCP servers

Buildkite provides both a _remote_ and _local_ MCP server.

The remote MCP server is one that Buildkite hosts, and is available for all customers to access at the following URL:

```url
https://mcp.buildkite.com/mcp
```

The local MCP server is one that you install yourself on your own machine. Learn more about how to set up and install a local Buildkite MCP server in [Installing the Buildkite MCP server locally](/docs/apis/mcp-server/installing-locally).

The MCP server is built on and interacts with Buildkite's REST API. Therefore, as part of installing a local Buildkite MCP server, you'll also need to [configure an API access token with the required scopes](/docs/apis/mcp-server/installing-locally#configure-api-access-token-with-required-scopes) that your local MCP server will use.

If you are using Buildkite's remote MCP server, you do not need to configure an API access token. Instead, your Buildkite user account's OAuth token, with pre-set access permission scopes is used.

