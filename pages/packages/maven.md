# Maven

Buildkite Packages provides repository support for Maven-based packages for Java.

Once your Java (Maven) package repository has been [created](/docs/packages/manage-repositories#create-a-repository), you can upload packages (generated from your application's build) to this repository by configuring your local `~/.m2/settings.xml` and application's `pom.xml` presented in your Java (Maven) package repository's details page.

To view and copy the required  `~/.m2/settings.xml` and `pom.xml` configurations:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select your Java (Maven) package repository on this page.
1. Expand _Publishing a package_ section and in the _Using Maven_ section, use the copy icon at the top-right of each respective code box to copy the relevant XML snippets.

Note the following:

- The `~/.m2/settings.xml` configuration provides the ID for your specific Java (Maven) package repository in Buildkite and authentication credentials to upload the package to this repository.
- The `pom.xml` configuration references the required Maven plugin (to upload the package), along with the ID and URL for your specific Java (Maven) package repository in Buildkite.

## Publishing a package

The `~/.m2/settings.xml` configuration above is based on this format:

```xml
// Add to '~/.m2/settings.xml' under 'settings' xml tag
<servers>
  <server>
    <id>org-slug-java-maven-package-repository-name</id>
    <password>java-maven-package-repository-credentials</password>
  </server>
</servers>
```

The `pom.xml` configuration above is based on this format:

```xml
// pluginsRepository: maven uses this plugin to push to repository
<pluginRepositories>
  <pluginRepository>
    <id>computology-maven-packagecloud-wagon</id>
    <url>https://packagecloud.io/computology/maven-packagecloud-wagon/maven2</url>           
    <releases>
      <enabled>true</enabled>
    </releases>
  </pluginRepository>
</pluginRepositories>

// distributionManagement: 'maven deploy' pushes to this repository
<distributionManagement>
  <repository>
    <id>org-slug-java-maven-package-repository-name</id>
    <url>https://buildkitepackages.com/{org.slug}/{java.maven.package.repository.name}</url>
  </repository>
  <snapshotRepository>
    <id>org-slug-java-maven-package-repository-name</id>
    <url>https://buildkitepackages.com/{org.slug}/{java.maven.package.repository.name}</url>
  </snapshotRepository>
</distributionManagement>
```
