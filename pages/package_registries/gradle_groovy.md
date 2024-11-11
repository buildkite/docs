# Gradle (Groovy)

Buildkite Package Registries provides registry support for Gradle-based Java packages (using the [Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)), using the Gradle Groovy DSL. If you're using Kotlin, refer to the [Gradle (Kotlin)](/docs/package-registries/gradle-kotlin) page.

Once your Java registry has been [created](/docs/package-registries/manage-registries#create-a-registry), you can publish/upload packages (generated from your application's build) to this registry by configuring your `build.gradle` file with the Gradle snippet presented on your Java registry's details page.

To view and copy the required `build.gradle` configurations:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your Java registry on this page.
1. Select **Publish a Java Package** and in the resulting dialog's `Using Gradle with maven-publish plugin` section, use the copy icon at the top-right of the code box to copy the Gradle code snippet and paste it into the appropriate area/s of your `build.gradle` file.

These `build.gradle` file configurations contain the:

<%= render_markdown partial: 'package_registries/gradle_file_configurations' %>

## Publish a package

The following steps describe the process above:

1. Copy the following Gradle snippet, paste it into your `build.gradle` file, and modify accordingly:

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
    * `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your Java registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

    <%= render_markdown partial: 'package_registries/java_package_domain_name_version' %>

    <%= render_markdown partial: 'package_registries/org_slug' %>

    <%= render_markdown partial: 'package_registries/java_registry_slug' %>

1. Publish your package:

    ```bash
    gradle publish
    ```

## Access a package's details

<%= render_markdown partial: 'package_registries/access_java_package_details_page' %>

<%= render_markdown partial: 'package_registries/package_details_page_sections' %>

### Downloading a package

A Java package can be downloaded from the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Select **Download**.

### Installing a package

A Java package can be installed using code snippet details provided on the package's details page. To do this:

1. [Access the package's details](#access-a-packages-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. Copy the code snippet, paste this into the `build.gradle` Gradle file, and run `gradle install` on this modified script file to install this package.

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

- `{org.slug}` is the org slug.

<%= render_markdown partial: 'package_registries/java_registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) or [registry token](/docs/package-registries/manage-registries#update-a-registry-configure-registry-tokens) used to download packages from your Java registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

    **Note:** Both the `authentication` and `credentials` sections are not required for registries that are publicly accessible.

<%= render_markdown partial: 'package_registries/java_package_domain_name_version' %>
