---
template: "landing_page"
---

# Buildkite Packages

Scale out asset management across any ecosystem with Buildkite Packages. Avoid the bottleneck of poorly managed and insecure dependencies.

Buildkite Packages allows you to:

- Manage artifacts and packages from [Buildkite Pipelines](/docs/pipelines), as well as other CI/CD applications that require artifact management.

- Provide registries to store your [packages and other package-like file formats](/docs/packages/background) such as container images and Terraform modules.

As well as storing a collection of packages, a registry also surfaces metadata or attributes associated with a package, such as the package's description, version, contents (files and directories), checksum details, distribution type, dependencies, and so on.

> 📘
> You can enable [Buildkite Packages](https://buildkite.com/packages) through the [**Organization Settings** page](/docs/packages/permissions#enabling-buildkite-packages).

## Get started

Run through the [Getting started](/docs/packages/getting-started) tutorial for a step-by-step guide on how to use Buildkite Packages.

If you're familiar with the basics, explore how to use registries for each of Buildkite Packages' supported package ecosystems:

<!-- vale off -->

<div class="ButtonGroup">
  <%= button ":alpine: Alpine (apk)", "/docs/packages/alpine" %>
  <%= button ":docker: Container (Docker)", "/docs/packages/container" %>
  <%= button ":debian: Debian/Ubuntu (deb)", "/docs/packages/debian" %>
  <%= button ":helm: Helm (OCI)", "/docs/packages/helm-oci" %>
  <%= button ":helm: Helm", "/docs/packages/helm" %>
  <%= button ":maven: Java (Maven)", "/docs/packages/maven" %>
  <%= button ":gradle: Java (Gradle)", "/docs/packages/gradle" %>
  <%= button ":node: JavaScript (npm)", "/docs/packages/javascript" %>
  <%= button ":python: Python (PyPI)", "/docs/packages/python" %>
  <%= button ":redhat: Red Hat (RPM)", "/docs/packages/red-hat" %>
  <%= button ":ruby: Ruby (RubyGems)", "/docs/packages/ruby" %>
  <%= button ":terraform: Terraform (modules)", "/docs/packages/terraform" %>
  <%= button ":package: Files (generic)", "/docs/packages/files" %>
</div>

<!-- vale on -->

Learn more about how to:

- Work with Buildkite Packages registries in [Manage registries](/docs/packages/manage-registries).
- Manage access to your registries in [User, team, and registry permissions](/docs/packages/permissions).
- Configure your own private storage for Buildkite Packages in [Private storage](/docs/packages/private-storage).
