# OIDC in Buildkite Package Registries

<%= render_markdown partial: 'platform/oidc_introduction' %>

You can configure Buildkite registries with OIDC policies that allow access using OIDC tokens issued by Buildkite Agents and other OIDC identity providers. This is similar to how [third-party products and services can be configured with OIDC policies](/docs/pipelines/security/oidc) to consume Buildkite Agent OIDC tokens for specific pipeline jobs, for deployment, or access management and security purposes.

A Buildkite Agent's OIDC tokens assert claims about the slugs of the pipeline it is building and organization that contains this pipeline, the ID of the job that created the token, as well as other claims, such as the name of the branch used in the build, the SHA of the commit that triggered the build, and the agent ID. If the token's claims do not comply with the registry's OIDC policy, the OIDC token is rejected, and any actions attempted with that token will fail. If the claims do comply, however, the Buildkite Agent and its permitted actions will have read and write access to packages in the registry.

Such tokens are also short-lived to further mitigate the risk of compromising the security of your Buildkite registries, should the token accidentally be leaked.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli/reference/oidc) allows you to request an OIDC token from Buildkite containing claims about the pipeline's current job. These tokens can then be used by a Buildkite registry to determine (through its OIDC policy) if the organization, pipeline and any other metadata associated with the pipeline and its job are permitted to publish/upload packages to this registry.

## OIDC token requirements

All Buildkite registries defined with an OIDC policy, require the following claims from an OIDC token (unless indicated as optional), regardless of the OIDC identity provider that issued the token.

