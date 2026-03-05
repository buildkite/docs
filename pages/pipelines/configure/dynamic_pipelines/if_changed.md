# Using if_changed

The `if_changed` feature is a [glob pattern](/docs/pipelines/configure/glob-pattern-syntax) that skips the step from a build if it does not match any files changed in the build. For example: `**.go,go.mod,go.sum,fixtures/**`. This feature allows you to detect changes in the repository and only build what changed.

When enabled, steps containing an `if_changed` attribute are evaluated against the Git diff. If the `if_changed` glob pattern matches no files changed in the build, the step is skipped.

`if_changed` can be used as an attribute of [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes-if-changed), [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes-if-changed), [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes-if-changed) steps, or by using the [agent CLI](/docs/agent/cli/reference/pipeline#apply-if-changed) on the [pipeline upload command](/docs/agent/cli/reference/pipeline) of the Buildkite agent to detect the [`if_changed` attribute](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes-if-changed) usage in your pipeline steps.

> 🚧
> `if_changed` is an agent-applied attribute, and such attributes are not accepted in pipelines set using the Buildkite interface. When used as an agent-applied attribute, it will only be applied by the Buildkite agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

The minimum Buildkite agent version required for using `if_changed` is version 3.99 (with `--apply-if-changed` flag). Starting with Buildkite agent version 3.103.0, this feature is enabled by default. From version 3.109.0 of the Buildkite agent, `if_changed` also supports lists of glob patterns and `include` and `exclude` attributes.

## Monorepo workflows

The `if_changed` feature is particularly useful for monorepo workflows, providing built-in change detection without requiring the monorepo-diff plugin. This can eliminate an extra pipeline generation cycle ("spawn a job to spawn more jobs") and simplify your pipeline configuration.

For example, in a monorepo with multiple services:

```yaml
steps:
  - label: "Frontend tests"
    command: "npm test"
    if_changed: "frontend/**"

  - label: "Backend tests"
    command: "go test ./..."
    if_changed:
      - "backend/**"
      - "go.{mod,sum}"

  - label: "Documentation build"
    command: "make docs"
    if_changed: "docs/**"
```

For more details on monorepo strategies, see [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos).

## How change detection works

The `if_changed` feature compares files against a base reference to determine what has changed (conceptually `git diff --merge-base <base>`).

The agent resolves the comparison base by checking the following in order, using the first valid value:

1. The [`--git-diff-base`](/docs/agent/cli/reference/pipeline#git-diff-base) agent configuration flag or `BUILDKITE_GIT_DIFF_BASE` environment variable
1. `origin/$BUILDKITE_PULL_REQUEST_BASE_BRANCH` (automatically set on pull request builds)
1. `origin/$BUILDKITE_PIPELINE_DEFAULT_BRANCH` (the pipeline's configured default branch)
1. `origin/main`

For example, to explicitly set the comparison base, configure `BUILDKITE_GIT_DIFF_BASE` in the environment of the job that runs `buildkite-agent pipeline upload`. Since `if_changed` is evaluated during the upload, not when steps run, this variable must be available in the upload job's environment rather than in individual step definitions.

You can set this in the pipeline's initial command step (the one that performs the upload):

```yaml
env:
  BUILDKITE_GIT_DIFF_BASE: "origin/develop"

steps:
  - label: "Upload dynamic pipeline"
    command: "buildkite-agent pipeline upload .buildkite/pipeline.yml"
```

Where `.buildkite/pipeline.yml` contains steps with `if_changed`:

```yaml
steps:
  - label: "Run if backend changed"
    command: "make test-backend"
    if_changed: "backend/**"
```

Alternatively, set it through [agent configuration](/docs/agent/cli/reference/pipeline#git-diff-base) using the `--git-diff-base` flag, or as an environment variable on the agent itself.

## What happens when steps are skipped

When the `if_changed` pattern doesn't match any changed files, the step is [skipped](/docs/pipelines/configure/dependencies#how-skipped-steps-affect-dependencies). In the Buildkite Pipelines interface:

- This step appears in your build with a "skipped" status
- The step's dependencies and dependents are handled appropriately
- The overall build continues to the next steps

This is similar to using a `skip` [attribute](/docs/pipelines/configure/step-types/command-step#command-step-attributes), but the decision is made dynamically based on file changes rather than being predetermined.

## Glob pattern reference

The `if_changed` feature uses the [zzglob](https://github.com/DrJosh9000/zzglob) pattern syntax, which is similar to standard glob patterns but with some differences. For complete pattern syntax details, see [Glob pattern syntax](/docs/pipelines/configure/glob-pattern-syntax).

The key pattern features are:

- `**` matches any number of directories
- `*` matches any characters within a single path segment
- `?` matches a single character
- `{option1,option2}` matches either option (brace expansion)
- Character classes like `[abc]` or `[0-9]`

## Usage examples

This section covers some examples that demonstrate various forms of the `if_changed` attribute.

> 🚧 Common mistake with dynamic pipelines
> When using dynamic pipelines, the `if_changed` attribute must be placed in the YAML file that is uploaded during the `buildkite-agent pipeline upload` command, _not_ in the step that performs the upload. This is necessary because the agent must have access to your repository when it processes the `if_changed` attribute during the `buildkite-agent pipeline upload` command.

### Single glob pattern

The simplest form of `if_changed` uses a single glob pattern to match files. This step only runs if any `.go` file anywhere in the repository changes:

```yaml
steps:
  - label: "Only run if a .go file anywhere in the repo is changed"
    if_changed: "**.go"
```

> 📘
> YAML requires some strings containing special characters to be quoted.

### Brace expansion for multiple patterns

Braces `{,}` let you combine patterns and subpatterns within a single string. This step only runs if `go.mod` or `go.sum` changes:

```yaml
steps:
  - label: "Only run if go.mod or go.sum are changed"
    if_changed: go.{mod,sum}
```

> 🚧
> This syntax is whitespace-sensitive. A space within a pattern is treated as part of the file path to be matched. For example, `go.{mod, sum}` would not work as expected.

You can combine recursive patterns with brace expansion. This step runs if any Go-related file changes:

```yaml
steps:
  - label: "Run if any Go-related file is changed"
    if_changed: "{**.go,go.{mod,sum}}"
```

This step runs for any changes within the `app/` or `spec/` directories:

```yaml
steps:
  - label: "Run for any changes within app/ or spec/"
    if_changed: "{app/**,spec/**}"
```

### Pattern lists

Starting with Buildkite agent version 3.109, lists of patterns are supported. If any changed file matches any of the patterns, the step runs. This provides a more readable alternative to brace expansion.

This step runs if any Go-related file changes:

```yaml
steps:
  - label: "Run if any Go-related file is changed"
    if_changed:
      - "**.go"
      - go.{mod,sum}
```

This step runs for any changes in the `app/` or `spec/` directories:

```yaml
steps:
  - label: "Run for any changes in app/ or spec/"
    if_changed:
      - app/**
      - spec/**
```

### Include and exclude attributes

Starting with Buildkite agent version 3.109, `include` and `exclude` attributes are supported. The `exclude` attribute eliminates matching files from causing a step to run. When using `exclude`, the `include` attribute is required.

This step runs for changes in `spec/`, but not for changes in `spec/integration/`:

```yaml
steps:
  - label: "Run for changes in spec/, but not in spec/integration/"
    if_changed:
      include: spec/**
      exclude: spec/integration/**
```

Both `include` and `exclude` can use pattern lists. This step runs for changes in `api/` or `internal/`, but excludes `api/docs/` and any `.py` files in `internal/`:

```yaml
steps:
  - label: "Run for api and internal, but not api/docs or internal .py files"
    if_changed:
      include:
        - api/**
        - internal/**
      exclude:
        - api/docs/**
        - internal/**.py
```

### Conditional pipeline triggers

You can use `if_changed` on trigger steps to conditionally trigger downstream pipelines:

```yaml
steps:
  - label: "Trigger deployment pipeline"
    trigger: "deploy-production"
    if_changed:
      - "src/**"
      - "Dockerfile"
      - "deployment/**"
    build:
      message: "Deploy changes from ${BUILDKITE_BRANCH}"
      commit: "${BUILDKITE_COMMIT}"
      branch: "${BUILDKITE_BRANCH}"
```

## Advanced use cases for if_changed

Starting with Buildkite agent version 3.115.0, you can provide a custom list of changed files instead of relying on Git diff. This is useful when:

- Working with shallow clones where Git history is limited
- Using external monorepo tools (such as [Bazel](/docs/pipelines/tutorials/bazel)) that have their own change detection
- Integrating with CI systems that already compute changed files upstream
- Working with non-git repositories

Use the `--changed-files-path` flag or `BUILDKITE_CHANGED_FILES_PATH` environment variable:

```bash
# Generate changed files list (example with custom tooling)
echo "src/main.go
pkg/feature/handler.go
README.md" > changed-files.txt

# Upload pipeline with custom changed files
buildkite-agent pipeline upload --changed-files-path changed-files.txt
```

Or using the environment variable:

```yaml
steps:
  - label: "\:pipeline\: Upload dynamic steps"
    command: |
      # Your custom change detection
      nx affected:apps --plain > changed-files.txt
      buildkite-agent pipeline upload
    env:
      BUILDKITE_CHANGED_FILES_PATH: "changed-files.txt"
```

The file format is a newline-separated list of file paths relative to the repository root.

## Troubleshooting

In this section, you can find some of the issues that you might run into when using the `if_changed` attribute and how to solve them.

### Step still runs when it shouldn't

1. **Check the agent version**: Ensure you're running agent version 3.103.0+ (or using `--apply-if-changed` flag with version 3.99+. See [Notes on agent version requirements](/docs/pipelines/configure/dynamic-pipelines/if-changed#notes-on-agent-version-requirements) at the start of this page).
1. **Verify pattern placement**: Make sure `if_changed` is in the correct YAML file (see the dynamic pipelines note above).
1. **Test the glob pattern**: The pattern is matched against file paths relative to the repository root.
1. **Check the comparison base**: The agent resolves the comparison base using a [specific order](/docs/pipelines/configure/dynamic-pipelines/if-changed#how-change-detection-works). Set `BUILDKITE_GIT_DIFF_BASE` if you need a different base.

### Pattern doesn't match expected files

1. **Use the correct syntax**: The pattern uses non-bash glob or regex syntax.
1. **Mind the whitespace**: In brace expansions like `{mod,sum}`, spaces are treated as part of the pattern.
1. **Quote special characters**: In YAML, patterns starting with `*` or other special characters must be quoted.
1. **Test locally**: You can test patterns using `git diff --name-only origin/main` to see which files changed.

### All steps run despite if_changed being set

If the agent can't determine the changed files (for example, the comparison base branch doesn't exist in your repository, or you're working with a shallow clone that doesn't have the base branch), the agent disables `if_changed` and runs all steps normally, stripping the `if_changed` attributes. Check the agent logs for errors related to the git diff operation.

Consider using `--changed-files-path` for shallow clone scenarios.

### Agent shows "skipped" for all steps

This can happen if no files actually changed between the current commit and the comparison base. Verify which base the agent is using by checking the [resolution order](/docs/pipelines/configure/dynamic-pipelines/if-changed#how-change-detection-works), and run `git diff --name-only --merge-base <base>` locally to confirm the diff is empty. If the base isn't what you expect, set `BUILDKITE_GIT_DIFF_BASE` explicitly.
