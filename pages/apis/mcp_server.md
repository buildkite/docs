# Buildkite MCP server overview

The [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) is an open protocol standard on how to connect artificial intelligence (AI) tools, agents and models to a variety of other systems and data sources.

Buildkite provides its own [open-source MCP server](https://github.com/buildkite/buildkite-mcp-server) to expose Buildkite product data (for example, data from pipelines, builds, and jobs for Pipelines, including test data for Test Engine) for AI tools, editors, agents, and other products to interact with.

Buildkite's MCP server is built on and interacts with the [Buildkite REST API](/docs/apis/rest-api). Learn more about what the MCP server is capable of in the [MCP tools overview](/docs/apis/mcp-server/tools).

When Buildkite Pipelines jobs use [promise job failure](/docs/pipelines/configure/promise-job-failure), the MCP server can help AI agents react before the job finishes. A job can still be `running` while it has declared a promised failure and caused the build to enter `failing`. Agents should treat this as a promised failure signal, start investigating, and then check the final job result later for any additional logs, artifacts, or test results.

To start using Buildkite's MCP server, first determine which [type of Buildkite MCP server](#types-of-mcp-servers) to work with. This next section provides an overview of the differences between these MCP server types and how they need to be configured.

Once you have established which Buildkite MCP server to use (remote or local) and if local, have [installed the MCP server](/docs/apis/mcp-server/local/installing#install-and-run-the-server-locally) and [configured its API access token](/docs/apis/mcp-server/local/installing#configure-an-api-access-token), you can then proceed to configure your AI tools to work with the [remote](/docs/apis/mcp-server/remote/configuring-ai-tools) (recommended) or [local](/docs/apis/mcp-server/local/configuring-ai-tools) MCP server.

> 📘 Remote MCP server rate limits
> Requests made through the OAuth-based remote Buildkite MCP server count against a separate rate limit from your Buildkite organization's REST API rate limit. See [Platform and organization-level limits](/docs/platform/limits#platform-and-organization-level-limits) for specific values.

## What you can do with the MCP server

The Buildkite MCP server lets an AI tool investigate and manage your CI work from the same conversation where you develop code. After connecting your AI tool, explicitly ask it to use Buildkite. Connecting the server alone does not make the AI tool monitor builds.

The following prompts are starting points. Replace the example organization, pipeline, branch, and build number with your own values, or provide a build URL. These investigation workflows can use [read-only access](#read-only-remote-mcp-server). If you restrict [toolsets](/docs/apis/mcp-server/tools/toolsets), include the ones each workflow needs. If you connect with an [API access token](#use-an-api-access-token-for-durable-authentication) instead of OAuth, grant the corresponding read scopes.

### Watch a pull request build

Ask your AI tool to follow a build while you continue working:

```text
Use the Buildkite MCP server to wait for build 123 in example-org/example-pipeline to finish. If it fails or gets blocked, summarize why with links. Use only read-only calls.
```

If your AI tool already has the build URL in context, you can also ask:

```text
Babysit this build.
```

Use the longer prompt when you need to specify read-only calls. The shorter request alone does not restrict what the AI tool can do.

The `wait_for_build` tool polls for up to 45 seconds per call and can spend up to 10 more seconds fetching annotations after a build settles. It treats a blocked build as finished so the AI tool can report that it needs input. The tool uses the `builds` toolset and requires `read_builds`. To follow up with logs, include the `logs` toolset and `read_build_logs` scope. To keep watching beyond one call, the AI tool must call again or use its own scheduling or event mechanism.

### Investigate a failure

Ask for evidence before deciding whether to change code or retry a job:

```text
Use the Buildkite MCP server to investigate failed build 123 in example-org/example-pipeline. Tell me the likely cause with links to the evidence, and say if any logs or test results are missing. Use only read-only calls.
```

The `get_build_failure_summary` tool gathers problem jobs, log tails, error and warning annotations, and available failed tests in one call. Its results can be partial, so check for missing or truncated evidence before drawing conclusions. The tool uses the `investigations` toolset and requires `read_builds`, `read_build_logs`, and `read_suites`. Include `builds`, `logs`, `annotations`, or `tests` as needed for deeper follow-up calls.

### Query pipeline state

Ask for a summary instead of opening each pipeline's build page:

```text
Use the Buildkite MCP server to list recent builds on main in example-org/example-pipeline. Summarize their states with links, and check each build's details to flag any that are blocked. Use only read-only calls.
```

For this query, the AI tool can use the build and job tools. You can also request actions such as retrying a failed job or starting a build when write access is enabled. These tools require the `write_builds` scope, which the read-only endpoints don't grant. These actions change state and can run pipeline commands, including deployments. Review the proposed action before approving it, and configure your AI tool or gateway to require approval for writes. See [Tool annotations and access control](/docs/apis/mcp-server/tools#tool-annotations-and-access-control).

## Choose a client and access method

The MCP tools available to an AI client are the same when it connects to the same endpoint with the same toolsets and permissions. Choose a client based on where you work and how you want to manage the connection.

Client or access method | Best suited for | Trade-offs
--- | --- | ---
[Claude Code](/docs/apis/mcp-server/remote/configuring-ai-tools#claude-code) | Interactive terminal-based coding workflows | Uses remote OAuth and requires a browser when first authorizing or re-authenticating
[Codex](/docs/apis/mcp-server/remote/configuring-ai-tools#codex) | Interactive terminal or editor-based coding workflows | Uses remote OAuth and requires a browser when first authorizing or re-authenticating
[Visual Studio Code](/docs/apis/mcp-server/remote/configuring-ai-tools#visual-studio-code) | Developers who want Buildkite context in their editor | MCP availability and prompts are tied to the editor and its AI extension
[Cursor](/docs/apis/mcp-server/remote/configuring-ai-tools#cursor) | Developers who want Buildkite MCP tools and Buildkite skills installed together | The marketplace plugin manages more than the MCP connection. Install only the MCP server if you do not want the accompanying skills
[Local MCP server](/docs/apis/mcp-server/local/installing) | Automated workflows, pinned MCP server versions, or environments that cannot use interactive OAuth | Requires an API access token, consumes the organization's REST API quota, and leaves upgrades and credential storage to you
Remote [API token pass-through](#api-token-pass-through-remote-mcp-server) | Headless agents, background services, and customer-managed MCP gateways | Avoids browser re-authentication, but requires secure API token storage, rotation, and revocation, and consumes the organization's REST API quota
{: class="responsive-table"}

For interactive personal use, start with the remote OAuth endpoint. Use the [read-only endpoint](#read-only-remote-mcp-server) unless the client needs to create, update, retry, or cancel resources. For a headless workflow, use API token pass-through or run the local MCP server with a narrowly scoped API access token.

### MCP server or Buildkite CLI

AI agents with shell access can also use the [Buildkite CLI](/docs/platform/cli) (`bk`), and some [Buildkite skills](/docs/platform/ai-agents#build-with-agents-skills), such as those for [preflight builds](/docs/platform/cli/preflight), run CLI commands. Both the CLI and the MCP server respect the Buildkite user's permissions and the credential's API scopes. Both can use OAuth instead of a stored API access token.

- Use the remote MCP server when you want to avoid distributing API access tokens to agent environments, and to restrict a connection with the [read-only endpoint](#read-only-remote-mcp-server) and [toolsets](/docs/apis/mcp-server/tools/toolsets).
- Use the CLI when a skill or workflow requires it. Authenticate with [`bk auth login`](/docs/platform/cli/configuration#authenticate-using-oauth) and use its `--scopes` option to request only the scopes the workflow needs.

If an agent can use both, each path uses its own credentials, and a read-only MCP connection doesn't restrict the CLI. Restrict every credential available to the agent, as described in [Read-only access boundaries](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries).

## Types of MCP servers

Buildkite provides both a [remote](#types-of-mcp-servers-remote-mcp-server) and [local](#types-of-mcp-servers-local-mcp-server) MCP server, both of which provide access to its [MCP server tools](/docs/apis/mcp-server/tools#available-mcp-tools). The remote MCP server supports OAuth authentication for interactive AI tools and [API token pass-through](#api-token-pass-through-remote-mcp-server) for headless agents.

The Buildkite MCP server is under active development. Tools or their behavior may change or be removed, including breaking changes. If you need continued access to a specific tool or behavior, [run the local server](/docs/apis/mcp-server/local/installing) with a versioned Docker image tag or a binary from a specific release. For Docker, replace `buildkite/mcp-server` with `buildkite/mcp-server:<version>` in both the run command and your AI tool configuration. Buildkite-hosted remote endpoints update automatically and cannot be pinned to a version.

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
    * MCP access tokens last up to one hour, and refresh tokens last up to 30 days. Clients that support refresh can renew credentials without another interactive login. See [OAuth for remote MCP and the Buildkite CLI](/docs/platform/security/oauth) for token lifetimes, security testing, and audit visibility.
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

Requests made with a personal API token or a token issued by your token exchange application count toward [standard REST API limits](/docs/apis/rest-api/rate-limits), not the separate [MCP rate limit](/docs/apis/mcp-server/remote/rate-limits).

Use this endpoint only for agents or services that cannot complete the interactive OAuth flow. It also avoids contention when multiple background agents would otherwise share OAuth tokens. For prompt-based AI tools, use the OAuth-based remote MCP server at `https://mcp.buildkite.com/mcp`.

> 📘
> The API token pass-through endpoint supports the same [toolsets](/docs/apis/mcp-server/tools/toolsets) and read-only routing options as the OAuth-based remote MCP server. Learn more in [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents).

<h4 id="read-only-remote-mcp-server">Read-only remote MCP server</h4>

Buildkite also provides a version of the remote MCP server with read-only access to the Buildkite platform. This version is available for all users to access at the following URL:

```url
https://mcp.buildkite.com/mcp/readonly
```

This remote MCP server version issues a short-lived OAuth access token for your Buildkite user account, along with _read-only_ access permission scopes pre-set by the Buildkite platform. Hence, when using this remote MCP server, only [MCP tools](/docs/apis/mcp-server/tools#available-mcp-tools) whose required [token scope](/docs/apis/managing-api-tokens#token-scopes) begins with `read_` are available, as well as tools with no required scope specified.

> 🚧 Read-only access is not a sandbox
> Read-only MCP access restricts this connection, not the AI agent's other tools or credentials. An AI agent with shell access and a separately authenticated `bk` CLI can still make changes using the permissions of that CLI session. See [Read-only access boundaries](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries) for how to restrict these other access paths.

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

- Unlike requests using remote MCP OAuth credentials, requests made through the local MCP server with a personal API token count toward [standard REST API limits](/docs/apis/rest-api/rate-limits).

If you intend to use the local Buildkite MCP server, learn more about how to set up and install it in [Installing the Buildkite MCP server](/docs/apis/mcp-server/local/installing).

## How remote OAuth works

When an interactive client first connects to `https://mcp.buildkite.com/mcp`, it opens the **Connect with Buildkite MCP Server** page in your browser. Sign in to Buildkite if prompted, select the Buildkite organization to connect, review the requested scopes, and select **Authorize**. If the organization requires SSO, complete SSO before authorizing. Buildkite then shows a confirmation page with the client's name and redirect URL, so you can confirm that the request came from the client you expected before returning to it.

Each authorization is limited to the selected organization, your Buildkite user permissions, and the approved API scopes. To use more than one organization, [add a separate MCP connection for each one](/docs/apis/mcp-server/remote/configuring-ai-tools#connect-to-multiple-organizations). MCP tools make Buildkite REST API requests with these credentials, so the MCP server does not bypass the normal Buildkite authorization model.

### Session lifetime and re-authentication

Remote MCP access tokens last up to one hour, and refresh tokens last up to 30 days. A client that supports refresh can renew credentials without opening a browser. The client must save the replacement refresh token and use it for the next refresh. The underlying Buildkite authorization can expire sooner. See [Token lifetime and refresh](/docs/platform/security/oauth#token-lifetime-and-refresh).

You need to authorize the client again in the browser when:

- The client's refresh token has expired.
- You [revoke the client's access](#revoke-access-revoke-oauth-access).
- You lose access to the selected organization.
- The client loses its stored OAuth credentials, for example, after you remove and re-add the MCP server or clear the client's credential cache.
- The client keeps using a replaced refresh token after the reuse grace period and no longer has a valid replacement. This can happen when several processes share one set of OAuth credentials. Use [API token pass-through](#api-token-pass-through-remote-mcp-server) for background agents instead.

If a client disconnects about an hour after authorizing, or asks you to authorize again repeatedly, the client might not be refreshing its credentials successfully. Stop retrying the failed tool calls, update the client to its latest version, and reconnect the MCP server or run the client's OAuth login action. See [Recovering from authentication errors](/docs/apis/mcp-server/remote/rate-limits#recovering-from-authentication-errors) for more troubleshooting steps.

## Use an API access token for durable authentication

API access tokens are suitable for headless agents, background services, and MCP gateways that cannot complete browser-based OAuth. They also avoid contention caused by multiple background agents sharing OAuth tokens. Set the expiry when you [create the API access token](/docs/apis/managing-api-tokens#creating-and-editing-api-access-tokens-create-an-api-access-token), and rotate it before that expiry. The token remains valid until it expires or is revoked, and does not depend on an OAuth refresh session.

Send the token to `https://mcp.buildkite.com/direct` as described in [API token pass-through for headless agents](/docs/apis/mcp-server/remote/configuring-ai-tools#api-token-pass-through-for-headless-agents), or use it with a [local MCP server](/docs/apis/mcp-server/local/installing). Use a separate token for each agent or gateway, select only the scopes its tools require, and prefer read-only access when the workflow does not need to change Buildkite resources.

An API access token is a long-lived bearer credential. Anyone who obtains it can act with its user, organization, and scopes until it expires or is revoked. Store it in a secret manager rather than a repository, client configuration file, prompt, or log. Customer-managed gateways should keep the token on the gateway and apply their own user authorization, audit, and rate-limit controls instead of distributing it to downstream clients.

## Revoke access

Where you revoke access depends on how the client authenticates. If you're not sure which credential a client uses, check both locations.

### Revoke OAuth access

OAuth sessions for the remote MCP server and the [Buildkite CLI](/docs/platform/cli/configuration#authenticate-using-oauth) are managed on the **Connected Apps** page. To revoke one:

1. Open [**Connected Apps**](https://buildkite.com/user/connected-apps) in your personal settings.
1. Under **Authorized Applications**, find the application, such as **Buildkite MCP Server**.
1. Select **Revoke** and confirm.

Revoking an application removes its OAuth grant, along with its access and refresh tokens. The client cannot make more API requests until you authorize it again.

### Revoke an API access token

API access tokens used with the [API token pass-through endpoint](#api-token-pass-through-remote-mcp-server), a [local MCP server](/docs/apis/mcp-server/local/installing), or a gateway are managed on the **API Access Tokens** page. To revoke one:

1. Open [**API Access Tokens**](https://buildkite.com/user/api-access-tokens) in your personal settings.
1. Find the token and select **Revoke**, then confirm.

Buildkite organization administrators can instead [remove the organization's access from the token](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token). Stop affected agents before replacing the credential to prevent repeated unauthorized requests.
