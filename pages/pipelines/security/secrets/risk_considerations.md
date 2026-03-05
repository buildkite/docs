# Risk considerations

This page covers some of the risks associated with managing secrets with Buildkite Pipelines, and _practices you should avoid_ to mitigate these risks.

When appropriate, some guidance is provided on alternative approaches to mitigate these risks.

## Storing secrets in your pipeline settings

You should never store secrets on your Buildkite Pipeline Settings page. Not only does this expose the secret value to Buildkite, but pipeline settings are often returned in REST and GraphQL API payloads.

> 📘 Never store secret values in your Buildkite pipeline settings.

## Storing secrets in your pipeline.yml

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

> 📘 Never store secrets in the `env` section of your pipeline.

## Referencing secrets in your pipeline YAML

You should never refer to secrets directly in your `pipeline.yml` file, as they may be interpolated during the [pipeline upload](/docs/agent/cli/reference/pipeline#uploading-pipelines) and sent to Buildkite. For example:

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

The Buildkite agent does [redact strings](/docs/pipelines/configure/managing-log-output#redacted-environment-variables) that match the values off of environment variables whose names match common password patterns such as `*_PASSWORD`, `*_SECRET`, `*_TOKEN`, `*_PRIVATE_KEY` ,  `*_ACCESS_KEY`, `*_SECRET_KEY`, and `*_CONNECTION_STRING` .

To prevent the risk of interpolation, it is recommended that you replace the command block with a script in your repository, for example:

```yml
steps:
  - command: scripts/trigger-github-deploy
```
{: codeblock-file="pipeline.yml"}

> 📘
> Use [build scripts](/docs/pipelines/configure/writing-build-scripts) instead of `command` blocks for steps that use secrets.

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
