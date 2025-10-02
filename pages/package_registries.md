---
template: "landing_page"
---

# Buildkite Package Registries

Scale out asset management for faster builds and deployments across any ecosystem with _Buildkite Package Registries_. Secure your supply chain and avoid the bottlenecks of poorly managed and insecure dependencies.

Package Registries allows you to:

- Manage artifacts and packages from [Buildkite Pipelines](/docs/pipelines), as well as other CI/CD applications that require artifact management.

- Provide registries to store your [packages and other package-like file formats](/docs/package-registries/background) such as container images and Terraform modules.

As well as storing a collection of packages, a registry also surfaces metadata or attributes associated with a package, such as the package's description, version, contents (files and directories), checksum details, distribution type, dependencies, and so on.

> 📘
> Customers on legacy Buildkite plans can enable [Package Registries](https://buildkite.com/platform/package-registries) through the [**Organization Settings** page](/docs/package-registries/security/permissions#enabling-buildkite-packages).

## Get started

Run through the [Getting started](/docs/package-registries/getting-started) tutorial for a step-by-step guide on how to use Buildkite Package Registries.

If you're familiar with the basics, explore how to use registries for each of Buildkite Package Registries' supported package ecosystems:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":alpine: Alpine (apk)", "/docs/package-registries/ecosystems/alpine" %>
  <%= button ":docker: OCI (Docker)", "/docs/package-registries/ecosystems/oci" %>
  <%= button ":debian: Debian/Ubuntu (deb)", "/docs/package-registries/ecosystems/debian" %>
  <%= button ":package: Files (generic)", "/docs/package-registries/ecosystems/files" %>
  <%= button ":helm: Helm (OCI)", "/docs/package-registries/ecosystems/helm-oci" %>
  <%= button ":helm: Helm", "/docs/package-registries/ecosystems/helm" %>
  <%= button ":hugging_face: Hugging Face (models)", "/docs/package-registries/ecosystems/hugging-face" %>
  <%= button ":maven: Java (Maven)", "/docs/package-registries/ecosystems/maven" %>
  <%= button ":gradle: Java (Gradle)", "/docs/package-registries/ecosystems/gradle-kotlin" %>
  <%= button ":node: JavaScript (npm)", "/docs/package-registries/ecosystems/javascript" %>
  <%= button ":nuget: NuGet", "/docs/package-registries/ecosystems/nuget" %>
  <%= button ":python: Python (PyPI)", "/docs/package-registries/ecosystems/python" %>
  <%= button ":redhat: Red Hat (RPM)", "/docs/package-registries/ecosystems/red-hat" %>
  <%= button ":ruby: Ruby (RubyGems)", "/docs/package-registries/ecosystems/ruby" %>
  <%= button ":terraform: Terraform (modules)", "/docs/package-registries/ecosystems/terraform" %>
</div>

<!-- vale on -->

## Core features

<%= tiles "package_registries_features" %>

## API & references

Learn more about:

- Package Registries' APIs through the:
    * [REST API documentation](/docs/apis/rest-api), and related endpoints, starting with [registries](/docs/apis/rest-api/package-registries/registries).
    * [GraphQL documentation](/docs/apis/graphql-api) and its [registries](/docs/apis/graphql/cookbooks/registries)-related queries, as well as [portals](/docs/apis/portals).
- Package Registries' [webhooks](/docs/apis/webhooks/package-registries).
