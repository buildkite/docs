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

_Buildkite Package Registries_ was previously called _Buildkite Packages_.

## Get started

Run through the [Getting started](/docs/package-registries/getting-started) tutorial for a step-by-step guide on how to use Buildkite Package Registries.

If you're familiar with the basics, explore how to use registries for each of Buildkite Package Registries' supported package ecosystems:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":alpine: Alpine (apk)", "/docs/package-registries/alpine" %>
  <%= button ":docker: Container (Docker)", "/docs/package-registries/container" %>
  <%= button ":debian: Debian/Ubuntu (deb)", "/docs/package-registries/debian" %>
  <%= button ":package: Files (generic)", "/docs/package-registries/files" %>
  <%= button ":helm: Helm (OCI)", "/docs/package-registries/helm-oci" %>
  <%= button ":helm: Helm", "/docs/package-registries/helm" %>
  <%= button ":maven: Java (Maven)", "/docs/package-registries/maven" %>
  <%= button ":gradle: Java (Gradle)", "/docs/package-registries/gradle" %>
  <%= button ":node: JavaScript (npm)", "/docs/package-registries/javascript" %>
  <%= button ":python: Python (PyPI)", "/docs/package-registries/python" %>
  <%= button ":redhat: Red Hat (RPM)", "/docs/package-registries/red-hat" %>
  <%= button ":ruby: Ruby (RubyGems)", "/docs/package-registries/ruby" %>
  <%= button ":terraform: Terraform (modules)", "/docs/package-registries/terraform" %>
</div>

<!-- vale on -->

Learn more about how to:

- Work with registries in [Manage registries](/docs/package-registries/manage-registries).
- Manage access to your registries in [User, team, and registry permissions](/docs/package-registries/security/permissions).
- Configure your own private storage for Buildkite Package Registries in [Private storage](/docs/package-registries/private-storage).
