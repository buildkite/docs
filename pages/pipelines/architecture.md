---
toc: false
---

# Hybrid architecture

In a self-hosted architectural setup, Buildkite Pipelines has a hybrid architecture consisting of the following:

- **Buildkite dashboard:** A software-as-a-service (SaaS) control plane for visualizing and managing CI/CD pipelines. This coordinates work and displays results.
- **Agents:** Small, reliable, and cross-platform build runners. These are hosted by you, either on-premises or in the cloud. They execute the work they receive from the Buildkite dashboard.

The following diagram shows the split in Buildkite between the SaaS platform and the agents running on your infrastructure.

<%= image "buildkite-hybrid-architecture.png", alt: "Shows the hybrid architecture combining a SaaS platform with your infrastructure" %>

The diagram shows that Buildkite provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. By design, sensitive data, such as source code and secrets, remain within your environment and are not seen by Buildkite. This decoupling provides flexibility and security as you maintain control over the build environment and agent scaling while Buildkite manages the coordination, scheduling, and web interface.
