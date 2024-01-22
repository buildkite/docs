# Single sign-on with Okta

To add Okta as an SSO provider for your Buildkite organization, you need admin privileges for both Okta and Buildkite.


## Setting up SSO with SAML

To set up single sign-on, follow the [SAML configuration guide](https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-Buildkite.html).

## Using SCIM to provision and manage users

Customers on the Buildkite [Enterprise](https://buildkite.com/pricing) plan can optionally enable automatic deprovisioning for their Buildkite users.

### Supported SCIM features

* Create users
* Deactivate users (deprovisioning)

>📘
> Buildkite does not bill you for users that you add to your Okta Buildkite app until they sign in to your Buildkite organization.

### Configuration instructions

Using the SCIM provisioning settings in Okta, Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan can automatically remove user accounts from your Buildkite organization. In Okta this feature is called 'Deactivating' a user. You need an enabled Okta SSO Provider before you can set up SCIM.

>📘 User deprovisioning
> User deprovisioning is an Enterprise only feature and automatically enabled. If you are using a [custom provider](/docs/integrations/sso/custom-saml) as an Enterprise customer, please contact support@buildite.com to have the 'SCIM for Custom SAML' feature flag enabled.

After creating your SSO Provider in Buildkite, you will need the  _Base URL_ and _API Token_ from your Okta SSO Provider Settings:

<%= image "okta-scim-settings.png", width: 1440/2, height: 548/2, alt: "Screenshot of the Buildkite Okta Settings SCIM Deprovisioning section" %>

Go to your Buildkite application in Okta to set up deprovisioning:

1. On the _Sign On_ tab in the Okta Buildkite application, edit the _Credentials Details_ settings, select _Email_ for the _Application username format_ and press _Save_.
1. On the _Provisioning_ tab, select _Integration_ from the left side menu.
1. Click _Configure API Integration_.
1. Tick _Enable API integration_ and enter the URL and API token copied from your Buildkite SSO Provider settings.
1. Click _Test API Credentials_ and then _Save_ once successfully verified.
1. Select _To App_ from the left side menu.
1. Edit the _Provisioning to App_ settings, and enable _Create Users_ and _Deactivate Users_.
1. Save and test your settings.

### Provisioning existing users

Buildkite creates accounts for existing Okta users with just-in-time user provisioning (JIT provisioning). To deprovision users, you need to sync them.

This can be done one of two ways:

1. Removing and re-assigning the users and groups to the Okta Buildkite app, or
1. If your Okta tenant has [Lifecycle Management] enabled, then you can use the _Provision User_ function on the _Assignments_ tab of the Okta Buildkite app

[Lifecycle Management]: https://www.okta.com/products/lifecycle-management/

## SAML user attributes

<%= render_markdown partial: 'integrations/sso/saml_user_attributes' %>
