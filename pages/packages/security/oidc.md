# OIDC in Buildkite Packages

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure Buildkite Packages registries with OIDC policies that allow access using OIDC tokens from OIDC identity providers. These policies can permit access to the registry based on the source and contents of the token. This is similar to how [third-party products and services can be configured with OIDC policies](/docs/pipelines/security/oidc) to consume Buildkite OIDC tokens from Buildkite pipelines, for deployment, or access management and security purposes.

OIDC tokens issued by a Buildkite Agent assert claims about the slugs of the pipeline it is building and organization that contains this pipeline, the ID of the job that created the token, as well as other claims, such as the name of the branch used in the build, the SHA of the commit that triggered the build, and the agent ID. If the token's claims do not comply with the registry's OIDC policy, the OIDC token is rejected, and any actions attempted with that token will fail. If the claims do comply, however, the OIDC token will have read and write access to packages in the registry.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens can then be used by a Buildkite Package Registry to determine (through its OIDC policy) if the organization, pipeline and any other metadata associated with the pipeline and its job are permitted to publish/upload packages to this registry.

## Checks always applied to OIDC tokens

Before applying the OIDC policy on a given package registry, the following checks are always applied to the OIDC token:
- The `iat` claim must be present, and a UNIX timestamp in the past
- The `nbf` claim, if present, must be a UNIX timestamp in the past
- The `exp` claim must be present, and a UNIX timestamp in the future
- The token's total lifetime - that is, `exp` minus `iat` - cannot be greater than 5 minutes
- The `aud` claim must be equal to the registry's canonical URL, which is of the form `https://packages.buildkite.com/<organization slug>/<registry slug>`.

## OIDC policy format

### Example policy:
```yaml
- iss: https://agent.buildkite.com
  claims:
    organization_slug: your-org
    pipeline_slug: your-pipeline
    build_branch: main

- iss: https://token.actions.githubusercontent.com
  claims:
    repository:
      matches: your-org/*
    actor:
      in:
        - deploy-bot
        - revert-bot
```

In this example, the policy has two statements. The first statement allows tokens representing a Buildkite Agent, but only if the token claims match the organization slug `your-org`, **and** the pipeline slug is `your-pipeline`, **and** the build branch is `main`. The second statement allows tokens from GitHub Actions, but only if the token claims are from a repository matching `your-org/*`, and the actor is either `deploy-bot` or `revert-bot`.

### Policy structure

Package Registry OIDC Policies in Buildkite are defined as a YAML or JSON list of statements, each of which covers a token issuer, and is comprised of a map of claim rules, which must _all_ match the token for the statement to match. If any statement in the policy matches, the token is accepted. If no statements match, the token is rejected.

When using YAML to define a policy, only "simple" YAML is accepted - YAML containing only scalar values, maps, and lists. This means that complex YAML features like anchors, aliases, tagged values are not supported, and will be rejected.

#### Statements

Each statement in the policy must contain contain an `iss` field, which is the issuer of the token. This is used to match the token to the statement. Multiple statements can be used to allow access from multiple issuers, and multiple statements covering the same issuer can be used for more complex policies.

