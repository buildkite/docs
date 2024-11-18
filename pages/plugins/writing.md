# Writing plugins

This page shows you how to write your own Buildkite plugin, and how to validate the `plugin.yml` file which describes it against the plugin schema.


## Tutorial: write a plugin

In this tutorial, we'll create a Buildkite plugin called "File Counter", which counts the number of files in the build directory once the command has finished, and creates a build annotation with the count.

```yml
steps:
  - command: ls
    plugins:
      - a-github-user/file-counter#v1.0.0:
          pattern: '*.md'
```
{: codeblock-file="pipeline.yml"}

## Step 1: Create a new git repository

The most common kind of Buildkite plugin is a Git repository, with a descriptive name ending in `-buildkite-plugin`. This suffix is required to allow using the `user/plugin-name` syntax in pipelines. Let's create a new Git repository following these naming conventions:

```shell
mkdir file-counter-buildkite-plugin
cd file-counter-buildkite-plugin
git init
```

> 📘 The `-buildkite-plugin` suffix
> We recommend using the `-buildkite-plugin` suffix in the repository name because:
> <ul>
>   <li>You can reference the plugin in pipelines using the `user/plugin-name` syntax rather than the full URL.</li>
>   <li>It makes it easier for community members to find and use the plugin if you make it public.</li>
>   <li>It communicates the purpose of the code.</li>
> </ul>

## Step 2: Add a plugin.yml

Next, create `plugin.yml` to describe how the plugin appears in the [Buildkite plugins directory](/docs/plugins/directory), what it requires, and what configuration options it accepts.

```yaml
name: File Counter
description: Annotates the build with a file count
author: https://github.com/a-github-user
requirements: []
configuration:
  properties:
    pattern:
      type: string
  additionalProperties: false
```
{: codeblock-file="plugin.yml"}

