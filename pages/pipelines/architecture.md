---
toc: false
---

# Understand the architecture

Before creating a pipeline, take a moment to understand Buildkite's architecture and the advantages it provides.

Buildkite uses a hybrid model consisting of the following:

- **Buildkite dashboard:** A software-as-a-service (SaaS) control panel for visualizing and managing CI/CD pipelines. This coordinates work and displays results.
- **Agents:** Small, reliable, and cross-platform build runners. These are hosted by you, either on-premise or in the cloud. They execute the work they receive from the Buildkite dashboard.

The following diagram shows the split in Buildkite between the SaaS platform and the agents running on your infrastructure.

<%= image "buildkite-hybrid-architecture.png", alt: "Shows the hybrid architecture combining a SaaS platform with your infrastructure" %>

The diagram shows that Buildkite provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. By design, sensitive data, such as source code and secrets, remain within your environment and are not seen by Buildkite. This decoupling provides flexibility and security as you maintain control over the build environment and agent scaling while Buildkite manages the coordination, scheduling, and web interface.
