---
keywords: oidc, authentication, IAM, roles
---

# OIDC in Buildkite Pipelines

[OpenID Connect (OIDC)](https://openid.net/developers/how-connect-works/) lets Buildkite Pipelines jobs access other services without storing long-lived credentials. You configure the service to trust specific jobs, and each job requests a short-lived token when it runs.

## How OIDC works

The service uses information in the token, called _claims_, to decide which jobs can authenticate:

1. You configure the service to trust tokens from the intended Buildkite organization and jobs.
1. A pipeline job requests an OIDC token from Buildkite using the Buildkite agent.
1. Buildkite issues a signed token containing claims about the job.
1. The service verifies the token and checks its claims before granting access.

## Configure the service

Follow the guide for the service your pipeline needs to access:

- [Configure OIDC with AWS](/docs/pipelines/security/oidc/aws)
- [Configure OIDC with Azure](/docs/pipelines/security/oidc/azure)
- [Configure OIDC with Buildkite Package Registries](/docs/package-registries/security/oidc)

Each guide explains the service's trust configuration, required audience, and how to use the token to access resources.

## Request a token from a pipeline step

After configuring the service, use the [Buildkite agent's OIDC command](/docs/agent/cli/reference/oidc) in the job that needs access:

```bash
OIDC_TOKEN=$(buildkite-agent oidc request-token --audience "AUDIENCE_VALUE")
```

Replace `AUDIENCE_VALUE` with the value required by the service, such as `sts.amazonaws.com` for AWS. Pass the token to the service using its authentication command. Do not print the token or upload it as an artifact. Each job that needs access should request its own token.

For complete pipeline examples, see the [AWS pipeline configuration](/docs/pipelines/security/oidc/aws#step-4-configure-your-pipeline-to-assume-the-role) and [Azure example pipeline](/docs/pipelines/security/oidc/azure#example-pipeline).

## Restrict which jobs can authenticate

Configure the service to check the organization and jobs represented by each token.

> 🚧 Checking the issuer is not enough
> All Buildkite organizations share the issuer `https://agent.buildkite.com`. A policy that checks only the issuer could accept tokens from another Buildkite organization.
> See [Unit 42's analysis of OIDC misconfigurations in CI/CD](https://unit42.paloaltonetworks.com/oidc-misconfigurations-in-ci-cd/) for examples of how attackers exploit overly broad trust policies.

Use the following claims where the service supports them:

Claim | What to restrict
----- | ----------------
`organization_id` | The immutable UUID of the Buildkite organization allowed to authenticate
`pipeline_id` | The immutable UUID of the pipeline allowed to authenticate
`aud` (audience) | The intended service, matching the value in the token request
`sub` (subject) | The job context or immutable identifier allowed to authenticate
{: class="responsive-table"}

The `organization_id` claim is a UUID, not the organization slug used in URLs. For example, `example-org` is a slug, while `00000000-0000-4000-8000-000000000001` is an example UUID. Obtain your organization's UUID from the `BUILDKITE_ORGANIZATION_ID` [environment variable](/docs/pipelines/configure/environment-variables) in a job or the `id` field in the [Get an organization REST API response](/docs/apis/rest-api/organizations#get-an-organization).

Use immutable UUIDs rather than relying only on slugs. Organization and pipeline slugs can change, and deleted slugs can be reused. A pipeline slug alone does not identify an organization. If your policy also checks slugs, update those conditions when a slug changes. See the [OIDC token claim reference](/docs/agent/cli/reference/oidc#claims) for all claims and example values.

By default, `sub` contains the organization slug, pipeline slug, Git ref, commit, and step key. For services that require an exact subject match, use `--subject-claim` to replace this compound value with an immutable ID. For example, to use the pipeline UUID:

```bash
OIDC_TOKEN=$(buildkite-agent oidc request-token \
  --audience "AUDIENCE_VALUE" \
  --subject-claim pipeline_id)
```

Configure the service to match that pipeline UUID exactly. You can obtain it from the `BUILDKITE_PIPELINE_ID` environment variable. Replacing the subject removes the ref, commit, and step information from `sub`. Enforce any required restrictions separately using claims the service supports. A service that checks only this subject cannot distinguish between branches or steps in the pipeline.

Other [custom subject claims](/docs/agent/cli/reference/oidc#custom-subject-claims), such as `cluster_id` or `organization_id`, allow broader access. Use them only when every job within that scope should be able to authenticate.

## Review the trust configuration

Trust rules determine which jobs can authenticate. Permissions determine what those jobs can do after authentication. Check both before granting access:

Check | Recommendation
----- | --------------
Claim restrictions | Mapping a claim to a provider attribute does not restrict accepted values. Add conditions or identity bindings that enforce the intended organization and jobs.
Pipeline scope | Restrict access to the intended pipeline, not just its organization. Otherwise, a compromised pipeline in the same organization could obtain a token that grants access to resources intended for another pipeline.
Other access rules | Review every rule that can grant access. A broader rule can bypass restrictions in another rule.
Audience | Require the same `aud` value in the service configuration and token request. Jobs choose this value with `--audience`, so audience validation does not replace organization and job restrictions.
Untrusted code | Restrict who can trigger or change privileged pipelines using [pipeline permissions](/docs/pipelines/security/permissions). Keep untrusted pull requests out of pipelines that can authenticate to sensitive services. A branch condition alone does not guarantee trusted code.
Permissions | Grant only the actions and resources each job needs. For example, a job that reads a package does not need permission to delete packages. Short token lifetimes do not correct broad trust or permissions.
{: class="responsive-table responsive-table--nowrap-first-column"}

For service-specific restrictions, see [AWS access restrictions](/docs/pipelines/security/oidc/aws#restricting-access-with-buildkite-oidc-claims) and [Azure access control limitations](/docs/pipelines/security/oidc/azure#known-limitations).

### Test allowed and denied access

Test against non-production resources before granting production access:

1. Run the intended job and confirm that it can authenticate and perform a permitted action.
1. Try authenticating from a different pipeline that should not have access, using the expected audience. If you control a separate test organization, test from that organization too. Confirm that each attempt fails.
1. Try authenticating from a disallowed branch or step if your policy restricts them. Confirm that each attempt fails.
1. Request a token with a different audience and confirm that the service rejects it.
1. From the permitted job, try a harmless action outside its permissions, such as reading a test resource it should not access. Confirm that authentication succeeds but the action is denied.
