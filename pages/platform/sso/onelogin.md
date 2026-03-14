# Single sign-on with OneLogin

You can use OneLogin as an SSO provider for your Buildkite organization. To complete this tutorial, you need admin privileges for both OneLogin and Buildkite.


## Step 1. Add the Buildkite app to your OneLogin account

Log into your OneLogin account, and follow these steps:

1. In the **Apps** tab of your OneLogin organization's **Admin** area, select the **Add App** button to search the OneLogin directory.
1. Search for 'Buildkite'.
1. Add the Buildkite app to your OneLogin account.
1. Click on the **Configuration** tab of your new Buildkite application.
1. Enter your Buildkite organization slug.
1. Click the **Save** button in the top right to save your configuration.

## Step 2. Create an SSO provider

In your [Buildkite organization **Settings**](https://buildkite.com/organizations/~/settings)' **Single Sign On** menu item, choose the OneLogin provider:

<%= image "sso-settings.png", width: 1716/2, height: 884/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

On the following screen in the setup form, enter your IdP data. The following three required fields can be found in the **SSO** tab on the Buildkite app page in OneLogin:

<table>
    <tr>
        <td>SAML 2.0 Endpoint (HTTP)</td>
        <td>
            The URL where you can log in to OneLogin's SAML service.
        </td>
    </tr>
    <tr>
        <td>Issuer URL</td>
        <td>
            The URL that identifies your OneLogin service.
        </td>
    </tr>
    <tr>
        <td>X.509 certificate</td>
        <td>
            The public key certificate generated for you by OneLogin. You need the whole file, not just a link to the file.
        </td>
    </tr>
</table>

>📘 You can also set up SSO providers manually with GraphQL.
> See the <a href="/docs/platform/sso/sso-setup-with-graphql">SSO setup with GraphQL guide</a> for detailed instructions and code samples.

## Step 3. Perform a test login

Follow the instructions on the provider page to perform a test login. Performing a test login verifies that SSO is working correctly before you activate it for your organization members.

## Step 4. Enable the new SSO provider

Once you've performed a test login you can enable your provider. Activating SSO will not force a log out of existing users, but will cause all new or expired sessions to authorize through OneLogin before organization data can be accessed.

If you need to edit or update your OneLogin provider settings at any time, you will need to disable the provider first. For more information on disabling a provider, see the [disabling SSO](/docs/platform/sso#disabling-and-removing-sso) section of the SSO overview.

## SAML user attributes

<%= render_markdown partial: 'platform/sso/saml_user_attributes' %>
