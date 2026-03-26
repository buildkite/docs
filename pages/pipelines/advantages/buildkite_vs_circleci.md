# Advantages of migrating from CircleCI

CircleCI is a hosted CI/CD platform built around a fixed hierarchy of organizations, VCS connections, and projects, where each project maps one-to-one to a repository. [Buildkite Pipelines](/docs/pipelines) takes a different approach: pipelines are decoupled from repositories, so you can create multiple pipelines per repository, trigger pipelines across repositories, or run pipelines independently of any repository.

CircleCI works well for small teams getting started quickly, but its credit-based pricing, plan-based concurrency caps, and static configuration model can become obstacles as teams and repositories grow. Buildkite Pipelines is designed from the ground up for scale, flexibility, and predictable cost.

## Pipeline structure and flexibility

CircleCI projects using the GitHub App integration can define multiple pipelines per project, each with its own configuration file and trigger. However, pipelines still live within the org → project → repository structure, and cross-repository triggering requires additional setup through separate trigger sources.

Buildkite Pipelines treats pipelines as decoupled, runtime-programmable units that are not tied to a specific repository. You can create multiple pipelines per repository, trigger pipelines across repositories, or run pipelines independently of any repository, letting teams model CI/CD around how they actually build and ship software.

## Scaling and limits

CircleCI's performance and throughput are constrained by plan-based concurrency, queued capacity, and shared-platform limits. The free plan caps concurrency at 30 jobs (one for macOS), and higher plans raise that cap but still impose fixed ceilings. Even self-hosted runners are limited by plan tier. As organizations scale, these limits show up as longer queue times and slower developer feedback loops.

Buildkite Pipelines scales by adding [agents](/docs/agent), without platform-imposed concurrency caps. The agent architecture is lightweight, supports 100,000+ concurrent agents, and offers turnkey autoscaling through the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws), [Elastic CI Stack for GCP](/docs/agent/self-hosted/gcp/elastic-ci-stack), and [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s).

## Dynamic pipelines vs. static configuration

CircleCI configuration is largely static and declarative: workflows are defined up front, and once a pipeline starts, you are mostly choosing among predeclared paths. Commands, jobs, and workflows can be parameterized, which functions as a templating system, but adds cognitive load as configurations grow.

While CircleCI now supports multiple pipelines per project, each individual pipeline configuration is still static. CircleCI offers two approaches to manage complexity within a configuration, both with significant tradeoffs:

- **Config packing:** Split configuration across multiple files (`commands/`, `executors/`, `jobs/`, `workflows/`, `root.yml`) and run `circleci config pack` to generate a single merged config. This trades readability for modularity: tracing a single workflow may require following references across many files in the folder structure.
- **Continuations:** An orb-based mechanism for selecting which YAML to continue with at runtime. Continuations are limited to a single continuation config per repository and are generally hard to reason about.

Both approaches still require heavy use of parameters to customize different execution paths, and attempt to work around the fact that CircleCI configuration is fundamentally static. Teams end up over-specifying "just in case" jobs and conditionals, which wastes compute and increases maintenance overhead.

With Buildkite Pipelines, [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) let you generate and modify steps at runtime using real code in whatever language suits your execution environment and your team's expertise. You can decide what to run based on changed files, dependency graphs, repository state, or external signals. Instead of producing a monolithic config, you can isolate concerns across multiple pipelines and generate only the steps you need. The pipeline adapts during execution rather than forcing you to predeclare every possible path.

## Reliability and infrastructure control

Both CircleCI and Buildkite Pipelines rely on a managed control plane for orchestration, and both support self-hosted runners that handle checkout and execution locally during a job.

With Buildkite Pipelines, you have additional control over where supporting infrastructure lives. For example, you can direct [artifact storage](/docs/pipelines/configure/artifacts) to your own S3 bucket, and use your own persistent volumes or shared network storage for caching. This means you can reduce dependencies on vendor-managed infrastructure for concerns beyond orchestration.

## High-performance hosted machines

CircleCI provides hosted compute, but performance and cost can vary depending on the resource classes and what you need to add on top. Docker layer caching, for example, carries both a per-job credit cost and a storage cost, and all cached layers live entirely on CircleCI infrastructure with no option to redirect them elsewhere.

Buildkite Pipelines offers flexible compute options: run on your own infrastructure using [self-hosted agents](/docs/agent/self-hosted) when that is the best option for your use case, or use [Buildkite hosted agents](/docs/agent/buildkite-hosted) when you want fully managed Linux or macOS compute. Hosted agents are designed for fast startup and isolated environments, with higher-performance options for workloads like mobile CI that benefit from modern Apple silicon. Persistent cache volumes on NVMe (Linux) and disk images (macOS) retain dependencies, Git mirrors, and Docker layers for up to 14 days.

## Data sharing and caching

CircleCI provides three built-in mechanisms for sharing data between jobs:

- Caches (save and restore specific paths keyed by configurable cache keys)
- Workspaces (persist and attach working directory state across jobs)
- Artifacts (meant for outputs consumed outside CI).

These primitives are well-integrated but live entirely on CircleCI infrastructure with no option to use your own storage. Storage for caches, workspaces, and Docker layer caching all consume paid credits. CircleCI has no built-in mechanism for sharing lightweight state between steps, such as key-value pairs generated at runtime.

