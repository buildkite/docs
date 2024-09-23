---
template: "landing_page"
---

# Buildkite Package Registries

Scale out asset management across any ecosystem with Buildkite Package Registries. Avoid the bottleneck of poorly managed and insecure dependencies.

Buildkite Package Registries allows you to:

- Manage artifacts and packages from [Buildkite Pipelines](/docs/pipelines), as well as other CI/CD applications that require artifact management.

- Provide registries to store your [packages and other package-like file formats](/docs/packages/background) such as container images and Terraform modules.

As well as storing a collection of packages, a registry also surfaces metadata or attributes associated with a package, such as the package's description, version, contents (files and directories), checksum details, distribution type, dependencies, and so on.

> 📘
> You can enable [Buildkite Package Registries](https://buildkite.com/packages) through the [**Organization Settings** page](/docs/packages/permissions#enabling-buildkite-packages).

_Buildkite Packages Registries_ was previously called _Buildkite Packages_.

## Get started

Run through the [Getting started](/docs/packages/getting-started) tutorial for a step-by-step guide on how to use Buildkite Package Registries.

If you're familiar with the basics, explore how to use registries for each of Buildkite Package Registries' supported package ecosystems:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":alpine: Alpine (apk)", "/docs/packages/alpine" %>
  <%= button ":docker: Container (Docker)", "/docs/packages/container" %>
  <%= button ":debian: Debian/Ubuntu (deb)", "/docs/packages/debian" %>
  <%= button ":package: Files (generic)", "/docs/packages/files" %>
  <%= button ":helm: Helm (OCI)", "/docs/packages/helm-oci" %>
  <%= button ":helm: Helm", "/docs/packages/helm" %>
  <%= button ":maven: Java (Maven)", "/docs/packages/maven" %>
  <%= button ":gradle: Java (Gradle)", "/docs/packages/gradle" %>
  <%= button ":node: JavaScript (npm)", "/docs/packages/javascript" %>
  <%= button ":python: Python (PyPI)", "/docs/packages/python" %>
  <%= button ":redhat: Red Hat (RPM)", "/docs/packages/red-hat" %>
  <%= button ":ruby: Ruby (RubyGems)", "/docs/packages/ruby" %>
  <%= button ":terraform: Terraform (modules)", "/docs/packages/terraform" %>
</div>

<!-- vale on -->

Learn more about how to:

- Work with registries in [Manage registries](/docs/packages/manage-registries).
- Manage access to your registries in [User, team, and registry permissions](/docs/packages/permissions).
- Configure your own private storage for Buildkite Package Registries in [Private storage](/docs/packages/private-storage).
