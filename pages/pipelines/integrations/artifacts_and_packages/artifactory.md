# Artifactory

There are many ways to use [Artifactory](https://jfrog.com/artifactory/) with Buildkite. This document covers how to configure the Buildkite Agent's built-in Artifactory support, as well as how to use Artifactory's package management features in your Buildkite pipelines.

## Buildkite Agent's Artifactory support

The Buildkite Agent can upload and download artifacts directly from Artifactory. Export the following environment variables in your [Agent environment hook](/docs/agent/v3/hooks) to configure the Agent's Artifactory support.

See the [Managing pipeline secrets](/docs/pipelines/security/secrets/managing) documentation for how to securely set up these environment variables.

Required environment vars:

<table>
  <tr>
    <td><code>BUILDKITE_ARTIFACT_UPLOAD_DESTINATION</code></td>
    <td>
      The Artifactory repository and path that will be used to upload and download artifacts, starting with an rt:// prefix<br>
      <em>Example:</em> <code>"rt://some-repo/build-$BUILDKITE_BUILD_NUMBER/$BUILDKITE_JOB_ID/"</code><br>
    </td>
  </tr>
  <tr>
    <td><code>BUILDKITE_ARTIFACTORY_URL</code></td>
    <td>
      Your Artifactory instance URL, including the <code>/artifactory</code> suffix<br>
      <em>Example:</em> <code>https://my-artifactory-server/artifactory</code><br>
    </td>
  </tr>
  <tr>
    <td><code>BUILDKITE_ARTIFACTORY_USER</code></td>
    <td>
      The username of a user configured in your Artifactory instance<br>
      <em>Example:</em> <code>some-user</code><br>
    </td>
  </tr>
  <tr>
    <td><code>BUILDKITE_ARTIFACTORY_PASSWORD</code></td>
    <td>
      The <a href="https://jfrog.com/help/r/jfrog-platform-administration-documentation/api-key">API Key</a>, <a href="https://jfrog.com/help/r/jfrog-platform-administration-documentation/access-tokens">Access Token</a>, or password for your Artifactory user<br>
      <em>Example:</em> <code>AKCp5dKiQ9syTzu9GFhpF3iTzDcFhYAa4...</code><br>
    </td>
  </tr>
</table>

Once the above environment variables are configured, all artifact uploads and downloads will use Artifactory. For example, the following [command step](/docs/pipelines/configure/step-types/command-step) will build a binary and upload it to Artifactory using the `artifact_paths` attribute:

```yml
steps:
  - label: "\:golang\: \:package\:"
    command: "go build -v -o myapp-darwin-amd64"
    artifact_paths: "myapp-darwin-amd64"
    plugins:
      - docker#v3.3.0:
          image: "golang:1.11"
```
{: codeblock-file="pipeline.yml"}

<%= image "buildkite-artifact-step.png", width: 2320/2, height: 822/2, alt: "Screenshot of a Buildkite command step's output logging an artifact upload to Artifactory" %>

<%= image "artifactory-go-local-repository.png", width: 1484/2, height: 674/2, alt: "Screenshot of an artifact in the go-local repository in Artifactory" %>

> 📘 Retrieving artifacts using the Buildkite Agent  
> The Buildkite Agent uses Buildkite's APIs to fetch the correct URLs to download artifacts from Artifactory. By default, the agent searches for artifacts uploaded within the same build. To download artifacts that were uploaded in different builds using [`buildkite-agent artifact download`](/docs/agent/v3/cli-artifact#downloading-artifacts) or [artifacts-buildkite-plugin](https://github.com/buildkite-plugins/artifacts-buildkite-plugin), pass the [`BUILDKITE_BUILD_ID`](/docs/agent/v3/cli-artifact#downloading-artifacts-options) of the job through which the artifact was uploaded, as additional information to the `--build` option's argument.

## Using Artifactory for package management

To help cache and secure your build dependencies, you can use [Artifactory's package management](https://jfrog.com/help/r/jfrog-artifactory-documentation/package-management) features in your Buildkite pipelines. Each package management platform is configured differently.

For example, to use an [Artifactory NPM repositories](https://jfrog.com/help/r/jfrog-artifactory-documentation/npm-repositories) in your build steps, you can configure the following [Agent environment hook](/docs/agent/v3/hooks) to instruct the [npm command](https://docs.npmjs.com/cli/npm) to use Artifactory instead of npmjs.com:

```bash
export NPM_CONFIG_REGISTRY="https://${BUILDKITE_ARTIFACTORY_USER}:${BUILDKITE_ARTIFACTORY_PASSWORD}@my-artifactory-server/artifactory/api/npm/npm-local/"
```

You can use this same approach for [Ruby gem repositories](https://jfrog.com/help/r/jfrog-artifactory-documentation/rubygems-repositories), [Docker repositories](https://jfrog.com/help/r/jfrog-artifactory-documentation/docker-repositories), and any other Artifactory supported package managers.

If you're running build steps in a Docker container, you'll need to ensure the package management configuration is available inside the container. For example, if you're testing Node in a container, you'll need to pass through the above `NPM_CONFIG_REGISTRY` environment variable into the container:

```yml
steps:
  - label: "\:node\: \:hammer\:"
    commands:
      - npm install
      - npm test
    plugins:
      docker#v3.3.0:
        image: "node:11"
        environment:
          - NPM_CONFIG_REGISTRY
```
{: codeblock-file="pipeline.yml"}
