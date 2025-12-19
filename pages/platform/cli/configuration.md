# Buildkite CLI configuration

The Buildkite CLI uses both the [REST](/docs/apis/rest-api) and [GraphQL](/docs/apis/graphql-api) APIs to interact with Buildkite, and therefore, requires the configuration of an API access token.

## Create an API access token for the Buildkite CLI

To create a new API access token:

1. Select your user profile icon > [**Personal Settings**](https://buildkite.com/user/settings) in the global navigation.

1. Select **API Access Tokens** to access your [**API Access Tokens**](https://buildkite.com/user/api-access-tokens) page.

1. Select **New API Access Token** to open the [**New API Access Token**](https://buildkite.com/user/api-access-tokens/new) page.

1. Specify a **Description** and the **Organization Access** (that is, the specific Buildkite organization) for this token.

1. Once you have selected the required **REST API Scopes** and **Enable GraphQL API access** for the token, retain a copy of your API access token's value in a secure location.

**Note:** You can also use the following **New API Access Token** page links with pre-set fields to create these API access tokens:

- [New API access token with description](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI)—pre-sets the **Description** field with `Buildkite CLI`.

-  [New API access token with description and API scopes](https://buildkite.com/user/api-access-tokens/new?description=Buildkite%20CLI&scopes%5B%5D=read_agents&scopes%5B%5D=write_agents&scopes%5B%5D=read_clusters&scopes%5B%5D=write_clusters&scopes%5B%5D=read_teams&scopes%5B%5D=write_teams&scopes%5B%5D=read_artifacts&scopes%5B%5D=write_artifacts&scopes%5B%5D=read_builds&scopes%5B%5D=write_builds&scopes%5B%5D=read_build_logs&scopes%5B%5D=read_organizations&scopes%5B%5D=read_pipelines&scopes%5B%5D=write_pipelines&scopes%5B%5D=read_user&scopes%5B%5D=read_suites&scopes%5B%5D=write_suites&scopes%5B%5D=read_registries&scopes%5B%5D=write_registries&scopes%5B%5D=delete_registries&scopes%5B%5D=read_packages&scopes%5B%5D=write_packages&scopes%5B%5D=delete_packages&scopes%5B%5D=graphql)—pre-sets the **Description** field with `Buildkite CLI`, along with all the required **REST API Scopes** and **Enable GraphQL API access** options already selected.

If you use one of these links, you must still specify the Buildkite organization (in **Organization Access**) for this API access token.

## Configure the Buildkite CLI with your API access token

Once you have [created your API access token](#create-an-api-access-token-for-the-buildkite-cli), you'll need to configure the Buildkite CLI with this token.

To do this:

1. Run the following command:

    ```bash
    bk configure
    ```

1. When prompted for `Organization slug`, specify the slug for your Buildkite organization.

1. When prompted for `API Token`, specify the value for your configured API access token.

    **Note:** Upon successfully running this command for the first time, a new file is created at `$HOME/.config/bk.yaml`, which stores the Buildkite organization and its API access token configuration for your local Buildkite CLI.

### Using command flags

You can also run the `bk configure` command with the command flags, `--org` and `--token`, each of which can take either a literal or environment variable for the Buildkite organization slug and API access token, respectively.

For example:

```bash
bk configure --org my-buildkite-organization --token $BUILDKITE_API_TOKEN
```

### Command behavior and configuration files

The `bk configure` command is directory-specific, and running this command also creates a file called `.bk.yaml` in your current directory, which records the current Buildkite organization that your `bk` command is configured to work with from this current directory.

Attempting to run this command again in the same directory results in an error (due to the presence of a `.bk.yaml` file). Instead:

- You can [configure your Buildkite CLI tool to work with other Buildkite organizations](#configure-the-buildkite-cli-with-multiple-organizations).
- If your Buildkite CLI is already configured with multiple organizations, you can [choose a different Buildkite organization](#select-a-configured-organization) for it to work with.

If you run this command in a new directory (without a `.bk.yaml` file), and you specify a different API access token value for a Buildkite organization which has already been configured in `$HOME/.config/bk.yaml`, then this new API access token replaces the existing one configured in this file for that Buildkite organization.

## Configure the Buildkite CLI with multiple organizations

Some users may have access to Buildkite organizations—one for their company, and others for open-source work, personal work, etc.

The Buildkite CLI tool allows you to work with such multiple Buildkite organizations.

To configure the Buildkite CLI tool with another Buildkite organization:

1. Ensure you have [created individual API access tokens](#create-an-api-access-token-for-the-buildkite-cli) for each Buildkite organization to configure in the Buildkite CLI tool.

1. Run the following command:

    ```bash
    bk configure add
    ```

1. When prompted for `Organization slug`, specify the slug for the new Buildkite organization to add to the Buildkite CLI.

1. When prompted for `API Token`, specify the value for your configured API access token for this organization.

    **Note:** Upon success, a new Buildkite organization and corresponding API access token entry is added to your `$HOME/.config/bk.yaml`. This file stores all currently configured Buildkite organizations and their respective API access tokens for your local Buildkite CLI.

## Select a configured organization

If your Buildkite CLI tool has been [configured with multiple Buildkite organizations](#configure-the-buildkite-cli-with-multiple-organizations), you can switch from your current/active Buildkite organization to another. To do this:

1. Run the following command:

    ```bash
    bk use
    ```

1. Use the cursor select another configured Buildkite organization and make it the current/active one. All subsequent `bk` commands will operate with the new active organization.

    **Notes:**
    * If you already know the slug of the other Buildkite organization you're switching to, you can specify this value immediately after the `bk use` command, for example, `bk use my-other-organization`.
    * Upon success, the `.bk.yaml` file in your current directory is updated with your current/active Buildkite organization.
