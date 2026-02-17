---
toc: false
---

# Command-line reference overview

The agent has a command line interface (CLI) that lets you interact with and control the agent through the command line. The comprehensive command set lets you interact with Buildkite Pipelines, manage agent configuration, control job execution, and manipulate artifacts. These commands are essential for managing your build infrastructure, automating tasks, and troubleshooting issues.

The agent CLI has the following commands and built-in help. Select a linked command to see more detailed help about it.

<div class="highlight">
  <pre class="highlight shell"><code>$ buildkite-agent --help
Usage:

  buildkite-agent &lt;command&gt; [options...]

Available commands are:

  <a href="/docs/agent/v3/cli/reference/start">start</a>             Starts a Buildkite agent
  acknowledgements  Prints the licenses and notices of open source software incorporated into this software.
  <a href="/docs/agent/v3/cli/reference/tool">tool</a>              Utilities for working with the Buildkite Agent
  help, h           Shows a list of commands or help for one command

Commands that can be run within a Buildkite job:

  <a href="/docs/agent/v3/cli/reference/annotate">annotate</a>    Annotate the build page in the Buildkite UI with information from within a Buildkite job
  <a href="/docs/agent/v3/cli/reference/annotation">annotation</a>  Make changes to annotations on the currently running build
  <a href="/docs/agent/v3/cli/reference/artifact">artifact</a>    Upload/download artifacts from Buildkite jobs
  <a href="/docs/agent/v3/cli/reference/build">build</a>       Interact with a Buildkite build
  <a href="/docs/agent/v3/cli/reference/env">env</a>         Interact with the environment of the currently running build
  <a href="/docs/agent/v3/cli/reference/job">job</a>         Interact with a Buildkite job
  <a href="/docs/agent/v3/cli/reference/lock">lock</a>        Lock or unlock resources for the currently running build
  <a href="/docs/agent/v3/cli/reference/redactor">redactor</a>    Redact sensitive information from logs
  <a href="/docs/agent/v3/cli/reference/meta-data">meta-data</a>   Get/set metadata from Buildkite jobs
  <a href="/docs/agent/v3/cli/reference/oidc">oidc</a>        Interact with Buildkite OpenID Connect (OIDC)
  <a href="/docs/agent/v3/cli/reference/pause">pause</a>       Pause the agent
  <a href="/docs/agent/v3/cli/reference/pipeline">pipeline</a>    Make changes to the pipeline of the currently running build
  <a href="/docs/agent/v3/cli/reference/resume">resume</a>      Resume the agent
  <a href="/docs/agent/v3/cli/reference/secret">secret</a>      Interact with Pipelines Secrets
  <a href="/docs/agent/v3/cli/reference/step">step</a>        Get or update an attribute of a build step, or cancel unfinished jobs for a step
  <a href="/docs/agent/v3/cli/reference/stop">stop</a>        Stop the agent

Internal commands, not intended to be run by users:

  <a href="/docs/agent/v3/cli/reference/bootstrap">bootstrap</a>               Harness used internally by the agent to run jobs as subprocesses
  kubernetes-bootstrap    Harness used internally by the agent to run jobs on Kubernetes
  git-credentials-helper  Internal process used by hosted compute jobs to authenticate with Github

Use "buildkite-agent &lt;command&gt; --help" for more information about a command.
</code></pre>
</div>
