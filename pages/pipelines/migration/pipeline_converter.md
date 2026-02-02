# Buildkite pipeline converter overview

The Buildkite pipeline converter serves as a compatibility layer, enabling the conversion of your existing CI configurations into a format compatible with Buildkite's pipeline definitions.

You can start the translation of your pipelines from other CI providers to Buildkite Pipelines by seeing how workflows from other CI/CD platforms map to the Buildkite Pipelines' concepts and architecture.

Rather than serving as a complete automated migration solution, the Buildkite pipeline converter demonstrates how configurations from these other CI/CD platforms could be structured in a Buildkite pipeline configuration format.

The Buildkite pipeline converter:

- Supports the following CI providers:

    * [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
    * [CircleCI](/docs/pipelines/migration/tool/circleci)
    * [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
    * [Jenkins](/docs/pipelines/migration/tool/jenkins)

- Can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

- Can be run using the [`bk pipeline convert` command](/docs/platform/cli/reference/pipeline#convert-pipeline) of the [Buildkite CLI](/docs/platform/cli).

## Interactive web-based version

To get started with the Buildkite pipeline converter, use its [interactive web version](https://buildkite.com/resources/convert/).

<%= image "pipeline-converter-web.png", alt: "Buildkite pipeline converter's web UI" %>

To start translating your existing pipeline or workflow configuration into a Buildkite pipeline:

1. If you are using a CI/CD platform other than **GitHub Actions**, select it from this dropdown.
1. In the left panel, enter the pipeline definition to translate into a Buildkite pipeline definition.
1. Select the **Convert** button to reveal the translated pipeline definition in the right panel.
1. Copy the resulting Buildkite pipeline YAML configuration on the right and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

### Conversion errors

If the pipeline configuration you are trying to convert to a Buildkite pipeline contains syntax or other errors, you might see a **Conversion failed** message.

In this case, ensure that the original pipeline configuration you are translating to a Buildkite pipeline is a valid pipeline definition for the CI/CD platform you are migrating from.

## Next steps

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Buildkite Migration Services](https://buildkite.com/resources/migrations/)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](/docs/pipelines/migration/from-bamboo)
