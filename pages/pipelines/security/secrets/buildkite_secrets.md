# Buildkite secrets

_Buildkite secrets_ is an encrypted key-value store secrets management service offered by Buildkite for use by the Buildkite Agent. These secrets can be accessed using the [`buildkite-agent secret get` command](/docs/agent/v3/cli/reference/secret) or within a job's environment variables by defining `secrets` on relevant steps within a pipeline YAML configuration. The secrets are encrypted both at rest and in transit, and are decrypted on Buildkite's application servers when accessed by the agent.

Buildkite secrets:

- Are scoped within a given [cluster](/docs/pipelines/security/clusters), and are accessible to all agents within that cluster only, since each cluster has its own unique secrets encryption key. The secrets are decrypted by the Buildkite control plane and then sent to the agent.

- Are available to both [Buildkite hosted](/docs/agent/v3/buildkite-hosted) as well as self-hosted agents.

## Access control

In addition to being scoped within a cluster, access to Buildkite secrets is managed through agent access policies. These policies restrict which agents can access secrets during builds. For detailed information about policy structure and examples, see [Access policies for Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets/access-policies).

## Create a secret

Buildkite secrets can only be created by [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster), as well as [Buildkite organization administrators](/docs/pipelines/security/permissions#manage-teams-and-permissions-organization-level-permissions).

### Using the Buildkite interface

To create a new Buildkite secret using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to create the new Buildkite secret.
1. Select **Secrets** to access the **Secrets** page, then select **New Secret**.
1. Enter a **Key** for the secret, which can only contain letters, numbers, and underscores, as valid characters.

    **Notes:**
    * The maximum permitted length for a key is 255 characters.
    * If you attempt to use any other characters for the key, or you begin your key with `buildkite` or `bk` (regardless of case), your secret will not be created when selecting **Create Secret**.

1. Enter the **Value** for the secret. This value can be any number of valid UTF-8 characters up to a maximum of 8 kilobytes. Be aware that once the secret is created, this value will no longer be visible through the Buildkite interface and will be redacted when output in build logs.
1. Select **Create Secret** to create your new secret, which can now be accessed within jobs through the `buildkite-agent secret get` command.

## Update a secret's value

Buildkite secrets can only be updated by [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster), as well as [Buildkite organization administrators](/docs/pipelines/security/permissions#manage-teams-and-permissions-organization-level-permissions).

### Using the Buildkite interface

To update an existing Buildkite secret's value using the Buildkite interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster where the secret you wish to update is located.
1. Select **Secrets** to access the **Secrets** page, then select **Edit** in the row of the secret you wish to update.
1. Enter a new **Value** for your secret. This value can be any number of valid UTF-8 characters up to a maximum of 8 kilobytes. Be aware that once the secret's value is updated, it will no longer be visible through the Buildkite interface and will be redacted when output in build logs.
1. Select **Update Secret** to update the secret's value.

> 📘
> While a secret's **Value** can be modified, the **Key** value cannot be changed.

## Use a Buildkite secret in a job

### From within a pipeline YAML configuration

> 📘 Minimum Buildkite Agent version requirement
> To use Buildkite secrets in a job, defined by its pipeline YAML configuration, version 3.106.0 or later of the Buildkite Agent is required. Using earlier versions of the Buildkite Agent will result in pipeline failures.

Once you've [created a secret](#create-a-secret), you can specify secrets in your pipeline YAML configuration, which will be injected into your job environment. Secrets can be specified for all steps in a build and per command step.

For example, to load the `API_ACCESS_TOKEN` secret in all jobs for your build:

```yaml
steps:
  - command: do_something.sh
  - command: api_call.sh

secrets:
  - API_ACCESS_TOKEN
```

Or to load it for only the jobs that need it:

```yaml
steps:
  - command: do_something.sh
  - command: api_call.sh
    secrets:
      - API_ACCESS_TOKEN
```

The value of the secret `API_ACCESS_TOKEN` is retrieved when the job starts up, and is injected into the job's environment variables as the value of the environment variable `API_ACCESS_TOKEN`. The environment variable is available to all of the job's hooks, plugins, and commands. If you need to limit the scope of secret exposure to a specific part of a job, you can use `buildkite-agent secret get` to retrieve the secret's value within the phase of the job the secret is required for.

#### Custom environment variable names for secrets

To use a custom environment variable name, you can specify `secrets` as a hash with an environment variable name as the key and the secret's key as the value.

```yaml
  - command: do_something.sh
  - command: api_call.sh
    secrets:
      MY_APP_ACCESS_TOKEN: API_ACCESS_TOKEN
```

This will inject the value of the secret `API_ACCESS_TOKEN` into the environment variable `MY_APP_ACCESS_TOKEN`. Custom environment variable names for secrets cannot start with `BUILDKITE` or `BK` (with the exception of `BUILDKITE_API_TOKEN`).

### From a build script or hook

Once you've [created a secret](#create-a-secret), the [`buildkite-agent secret get` command](/docs/agent/v3/cli/reference/secret) can be used within the Buildkite Agent to print the secret's value to standard out (stdout). You can use this command within standard bash-like commands to redirect the secret's output into an environment variable, a file, or your own tool that uses the Buildkite secret's value directly, for example:

- Setting a Buildkite secret with the key `secret_name` into an environment variable called `SECRET_VAR`:

    `SECRET_VAR=$(buildkite-agent secret get secret_name)`

- Redirecting the value of a Buildkite secret with the key `secret_name` into a file called `secret.txt`:

    `buildkite-agent secret get secret_name > secret.txt`

- Passing the output of your Buildkite secret (using the `buildkite-agent secret get` command) to your own tool named `cli-tool` that accepts a secret via its `-token` option:

    `cli-tool —token $(buildkite-agent secret get secret_name)`

Here’s a simple example of how one of these commands might appear in a Buildkite Pipeline step:

```yaml
steps:
  - agents: { queue: "hosted" }
    command:
      - buildkite-agent secret get secret_name > secret.txt
```
{: codeblock-file="pipeline.yml"}

## Redaction

If any Pipeline, script or your own tool (accidentally) prints out the value of any Buildkite secret to standard out, this value is automatically redacted from the build logs.

If for any reason you detect a secret value that isn't redacted, please rotate your secrets and contact security@buildkite.com.

## Security controls

Buildkite secrets are designed, with the following controls in place:

- Secrets are encrypted in transit using TLS.
- Secrets are always stored encrypted at rest.
- All access to the secrets are logged.
- Employee access to secrets is strictly limited and audited.

## Manage secrets using the REST API

You can manage Buildkite secrets programmatically using the [Buildkite REST API](/docs/apis/rest-api/clusters/secrets). The API endpoint allows you to:

- List all secrets in a cluster
- Get details for a specific secret
- Create new secrets
- Update secret details (description and access policy)
- Update secret values
- Delete secrets

For detailed information about available endpoints, authentication, and examples, see the [cluster's secrets endpoint of the REST API documentation](/docs/apis/rest-api/clusters/secrets).

## Best practices

Buildkite secrets are stored by Buildkite, and Buildkite manages the keys used to encrypt and decrypt these secrets stored in its secrets management service, both at rest and in transit. You should implement additional controls to manage the lifecycle of secrets stored within Buildkite secrets, in addition to any monitoring capability you may require. For example:

- All credentials should be rotated regularly.
- Track the secrets stored in Buildkite secrets within your own asset management processes.
- Enable logging for services that are accessed using the secrets stored in Buildkite secrets.
- Should you detect a compromise or are concerned about the security of your secrets, please contact security@buildkite.com immediately.
