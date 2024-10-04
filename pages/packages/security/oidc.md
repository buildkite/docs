# OIDC in Buildkite Packages

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure registries in Buildkite Packages with OIDC policies that allow access using OIDC tokens issued by Buildkite Agents and other OIDC identity providers. This is similar to how [third-party products and services can be configured with OIDC policies](/docs/pipelines/security/oidc) to consume Buildkite Agent OIDC tokens for specific pipeline jobs, for deployment, or access management and security purposes.

A Buildkite Agent's OIDC tokens assert claims about the slugs of the pipeline it is building and organization that contains this pipeline, the ID of the job that created the token, as well as other claims, such as the name of the branch used in the build, the SHA of the commit that triggered the build, and the agent ID. If the token's claims do not comply with the registry's OIDC policy, the OIDC token is rejected, and any actions attempted with that token will fail. If the claims do comply, however, the OIDC token will have read and write access to packages in the registry.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens can then be used by a registry in Buildkite Packages to determine (through its OIDC policy) if the organization, pipeline and any other metadata associated with the pipeline and its job are permitted to publish/upload packages to this registry.

## OIDC token requirements

All registries in Buildkite Packages defined with an OIDC policy, require the following claims from an OIDC token (unless indicated as optional), regardless of the OIDC identity provider that issued the token.

