# Advantages of migrating from CircleCI

CircleCI is a hosted CI/CD platform built around a fixed hierarchy of organizations, VCS connections, and projects, where each project maps one-to-one to a repository. Buildkite Pipelines takes a different approach: instead of tying pipelines to a rigid project structure, it separates the control plane from the compute plane so you can run agents wherever you choose.

CircleCI works well for small teams getting started quickly, but its credit-based pricing, plan-based concurrency caps, and static configuration model can become obstacles as teams and repositories grow. Buildkite Pipelines is designed from the ground up for scale, flexibility, and predictable cost.

## Pipeline structure and flexibility

Because CircleCI pipelines only exist inside the org → VCS → project → repository structure, you cannot create multiple pipelines for a single repository, trigger pipelines across repositories, or run pipelines that operate independently of any repository.

Buildkite Pipelines treats pipelines as decoupled, runtime-programmable units. You can do all of the above, letting teams model CI/CD around how they actually build and ship software rather than conforming to a platform-imposed project structure.

## Scaling and limits

CircleCI's performance and throughput are constrained by plan-based concurrency, queued capacity, and shared-platform limits. The free plan caps concurrency at 30 jobs (one for macOS), and higher plans raise that cap but still impose fixed ceilings. Resource classes are predefined. As organizations scale, these limits show up as longer queue times and slower developer feedback loops.

Buildkite Pipelines scales by adding agents, without platform-imposed concurrency caps. The agent architecture is lightweight, supports 100,000+ concurrent agents, and offers turnkey autoscaling through the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws), [Elastic CI Stack for GCP](/docs/agent/self-hosted/gcp/elastic-ci-stack), and [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s).

## Dynamic pipelines vs. static config

CircleCI configuration is largely static and declarative: workflows are defined up front, and once a pipeline starts you are mostly choosing among predeclared paths. Commands, jobs, and workflows can be parameterized, which functions as a templating system, but adds cognitive load as configurations grow.

When teams outgrow a single configuration file, CircleCI offers two approaches to manage complexity, both with significant tradeoffs:

- **Config packing:** Split configuration across multiple files (`commands/`, `executors/`, `jobs/`, `workflows/`, `root.yml`) and run `circleci config pack` to generate a single merged config. In practice, this can produce generated configs of 4,000 lines or more, making execution paths difficult to trace.
- **Continuations:** An orb-based mechanism for selecting which YAML to continue with at runtime. Continuations are limited to a single continuation config per repository and are generally hard to reason about.

Both approaches attempt to work around the fact that CircleCI configuration is fundamentally static. Teams end up over-specifying "just in case" jobs and conditionals, which wastes compute and increases maintenance overhead.

In Buildkite Pipelines, [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) let you generate and modify steps at runtime using real code. You can decide what to run based on changed files, dependency graphs, repository state, or external signals. Instead of producing a monolithic config, you can isolate concerns across multiple pipelines and generate only the steps you need. The pipeline adapts during execution rather than forcing you to predeclare every possible path.

## Reliability and infrastructure control

CircleCI offers self-hosted runners, but orchestration, state management, logging, and storage still depend on CircleCI's managed control plane. When that shared infrastructure has issues, even teams running their own compute are affected.

Buildkite Pipelines separates orchestration from execution by design. Agents run on your infrastructure and handle checkout, execution, and artifact storage locally. The control plane coordinates work and receives metadata, but a control-plane interruption does not affect jobs already running on your agents.

## High-performance hosted machines

CircleCI provides hosted compute, but performance and cost can vary depending on the resource classes and what you need to add on top. Docker layer caching, for example, carries both a per-job credit cost and a storage cost, and all cached layers live entirely on CircleCI infrastructure with no option to redirect them elsewhere.

Buildkite gives you flexible compute options: run on your own infrastructure when that is best, or use [Buildkite hosted agents](/docs/agent/buildkite-hosted) when you want fully managed Linux or macOS compute. Hosted agents are designed for fast startup and isolated environments, with higher-performance options for workloads like mobile CI that benefit from modern Apple silicon. Persistent cache volumes on NVMe (Linux) and disk images (macOS) retain dependencies, Git mirrors, and Docker layers for up to 14 days.

