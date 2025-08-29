---
toc: false
---

# Migrate to Buildkite Pipelines overview

Migrating to Buildkite is a smooth process with the right context and planning. This page covers the tools and resources that will help you seamlessly transition from your existing CI/CD tool to Buildkite Pipelines.

## Migration tool

The Buildkite migration tool is designed to help you understand Buildkite by providing a hands-on, high-level overview of how workflows from other CI/CD platforms map to Buildkite Pipelines concepts and architecture.

Rather than serving as a complete automated migration solution, the Buildkite migration tool helps you visualize how configurations from from [GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines), and Jenkins (currently in beta) could be structured in the Buildkite Pipelines configuration format.

Using the Buildkite migration tool will accelerate your understanding of Buildkite concepts, allowing you to make informed decisions about how to rearchitect and optimize your pipelines for the Buildkite platform. Use the tool's output as a learning foundation, then iterate and refine your pipeline designs before beginning the actual migration process.

You can immediately start experimenting with the Buildkite migration tool in its [interactive web-based app](https://buildkite.com/resources/migrate/) form or run the Buildkite migration tool [locally via an HTTP API](/docs/pipelines/migration/tool#local-api-based-version).

<%= image "migration-tool-web-ui.png", alt: "Converting GitHub Actions pipeline to a Buildkite pipeline using Buildkite migration tool" %>

## Migration guides

The guides walk through the entire process step by step, covering the key aspects of migration, such as:

1. Understanding the differences.
1. Trying out Buildkite.
1. Provisioning agent infrastructure.
1. Translating pipeline definitions.
1. Integrating with your tools.
1. Sharing your setup.

To get started, choose the guide that corresponds to the CI/CD tool you are migrating from:

- [Migrate from Jenkins](/docs/pipelines/migration/from-jenkins)
- [Migrate from Bamboo](/docs/pipelines/migration/from-bamboo)

## Plan your migration

Take a look at the following information resource to understand how customers usually migrate to Buildkite. This resources section will keep expanding to cover the different strategies of migrating to Buildkite, the pitfalls and benefits of different approaches, and will help you plan your own migration to Buildkite.

- [Webinar: Strategies for migrating your CI/CD pipelines to Buildkite](https://www.youtube.com/watch?v=nV8u3dnEHZ0).

## Migration services

If you would like to receive assistance when migrating from your existing CI/CD provider to Buildkite Pipelines, you can make use of the [Buildkite Migration Services](https://buildkite.com/resources/migrations/) offer.

The Migration Services team works directly with your organization to provide strategic planning, implementation guidance, and proven best practices.

If you need further help, guidance, or have any questions, please reach out to support at support@buildkite.com. We're here to help you make a smooth transition to Buildkite.