| Claim | Value |
| ----- | ----- |
| [`iat` (issued at)](/docs/agent/v3/cli-oidc#iat) | Must be a UNIX timestamp in the past. |
| [`nbf` (not before)](/docs/agent/v3/cli-oidc#nbf) (Optional) | If present, must be a UNIX timestamp in the past. |
| [`exp` (expiration time)](/docs/agent/v3/cli-oidc#exp) | Must be a UNIX timestamp in the future. The OIDC token's lifespan—that is, the `exp` minus the `iat` timestamp values—cannot be greater than 5 minutes. |
| [`aud` (audience)](/docs/agent/v3/cli-oidc#aud) | Must be equal to the registry's canonical URL, which has the format `https://packages.buildkite.com/{org.slug}/{registry.slug}`. |

When generating an OIDC token from:

- A [Buildkite Agent](/docs/agent/v3/cli-oidc), the [`--audience` option](/docs/agent/v3/cli-oidc#audience) must explicitly be specified with the required value, whereas `iat`, `nbf` and `exp` claims will automatically be included in the token.

- Another OIDC identity provider, ensure that its OIDC tokens contain these required claims. This should be the case by default, but if not, consult the relevant documentation for your OIDC identity provider on how to include these claims in the OIDC tokens it issues.

## Define an OIDC policy for a registry

You can specify an OIDC policy for your Buildkite registry, which defines the criteria for which OIDC tokens, from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another OIDC identity provider, will be accepted by your registry and authenticate a package publication/upload action from that system.

To define an OIDC policy for one or more Buildkite pipeline jobs in a registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the registry whose OIDC policy needs defining.

1. Select **Settings** > **OIDC Policy** to access the registry's **OIDC Policy** page.

1. In the **Policy** field, specify this using the following [Basic OIDC policy format](#define-an-oidc-policy-for-a-registry-basic-oidc-policy-format), or one based on a more [complex example](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example).

Learn more about how an OIDC policy for a registry is constructed in [Policy structure and behavior](#define-an-oidc-policy-for-a-registry-policy-structure-and-behavior).

### Basic OIDC policy format

The basic format for an OIDC policy for OIDC tokens issued by a Buildkite Agent is:

```yaml
- iss: https://agent.buildkite.com
  claims:
    organization_slug: organization-slug
    pipeline_slug: pipeline-slug
    build_branch: main
```

where:

- `iss` (the issuer) must be `https://agent.buildkite.com`, representing the Buildkite Agent.
- `organization-slug` can be obtained from the end of your Buildkite URL, after accessing **Packages** or **Pipelines** in the global navigation of your organization in Buildkite.
- `pipeline-slug` can be obtained from the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.
- `main` or whichever branch of the repository you want to restrict package publication/uploads from pipeline builds.

However, more [complex OIDC policies](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example) can be created.

### Complex OIDC policy example

The following OIDC policy for a registry in Buildkite Packages contains two [_statements_](#statements)—one for a registry in Buildkite Packages and another for GitHub Actions.

```yaml
- iss: https://agent.buildkite.com
  claims:
    organization_slug:
      equals: your-org
    pipeline_slug:
      in:
        - one-pipeline
        - another-pipeline
    build_branch:
      matches:
        - main
        - feature/*
      not_equals: feature/not-this-one

- iss: https://token.actions.githubusercontent.com
  claims:
    repository:
      matches: your-org/*
    actor:
      in:
        - deploy-bot
        - revert-bot
```

The first statement allows OIDC tokens representing a pipeline's job being built by a Buildkite Agent, but only when all of the following is true for the tokens' claims:

- The [organization slug](/docs/agent/v3/cli-oidc#organization-slug) is `your-org`
- The [pipeline slug](/docs/agent/v3/cli-oidc#pipeline-slug) is either `one-pipeline` or `another-pipeline`
- The [build branch](/docs/agent/v3/cli-oidc#build-branch) is either `main` or matches a `feature/*` branch

The second statement allows OIDC tokens representing a GitHub Actions workflow, but only when all of the following is true for the tokens' claims:

- The repositories match `your-org/*`
- The actor is either `deploy-bot` or `revert-bot`

### Policy structure and behavior

OIDC policy [_statements_](#statements) in Buildkite Packages are defined as a YAML- or JSON-formatted list, each of which includes a _token issuer_ from an OIDC identity provider, along with a map of [_claim rules_](#claim-rules).

If an OIDC token's claims match both the token issuer and _all_ claim rules defined by any statement within a registry's OIDC policy, then the token is accepted and the OIDC identity provider that issued the token is granted access to the registry. If no statements of the OIDC policy match, the token is rejected, and no registry access is granted.

When using YAML to define an OIDC policy, only _simple_ YAML syntax is accepted—that is, YAML containing only scalar values, maps, and lists. Complex YAML syntax and features, such as anchors, aliases, and tagged values are not supported.

<a id="statements"></a>

#### Statements

A _statement_ defines a list of [_claim rules_](#claim-rules) for a particular _token issuer_ within an OIDC policy, where a token issuer is typically determined by an OIDC identity provider.

Each statement in the policy must contain contain a token issuer (`iss`) field, whose value is determined by the OIDC identity provider, and permits OIDC tokens from that token issuer. While multiple statements are typically used to allow access from multiple token issuers (that is, one statement per issuer), more than one statement can also be defined for a single issuer or OIDC identity provider to handle more complex claim rule scenarios.

A statement must also contain a `claims` field, which is a map of [claim rules](#claim-rules).

Currently, only OIDC tokens from the following token issuers are supported.

| Token issuer name | The token issuer (`iss`) value | Relevant documentation link |
| ----------------- | ------------------------------ | --------------------------- |
| Buildkite | `https://agent.buildkite.com` | [Buildkite Agent `oidc` command](/docs/agent/v3/cli-oidc) |
| GitHub Actions | `https://token.actions.githubusercontent.com` | [GitHub Actions OIDC Tokens](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect) |
| CircleCI | `https://oidc.circleci.com/org/$ORG` where `$ORG` is your organization name | [CircleCI OIDC Tokens](https://circleci.com/docs/openid-connect-tokens) |

If you'd like to use OIDC tokens from a different token issuer or OIDC identity provider in Buildkite Packages, please contact [support](https://buildkite.com/support).

<a id="claim-rules"></a>

#### Claim rules

A [_statement_](#statements) contains a `claims` field, which in turn contains a map of _claim rules_, where the rule's key is the name of the claim being verified, and the rule's value is the actual rule used to verify this claim. Each rule is a map of [_matchers_](#claim-rule-matchers), which are used to match a claim value in an OIDC token.

If at least one claim rule defined within an OIDC policy's statement is missing from an OIDC token and no other statements in that policy have complete matches with the token's claims, then the token is rejected. When a claim rule contains multiple matchers—such as the `build_branch` claim rule in the [complex example](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example) above—_all_ of the rule's matchers must match a claim in the token for it to be granted registry access. In the `build_branch` example above, this means that the token must have a `build_branch` claim whose value is either `main` or begins with `feature/`, but whose value is not `feature/not-this-one`.

Be aware that this means some combinations of matchers used in a claim rule may never match an OIDC token's claims. For example, the following OIDC policy statement will always reject a token, since the token's `build_branch` claim cannot be both equal to `main` and not equal to `main` at the same time:

```yaml
- iss: https://agent.buildkite.com
  claims:
    build_branch:
      equals: main
      not_equals: main
```

<a id="claim-rule-matchers"></a>

#### Claim rule matchers

The following _matchers_ can be used within a [_claim rule_](#claim-rules).

| Matcher | Argument type | Description |
| ------- | ------------- | ----------- |
| `equals` | Scalar  | The claim value must be exactly equal to the argument. |
| `not_equals` | Scalar | The claim value must not be exactly equal to the argument. |
| `in` | List of scalars | The claim value must be in the list of arguments. |
| `not_in` | List of scalars | The claim value must not be in the list of arguments. |
| `matches` | List of glob strings OR a single glob string | The claim value must match at least one of the globs provided. Note that this matcher is only applied when the claim value is a string, and is ignored otherwise. |

Argument type details:

- A scalar is a single value, which must be a String, Number (float or integer), Boolean, or Null.

- A glob string is a string that may contain wildcards, such as `*` or `?`, which match zero or more characters, or a single character respectively. Glob strings are _not_ regular expressions, and do not support the full range of features that regular expressions do.

As a special case, if a claim rule in its entirety is a scalar, it is treated as if it were a rule with the `equals` matcher. This means that the following two claim rules are equivalent:

```yaml
organization_slug: your-org
# is equivalent to
organization_slug:
  equals: your-org
```

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
