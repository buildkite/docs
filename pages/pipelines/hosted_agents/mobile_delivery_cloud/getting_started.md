# Getting started with Mobile Delivery Cloud

👋 Welcome to Buildkite Mobile Delivery Cloud! You can use Mobile Delivery Cloud to help you run CI/CD pipelines to build your mobile apps, and track and analyze automated tests, as well as house your built mobile app artifacts within appropriate registries, all within a matter of steps.

Kotlin test:

```kotlin
plugins {
  `maven-publish`
  `java-library`
}

publishing {
  publications {
      create<MavenPublication>("maven") {
          // MODIFY: Define your Maven coordinates of your package
          groupId = "com.your_domain_name"
          artifactId = "your_package_name"
          version = "your_package_version"

          from(components["java"])
      }
  }

  repositories {
    maven {
      url = uri("https://packages.buildkite.com/{org.slug}/{registry.slug}/maven2/")
      authentication {
        create<HttpHeaderAuthentication>("header")
      }

      credentials(HttpHeaderCredentials::class) {
        name = "Authorization"
        value = "Bearer $TOKEN"
      }
    }
  }
}
```
