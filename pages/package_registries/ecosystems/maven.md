# Maven

Buildkite Package Registries provides registry support for Maven-based Java packages.

Once your Java source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry by configuring your `~/.m2/settings.xml` and application's relevant `pom.xml` files.

## Publish a package

The **Publish Instructions** tab of your Java source registry includes Maven XML snippets you can use to configure your environment for publishing packages to this registry. To view and copy the required `~/.m2/settings.xml` and `pom.xml` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Java source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, in the **Using Maven** section, select **Maven** to expand this section.
1. Use the copy icon at the top-right of each respective code box to copy the relevant XML snippets and paste it into its appropriate file.

    These file configurations contain the following:
    * `~/.m2/settings.xml`: the ID for your specific Java source registry in Buildkite and a temporary API access token required to publish the package to this registry.
    * `pom.xml`: the ID and URL for this source registry.

1. You can then run the `mvn deploy` command to publish the package to this source registry.

### Detailed instructions

You can also configure these files yourself (modifying the snippets as required), by following these detailed instructions.

1. Copy the following XML snippet, paste it into your `~/.m2/settings.xml` file, and modify accordingly:

    ```xml
    <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
        http://maven.apache.org/xsd/settings-1.0.0.xsd">
      <servers>
        <server>
          <id>org-slug-registry-slug</id>
          <configuration>
            <httpHeaders>
              <property>
                <name>Authorization</name>
                <value>Bearer registry-write-token</value>
              </property>
            </httpHeaders>
          </configuration>
        </server>
      </servers>
    </settings>
    ```

    where:
    <%= render_markdown partial: 'package_registries/ecosystems/java_registry_id' %>

    <%= render_markdown partial: 'package_registries/ecosystems/java_registry_write_token' %>

    **Note:** This step only needs to be performed once for the life of your Java source registry, and API access token.

1. Copy the following XML snippet, paste it into your `pom.xml` configuration file, and modify accordingly:

    ```xml
    <distributionManagement>
      <repository>
        <id>org-slug-registry-slug</id>
        <url>https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/</url>
      </repository>
      <snapshotRepository>
        <id>org-slug-registry-slug</id>
        <url>https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/</url>
      </snapshotRepository>
    </distributionManagement>
    ```

    where:
    * `org-slug-registry-slug` is the ID of your Java source registry (above).

    <%= render_markdown partial: 'package_registries/org_slug' %>

    <%= render_markdown partial: 'package_registries/ecosystems/java_registry_slug' %>

1. Publish your package:

    ```bash
    mvn deploy
    ```

## Access a package's details

<%= render_markdown partial: 'package_registries/ecosystems/access_java_package_details_page' %>

<%= render_markdown partial: 'package_registries/ecosystems/package_details_page_sections' %>

### Downloading a package

A Java package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

<h3 id="access-a-packages-details-installing-a-package"></h3>

### Installing a package from a source registry

A Java package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** tab is displayed and select the **Maven** section to expand it.
1. Copy each code snippet, and paste them into their respective `~/.m2/settings.xml` and `pom.xml` files (under the `project` XML tag), modifying the required values accordingly.

    **Note:** The `~/.m2/settings.xml` configuration:
    * Is _not_ required if your registry is publicly accessible.
    * Only needs to be performed once for the life of your Java registry.

    You can then run `mvn install` on this modified `pom.xml` to install this package.

The `~/.m2/settings.xml` code snippet is based on this format:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
    http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>org-slug-registry-slug</id>
      <configuration>
        <httpHeaders>
          <property>
            <name>Authorization</name>
            <value>Bearer registry-read-token</value>
          </property>
        </httpHeaders>
      </configuration>
    </server>
  </servers>
</settings>
```

where:

<%= render_markdown partial: 'package_registries/ecosystems/java_registry_id' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Java source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

The `pom.xml` code snippet is based on this format:

```xml
<repositories>
  <repository>
    <id>org-slug-registry-slug</id>
    <url>https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/</url>
    <releases>
      <enabled>true</enabled>
    </releases>
    <snapshots>
      <enabled>true</enabled>
    </snapshots>
  </repository>
</repositories>

<dependencies>
  <dependency>
    <groupId>com.name.domain.my</groupId>
    <artifactId>my-java-package-name</artifactId>
    <version>my-java-package-version</version>
  </dependency>
</dependencies>
```

where:

<%= render_markdown partial: 'package_registries/ecosystems/java_registry_id' %>

- `{org.slug}` is the org slug, which can be obtained as described above.

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/java_package_domain_name_version' %>
