# Advantages of migrating from Jenkins

Jenkins has served the CI/CD community for over 20 years, but the architecture that enabled its flexibility creates operational challenges at scale.

## Managed control plane

Jenkins is self-hosted only. You deploy, scale, secure, and upgrade your controllers. When a controller is slow or down, developers are blocked. Buildkite Pipelines separates orchestration from execution: a managed SaaS control plane with agents running on your infrastructure.

## Buildkite Agents

Jenkins upgrades are notoriously difficult, often delayed for years due to plugin compatibility risks. With Buildkite Pipelines, the control plane updates continuously. Agent updates are also straightforward and incremental. Also, in contrast to Jenkins, Buildkite Agents are ephemeral by design: spin up, run a job, tear down. This ensures clean, reproducible builds.

## Effortless scaling

Adding Jenkins capacity means tuning controllers and executors. Buildkite Agents poll for work. Adding capacity means adding agents, with no central bottleneck.

## Simpler pipelines

Jenkins Groovy pipelines are powerful but complex, with pitfalls that can affect controller stability. Buildkite uses YAML, which is easier to read and version-control.

See more in [Pipeline design and structure](/docs/pipelines/design-and-structure).

## Fewer plugin dependencies

Jenkins has 1,800+ plugins of varying quality. Plugin issues can destabilize entire controllers. Buildkite's core features are built in, and the [Buildkite plugins](/docs/pipelines/integrations/plugins) run on agents, isolating failures to individual builds.

## Lower total cost

Jenkins is free to download but requires dedicated admin teams to manage the infrastructure. Buildkite Pipelines reduces operational overhead, letting your team focus on shipping software.

## Migration path

To start converting your Jenkins pipelines to Buildkite Pipelines, follow the instructions in [Migrate from Jenkins](/docs/pipelines/migration/from-jenkins), then migrate pipeline by pipeline. The main challenge you might face in the migration is cultural: shifting from sequential execution and shared workspaces to Buildkite's parallel-by-default, fresh-workspace model.

You can also try out the the [Buildkite pipeline converter](/docs/pipelines/migration/pipeline-converter) to see how your existing Jenkins pipelines might look like converted to Buildkite Pipelines.
