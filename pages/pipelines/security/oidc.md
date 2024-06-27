---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

<%= render_markdown partial: 'platform/buildkite_agent_oidc_token_overview' %>

Third-party products and services, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and many others, as well as Buildkite products, such as [Packages](/docs/packages/security/oidc), can be configured with OIDC-compatible policies that restrict agent interactions to specific permitted Buildkite organizations, pipelines, jobs, and agents.

A Buildkite OIDC token, representing an agent interaction from a pipeline's job, can be used by such third-party services and Buildkite Packages to allow these services to authenticate this interaction, based on the organization, pipeline, job details, and agent associated with this pipeline's job.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token for the pipeline's current job. These tokens are then exchanged on federated systems like AWS for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkite's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).
