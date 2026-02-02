# Alpine

Buildkite Package Registries provides registry support for Alpine-based (apk) packages for Alpine Linux operating systems.

Once your Alpine source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry.

## Publish a package

You can use two approaches to publish an apk package to your Alpine source registry—[`curl`](#publish-a-package-using-curl) or the [Buildkite CLI](#publish-a-package-using-the-buildkite-cli).

### Using curl

The **Publish Instructions** tab of your Alpine source registry includes a `curl` command you can use to upload a package to this registry. To view and copy this `curl` command:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Alpine source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of the relevant code box to copy this `curl` command and run it (with the appropriate values) to publish the package to this source registry.

This command provides:

- The specific URL to publish a package to your specific Alpine source registry in Buildkite.
- A temporary API access token required to publish packages to this source registry.
- The Alpine package file to be published.

You can also create this command yourself using the following `curl` command (which you'll need to modify as required before submitting):

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@path/to/alpine/package.apk"
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Alpine source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Alpine source registry from the **Registries** page.

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Alpine source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish packages to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Alpine source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/ecosystems/path_to_alpine_package' %>

For example, to upload the file `my-alpine-package_0.1.1_r0.apk` from the current directory to the **My Alpine packages** source registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-alpine-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-alpine-package_0.1.1_r0.apk"
```

### Using the Buildkite CLI

The following [Buildkite CLI](/docs/platform/cli) command can also be used to publish an apk package to your Alpine source registry from your local environment, once it has been [installed](/docs/platform/cli/installation) and [configured with an appropriate token](#token-usage-with-the-buildkite-cli):

```bash
bk package push registry-slug path/to/alpine/package.apk
```

where:

- `registry-slug` is the slug of your Alpine source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Alpine source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/path_to_alpine_package' %>

<h4 id="token-usage-with-the-buildkite-cli">Token usage with the Buildkite CLI</h4>

<%= render_markdown partial: 'package_registries/ecosystems/buildkite_cli_token_usage' %>

## Access a package's details

An Alpine (apk) package's details can be accessed from its source registry through the **Releases** (tab) section of your Alpine source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Alpine source registry on this page.
1. On your Alpine source registry page, select the package to display its details page.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

An Alpine (apk) package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

An Alpine package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

**Step 1**: Configure your Alpine registry as the source for your Alpine (apk) packages:

```bash
echo "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/alpine_any/alpine_any/main" >> /etc/apk/repositories
```

where:

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Alpine registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

**Step 2**: Install the registry signing key:

```bash
wget -O /etc/apk/keys/{org.uuid}_{registry.uuid}.rsa.pub "https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}/rsakey"
```

where:

- `{org.uuid}` is the UUID of your Buildkite organization. This value can be obtained from this Alpine package **Instructions** page section. Alternatively, you can also obtain this value:
    * From your organization's **Pipeline Settings** page. To do this:
        1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.
        1. Select **Pipelines** > **Settings** to access the [**Pipeline Settings**](https://buildkite.com/organizations/~/pipeline-settings) page.
        1. At the end of the page, copy the value from the **Organization UUID** field.

    * By running the `getCurrentUsersOrgs` [GraphQL](/docs/apis/graphql-api) query to obtain the relevant organization UUID value in the response for the current user's accessible organizations:

        ```graphql
        query getCurrentUsersOrgs {
          viewer {
            organization {
              edges {
                node {
                  name
                  id
                  uuid
                }
              }
            }
          }
        }
        ```

- `{registry.uuid}` is the UUID of your Alpine registry. Again, this value can be obtained from this Alpine package **Instructions** page section. Alternatively, you can also obtain this value:
    * From your registry's **Settings** page. To do this:
        1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.
        1. Select your Alpine registry on this page.
        1. Select **Settings** to open the registry's **Settings** page.
        1. Copy the **UUID** shown in the **API Integration** section of this page, which is this `{registry.uuid}` value.

    * By running the `getOrgRegistries` GraphQL query to obtain the registry UUID values of your `{org.slug}` in the response:

        ```graphql
        query getOrgRegistries {
          organization(slug: "{org.slug}") {
            registries(first: 20) {
              edges {
                node {
                  name
                  id
                  uuid
                }
              }
            }
          }
        }
        ```

- `buildkite:{registry.read.token}@` while these values are the same as those in the previous step for configuring your source Alpine registry, this component is not required for registries that are publicly accessible.

**Step 3**: Retrieve the latest apk indices:

```bash
apk update
```

#### Package installation

Use `apk` to install the package:

```bash
apk add package-name==version-number
```

where:

- `package-name` is the name of your package.

- `version-numnber` is the version number of this package.
