# OIDC in Buildkite Packages

<%= render_markdown partial: 'platform/buildkite_agent_oidc_token_overview' %>

Third-party products and services, such as [GitHub Actions](https://github.com/features/actions), as well as Buildkite Packages itself, can be configured with OIDC-compatible policies that only permit agent interactions from specific Buildkite organizations, pipelines, jobs, and agents, associated with a pipeline's job.

A Buildkite OIDC token, representing such an agent interaction containing this metadata, can be used by these third-party services and Buildkite Packages, to allow the service to authenticate the Buildkite interaction. If one of these interactions does not match or comply with the service's policy, the interaction is rejected.

The [Buildkite Agent's `oidc` command](/docs/agent/v3/cli-oidc) allows you to request an OIDC token from Buildkite representing the pipeline's current job. These tokens are can then used by a Buildkite Packages registry to determine if the organization, pipeline and any other metadata associated with the pipeline and its job are permitted to publish/upload packages to this registry.

## Define OIDC policies for a registry

You can specify an OIDC policy for your Buildkite registry, which defines the criteria for which OIDC tokens, from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another third-party system, will be accepted by your registry and authenticate a package publication/upload action from that system.

1. After [creating your registry](/docs/packages/manage-registries#create-a-registry), begin [updating it](/docs/packages/manage-registries#update-a-registry) to access the **OIDC Policy** page.
1. To configure an OIDC policy for a Buildkite pipeline's job, in the **Policy** field, specify this using the following format:

    ```yaml
    - iss: https://agent.buildkite.com
      organization_slug: organization-slug
      pipeline_slug: pipeline-slug
      build_branch: main
    ```

    where:
    * `iss` (the issuer) must be `https://agent.buildkite.com`, representing the Buildkite Agent.
    * `organization-slug` can be obtained from the end of your Buildkite URL, after accessing **Packages** or **Pipelines** in the global navigation of your organization in Buildkite.
    * `pipeline-slug` can be obtained from the end of your Buildkite URL, after accessing **Pipelines** in the global navigation of your organization in Buildkite.
    * `main` or whichever branch of the repository you want to restrict package publication/uploads from pipeline builds.

Each of these OIDC policy fields acts as a _filter_ and only authenticates and accepts OIDC tokens from Buildkite Agent pipelines and jobs whose criteria match these field values. Therefore, omitting a field makes the policy less strict.

You can also specify multiple policies in this **Policy** field to allow your registry to accept jobs from other pipelines, as well as OIDC tokens from other systems.

### Example OIDC policies for a registry

The following example OIDC policies defined on a registry:

```yaml
- iss: https://agent.buildkite.com
  organization_slug: my-organization
  pipeline_slug: my-pipeline
  build_branch: main
- iss: https://agent.buildkite.com
  organization_slug: my-organization
  pipeline_slug: my-second-pipeline
```

Will only authenticate and accept OIDC tokens (and therefore, allow package publishing/uploads to this registry) from Buildkite Agents:

- Configured with the organization `my-organization`.

- Running pipeline builds of the `my-pipeline` or `my-second-pipeline` pipelines within this organization.

- For `my-pipeline`, running builds from the `main` branch of the repository.

- For `my-second-pipeline`, running builds from any branch of the repository.

## Configure a Buildkite pipeline to authenticate to a registry

When configuring a Buildkite pipeline [`command` step](/docs/pipelines/command-step) to request an OIDC token from Buildkite to interact with your Buildkite registry [configured with an OIDC policy](#define-oidc-policies-for-a-registry), use the following [`buildkite-agent oidc` command](/docs/agent/v3/cli-oidc):

```bash
buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{org.slug}/{registry.slug}" --lifetime 300
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

- `{registry.slug}` is the slug of your registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of your registry name, and can be obtained after accessing **Packages** in the global navigation > your registry from the **Registries** page.
