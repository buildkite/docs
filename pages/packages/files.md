
# Files

Buildkite Package Registries provides registry support for generic files to cover some cases where native package management isn't required.

Once your Files registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload files (of any type and extension) to this registry via the relevant `curl` command presented on your registry details page.

To view and copy this `curl` command:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your registry on this page.
1. Select **Publish a File** and in the resulting dialog, use the copy icon at the top-right of the code box to copy this `curl` command and run it to publish a file to your registry.

This command provides:

- The specific URL to publish a file to your specific registry in Buildkite.
- The API access token required to publish files to your registry.
- The file to be published.

## Publish a file

The following `curl` command (which you'll need to modify as required before submitting) describes the process above to publish a file to your registry:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/{org.slug}/registries/{registry.slug}/packages \
  -H "Authorization: Bearer $REGISTRY_WRITE_TOKEN" \
  -F "file=@<path_to_file>"
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/registry_slug' %>

- `$REGISTRY_WRITE_TOKEN` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload files to your registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish files to any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'packages/path_to_file' %>

For example, to upload the file `my-custom-app.ipa` from the current directory to the **My files** registry in the **My organization** Buildkite organization, run the `curl` command:

```bash
curl -X POST https://api.buildkite.com/v2/packages/organizations/my-organization/registries/my-files/packages \
  -H "Authorization: Bearer $REPLACE_WITH_YOUR_REGISTRY_WRITE_TOKEN" \
  -F "file=@my-custom-app.ipa"
```

## Access a file's details

The file details can be accessed from this registry using the **Packages** section of your registry page.

To access your file details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your registry on this page.
1. On your registry page, select the file to display its details page.

<%= render_markdown partial: 'packages/file_details_page_sections' %>

### Downloading a file

The file can be downloaded from the file details page. To do this:

1. [Access the file's details](#access-a-files-details).
1. Select **Download**.

Or; a file can be installed via the command line using code snippet details provided on the file details page. To do this:

1. [Access the file's details](#access-a-files-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and run it.
