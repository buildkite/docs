# Using plugins

Plugins can be used in pipeline [command steps](/docs/pipelines/configure/step-types/command-step) to access a library of commands or perform actions.

## Adding a plugin to your pipeline

To add a plugin to a [command step](/docs/pipelines/configure/step-types/command-step), use the `plugins` attribute.  The `plugins` attribute accepts an array, so you can add multiple plugins to the same step.

When multiple plugins are listed in the same step, they will run in the [order of the hooks](/docs/agent/hooks#job-lifecycle-hooks), and within each hook, in the order they were listed in the step.

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      - shellcheck#v1.4.0:
          files: scripts/*.sh
      - docker#v5.13.0:
          image: node
          workdir: /app
```

> 📘
> Always specify a tag or commit (for example, <code>v1.2.3</code>) to prevent the plugin changing unexpectedly, and to prevent stale checkouts of plugins on your agent machines.

Not all plugins require a `command` attribute, for example:

```yml
steps:
  - plugins:
      - docker-login#v3.0.0:
          username: xyz
      - docker-compose#v5.11.0:
          build: app
          image-repository: index.docker.io/myorg/myrepo
```

Although there's no `command` attribute in the above example, this is still
considered a command step, so all command attributes are available for use.

It is possible to define multiple hooks of the same type in both a
[plugins](/docs/agent/hooks#hook-locations-plugin-hooks) and the
[agent hooks](/docs/agent/hooks#hook-locations-agent-hooks) location.
See [job lifecycle hooks](/docs/agent/hooks#job-lifecycle-hooks)
for the overall order of hooks, and the relative order of invocation for each
location.

## Configuring plugins

Plugins are configured using attributes on steps in your pipeline YAML definition. While you can't define plugins at a pipeline level, you can use [YAML anchors](/docs/pipelines/integrations/plugins/using#using-yaml-anchors-with-plugins) to avoid repeating the plugin code over multiple steps. The simplest plugin is one that accepts no configuration, such as the [Library Example plugin](https://github.com/buildkite-plugins/library-example-buildkite-plugin):

```yml
steps:
  - label: "\:books\:"
    plugins:
      - library-example#v1.0.0: ~
```

More commonly, plugins accept various configuration options. For example, the [Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin) requires the attribute `image`, and we have also included the optional `workdir` attribute:

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      - docker#v5.13.0:
          image: node
          workdir: /app
```

More advanced plugins, such as [Docker Compose plugin](\https://github.com/buildkite-plugins/docker-compose-buildkite-plugin), are designed to be used multiple times in a pipeline, using the build's [meta-data store](/docs/pipelines/configure/build-meta-data) to share information from one step to the next. This means that you can build a Docker image in the first step of a pipeline and refer to that image in subsequent steps.

```yml
steps:
  # Prebuild the app image, upload it to a registry for later steps
  - label: "\:docker\: Build"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          image-repository: index.docker.io/org/repo

  - wait

  # Use the app image built above to run concurrent tests
  - label: "\:docker\: Test %spawn"
    command: test.sh
    parallelism: 25
    plugins:
      - docker-compose#v5.11.0:
          run: app
```

See each plugin's readme for a list of which options are available.

## Using YAML anchors with plugins

YAML allows you to define an item as an anchor with the ampersand `&` character. You can then reference the anchor with the asterisk `*` character, also known as an _alias_, which includes the content of the anchor at the point it is referenced.

The following example uses a YAML anchor (`docker`) to remove the need to repeat the same plugin configuration on each step:

```yml
common:
  - docker_plugin: &docker
      docker#v5.13.0:
        image: something-quiet

steps:
  - label: "Read in isolation"
    command: echo "I'm reading..."
    plugins:
      - *docker
  - label: "Read something else"
    command: echo "On to a new book"
    plugins:
      - *docker
```

This would result in the `steps` section being expanded to:

```yml
...

steps:
  - label: "Read in isolation"
    command: echo "I'm reading..."
    plugins:
      docker#v5.13.0:
        image: something-quiet
  - label: "Read something else"
    command: echo "On to a new book"
    plugins:
      docker#v5.13.0:
        image: something-quiet
```

### Overriding YAML anchors

You can override a [YAML anchor](#using-yaml-anchors-with-plugins) with the `<<:` syntax before its _alias_. This allows you to override parts of the anchor item's contents, while retaining others, therefore reducing the need to create multiple anchors with similar configurations.

The following example uses a YAML anchor (`docker-step`) and overrides the `command` run in one of its aliases whilst using the same plugin version and container image:

```yml
common:
  - docker-step: &docker-step
      command: "uname -a"
      plugins:
        docker#v5.13.0:
          image: alpine

steps:
  - *docker-step
  - <<: *docker-step
    command: "date"
```

This would result in the `steps` section being expanded to:

```yml
...

steps:
  - command: "uname -a"
    plugins:
      docker#v5.13.0:
        image: alpine
  - command: "date"
    plugins:
      docker#v5.13.0:
        image: alpine

```

## Plugin sources

There are three main sources of plugins:

- Buildkite-maintained plugins
- Non-Buildkite plugins hosted on GitHub
- Local, private, and non-GitHub plugins

Buildkite-maintained plugins can be found in the [Buildkite Plugins GitHub organization](https://github.com/buildkite-plugins). When using these plugins, you can refer to them using only the name of the plugin, for example:

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      # Resolves to https://github.com/buildkite-plugins/docker-buildkite-plugin
      - docker#v5.13.0:
          image: node
          workdir: /app
```

Non-Buildkite plugins hosted on GitHub require you to include the GitHub user or organization name as well as the plugin name, for example:

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      # Resolves to https://github.com/my-org/docker-buildkite-plugin
      - my-org/docker#v5.13.0:
          image: node
          workdir: /app
```

Local, private, and non-GitHub plugins can be used by specifying the fully qualified Git URL, for example:

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      - https://bitbucket.com/my-org/my-plugin.git#v1.0.0: ~
      - ssh://git@github.com/my-org/my-plugin.git#v1.0.0: ~
      - file:///a-local-path/my-plugin.git#v1.0.0: ~
```

You can also reference plugins stored in subdirectories of a repository by appending the subdirectory path to the URL. This allows you to keep multiple plugins in a single repository:

```yml
steps:
  - command: yarn install && yarn run test
    plugins:
      - https://github.com/my-org/my-plugins.git/my-plugin#v1.0.0: ~
```

For more information, see [Subdirectory plugins](/docs/pipelines/integrations/plugins/writing#subdirectory-plugins).

## Pinning plugin versions

To avoid a plugin's git tag contents being changed, you can use the commit SHA of the tag, for example using `docker-compose#287293c4` in the following example:

```yml
steps:
  - command: echo 'Hello World'
    plugins:
      - docker-compose#287293c4:
          run: app
```

## Referencing plugins from a specific branch

To test plugins you can reference the branch, for example:

```yml
steps:
  - command: echo 'Hello World'
    plugins:
      - docker-compose#feature/add-new-feature:
          run: app
```

## Disabling plugins

To selectively allow and disallow plugins see [securing your Buildkite Agent](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins).

To disable plugins entirely, set the [`no-plugins`](/docs/agent/self-hosted/configure#no-plugins)
option.
