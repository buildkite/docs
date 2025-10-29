# Buildkite migration tool overview

The Buildkite migration tool serves as a compatibility layer, enabling the conversion of your existing CI configurations into a format compatible with Buildkite's pipeline definitions.

You can start the translation of your pipelines from other CI providers to Buildkite Pipelines by seeing how workflows from other CI/CD platforms map to the Buildkite Pipelines' concepts and architecture. Rather than serving as a complete automated migration solution, the Buildkite migration tool demonstrates how configurations from these other CI/CD platforms could be structured in a Buildkite pipeline configuration format.

The Buildkite migration tool:

- Supports the following CI providers:

    * [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
    * [CircleCI](/docs/pipelines/migration/tool/circleci)
    * [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
    * [Jenkins (currently in beta)](/docs/pipelines/migration/tool/jenkins)

- Can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Interactive web-based version

The fastest way to get started with the Buildkite migration tool is to use its [interactive web version](https://buildkite.com/resources/migrate/), also known as the _Buildkite migration interactive web tool_.

<%= image "migration-tool-web.png", alt: "Buildkite migration tool's web UI" %>

To start translating your existing pipeline or workflow configuration into a Buildkite pipeline:

1. If you are using a CI/CD platform other than **GitHub Actions**, select it from this drop-down.
1. In the left panel, enter the pipeline definition to translate into a Buildkite pipeline definition.
1. Select the **Convert** button to reveal the translated pipeline definition in the right panel.
1. Copy the resulting Buildkite pipeline YAML configuration on the right and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

### Conversion errors

If the pipeline configuration you are trying to convert to a Buildkite pipeline contains syntax or other errors, you might see the following **Conversion failed** message.

<%= image "conversion-failed.png", alt: "Error message in the Buildkite migration tool's web UI" %>

In such cases, ensure that the original pipeline configuration you are translating to a Buildkite pipeline is a valid pipeline definition for the CI/CD platform you are migrating from.

## Local version

If you would like to run the Buildkite migration tool locally, because you're are interested in developing this tool further, or you'd prefer to work with your pipeline conversions locally, clone the [Buildkite migration tool repository](https://github.com/buildkite/migration) to run the migration tool using [Puma](https://github.com/puma/puma), which you can then access through its HTTP-based API.

To do this, after cloning this repository, start the Buildkite migration tool's web interface using the following Docker command:

```sh
docker compose up webui
```

After the Docker image has started, you'll be able to access the web interface of the Buildkite migration tool at `http://localhost:9292`.

<%= image "api-web-ui.png", alt: "Web UI of the API version of the Buildkite migration tool" %>

You can also use the `docker run` command to start the Buildkite migration tool, although you will need to override the entrypoint:

```shell
$ docker run --rm -ti -p 9292:9292 --entrypoint '' --workdir /app $IMAGE:$TAG puma --port 9292
```

Once the Buildkite migration tool is running locally, you can also interact with it programmatically, for example:

```shell
$ curl -X POST -F 'file=@app/examples/circleci/legacy.yml' http://localhost:9292
```
which should then return output like this:

```yaml
---
steps:
- commands:
  - "# No need for checkout, the agent takes care of that"
  - pip install -r requirements/dev.txt
  plugins:
  - docker#v5.7.0:
      image: circleci/python:3.6.2-stretch-browsers
  agents:
    executor_type: docker
  key: build
```

You could also pipe the output directly to `buildkite-agent pipeline upload`.

## Next steps

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Buildkite Migration Services](https://buildkite.com/resources/migrations/)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](/docs/pipelines/migration/from-bamboo)