Currently, only tokens from a specific set of issuers are supported. The supported issuers are:
| Issuer name    | `iss` value                                   | Link to documentation |
| -------------- | --------------------------------------------- | --------------------- |
| Buildkite      | `https://agent.buildkite.com`                 | [Buildkite Agent OIDC Tokens](/docs/agent/v3/cli-oidc) |
| GitHub Actions | `https://token.actions.githubusercontent.com` | [GitHub Actions OIDC Tokens](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect) |
| CircleCI       | `https://oidc.circleci.com/org/$ORG` where `$ORG` is your organization name | [CircleCI OIDC Tokens](https://circleci.com/docs/openid-connect-tokens/) |

If you'd like to use OIDC tokens from a different issuer in Buildkite Package Registries, please [contact support](mailto:support@buildkite.com) - we'd love to hear from you!

The statement must also contain a `claims` field, which is a map of claim rules where the key is the name of the claim being verified, and the value is a rule used to verify it. Each rule is a map of matchers, which are used to match the claim value in the token.

#### Claim rules

For a statement to match a token, all claim rules in that statement must match the token's claims. If a claim is not present in the token, it is considered to not match the rule. Where a claim rule contains multiple matchers - such as the `build_branch` claim rule above - **all** of the matchers must match for the claim to match the rule. In the `build_branch` example above, this means that the token must have a `build_branch` claim that is either `main` or starts with `feature/`, but is not `feature/not-this-one`.

Note that this means that some combinations of matchers can never match a token. For example, the following policy can never match a token, as the claim `build_branch` cannot be both equal to `main` and not equal to `main` at the same time:
```yaml
- iss: "https://agent.buildkite.com"
  claims:
    build_branch:
      equals: "main"
      not_equals: "main"
```
##### Claim rule matchers

Available matchers for claim rules are:

| Matcher      | Argument Type                                | Description                                                   |
| ------------ | -------------------------------------------- | ------------------------------------------------------------- |
| `equals`     | Scalar                                       | The claim value must be exactly equal to the argument         |
| `not_equals` | Scalar                                       | The claim value must not be exactly equal to the argument     |
| `in`         | List of scalars                              | The claim value must be in the list of arguments              |
| `not_in`     | List of scalars                              | The claim value must not be in the list of arguments          |
| `matches`    | List of glob strings OR a single glob string | The claim value must match at least one of the globs provided. Note that this matcher is only applied when the claim value is a string, and is ignored otherwise |

In the above table, a scalar is a single value, which must be a String, Number (float or integer), Boolean, or Null. A glob string is a string that may contain wildcards, such as `*` or `?`, which match zero or more characters, or a single character respectively. Glob strings are _not_ regular expressions, and do not support the full range of features that regular expressions do.

As a special case, if a claim rule in its entirety is a scalar, it is treated as if it were a rule with the `equals` matcher. This means that the following two claim rules are equivalent:

```yaml
organization_slug: "your-org"
# is equivalent to
organization_slug:
  equals: "your-org"
```

## Define an OIDC policy for a registry

You can specify an OIDC policy for your Buildkite registry, which defines the criteria for which OIDC tokens, from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another third-party system, will be accepted by your registry and authenticate a package publication/upload action from that system.

To define an OIDC policy for one or more Buildkite pipeline jobs in a registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the registry whose OIDC policy needs defining.

1. Select **Settings** > **OIDC Policy** to access the registry's **OIDC Policy** page.

1. In the **Policy** field, specify this using the above format

## Configure a Buildkite pipeline to authenticate to a registry

Configuring a Buildkite pipeline [`command` step](/docs/pipelines/command-step) to request an OIDC token from Buildkite to interact with your Buildkite registry [configured with an OIDC policy](#define-an-oidc-policy-for-a-registry), is a two-part process.

### Part 1: Request an OIDC token from Buildkite

To do this, use the following [`buildkite-agent oidc` command](/docs/agent/v3/cli-oidc):

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{org.slug}/{registry.slug}" --lifetime 300
```

where:

- `--audience` is the target system that consumes this OIDC token. For Buildkite Packages, this value must be based on the URL `https://packages.buildkite.com/{org.slug}/{registry.slug}`.

<%= render_markdown partial: 'packages/org_slug' %>

- `{registry.slug}` is the slug of your registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of your registry name, and can be obtained after accessing **Packages** in the global navigation > your registry from the **Registries** page.

- `--lifetime` is the time (in seconds) that the OIDC token is valid for. By default, this value must be less than `300`.

### Part 2: Authenticate the Buildkite registry with the OIDC token

To do this (using Docker as an example), authenticate the Buildkite registry with the OIDC token obtained in [part 1](#configure-a-buildkite-pipeline-to-authenticate-to-a-registry-part-1-request-an-oidc-token-from-buildkite) by piping the output through to the `docker login` command:

```bash
docker login packages.buildkite.com/{org.slug}/{registry.slug} --username buildkite --password-stdin
```

where:

- `{org.slug}` and `{registry.slug}` are the same as the values used in the [`buildkite-agent oidc request-token` command](#configure-a-buildkite-pipeline-to-authenticate-to-a-registry-part-1-request-an-oidc-token-from-buildkite).

- `--username` always has the value `buildkite`.

Therefore, the full [`command` step](/docs/pipelines/command-step) would look like:

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{org.slug}/{registry.slug}" --lifetime 300 | docker login packages.buildkite.com/{org.slug}/{registry.slug} --username buildkite --password-stdin
```

Assuming a Buildkite organization with slug `my-organization` and a pipeline slug `my-pipeline`, this full command would look like:

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/my-organization/my-pipeline" --lifetime 300 | docker login packages.buildkite.com/my-organization/my-pipeline --username buildkite --password-stdin
```

### Example pipeline

The following example Buildkite pipeline YAML snippet demonstrates how to push Docker images to a Buildkite registry using OIDC token authentication:

```yml
steps:
- key: "docker-build" # Build the Docker image
  label: "\:docker\: Build"
  command: docker build --tag packages.buildkite.com/my-organization/my-pipeline/my-image:latest .

- key: "docker-login" # Authenticate the Buildkite Agent to the Buildkite Packages registry using an OIDC token
  label: "\:docker\: Login"
  command: buildkite-agent oidc request-token --audience "https://packages.buildkite.com/my-organization/my-pipeline" --lifetime 300 | docker login packages.buildkite.com/my-organization/my-pipeline --username buildkite --password-stdin
  depends_on: "docker-build"

- key: "docker-push" # Now authenticated, push the Docker image to the registry
  label: "\:docker\: Push"
  command: docker push packages.buildkite.com/my-organization/my-pipeline/my-pipeline/my-image:latest
  depends_on: "docker-login"

```
{: codeblock-file="pipeline.yml"}
