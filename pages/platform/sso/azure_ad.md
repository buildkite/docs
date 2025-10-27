# Single sign-on with Microsoft Entra ID (Azure AD)

You can use [Microsoft Entra ID](https://www.microsoft.com/en-us/security/business/identity-access/microsoft-entra-id#Overview) (formerly known as Azure Active Directory) as an SSO provider for your Buildkite organization. To complete this tutorial, you need admin privileges for both Azure and Buildkite.

> 📘 You can also set up SSO providers manually with GraphQL.
> See the <a href="/docs/platform/sso/sso-setup-with-graphql">SSO setup with GraphQL guide</a> for detailed instructions and code samples.


## Step 1. Create a Buildkite SSO provider

In your [Buildkite organization **Settings**](https://buildkite.com/organizations/~/settings), click **Single Sign On**, then choose the custom SAML provider from the available options:

<%= image "sso-settings.png", width: 1716/2, height: 884/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

1. Choose the **Provide IdP Metadata Later** option when configuring your custom SAML provider
2. Copy the Assertion Consumer Service (ACS) URL for use in [Step 2](#step-2-add-buildkite-in-azure-ad)

## Step 2. Add Buildkite in Azure AD

In your [Azure Admin Console](https://portal.azure.com/), follow these instructions:

1. Choose **Azure Active Directory**, and under **Quick actions**, choose **Add enterprise application**.
1. Click **+ Create your own application**.
1. Give your application a name, for example 'Buildkite'.
1. Choose **Integrate any other application you don't find in the gallery (Non-gallery)** and click **Create**.
1. Choose **Set up single sign on**, then **SAML**, then in the **Basic SAML Configuration** box, choose **Edit**.
1. Enter the following configuration and save:
    * **Identifier (Entity ID)**: `https://buildkite.com`
    * **Reply URL (Assertion Consumer Service URL)**: the ACS URL you copied in [Step 1](#step-1-create-a-buildkite-sso-provider)
1. Copy the **App Federation Metadata Url** value from the **SAML Signing Certificate** box for use in [Step 3](#step-3-update-your-buildkite-sso-provider).

## Step 3. Update your Buildkite SSO provider

On your [Buildkite organization **Settings**](https://buildkite.com/organizations/~/settings)' **Single Sign On** page, select the custom SAML provider from the list of **Configured SSO Providers**.

1. Click the **Edit Provider** button, choose the **Configure Using IdP Meta Data URL** option, and enter the **App Federation Metadata Url** you copied in Step 2.
1. Save your new settings. Buildkite returns you to your custom SAML provider page.

## Step 4. Perform a test login

On your Custom SAML provider page, click **Perform Test Login** to verify that SSO is working correctly before you activate it for your organization members.

If you receive an error from Microsoft about the user not being assigned to the application, you can assign an initial user:

1. In your Azure Admin Console, select the new **Buildkite** enterprise app.
1. Choose **Users and groups** from the navigation sidebar.
1. Click **Add user/group**.
1. Select the user and click **Assign**.

Then, on your [Buildkite organization **Settings**](https://buildkite.com/organizations/~/settings)' **Single Sign On** page, select the custom SAML provider from the list of **Configured SSO Providers**, and retry the test login.

## Step 5. Enable the new SSO provider

Once you've [performed a test login](#step-4-perform-a-test-login) you can enable your SSO provider using the **Enable** button. Enabling the SSO provider will not force a log out of any signed in users, but will cause all new or expired sessions to authorize through Azure AD before accessing any organization data.

> 🚧
>If you need to edit or update your Azure Active Directory provider settings, you will need to <a href="/docs/platform/sso#disabling-and-removing-sso">disable the SSO provider</a> first.

## Using SCIM to provision and manage users

Enterprise plan customers can automatically add and remove user accounts from their Buildkite organization using the SCIM provisioning settings in Azure AD.

### Supported SCIM features

* Create users
* Deactivate users (deprovisioning)

> 📘
> Buildkite does not bill you for users that you add to Azure AD until they sign in to your Buildkite organization.

### Configuration instructions

Adding and removing users accounts in Azure AD is called provisioning. You need an enabled Azure AD SSO Provider for your Buildkite Organization before you can set up SCIM provisioning.

> 📘
> User deprovisioning is an Enterprise plan-only feature and is automatically enabled. As an Enterprise plan customer, if you are using a [custom provider](/docs/platform/sso/custom-saml), please contact support@buildite.com to have this feature enabled.

After enabling your Azure AD SSO provider in Buildkite, get the **Base URL** and **API Token** from your Azure AD SSO provider settings:

<%= image "azuread-scim-settings.png", width: 1440/2, height: 548/2, alt: "Screenshot of the Buildkite Settings SCIM Deprovisioning section" %>

Then go to your [Azure Admin Console](https://portal.azure.com/) and select the new Buildkite enterprise app to set up provisioning:

1. Choose **Provisioning** from the navigation sidebar, then click **Get started**.
1. Select **Automatic** provisioning mode and enter the following details:
    * **Tenant URL**: the Base URL from your Buildkite SSO Provider settings
    * **Secret Token**: the API Token from your Buildkite SSO Provider settings
1. Click **Test Connection**, and when you receive confirmation the settings are valid, save.
1. Disable group synchronization:
    1. Expand **Mappings**, then click **Provision Azure Active Directory Groups**.
    1. Toggle **Enabled** to **No** and click **Save**.
1. Customize the User mappings:
    1. Expand **Mappings**, then click **Provision Azure Active Directory Users**.
    1. Keep the following four mappings, and delete any others:
        - `userPrincipalName` to `userName`
        - `Switch([IsSoftDeleted], , "False", "True", "True", "False")` to `active`
        - `givenName` to `name.givenName`
        - `surname` to `name.familyName`
1. Toggle **Provisioning Status** to **On** and save.
1. Return to the **Provisioning** menu of your Azure AD enterprise app and view the **Current cycle status** section:
    * If provisioning is working, this will say **Initial cycle completed**.
    * If errors are displayed, click **View provisioning logs** for more details on what went wrong.

## SAML user attributes

<%= render_markdown partial: 'platform/sso/saml_user_attributes' %>
