# Git checkout optimization

This page covers best practices for optimizing Git workflows in Buildkite Pipelines through the use of sparse checkout and Git mirrors.

## Sparse checkout

Sparse checkout is a [Git feature](https://git-scm.com/docs/git-sparse-checkout) that allows you to check out only a subset of paths from a repository into your working directory, while the local repository still retains the full commit history. When using sparse checkout, after you have specified the required paths, Git will populate only those files locally, which speeds up operations and reduces disk usage on very large, monorepo-style projects, without changing the repository itself or requiring server-side setup.

To natively implement sparse checkout in Buildkite Pipelines, you can use the [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/). It allows you to speed up pipeline upload by checking out only `.buildkite` or other specific paths and supports cone and non-cone patterns, optional aggressive cleanup, skipping `ssh-keyscan`, and verbose mode for debugging.

## Git mirrors

[Git mirrors](/docs/agent/v3/git-mirrors) are one of the most effective ways to speed up Git checkouts in Buildkite Pipelines. Instead of fetching the entire repository from your remote Git server every time, agents maintain a single local bare mirror of each repository on the host machine.

When a build runs, the Buildkite Agent performs a fast local clone from the mirror by using `git clone --reference`, significantly reducing checkout times, especially for large repositories or those with extensive histories. Submodules also benefit from this optimization by referencing the mirror during their checkout process.

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
> In addition to sparse checkout and Git mirrors, for checkout optimization you can also use the [Git Shallow Clone Buildkite Plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/) that sets `--depth` flag for git-clone and git-fetch commands.

## Difference in default checkout behavior compared to other CI/CD platforms

The checkout process in Buildkite Pipelines might appear slower than on other CI/CD platforms - resulting in job and build times also appearing to be slower in a one-to-one migration comparison. This difference stems from how different platforms configure Git operations.

The following section is explaining the difference by comparing Buildkite Pipelines' and GitHub Actions' default checkout processes, but the difference and the optimization strategies for Buildkite Pipelines will be valid regardless of the CI/CD platform you might be coming from, as long as your are dealing with Git LFS.

If you look at GitHub Actions' default checkout behavior, it:

- Uses a shallow clone with `--depth=1` so it only fetches what is necessary for the current commit or PR.
- Automatically fetches PR references and tags — so it doesn't require an extra git fetch process.
- Skips Git LFS downloads unless `lfs: true` is set:

```yaml
- uses: actions/checkout@v4
	with:
		lfs: false # default
		fetch-depth: 1 # default
```

- Uses internal mirrors on GitHub’s own infrastructure.

As a result, in GitHub Actions, the checkout process running on all defaults will be faster because it is shallow and LFS-free, unless explicitly requested.

Compared to GitHub Actions' default checkout behavior, in Buildkite Pipelines:

- Git LFS is enabled by default. You can override this by setting an environment variable (`GIT_LFS_SKIP_SMUDGE=1`).

```yaml
env:
  GIT_LFS_SKIP_SMUDGE: "1"
```

- Buildkite Agent checks out the full working repository. Shallow clone can be configured using an environment variable (`git lfs env: false`) or the [Git Shallow Clone plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/).
- Other Buildkite plugins you can use to override or customize the default checkout behavior are:

    * [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/) that performs a sparse checkout so only selected paths are fetched and checked out, reducing time and bandwidth on large repositories.
    * [Custom Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/custom-checkout-buildkite-plugin/) that overrides the default agent checkout by setting a custom `refspec` and then doing a `git lfs pull`.

- An agent checkout hook can be used to replicate some of the default checkout options used by GitHub Actions which include `--depth=1`, `--single-branch`, and `--no-recurse-submodules`.
- Git mirrors can be used but it's not a default option and doesn't offer a considerable improvement in terms of checkout speed.
