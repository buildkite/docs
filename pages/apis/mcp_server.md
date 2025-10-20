# Buildkite MCP server overview

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect artificial intelligence (AI) tools, agents and models to a variety of other systems and data sources.

Buildkite provides its own [open-source MCP server](https://github.com/buildkite/buildkite-mcp-server) to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, including test data for Test Engine) for AI tools, editors, agents, and other products to interact with.

Buildkite's MCP server is built on and interacts with the [Buildkite REST API](/docs/apis/rest-api). Learn more about what the MCP server is capable of in the [MCP tools overview](/docs/apis/mcp-server/tools).

To start using Buildkite's MCP server, first determine which [type of Buildkite MCP server](#types-of-mcp-servers) to work with. This next section provides an overview of the differences between these MCP server types and how they need to be configured.

Once you have established which Buildkite MCP server to use (remote or local) and if local, have [installed the MCP server](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally) and [configured its API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token), you can then proceed to configure your AI tools to work with the [remote](/docs/apis/mcp-server/remote/configuring-ai-tools) (recommended) or [local](/docs/apis/mcp-server/local/configuring-ai-tools) MCP server.

## Types of MCP servers

Buildkite provides both a [remote](#types-of-mcp-servers-remote-mcp-server) and [local](#types-of-mcp-servers-local-mcp-server) MCP server, both of which provide access to its [MCP server tools](/docs/apis/mcp-server/tools#available-mcp-tools).

### Remote MCP server

The _remote_ MCP server is one that Buildkite hosts, and is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp
```

This type of MCP server is typically used by AI tools that you interact with directly from a prompt, and it's the recommended MCP server type to use.

#### What it's suitable for

The remote MCP server is suitable for personal usage with an AI tool, as it has the following advantages.

- You don't need to configure an API access token, which poses a potential security risk if leaked.

    Instead, you only require your Buildkite user account, and the Buildkite platform issues a short-lived OAuth access token, representing your user account for authentication, along with both _read_ and _write_ access permission scopes which are pre-set by the Buildkite platform to provide the authorization. This OAuth token auth process takes place after [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools) and connecting to it.

    **Notes:**
    * OAuth access tokens are valid for 12 hours, and the refresh tokens are valid for seven days.
    * These OAuth access tokens provide both read and write access to the remote MCP server. If you'd prefer to restrict your access to read-only, a [read-only version of the MCP server](#read-only-remote-mcp-server) is also available.

- There is no need to install or upgrade any software. Since the remote MCP server undergoes frequent updates, you get access to new features and fixes automatically.

#### What it's not suitable for

The remote MCP server is not suitable for use in automated workflows, where running a specific version of the MCP server is important for generating consistent results.

<h4 id="read-only-remote-mcp-server">Read-only remote MCP server</h4>

Buildkite also provides a version of the remote MCP server with read-only access to the Buildkite platform. This version is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp/readonly
```

This remote MCP server version issues a short-lived OAuth access token for your Buildkite user account, along with _read-only_ access permission scopes pre-set by the Buildkite platform. Hence, when using this remote MCP server, only [MCP tools](/docs/apis/mcp-server/tools#available-mcp-tools) whose required [token scope](/docs/apis/managing-api-tokens#token-scopes) begins with `read_` are available, as well as tools with no required scope specified.

> 📘
> Read-only access can also be configured using the standard [remote MCP server URL](#types-of-mcp-servers-remote-mcp-server), by configuring the MCP server to send `X-Buildkite-Readonly: true` in the header of requests to the Buildkite platform. Learn more about this in [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools) and [Remote MCP server configuration for toolsets](/docs/apis/mcp-server/tools/toolsets#configuring-the-remote-mcp-server).

### Local MCP server

The _local_ MCP server is one that you install yourself directly on your own machine or in a containerized environment.

This type of MCP server is typically used by AI tools as _AI agents_, which an automated system or workflow, such as a Buildkite pipeline, can interact with. Such AI agent interactions are usually shell-based.

#### What it's suitable for

The local MCP server enables automated workflows (for example, using [Buildkite Pipelines](/docs/pipelines)), where running a specific version of the MCP server is important for generating consistent results.

Also, if you want to contribute to the [Buildkite MCP server project](https://github.com/buildkite/buildkite-mcp-server), the local MCP server allows you to run and test your changes locally.

#### What it's not suitable for

The local MCP server is not suitable for personal usage with an AI tool, as it has the following disadvantages.

- Since your Buildkite API access token is used for authentication and authorization to the MCP server, you'll need to manage the security (for example, leak prevention) of this token and its storage in plain text.

- You'll also need to manage upgrades to the MCP server yourself, especially if you choose to install the binary version of the local MCP server, which means you may miss out on new and updated features offered automatically through the [remote MCP server](#types-of-mcp-servers-remote-mcp-server).

If you intend to use the local Buildkite MCP server, learn more about how to set up and install it in [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing).
