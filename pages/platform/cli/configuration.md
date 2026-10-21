# Buildkite CLI configuration

The Buildkite CLI uses both the [REST](/docs/apis/rest-api) and [GraphQL](/docs/apis/graphql-api) APIs to interact with Buildkite. You can authenticate using OAuth or configure an API access token.

## Authenticate using OAuth

You can authenticate the Buildkite CLI using OAuth with the [`bk auth login`](/docs/platform/cli/reference/auth#login-auth) command, which opens your browser to complete the authentication flow.

For how authorization, token refresh, revocation, and audit events work, see [OAuth for remote MCP and the Buildkite CLI](/docs/platform/security/oauth).

> 🚧 Logging in fails when the organization has no active plan
> After you authorize the CLI, `bk auth login` looks up organizations through the REST API. The API omits an organization whose evaluation trial has ended and no plan is selected. The CLI then reports `no organizations found for this token`, even if you selected the organization in the browser.
> This isn't a restriction of the Free plan. Choose a plan, including the Free plan, on the organization's billing page, then run `bk auth login` again. See [Organizations API](/docs/apis/rest-api/organizations).

By default, `bk auth login` requests all available REST API scopes. The Buildkite platform enforces server-side restrictions. The issued token only grants permissions that your Buildkite user account actually has. The `graphql` scope is excluded from this process due to its unscoped nature.

To restrict the scopes requested during OAuth login, use the `--scopes` flag. For example, `--scopes "read_only"` requests only read access. You can also combine scope groups with individual scopes, such as `--scopes "read_only write_builds"`. Learn more about available scopes in [Token scopes](/docs/apis/managing-api-tokens#token-scopes).

> 📘 Restricting CLI token scopes
> For organizations that enforce the principle of least privilege, use `--scopes` to issue CLI tokens with only the minimum scopes required. Without `--scopes`, the token is issued with all scopes that your account has permission for.

To preselect an organization during OAuth login, use the `--org` flag. This also works with device authorization on a headless machine or remote shell:

```bash
bk auth login --device --org my-org
```

The organization is a hint. You can select another available organization on the authorization page before approving the request.

## Create an API access token for the Buildkite CLI

To create a new API access token:

1. Select your user profile icon > [**Personal Settings**](https://buildkite.com/user/settings) in the global navigation.

1. Select **API Access Tokens** to access your [**API Access Tokens**](https://buildkite.com/user/api-access-tokens) page.

1. Select **New API Access Token** to open the [**New API Access Token**](https://buildkite.com/user/api-access-tokens/new) page.

1. Specify a **Description** and the **Organization Access** (that is, the specific Buildkite organization) for this token.

1. Select the **REST API Scopes** required by your commands. Select **Enable GraphQL API access** only if your commands need GraphQL. Create the token and retain its value in a secure location.

You can also use the following **New API Access Token** page links with pre-set fields to create these API access tokens:

- [New API access token with description](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI)—pre-sets the **Description** field with `Buildkite CLI`.

- [New API access token with description and API scopes](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI&scopes%5B%5D=read_agents&scopes%5B%5D=write_agents&scopes%5B%5D=read_clusters&scopes%5B%5D=write_clusters&scopes%5B%5D=read_teams&scopes%5B%5D=write_teams&scopes%5B%5D=read_artifacts&scopes%5B%5D=write_artifacts&scopes%5B%5D=read_builds&scopes%5B%5D=write_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_organizations&scopes%5B%5D=read_pipelines&scopes%5B%5D=write_pipelines&scopes%5B%5D=read_user&scopes%5B%5D=read_suites&scopes%5B%5D=write_suites&scopes%5B%5D=read_registries&scopes%5B%5D=write_registries&scopes%5B%5D=delete_registries&scopes%5B%5D=read_packages&scopes%5B%5D=write_packages&scopes%5B%5D=delete_packages&scopes%5B%5D=graphql)—pre-sets the **Description** field with `Buildkite CLI`, along with REST API scopes and GraphQL access. Review these permissions and select only the scopes your commands require.

If you use one of these links, you must still specify the Buildkite organization (in **Organization Access**) for this API access token.

## Configure the Buildkite CLI with your API access token

After you have [created your API access token](#create-an-api-access-token-for-the-buildkite-cli), store it for an organization using `bk auth login`. For example, with the token supplied through an environment variable:

```bash
bk auth login --org my-org --token "$BUILDKITE_API_TOKEN"
```

The token is stored in the configured credential store, keyed by organization. Login registers the organization and saves it as the user-level default. It does not create a repository-local `.bk.yaml` file. An existing local organization selection still takes precedence over this default.

The legacy `bk configure` and `bk configure add` commands remain available for interactive API token entry. `bk configure` rejects an already configured token for the target organization unless you pass `--force`; the presence of `.bk.yaml` alone does not prevent configuration.

### Credential storage

By default, the CLI uses the operating system's credential store, such as the macOS Keychain. Tokens are not written to `bk.yaml`. Legacy plaintext tokens in configuration files can still be read, but produce a deprecation warning. Run `bk auth login` to store credentials in the configured credential store instead.

On headless Linux hosts, you can select the in-memory `/dev/shm` credential store:

```bash
bk config set credential_store shm
bk auth login --device
```

The `shm` store is intended for Linux and is not persistent across reboots. OAuth login requires an available credential store for access and refresh tokens. If no store is available, API-token login registers the organization but does not save the token; supply `BUILDKITE_API_TOKEN` at runtime instead.

### Automation and token precedence

For automation, supply a token and organization through environment variables without running login:

```bash
export BUILDKITE_ORGANIZATION_SLUG=my-org
# Supply BUILDKITE_API_TOKEN through your secret manager or CI environment.
bk build list --no-input --json
```

`BUILDKITE_API_TOKEN` overrides stored credentials, including OAuth credentials. The CLI does not replace an invalid environment token with a stored OAuth token after an authentication failure. Unset the variable to use stored credentials again.

## Configure the Buildkite CLI with multiple organizations

Run `bk auth login --org my-other-org` for each organization you need. Stored credentials are selected per organization. The CLI does not fall back to another organization's stored credentials when the target organization has no token.

For API tokens, repeat `bk auth login --org my-other-org --token "$BUILDKITE_API_TOKEN"` with the appropriate token. A token supplied through `BUILDKITE_API_TOKEN` can access multiple organizations if its permissions allow it.

## Select a configured organization

Use `bk auth switch` to select a configured organization interactively, or provide its slug:

```bash
bk auth switch my-other-org
```

Inside a Git repository, switching saves the selection in the repository-local `.bk.yaml`. Outside a repository, it updates the user-level default. `bk auth switch` replaces the deprecated `bk use` command.

To select an organization for one invocation without changing either file, use the global `--org` flag:

```bash
bk --org my-other-org build list
bk --org my-other-org job log JOB_UUID
```

Organization selection uses this precedence: `--org`, `BUILDKITE_ORGANIZATION_SLUG`, local `.bk.yaml`, then user configuration. For UUID-based job commands, choose the organization that owns the job; `--org` selects credentials, not a different job.

A qualified pipeline or build target also selects its organization and stored credentials for that invocation:

```bash
bk build list --pipeline my-other-org/my-pipeline
bk build view https://buildkite.com/my-other-org/my-pipeline/builds/123
```

If `--org` and a qualified target name different organizations, the command fails before execution. Targets naming different organizations also conflict. `bk browse` is an exception: it builds a URL without requiring credentials for the target organization. For `bk pipeline copy`, a qualified source does not change the selected destination organization; use `--target org/name` to select a destination explicitly. An explicit `--org` must agree with the source organization.

## Configuration files and preferences

User configuration is stored in `$XDG_CONFIG_HOME/bk.yaml` when `XDG_CONFIG_HOME` is set. Otherwise, Windows uses `%AppData%\Buildkite CLI\bk.yaml`, and Linux and macOS use `$HOME/.config/bk.yaml`. Repository-local preferences are stored in `.bk.yaml`.

Use [`bk config`](/docs/platform/cli/reference/config) to inspect and change preferences:

```bash
bk config list
bk config set output_format text
bk config set output_format yaml --local
bk config set no_pager true
```

Commands that support structured output default to JSON unless configured otherwise. Explicit format flags take precedence over `BUILDKITE_OUTPUT_FORMAT`, local preferences, and user preferences. Guided pipeline creation defaults to concise text when no format preference is set. The Preflight command uses `--json` for JSONL events rather than a single JSON document.
