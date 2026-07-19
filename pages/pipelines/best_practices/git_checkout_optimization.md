# Git checkout optimization

This page covers best practices for optimizing Git workflows in Buildkite Pipelines through the use of shallow clones, sparse checkout, and Git mirrors.

> 📘 Checkout configuration reference
> For configuration details on individual checkout options such as `skip`, `depth`, `submodules`, `sparse`, `flags`, and `commit_verification`, see [Git checkout](/docs/pipelines/configure/git-checkout). This page focuses on optimization strategies.

## Shallow clones

Shallow clones limit the number of commits fetched during checkout, which reduces both download time and disk usage. This is one of the simplest ways to speed up checkout for repositories with long histories where the build only needs recent code.

Buildkite Pipelines supports shallow clones natively through the `checkout.depth` key in your pipeline YAML. Set `checkout.depth` to a positive integer to fetch only that many commits.

Shallow clones work well for steps that compile code, run tests, or perform other tasks that only need the current state of the repository. They are not suitable for steps that require full Git history, such as changelog generation, `git blame`, or `git merge-base` operations.

## Sparse checkout

Sparse checkout is a [Git feature](https://git-scm.com/docs/git-sparse-checkout) that allows you to check out only a subset of paths from a repository into your working directory, while the local repository still retains the full commit history. This speeds up operations and reduces disk usage on very large, monorepo-style projects, without changing the repository itself or requiring server-side setup.

Buildkite Pipelines supports sparse checkout natively through the `checkout.sparse` key in your pipeline YAML. For full details on configuring sparse checkout, including cone mode behavior, Git version requirements, and submodule limitations, see [Git checkout](/docs/pipelines/configure/git-checkout).

You can also use the [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/), which supports cone and non-cone patterns, optional aggressive cleanup, skipping `ssh-keyscan`, and verbose mode for debugging.

## Git mirrors

[Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) are one of the most effective ways to speed up Git checkouts in Buildkite Pipelines. Instead of fetching the entire repository from your remote Git server every time, agents maintain a single local bare mirror of each repository on the host machine.

When a build runs, the Buildkite agent performs a fast local clone from the mirror by using `git clone --reference` flag, significantly reducing checkout times, especially for large repositories or those with extensive histories. Submodules also benefit from this optimization by referencing the mirror during their checkout process.

## Comparing optimization approaches

Shallow clones, sparse checkout, and Git mirrors solve different problems and can be combined. Understanding when to use each can make a real difference in your build performance.

**Shallow clones:**

- Reduce the amount of history fetched, which speeds up the clone and fetch phases.
- Have no effect on which files appear in the working directory — all paths are still checked out.
- Require no infrastructure changes or Git version constraints.
- Best suited for build and test steps that only need recent commits.

**Sparse checkout:**

- Is client-side only, so no extra infrastructure or separate repository is required for its implementation.
- Downloads the full repository history but only checks out the selected paths in the working tree — the files and folders that you actually need in your working directory.
- Useful for [monorepo](/docs/pipelines/best-practices/working-with-monorepos) teams where different teams touch different directories — for example, when the frontend developers don't need backend code cluttering their workspace (and vice versa).

**Git mirrors:**

- A separate copy of your repository (typically created with `--mirror` or `--bare`) that mirrors another repository and acts as a local cache.
- Useful in CI/CD environments with frequent builds to avoid repeatedly hitting your Git server.
- Can mirror everything (all refs and history) or be combined with filtering if you build specialized mirrors.
- Require some upfront setup and ongoing maintenance, but result in faster checkout times.

### Combining approaches

You can use `checkout.depth` and `checkout.sparse` together. When combined, the agent performs a shallow clone with the specified depth and checks out only the specified paths. This gives you both reduced history and a smaller working directory, which is useful for monorepo steps that need only a few directories and no historical context.

### When to use which

- Use a shallow clone when you want to reduce checkout time with minimal configuration and no infrastructure changes.
- Use sparse checkout when you’re optimizing developer workstation performance — for example, developers need to work in a large repository but only on a few directories, optimizing local checkouts and IDE performance without changing server infrastructure.
- Use a Git mirror when you’re optimizing distribution, reliability, or centralization for automation and scaling — for example, when you need a replicated source of truth for CI, faster clones for many agents, network isolation, or migration between hosts.

## Understanding checkout defaults across platforms

The default checkout behavior in Buildkite Pipelines prioritizes completeness and flexibility. As a result, if you're migrating to Buildkite Pipelines from another CI/CD platform, especially if you're using LFS, you might notice differences in checkout speed or behavior.

To understand how Buildkite's checkout defaults differ from other platforms in a GitHub Actions-based example (including LFS handling, shallow clones, and customization options), see [Understanding the difference in default checkout behaviors](/docs/pipelines/migration/from-githubactions#understand-the-differences-the-difference-in-default-checkout-behaviors).

## How to monitor Git operations

Understanding where time is spent during Git checkout helps you identify bottlenecks and measure the impact of optimizations. The following approaches can help you gain visibility into Git performance across your builds.

### OpenTelemetry tracing

The Buildkite agent emits [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry) trace spans for checkout behavior when [tracing is enabled](/docs/agent/self-hosted/monitoring-and-observability/tracing#using-opentelemetry-tracing). Two spans are relevant to Git operations:

- **`checkout`:** Covers the entire checkout phase, including `pre-checkout` and `post-checkout` [hooks](/docs/agent/hooks).
- **`repo-checkout`:** A child span of `checkout` that isolates the Git checkout itself, excluding hook execution time.

By comparing these two spans, you can determine whether slowdowns originate from Git operations or from custom [hook](/docs/agent/hooks) logic. If you are also using the [OpenTelemetry Tracing Notification Service](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-notification-service), you can propagate traces from the Buildkite control plane through to the agent spans for an end-to-end view of build performance.

### Checkout hooks

You can use a [checkout hook](/docs/agent/hooks) on your agents to add custom timing or instrumentation around the Git checkout phase. For example, a `pre-checkout` hook could record a start timestamp and a `post-checkout` hook could calculate the elapsed time and send it to your monitoring system. This approach works with any observability platform and does not require OpenTelemetry.

### Git caching proxies

A local or network-level Git caching proxy sits between your agents and the upstream Git server, caching repository data and serving repeated clones or fetches from a local cache. Because all Git traffic flows through the proxy, it provides a natural instrumentation point for collecting metrics such as cache hit rates, clone durations, and bandwidth usage.

Two open-source options that support Git caching with built-in observability are:

- [Cachew](https://github.com/block/cachew): A protocol-aware caching proxy that maintains compressed snapshots of repositories for faster restores. It supports OpenTelemetry metrics and Prometheus integration.
- [content-cache](https://github.com/wolfeidau/content-cache): A content-addressable caching proxy that supports Git smart HTTP protocol with pack-level caching. It exports OpenTelemetry metrics and provides Prometheus endpoints for monitoring cache effectiveness.
