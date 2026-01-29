# Advantages of migrating from GitLab

GitLab is a DevSecOps platform covering the entire software development lifecycle. Buildkite Pipelines takes a different approach: instead of doing a little bit of everything, it focuses on doing CI/CD exceptionally well.

## Lightweight Buildkite Agents vs. heavyweight runners

GitLab runners are full compute units requiring specific executors (shell, Docker, Kubernetes) and complex setup with firewall rules and connectivity requirements. Most GitLab customers use hosted runners because self-hosting is complicated.

Buildkite Agents are lightweight software that can run anywhere with a simple outbound HTTPS connection. Multiple agents can run per CPU, and setup in Kubernetes is straightforward. Your code and builds stay in your environment by default.

## Flexible pipelines vs. rigid stages

GitLab pipelines use predefined stages (build, test, deploy) that enforce serial execution order. Jobs are grouped into stages and execute sequentially. Dynamic capabilities are limited to "child pipelines" that require project-level configuration.

Buildkite Pipelines has no predefined stages. You can use `depends_on` and `wait` steps to build custom DAGs with full flexibility. [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) generate steps on the fly during execution based on runtime conditions, repository state, or any custom logic.

## Better monorepo performance

GitLab struggles with large monorepo structures at scale. Buildkite Pipelines handles monorepos efficiently through dynamic pipeline generation that can analyze dependencies and selectively build only what changed.

## Simpler job routing

GitLab tags require exact matches. If a job has tags `[Linux, GPU, Docker]`, a runner must have all three tags. Buildkite queues and tags offer more flexibility, allowing agents to match jobs based on various criteria without requiring exact tag matching.

## Explicit artifact control

GitLab automatically passes artifacts between stages, which can obscure state management. Buildkite Pipelines uses explicit `artifact_upload` and `artifact_download` commands, giving you clear control over what moves between steps.

## Predictable pricing vs. runner minutes

GitLab charges for runner minutes on top of user fees. This poses a risk of exceeding the monthly allocation and facing unexpected bills. You also cannot mix pricing tiers within an organization: if you want Ultimate features, every user must be on Ultimate.

Buildkite Pipelines pricing is based on agent concurrency, typically using the 95th percentile. No surprise bills from exceeding allocations, and short bursts don't inflate costs.

## Integration with GitLab SCM

Some organizations use GitLab for source code management while using Buildkite Pipelines for CI/CD. Buildkite Pipelines integrates with GitLab via webhooks, triggering pipelines from Git events. This way, you get GitLab's SCM features with Buildkite's superior CI/CD performance.

## Migration path

To start converting your existing GitLab pipelines to Buildkite Pipelines, use the following principles:

1. Audit current setup: document variables, tags, routing logic, and performance benchmarks.
1. Convert pipeline structure from serial stages to parallel steps with explicit dependencies.
1. Map GitLab predefined variables to Buildkite Pipelines equivalents.
1. Replace automatic artifact passing with explicit upload/download commands.
1. Start with non-production pipelines and run both systems in parallel to validate results.

Teams typically see faster execution through better parallelization, reduced infrastructure complexity, more predictable costs, and simplified agent management after migration.
