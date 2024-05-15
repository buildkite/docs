# Managing pipeline secrets

When you need to use secret values in your pipelines, there are some best practices you should follow to ensure they stay safely within your infrastructure and are never stored in, or sent to, Buildkite.

## Using a secrets storage service

A best practice for secret storage is to use your own secrets storage service, such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [Hashicorp Vault](https://www.vaultproject.io).

Buildkite provides various [plugins](/docs/plugins) that integrate reading and exposing secrets to your build steps using secrets storage services, such as the following. If a plugin for the service you use is not listed below or in [Buildkite's plugins directory](/docs/plugins/directory), please contact support.

<table>
    <thead>
        <tr><th>Service</th><th>Plugin</th></tr>
    </thead>
    <tbody>
        <tr><td>AWS SSM</td><td><a href="https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin">aws-assume-role-with-web-identity-buildkite-plugin</a></td></tr>
        <tr><td>GC Secrets</td><td><a href="https://github.com/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin">gcp-workload-identity-federation-buildkite-plugin</a></td></tr>
        <tr><td>Hashicorp Vault</td><td><a href="https://github.com/buildkite-plugins/vault-secrets-buildkite-plugin">vault-secrets-buildkite-plugin</a></td></tr>
    </tbody>
</table>

## Exporting secrets with environment hooks

If you don't use a secrets storage service, then you can use the Buildkite agent's `environment` hook to export secrets to a job.

The `environment` hook is a shell script that is sourced at the beginning of a job.
It runs within the job's shell, so you can use it to conditionally run commands and export secrets within the job.

By default, the `environment` hook file is stored in the agent's `hooks` directory.
The path to this directory varies by platform; read the [installation instructions](/docs/agent/v3/installation) for the path on your platform.
The path can also be overridden by the [`hooks-path`](/docs/agent/v3/hooks#hook-locations-agent-hooks) setting.

For example, to expose a Test Analytics API token to a specific pipeline, create an `environment` script in your agent's `hooks` directory that checks for the pipeline slug before exporting the secret:

```bash
#!/bin/bash
set -euo pipefail

if [[ "$BUILDKITE_PIPELINE_SLUG" == "pipeline-one" ]]; then
  export BUILDKITE_ANALYTICS_TOKEN="oS3AG0eBuUJMWRgkRvek"
fi
```
{: codeblock-file="hooks/environment"}

Adding conditional checks, such as the pipeline slug and step identifier, helps to limit accidental disclosure of secrets.
For example, suppose you have a step that runs a script expecting a `SECRET_DEPLOYMENT_ACCESS_TOKEN` environment variable, like this one:

```yml
steps:
  - command: scripts/trigger-deploy
    key: trigger-deploy
```
{: codeblock-file="pipeline.yml"}

In your `environment` hook, you can export the deployment token only when when the job is the deployment step in a specific pipeline:

```bash
#!/bin/bash
set -euo pipefail

if [[ "$BUILDKITE_PIPELINE_SLUG" == "my-app" && "$BUILDKITE_STEP_KEY" == "trigger-deploy" ]]; then
  export SECRET_DEPLOYMENT_ACCESS_TOKEN="bd0fa963610b..."
fi
```
{: codeblock-file="hooks/environment"}

The script exports `SECRET_DEPLOYMENT_ACCESS_TOKEN` only for the named pipeline and step.
Since this script runs for every job, you can extend it to selectively export all of the secrets used on that agent.

## Storing secrets with the Elastic CI Stack for AWS

To store secrets when using the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws), place them inside your stack's encrypted S3 bucket.
Unlike hooks defined in [agent `hooks-path`](/docs/agent/v3/hooks#hook-locations-agent-hooks),
the Elastic CI Stack for AWS's `env` hooks are defined per-pipeline.

For example, to expose a `GITHUB_MY_APP_DEPLOYMENT_ACCESS_TOKEN` environment
variable to a step with identifier `trigger-github-deploy`, you would create the
following `env` file on your local development machine:

```bash
#!/bin/bash
set -euo pipefail

if [[ "$BUILDKITE_STEP_KEY" == "trigger-github-deploy" ]]; then
  export GITHUB_MY_APP_DEPLOYMENT_ACCESS_TOKEN="bd0fa963610b..."
fi
```
{: codeblock-file="env"}

You then upload the `env` file, encrypted, into the secrets S3 bucket with the
following command:

```bash
# Upload the env
aws s3 cp --acl private --sse aws:kms env "s3://elastic-ci-stack-my-stack-secrets-bucket/my-app/env"
# Remove the original file
rm env
```

See the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) readme for more information and examples.

## Anti-pattern: Storing secrets in your pipeline settings

You should never store secrets on your Buildkite Pipeline Settings page. Not only does this expose the secret value to Buildkite, but pipeline settings are often returned in REST and GraphQL API payloads.

> 📘 Never store secret values in your Buildkite pipeline settings.

## Anti-pattern: Storing secrets in your pipeline.yml

You should never store secrets in the `env` block at the top of your pipeline steps, whether it's in a `pipeline.yml` file or the YAML steps editor.

```yml
env:
  # Security risk! The secret will be sent to and stored by Buildkite, and
  # be available in the "Uploaded Pipelines" list in the job's Timeline tab.
  GITHUB_MY_APP_DEPLOYMENT_ACCESS_TOKEN: "bd0fa963610b..."

steps:
  - command: scripts/trigger-github-deploy
```
{: codeblock-file="pipeline.yml"}

> 📘 Never store secrets in the <code>env</code> section of your pipeline.

## Anti-pattern: Referencing secrets in your pipeline YAML

You should never refer to secrets directly in your `pipeline.yml` file, as they may be interpolated during the [pipeline upload](/docs/agent/v3/cli-pipeline#uploading-pipelines) and sent to Buildkite. For example:

```yaml
steps:
  # Security risk! The environment variable containing the secret will be
  # interpolated into the YAML file and then sent to Buildkite.
  - command: |
      curl \
        --header "Authorization: token $GITHUB_MY_APP_DEPLOYMENT_ACCESS_TOKEN" \
        --header "Content-Type: application/json" \
        --request POST \
        --data "{\"ref\": \"$BUILDKITE_COMMIT\"}" \
        https://api.github.com/repos/my-org/my-app/deployments
```
{: codeblock-file="pipeline.yml"}

Referencing secrets in your steps risks them being interpolated, uploaded to Buildkite, and shown in plain text in the "Uploaded Pipelines" list in the job's Timeline tab.

The Buildkite agent does [redact strings](/docs/pipelines/managing-log-output#redacted-environment-variables) that match the values off of environment variables whose names match common password patterns such as `*_PASSWORD`, `*_SECRET`, `*_TOKEN`, `*_ACCESS_KEY`, and `*_SECRET_KEY`.

To prevent the risk of interpolation, it is recommended that you replace the command block with a script in your repository, for example:

```yml
steps:
  - command: scripts/trigger-github-deploy
```
{: codeblock-file="pipeline.yml"}

> 📘
> Use <a href="/docs/pipelines/writing-build-scripts">build scripts</a> instead of <code>command</code> blocks for steps that use secrets.

If you must define your script in your steps, you can prevent interpolation by using the `$$` syntax:

```yml
steps:
  # By using $$ the value of the secret is never sent to Buildkite. This is
  # still not best practice, as it's easy to forget the additional $ character
  # and expose the secret.
  - command: |
      curl \
        --header "Authorization: token $$GITHUB_MY_APP_DEPLOYMENT_ACCESS_TOKEN" \
        --header "Content-Type: application/json" \
        --request POST \
        --data "{\"ref\": \"$$BUILDKITE_COMMIT\"}" \
        https://api.github.com/repos/my-org/my-app/deployments
```
{: codeblock-file="pipeline.yml"}
