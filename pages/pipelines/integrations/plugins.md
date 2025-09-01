# Buildkite plugins

Plugins are small self-contained pieces of extra functionality that help you customize Buildkite to your specific workflow. Plugins modify your build [command steps](/docs/pipelines/configure/step-types/command-step) at one or more of the ten [job lifecycle hooks](/docs/agent/v3/hooks). Each hook modifies a different part of the job lifecycle, for example:

- Setting up the environment.
- Checking out the code.
- Running commands.
- Handling artifacts.
- Cleaning up the environment.

The following diagram shows how a plugin might hook into the job lifecycle:

<%= image "plugins-job-lifecycle-example.png", alt: "A plugin interacts with the job lifecycle using environment, post-command, and pre-exit hooks", class: "no-decoration" %>

Plugins can be *open source* and available for anyone to use, or *private* and kept in private repositories that only your organization and agents can access. Plugins can be hosted and referenced using [a number of sources](/docs/pipelines/integrations/plugins/using#plugin-sources).

Plugins can be also be *vendored* (if they are already present in the repository, and included using a relative path) or *non-vendored* (when they are included from elsewhere), which affects the [order](/docs/agent/v3/hooks#job-lifecycle-hooks) they are run in.

## How to use plugins

Add plugins to [command steps](/docs/pipelines/configure/step-types/command-step) in your YAML pipeline to add functionality to Buildkite. Plugins can do things like execute steps in Docker containers, read values from a credential store, or add test summary annotations to builds.

<%= image "plugins-overview.png", width: 537, height: 209, alt: "Screenshot of a pipeline step with a plugin, and the plugin from the directory", class: "no-decoration" %>

Reference plugins in your pipeline configuration, and when the step containing the plugin runs, your agent will override the default behavior with hooks defined in the plugin [hooks](/docs/agent/v3/hooks). In case there is more than one, it will be with the command hook of the first plugin that defines it.

> 📘 Plugin execution and conditionals
> Plugins run during the job lifecycle, before the step-level `if` conditionals are evaluated. To conditionally run plugins, use either [group steps with conditionals](/docs/pipelines/configure/conditionals#conditionally-running-plugins-with-group-steps) or [dynamic pipeline uploads](/docs/pipelines/configure/conditionals#conditionally-running-plugins-with-dynamic-uploads).

Some plugins allow configuration. This is usually defined in your `pipeline.yml` file and is read by the agent before the plugin hooks are run. See plugins' readme files for detailed configuration and usage instructions.

See [Using plugins](/docs/pipelines/integrations/plugins/using) for more information about adding plugins to your pipeline definition.

## Finding plugins

Use the [Buildkite plugins directory](/docs/pipelines/integrations/plugins/directory) to find all the plugins maintained by Buildkite, as well as plugins from third-party developers.

## Creating a plugin

Learn more about how to create plugins, along with step-by-step instructions, on the [Writing plugins](/docs/pipelines/integrations/plugins/writing) page, along with some [useful tools](/docs/pipelines/integrations/plugins/tools) to help you develop them.
