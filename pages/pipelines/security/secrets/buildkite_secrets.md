# Buildkite secrets

_Buildkite secrets_ is an encrypted key-value store secrets management service offered by Buildkite for use by the Buildkite Agent. These secrets can be accessed using the [`buildkite-agent secret get` command](/docs/agent/v3/cli-secret). The secrets are encrypted both at rest and in transit, and are decrypted on Buildkite's application servers when accessed by the agent.

Buildkite secrets:

- Are scoped within a given [cluster](/docs/pipelines/clusters), and are accessible to all agents within that cluster only, since each cluster has its own unique secrets encryption key. The secrets are decrypted by the Buildkite control plane and then sent to the agent.

- Are available to both [Buildkite hosted](/docs/pipelines/hosted-agents) as well as self-hosted agents.

## Create a secret

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

### From a build script or hook

Once you've [created a secret](#create-a-secret), the [`buildkite-agent secret get` command](/docs/agent/v3/cli-secret) can be used within the Buildkite Agent to print the secret's value to standard out (stdout). You can use this command within standard bash-like commands to redirect the secret's output into an environment variable, a file, or your own tool that uses the Buildkite secret's value directly, for example:

- Setting a Buildkite secret with the key `secret_name` into an environment variable called `SECRET_VAR`:

    `SECRET_VAR=$(buildkite-agent secret get secret_name)`

- Redirecting the value of a Buildkite secret with the key `secret_name` into a file called `secret.txt`:

    `buildkite-agent secret get secret_name > secret.txt`

- Passing the output of your Buildkite secret (via the `buildkite-agent secret get` command) to your own tool named `cli-tool` that accepts a secret via its `-token` option:

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

## Best practices

Buildkite secrets is not a zero-knowledge system, whereby Buildkite owns, stores, and manages the keys used for encrypting the secrets stored in the service at rest and in transit. You should implement additional controls to manage the lifecycle of secrets stored within Buildkite secrets, in addition to any monitoring capability you may require in line with your risk appetite. For example:

- Only store short-lived secrets in Buildkite secrets. Do not store long-lived secrets or secrets with no expiry in Buildkite secrets.
- Track the secrets stored in Buildkite secrets within your own asset management processes.
- Enable logging for services that are accessed using the secrets stored in Buildkite secrets.
- Should you detect a compromise or are concerned about the security of your secrets, please contact security@buildkite.com immediately.
