# Managing pipeline secrets

This page provides guidance on best practices for managing your secrets in a [hybrid Buildkite architecture](/docs/pipelines/getting-started#understand-the-architecture) with self-hosted agents in your own infrastructure, or using [Buildkite hosted agents](/docs/pipelines/hosted-agents). These secrets may be required by your Buildkite pipelines to access 3rd party systems as part of your build or deployment processes. However, these best practice guidelines help ensure that your secrets stay safely within your infrastructure and are never stored in, or sent to Buildkite.

## Using a secrets storage service

The best practice for managing secrets with Buildkite is to house your secrets within your own _secrets storage service_, such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [Hashicorp Vault](https://www.vaultproject.io).

Buildkite provides various [plugins](/docs/pipelines/integrations/plugins) that integrate reading and exposing secrets to your build steps using secrets storage services, such as the following. If a plugin for the service you use is not listed below or in the [Buildkite plugins directory](https://buildkite.com/resources/plugins), please contact support.

A secrets storage service can be used with either self-hosted agents in your own infrastructure, as part of a [hybrid Buildkite architecture](/docs/pipelines/getting-started#understand-the-architecture), or with [Buildkite hosted agents](/docs/pipelines/hosted-agents).

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

## Without a secrets storage service

While using a [secrets storage service](#using-a-secrets-storage-service) is the best practice for managing your secrets, if you don't or cannot use such a service and you use self-hosted agents in your own infrastructure, as part of a [hybrid Buildkite architecture](/docs/pipelines/getting-started#understand-the-architecture), this section provides alternative approaches to managing your pipeline secrets.

### Exporting secrets with environment hooks

You can use the Buildkite agent's `environment` hook to export secrets to a job.

The `environment` hook is a shell script that is sourced at the beginning of a job.
It runs within the job's shell, so you can use it to conditionally run commands and export secrets within the job.

By default, the `environment` hook file is stored in the agent's `hooks` directory.
The path to this directory varies by platform; read the [installation instructions](/docs/agent/v3/self-hosted/install) for the path on your platform.
The path can also be overridden by the [`hooks-path`](/docs/agent/v3/hooks#hook-locations-agent-hooks) setting.

For example, to expose a Test Engine API token to a specific pipeline, create an `environment` script in your agent's `hooks` directory that checks for the pipeline slug before exporting the secret:

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

### Storing secrets with the Elastic CI Stack for AWS

When using the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) with your own AWS account and environment, you can store your secrets inside your stack's encrypted S3 bucket.
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
aws s3 cp --acl private --sse aws:kms env "s3://elastic-ci-stack-my-stack-secrets-bucket/env"
# Remove the original file
rm env
```

See the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) readme for more information and examples.
