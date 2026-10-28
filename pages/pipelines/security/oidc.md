---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure third-party products and services, such as [AWS](https://aws.amazon.com/), [GCP](https://cloud.google.com/), [Azure](https://azure.microsoft.com/) and many others, as well as Buildkite products, such as [Package Registries](/docs/package-registries/security/oidc), with OIDC policies that only permit Buildkite agent interactions from specific Buildkite organizations, pipelines, agents, and other metadata associated with the pipeline's job.

A Buildkite OIDC token is issued by a Buildkite agent, asserting claims about the pipeline it is building and the organization that contains this pipeline (both their immutable UUIDs and slugs), the IDs of the build and job that created the token, as well as other claims, such as the name of the branch used in the build, the SHA of the commit that triggered the build, and the agent ID. Such a token is:

- Associated with a Buildkite agent interaction to perform one or more actions within your third-party services. If the token's claims do not comply with the service's OIDC policy, the token is rejected and subsequent pipeline jobs' interactions from the Buildkite agent are rejected. If the claims do comply, the Buildkite agent and its permitted pipeline's jobs will have access to the allowable actions defined by these services.
- Short-lived to further mitigate the risk of compromising the security of these services, should the token accidentally be leaked.

The [Buildkite agent's `oidc` command](/docs/agent/cli/reference/oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens can then be consumed by federated systems like AWS, and exchanged for authenticated role-based access with specific permissions to interact with your cloud environments.

By default, the token's `sub` (subject) claim identifies the pipeline. You can use the `--subject-claim` flag to set it to a different immutable identifier, such as a cluster UUID or organization UUID, giving you control over how broadly or narrowly trust is scoped. See [Custom subject claims](/docs/agent/cli/reference/oidc#custom-subject-claims) for details.

## Restrict access with OIDC policies

Configure the receiving service's OIDC trust policy to accept tokens only from the Buildkite organizations and workloads that need access. Buildkite issues signed tokens containing claims about a job. Your receiving service is responsible for checking those claims before granting access.

> 🚧 The issuer does not identify your organization
> The issuer `https://agent.buildkite.com` is shared across Buildkite organizations. Verifying this issuer alone does not restrict access to your organization. A policy without organization or workload restrictions could accept tokens from another customer's organization.

When configuring or reviewing a trust policy:

- **Restrict the organization and workload**: Use immutable identifiers, such as `organization_id` and `pipeline_id`, where the provider supports them. Alternatively, match an immutable identifier in the `sub` claim. A pipeline slug alone does not identify an organization, and deleted organization and pipeline slugs can be reused.
- **Enforce claim values**: Mapping a claim to a provider attribute does not restrict which values are accepted. Add conditions or identity bindings that enforce the intended values. Check every rule that can grant access so that a broader rule does not bypass these restrictions.
- **Validate the audience**: Configure the receiving service to require the intended `aud` (audience) value, and request a token with the matching audience. Audience validation does not replace organization and workload restrictions.
- **Control what code can authenticate**: Restrict who can trigger or change pipelines with privileged access, including whether they run untrusted pull requests. A branch condition alone does not guarantee that the job executes only trusted code.

Limit the permissions granted after authentication separately from the trust policy. Grant only the actions and resources the workload needs. For example, an integration that only creates builds should not also have permission to create pipelines. Short-lived tokens reduce the time a leaked token can be used, but do not compensate for overly broad trust or permissions.

For provider-specific configuration, see [Restricting access with Buildkite OIDC claims in AWS](/docs/pipelines/security/oidc/aws#restricting-access-with-buildkite-oidc-claims), [Adding a federated identity credential in Azure](/docs/pipelines/security/oidc/azure#step-2-add-a-federated-identity-credential), and [Azure access control limitations](/docs/pipelines/security/oidc/azure#known-limitations).
