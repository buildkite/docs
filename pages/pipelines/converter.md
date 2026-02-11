# Buildkite pipeline converter overview

The Buildkite pipeline converter serves as a compatibility layer, allowing you to try conversion of your existing CI configurations into a format compatible with Buildkite's pipeline definitions.

Rather than serving as a complete automated migration solution, the Buildkite pipeline converter demonstrates how configurations from these other CI/CD platforms could be structured in a Buildkite pipeline configuration format.

To get started with the Buildkite pipeline converter, use its [interactive web version](https://buildkite.com/resources/convert/).

<%= image "pipeline-converter-web.png", alt: "Buildkite pipeline converter's web UI" %>

Or use the [`bk pipeline convert` command](/docs/platform/cli/reference/pipeline#convert-pipeline) of the [Buildkite CLI](/docs/platform/cli).

## How to use the pipeline converter

To start translating your existing pipeline or workflow configuration into a Buildkite pipeline:

1. If you are using a CI/CD platform other than **GitHub Actions**, select it from this dropdown.
1. In the left panel, enter the pipeline definition to translate into a Buildkite pipeline definition.
1. Select the **Convert** button to reveal the translated pipeline definition in the right panel.
1. Copy the resulting Buildkite pipeline YAML configuration on the right and [create](/docs/pipelines/configure) a [new Buildkite pipeline](https://www.buildkite.com/new) with it.

An AI Large Language Model (LLM) is used to achieve the best results in the translation process. The LLM analyzes the Bitbucket Pipelines configuration to understand its structure and intent, and then generates a functionally equivalent Buildkite pipeline. The AI model _does not_ use any submitted data for its own training.

> 🚧 Conversion errors
> If the pipeline configuration you are trying to convert to a Buildkite pipeline contains syntax or other errors or is not a valid pipeline configuration, you will see an error message _"This doesn't look like valid YAML. Please paste your pipeline configuration."_ In this case, ensure that the original pipeline configuration you are translating to a Buildkite pipeline is a valid pipeline definition for the CI/CD platform you are migrating from.

## Compatibility

The Buildkite pipeline converter Supports the following CI providers:

- [GitHub Actions](/docs/pipelines/migration/tool/github-actions)
- [CircleCI](/docs/pipelines/migration/tool/circleci)
- [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines)
- [Jenkins](/docs/pipelines/migration/tool/jenkins)
- Bitrise (beta)
- GitLab CI (beta)
- Harness (beta)

The converter can be used as a standalone tool or potentially integrated into your [Buildkite Migration Services](https://buildkite.com/resources/migrations/) process, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Next steps

For more tools and recommendations regarding migrating from your existing CI/CD platform to Buildkite, see:

- [Migrate to Buildkite Pipelines](/docs/pipelines/migration)
- [Buildkite Migration Services](https://buildkite.com/resources/migrations/)
- [Migration from Jenkins - a step-by-step guide](/docs/pipelines/migration/from-jenkins)
- [Migration from Bamboo - a step-by-step guide](/docs/pipelines/migration/from-bamboo)
