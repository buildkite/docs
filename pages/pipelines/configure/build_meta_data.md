# Using build meta-data

In this guide, we'll walk through using the Buildkite agent's [meta-data command](/docs/agent/v3/cli-meta-data) to store and retrieve data between different steps in a build pipeline.

Meta-data is intended to store data to be used across steps. For example, you can tag a build with the software version it deploys so that you can later identify which build deployed a particular version.

Meta-data values are restricted to a maximum of 100 kilobytes. However, meta-data values larger than 1 kilobyte are discouraged. For anything over 1 kb use an [artifact](/docs/pipelines/configure/artifacts) instead.

## Setting data

The agent's `meta-data` command is the only method for setting meta-data. You can run the command from the command line or in a script.

To set meta-data in the meta-data store, use the `set` command with a key/value pair:

```bash
buildkite-agent meta-data set "release-version" "1.1"
```

This command results in the value "1.1" being associated with the key "release-version" in the meta-data store.

Once meta-data is set for a build, it cannot be deleted. It can only be updated using the `set` command.

## Getting data

You can retrieve data from the meta-data store either using the command line or in a script. The same as when setting data, both of these methods use the `buildkite-agent` cli with the `meta-data` command.

Values can only be retrieved from the store after it has been set - ensure that any steps that are getting data are guaranteed to run after the completion of the step that sets the data. One way to ensure workflows in this way is to use a [wait step](/docs/pipelines/configure/step-types/wait-step).

To retrieve meta-data, use the `get` command with the previously set key:

```bash
buildkite-agent meta-data get "release-version"
```

Assuming that the "release-version" key was set with the value from the Setting Data example, this command will return "1.1". If there are no keys matching the name "release-version", it will return an error.

> 📘 Default values
> The `get` command has a `default` flag. You can use this to return a value in the case that the key has not been set.

## Using meta-data on the dashboard

Meta-data is not widely exposed in the Buildkite dashboard, but it can be added to most builds URLs to filter down the list of builds shown to only those with certain meta-data.

To list builds in a pipeline which have a "release-version" of "1.1" you could use:

https://buildkite.com/my-organization/my-pipeline/builds?meta_data[release-version]=1.1

## Using meta-data in the REST API

You can use meta-data to identify builds when searching for builds in the REST API.

<!-- vale off -->

For more information, see the [Builds API in the Buildkite REST API documentation](/docs/apis/rest-api/builds).

<!-- vale on -->

## Further documentation

See the [Buildkite agent build meta-data documentation](/docs/agent/v3/cli-meta-data) for a full list of options and details of Buildkite's meta-data support.
