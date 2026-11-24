# Command-line reference overview

The [Buildkite CLI](/docs/platform/cli) (`bk`) allows you to interact with the Buildkite platform through the command line. The comprehensive set of `bk` commands, along with categories of sub-commands, lets you manage Buildkite agents and their configuration, work with a Buildkite pipeline's builds, control job execution, and manipulate its artifacts. These command sets can be essential for managing your build infrastructure, automating tasks, and troubleshooting issues.

## Commands

The following pages describe how to use the `bk` command, organized by its command category:

<!-- BEGIN auto-generated command list -->
- [`agent`](/docs/platform/cli/reference/agent)
- [`api`](/docs/platform/cli/reference/api)
- [`artifacts`](/docs/platform/cli/reference/artifacts)
- [`auth`](/docs/platform/cli/reference/auth)
- [`browse`](/docs/platform/cli/reference/browse)
- [`build`](/docs/platform/cli/reference/build)
- [`cache`](/docs/platform/cli/reference/cache)
- [`cluster`](/docs/platform/cli/reference/cluster)
- [`config`](/docs/platform/cli/reference/config)
- [`configure`](/docs/platform/cli/reference/configure)
- [`init`](/docs/platform/cli/reference/init)
- [`job`](/docs/platform/cli/reference/job)
- [`maintainer`](/docs/platform/cli/reference/maintainer)
- [`organization`](/docs/platform/cli/reference/organization)
- [`package`](/docs/platform/cli/reference/package)
- [`pipeline`](/docs/platform/cli/reference/pipeline)
- [`preflight`](/docs/platform/cli/reference/preflight)
- [`queue`](/docs/platform/cli/reference/queue)
- [`repository-connection`](/docs/platform/cli/reference/repository-connection)
- [`secret`](/docs/platform/cli/reference/secret)
- [`skill`](/docs/platform/cli/reference/skill)
- [`team`](/docs/platform/cli/reference/team)
- [`update`](/docs/platform/cli/reference/update)
- [`user`](/docs/platform/cli/reference/user)
- [`version`](/docs/platform/cli/reference/version)
<!-- END auto-generated command list -->

## Global flags

These flags are available across commands:

| Flag | Behavior |
| --- | --- |
| `-h`, `--help` | Show help for the selected command. |
| `--org SLUG` | Select the organization for this invocation without changing configuration files. |
| `-y`, `--yes` | Skip confirmation prompts. This does not supply missing arguments or other interactive selections. |
| `--no-input` | Disable interactive prompts. Provide required selections explicitly. |
| `-q`, `--quiet` | Suppress progress output. |
| `--no-pager` | Disable the pager for text output. |
| `--debug`, `--verbose` | Log HTTP API traffic to stderr. Bodies can contain sensitive data. |
{: class="responsive-table"}

For scripts, use `--no-input` and an explicit output format when the command supports it. Mutations that require confirmation also need `--yes`. See [configuration](/docs/platform/cli/configuration) for environment variables, output preferences, and organization selection.

> 🚧 Review debug logs before sharing
> Debug logging redacts common credential headers and selected token, password, and private-key body fields. It omits query strings, fragments, URL user information, and cluster-secret create/update request bodies. Arbitrary bodies, URL paths, and other headers can still contain sensitive data. Review logs before sharing or retaining them.
