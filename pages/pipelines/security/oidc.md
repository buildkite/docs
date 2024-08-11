---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure third-party products and services, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and many others, as well as Buildkite products, such as [Packages](/docs/packages/security/oidc), with OIDC policies that only permit Buildkite Agent interactions from specific Buildkite organizations, pipelines, jobs, and agents, associated with a pipeline's job.

A Buildkite OIDC token is a signed [JSON Web Token (JWT)](https://jwt.io/) provided by a Buildkite Agent, containing information and metadata about a pipeline and its job, including the pipeline and organization slugs, as well as job-specific data, such as the branch, the commit SHA, the job ID, and the agent ID. Such tokens represent Buildkite Agent interactions (containing relevant pipeline job metadata), which can be used by these third-party services and Buildkite Packages, to allow the service to authenticate this interaction. If an interaction does not match or comply with the service's OIDC policy, the OIDC token and subsequent pipeline interactions are rejected.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite for the pipeline's current job. These tokens are then consumed by federated systems like AWS, and exchanged for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkite's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).
