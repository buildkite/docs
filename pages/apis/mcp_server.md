# Buildkite MCP server overview

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect artificial intelligence (AI) tools, agents and models to a variety of other systems and data sources.

Buildkite provides its own [open-source MCP server](https://github.com/buildkite/buildkite-mcp-server) to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, including test data for Test Engine) for AI tools, editors, agents, and other products to interact with.

Buildkite's MCP server is built on and interacts with the [Buildkite REST API](/docs/apis/rest-api). Learn more about what the MCP server is capable of in the [MCP tools overview](/docs/apis/mcp-server/tools).

When Buildkite Pipelines jobs use [promise job failure](/docs/pipelines/configure/promise-job-failure), the MCP server can help AI agents react before the job finishes. A job can still be `running` while it has declared a promised failure and caused the build to enter `failing`. Agents should treat this as a promised failure signal, start investigating, and then check the final job result later for any additional logs, artifacts, or test results.

To start using Buildkite's MCP server, first determine which [type of Buildkite MCP server](#types-of-mcp-servers) to work with. This next section provides an overview of the differences between these MCP server types and how they need to be configured.

Once you have established which Buildkite MCP server to use (remote or local) and if local, have [installed the MCP server](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally) and [configured its API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token), you can then proceed to configure your AI tools to work with the [remote](/docs/apis/mcp-server/remote/configuring-ai-tools) (recommended) or [local](/docs/apis/mcp-server/local/configuring-ai-tools) MCP server.

> 📘 Remote MCP server rate limits
> Requests made through the remote Buildkite MCP server count against a separate rate limit from your Buildkite organization's REST API rate limit. See [Platform and organization-level limits](/docs/platform/limits#platform-and-organization-level-limits) for specific values.

## Choose a client and access method

The MCP tools available to an AI client are the same when it connects to the same endpoint with the same toolsets and permissions. Choose a client based on where you work and how you want to manage the connection.

Client or access method | Best suited for | Trade-offs
--- | --- | ---
[Claude Code](/docs/apis/mcp-server/remote/configuring-ai-tools#claude-code) | Interactive terminal-based coding workflows | Uses remote OAuth and requires a browser when first authorizing or re-authenticating
[Codex](/docs/apis/mcp-server/remote/configuring-ai-tools#codex) | Interactive terminal or editor-based coding workflows | Uses remote OAuth and requires a browser when first authorizing or re-authenticating
[Visual Studio Code](/docs/apis/mcp-server/remote/configuring-ai-tools#visual-studio-code) | Developers who want Buildkite context in their editor | MCP availability and prompts are tied to the editor and its AI extension
[Cursor](/docs/apis/mcp-server/remote/configuring-ai-tools#cursor) | Developers who want Buildkite MCP tools and Buildkite skills installed together | The marketplace plugin manages more than the MCP connection. Install only the MCP server if you do not want the accompanying skills
[Local MCP server](/docs/apis/mcp-server/local/installing) | Automated workflows, pinned MCP server versions, or environments that cannot use interactive OAuth | Requires an API access token, consumes the organization's REST API quota, and leaves upgrades and credential storage to you
Remote [API token pass-through](#api-token-pass-through-remote-mcp-server) | Headless agents, background services, and customer-managed MCP gateways | Avoids browser re-authentication, but requires secure API token storage, rotation, and revocation
{: class="responsive-table"}

For interactive personal use, start with the remote OAuth endpoint. Use the [read-only endpoint](#read-only-remote-mcp-server) unless the client needs to create, update, retry, or cancel resources. For a headless workflow, use API token pass-through or run the local MCP server with a narrowly scoped API access token.

## Types of MCP servers

Buildkite provides both a [remote](#types-of-mcp-servers-remote-mcp-server) and [local](#types-of-mcp-servers-local-mcp-server) MCP server, both of which provide access to its [MCP server tools](/docs/apis/mcp-server/tools#available-mcp-tools). The remote MCP server supports OAuth authentication for interactive AI tools and [API token pass-through](#api-token-pass-through-remote-mcp-server) for headless agents.

### Remote MCP server

The _remote_ MCP server is one that Buildkite hosts, and is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp
```

The OAuth-based remote MCP server at this URL is typically used by AI tools that you interact with directly from a prompt, and it's the recommended MCP server type to use.

#### What it's suitable for and advantages

The OAuth-based remote MCP server is suitable for personal usage with an AI tool, as it has the following advantages.

- You don't need to configure an API access token, which poses a potential security risk if leaked.

    Instead, you only require your Buildkite user account, and the Buildkite platform issues a short-lived OAuth access token, representing your user account for authentication, along with both _read_ and _write_ access permission scopes which are pre-set by the Buildkite platform to provide the authorization. This OAuth token auth process takes place after [configuring your AI tool with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools) and connecting to it.

    **Notes:**
    * OAuth access tokens are valid for 12 hours, and the refresh tokens are valid for seven days.
    * These OAuth access tokens provide both read and write access to the remote MCP server. If you'd prefer to restrict your access to read-only, a [read-only version of the MCP server](#read-only-remote-mcp-server) is also available.

- There is no need to install or upgrade any software. Since the remote MCP server undergoes frequent updates, you get access to new features and fixes automatically.

- The remote MCP server has a separate rate limit usage quota to your [Buildkite organization's REST API](/docs/apis/rest-api/rate-limits). See [Remote MCP server rate limits](/docs/apis/mcp-server/remote/rate-limits).

#### What it's not suitable for

The OAuth-based remote MCP server is not suitable for automated workflows that cannot complete interactive OAuth. For workflows where running a specific version of the MCP server is important for generating consistent results, use the [local MCP server](#types-of-mcp-servers-local-mcp-server).

<h4 id="api-token-pass-through-remote-mcp-server">API token pass-through remote MCP server</h4>

Buildkite also provides a version of the remote MCP server for headless agents and background services that already have a [Buildkite API access token](/docs/apis/managing-api-tokens). This version is available at the following URL:

```url
https://mcp.buildkite.com/direct
```

This remote MCP server version accepts the API access token in an `Authorization: Bearer <buildkite-api-token>` header. The token is forwarded to the Buildkite REST API, and the token scopes determine which MCP tool calls can complete successfully.

Use this endpoint only for agents or services that cannot complete the interactive OAuth flow. For prompt-based AI tools, use the OAuth-based remote MCP server at `https://mcp.buildkite.com/mcp`.

> 📘
> The API token pass-through endpoint supports the same [toolsets](/docs/apis/mcp-server/tools/toolsets) and read-only routing options as the OAuth-based remote MCP server. Learn more in [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents).

<h4 id="read-only-remote-mcp-server">Read-only remote MCP server</h4>

Buildkite also provides a version of the remote MCP server with read-only access to the Buildkite platform. This version is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp/readonly
```

This remote MCP server version issues a short-lived OAuth access token for your Buildkite user account, along with _read-only_ access permission scopes pre-set by the Buildkite platform. Hence, when using this remote MCP server, only [MCP tools](/docs/apis/mcp-server/tools#available-mcp-tools) whose required [token scope](/docs/apis/managing-api-tokens#token-scopes) begins with `read_` are available, as well as tools with no required scope specified.

> 📘
> Read-only access can also be configured in a similar manner for [toolsets](/docs/apis/mcp-server/tools/toolsets). Learn more about this in [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools) and [Remote MCP server configuration for toolsets](/docs/apis/mcp-server/tools/toolsets#configuring-the-remote-mcp-server).

### Local MCP server

The _local_ MCP server is one that you install yourself directly on your own machine or in a containerized environment.

This type of MCP server is typically used by AI tools as _AI agents_, which an automated system or workflow, such as a Buildkite pipeline, can interact with. Such AI agent interactions are usually shell-based.

#### What it's suitable for

The local MCP server enables automated workflows (for example, using [Buildkite Pipelines](/docs/pipelines)), where running a specific version of the MCP server is important for generating consistent results.

Also, if you want to contribute to the [Buildkite MCP server project](https://github.com/buildkite/buildkite-mcp-server), the local MCP server allows you to run and test your changes locally.

#### What it's not suitable for and disadvantages

The local MCP server is not suitable for personal usage with an AI tool, as it has the following disadvantages.

- Since your Buildkite API access token is used for authentication and authorization to the MCP server, you'll need to manage the security (for example, leak prevention) of this token and its storage in plain text.

- You'll also need to manage upgrades to the MCP server yourself, especially if you choose to install the binary version of the local MCP server, which means you may miss out on new and updated features offered automatically through the [remote MCP server](#types-of-mcp-servers-remote-mcp-server).

- Unlike the [remote MCP server](#types-of-mcp-servers-remote-mcp-server), requests made through the local MCP server count towards your Buildkite organization's standard [REST API rate limit](/docs/apis/rest-api/limits).

If you intend to use the local Buildkite MCP server, learn more about how to set up and install it in [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing).

## How remote OAuth works

When an interactive client connects to `https://mcp.buildkite.com/mcp`, the client opens the Buildkite authorization flow. You log in, select one Buildkite organization, review the requested scopes, and authorize the connection. If the organization requires SSO, complete SSO before authorizing.

The resulting access is limited to the selected organization, your Buildkite user permissions, and the approved API scopes. MCP tools make Buildkite REST API requests with those credentials. The MCP server does not bypass the normal Buildkite authorization model.

The OAuth access token is valid for 12 hours. The client should use the refresh token to renew access without opening a browser. The refresh token is valid for seven days and rotates when used. You need to complete the browser authorization again when the refresh token expires or can no longer be used. Re-authentication is also required after you revoke the application, lose access to the selected organization, or when the client loses its stored OAuth credentials.

If a client disconnects after 12 hours, do not repeatedly retry its failed tool calls. Reconnect the MCP server or run the client's OAuth login action. A disconnect at the access-token boundary usually means the client did not refresh its credentials successfully.

### Revoke OAuth access

If you no longer use a client or suspect its OAuth credentials were exposed:

1. Open [**Connected Apps**](https://buildkite.com/user/connected-apps) in your personal settings.
1. Find **Buildkite MCP Server** under **Authorized Applications** and select **Details** to verify its organization, permissions, and recent use.
1. Select **Revoke**.

Revoking the application removes the OAuth grant and its associated access and refresh tokens. The client cannot make more API requests until you authorize it again.

## Use an API access token for durable authentication

API access tokens are suitable for headless agents, background services, and MCP gateways that cannot complete browser-based OAuth. Set the expiry when you [create the API access token](/docs/apis/managing-api-tokens#creating-and-editing-api-access-tokens-create-an-api-access-token), and rotate it before that expiry. The token remains valid until it expires or is revoked, and does not depend on an OAuth refresh session.

Send the token to `https://mcp.buildkite.com/direct` as described in [API token pass-through for headless agents](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents), or use it with a [local MCP server](/docs/apis/mcp-server/local/installing). Use a separate token for each agent or gateway, select only the scopes its tools require, and prefer read-only access when the workflow does not need to change Buildkite resources.

An API access token is a long-lived bearer credential. Anyone who obtains it can act with its user, organization, and scopes until it expires or is revoked. Store it in a secret manager rather than a repository, client configuration file, prompt, or log. Customer-managed gateways should keep the token on the gateway and apply their own user authorization, audit, and rate-limit controls instead of distributing it to downstream clients.

To revoke a leaked API access token, open [**API Access Tokens**](https://buildkite.com/user/api-access-tokens) in your personal settings and revoke the token. Buildkite organization administrators can instead [remove the organization's access from the token](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token). Stop affected agents before replacing the credential to prevent repeated unauthorized requests.

## Example workflows

Start with a read-only connection and a narrowly scoped task. The following examples show prompts and the access they require.

- **Investigate recent failures:** Ask, "Find failed builds for `example-pipeline` from the last 24 hours, summarize the failing jobs, and inspect their logs for a common cause." This requires the `pipelines`, `builds`, and `logs` toolsets with `read_pipelines`, `read_builds`, and `read_build_logs` scopes.
- **Check agent and queue health:** Ask, "Show disconnected agents and queues with waiting jobs, then identify where capacity may be blocked." This requires the `agents`, `clusters`, and `builds` toolsets with `read_agents`, `read_clusters`, and `read_builds` scopes.
- **Review test failures:** Ask, "For the latest failed build of `example-pipeline`, summarize failed tests and group repeated failures." This requires the `builds` and `tests` toolsets with `read_builds` and `read_suites` scopes. Add the `logs` toolset and `read_build_logs` scope if the client also needs job logs.
- **Retry a failed build:** First ask the client to explain which build it proposes to retry. After reviewing the answer, ask it to retry that build. This requires the `builds` toolset with `read_builds` and `write_builds` scopes. Write access lets the client change Buildkite resources, so require confirmation in the client or gateway where supported.

See the [MCP tools overview](/docs/apis/mcp-server/tools) for each tool's required scope and [toolsets](/docs/apis/mcp-server/tools/toolsets) for restricting which tools a client can use.