## Data sharing and caching

CircleCI provides three built-in mechanisms for sharing data between jobs: caches (save and restore specific paths keyed by configurable cache keys), workspaces (persist and attach working directory state across jobs), and artifacts (meant for outputs consumed outside CI). These primitives are well-integrated but live entirely on CircleCI infrastructure with no option to use your own storage. Storage for caches, workspaces, and Docker layer caching all consume paid credits.

With Buildkite Pipelines, you control where data lives. [Artifacts](/docs/pipelines/configure/artifacts) can be stored in your own S3 bucket by setting environment variables on your agents. Caching strategies are flexible because agents run on your infrastructure, so you can use persistent volumes, shared network storage, or cache volumes on [Buildkite hosted agents](/docs/agent/buildkite-hosted). You are not locked into a single vendor-managed storage model.

## Centralized visibility and governance

CircleCI provides org-level Insights and dashboards, but platform teams managing CI across many projects may still find themselves coordinating governance, runner state, and pipeline standards across separate surfaces.

Buildkite Pipelines provides a unified dashboard that shows build health, queue metrics, and agent status across the entire organization. [Clusters](/docs/pipelines/security/clusters) let platform teams define isolated boundaries for agents and pipelines, and [pipeline templates](/docs/pipelines/governance/templates) enforce consistent build patterns across teams.

## Monorepo performance

CircleCI supports path filtering, but sophisticated monorepo strategies require additional custom glue to correctly model cross-directory dependencies and to avoid rebuilding unaffected services.

Buildkite Pipelines handles large [monorepos](/docs/pipelines/best-practices/working-with-monorepos) efficiently by making the pipeline itself programmable. [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) can implement dependency-aware builds and selective rebuilds, with the [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes) for declarative path filtering. This reduces wasted work and helps keep feedback fast as repository complexity grows.

## Orbs vs. plugins

CircleCI orbs are reusable YAML configuration abstractions that can define executors, commands, jobs, and workflows. Orbs are tightly coupled to CircleCI's config model and executor types. While orb source code can be reviewed, orbs are resolved and expanded at config compilation time, which means runtime behavior depends on how CircleCI processes the merged config.

Buildkite [plugins](/docs/pipelines/integrations/plugins) are versioned Git repositories that run directly on your agents as hooks. Because plugins execute on your infrastructure, runtime behavior is directly auditable in the environment where it runs. You can fork, modify, and pin plugins to specific commits.

## Test optimization

CircleCI has strong built-in test integration. The `store_test_results` step accepts JUnit output and provides a **Tests** tab in the UI with failed and flaky test visibility, along with tooling for test splitting when results are stored. These features are available even on basic plans.

[Buildkite Test Engine](/docs/test-engine) goes further with intelligent test splitting that balances suites dynamically using historical runtime data, automatic flaky test retries, flaky test quarantine, and rich analytics across your entire organization.

## Predictable pricing

CircleCI's credit-based billing can become difficult to predict as build volume grows. Credits are consumed by compute (job minutes), storage (Docker layer caching, caches, workspaces), and users. User costs can become the sharpest edge: each additional user beyond the plan's included count adds a significant credit cost, which can make CircleCI feel reasonable for small teams but increasingly hard to justify as the team grows. Different resource classes consume credits at different rates, and unused credits expire monthly.

