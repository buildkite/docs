---
keywords: oidc, authentication, IAM, roles
---

# OIDC with Buildkite

An [Open ID Connect (OIDC)](https://openid.net/developers/how-connect-works/) token is a signed JSON Web Token (JWT) provided by the Buildkite Agent containing information about the pipeline and job, including the pipeline and organisation slugs, as well as job-specific data, such as the branch, the commit SHA, the job ID, and the agent ID.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token representing the current job. These tokens can then be exchanged on federated systems like AWS for authenticated role-based access with specific permissions to interact with your cloud environments.

This section of the Buildkite Docs covers Buildkit's OIDC implementation with other federated systems, such as [AWS](/docs/pipelines/security/oidc/aws).