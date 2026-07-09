# GitHub Enterprise Server

Buildkite can connect to your GitHub Enterprise Server and use the [GitHub Status API](https://docs.github.com/en/rest/commits/statuses) to update the status of commits in pull requests. This guide describes the setup for self-hosted GitHub Enterprise Server. GitHub Enterprise Cloud users should refer to [GitHub](/docs/pipelines/source-control/github).

> 📘 Buildkite plan availability and GitHub Enterprise version
> GitHub Enterprise is only available to Buildkite customers on [Pro or Enterprise](https://buildkite.com/pricing) plans.
> This guide is based on GitHub Enterprise version 2.16.3. Earlier or later versions may have different menus and headings for the OAuth app registration. All of the Buildkite settings will remain the same.

> 📘 Accessing private repositories
> Connecting your GitHub Enterprise Server to Buildkite configures webhooks and commit statuses. To give your agents access to clone private repositories, you need to configure code access separately. The recommended approach is to store an SSH key as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets) and reference it with [`checkout.ssh_secret`](/docs/pipelines/configure/git-checkout#ssh-key-from-buildkite-secrets) in your pipeline YAML. For full setup instructions, see [self-hosted agent code access](/docs/agent/self-hosted/code-access) or [Buildkite hosted agent code access](/docs/agent/buildkite-hosted/code-access).

You can connect a GitHub Enterprise Server installation using either an OAuth App or a GitHub App. This guide covers the OAuth App integration first, which Buildkite shows as **GitHub Enterprise Server (legacy)**. The GitHub App integration is newer and currently in private preview. With it, Buildkite creates and manages the app for you and supports optional code access for hosted agents. For proxy and firewall setups, see [Firewalled installs](#firewalled-installs).

## OAuth App

### Step 1: Register Buildkite as an OAuth app

In your GitHub Enterprise organization settings, select **OAuth Apps** under **Developer Settings**:

<%= image "oauth-apps-developer-settings.png", width:2038/2, height:1395/2, alt:"Screenshot of the OAuth Apps Page in the Developer Settings Menu" %>

Select **Register an application**. Fill out the form with the following values:

* Name: `Buildkite`
* URL: `https://buildkite.com`
* Callback URL: `https://buildkite.com/user/authorize/github_enterprise/callback`

<%= image "register-oauth-application-form.png", width:1548/2, height:1107/2, alt:"Screenshot of the form to Register an OAuth Application" %>

Select **Register application** at the bottom of the form.

After successfully registering your application, you can optionally add a logo to your app. Here is a pre-cropped image you can use:

<%= image "buildkite-square.png", width:350/2, height:350/2, alt:"Buildkite Logo" %>

Make a note of your Client ID and Client Secret, you will need those to connect your GitHub Enterprise Server with Buildkite in the next step.

<%= image "client-id-and-secret.png", width:767/2, height:707/2, alt:"Screenshot of the Client ID and Client Secret section of the Buildkite OAuth App settings page" %>

### Step 2: Update your Buildkite organization settings

1. Open your Buildkite organization's Settings and choose [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers).
1. Select **GitHub Enterprise Server (legacy)**.
1. Enter your settings:
    - The URL and public proxy URL of your GitHub Enterprise Server
    - The  Client ID and Client Secret from the GitHub OAuth App you created in Step 1
    - If you're using self-signed certificates, make sure the **Verify TLS Certificate** checkbox is not selected.
1. Select **Save GitHub Enterprise Settings** to save your settings. After saving, the **Secret** field appears blank. Buildkite has saved it, and will not display it.

    <%= image "buildkite-github-enterprise-settings.png", width:1942/2, height:1260/2, alt:"Screenshot of the GitHub Enterprise settings section in Buildkite" %>

    You can optionally supply a TLS certificate pair to be used by Buildkite as a client certificate when contacting your GitHub Enterprise endpoints.

    <%= image "tls-client-certificate.png", width:1900/2, height:1184/2, alt:"Screenshot of the TLS client settings section of the GitHub Enterprise settings in Buildkite" %>

### Step 3: Connect your GitHub Enterprise account to Buildkite

For Buildkite to mark commits and pull requests as pass or fail, you need to authorize your GitHub Enterprise user account with Buildkite.

1. In your Buildkite **Personal Settings**, select <a href="<%= url_helpers.user_authorizations_url %>" rel="nofollow">Connected Apps</a>. Here you'll see your GitHub Enterprise Server along with any other connected apps.
1. Select **Connect** next to **GitHub Enterprise**:

    <%= image "buildkite-connected-apps-settings.png", width:2324/2, height:636/2, alt:"Screenshot of the Connected Apps page in Buildkite Personal Settings with the GitHub Enterprise App" %>

1. Buildkite redirects you back to your GitHub Enterprise Server, where it asks you to authorize your new Buildkite OAuth app to use your GitHub Enterprise account. Select **Authorize** to complete your setup:

    <%= image "authorize-buildkite.png", width:1128/2 , height:1392/2, alt:"Screenshot of the Authorization page in GitHub Enterprise" %>

    That's it! Next time you create a pipeline with a repository that's either `https://git.mycompany.com/acme-inc/app.git` or `git@git.mycompany.com:acme-inc/app.git`.
    Buildkite will recognize that it's hosted on your GitHub Enterprise Server, and use your newly created OAuth authorization to update the commit statuses.

### Transferring ownership

If you need to leave your current GitHub Enterprise Organization, you need to transfer the OAuth ownership first. Without this, the remaining members of your Buildkite team who are using that GitHub Enterprise Organization for OAuth won't be able to log in.

To correctly transfer the OAuth ownership over your GitHub Enterprise Organization, see GitHub's official documentation for [Transferring ownership of an OAuth App](https://docs.github.com/en/developers/apps/managing-oauth-apps/transferring-ownership-of-an-oauth-app) and [Maintaining ownership continuity for your organization](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/maintaining-ownership-continuity-for-your-organization).

## GitHub App

> 📘 Private preview feature
> The GitHub App integration for GitHub Enterprise Server is currently in private preview. To enable it for your Buildkite organization, contact support@buildkite.com.

With the GitHub App integration, Buildkite creates a [GitHub App](https://docs.github.com/en/apps) on your GitHub Enterprise Server that receives webhooks to trigger builds and reports commit statuses back to your repositories and pull requests. You can optionally grant it code access so hosted agents can clone private repositories.

### Set up the GitHub App

1. Open your Buildkite organization's Settings and choose [**Repository Providers**](https://buildkite.com/organizations/~/repository-providers).
1. Select **GitHub Enterprise Server**, the entry marked **New**, rather than **GitHub Enterprise Server (legacy)**.
1. Enter your settings:
    - **URL**: the URL of the GitHub Enterprise Server to connect, for example `https://github.example.com`.
    - **GitHub Enterprise Organization**: the organization on GitHub Enterprise Server to create the app in. For example, to create the app in `https://github.example.com/acme`, enter `acme`.
    - **Code read access**: select this to grant the app read-only repository contents permission. This is required if using hosted agents to clone private repositories, and for the branch, tag, and release webhook events.
    - If Buildkite reaches your GitHub Enterprise Server through a proxy, open **Advanced API settings** and set the **Public API URL**. See [Firewalled installs](#firewalled-installs) for the network configuration.
1. Select **Create**. Buildkite sends you to your GitHub Enterprise Server to create the app from a manifest. This step runs against your GitHub Enterprise Server URL directly, so you need browser access to it.
1. On your GitHub Enterprise Server, review the app details and create the app. Your GitHub Enterprise Server will return you to Buildkite, which registers the provider and opens its settings page.
1. The provider isn't functional until the app is installed on your GitHub Enterprise Server. On the Buildkite provider settings page, select **Install GitHub App** to return to your GitHub Enterprise Server, then choose the organizations and repositories the app can access and install it. Your GitHub Enterprise Server returns you to Buildkite, which confirms the installation. Install the app in each GitHub organization you want to use with Buildkite.

### Known limitations for additional webhook events

The GitHub App manifest subscribes to the `create`, `delete`, and `release` webhook events. GitHub only delivers these events when the app has `contents: read` permission, which the manifest includes only when you select **Code read access** during setup.

This means installations without code access don't receive `create`, `delete`, or `release` events, so the corresponding pipeline settings (branch and tag creation and release triggers) have no effect. The `cancel_deleted_branch_builds` setting is not affected, because branch deletion is also detected through `push` events.

> 📘 Enabling additional webhook events
> To enable these events, reinstall the GitHub App with code access enabled. See the [GitHub integration docs](/docs/pipelines/source-control/github#running-builds-on-additional-github-events) for details on additional webhook events.

## Branch configuration and settings

<%= render_markdown partial: 'pipelines/source_control/branch_config_settings' %>

## Firewalled installs

If your GitHub Enterprise Server is behind a firewall, you need to allow Buildkite's IP addresses so Buildkite can reach the GitHub Enterprise Server API to authenticate and update your pull request statuses.

All Buildkite network traffic to your GitHub Enterprise Server comes from a set list of IP addresses. Because these addresses can change, retrieve them from the [Meta API endpoint](/docs/apis/rest-api/meta#get-meta-information) rather than hard-coding them, then configure your network to allow traffic from every address the endpoint returns.

The proxy guidance below depends on which integration you are setting up. The OAuth App and the GitHub App reach GitHub Enterprise Server over different paths.

### OAuth App

For additional security, you can put a proxy in front of GitHub Enterprise Server that allows only the API endpoints the OAuth integration requires, then enter the proxy address in the **Public API URL** field of your Buildkite GitHub Enterprise Server settings. The OAuth integration only calls these paths:

* `/api/v3/repos/.*/.*/statuses/.*`
* `/api/v3/user`
* `/api/v3/user/emails`
* `/login/oauth`

The following is an example [NGINX](https://www.nginx.com) server configuration that proxies these paths:

```nginx
daemon off;

events {
  worker_connections 1024;
}

http {

  server {
    listen 443 ssl;

    location / {
      # Your own IPs
      allow ...;
      
      deny all;
    }

    location ~ ^/api/v3/repos/.*/.*/statuses {
      proxy_pass https://ghe.internal:443;

      # Allow for OAuth Buildkite App to update commit statuses
      # IPs Subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
      allow 100.24.182.113;
      allow 35.172.45.249;
      allow 54.85.125.32;

      deny all;
    }

    location = /api/v3/user {
      proxy_pass https://ghe.internal:443;

      # Allow for OAuth Buildkite App
      # IPs Subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
      allow 100.24.182.113;
      allow 35.172.45.249;
      allow 54.85.125.32;

      deny all;
    }

    location = /api/v3/user/emails {
    proxy_pass https://ghe.internal:443;

    # Allow for OAuth Buildkite App
    # IPs Subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
    allow 100.24.182.113;
    allow 35.172.45.249;
    allow 54.85.125.32;

    deny all;
    }

    location /login/oauth {
      proxy_pass https://ghe.internal:443;

      # Allow for OAuth Buildkite App to authorize
      # IPs Subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
      allow 100.24.182.113;
      allow 35.172.45.249;
      allow 54.85.125.32;

      # Your own IPs
      allow ...;

      deny all;
    }

  }
}
```

Learn more about restricting access to your GitHub Enterprise Server on firewalled or proxy services in [Restricting access to proxied TCP resources of the NGINX docs](https://docs.nginx.com/nginx/admin-guide/security-controls/controlling-access-proxied-tcp/).

### GitHub App

The GitHub App integration registers its app on GitHub Enterprise Server using a [GitHub App manifest flow](https://docs.github.com/en/apps/sharing-github-apps/registering-a-github-app-from-a-manifest). The flow crosses two different network paths, and the routing matters when a proxy sits in front of GitHub Enterprise Server:

* App registration runs in your browser against your GitHub Enterprise Server URL directly, not through the **Public API URL** proxy. GitHub Enterprise Server binds the login session to its own canonical hostname. Routing this step through a proxy on a different hostname drops the session and the app is never created. Whoever sets up the integration needs browser access to the GitHub Enterprise Server URL.
* Buildkite's server-side calls go through the **Public API URL** proxy when you set one, and otherwise reach GitHub Enterprise Server directly. These calls convert the manifest into an app, install it, manage webhooks, and update commit statuses.

To restrict the server-side proxy, allow the Buildkite IP addresses from the [Meta API endpoint](/docs/apis/rest-api/meta#get-meta-information) and pass the requests through. If you also restrict by path, the GitHub App integration reaches these paths on GitHub Enterprise Server:

* `/api/v3/app-manifests/.*/conversions`
* `/api/v3/app/installations.*`
* `/api/v3/installation/repositories`
* `/api/v3/user/installations`
* `/api/v3/repos/.*`
* `/api/v3/search/repositories`
* `/api/v3/rate_limit`
* `/login/oauth/access_token`

Allowing the broader `/api/v3/` and `/login/oauth/` prefixes is simpler and won't need revisiting if the set of endpoints changes. The following is an example [NGINX](https://www.nginx.com) server configuration for the server-side proxy. This configuration carries Buildkite's server-side calls only. Browser-driven app registration reaches GitHub Enterprise Server directly and is not proxied here:

```nginx
daemon off;

events {
  worker_connections 1024;
}

http {

  server {
    listen 443 ssl;

    # App registration is browser-driven and reaches GitHub Enterprise Server
    # directly, so it is not proxied here. This proxy carries Buildkite's
    # server-side calls only.
    location / {
      deny all;
    }

    location /api/v3/ {
      proxy_pass https://ghe.internal:443;

      # IPs subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
      allow 100.24.182.113;
      allow 35.172.45.249;
      allow 54.85.125.32;

      deny all;
    }

    location = /login/oauth/access_token {
      proxy_pass https://ghe.internal:443;

      # IPs subject to change - https://buildkite.com/docs/apis/rest-api/meta#get-meta-information
      allow 100.24.182.113;
      allow 35.172.45.249;
      allow 54.85.125.32;

      deny all;
    }

  }
}
```

### GitHub App provider with a Public API URL

When using the GitHub App provider for GitHub Enterprise Server with a **Public API URL** (reverse proxy) configured, the browser-driven App creation step uses your GHES **URL** (canonical hostname) directly, not the proxy:

* **Browser setup step**: Your browser connects to the canonical GHES **URL** to create the GitHub App. The person running setup must be able to reach and log in to GHES at this address.
* **Server-side API traffic**: Buildkite continues to use the **Public API URL** for server-side API calls, including exchanging the manifest code during setup and updating commit statuses after setup.

If the canonical GHES URL is not reachable from the browser during setup, App creation will fail with "We didn't find an App Manifest for your request." Ensure the person running setup has browser access to the canonical GHES URL to complete the initial connection step.

## Multiple GitHub Enterprise integrations

You can set up multiple GitHub Enterprise integrations with your Buildkite organization. However, due to the OAuth installation requirements, each integration must be configured by a unique user. Each user must possess admin permissions in both Buildkite and GitHub.

## Using one repository in multiple pipelines and organizations

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org' %>

<%= render_markdown partial: 'pipelines/source_control/one_repo_multi_org_github' %>

## Build skipping

<%= render_markdown partial: 'pipelines/source_control/build_skipping' %>
