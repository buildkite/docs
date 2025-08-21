---
toc_include_h3: false
---

# Single sign-on support

You can use a single sign-on (SSO) provider to protect access to your organization's data in Buildkite. Buildkite supports many different SSO providers, and you can configure multiple SSO providers for a single Buildkite organization.

SSO is available to customers on the Buildkite [Pro and Enterprise](https://buildkite.com/pricing) plans.

You can enforce SSO authentication for your entire Buildkite organization by ensuring that [2FA authentication](/docs/platform/team-management/enforce-2fa) has been disabled for your Buildkite organization. Doing so ensures that all users must log in using SSO when accessing your Buildkite organization.

## Supported providers

Buildkite supports the following SSO providers:

* [Okta](/docs/platform/sso/okta)
* [ADFS](/docs/platform/sso/adfs)
* [GitHub](/docs/platform/sso/github-sso)
* [Google Workspace](/docs/platform/sso/google-workspace)
* [Google Workspace (SAML)](/docs/platform/sso/google-workspace-saml)
* [Azure Active Directory](/docs/platform/sso/azure-ad)
* [OneLogin](/docs/platform/sso/onelogin)
* [Custom SAML](/docs/platform/sso/custom-saml)

## Adding SSO

Many of the SSO providers can be configured by an organization admin using [Organization Settings → SSO Settings](https://buildkite.com/organizations/-/sso):

<%= image "sso-settings.png", width: 1716/2, height: 884/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

You can also [configure SSO manually using the GraphQL API](/docs/platform/sso/sso-setup-with-graphql).

Once configured, all access to organization data requires signing into your SSO provider:

<%= image "sso-enabled.png", width: 1580/2, height: 834/2, alt: "Screenshot of the SSO protecting access to data" %>

## Disabling and removing SSO

If you need to edit your SSO settings, temporarily stop logins using SSO, or want to delete your SSO provider, you'll first need to disable it.

There are two ways to disable a provider:

1. Using the 'Disable' button in your SSO provider Settings, or
1. Using the [GraphQL API](/docs/platform/sso/sso-setup-with-graphql#disabling-an-sso-provider)

If you have switched off all of your SSO providers, users will be required to log in using a username and password. If users don't have a password, and need access while SSO is switched off, they can perform a 'Forgotten Password' reset.

## Migrating from one SSO provider to another SSO provider

If you are the administrator of an organization within Buildkite with an existing SSO provider set up, and you want to switch to a different SSO provider, these are the steps you need to take:

1. [Add](/docs/platform/sso#adding-sso) a new SSO provider, verify it, and allow login from both SSO providers. The users in your organization can continue to sign in and use the same user accounts within Buildkite as long as the emails stay the same.
1. [Disable and remove](/docs/platform/sso#disabling-and-removing-sso) the SSO provider you no longer need. If the user credentials (email) stay the same, this is all you need to migrate from one SSO provider to another.

>📘
> If you are also changing the email provider, make sure that Buildkite users in your organization sign in to their existing accounts when performing single sign-on through the new provider to prevent your organization being billed twice for the same users.

If you'd like to have some help with the migration, contact support@buildkite.com.

## SSO session duration

You can configure the SSO Session Duration to timeout after a predetermined time. When the specified duration elapses, the user will be signed out of the session.

To set the Session Duration you can either use the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#update-the-default-sso-provider-session-duration) or complete
the following steps via the settings interface.

First select the SSO Provider you would like to configure.

<%= image "session_duration/select_provider.png", width: 1201/2, height: 786/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

Then click **Update Session Duration** from the **Session Duration** section of the
SSO Provider settings page.

<%= image "session_duration/update_session_duration.png", width: 1201/2, height: 1043/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

You can configure the session duration to any timeout between 6 hours and 8,760 hours (1 year).

<%= image "session_duration/configure_session_duration.png", width: 623, height: 315, alt: "Screenshot of the Buildkite SSO Session Duration Configuration" %>

## SSO session IP address pinning

> 📘 Enterprise feature
> Pinning SSO sessions to IP addresses is only available on an [Enterprise](https://buildkite.com/pricing) plan.

Session IP address pinning prompts users to re-authenticate when their IP address changes. This prevents session hijacking by restricting authorized sessions to only originate from the IP address used to create the session. If any attempt is made to access Buildkite from a different IP address, the session is instantly revoked and the user must re-authenticate. Users must be required to use SSO in the [organization's user settings](https://buildkite.com/organizations/~/users) for SSO session IP address pinning to work for them.

To set up SSO session IP address pinning, use the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#pin-sso-sessions-to-ip-addresses) or complete the following steps in the Buildkite dashboard:

1. Navigate to the [organization's **Single Sign On** settings](https://buildkite.com/organizations/~/sso).
1. In the **Configured SSO Providers** section, select the provider.
1. In the **Session IP Address Pinning** section, select **Update Session IP Address Pinning**.
1. In the resulting dialog, select the **Session IP Address Pinning** checkbox.
1. Select **Save Session IP Address Pinning**.

## Frequently asked questions

### Can some people in the organization use SSO and others not?
Yes, team maintainers can select whether a user is 'required' to use SSO or whether it is 'optional'. You can find this setting in the [organization's user settings](https://buildkite.com/organizations/~/users).

### Do you support JIT provisioning?
Yes, we do. Just-in-time user provisioning (JIT provisioning) creates accounts only when needed. You can grant a user access to Buildkite through your SSO provider, but their account won't be created until it's required—typically upon their first login attempt. For billing purposes, the user doesn't exist until their account is created.

### What happens if a person leaves our company?
You will need to manually remove them from your Buildkite organization. This will not affect access to the user's personal account or any other organizations they are a member of.

### Can I use different SSO providers for my Buildkite organization at the same time?
Yes, as an admin you need to [add and verify](/docs/platform/sso#adding-sso) a new SSO provider. Next, you need to allow login from both SSO providers in the [Organization settings](https://buildkite.com/organizations/-/sso). As long as the sign-in emails stay the same, the users in your organization can continue to sign in and use the same user accounts within Buildkite.

### Can we enable SSO on multiple domains for one organization?
Yes, by adding multiple SSO providers. You can enable as many different identity providers for your organization as you need.

### Will enabling SSO disrupt my team?

<!--alex ignore easy-->

No, SSO must be verified before being enabled, and can easily be switched off if required. Once enabled, users will see a new "SSO" badge on the organization and will be required to authorise with your SSO provider to access organization data.

### Will enabling SSO affect builds, agents or pipelines?
No, all of your builds, agents, and pipelines will continue to run as normal.

### Does enabling SSO affect billing?
No, enabling SSO will not affect how much you are billed. However, whenever a new user signs in to Buildkite using SSO, they will be added to your organization as if you had invited them.

### Can I sync my identity provider's groups with my Buildkite teams?
Yes, if you are able to associate your provider's groups with your Buildkite team UUIDs, you can adjust the SAML assertion to send 'teams' as an additional [SAML User Attribute](/docs/platform/sso/custom-saml#saml-user-attributes).

### I want to rename my Buildkite organization. Will it affect my SSO provider(s)?
No, SSO providers are setup using a unique identifier and are unaffected when a Buildkite organization is renamed.

### Can I merge two organizations that use different SSO providers?
In short, yes, you can. However, merging Buildkite organizations that already have SSO providers might be a tricky scenario, and it's highly recommended that you contact support@buildkite.com for help or guidance before you attempt such migration.

### Why am I being asked for my password in the "Authorization Required" screen when signing in using SSO?
Signing in to your Buildkite organization requires authentication and authorization with both Buildkite and your SSO provider. Authentication determines if you are who you claim to be. Authorization determines if you have the correct permissions within the Buildkite organization you're trying to access.

Both authentication and authorization are necessary because SSO using one Buildkite organization shouldn't provide access to your other Buildkite organizations. Confirming your password is Buildkite's way to ensure that you are who you say you are. Once you've authenticated with Buildkite, it determines which organizations your account is authorized to access.

### I'm already a member of a Buildkite organization. Should I create a new Buildkite user account if I want to work within a different organization (pet project, open source work, etc.)?
<!--alex ignore easy-->

Some people choose to have multiple user accounts, one per Buildkite organization. It's fine to do this, but it can be slightly inconvenient as such an approach does not provide easy tools for switching between accounts. You will need to use different browsers or log in and out quite often.

It's recommended to have a single Buildkite user account and join multiple organizations when required.

### Why do I get the error "this email is already being used by another user" when logging in?

There are two common reasons. The first is that you are using shared accounts, so the email is associated with another account. To resolve that, you need to remove the association from your Email Personal Settings.

The second is that the account already exists in Buildkite. If you have access to the old account, delete it before continuing. You may also need to clean up any SSO authorization records on Buildkite for the old account. If that doesn't resolve the issue or you don't have access to the account, please reach out to support@buildkite.com for assistance.

### Why do I get the error "we couldn't find an account with that email address" when logging in?

This is likely caused by trying to log in from the wrong place. You need to log in from https://buildkite.com/sso and follow the link from the email you receive. If the issue persists, please reach out to support@buildkite.com for assistance.

### Will setting the session duration affect all current sessions or only the new sessions?

When you [update the session duration](/docs/apis/graphql/cookbooks/organizations#update-the-default-sso-provider-session-duration), it affects both new and old SSO sessions.

### When is an SSO session considered to start?

An SSO session starts for a user from the moment they sign in using SSO.