| Claim | Value |
| ----- | ----- |
| [`iat` (issued at)](/docs/agent/v3/cli/reference/oidc#iat) | Must be a UNIX timestamp in the past. |
| [`nbf` (not before)](/docs/agent/v3/cli/reference/oidc#nbf) (Optional) | If present, must be a UNIX timestamp in the past. |
| [`exp` (expiration time)](/docs/agent/v3/cli/reference/oidc#exp) | Must be a UNIX timestamp in the future. The OIDC token's lifespan—that is, the `exp` minus the `iat` timestamp values—cannot be greater than 5 minutes. |
| [`aud` (audience)](/docs/agent/v3/cli/reference/oidc#aud) | Must be equal to the registry's canonical URL, which has the format `https://packages.buildkite.com/{org.slug}/{registry.slug}`. |

When generating an OIDC token from:

- A [Buildkite Agent](/docs/agent/v3/cli/reference/oidc), the [`--audience` option](/docs/agent/v3/cli/reference/oidc#audience) must explicitly be specified with the required value, whereas `iat`, `nbf` and `exp` claims will automatically be included in the token.

- Another OIDC identity provider, ensure that its OIDC tokens contain these required claims. This should be the case by default, but if not, consult the relevant documentation for your OIDC identity provider on how to include these claims in the OIDC tokens it issues.

## Define an OIDC policy for a registry

You can specify an OIDC policy for your Buildkite registry, which defines the criteria for which OIDC tokens, from the [Buildkite Agent](/docs/agent/v3/cli/reference/oidc) or another OIDC identity provider, will be accepted by your registry and authenticate a package publication/upload action from that system.

To define an OIDC policy for one or more Buildkite pipeline jobs in a registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the registry whose OIDC policy needs defining.

1. Select **Settings** > **OIDC Policy** to access the registry's **OIDC Policy** page.

1. In the **Policy** field, specify this using the following [Basic OIDC policy format](#define-an-oidc-policy-for-a-registry-basic-oidc-policy-format), or one based on a more [complex example](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example).

Learn more about how an OIDC policy for a registry is constructed in [Policy structure and behavior](#define-an-oidc-policy-for-a-registry-policy-structure-and-behavior).

### Basic OIDC policy format

The basic format for a Buildkite registry's OIDC policy is:

```yaml
- iss: https://agent.buildkite.com
  scopes:
    - read_packages
  claims:
    organization_slug: organization-slug
    pipeline_slug: pipeline-slug
    build_branch: main
```

where:

- `iss` (the issuer) is `https://agent.buildkite.com`, representing tokens issued by Buildkite.
- the `scopes` field identifies the actions that the token can perform. The only supported scopes are `read_packages`, `write_packages`, and `delete_packages`.
- the `claims` field contains:

    * `organization-slug`, which can be obtained from the end of your Buildkite URL, after accessing **Package Registries** or **Pipelines** in the global navigation of your organization in Buildkite.
    * `pipeline-slug`, which can be obtained from the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.
    * `main` or whichever branch of the repository you want to restrict package publication/uploads from pipeline builds.

However, more [complex OIDC policies](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example) can be created.

### Complex OIDC policy example

The following OIDC policy for a Buildkite registry contains two [_statements_](#statements)—one for a registry in Package Registries and another for GitHub Actions.

```yaml
- iss: https://agent.buildkite.com
  scopes:
    - read_packages
    - write_packages
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
  scopes:
    - delete_packages
  claims:
    repository:
      matches: your-org/*
    actor:
      in:
        - deploy-bot
        - revert-bot
```

The first statement allows OIDC tokens representing a pipeline's job being built by a Buildkite Agent, but only when all of the following is true for the tokens' claims:

- The [organization slug](/docs/agent/v3/cli/reference/oidc#organization-slug) is `your-org`
- The [pipeline slug](/docs/agent/v3/cli/reference/oidc#pipeline-slug) is either `one-pipeline` or `another-pipeline`
- The [build branch](/docs/agent/v3/cli/reference/oidc#build-branch) is either `main` or matches a `feature/*` branch

Tokens allowed by this statement can read and write packages in the registry.

The second statement allows OIDC tokens representing a GitHub Actions workflow, but only when all of the following is true for the tokens' claims:

- The repositories match `your-org/*`
- The actor is either `deploy-bot` or `revert-bot`

Tokens allowed by this statement can only delete packages in the registry.

### Policy structure and behavior

OIDC policy [_statements_](#statements) in Buildkite Package Registries are defined as a YAML- or JSON-formatted list, each of which includes a _token issuer_ from an OIDC identity provider, along with a map of [_claim rules_](#claim-rules).

If an OIDC token's claims match both the token issuer and _all_ claim rules defined by any statement within a registry's OIDC policy, then the token is accepted and the OIDC identity provider that issued the token is granted access to the registry. If no statements of the OIDC policy match, the token is rejected, and no registry access is granted.

When multiple statements match a token's claims, the token is accepted by the first matching statement in the policy, and no further statements are evaluated. This affects the use of scopes, as only the scopes defined in the first matching statement are granted to the token.

When using YAML to define an OIDC policy, only simple YAML syntax is accepted—that is, YAML containing only scalar values, maps, and lists. Complex YAML syntax and features, such as anchors, aliases, and tagged values are not supported.

<a id="statements"></a>

#### Statements

A _statement_ consists of a list of [_claim rules_](#claim-rules) for a particular _token issuer_ within an OIDC policy, as well as the _API scopes_ that the token is allowed to access.

Each statement in the policy must contain:

- An `iss` field, which is used to identify the token issuer. Statements will only match OIDC tokens whose `iss` claim matches the value of this field.
- A `scopes` field, which is a list of API scopes that a token is granted. Currently, the only scopes supported by Registry OIDC policies are `read_packages`, `write_packages`, and `delete_packages`. If a token's claims match a statement, the token is granted access to the registry with the scopes defined in that statement.
- A `claims` field, which is a map of [claim rules](#claim-rules).

Currently, only OIDC tokens from the following token issuers are supported.

| Token issuer name | The token issuer (`iss`) value | Relevant documentation link |
| ----------------- | ------------------------------ | --------------------------- |
| Buildkite | `https://agent.buildkite.com` | [Buildkite Agent `oidc` command](/docs/agent/v3/cli/reference/oidc) |
| GitHub Actions | `https://token.actions.githubusercontent.com` | [GitHub Actions OIDC Tokens](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/about-security-hardening-with-openid-connect) |
| CircleCI | `https://oidc.circleci.com/org/$ORG` where `$ORG` is your organization name | [CircleCI OIDC Tokens](https://circleci.com/docs/openid-connect-tokens) |

If you'd like to use OIDC tokens from a different token issuer or OIDC identity provider with Buildkite Package Registries, please contact [support](https://buildkite.com/about/contact/).

<a id="claim-rules"></a>

#### Claim rules

A [_statement_](#statements) contains a `claims` field, which in turn contains a map of _claim rules_, where the rule's key is the name of the claim being verified, and the rule's value is the actual rule used to verify this claim. Each rule is a map of [_matchers_](#claim-rule-matchers), which are used to match a claim value in an OIDC token.

If at least one claim rule defined within an OIDC policy's statement is missing from an OIDC token and no other statements in that policy have complete matches with the token's claims, then the token is rejected. When a claim rule contains multiple matchers—such as the `build_branch` claim rule in the [complex example](#define-an-oidc-policy-for-a-registry-complex-oidc-policy-example) above—_all_ of the rule's matchers must match a claim in the token for it to be granted registry access. In the `build_branch` example above, this means that the token must have a `build_branch` claim whose value is either `main` or begins with `feature/`, but whose value is not `feature/not-this-one`.

Be aware that this means some combinations of matchers used in a claim rule may never match an OIDC token's claims. For example, the following OIDC policy statement will always reject a token, since the token's `build_branch` claim cannot be both equal to `main` and not equal to `main` at the same time:

```yaml
- iss: https://agent.buildkite.com
  scopes:
    - read_packages
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

Configuring a Buildkite pipeline [`command` step](/docs/pipelines/configure/step-types/command-step) to request an OIDC token from Buildkite to interact with your Buildkite registry [configured with an OIDC policy](#define-an-oidc-policy-for-a-registry), is a two-part process.

### Part 1: Request an OIDC token from Buildkite

To do this, use the following [`buildkite-agent oidc` command](/docs/agent/v3/cli/reference/oidc):

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{org.slug}/{registry.slug}" --lifetime 300
```

where:

- `--audience` is the target system that consumes this OIDC token. For Buildkite Package Registries, this value must be based on the URL `https://packages.buildkite.com/{org.slug}/{registry.slug}`.

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of your registry name, and can be obtained after accessing **Package Registries** in the global navigation > your registry from the **Registries** page.

- `--lifetime` is the time (in seconds) that the OIDC token is valid for. By default, this value must be less than `300`.

### Part 2: Authenticate the registry with the OIDC token

To do this (using Docker as an example), authenticate the registry with the OIDC token obtained in [part 1](#configure-a-buildkite-pipeline-to-authenticate-to-a-registry-part-1-request-an-oidc-token-from-buildkite) by piping the output through to the `docker login` command:

```bash
docker login packages.buildkite.com/{org.slug}/{registry.slug} --username buildkite --password-stdin
```

where:

- `{org.slug}` and `{registry.slug}` are the same as the values used in the [`buildkite-agent oidc request-token` command](#configure-a-buildkite-pipeline-to-authenticate-to-a-registry-part-1-request-an-oidc-token-from-buildkite).

- `--username` always has the value `buildkite`.

As a result, the full [`command` step](/docs/pipelines/configure/step-types/command-step) would look like:

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{org.slug}/{registry.slug}" --lifetime 300 | docker login packages.buildkite.com/{org.slug}/{registry.slug} --username buildkite --password-stdin
```

For a Buildkite organization with a slug `my-organization` and a registry slug `my-registry`, this full command would look like:

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/my-organization/my-registry" --lifetime 300 | docker login packages.buildkite.com/my-organization/my-registry --username buildkite --password-stdin
```

### Example pipeline

The following example Buildkite pipeline YAML snippet demonstrates how to push Docker images to a Buildkite registry using OIDC token authentication:

```yml
steps:
- key: "docker"
  label: "\:docker\: Build, Login & Push"
  commands:
    - echo "Building Docker image"
    - docker build --tag packages.buildkite.com/my-organization/my-registry/my-image:latest .
    - echo "Logging into Buildkite Package Registry using OIDC"
    - buildkite-agent oidc request-token --audience "https://packages.buildkite.com/my-organization/my-registry" --lifetime 300 | docker login packages.buildkite.com/my-organization/my-registry --username buildkite --password-stdin
    - echo "Pushing Docker image to Buildkite Package Registry"
    - docker push packages.buildkite.com/my-organization/my-registry/my-image:latest
```
{: codeblock-file="pipeline.yml"}
