# Buildkite migration tool overview

The Buildkite migration tool serves as a compatibility layer, enabling the conversion of some of your existing CI configurations into a format compatible with Buildkite's pipeline definitions.

You can start the translation of your pipelines from other CI providers to Buildkite Pipelines by seeing how workflows from other CI/CD platforms map to the Buildkite Pipelines' concepts and architecture.

Rather than serving as a complete automated migration solution, the Buildkite migration tool demonstrates how configurations from [GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines), and Jenkins (currently in beta) could be structured in a Buildkite pipeline configuration format.

The Buildkite migration tool can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Interactive web-based version

The Buildkite migration tool currently supports the following CI providers:

- [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
- [CircleCI](/docs/pipelines/migration/tool/circleci)
- [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
- Jenkins (currently in Beta)

The fastest way to get started with the Buildkite migration tool is to use its [interactive web version](https://buildkite.com/resources/migrate/).

<%= image "migration-tool-web.png", alt: "Buildkite migration tool's web UI" %>

To start translating your existing pipeline configuration into a Buildkite pipeline:

1. In the drop-down list, select your CI/CD platform.
1. Enter a pipeline definition you would like to translate into a Buildkite pipeline definition on the left side of the tool.
1. Click the **Convert** button.
1. You'll see the translated pipeline definition on the right side of the tool.
1. You can copy the resulting yaml pipeline configuration and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

### Conversion errors

If the pipeline configuration you are trying to convert to a Buildkite pipeline contains syntax or other errors, you might see the following pop-up **Conversion failed** message:

<%= image "conversion-failed.png", alt: "Error message in the Buildkite migration tool's web UI" %>

In this case, make sure that the original pipeline configuration you are trying to translate to a Buildkite pipeline configuration is a valid pipeline definition for the CI/CD platform you are migrating from.

## Local API-based version

If you would like to run the Buildkite migration tool locally, you can clone the [Buildkite migration tool repository](https://github.com/buildkite/migration) to run the migration tool's API via a HTTP API using `puma` from the `app` folder of this repository.

After cloning the [Buildkite migration tool repository](https://github.com/buildkite/migration), you can start the web UI with the following Docker command:

```sh
docker compose up webui
```

After starting the Docker image, you will be able to access the web interface of the Buildkite migration tool at `http://localhost:9292`.

<%= image "api-web-ui.png", alt: "Web UI of the API version of the Buildkite migration tool" %>

If you would prefer to use `docker run` command for starting the Buildkite migration too, you can also do it but you will need to override the entrypoint in the following way:

```shell
$ docker run --rm -ti -p 9292:9292 --entrypoint '' --workdir /app $IMAGE:$TAG puma --port 9292
```

You can also interact with the Buildkite migration tool programmatically and even pipe the output directly to `buildkite-agent pipeline upload`:

```shell
$ curl -X POST -F 'file=@app/examples/circleci/legacy.yml' http://localhost:9292
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

## Next steps

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Buildkite Migration Services](https://buildkite.com/resources/migrations/)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](https://buildkite.com/docs/pipelines/migration/from-bamboo)
