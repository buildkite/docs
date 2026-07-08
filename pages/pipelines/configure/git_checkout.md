# Git checkout

Before any build step runs, by default the Buildkite agent checks out your source code from the repository. This happens automatically without the need for extra configuration, but you can use a `checkout` block in your pipeline YAML to customize the behavior. You can skip the checkout entirely, perform shallow clones, restrict which paths are checked out, and more.

This page explains each checkout option and when to use it. For the full attribute reference, see the [command step checkout attributes](/docs/pipelines/configure/step-types/command-step#checkout-attributes).

## How checkout works

When a Buildkite Pipelines job starts, the agent performs the following steps in order:

1. **Clone or fetch the repository.** If a local copy exists, the agent fetches the latest changes. Otherwise, it clones the repository from scratch.
1. **Clean the working directory.** The agent runs `git clean` to remove untracked files left by previous builds.
1. **Check out the target commit.** The agent checks out the specific commit that triggered the build.
1. **Initialize submodules.** If submodules are enabled, the agent fetches them recursively.
1. **Run checkout hooks.** Any `pre-checkout` and `post-checkout` [hooks](/docs/agent/hooks) execute around this process.

Each `checkout` option described on this page affects one or more of these steps. For example, `checkout.skip` bypasses all of them, while `checkout.depth` modifies the clone and fetch behavior in step 1.

## Pipeline-level and step-level configuration

In Buildkite Pipelines, the `checkout` block can appear in two places:

- **Pipeline level:** Sets defaults that apply to every step in the pipeline.
- **Step level:** Overrides the pipeline-level defaults for a specific step.

When both are present, each key is resolved independently. The step value takes precedence for any key it sets, and the pipeline value is inherited for keys the step leaves unset.

For `flags`, `commit_verification`, and `sparse`, an explicit entry in the step's `env` map takes precedence if it sets the same [environment variable](/docs/pipelines/configure/environment-variables). For `skip`, `submodules`, and `depth`, the `checkout` value always takes effect.

> 📘
> The `ssh_secret` key is step-level only. It is not inherited from a pipeline-level `checkout` block, so it must be set on each step that needs it.

The following example sets pipeline-level defaults for shallow clones and disabled submodules, then overrides the depth for a single step:

```yaml
checkout:
  depth: 10
  submodules: false

steps:
  - label: "Unit tests"
    command: "make test"

  - label: "Full history analysis"
    command: "make audit"
    checkout:
      depth: 0
      submodules: true
```
{: codeblock-file="pipeline.yml"}

In this pipeline, the "Unit tests" step inherits `depth: 10` and `submodules: false` from the pipeline level. The "Full history analysis" step overrides both values.

## Skipping checkout

The `checkout.skip` key tells the agent to skip the Git checkout phase entirely. When set to `true`, the agent does not clone, fetch, or check out any code before running the step's command.

This is useful for steps that do not need source code:

- **Notification steps** that send messages or update external systems
- **Utility steps** that run self-contained scripts or container images

The key accepts a boolean (`true` or `false`) or the equivalent string. It is emitted as [`BUILDKITE_SKIP_CHECKOUT`](/docs/pipelines/configure/environment-variables#BUILDKITE_SKIP_CHECKOUT).

```yaml
steps:
  - label: "Upload pipeline"
    command: "buildkite-agent pipeline upload"
    checkout:
      skip: true
```
{: codeblock-file="pipeline.yml"}

## Shallow clones

The `checkout.depth` key performs a shallow clone with the specified number of commits. This appends `--depth=N` to both [`BUILDKITE_GIT_CLONE_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_CLONE_FLAGS) and [`BUILDKITE_GIT_FETCH_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_FETCH_FLAGS), so the agent fetches only the most recent history.

Shallow clones are useful for large repositories where full history is not needed. They reduce checkout time and disk usage by downloading fewer objects from the remote.

> 🚧 Limitations of shallow clones
> Some Git operations require full history. Commands like `git log` across the entire history, `git blame`, and `git merge-base` may return incomplete or incorrect results with a shallow clone. If a step needs full history, either omit `checkout.depth` for that step or set it to `0`.

```yaml
steps:
  - label: "Build"
    command: "make build"
    checkout:
      depth: 50
```
{: codeblock-file="pipeline.yml"}

## Sparse checkout

The `checkout.sparse` key checks out only specified paths using the Git [sparse checkout](https://git-scm.com/docs/git-sparse-checkout) feature in cone mode. The agent populates only the listed paths in the working directory, while the local repository still retains the full commit history.

Sparse checkout is particularly valuable in monorepo workflows where individual steps only need specific directories. Instead of checking out the entire repository tree, each step can declare exactly which paths it needs, reducing disk usage and speeding up operations like IDE indexing and file watchers.

The `sparse` key is a map containing a single key, `paths`, which accepts a string or an array of strings. The value is emitted as [`BUILDKITE_GIT_SPARSE_CHECKOUT_PATHS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_SPARSE_CHECKOUT_PATHS).

> 📘 Requirements and constraints
> Sparse checkout requires Git 2.26 or later. On agents with an older Git version, the agent falls back to a full checkout. Submodules are not initialized when sparse checkout is enabled.

The following example sets sparse checkout at the pipeline level so every step gets the `.buildkite/` directory, then adds step-specific paths:

```yaml
checkout:
  sparse:
    paths:
      - .buildkite/

steps:
  - label: "Build frontend"
    command: "make build"
    checkout:
      sparse:
        paths:
          - .buildkite/
          - frontend/

  - label: "Build backend"
    command: "make build"
    checkout:
      sparse:
        paths:
          - .buildkite/
          - backend/
```
{: codeblock-file="pipeline.yml"}

For a comparison of sparse checkout with Git mirrors and other optimization strategies, see [Git checkout optimization](/docs/pipelines/best-practices/git-checkout-optimization).

## Submodules

The `checkout.submodules` key controls whether the Buildkite agent fetches Git submodules during checkout. It accepts a boolean (`true` or `false`) or the equivalent string, and is emitted as [`BUILDKITE_GIT_SUBMODULES`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_SUBMODULES).

When omitted at both the pipeline and step level, the agent defaults to `true`, meaning submodules are fetched automatically.

> 🚧 Agent-level override
> The agent's `--no-git-submodules` flag retains a hard veto over `checkout.submodules`. If an agent starts with that flag, it forces `BUILDKITE_GIT_SUBMODULES=false` regardless of the value set in the pipeline YAML, and the build log emits a protected-environment-variable notice.

Disabling submodules can speed up checkout when your repository has large or numerous submodules that are not needed for every step. Note that submodules are also automatically disabled when [sparse checkout](#sparse-checkout) is enabled.

```yaml
checkout:
  submodules: false

steps:
  - label: "Fast build"
    command: "make build"

  - label: "Integration tests"
    command: "make integration"
    checkout:
      submodules: true
```
{: codeblock-file="pipeline.yml"}

## Custom Git flags

The `checkout.flags` key lets you set custom flags for specific Git operations during checkout. It is a map with four valid keys: `clone`, `fetch`, `checkout`, and `clean`. Each key sets the corresponding `BUILDKITE_GIT_*_FLAGS` [environment variable](/docs/pipelines/configure/environment-variables):

- `clone`: Sets [`BUILDKITE_GIT_CLONE_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_CLONE_FLAGS)
- `fetch`: Sets [`BUILDKITE_GIT_FETCH_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_FETCH_FLAGS)
- `checkout`: Sets [`BUILDKITE_GIT_CHECKOUT_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_CHECKOUT_FLAGS)
- `clean`: Sets [`BUILDKITE_GIT_CLEAN_FLAGS`](/docs/pipelines/configure/environment-variables#BUILDKITE_GIT_CLEAN_FLAGS)

When pipeline-level and step-level `flags` are both present, step values win per key. Pipeline values are inherited for any key the step omits.

Common use cases include partial clones with `--filter=blob:none` (which downloads commit and tree objects but defers blob downloads until needed), adding `--prune` to fetch for cleaning up stale remote-tracking references, and customizing clean behavior.

> 🚧 Security consideration
> These flags are passed directly to Git commands. In [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) where step definitions may come from untrusted input, validate the flag values to prevent command injection.

```yaml
steps:
  - label: "Blobless build"
    command: "make build"
    checkout:
      flags:
        clone: "--filter=blob:none"
        fetch: "--prune"
        clean: "-ffdx"
```
{: codeblock-file="pipeline.yml"}

## SSH key from Buildkite Secrets

The `checkout.ssh_secret` key specifies the name of a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets) that contains an SSH private key. At job startup, the agent fetches the SSH key from Buildkite Secrets using this name and configures `GIT_SSH_COMMAND` to use it during the Git checkout.

This is useful when cloning private repositories that require different SSH keys per step, such as when a build step needs access to a separate dependency repository.

Unlike the other `checkout` keys, `ssh_secret` is step-level only. It is not inherited from a pipeline-level `checkout` block, so it must be set on each step that needs it.

The value must be a string that:

- Starts with a letter
- Contains only letters, numbers, and underscores
- Does not start with `buildkite` or `bk`

```yaml
steps:
  - label: "Build with private deps"
    command: "make build"
    checkout:
      ssh_secret: "BUILDKITE_SECRET_NAME"
```
{: codeblock-file="pipeline.yml"}

## Commit verification

The `checkout.commit_verification` key tells the Buildkite agent to verify that the commit being built exists on the specified branch. This security feature is a branch-commit verification check, not GPG or SSH signature verification. It protects against a scenario where a bad actor tries to trick CI into building a malicious commit that exists on a branch as though it is actually a commit on your `main` branch.

Two modes are available:

- `strict`: Fails the job if the commit cannot be verified on the branch.
- `warn`: Emits a warning in the build log without failing the job.

When omitted, the agent falls back to its own `--git-commit-verification` [configuration setting](/docs/agent/self-hosted/configure#configuration-settings).

The agent silently skips verification in several cases where it is either not possible or not meaningful:

- Tag builds
- Pull request builds
- Builds where the commit is `HEAD`
- Builds with no branch set
- Builds using a custom refspec

```yaml
steps:
  - label: "Deploy"
    command: "make deploy"
    checkout:
      commit_verification: "strict"
```
{: codeblock-file="pipeline.yml"}

## Troubleshooting

### Verifying checkout options take effect

To confirm that a `checkout` option is being applied, inspect the `BUILDKITE_GIT_*` environment variables in the build log. Add an `echo` command to your step to print the relevant variable:

```yaml
steps:
  - label: "Debug checkout"
    command: |
      echo "Clone flags: $BUILDKITE_GIT_CLONE_FLAGS"
      echo "Sparse paths: $BUILDKITE_GIT_SPARSE_CHECKOUT_PATHS"
      echo "Submodules: $BUILDKITE_GIT_SUBMODULES"
```
{: codeblock-file="pipeline.yml"}

### Sparse checkout paths not found

If sparse checkout does not populate expected files, verify that the paths match the repository directory structure exactly. Paths are case-sensitive and must reference directories or files that exist in the repository. Also confirm that the agent is running Git 2.26 or later, as older versions fall back to a full checkout without an error.

### Submodules not initializing

If submodules are not being fetched, check:

- Whether [sparse checkout](#sparse-checkout) is enabled, as it disables submodule initialization.
- Whether the agent was started with the `--no-git-submodules` flag, which forces `BUILDKITE_GIT_SUBMODULES=false` regardless of pipeline configuration.

### SSH key issues during checkout

If the checkout fails with an SSH authentication error, verify that:

- The secret name meets the [naming constraints](#ssh-key-from-buildkite-secrets) (starts with a letter, contains only letters, numbers, and underscores, and does not start with `buildkite` or `bk`).
- The secret exists in [Buildkite Secrets](/docs/pipelines/security/secrets/buildkite-secrets) and contains a valid SSH private key.
- The `ssh_secret` key is set at the step level, not the pipeline level.

### Shallow clone limitations

If a Git command returns unexpected results, check whether the step is using a shallow clone. Operations like `git log` across the full history, `git blame`, and `git merge-base` require complete history. Remove or omit `checkout.depth` for steps that need full history access.
