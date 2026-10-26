---
description: "Compare self-hosted and Buildkite hosted agents, understand how jobs run, and choose setup and security guides for Buildkite Pipelines."
---

# Buildkite Pipelines architecture

Buildkite Pipelines schedules your builds through a hosted _control plane_. Your jobs run on [agents](/docs/agent), either on infrastructure you manage or on Buildkite hosted infrastructure. Choose the build environment that fits your infrastructure, customization, and security requirements.

## Choose your build environment

Both models use the same Buildkite Pipelines interface to configure pipelines and view results. The difference is who manages the infrastructure that runs your jobs.

Requirement | Self-hosted agents | Buildkite hosted agents
----------- | ------------------ | -----------------------
Infrastructure management | You provision, scale, and maintain the build machines | Buildkite provisions, scales, and maintains the build machines
Build environment | Your own cloud or on-premises infrastructure | Buildkite-managed infrastructure
Typical use case | You need control over machine configuration or access to your private network | You want to run builds without managing agent infrastructure
Setup | [Install a self-hosted agent](/docs/agent/self-hosted/install) | [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue)
{: class="responsive-table"}

For platform support, scaling options, and configuration differences, see [Self-hosted and Buildkite hosted agents compared](/docs/agent#self-hosted-and-buildkite-hosted-agents-compared).

## How a build runs

The Buildkite Pipelines control plane coordinates the build. Agents execute its jobs:

1. A source-control event or another build trigger starts a build.
1. Buildkite Pipelines makes jobs available to agents in the targeted [queues](/docs/agent/queues).
1. An agent accepts a job, checks out the source code, and runs the job's commands.
1. The agent streams logs, uploads configured artifacts, and reports the result.

Agents connect to the control plane over HTTPS. Self-hosted agents do not require inbound firewall access for this connection. For details, see [How the agent works](/docs/agent#how-it-works).

## Self-hosted (hybrid) architecture

In a self-hosted, or _hybrid_, architecture, Buildkite Pipelines manages the control plane and you manage the agents. You choose the hardware, operating systems, installed tools, network access, and scaling strategy for your build environment.

The following diagram shows the split in Pipelines between its hosted control plane and the agents running on your infrastructure.

<%= image "buildkite-hybrid-architecture.png", width: 1504/2, height: 896/2, alt: "Buildkite manages the control plane, web interface, and integrations; agents execute jobs on your infrastructure" %>

Your agents check out and execute source code in your environment. Agents send job logs and build results to Buildkite and upload artifacts to your configured storage. Source code or secrets included in those outputs can leave your environment. Review the [shared security responsibilities](/docs/platform/security#shared-responsibility) to understand which data is transmitted and which controls your organization manages.

Unlike a fully self-hosted CI/CD system, you do not need to operate or update the control plane. You remain responsible for provisioning, securing, and maintaining your agent infrastructure.

## Buildkite hosted architecture

With [Buildkite hosted agents](/docs/agent/buildkite-hosted), Buildkite Pipelines provides both the control plane and the infrastructure that runs your jobs. Buildkite provisions and scales the build machines, then destroys each job's environment after the job finishes.

Your organization still configures its pipelines, agent images, source-code access, secrets, and network access. Hosted infrastructure reduces machine maintenance; it does not remove responsibility for the code your jobs run or the systems they can access.

## Next steps

- **Run a build**: Follow [Getting started with Pipelines](/docs/pipelines/getting-started) to create and run your first pipeline.
- **Route jobs to your infrastructure**: Learn how to [target a queue from a pipeline](/docs/agent/queues#targeting-a-queue-from-a-pipeline).
- **Secure your setup**: Follow [Secure your first production pipeline](/docs/platform/security/first-production-pipeline) for configuration steps and verification checks.
