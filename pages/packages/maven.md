# Maven

Buildkite Packages provides registry support for Maven-based Java packages.

Once your Java registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry by configuring your `~/.m2/settings.xml` and application's relevant `pom.xml` files with the Maven XML snippets presented on your Java registry's details page.

To view and copy the required  `~/.m2/settings.xml` and `pom.xml` configurations:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Java registry on this page.
1. Select **Publish a Java Package** and in the resulting dialog's **Using Maven** section, use the copy icon at the top-right of each respective code box to copy the relevant XML snippet and paste it into its appropriate file.

These file configurations contain the following:

- `~/.m2/settings.xml`: the ID for your specific Java registry in Buildkite and the API access token required to publish the package to this registry.
- `pom.xml`: the ID and URL for your specific Java registry in Buildkite.

## Publish a package

The following steps describe the process above:

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
    * `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Java registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

    <%= render_markdown partial: 'packages/java_registry_id' %>

    **Note:** This step only needs to be performed once for the life of your Java registry, and API access token.

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
    * `org-slug-registry-slug` is the ID of your Java registry (above).

    <%= render_markdown partial: 'packages/org_slug' %>

    <%= render_markdown partial: 'packages/java_registry_slug' %>

1. Publish your package:

    ```bash
    mvn deploy
    ```

## Access a package's details

<%= render_markdown partial: 'packages/access_java_package_details_page' %>

<%= render_markdown partial: 'packages/package_details_page_sections' %>

### Downloading a package

A Java package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Java package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Installation instructions** section is displayed.
1. Copy each code snippet, and paste them into their respective `~/.m2/settings.xml` and `pom.xml` files (under the `project` XML tag), and run `mvn install` on this modified `pom.xml` to install this package.

    **Note:** The `~/.m2/settings.xml` configuration:
    * Is _not_ required if your registry is publicly accessible.
    * Only needs to be performed once for the life of your Java registry.

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

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/packages/manage-registries#update-a-registry-configure-registry-tokens) used to download packages from your Java registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

<%= render_markdown partial: 'packages/java_registry_id' %>

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

<%= render_markdown partial: 'packages/java_registry_id' %>

- `{org.slug}` is the org slug.

<%= render_markdown partial: 'packages/java_registry_slug' %>

<%= render_markdown partial: 'packages/java_package_domain_name_version' %>
