# Buildkite migration tool overview

The Buildkite migration tool helps you start the transition of pipelines from other CI providers to Buildkite Pipelines by demonstrating how workflows from other CI/CD platforms map to Buildkite Pipelines concepts and architecture. It serves as a compatibility layer, enabling the conversion of some of your existing CI configurations into a format compatible with Buildkite's pipeline definition.

Rather than serving as a complete automated migration solution, the Buildkite migration tool helps you visualize how configurations from from [GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines), and Jenkins (currently in beta) could be structured in Buildkite pipeline configuration format.

The Buildkite migration tool can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Interactive web-based version

The fastest way to get started with the Buildkite migration tool is to use it as an [interactive web tool](https://buildkite.com/resources/migrate/).

<%= image "migration-tool-web.png", alt: "Buildkite migration tool's web UI" %>

The Buildkite migration tool currently supports the following CI providers:

- [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
- [CircleCI](/docs/pipelines/migration/tool/circleci)
- [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
- Jenkins (currently in Beta)

To start translating your existing pipeline configuration into a Buildkite pipeline:

1. In the drop-down list, select your CI/CD platform.
1. Enter a pipeline definition you would like to translate into a Buildkite pipeline definition on the left side of the tool.
1. Click the **Convert** button.
1. You'll see the translated pipeline definition on the right side of the tool.
1. You can copy the resulting yaml pipeline definition and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

In the following chapters, you will find example pipeline snippets from GitHub Actions, CircleCI, and Bitbucket pipeline definitions and the results you are expected to get after converting them to Buildkite pipeline configurations by running the Buildkite migration tool. In each example, two steps are decidedly easily translatable to Buildkite pipeline configuration and one is not. This approach should give you an idea of what you'll see when translating a real-world pipeline configuration where some parts map well to Buildkite while other parts do not have an exact equivalent in Buildkite.

## Local API-based version

If you would like to run the Buildkite migration tool locally, you can clone the [Buildkite migration tool repository](https://github.com/buildkite/migration) to run the migration tool's API via a HTTP API using `puma` from the `app` folder of this repository.

You start the web UI with either of the following Docker commands:

```sh
docker compose up webui
```

> 📘
> If you are using `docker run`, you will need to override the entrypoint:

```shell
$ docker run --rm -ti -p 9292:9292 --entrypoint '' --workdir /app $IMAGE:$TAG puma --port 9292
```

After that, you will be able to access a web interface at `http://localhost:9292`.

You can also programmatically interact with it (and even pipe the output directly to `buildkite-agent pipeline upload`):

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
