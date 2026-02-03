# Ruby

Buildkite Package Registries provides registry support for Ruby-based (RubyGems) packages.

Once your Ruby source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry using a single command, or by configuring your `~/.gem/credentials` and `gemspec` files.

## Publish a package

The **Publish Instructions** tab of your Ruby source registry includes command/code snippets you can use to publish a package to this registry with a single command, or to configure your environment for publishing packages to this registry on an ongoing basis. To view and copy the required command or `~/.gem/credentials` and `gemspec` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Ruby source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, use the copy icon at the top-right of each respective code box to copy its snippet and paste it into your command line tool or the appropriate file.
1. The following subsections describe the processes in the code boxes above, serving the following use cases:
    * **Quick start** section—for rapid RubyGems package publishing, using a temporary token. See [Single command](#publish-a-package-single-command) for detailed instructions on how to configure this command yourself.
    * **Setup** section—implements configurations for a more permanent RubyGems package publishing solution. See [Ongoing publishing](#publish-a-package-ongoing-publishing) for detailed instructions on how to configure these commands yourself.

### Single command

The first code box provides a quick mechanism for uploading RubyGems package to your Ruby registry.

```bash
GEM_HOST_API_KEY="temporary-write-token-that-expires-after-5-minutes" \
  gem push --host="https://packages.buildkite.com/{org.slug}/{registry.slug}" *.gem
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/ruby_registry_slug' %>

Since the `temporary-write-token-that-expires-after-5-minutes` expires quickly, it is recommended that you just copy this command directly from the **Publish Instructions** page.

### Ongoing publishing

The remaining code boxes on the **Publish Instructions** page provide configurations for a more permanent solution for ongoing RubyGems uploads to your Ruby registry.

1. Copy the following set of commands, paste them and modify as required before running to create your `~/.gem/credentials` file:

    ```bash
    mkdir ~/.gem
    touch ~/.gem/credentials
    chmod 600 ~/.gem/credentials
    echo "https://packages.buildkite.com/{org.slug}/{registry.slug}: registry-write-token" >> ~/.gem/credentials
    ```

    where:
    <%= render_markdown partial: 'package_registries/org_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/ruby_registry_slug' %>
    <%= render_markdown partial: 'package_registries/ecosystems/ruby_registry_write_token' %>

    **Note:** This step only needs to be conducted once for the life of your Ruby source registry.

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

A Ruby package's details can be accessed from this registry through the **Releases** (tab) section of your Ruby source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Ruby source registry on this page.
1. On your Ruby source registry page, select the package within the **Releases** (tab) section. The package's details page is displayed.

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

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
1. Ensure the **Installation** > **Instructions** section is displayed.
1. Copy the command in the code snippet, paste it into your terminal, and run it.

This code snippet is based on this format:

```bash
gem install gem-package-name -v version.number \
  --clear-sources --source https://buildkite:{registry.read.token}@packages.buildkite.com/{org.slug}/{registry.slug}
```

where:

- `gem-package-name` is the name of your RubyGems gem package.

- `version.number` is the version of your RubyGems gem package

- `{registry.read.token}` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Ruby registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization. This URL component, along with its surrounding `buildkite:` and `@` components are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the name of your Ruby registry.
