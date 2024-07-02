# Alpine

Buildkite Packages provides registry support for Alpine-based (apk) packages for Alpine Linux operating systems.

Once your Alpine registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry via the relevant `curl` command presented on your Alpine registry's details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Alpine registry on this page.
1. Select **Publish an Alpine Package** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and submit it to publish a package to your Alpine registry.

This command provides:

- The specific URL to publish a package to your specific Alpine registry in Buildkite.
- The API write token required to publish packages to your Alpine registry.
- The Alpine package file to be published.

## Publish a package

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a package to your Alpine registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/alpine_registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Alpine registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'packages/path_to_file' %>

For example, to upload the file `my-alpine-package_0.1.1_r0.apk` from the current directory to the **My Alpine packages** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-alpine-packages/packages \
  -H "Authorization: Bearer $REPLACE_WITH_MY_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-alpine-package_0.1.1_r0.apk"
```
