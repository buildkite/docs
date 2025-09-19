# Single sign-on with ADFS

You can use Active Directory Federation Services (ADFS) for your Buildkite organization. To complete this tutorial, you need admin privileges for both your ADFS server and Buildkite.

ADFS SSO is available to customers on the Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

>📘 You can also set up SSO providers manually with GraphQL.
> See the <a href="/docs/platform/sso/sso-setup-with-graphql">SSO setup with GraphQL guide</a> for detailed instructions and code samples.


## Step 1. Create a Buildkite SSO provider

Click the [Buildkite organization **Settings**](https://buildkite.com/organizations/~/settings)' **Single Sign On** menu item, then choose the ADFS provider from the available options:

<%= image "sso-settings.png", width: 1716/2, height: 884/2, alt: "Screenshot of the Buildkite SSO Settings Page" %>

On the following page, copy the ACS URL for use in Step 2.

## Step 2. Set up Buildkite in the ADFS management console

The instructions below guide you through using a series of wizards to:

+ Add a Relying Party Trust
+ Add an Issuance Transform Rule, a type of Claim Rule
+ Export the Token-signing Certificate
+ Update the Authentication Policy

With these wizards, you'll set up your domain for SSO and retrieve the information the Buildkite team requires to complete the setup process.

>📘 This guide was written for, and tested using, Windows Server 2016
> Some of the wizard pages and dialog tab names have changed across versions of Windows Server.
> For a guide written for Windows Server 2012, the <a href="https://www.pagerduty.com/docs/guides/adfs-sso-guide/">PagerDuty SSO integration guide</a> is very similar to Buildkite. Follow the PagerDuty instructions, and substitute in the Buildkite values from the instructions below.

### Step 2.1 Add a relying party trust

From the **Actions** sidebar, click **Add relying party trust...** to start the wizard:

1. **Welcome**: Select **Claims aware**.
1. **Select data source**: Select **Enter data about the relying party manually**.
1. **Specify display name**: Call your relying party `Buildkite`.
1. **Choose profile**: Select **ADFS profile**.
1. **Configure certificate**: Skip this step, as you don't need a token encryption certificate.
1. **Configure URL**:
	Select **Enable support for the SAML 2.0 WebSSO protocol**.
	Enter the ACS URL from Buildkite as your **Relying party SAML 2.0 SSO service URL**.
1. **Configure identifiers**:
	Enter `https://<your IDP url>/adfs/services/trust` into the **Relying party trust identifier** field.
	Click **Add** to add it to the **Relying party trust identifiers** list.
1. **Choose Access Control Policy**:
	Choose **Permit everyone**.
	You can choose to select specific users, but that involves further steps that aren't covered by this guide.
1. **Ready to add trust**: Review your settings to make sure all the URLs are correct.
1. **Finish**:
	Leave the **Configure claims issuance policy for this application** box checked.
	Click **Close** to close the wizard and save your setup.

In the **Actions** sidebar, you should now have a subheading **Buildkite**.

### Step 2.2 Add an issuance transform rule

From the **Buildkite** section of the **Actions** sidebar, click **Edit claim issuance policy...**.

From this point, add three rules, where each one begins with using the **Add Rule** button on the **Issuance transform rules** tab:

Rule 1

1. **Choose rule type**: **Send LDAP Attributes as claims**
1. **Configure claim rule**:
    * **Claim Rule Name**: Get Attributes
    * **Attribute Store**: Active Directory
    * **Mapping of LDAP Attributes to outgoing claim types**:
        - **LDAP Attribute**: Email Addresses, Outgoing claim type: Email address
        - **LDAP Attribute**: Display-Name, Outgoing claim type: Name
1. Click **Finish** to add the rule.

Rule 2

1. **Choose rule type**: **Transform an incoming claim**
1. **Configure claim rule**:
    * **Claim Rule Name**: Name ID Transform
    * **Incoming Claim Type**: Email address
    * **Outgoing Claim Type**: Name ID
    * **Outgoing Name ID Format**: Email
    * Select **Pass through all claim values**
1. Click **Finish** to add the rule.

Rule 3

1. **Choose rule type**: **Send claims using a custom rule**
1. **Configure claim rule**:
    * **Claim Rule Name**: Attribute Name Transform
    * **Custom Rule**:
		  <pre><code>c:[Type == "https://schemas.xmlsoap.org/ws/2005/05/identity/claims/name "]
		  => issue(Type = "Name", Issuer = c.Issuer, OriginalIssuer = c.OriginalIssuer, Value = c.Value, ValueType = c.ValueType);</code></pre>
1. Click **Finish** to add the rule.
1. Click **OK** to save and exit the **Claim Issuance Policy** dialog.

For more information on what other attributes Buildkite accepts, see the [SAML user attributes](#saml-user-attributes) table.

### Step 2.3 Export the token signing certificate

From the **Service** section of the **ADFS** console tree, select the **Certificates** subsection.

1. Click on the certificate listed under the heading **Token-signing**.
1. In the **CN=ADFS Signing** section of the **Actions** sidebar, click **View Certificate...**.
1. In the **Certificate** dialog, select the **Details** tab.
1. Click the **Copy to File...** button.
1. Start the **Certificate Export Wizard**.
1. **Export File Format**: select **Base-64 encoded X.509 (.CER)**.
1. **File to Export**: name your file, and choose where you'd like to export the file
1. Check the settings are correct, and click **Finish**.

### Step 2.4 Update the authentication policy

From the **Service** section of the **ADFS** console tree, select the **Authentication Methods** subsection.

1. Under the **Primary Authentication Methods** header, click the **Edit** link.
1. In the **Intranet** section, ensure that the **Forms Authentication** box is checked.
1. Click **OK** to exit the dialog.

## Step 3. Update your Buildkite SSO provider

On your Buildkite organization settings' **Single Sign On** page, select your ADFS provider from the list of **Configured SSO Providers**.

Click the **Edit Settings** button, choose the **Manual data** option, and enter the IdP data you saved during the previous step:

<table>
    <tr>
        <td>Login URL</td>
        <td>
          The URL where you can log in to your ADFS service. Usually your domain name or IP, with <code>/adfs/ls</code> appended.
        </td>
    </tr>
    <tr>
        <td>Federation Service Identifier</td>
        <td>
            The URL that identifies your ADFS service. Usually your domain name or IP, with <code>/adfs/services/trust</code> appended.
        </td>
    </tr>
    <tr>
        <td>X.509 certificate</td>
        <td>
       	  Attach the X.509 certificate that you downloaded during setup
        </td>
    </tr>
</table>

## Step 4. Perform a test login

Follow the instructions on the provider page to perform a test login. Performing a test login verifies that SSO is working correctly before you activate it for your organization members.

## Step 5. Enable the new SSO provider

Once you've performed a test login you can enable your provider using the **Enable** button. Activating SSO will not force a log out of existing users, but will cause all new or expired sessions to authorize through ADFS before organization data can be accessed.

If you need to edit or update your ADFS provider settings at any time, you will need to disable the provider first. For more information on disabling a provider, see the [disabling SSO](/docs/platform/sso#disabling-and-removing-sso) section of the SSO overview.

## SAML user attributes

<%= render_markdown partial: 'platform/sso/saml_user_attributes' %>
