# Buildkite plugins

Add plugins to [command steps](/docs/pipelines/command-step) in your YAML pipeline to add functionality to Buildkite. Plugins can do things like execute steps in Docker containers, read values from a credential store, or add test summary annotations to builds.

<%= image "plugins-overview.png", width: 537, height: 209, alt: "Screenshot of a pipeline step with a plugin, and the plugin from the directory", class: "no-decoration" %>


## What is a plugin?

Plugins are small self-contained pieces of extra functionality that help you customize Buildkite to your specific workflow. Plugins modify your build [command steps](/docs/pipelines/command-step) at one or more of the ten [job lifecycle hooks](/docs/agent/v3/hooks). Each hook changes a different part of how your jobs set up the environment, check out code, run commands, handle artifacts or clean up the environment.

Reference plugins in your pipeline configuration, and when the step containing the plugin runs, your agent will override the default behavior with hooks defined in the plugin [hooks](/docs/agent/v3/hooks). In case there is more than one, it will be with the command hook of the first plugin that defines it.

Plugins can be *open source* and available for anyone to use, or *private* and kept in private repositories that only your organization and agents can access. Plugins can be hosted and referenced using [a number of sources](/docs/plugins/using#plugin-sources).

Plugins can be also be *vendored* (if they are already present in the repository,
and included using a relative path) or *non-vendored* (when they are included
from elsewhere), which affects the [order](/docs/agent/v3/hooks#job-lifecycle-hooks) they are run in.

Some plugins allow configuration. This is usually defined in your `pipeline.yml` file and is read by the agent before the plugin hooks are run. See plugins' readme files for detailed configuration and usage instructions.

## Finding plugins

In the [Buildkite plugins directory](/docs/plugins/directory) you can find all the plugins maintained by Buildkite, as well as plugins from third-party developers.

## Creating a plugin

See the [Writing plugins](/docs/plugins/writing) documentation for step-by-step instructions on how to create a plugin.
