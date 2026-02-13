# Advantages of migrating from Jenkins

Jenkins is the original open-source automation server that pioneered CI/CD. Buildkite Pipelines takes a different approach: instead of self-managing everything, it pairs a managed control plane with your own infrastructure to deliver the speed and reliability that modern engineering teams need.

Jenkins has served the CI/CD community for over 20 years, but the architecture that enabled its flexibility creates operational challenges at scale.

## Managed control plane

By default, Jenkins is primarily self-hosted. You need to deploy, scale, secure, and upgrade your controllers yourself. When a controller is slow or down, developers are blocked.

Buildkite Pipelines separates orchestration from execution: a managed SaaS control plane with agents running on your infrastructure. In Buildkite Pipelines, can choose between self-hosted and [hosted agents](/docs/agent/v3/buildkite-hosted).

## Buildkite Agents

Jenkins upgrades are notoriously difficult, often delayed for years due to plugin compatibility risks. With Buildkite Pipelines, the control plane updates continuously. Agent updates are also straightforward and incremental.

In contrast to Jenkins, Buildkite Agents are ephemeral by design: spin up, run a job, tear down. This ensures clean, reproducible builds.

## Scaling without a central bottleneck

Adding Jenkins capacity means tuning controllers and executors. Buildkite Agents poll for work. Adding capacity means adding agents, with no central bottleneck.

## Simpler pipelines

Jenkins Groovy pipelines are powerful but complex, with pitfalls that can affect controller stability. Buildkite Pipelines uses YAML, which is easier to read and version-control.

See more in [Pipeline design and structure](/docs/pipelines/best-practices/pipeline-design-and-structure).

## Dynamic pipelines

With the help of Buildkite [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), you can generate or modify steps at runtime based on changed files, repository state, or any custom logic. Fan out tests only after builds succeed, skip unnecessary steps, or generate deployment steps based on what actually changed.

## Fewer plugin dependencies

Jenkins has more than 1,800 plugins of varying quality. Plugin issues can destabilize entire controllers. Buildkite Pipelines' core features are built in, and the [Buildkite plugins](/docs/pipelines/integrations/plugins) run on agents, isolating failures to individual builds.

## Lower total cost

Jenkins is free to download but requires dedicated admin teams to manage the infrastructure. Buildkite Pipelines reduces operational overhead, letting your team focus on building and delivering software.

## Migration path

You can try out the [Buildkite pipeline converter](/docs/pipelines/migration/pipeline-converter) to see how your converted Jenkins pipelines look in Buildkite Pipelines.

To start converting your Jenkins pipelines to Buildkite Pipelines, follow the instructions in [Migrate from Jenkins](/docs/pipelines/migration/from-jenkins), then migrate pipeline by pipeline. The main challenge you might face in the migration is cultural: shifting from sequential execution and shared workspaces to Buildkite's parallel-by-default, fresh-workspace model.

For help migrating migrating from Jenkins to Buildkite Pipelines, please reach out to the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com).
