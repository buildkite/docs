# OIDC in Buildkite Packages

<%= render_markdown partial: 'platform/buildkite_agent_oidc_token_overview' %>

Third-party products and services, such as [GitHub Actions](https://github.com/features/actions), as well as Buildkite Packages itself, can be configured with OIDC-compatible policies that only permit agent interactions from specific Buildkite organizations, pipelines, jobs, and agents, associated with a pipeline's job.

A Buildkite OIDC token, representing such an agent interaction containing this metadata, can be used by these third-party services and Buildkite Packages, to allow the service to authenticate the Buildkite interaction. If one of these interactions does not match or comply with the service's policy, the OIDC token and hence, subsequent interactions are rejected.

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

- Configured with the Buildkite organization `my-organization`.

- Running pipeline builds of the `my-pipeline` or `my-second-pipeline` pipelines within this organization.

- For `my-pipeline`, running builds from the `main` branch of the repository.

- For `my-second-pipeline`, running builds from any branch of the repository.

## Configure a Buildkite pipeline to authenticate to a registry

Configuring a Buildkite pipeline [`command` step](/docs/pipelines/command-step) to request an OIDC token from Buildkite to interact with your Buildkite registry [configured with an OIDC policy](#define-oidc-policies-for-a-registry), is a two-part process.

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

