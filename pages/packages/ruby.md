# Ruby

Buildkite Packages provides registry support for Ruby-based (RubyGems) packages.

Once your Ruby registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry via a single command, or by configuring your `~/.gem/credentials` and `gemspec` files with the code snippets presented on your Ruby registry's details page.

To view and copy the required command or  `~/.gem/credentials` and `gemspec` configurations:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Ruby registry on this page.
1. Select **Publish a Ruby Package** and in the resulting dialog, use the copy icon at the top-right of the relevant code box to copy its snippet and paste it into your command line tool or the appropriate file.

These file configurations contain the following:

- `~/.gem/credentials`: the URL for your specific Ruby registry in Buildkite and the API access token required to publish the package to this registry.
- `gemspec`: the URL for your specific Ruby registry in Buildkite.

## Publish a package

The following subsections describe the processes in the code boxes above, serving the following use cases:

- [Single command](#publish-a-package-single-command)—for rapid RubyGems package publishing, using a temporary token.
- [Ongoing publishing](#publish-a-package-ongoing-publishing)—implements configurations for a more permanent RubyGems package publishing solution.

### Single command

The first code box provides a quick mechanism for uploading RubyGems package to your Ruby registry.

```bash
GEM_HOST_API_KEY="temporary-write-token-that-expires-after-5-minutes" \
  gem push --host="https://packages.buildkite.com/{org.slug}/{registry.slug}" *.gem
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/ruby_registry_slug' %>


Since the `temporary-write-token-that-expires-after-5-minutes` expires quickly, it is recommended that you just copy this command directly from the **Publish a Ruby Package** dialog.

### Ongoing publishing

The remaining code boxes on the **Publish a Ruby Package** dialog provide configurations for a more permanent solution for ongoing RubyGems uploads to your Ruby registry.

1. Copy the following set of commands, paste them and modify as required before running to create your `~/.gem/credentials` file:

    ```bash
    mkdir ~/.gem
    touch ~/.gem/credentials
    chmod 600 ~/.gem/credentials
    echo "https://packages.buildkite.com/{org.slug}/{registry.slug}: registry-write-token" >> ~/.gem/credentials
    ```

    where:
    <%= render_markdown partial: 'packages/org_slug' %>
    <%= render_markdown partial: 'packages/ruby_registry_slug' %>
    <%= render_markdown partial: 'packages/ruby_registry_write_token' %>

    **Note:** This step only needs to be conducted once for the life of your Ruby registry.

1. Copy the following code snippet and paste it to modify the `allowed_push_host` line of your Ruby (gem) package's `.gemspec` file:

    ```conf
    spec.metadata["allowed_push_host"] = "https://packages.buildkite.com/{org.slug}/{registry.slug}"
    ```

    **Note:** This configuration prevents your Ruby package accidentally being published to the main [RubyGems registry](https://rubygems.org/).

1. Publish your Ruby (RubyGems) package:

    ```bash
    gem build *.gemspec
    gem push *.gem
    ```

    Alternatively, if you are using a [Ruby (gem) package created with Bundler](https://bundler.io/guides/creating_gem.html#releasing-the-gem), publish the package this way:

    ```bash
    rake release
    ```

## Access a package's details

A Ruby package's details can be accessed from this registry using the **Packages** section of your Ruby registry page.

To access your Ruby package's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Ruby registry on this page.
1. On your Ruby registry page, select the package within the **Packages** section. The package's details page is displayed.

<%= render_markdown partial: 'packages/package_details_page_sections' %>

A Ruby registry's package also has a **Dependencies** tab, which lists other RubyGems gem packages that your currently viewed Ruby gem package has dependencies on.

### Downloading a package

A Ruby package can be downloaded from the package's details page.

To download a package:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Ruby package can be installed using code snippet details provided on the package's details page.

To install a package:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Installation instructions** section is displayed.
1. Copy the command in the code snippet, paste it into your terminal, and run it.

This code snippet is based on this format:

```bash
gem install gem-package-name -v version.number \
  --clear-sources --source https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}
```

where:

- `gem-package-name` is the name of your RubyGems gem package.

- `version.number` is the version of your RubyGems gem package

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/packages/manage-registries#update-a-registry-configure-registry-tokens) used to download packages to your Ruby registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'packages/org_slug' %>

- `{registry.slug}` is the name of your Ruby registry.
