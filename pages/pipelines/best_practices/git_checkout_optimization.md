# Git checkout optimization

This page covers best practices for optimizing Git workflows in Buildkite Pipelines through the use of sparse checkout and Git mirrors.

## Sparse checkout

Sparse checkout is a [Git feature](https://git-scm.com/docs/git-sparse-checkout) that allows you to check out only a subset of paths from a repository into your working directory, while the local repository still retains the full commit history. When using sparse checkout, after you have specified the required paths, Git will populate only those files locally, which speeds up operations and reduces disk usage on very large, monorepo-style projects, without changing the repository itself or requiring server-side setup.

To natively implement sparse checkout in Buildkite Pipelines, you can use the [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/). It allows you to speed up pipeline upload by checking out only `.buildkite` or other specific paths and supports cone and non-cone patterns, optional aggressive cleanup, skipping `ssh-keyscan`, and verbose mode for debugging.

## Git mirrors

[Git mirrors](/docs/agent/v3/git-mirrors) are one of the most effective ways to speed up Git checkouts in Buildkite Pipelines. Instead of fetching the entire repository from your remote Git server every time, agents maintain a single local bare mirror of each repository on the host machine.

When a build runs, the Buildkite Agent performs a fast local clone from the mirror by using `git clone --reference` flag, significantly reducing checkout times, especially for large repositories or those with extensive histories. Submodules also benefit from this optimization by referencing the mirror during their checkout process.

## Comparing sparse checkout and Git mirrors

While both approaches help optimize your Git workflow, they solve different problems and work in fundamentally different ways. Understanding when to use each can make a real difference in your build performance.

**Sparse checkout:**

- Is client-side only, so no extra infrastructure or separate repository is required for its implementation.
- Downloads the full repository history but only checks out the selected paths in the working tree - the files and folders that you actually need in your working directory.
- Useful for [monorepo](/docs/pipelines/best-practices/working-with-monorepos) teams where different teams touch different directories - for example, when the frontend developers don't need backend code cluttering their workspace (and vice versa).

**Git mirrors:**

- A separate copy of your repository (typically created with `--mirror` or `--bare`) that mirrors another repository and acts as a local cache.
- Useful in CI/CD environments with frequent builds to avoid repeatedly hitting your Git server.
- Can mirror everything (all refs and history) or be combined with filtering if you build specialized mirrors.
- Require some upfront setup and ongoing maintenance, but result in faster checkout times.

### When to use which

- Use sparse checkout when you’re optimizing developer workstation performance - for example, developers need to work in a large repository but only on a few directories, optimizing local checkouts and IDE performance without changing server infrastructure.
- Use a Git mirror when you’re optimizing distribution, reliability, or centralization for automation and scaling - for example, when you need a replicated source of truth for CI, faster clones for many agents, network isolation, or migration between hosts.

> 📘
> In addition to sparse checkout and Git mirrors, for checkout optimization you can also use the [Git Shallow Clone Buildkite Plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/) that sets `--depth` flag for `git-clone` and `git-fetch` commands.

## Understanding checkout defaults across platforms

The default checkout behavior in Buildkite Pipelines prioritizes completeness and flexibility. As a result, if you're migrating to Buildkite Pipelines from another CI/CD platform, especially if you're using LFS, you might notice differences in checkout speed or behavior.

For a detailed comparison of how Buildkite's checkout defaults differ from other platforms in a GitHub Actions-based example (including LFS handling, shallow clones, and customization options), see [Understanding the difference in default checkout behaviors](/docs/pipelines/migration/from-githubactions#understanding-the-difference-in-default-checkout-behaviors).