Buildkite Pipelines [pricing](https://buildkite.com/pricing/) is based on agent concurrency using the 95th percentile, so occasional spikes don't inflate costs. You can also use your own compute including spot instances to reduce costs further.

## Job routing and priorities

CircleCI routes jobs through resource classes and self-hosted runner labels, but has no native priority system. When an urgent fix and a long-running test suite compete for the same runner pool, there is no built-in way to let the urgent job run first.

Buildkite Pipelines provides job routing through agent [queues](/docs/agent/queues) and tag-based matching, so you can direct different workloads to different compute pools. Combined with [priority settings](/docs/pipelines/configure/step-types/command-step#priority), urgent jobs move ahead of lower-priority work without manual intervention.

## Secret management

CircleCI secrets are managed through contexts configured in the UI, and each job must explicitly opt into a context. There is no alternative mechanism.

Buildkite Pipelines supports multiple approaches: [agent hooks](/docs/agent/hooks), Kubernetes secrets, S3, a [secrets manager](/docs/pipelines/security/secrets/managing), or the [HashiCorp Vault plugin](https://buildkite.com/resources/plugins/vault-secrets). Teams can choose the model that fits their security posture without being forced into a single UI-driven pattern.

## Migration path

Migrations from CircleCI are rarely a one-to-one YAML translation. CircleCI limitations often shape a team's CI architecture, and moving to Buildkite Pipelines is an opportunity to remove those constraints. The most effective approach is to rethink workflows around what Buildkite Pipelines makes possible: breaking apart monolithic configs into multiple pipelines, using [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) to reduce complexity, and taking advantage of flexible compute and storage.

To start converting your CircleCI pipelines to Buildkite Pipelines, use the following principles:

1. Audit your current setup: document orbs, resource classes, contexts, and workflows.
1. Convert CircleCI workflows to Buildkite Pipelines steps with explicit dependencies using `depends_on` and `wait`.
1. Replace orbs with equivalent Buildkite [plugins](https://buildkite.com/resources/plugins/) or inline commands.
1. Map CircleCI contexts to Buildkite Pipelines environment variables or a [secrets manager](/docs/pipelines/security/secrets/managing).
1. Remove explicit `checkout` steps, since Buildkite Pipelines checks out code automatically.
1. Start with non-production pipelines and run both systems in parallel to validate results.

If you would like to receive assistance in migrating from CircleCI to Buildkite Pipelines, please reach out to the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com).

===

# Summary (CircleCI vs Buildkite Pipelines)

---

###

#### How CircleCI is structured

- **Org first, then VCS connection:** You create an organization, then connect a VCS provider (primarily GitHub, Bitbucket, GitLab). That VCS connection is made at the **organization level**.
- **Projects map 1:1 to repos:** A CircleCI “project” is created from a repository, with a **one-to-one mapping** between projects and repositories.
- **Pipelines only exist inside that model:** You **cannot create pipelines outside** the org → VCS → project → repo structure.

#### Pricing and why it can become a problem for growing teams

- **Credits drive almost all pricing:** The cloud offering is priced primarily in **credits**.
- **What consumes credits:**
    - **Compute** (job minutes)
    - **Storage** (Docker layer caching, internal cache, workspaces)
    - **Users**, defined as **people committing to the repos** connected to projects (not just people logging into CircleCI)
    - Some networking configuration (cloud offering)
- **Free plan (as described):** ~30,000 credits, 5 users, 2GB storage, up to 30 concurrent jobs (macOS: 1).
- **Performance plan (as described):** Starts at $15/month. Includes free-plan credits plus additional credits, higher concurrency (80, macOS still 1), more runner sizes, and more self-hosted runners (20). Support is extra (email support cited as ~$250/month).
- **User scaling is the sharp edge:**
    - Going beyond **5 users** can become expensive quickly.
    - Additional users were described as effectively adding **large credit costs per user** (25,000 credits per user on one plan; 40,000 on Scale).
    - This can make CircleCI feel “reasonable for very small teams” but much harder to justify as the team grows, especially compared with GitHub Actions minutes included with GitHub plans.

#### Pipeline configuration model

- **YAML-based configuration:** Typically stored at `.circleci/config.yml`.
- **Workflow is the unit you run:**
    - **Workflows** contain **jobs**.
    - Jobs contain **steps/commands**.
    - The UI shows workflows and their jobs.
- **Templating and parameterization:** CircleCI allows **commands, jobs, and workflows** to be parameterized, functioning like a templating system.
- **Built-in steps (GitHub Actions-like):** CircleCI provides “special commands” such as `checkout`, `run`, caching steps, etc. If you omit `checkout`, the code is not checked out.

#### Sharing data between jobs (and the cost/complexity tradeoffs)

- CircleCI has three major mechanisms:
    - **Cache:** save/restore specific paths keyed by configurable cache keys (described as powerful and native to CircleCI config).
    - **Workspace:** persist the working directory state in one job and attach it in another job (useful for sharing dependencies like `node_modules`).
    - **Artifacts:** meant for outputs consumed **outside** CircleCI (humans or downstream consumers), not for internal job-to-job transfer.
- Tradeoff called out in the talk:
    - Hosted runners with Docker images are flexible, but enabling **Docker layer caching** can consume paid storage credits.
    - Docker layer caching was described as having a **per-job credit cost** as well as storage cost.

#### Triggers, scheduling, and “multiple pipelines per repo” realities

- Historically, CircleCI was described as being effectively **single pipeline config per repo** with conditional logic inside.
- Newer features:
    - **Triggers** based on VCS events (push, tag, release) are newer and were presented as a step toward supporting **multiple pipelines per repository**.
    - **Webhooks** and an **API** exist for triggering.
    - **Scheduled pipelines** were described as constrained (UI scheduling reportedly limited to GitHub; legacy/other approaches exist).

#### Reuse and modularity: Orbs, config packing, and continuations

- **Orbs (CircleCI “plugins”):**
    - Orbs are reusable packages, often maintained by CircleCI.
    - Orbs can define **executors, commands, jobs, workflows**, not just steps.
    - Example described: AWS orb defining executors with AWS CLI, and other orbs composing on top.
- **Config packing (“modernization” approach):**
    - Split config into multiple files (`commands/`, `executors/`, `jobs/`, `workflows/`, `root.yml`) then run `circleci config pack` to generate a single config.
    - This can lead to very large generated configs (example cited: 4,000+ lines), and makes it harder to understand execution paths.
- **Continuations:**
    - A special orb-based mechanism for selecting which YAML to continue with.
    - Described as **convoluted**, **hard to understand**, and limited (one continuation config per repo).
    - Presented as being pushed aside by newer trigger-based approaches.

#### Where CircleCI was described as strong

- **Test integration:**
    - “Superb” test integration, described as included even on basic plans.
    - Built-in `store_test_results` with JUnit support.
    - UI provides a **Tests** tab, failed/flaky visibility, and tooling for test splitting when results are stored.
- **Native caching + workspace support:** Strong built-in primitives for sharing between jobs.

#### Pain points and why teams migrate to Buildkite (as described)

- **Dynamic pipelines are a major differentiator for Buildkite:**
    - Buildkite can generate pipeline YAML programmatically and upload it, compressing large, hard-to-maintain YAML into scripts plus dynamic pipeline uploads.
    - Buildkite can isolate concerns across multiple pipelines, rather than forcing everything into one monolithic config.
- **CircleCI configs can become monolithic and hard to reason about:**
    - Either navigate many packed files to trace execution, or work with an enormous generated YAML.
    - Conditional/parameter-based patterns add cognitive load.
- **Approval steps / pipeline UX:**
    - Approval-gated jobs can make timing and run duration confusing in the UI (described as a long-running timer, and limited resumability after long periods).
- **Storage and caching economics:**
    - Docker layer caching can be expensive and fully lives on CircleCI infrastructure, limiting control.
- **Compliance and infrastructure control:**
    - Buildkite was described as more flexible for compliance and customization (agents, artifacts, and hooks).
    - Buildkite can redirect certain storage behaviors (example given: artifacts to an S3 bucket via environment variables).
    - CircleCI caches/workspaces/Docker layer cache were described as “100% on their side” with no alternative.
- **Secret management flexibility:**
    - CircleCI secrets are managed via **contexts** configured in the UI, and jobs must explicitly opt into contexts.
    - Buildkite was described as supporting multiple approaches (agent hooks, Kubernetes secrets, S3, Vault plugin), without forcing everything through a single UI-driven secret model.

#### Practical migration takeaways highlighted in the Q&A

- Migrations are rarely just “translate YAML 1:1.” A recurring theme is **reframing** the workflow into “the Buildkite way,” especially by:
    - Breaking apart monolithic configs.
    - Using multiple pipelines and dynamic pipelines to reduce complexity.
    - Educating teams that CircleCI limitations shaped their architecture (and those constraints can be removed post-migration).