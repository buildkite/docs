# Migrate from GitHub Actions

This page is for people who are familiar with or already use GitHub Actions, want to migrate to the Buildkite Pipelines, and have some questions regarding the key differences between these two CI/CD platforms.

## Understanding the difference in default checkout behaviors

The Buildkite checkout process might appear slower (job and build times appearing slower) in a one-to-one migration comparison with GitHub Actions. This difference stems from default checkout strategies and Git configurations used by each platform.

> 📘
> While the following comparison focuses on GitHub Actions, if your current CI/CD platform uses shallow clones, skips LFS by default, or has other optimized checkout defaults, you'll likely notice similar differences when migrating to Buildkite Pipelines.

If you look at GitHub Actions' default checkout behavior, it:

- Uses a shallow clone with `--depth=1` so it only fetches what is necessary for the current commit or PR.
- Automatically fetches PR references and tags — so doesn't require an extra git fetch process.
- Skips Git LFS downloads unless `lfs: true` is set:

```yaml
- uses: actions/checkout@v4
  with:
    lfs: false # default
    fetch-depth: 1 # default
```

As a result, in GitHub Actions, the checkout process running on all defaults will be faster because it is shallow and LFS-free, unless explicitly requested.

Compared to GitHub Actions' default checkout behavior, in Buildkite Pipelines:

- Git LFS is enabled by default. You can override this by setting an environment variable (`GIT_LFS_SKIP_SMUDGE=1`).

```yaml
env:
  GIT_LFS_SKIP_SMUDGE: "1"
```

- Agent checks out the full working repository. Shallow clone can be configured using an environment variable or the [Git Shallow Clone plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/).
- Other Buildkite plugins you can use to override or customize the default checkout behavior are:

    * [Sparse Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/) that performs a sparse checkout so that only selected paths are fetched and checked out, reducing time and bandwidth on large repositories.
    * [Custom Checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/custom-checkout-buildkite-plugin/) that overrides the default agent checkout by setting a custom `refspec` and then doing a `git lfs pull`.

- An agent checkout hook can be used to replicate some of the default checkout options used by GitHub Actions which include `--depth=1`, `--single-branch`, and `--no-recurse-submodules`.
- [Git mirrors](/docs/agent/v3/self-hosted/configure/git-mirrors) can also be used for checkout optimization, but it doesn't offer a considerable improvement in terms of checkout speed.

Understanding these differences helps you optimize your checkout strategy when migrating from GitHub Actions to Buildkite Pipelines, whether that means matching GitHub Actions' faster defaults or taking advantage of Buildkite's flexibility to customize the checkout behavior for your specific needs.

You can learn more about checkout strategies for Buildkite Pipelines in [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).

## Translate an example pipeline

If you would like to get a hands-on understanding of the differences and how GitHub Actions workflows map onto Buildkite Pipelines, try out the [Buildkite pipeline converter](/docs/pipelines/converter/github-actions).
