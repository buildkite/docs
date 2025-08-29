# Gradle (Groovy)

Buildkite Package Registries provides registry support for Gradle-based Java packages (using the [Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)), using the Gradle Groovy DSL. If you're using Kotlin, refer to the [Gradle (Kotlin)](/docs/package-registries/ecosystems/gradle-kotlin) page.

Once your Java source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry by configuring your `build.gradle` file with the Gradle snippet presented on your Java registry's details page.

To view and copy the required `build.gradle` configurations:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Java source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, in the **Using Gradle with `maven-publish` plugin** section, select **Gradle (Groovy)** to expand this section.
1. Use the copy icon at the top-right of the code box to copy the Gradle code snippet and paste it into the appropriate area/s of your `build.gradle` file.

    These `build.gradle` file configurations contain the:
    <%= render_markdown partial: 'package_registries/ecosystems/gradle_file_configurations' %>

1. You can then run the `gradle publish` command to publish the package to this source registry.

## Publish a package

The following steps describe the process above:

1. Copy the following Gradle (Groovy) snippet, paste it into your `build.gradle` file, and modify accordingly:

    ```gradle
    plugins {
        id 'java'          // To publish java libraries
        id 'maven-publish' // To publish to Maven repositories
    }

    // Download standard plugins, e.g., maven-publish  from GradlePluginPortal
    repositories {
      gradlePluginPortal()
    }

    // Define Maven repository to publish to
    publishing {
      publications {
        maven(MavenPublication) {

          // MODIFY: Define your Maven coordinates of your package
          groupId = "com.name.domain.my"
          artifactId = "my-java-package-name"
          version = "my-java-package-version"

          // Tell gradle to publish project's jar archive
          from components.java
        }
      }

      repositories {
        maven {
          // Define the Buildkite repository to publish to
          url "https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/"
          authentication {
            header(HttpHeaderAuthentication)
          }
          credentials(HttpHeaderCredentials) {
            name = "Authorization"
            value = "Bearer registry-write-token"
          }
        }
      }
    }
    ```

    where:
    <%= render_markdown partial: 'package_registries/ecosystems/java_package_domain_name_version' %>

    <%= render_markdown partial: 'package_registries/org_slug' %>

    <%= render_markdown partial: 'package_registries/ecosystems/java_registry_slug' %>

    <%= render_markdown partial: 'package_registries/ecosystems/java_registry_write_token' %>

1. Publish your package:

    ```bash
    gradle publish
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
1. Ensure the **Installation** tab is displayed and select the **Gradle (Groovy)** section to expand it.
1. Copy the code snippet, paste this into the `build.gradle` Gradle file, and modify the required values accordingly.

    You can then run `gradle install` on this modified script file to install this package.

This code snippet is based on this format:

```gradle
repositories {
  maven {
    url "https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/"
    authentication {
      header(HttpHeaderAuthentication)
    }
    credentials(HttpHeaderCredentials) {
      name = "Authorization"
      value = "Bearer registry-read-token"
    }
  }
}

dependencies {
  implementation "com.name.domain.my:my-java-package-name:my-java-package-version"
}
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Java source registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

    **Note:** Both the `authentication` and `credentials` sections are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/ecosystems/java_package_domain_name_version' %>

### Installing a package from a composite registry

If your Java source registry is an upstream of a [composite registry](/docs/package-registries/registries/manage#composite-registries), you can install one of its packages using the code snippet details provided on the composite registry's **Setup & Usage** page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Java composite registry on this page.
1. Select the **Setup & Usage** tab to display the **Usage Instructions** page.
1. Select the **Gradle (Groovy)** tab.
1. Copy the relevant code snippets, and paste them into the `build.gradle` Gradle file, modifying their values as required. Learn more about this is [Configuring the `build.gradle` Gradle file](#configuring-the-build-dot-gradle-gradle-file), below.

    To install packages from any of this composite registry's configured upstreams, define each of these packages in their own `implementation` line within `dependencies { }` of your `build.gradle` Gradle file, as you would when [installing packages from a source registry](#access-a-packages-details-installing-a-package-from-a-source-registry), and run `gradle install` on this modified script file.

<h4 id="configuring-the-build-dot-gradle-gradle-file">Configuring the build.gradle Gradle file</h4>

The `build.gradle` code snippet is based on this format:

```gradle
repositories {
  // ...
  maven {
    url "https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/"
    authentication {
      header(HttpHeaderAuthentication)
    }
    credentials(HttpHeaderCredentials) {
      name = "Authorization"
      value = "Bearer registry-read-token"
    }
  }
}
```

where:

<%= render_markdown partial: 'package_registries/org_slug' %>

<%= render_markdown partial: 'package_registries/ecosystems/registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/registries/manage#configure-registry-tokens) used to download packages from your Java composite registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

    To avoid having to store the actual token value in this file (and mitigate its exposure to continuous integration environments), you can reference it using an environment variable. For example, if you set this token value in the environment variable `REGISTRY_READ_TOKEN`, like:

    ```bash
    export REGISTRY_READ_TOKEN="YOUR-ACTUAL-TOKEN-VALUE"
    ```

    you can reference this in the `value` field above as:

    ```gradle
    value = "Bearer ${System.getenv('REGISTRY_READ_TOKEN')}"
    ```

If you have added the official public registry to this Java composite registry, ensure that any references to the default `mavenCentral()` repository (in your `build.gradle` or other relevant `.gradle` files) have been removed, since Buildkite Package Registries itself handles the connection to the Maven Central repository through your Java composite registry.
