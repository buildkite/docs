# Buildkite Pipelines architecture

Buildkite Pipelines provides both a [_self-hosted_](#self-hosted-hybrid-architecture) and [_hosted_](#buildkite-hosted-architecture) architecture for its build environments.

## Self-hosted (hybrid) architecture

A self-hosted architecture (also known as a _hybrid_ architecture) separates the following aspects of Buildkite Pipelines' core functionality:

- **Buildkite Pipelines:** A software-as-a-service (SaaS) _control plane_, consisting of the [Buildkite Platform](/docs/platform), as well as its Pipelines product component and interface for visualizing and managing CI/CD pipelines. Buildkite Pipelines coordinates work and displays results.

- **Agents:** Small, reliable, and cross-platform build runners that constitute the _build environment_. In a self-hosted architecture, agents are hosted by you, either on-premises or in the cloud. Agents execute the work they receive from Pipelines.

In this type of hybrid architecture, Buildkite Pipelines runs the control plane (accessible through the main product interface) as a SaaS product, and you run the build environment on your own infrastructure. In other words, Pipelines handles the _orchestration_, and you bring the _compute_. That means you can fine-tune and secure the build environment to suit your particular use case and workflow.

The following diagram shows the split in Pipelines between its SaaS platform and the agents running on your infrastructure.

<%= image "buildkite-hybrid-architecture.png", alt: "Shows the hybrid architecture combining a SaaS platform with your infrastructure" %>

The diagram shows that Buildkite Pipelines provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. By design, sensitive data, such as source code and secrets, remain within your environment and are not seen by the Buildkite Platform. This decoupling provides flexibility and security as you maintain control over the build environment and agent scaling while Buildkite manages the coordination, scheduling, and web interface.

Compared to _fully self-hosted_ solutions, where you run both the control plane and build environment on your own infrastructure, a hybrid architecture reduces the maintenance burden on your team. Unlike managed solutions, a hybrid architecture gives you full control over security within your build environment.

Learn more about how to set up this architecture in the [Custom install](/docs/agent/self-hosted/install) section of the Self-hosted agent documentation.

## Buildkite hosted architecture

Buildkite also provides a _managed_ solution, offered through its _Buildkite hosted agents_ feature, where both the control plane of Buildkite Pipelines and its build environment are provided and handled by Buildkite. This solution is useful when you need to get a build environment up and running quickly or you have limited resources to implement a hybrid architecture, or both.

Learn more about this feature in [Buildkite hosted agents](/docs/agent/buildkite-hosted), and how to set up this architecture in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).
