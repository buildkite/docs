# OAuth for remote MCP and the Buildkite CLI

The [remote Buildkite MCP server](/docs/apis/mcp-server) and [Buildkite CLI](/docs/platform/cli) support OAuth. OAuth lets you authorize an application to access Buildkite on your behalf without manually creating and copying an API access token. You log in to Buildkite, select an organization, and approve the requested permissions.

This page explains how authorization and token refresh work, the security testing that covers remote MCP, and what administrators can see in the audit log.

## Authorize access

Both remote MCP and the CLI limit access to the authorized organization, granted [API scopes](/docs/apis/managing-api-tokens#token-scopes), and your user permissions. OAuth does not give an application more access than your Buildkite account has. If the organization requires [SSO](/docs/platform/sso), you must complete SSO before authorizing access.

### Remote MCP

Configure an OAuth-capable AI tool with the hosted endpoint:

```url
https://mcp.buildkite.com/mcp
```

When you connect, the AI tool opens the Buildkite authorization page. Select your organization, review the requested permissions, and select **Authorize**.

Remote MCP handles two related authorizations: your AI tool connects to the hosted MCP server, and the server uses your Buildkite authorization to make API requests. The credentials your AI tool receives are for the MCP connection, not for calling the Buildkite API directly. Both authorizations must remain valid for tool calls to succeed.

For workflows that only need read access, use the dedicated read-only endpoint:

```url
https://mcp.buildkite.com/mcp/readonly
```

This endpoint restricts the available tools and requested API scopes. A read-only label in your AI tool is not a substitute for configuring the read-only endpoint. Other credentials available to the AI tool, such as a separately authenticated CLI, retain their own permissions. See [Read-only access boundaries](/docs/apis/mcp-server/remote/configuring-ai-tools#read-only-access-boundaries).

For client setup and connections to multiple organizations, see [Configuring AI tools with the remote MCP server](/docs/apis/mcp-server/remote/configuring-ai-tools).

### Buildkite CLI

Start browser-based authorization with:

```bash
bk auth login
```

The CLI opens your browser so you can log in to Buildkite, select an organization, and authorize access. The CLI exchanges the authorization code for credentials and stores them locally. Unlike remote MCP, the CLI connects directly to Buildkite OAuth and the Buildkite API.

The browser flow uses Proof Key for Code Exchange (PKCE). PKCE binds the authorization-code exchange to the CLI login attempt that started it, without requiring a secret embedded in the CLI executable.

By default, the CLI requests all available REST API scopes. To request only read access, use:

```bash
bk auth login --scopes "read_only"
```

For a headless machine or remote shell, `bk auth login --device` lets you complete authorization in a browser on another device. Device login does not create the [OAuth authorization audit event](#audit-visibility).

For configuration options, see [Buildkite CLI configuration](/docs/platform/cli/configuration).

## Token lifetime and refresh

OAuth uses a short-lived _access token_ to authorize requests and a _refresh token_ to obtain replacement credentials without another interactive login.

Remote MCP access tokens last up to one hour, and refresh tokens last up to 30 days. These are the MCP-facing token lifetimes, not the lifetimes for every Buildkite OAuth application or the CLI. The underlying Buildkite authorization can shorten their validity.

An access token expiring does not mean you must log in again. An MCP client that supports refresh can renew its credentials automatically. The CLI also supports automatic refresh. Refresh replaces credentials, so the client must save the replacements in a credential store it can write to.

You may need to authorize access again if a refresh token expires, access is revoked, organization membership changes, or the client cannot refresh or save replacement credentials. Refresh does not guarantee an unlimited session.

If an AI tool appears connected but Buildkite tool calls fail, its Buildkite authorization may still need renewal. When reporting authentication problems, include the client and version, authentication method, organization, error message, and approximate time. Do not include tokens, authorization codes, or secrets.

## Revoke access

To revoke an OAuth application's access, open [**Connected Apps**](https://buildkite.com/user/connected-apps) in your personal settings and revoke the connection. This invalidates the associated Buildkite access and refresh tokens.

Running `bk auth logout` removes locally stored CLI credentials. It does not revoke the authorization in Buildkite. Use **Connected Apps** when you need to revoke access rather than only remove credentials from one machine.

## API token authentication

The remote MCP [API token pass-through endpoint](/docs/apis/mcp-server#api-token-pass-through-remote-mcp-server), local MCP server, and CLI can also use an existing API access token instead of OAuth. These connections do not use OAuth refresh and do not create the OAuth authorization audit event described below. Manage their scopes, storage, expiry, and revocation separately. See [Managing API access tokens](/docs/apis/managing-api-tokens).

## Security testing

The remote Buildkite MCP server is included in the Buildkite SOC 2 Type II scope and undergoes external penetration testing every six months.

For security assurance documents, including SOC 2 and penetration-test reports, visit the [Buildkite Trust Center](https://trust.buildkite.com/). Access to reports may require approval or a non-disclosure agreement.

## Audit visibility

Successful browser-based OAuth authorization for remote MCP and the CLI creates an organization-scoped `OAUTH_APPLICATION_AUTHORIZED` event. Buildkite records this event when the application successfully exchanges an authorization code for credentials, not whenever a client starts or reconnects.

Organization administrators on the Enterprise plan can view these events in the [**Audit Log**](/docs/platform/audit-log). Select **Settings** > **Audit** > **Audit Log**, then search the **Events** tab for `type:OAUTH_APPLICATION_AUTHORIZED`.

The event identifies the authorizing user, application, organization, and granted scopes. It also includes the IP address and user agent captured during authorization.

This event records who granted access, not ongoing usage. Device login, token refresh, and API-token authentication do not create this event. It is not a record of every CLI command or MCP tool call, or a list of active sessions. The absence of an authorization event does not establish that nobody is using MCP or the CLI.
