---
toc_include_h3: false
---

# Single sign-on support

Single sign-on (SSO) protects access to your organization's data in Buildkite. You can configure multiple SSO providers for one organization.

> 📘 Pro and Enterprise plan feature
> SSO capabilities are only available to Buildkite customers on the [Pro or Enterprise](https://buildkite.com/pricing) plan. Which providers you can configure depends on your plan. See [Supported providers](/docs/platform/sso#supported-providers) for the plan each provider requires.

SSO access depends on each member's requirement in the [organization's user settings](https://buildkite.com/organizations/~/users):

- **Required**: The member must use SSO to access your organization.
- **Optional**: The member can use SSO or their email and password.

For related access controls, see the [Security checklist](/docs/platform/security/checklist). To prepare for compromised accounts or a loss of trusted SSO access, see [Incident response](/docs/platform/security/incident-response).

## Supported providers

Buildkite supports the following SSO providers on the specified plans:

- [Okta](/docs/platform/sso/okta) (Pro and Enterprise plans)
- [ADFS](/docs/platform/sso/adfs) (Enterprise plan only)
- [GitHub](/docs/platform/sso/github-sso) (Pro and Enterprise plans)
- [Google Workspace](/docs/platform/sso/google-workspace) (Pro and Enterprise plans)
- [Google Workspace (SAML)](/docs/platform/sso/google-workspace-saml) (Enterprise plan only)
- [Microsoft Entra ID](/docs/platform/sso/azure-ad) (Enterprise plan only)
- [OneLogin](/docs/platform/sso/onelogin) (Pro and Enterprise plans)
- [Custom SAML](/docs/platform/sso/custom-saml) (Enterprise plan only)

## Adding SSO

As an organization administrator, select [**Organization Settings** > **SSO Settings**](https://buildkite.com/organizations/-/sso) to configure a supported provider:

<%= image "sso-settings.png", width: 1716/2, height: 884/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

You can also [configure SSO manually using the GraphQL API](/docs/platform/sso/sso-setup-with-graphql).

Once SSO is configured, members who are required to use SSO must sign in through your provider to access organization data:

<%= image "sso-enabled.png", width: 1580/2, height: 834/2, alt: "Screenshot of the SSO protecting access to data" %>

## Disabling and removing SSO

Disable an SSO provider before editing its settings, pausing SSO logins, or removing it. Use either method:

- Select **Disable** in the provider's settings.
- Use the [GraphQL API](/docs/platform/sso/sso-setup-with-graphql#disabling-an-sso-provider).

If all providers are disabled, users must log in with a username and password. Users without a password can use the password-reset process to create one.

## Migrating from one SSO provider to another SSO provider

To switch providers as an organization administrator, keep both providers available until you have verified the new one:

1. [Add](/docs/platform/sso#adding-sso) and verify the new provider. Allow login through both providers, using the same email addresses so members keep their existing Buildkite accounts.
1. [Disable and remove](/docs/platform/sso#disabling-and-removing-sso) the old provider.

>📘
> If you are also changing the email provider, make sure that Buildkite users in your organization sign in to their existing accounts when performing single sign-on through the new provider to prevent your organization being billed twice for the same users.

If you'd like to have some help with the migration, contact support@buildkite.com.

## SSO session duration

SSO sessions do not expire by default. You can set a session duration between six hours and 8,760 hours (one year). Users are signed out when the configured duration elapses. Changes affect both new and existing sessions.

Set the duration using the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#update-the-default-sso-provider-session-duration) or the provider's settings:

1. Select the SSO provider you want to configure.

    <%= image "session_duration/select_provider.png", width: 1201/2, height: 786/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

1. In **Session Duration**, select **Update Session Duration**.

    <%= image "session_duration/update_session_duration.png", width: 1201/2, height: 1043/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

1. Enter the duration and save your changes.

    <%= image "session_duration/configure_session_duration.png", width: 623, height: 315, alt: "Screenshot of the Buildkite SSO Session Duration Configuration" %>

## SSO session IP address pinning

> 📘 Enterprise plan feature
> Pinning SSO sessions to IP addresses is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

Session IP address pinning revokes an SSO session when it is used from a different IP address. The user must re-authenticate. This restricts use of the session to the IP address that created it.

Pinning applies only to members required to use SSO in the [organization's user settings](https://buildkite.com/organizations/~/users).

To set up SSO session IP address pinning, use the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#pin-sso-sessions-to-ip-addresses) or complete the following steps in the Buildkite dashboard:

1. Navigate to the [organization's **Single Sign On** settings](https://buildkite.com/organizations/~/sso).
1. In the **Configured SSO Providers** section, select the provider.
1. In the **Session IP Address Pinning** section, select **Update Session IP Address Pinning**.
1. In the resulting dialog, select the **Session IP Address Pinning** checkbox.
1. Select **Save Session IP Address Pinning**.

## Requiring SSO sign-in again

As an organization administrator, you can revoke every active SSO session for your organization at once, for example, during a suspected security incident. Affected members, including you, must sign in through your identity provider again before they can access the organization.

To require SSO sign-in again:

1. Select **Settings** > **Security**.
1. In the **SSO Sessions** section, select **Require SSO sign-in again**.
1. Review the consequences, then select **Require SSO sign-in again** to confirm, or **Cancel** to go back without revoking any sessions.

Requiring SSO sign-in again only revokes this organization's SSO sessions. It doesn't:

- Affect sessions in your other organizations.
- Affect members whose SSO is optional in this organization.
- Revoke API access tokens or agent tokens. [Revoke these separately](/docs/platform/security/incident-response#revoke-compromised-tokens) if they may also be compromised.
- Revoke existing OAuth access and refresh tokens, including those used by remote MCP and the Buildkite CLI. A new OAuth authorization that requires SSO must complete SSO again.

This action cannot be undone. Confirm that you can sign in through your identity provider before continuing.

## Frequently asked questions

These answers cover membership, provider changes, billing, and login issues.

### Can some people in the organization use SSO and others not?

Yes. Organization administrators can make SSO required or optional for each member in the [organization's user settings](https://buildkite.com/organizations/~/users). Members with optional SSO can use either SSO or their email and password.

### Do you support JIT provisioning?

Yes. Just-in-time (JIT) provisioning creates an account when a user first needs it, typically at their first SSO login. Granting access through your provider does not create a billable Buildkite user until the account is created.

### What happens if a person leaves our company?

Remove them from your Buildkite organization. This does not affect their personal account or access to other organizations. Enterprise customers can automate removal using [SCIM deprovisioning](/docs/platform/sso/okta#user-deprovisioning).

### Can I use different SSO providers for my Buildkite organization at the same time?

Yes. As an organization administrator:

1. [Add and verify](/docs/platform/sso#adding-sso) the new provider.
1. Allow login from both providers in [**Organization Settings**](https://buildkite.com/organizations/-/sso).
1. Keep sign-in email addresses the same so members retain their existing Buildkite accounts.

### Can we enable SSO on multiple domains for one organization?

Yes. Add multiple SSO providers. You can enable as many providers as your organization needs.

### Will enabling SSO disrupt my team?

Enabling SSO changes how members access organization data. Verify your provider before enabling it. Members required to use SSO must then authorize with your provider. The organization shows an SSO badge, and you can disable the provider if needed.

### Will enabling SSO affect builds, agents or pipelines?

No. Your builds, agents, and pipelines continue to run as normal.

### Does enabling SSO affect billing?

Enabling SSO does not itself change billing. New users who sign in through SSO join your organization as if you had invited them and count toward usage under your plan.

### Can I sync my identity provider's groups with my Buildkite teams?

Yes, if you associate your provider's groups with Buildkite team UUIDs. Configure the SAML assertion to send `teams` as an additional [SAML user attribute](/docs/platform/sso/custom-saml#saml-user-attributes).

### I want to rename my Buildkite organization. Will it affect my SSO provider(s)?

No. SSO providers use a unique identifier that does not change when you rename your organization.

### Can I merge two organizations that use different SSO providers?

Yes, but contact support@buildkite.com before merging organizations with existing SSO providers. Support can help you plan the migration.

### Why am I being asked for my password in the "Authorization Required" screen when signing in using SSO?

Buildkite asks for your password to confirm your identity before granting access to an organization. Signing in through one organization's SSO provider must not grant access to your other organizations.

Authentication confirms who you are. Authorization checks which organizations you can access. Buildkite and your SSO provider both participate in these checks.

### I'm already a member of a Buildkite organization. Should I create a new Buildkite user account if I want to work within a different organization (pet project, open source work, etc.)?

Use one Buildkite account and join multiple organizations. Separate accounts are allowed, but switching between them requires logging out and back in or using different browsers.

### Why do I get the error "this email is already being used by another user" when logging in?

The email address is already associated with a Buildkite account. The resolution depends on which account owns it:

- **Shared account**: Remove the email association from that account's personal email settings.
- **Existing individual account**: If you can access the old account, delete it before continuing. You may also need to clear its SSO authorization records.

Contact support@buildkite.com if you cannot access the account or the error persists.

### Why do I get the error "we couldn't find an account with that email address" when logging in?

This is likely caused by trying to log in from the wrong place. You need to log in from https://buildkite.com/sso and follow the link from the email you receive. If the issue persists, please reach out to support@buildkite.com for assistance.

### Will setting the session duration affect all current sessions or only the new sessions?

When you [update the session duration](/docs/apis/graphql/cookbooks/organizations#update-the-default-sso-provider-session-duration), it affects both new and old SSO sessions.

### When is an SSO session considered to start?

An SSO session starts for a user from the moment they sign in using SSO.
