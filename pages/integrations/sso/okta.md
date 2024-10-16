# Single sign-on with Okta

To add Okta as an SSO provider for your Buildkite organization, you need admin privileges for both Okta and Buildkite.


## Setting up SSO with SAML

To set up single sign-on, follow the [SAML configuration guide](https://saml-doc.okta.com/SAML_Docs/How-to-Configure-SAML-2.0-for-Buildkite.html).

## Using SCIM to provision and manage users

Customers on the Buildkite [Enterprise](https://buildkite.com/pricing) plan can optionally enable automatic deprovisioning for their Buildkite users.

### Supported SCIM features

* Create users
* Deactivate users (deprovisioning)

> 📘
> Buildkite does not bill you for users that you add to your Okta Buildkite app until they sign in to your Buildkite organization.

### Configuration instructions

Using the SCIM provisioning settings in Okta, Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan can automatically remove user accounts from your Buildkite organization. In Okta this feature is called 'Deactivating' a user. You need an enabled Okta SSO Provider before you can set up SCIM.

> 📘 User deprovisioning
> User deprovisioning is an Enterprise only feature and automatically enabled. If you are using a [custom provider](/docs/integrations/sso/custom-saml) as an Enterprise customer, please contact support@buildkite.com to have the 'SCIM for Custom SAML' feature flag enabled.

After creating your SSO Provider in Buildkite, you will need the **Base URL** and **API Token** from your Okta SSO Provider Settings:

<%= image "okta-scim-settings.png", width: 1440/2, height: 548/2, alt: "Screenshot of the Buildkite Okta Settings SCIM Deprovisioning section" %>

Go to your Buildkite application in Okta to set up deprovisioning:

1. On the **Sign On** tab in the Okta Buildkite application, edit the **Credentials Details** settings, select **Email** for the **Application username format** and click **Save**.
1. On the **Provisioning** tab, select **Integration** from the left side menu.
1. Click **Configure API Integration**.
1. Select the **Enable API integration** option and enter the URL and API token copied from your Buildkite SSO Provider settings.
1. Click **Test API Credentials** and then **Save** once successfully verified.
1. Select **To App** from the left side menu.
1. Edit the **Provisioning to App** settings, and enable **Create Users** and **Deactivate Users**.
1. Save and test your settings.

### Provisioning existing users

Buildkite creates accounts for existing Okta users with just-in-time user provisioning (JIT provisioning). To deprovision users, you need to sync them.

This can be done one of two ways:

1. Removing and re-assigning the users and groups to the Okta Buildkite app, or
1. If your Okta tenant has [Lifecycle Management] enabled, then you can use the **Provision User** function on the **Assignments** tab of the Okta Buildkite app.

[Lifecycle Management]: https://www.okta.com/products/lifecycle-management/

## SAML user attributes

<%= render_markdown partial: 'integrations/sso/saml_user_attributes' %>

>🚧 Accidental user role demotion/promotion
> Note that if SSO via Okta is enabled and configured, Buildkite will receive the information about user roles from Okta and match it. So if you manually user change roles in Buildkite but not in Okta, then every time a user logs into Buildkite via Okta, the role type in Buildkite will be rewritten to match the information provided by Okta. This can cause unintended user role demotion or promotion.
