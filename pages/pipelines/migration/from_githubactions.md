# Migrate from GitHub Actions

This page is for people who are familiar with or already use GitHub Actions, want to migrate to the Buildkite platform, and have some question regarding the key differences between the platforms.

## Understand the difference in the default checkout behavior

The Buildkite checkout process might appear slower - resulting in job and build times presenting slower, too, in a one-to-one migration. There are reasons for it.

If you look at GitHub Actions' default checkout behavior, it:

- Uses a shallow clone with `--depth=1`and so only fetches what is necessary for a commit or a PR on hand.
- Automatically fetches PR references and tags — no extra git fetch needed.
- Skips Git LFS downloads unless `lfs: true`is set:
```yaml
- uses: actions/checkout@v4
	with:
		lfs: false # default
		fetch-depth: 1 # default
```
- Uses internal mirrors on GitHub’s infrastructure.

As a result, in GutHub Actions the checkout process using all defaults usually takes ~3–5s so it is fast because it is shallow and LFS-free unless explicitly requested.

Compared to GitHub Actions' default checkout behavior, in Buildkite Pipelines:

- Git LFS is enabled by default. You can override this by setting an environment variable (`GIT_LFS_SKIP_SMUDGE=1`).
```yaml
env:
  GIT_LFS_SKIP_SMUDGE: "1"
```
- Buldkite Agent checks out the full working repository (and runs the Git fetch twice by default). Shallow clone con be configured using an environment variable (`git lfs env false`) or the [Git Shallow Clone plugin](https://buildkite.com/resources/plugins/peakon/git-shallow-clone-buildkite-plugin/).
- An agent checkout hookcan be used to set some of the other default options used by GitHub Actions which include `--depth=1`, `--single-branch`, and `--no-recurse-submodules`.
- Git mirrors can be used but it's not a default option and doesn't offer a considerable improvement in terms of checkout speed.

## Translate an example pipeline

If you would like to get a hands-on understanding of the differences and how GitHub Actions workflows map onto Buildkite Pipelines, try out the [Buildkite migration tool for GitHub Actions](https://buildkite.com/docs/pipelines/migration/tool/github-actions).
