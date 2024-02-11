# Buildkite Secrets

Only in the rarest cases does CI not need to access outside services, and in these cases, the usability of the CI is severely limited. To use CI effectively - and to move toward CD, continuous deployment - your CI system needs to be able to safely and securely interact with outside services like observability platforms, cloud providers, and other services.

To do this, you need to be able to securely store secrets like API credentials, SSH keys, and other sensitive information, and be able to use them safely and effectively in your builds. Buildkite Secrets provides such a way to do this - we'll securely store your secrets, and provide a way for you to access them in your builds.

Buildkite Secrets are an encrypted key-value store, where secrets are available to your builds via the Buildkite Agent. Secrets are encrypted both at rest and in transit using SSL, and are decrypted serverside when accessed by the agent. The agent makes it easy to use these secrets in your build scripts, and provides a way to inject secrets into your build steps as environment variables.

Secrets are scoped per-cluster, and all belong to a single cluster - that is, agents outside of the cluster the secret belongs to will not be able to access that secret.

## Security

**There is something we have to call out here so need to make sure it's in the docs**


## Alternatives to Buildkite secrets

Your secrets are important! We'd much rather your CI be as secure as possible, even if that means you don't use Buildkite Secrets. If you're not comfortable with Buildkite Secrets, there are a number of alternatives you can use to store and access secrets in your builds, all of which are compatible with and well-supported by Buildkite.

**Add examples of using the OIDC services to connect your secrets provider**


## Using Buildkite secrets

### UI

### API

> 📘 Not available in GraphQL
> There is currently no support for creating secrets though the GraphQL service.

### Terraform

## Using secrets in a build

### From within a build script/hook

The Buildkite agent comes packaged with utilities to get secret values from Buildkite secrets. In short, you can call buildkite-agent secret get --key “path/to/secret” to fetch the decrypted value of a secret from Buildkite. The Buildkite backend will ensure that the requesting agent has the necessary permissions to request the given secret.

The buildkite-agent secret get command prints the secret’s value to standard out, so you can use standard bash-isms to redirect it into an environment variable or a file, eg:

# Use a secret as an envar:
WIDGET_CORP_API_KEY="$(buildkite-agent secret get --key "path/to/widget_corp_api_key)"

# Send a secret into a file
buildkite-agent secret get --key "path/to/ssh_key" > "$HOME/.ssh/config"

Note that should the value of a secret be accidentally printed to standard out, it will be automatically redacted from the build logs.

### Injecting secrets via the Pipeline YAML

As an alternative to including calls to buildkite-agent secret get in your build scripts, the agent can be configured to inject secrets into Buildkite jobs prior to their execution. To do this, in your pipeline.yaml, add the secrets you want the job to use to a secrets block in the step:

```yaml
steps:
  - name: ":cog: Build it!"
    key: build
    command: ".buildkite/steps/build.sh"
    secrets:
      - key: /widget_corp/api_token_green
        env: WIDGET_CORP_API_TOKEN
      - key: /gadget_co/ssh_key
        file: ~/.ssh/ssh_key
```

Jobs for this step will be launched with an environment variable WIDGET_CORP_API_TOKEN, pre-filled with the decrypted value from Buildkite Secrets. Similarly, jobs will be launched with a file at the path ~/.ssh/ssh_key, likewise filled with the value stored in Buildkite Secrets. Upon finishing the job, all secrets will be cleared out of the environment, and all secret files deleted.

## Limits

<table>
    <thead>
        <tr><th>Condition</th><th>Limit</th></tr>
    </thead>
    <tbody>
        <tr><td>Key length</td><td>255 bytes</td></tr>
        <tr><td>Key composition</td><td>Must start with a forward slash. Alphanumeric and the following special characters</td></tr>
        <tr><td>Value length</td><td>65536 bytes</td></tr>
        <tr><td>Value composition</td><td>Must be valid UTF-8</td></tr>
        <tr><td>Secret count</td><td>10,000 Please contact support if you require an increase to your secrets limit</td></tr>
        <tr><td>API Rate Limit</td><td>1 Billion Requests per second</td></tr>
    </tbody>
</table>