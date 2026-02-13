# Buildkite Agent hooks

An agent goes through different phases in its lifecycle, including starting up, shutting down, and checking out code. Hooks let you extend or override the behavior of agents at different stages of its lifecycle. You "hook into" the agent at a particular stage.

## What's a hook?

A hook is a script executed or sourced by the Buildkite agent at a specific point in the job lifecycle. You can use hooks to extend or override the built-in behavior of an agent. Hooks are generally shell scripts, which the agent then executes or sources.

The Buildkite agent v3.47.0 or later can run hooks written in any programming language that your development teams use. See the [polyglot hooks](#polyglot-hooks) section for more information.

## Hook scopes

You can define hooks in the following locations:

- In the file system of the agent machine (called _agent hooks_, or more rarely _global hooks_).
- In your pipeline's repository (called _repository hooks_, or more rarely _local hooks_).
- In [plugins](/docs/pipelines/integrations/plugins) applied to steps.

For example, you could define an agent-wide `checkout` hook that spins up a fresh `git clone` on a new build machine, a repository `pre-command` hook that sets up repository-specific environment variables, or a plugin `environment` hook that fetches API keys from a secrets storage service.

There are two categories of hooks:

- Agent lifecycle
- Job lifecycle

Agent lifecycle hooks are _executed_ by the Buildkite agent as part of the agent's lifecycle. For example, the `pre-bootstrap` hook is executed before starting a job's bootstrap process, and the `agent-shutdown` hook is executed before the agent process terminates.

Job lifecycle hooks are _sourced_ (see "A note on sourcing" for specifics) by the Buildkite bootstrap in the different job phases. They run in a per-job shell environment, and any exported environment variables are carried to the job's subsequent phases and hooks. For example, the `environment` hook can modify or export new environment variables for the job's subsequent checkout and command phases. Shell options set by individual hooks, such as set `-e -o pipefail`, are not carried over to other phases or hooks.

<details>
<summary> 📝 A note on sourcing </summary>
<p>We use the word "sourcing" on this page, but it's not strictly correct. Instead, the agent uses a process called <a href="https://github.com/buildkite/agent/blob/1a5f05029cc363a984188c441f938dd316dedd16/hook/scriptwrapper.go">"the scriptwrapper"</a> to run hooks.</p>

<p>This process notes down the environment variables before a hook run, sources that hook, and compares the environment variables after the hook run to the environment variables before the hook run.</p>

<p>Any environment variables added, changed, or removed are then exported to the subsequent phases and hooks. Functionally, this is very similar to how <code>source</code> would work, but it's not quite the same. If you're relying on some very specific pieces of shellscripting functionality, you might find that things don't work quite as you expect.</p>

<p>We do this because there's no shared bash environment between two different hooks on the same job. Functionally, each hook runs in its own shell, orchestrated through the agent's Go code. This means that if you set an environment variable in one hook, it wouldn't be available in the next hook without this scriptwrapper process.</p>
</details>

## Hook locations

You can define hooks in the following locations:

- **Agent hooks:** These exist on the agent file system in a directory created by your agent installer and configured by the [`hooks-path`](/docs/agent/v3/self-hosted/configure#hooks-path) setting. You can define both agent lifecycle and job lifecycle hooks in the agent hooks location. Job lifecycle hooks defined here will run for every job the agent receives from any pipeline.
- **Repository hooks:** These exist in your pipeline repository's `.buildkite/hooks` directory and can define job lifecycle hooks. Job lifecycle hooks defined here will run for every pipeline that uses the repository. In scenarios where the current working directory is modified as part of the command or a post-command hook, this modification will cause these hooks to fail as the `.buildkite/hooks` directory can no longer be found in its new directory path. Ensure that the working directory is not modified to avoid these issues.
- **Plugin hooks:** These are provided by [plugins](/docs/pipelines/integrations/plugins) you've included in your pipeline steps and can define job lifecycle hooks. Job lifecycle hooks defined by a plugin will only run for the step that includes them. Plugins can be *vendored* (if they are already present in the repository and included using a relative path) or *non-vendored* (when they are included from elsewhere), which affects the order they are run in.

### Agent hooks

Every agent installer creates a hooks directory containing a set of
sample hooks. You can find the location of your agent hooks directory in your platform's installation documentation.

To get started with agent hooks, copy the relevant example script and remove the `.sample` file extension.

See [agent lifecycle hooks](#agent-lifecycle-hooks) and [job lifecycle hooks](#job-lifecycle-hooks) for the hook types that you can define in the agent hooks directory.

### Repository hooks

Repository hooks allow you to execute repository-specific scripts. Repository hooks live alongside your repository's source code under the `.buildkite/hooks` directory.

To get started, create a shell script in `.buildkite/hooks` named `post-checkout`. It will be sourced and run after your repository has been checked out as part of every job for any pipeline that uses this repository.

You can define any of the [job lifecycle hooks](#job-lifecycle-hooks) whose `Order` includes *Repository*.

### Plugin hooks

Plugin hooks allow plugins you've defined in your Pipeline Steps to override the default behavior.

See the [plugin documentation](/docs/pipelines/integrations/plugins) for how to implement plugin hooks and [job lifecycle hooks](#job-lifecycle-hooks) for the list of hook types that a plugin can define.

## Polyglot hooks

Buildkite Agent versions prior to v3.85.0 require hooks to be shell scripts. However, with the Buildkite Agent version v3.85.0 or later, hooks are significantly more flexible and can be written in the programming language of your choice.

In addition to the regular shell script hooks, polyglot hooks enable you to run two more types of hooks:

- **Interpreted hooks:** Hooks that are run by an interpreter, such as Python, Ruby, or Node.js. These hooks are run in the same way as shell script hooks, but are executed by the appropriate interpreter instead of by the shell. These hooks _must_ have a valid [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) as the first line of the hook. For example, `#!/usr/bin/python3` or `#!/usr/bin/env ruby`.
- **Binary hooks:** Binary executables produced by compiled languages such as Go, Rust, or C++. These hooks are run in the same way as shell script hooks, but are executed directly by the operating system. These hooks must be compiled for the correct operating system and architecture, and be executable by the agent user.

> 🚧 Windows support
> Interpreted hooks are not supported on Windows agents.

Polyglot hooks are run transparently by the agent, and are not distinguished from shell script hooks in the logs or the Buildkite dashboard. The agent will automatically detect the type of hook–whether it's a shell script, an interpreted hook, or a binary–and run it appropriately. All you need to do is place your hook in the correct location and ensure it's executable.

### Extra environment variables

When polyglot hooks are called, the following extra environment variables are set:

- `BUILDKITE_HOOK_PHASE`: The lifecycle phase of the hook being run. For example, `environment` or `post-checkout`. See [job lifecycle hooks](#job-lifecycle-hooks) for the full list of phases. This enables the hook to determine the phase it's running in, allowing you to use the same hook for multiple phases.
- `BUILDKITE_HOOK_PATH`: The path to the hook being run. For example, `/path/to/my-hook`.
- `BUILDKITE_HOOK_SCOPE`: The scope of the hook being run. For example, `global`, `local`, or `plugin`.

> 📘 Modifying environment variable values
> Be aware that when an agent is running a job, you can modify the values of these, as well as other environment variables within the agent, using its [internal job API](/docs/apis/agent-api/internal-job).

### Caveats

Polyglot hook usage comes with the following caveats:

- Interpreted hooks are not supported on Windows.
- Hooks must not have a file extension–except on Windows, where binary hooks must have the `.exe` extension.
- For interpreted hooks, the specified interpreter must already be installed on the agent machine. The agent won't install the interpreter or any package dependencies for you.
- Unlike shell hooks, environment variable changes are not automatically captured from polyglot hooks. If you want to modify the job's environment, you'll have to use the [Job API](/docs/agent/v3/self-hosted/configure/experiments#promoted-experiments-job-api).

## Agent lifecycle hooks

| Hook             | Location Order | Description |
| ---------------- | -------------- | ----------- |
| `agent-startup` | <span class="add-icon-agent">Agent</span> | Executed at agent startup, immediately prior to the agent being registered with Buildkite. Useful for initialising resources that will be used by all jobs that an agent runs, outside of the job lifecycle.<br /><br />Supported from agent version 3.42.0 and above. |
| `agent-shutdown` | <span class="add-icon-agent">Agent</span> | Executed when the agent shuts down. Useful for performing cleanup tasks for the entire agent, outside of the job lifecycle. |
{: class="table table--no-wrap"}

### Creating agent lifecycle hooks

The Buildkite agent executes agent lifecycle hooks.
These hooks can only be defined in the [agent `hooks-path`](#hook-locations-agent-hooks) directory.
Agent lifecycle hooks can be executables written in any programming language.
On Unix-like systems (such as Linux and macOS), hooks must be files that are executable by the user the agent is running as.

Use agent lifecycle hooks to prepare for or clean up after all jobs that may run.
For example, use `pre-bootstrap` to block unwanted jobs from running or use `agent-shutdown` to tear down a service after all jobs are finished.
If your hook uses details about any individual job to run, prefer [job lifecycle hooks](#job-lifecycle-hooks) for those tasks instead.

The agent exports few environment variables to agent lifecycle hooks.
Read the [agent lifecycle hooks table](#agent-lifecycle-hooks) for details on the interface between the agent and each hook type.

## Job lifecycle hooks

The following is a complete list of available job hooks, and the order in which
they are run as part of each job:

| Hook            | Location Order | Description |
| --------------- | -------------- | ----------- |
| `pre-bootstrap`  | <span class="add-icon-agent">Agent</span> | Executed before any job is started. Useful for [adding strict checks](/docs/agent/v3/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) before jobs are permitted to run.<br /><br />The proposed job command and environment is written to a file and the path to this file provided in the `BUILDKITE_ENV_FILE` environment variable. Use the contents of this file to determine whether to permit the job to run on this agent.<br /><br />If the <code>pre-bootstrap</code> hook terminates with an exit code of `0`, the job is permitted to run. Any other exit code results in the job being rejected, and job failure being reported to the Buildkite API. |
| `environment`   | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span>                                                                                                                    | Runs before all other hooks. Useful for [exporting secret keys](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks). |
| `pre-checkout`  | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span>                                                                                                                    | Runs before checkout. |
| `checkout`      | <span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-agent">Agent</span>                                                                                                                    | Overrides the default git checkout behavior. (See [Hook exceptions](#job-lifecycle-hooks-hook-exceptions).) |
| `post-checkout` | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span>                                                           | Runs after checkout. |
| `environment`   | <span class="add-icon-plugin">Plugin (vendored)</span>                                                                                                                                                                       | Unlike other plugins, environment hooks for vendored plugins run after checkout. |
| `pre-command`   | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span> | Runs before the build command |
| `command`       | <span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-agent">Agent</span> | Overrides the default command running behavior. (See [Hook exceptions](#job-lifecycle-hooks-hook-exceptions).) |
| `post-command`  | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span> | Runs after the command. |
| `pre-artifact`  | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span> | Runs before artifacts are uploaded, if an artifact upload pattern was defined for the job. |
| `post-artifact` | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span> | Runs after artifacts have been uploaded, if an artifact upload pattern was defined for the job. |
| `pre-exit`      | <span class="add-icon-agent">Agent</span><br /><span class="add-icon-repository">Repository</span><br /><span class="add-icon-plugin">Plugin (non-vendored)</span><br /><span class="add-icon-plugin">Plugin (vendored)</span> | Runs before the job finishes. Useful for performing cleanup tasks. |
{: class="table table--no-wrap"}

Each `command` job defined in a pipeline's `pipeline.yml` file runs independently of one another. Therefore, each defined hook will run for every one of these `command` jobs.

When defining multiple command items in a step using the `commands` attribute, such as the `pipeline.yml` example in [Command step attributes](/docs/pipelines/configure/step-types/command-step#command-step-attributes), then each item in the `commands` list is concatenated together and run as a single command. Therefore, a given hook will only run once for a given `commands` job consisting of multiple command items.

### Hook failure behavior

When a pipeline's job runs, the first point of failure causes the entire job to fail and terminate.

In the table above, if any of the hooks above `command` (from `pre-bootstrap` to `pre-command`, inclusive) fails with a non-zero exit code, then the `command` phase of the pipeline job will not run.

Since all the hooks below `command` (from `post-command` to `pre-exit`, inclusive) run _after_ the `command` phase of the pipeline job, then any non-zero exit code failure in these hooks would still fail the entire job. Be aware, however, that any actions in the `command` phase of the pipeline job would have already run successfully.

### Hook exceptions

Typically, if there are multiple hooks of the same type, all of them will be run (in the order shown in the table).

As of Agent v3.15.0, if multiple `checkout` or `command` hooks are found, only the first (of each type) will be run. This does not apply to other hook types.

However, for legacy compatibility, there is an exception with *plugins*. All `checkout` or `command` hooks provided by plugins will run in the order the plugins are specified, meaning multiple `checkout` and `command` hooks can run. Note that `checkout` hooks and `command` hooks provided by plugins will prevent any repository or agent hooks of the same type from running.

### Creating job lifecycle hooks

Job lifecycle hooks are sourced for every job an agent accepts. Use job lifecycle hooks to prepare for jobs, override the default behavior, or clean up after jobs that have finished. For example, use the `environment` hook to set a job's environment variables or the `pre-exit` hook to delete temporary files and remove containers. If your hook is related to the startup or shutdown of the agent, consider [agent lifecycle hooks](#agent-lifecycle-hooks) for those tasks instead.

Job lifecycle hooks have access to all the standard [Buildkite environment variables](/docs/pipelines/configure/environment-variables).

Job lifecycle hooks are copied to `$TMPDIR` directory and *sourced* by the agent's default shell. This has a few implications:

- `$BASH_SOURCE`: contains the location the hook is sourced from.
- `$0`: contains the location of the copy of the script that is running from `$TMPDIR`.

>🚧 "Permission denied" error when trying to execute hooks
> If your hooks don't execute, and throw a <code>Permission denied</code> error, it might mean that they were copied to a temporary directory on the agent that isn't executable. Configure the directory that hooks are copied to before execution using the <code>$TMPDIR</code> environment variable on the Buildkite agent, or make sure the existing directory is marked as executable.

To write job lifecycle hooks in another programming language, you need to execute them from within the shell script, and explicitly pass any Buildkite environment variables you need to the script when you call it.

The following is an example of an `environment` hook which exports a GitHub API key for the pipeline's release build step:

```bash
set -eu
echo '--- \:house_with_garden\: Setting up the environment'

export GITHUB_RELEASE_ACCESS_KEY='xxx'
```

## Job hooks on Windows

Buildkite defaults to using the Batch shell on Windows. Buildkite agents running on Windows require that either:

- The hooks files have a `.bat` extension, and be written in [Windows Batch](https://en.wikipedia.org/wiki/Batch_file), or
- The agent `shell` option points to the PowerShell or PowerShell Core executable, and the hooks files are written in PowerShell. PowerShell hooks are supported in Buildkite agent version 3.32.3 and above.

An example of a Windows `environment.bat` hook:

```batch
@ECHO OFF
ECHO "--- \:house_with_garden\: Setting up the environment"
SET GITHUB_RELEASE_ACCESS_KEY='xxx'
```

## Hooks on Buildkite Agent Stack for Kubernetes

The hook execution flow for jobs created by the Buildkite Agent Stack for Kubernetes controller is operationally different. The reason for this is that hooks are executed from within separate containers for checkout and command phases of the job's lifecycle. This means that any environment variables exported during the execution of hooks with the `checkout` container will _not_ be available to the command container(s).

The main differences arise with the `checkout` container and user-defined `command` containers:

- The `environment` hook is executed multiple times, once within the `checkout` container, and once within each of the user-defined `command` containers.
- Checkout-related hooks (`pre-checkout`, `checkout`, `post-checkout`) are only executed within the `checkout` container.
- Command-related hooks (`pre-command`, `command`, `post-command`) are only executed within the `command` container(s).

See the dedicated [Using agent hooks and plugins](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins) page for the detailed information on how agent hooks function when using the Buildkite Agent Stack for Kubernetes controller.

## Hooks on Buildkite hosted agents

Agent hooks are supported on [Buildkite hosted agents for Linux](/docs/agent/v3/buildkite-hosted/linux/custom-base-images#create-an-agent-image-using-agent-hooks).

Currently, [Buildkite hosted agents for macOS](/docs/agent/v3/buildkite-hosted/macos) do not support [agent hooks](#hook-locations-agent-hooks). Instead, use either [repository](#hook-locations-repository-hooks)- or [plugin](#hook-locations-plugin-hooks)-based hooks with these types of agents.