With Buildkite Pipelines, you control where data lives. For lightweight state sharing, [meta-data](/docs/pipelines/configure/build-meta-data) lets steps exchange key-value pairs at runtime without file-based sharing. [Artifacts](/docs/pipelines/configure/artifacts) can be stored in your own S3 bucket by setting environment variables on your agents. Caching strategies are flexible because agents run on your infrastructure, so you can use persistent volumes, shared network storage, or cache volumes on [hosted agents](/docs/agent/buildkite-hosted). You are not locked into a single vendor-managed storage model.

## Centralized visibility and governance

CircleCI provides org-level Insights and dashboards for build performance, but has no built-in mechanism for enforcing pipeline standards or isolating groups of runners and pipelines for different teams.

Buildkite Pipelines provides a unified dashboard that shows build health, queue metrics, and agent status across the entire organization. [Clusters](/docs/pipelines/security/clusters) let platform teams define isolated boundaries for agents and pipelines, and [pipeline templates](/docs/pipelines/governance/templates) enforce consistent build patterns across teams.

## Monorepo performance

CircleCI supports path filtering, but sophisticated monorepo strategies require additional scripting and configuration to correctly model cross-directory dependencies and to avoid rebuilding unaffected services.

Buildkite Pipelines handles large [monorepos](/docs/pipelines/best-practices/working-with-monorepos) efficiently by making the pipeline itself programmable. [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) can implement dependency-aware builds and selective rebuilds, with the [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) for declarative path filtering. For teams that want a turnkey solution, the [Monorepo Diff plugin](https://buildkite.com/resources/plugins/monorepo-diff) watches for changes across directories and triggers the appropriate pipelines automatically. This reduces wasted work and helps keep feedback fast as repository complexity grows.

## Orbs vs. plugins

Both CircleCI orbs and Buildkite [plugins](/docs/pipelines/integrations/plugins) are versioned, open source, and can be forked and pinned. The key differences are when they run and what they can use. CircleCI resolves and expands orbs at config compilation time, before the job starts, and orbs are written almost exclusively in Bash. Buildkite plugins run directly on your agents as hooks during job execution, can be written in any language available on the agent, and their runtime behavior is directly auditable in the environment where they run.

## Test optimization

CircleCI has strong built-in test integration. The `store_test_results` step accepts JUnit output and provides a **Tests** tab in the UI with failed and flaky test visibility, along with tooling for test splitting when results are stored. These features are available even on basic plans.

[Buildkite Test Engine](/docs/test-engine) goes further with intelligent test splitting that balances suites dynamically using historical runtime data, automatic flaky test retries, flaky test quarantine, and rich analytics across your entire organization.

## Predictable pricing

CircleCI's credit-based billing can become difficult to predict as build volume grows. Credits are consumed by compute (job minutes), storage (Docker layer caching, caches, workspaces), and users. User costs can become the sharpest edge: CircleCI counts anyone who commits to a connected repository, not just users who log in to the UI, and each additional user beyond the plan's included count adds a significant credit cost that increases at higher plan tiers. This can make CircleCI feel reasonable for small teams but increasingly hard to justify as the team grows. Different resource classes consume credits at different rates, and unused credits expire monthly.

Buildkite Pipelines [pricing](https://buildkite.com/pricing/) is based on agent concurrency using the 95th percentile, so occasional spikes don't inflate costs. You can also use your own compute including spot instances to reduce costs further.

## Job routing and priorities

Both platforms support job routing: CircleCI uses resource classes and self-hosted runner labels, while Buildkite Pipelines uses agent [queues](/docs/agent/queues) and tag-based matching. The difference is prioritization. CircleCI has no native priority system, so when an urgent fix and a long-running test suite compete for the same runner pool, there is no built-in way to let the urgent job run first. Buildkite Pipelines [priority settings](/docs/pipelines/configure/step-types/command-step#priority) let urgent jobs move ahead of lower-priority work without manual intervention.

## Secret management

CircleCI secrets are managed through contexts configured in the UI, and each job must explicitly opt into a context. There is no alternative mechanism.

Buildkite Pipelines supports multiple approaches: [agent hooks](/docs/agent/hooks), Kubernetes secrets, S3, a [secrets manager](/docs/pipelines/security/secrets/managing), or the [HashiCorp Vault plugin](https://buildkite.com/resources/plugins/vault-secrets). Teams can choose the model that fits their security posture without being forced into a single UI-driven pattern.

## Migration path

Migrations from CircleCI are rarely a one-to-one YAML translation. CircleCI limitations often shape a team's CI architecture, and moving to Buildkite Pipelines is an opportunity to remove those constraints. The most effective approach is to rethink workflows around what Buildkite Pipelines makes possible: breaking apart monolithic configs into multiple pipelines, using [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to reduce complexity, and taking advantage of flexible compute and storage.

To start converting your CircleCI pipelines to Buildkite Pipelines, use the following principles:

1. Audit your current setup: document orbs, resource classes, contexts, and workflows.
1. Convert CircleCI workflows to Buildkite Pipelines steps with explicit dependencies using `depends_on` and `wait`.
1. Replace orbs with equivalent Buildkite [plugins](https://buildkite.com/resources/plugins/) or inline commands.
1. Map CircleCI contexts to Buildkite Pipelines [environment variables](/docs/pipelines/configure/environment-variables) or a [secrets manager](/docs/pipelines/security/secrets/managing).
1. Remove explicit `checkout` steps, since Buildkite Pipelines checks out code automatically.
1. Start with non-production pipelines and run both systems in parallel to validate results.

You can try out the [Buildkite pipeline converter](/docs/pipelines/migration/pipeline-converter) to see how your existing CircleCI pipelines might look converted to Buildkite Pipelines.

If you would like to receive assistance in migrating from CircleCI to Buildkite Pipelines, please reach out to the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com).