The `configuration` property defines the validation rules for the plugin configuration using the [JSON Schema](https://json-schema.org) format. The plugin in this tutorial has a single `pattern` property, of type `string`.

Configuration properties are available to the hook script as environment variables with the naming pattern `BUILDKITE_PLUGIN_<PLUGIN_NAME>_<CONFIGURATION_PROPERTY>` where `<PLUGIN_NAME>` is not the name defined in `plugin.yml` but the repository or folder name compatible with Bash environment variables (in uppercase and only letters, numbers, and underscores). In this case, the configured value of `pattern` will be available as `BUILDKITE_PLUGIN_FILE_COUNTER_PATTERN`.

> 📘 Accessing properties on plugins referenced with Git URLs
> Note that if you <a href="/docs/plugins/using#plugin-sources">reference a plugin</a> with a full URL ending in <code>.git</code> and that plugin's name does not end with `-buildkite-plugin`, variable names will include `_GIT` as part of the plugin name. For example, the value of the configuration <code>pattern</code> in <code>https://github.com/my-org/my-plugin.git#v1.0.0</code> will be available as <code>BUILDKITE_PLUGIN_MY_PLUGIN_GIT_PATTERN</code>.

### Valid plugin.yml properties

<table>
  <thead>
    <tr>
      <th>Property</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>name</th>
      <td>The name of the plugin, in Title Case.</th>
    </tr>
    <tr>
      <td>description</th>
      <td>A short sentence describing what the plugin does.</th>
    </tr>
    <tr>
      <td>author</th>
      <td>A URL to the plugin author (for example, website or GitHub profile).</th>
    </tr>
    <tr>
      <td>requirements</th>
      <td>An array of commands that are expected to exist in the agent's <code>$PATH</code>.</th>
    </tr>
    <tr>
      <td>configuration</th>
      <td>A <a href="https://json-schema.org">JSON Schema</a> describing the valid configuration options available.</th>
    </tr>
  </tbody>
</table>

## Step 3: Validate the plugin

The [Buildkite Plugin Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter) is an app that helps ensure your plugin is up-to-date and has all the files required to list it in the plugins directory. The app is available as a Docker image you can run on the command line, with a dedicated plugin, or with Docker Compose. We recommend you start by running the linter on the command line, and then include the dedicated plugin in the pipeline for your plugin.

### Run on the command line

You can run the plugin linter with the following Docker command:

```shell
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-linter --id a-github-user/file-counter
```

### Run with the dedicated plugin

If your plugin has a Buildkite pipeline, you can add a step to lint it using the corresponding plugin:

```yml
  - label: ":shell: Lint"
    plugins:
      plugin-linter#v3.0.0:
        id: a-gihub-user/file-counter
```
{: codeblock-file=".buildkite/pipeline.yml"}

### Run with Docker Compose

If you want to run the linter using Docker Compose, you can add the following to a `docker-compose.yml` file:

```yml
services:
  lint:
    image: buildkite/plugin-linter
    command: ['--id', 'a-github-user/file-counter']
    volumes:
      - ".:/plugin:ro"
```
{: codeblock-file="docker-compose.yml"}

You can then run the tests using the following command:

```shell
docker-compose run --rm lint
```

## Step 4: Add a hook

Plugins can implement a number of [plugin hooks](/docs/agent/v3/hooks). For this plugin, create a `post-command` hook in a `hooks` directory:

```shell
mkdir hooks
touch hooks/post-command
chmod +x hooks/post-command
```

```shell
#!/bin/bash
set -euo pipefail

PATTERN="$BUILDKITE_PLUGIN_FILE_COUNTER_PATTERN"

echo "--- \:1234\: Counting the number of files"

COUNT=$(find . -name "$PATTERN" | wc -l)

echo "Found ${COUNT} files matching ${PATTERN}"

buildkite-agent annotate "Found ${COUNT} files matching ${PATTERN}"
```
  {: codeblock-file="hooks/post-command"}

## Step 5: Add a test

The next step is to test the `post-command` hook using BATS, and the `buildkite/plugin-tester` Docker image.

```shell
mkdir tests
touch tests/post-command.bats
chmod +x tests/post-command.bats
```

Create the following `tests/post-command.bats` file:

```shell
#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Creates an annotation with the file count" {
  export BUILDKITE_PLUGIN_FILE_COUNTER_PATTERN="*.bats"

  stub buildkite-agent 'annotate "Found 1 files matching *.bats" : echo Annotation created'

  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "Found 1 files matching *.bats"
  assert_output --partial "Annotation created"

  unstub buildkite-agent
}
```
{: codeblock-file="tests/post-command.bats"}


To run the test, run the following Docker command:

```shell
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-tester
```

```
 ✓ Creates an annotation with the file count

1 test, 0 failures
```

To make it easier to run this command, create a Docker Compose file:

```yml
version: '2'
services:
  tests:
    image: buildkite/plugin-tester
    volumes:
      - ".:/plugin:ro"
```
{: codeblock-file="docker-compose.yml"}

You can now run the tests using the following command:

```shell
docker-compose run --rm tests
```

## Step 6: Add a readme

Next, add a `README.md` file to introduce the plugin to the world:

<%= render 'plugins/tutorial_readme' %>

## Developing a plugin with a feature branch

When developing plugins, it is useful to have a quick feedback loop between making a change in your plugin code, and seeing the effects in a Buildkite pipeline. Let's say you're developing your feature on `my-org/plugin#dev-branch`. *By default*, if a Buildkite agent sees that it needs the plugin `my-org/plugin#dev-branch`, and it already has a checkout matching that, it will *not* pull any changes from the Git repository. But if you *do* want to see changes reflected immediately, set [`plugins-always-clone-fresh`](/docs/agent/v3/configuration#plugins-always-clone-fresh) to `true`.

One way to try this is to add the following step to the Buildkite pipeline where you're testing your plugin.  Configuring `BUILDKITE_PLUGINS_ALWAYS_CLONE_FRESH` on only one step means that other plugins, which are unlikely to be changing in the meantime, won't get unnecessarily cloned on every step invocation. You need agent version v3.37.0 or above to use `BUILDKITE_PLUGINS_ALWAYS_CLONE_FRESH`.

```yml
steps:
  - command: ls
    env:
      BUILDKITE_PLUGINS_ALWAYS_CLONE_FRESH: "true"
    plugins:
      - a-github-user/file-counter#dev-branch:
          pattern: '*.md'
```
{: codeblock-file="pipeline.yml"}

To use a private repository or a plugin hosted on another git host, you can use an absolute URL in the `<protocol>://<user>@<host>/<repo>` format. If you are using SSH, your build agent should have the SSH keys set up correctly for the authentication to work.

```yml
steps:
  - command: ls
    plugins:
      - ssh://git@github.com/a-github-user/file-counter:
          pattern: '*.md'
```
{: codeblock-file="pipeline.yml"}

## Publish to the Buildkite plugins directory

To add your plugin to the [Buildkite plugins directory](https://buildkite.com/plugins), publish your repository to a public GitHub repository and add the `buildkite-plugin` [repository topic tag](https://github.com/topics/buildkite-plugin). For full instructions, see the [plugins directory documentation](/docs/plugins/directory).

## Designing plugins: single-command plugins versus library plugins

When writing plugins, there are two patterns you can choose from:

* A single-command plugin: a small, declarative plugin, which exposes a single command for use in your pipeline steps. Most plugins follow this pattern.
* A library plugin, or super-plugin: this plugin type assembles multiple commands into one plugin. Refer to the [library example Buildkite plugin](https://github.com/buildkite-plugins/library-example-buildkite-plugin) for an example of how to set up this type of plugin.

## Vendored plugins

If you don't plan to share the plugin outside of one repository, you can use a _vendored plugin_. Vendored plugins sit alongside the rest of the repository code, and you include them with a relative path:

```yml
steps:
  - command: ls
    plugins:
      - ./relative/path/to/plugin:
          pattern: '*.md'
```
{: codeblock-file="pipeline.yml"}

Vendored plugins run after non-vendored plugins and don't have access to all the same hooks. See [the documentation about job lifecycle hooks](/docs/agent/v3/hooks#job-lifecycle-hooks) to learn more.
