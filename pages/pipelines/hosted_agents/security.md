# Hosted agents security

Customer security is paramount to Buildkite, where our source code, build artifacts and deployment processes represent some of our most valuable and sensitive assets.

The shift from [self-hosted architecture](/docs/pipelines/architecture#self-hosted-hybrid-architecture) to [Buildkite hosted one](/docs/pipelines/architecture#buildkite-hosted-architecture) for Buildkite Agents, introduces the potential of new attack vectors and shared responsibility models.

The security model for Buildkite hosted agents has the following characteristics.

- **Infrastructure and isolation security**: Buildkite employs a multi-tenant architecture, where each job runs in a completely isolated virtualized environment. Once a job is complete, regardless of its exit status, the virtualized environment is destroyed, along with all its data (except for cache volumes that persist across jobs). This ephemeral approach ensures that customer workloads remain isolated from each other, even though the underlying hardware is shared across multiple customers. For macOS hosted agents, virtualization is achieved through Apple's Virtualization framework on Apple Silicon, providing lightweight but secure virtual machine isolation. Learn more about [How Buildkite hosted agents work](/docs/pipelines/hosted-agents#how-buildkite-hosted-agents-work).

- **Physical and operational security**: The Mac fleet operates from multiple [Tier 3+ data centers](https://en.wikipedia.org/wiki/Data_centre_tiers) with restricted physical access controls and regular security monitoring. The platform maintains SOC 2 compliance through regular audits of both hardware and software security controls. While customers cannot currently provide custom base images for macOS hosted agents, customers do have significant control over these virtual machines during job execution—including the ability to install software using Homebrew, use git mirroring for performance, and leverage persistent cache volumes. This balance provides operational flexibility while maintaining the security boundaries necessary for a multi-tenant environment.
