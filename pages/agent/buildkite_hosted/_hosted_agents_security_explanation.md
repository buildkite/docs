Customer security is paramount to Buildkite, where our source code, build artifacts and deployment processes represent some of our most valuable and sensitive assets.

The shift from a [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) to a [Buildkite hosted](/docs/pipelines/architecture#buildkite-hosted-architecture) architecture for Buildkite Agents, introduces the potential for new attack vectors and shared responsibility models, and hence, additional security considerations.

The security model for Buildkite hosted agents has the following characteristics to address these security considerations and to mitigate attack risks.

- **Infrastructure and isolation security**: Buildkite employs a multi-tenant architecture, where each job runs in a completely isolated virtualized environment. Once a job is complete, regardless of its exit status, the virtualized environment is destroyed, along with all its data (except for [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) that persist across jobs). This ephemeral approach ensures that customer workloads remain isolated from each other, even though the underlying hardware is shared across multiple customers.

- **Physical and operational security**: The Buildkite hosted agent fleet operates from multiple [Tier 3+ data centers](https://en.wikipedia.org/wiki/Data_centre_tiers) with restricted physical access controls and regular security monitoring. The platform maintains SOC 2 compliance through regular audits of both hardware and software security controls.
