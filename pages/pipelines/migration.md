---
toc: false
---

# Migrate to Buildkite Pipelines overview

Migrating to Buildkite is a smooth process with the right context and planning. This page covers the tools and resources that will help you seamlessly transition from your existing CI/CD tool to Buildkite Pipelines.

## Strategic overview

The following resources provide you with a high-level strategic overview of a process of migration from your current CI/CD platform to Buildkite:

- [Webinar: Strategies for migrating your CI/CD pipelines to Buildkite](https://www.youtube.com/watch?v=nV8u3dnEHZ0)
- PDF guide: The CI/CD Migration Playbook

## Migration tool

To start translating your existing pipelines from other CI providers to Buildkite Pipelines, you can use the [Buildkite migration tool](/docs/pipelines/migration/tool).

Instead of manually rewriting all of your pipeline definitions, the Buildkite migration tool helps you automatically translate configurations from [GitHub Actions](/docs/pipelines/migration/tool/github-actions), [CircleCI](/docs/pipelines/migration/tool/circleci), [Bitbucket Pipelines](/docs/pipelines/migration/tool/bitbucket-pipelines), and Jenkins (currently in beta) into compatible Buildkite formats.

The tool intelligently handles platform-specific features like matrix builds, executor mappings, and step dependencies, preserving your workflow logic while adapting it to Buildkite's architecture. This automated approach significantly reduces migration time and helps ensure your converted pipelines maintain the same functionality as your original configurations where maintaining equivalent functionality is possible.

You can immediately start using the Buildkite migration tool as an [interactive web-based app](https://buildkite.com/resources/migrate/) or run the Buildkite migration tool [locally via an HTTP API](/docs/pipelines/migration/tool#local-api-based-version).

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

## Migration services

If you would like to receive assistance when migrating from your existing CI/CD provider to Buildkite Pipelines, you can make use of the [Buildkite Migration Services](https://buildkite.com/resources/migrations/) offer.

The Migration Services team works directly with your organization to provide strategic planning, implementation guidance, and proven best practices.

If you need further help, guidance, or have any questions, please reach out to support at support@buildkite.com. We're here to help you make a smooth transition to Buildkite.
