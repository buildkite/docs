# Using build meta-data

In this guide, we'll walk through using the Buildkite agent's [meta-data command](/docs/agent/v3/cli-meta-data) to store and retrieve data between different steps in a build pipeline.

Meta-data is intended to store data to be used across steps. For example, you can tag a build with the software version it deploys so that you can later identify which build deployed a particular version.

Meta-data values are each restricted to a maximum of 100 kilobytes (kb). However, meta-data values larger than 1 kb are discouraged. For any such values over 1 kb, use an [artifact](/docs/pipelines/configure/artifacts) instead.

> 🚧
> You should not store secrets or other sensitive information in build meta-data, as it is not a secure medium and its contents can be viewed through the Buildkite interface. Instead, please follow the guidance in [Managing pipeline secrets](/docs/pipelines/security/secrets/managing) for best practices on storing and using secrets in your pipelines.

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

For more information, see the [Builds API in the Buildkite REST API documentation](/docs/apis/rest-api/builds).

## Using build input parameters

When a pipeline's steps begin with a `block` or `input` step, any fields will be rendered in the **New Build** dialog.

For example, a pipeline with the slug `activities` in an organization whose slug is `demo` has the following definition:

```yaml
steps:
  - block: What would you like to see?
    fields:
      - text: Which city?
        key: city
      - select: What activities?
        key: activities
        multiple: true
        options:
          - label: Restaurants
            value: restaurants
          - label: Museums
            value: museums
          - label: Sports
            value: sports
```

The **New Build** dialog will include the `block` or `input` step fields, and will set the meta-data fields on the new build.

Meta-data fields can also be pre-populated using query string parameters.

```
https://buildkite.com/organizations/{organization-slug}/pipelines/{pipelines-slug}/builds/new?meta_data[{key}]={value}
```

You can pre-populate the input fields of such pipelines' URLs, which you can bookmark for subsequent use:

```
https://buildkite.com/organizations/demo/pipelines/activities/builds/new?meta_data[city]=Melbourne&meta_data[activities]=restaurants,sports
```

<%= image "new_build_form.png", alt: "New Build form with input fields pre-populated" %>

Using meta-data to pre-populate fields in this way carries some considerations regarding how the input step behaves. Learn more about this in the [Input step](/docs/pipelines/configure/step_types/input_step.md) page.

## Special meta-data

Meta-data keys starting with `buildkite:` are reserved for special values provided by Buildkite. These may be generated on request.

<!-- vale off -->

### buildkite:webhook

<!-- vale on -->

The special `buildkite:webhook` meta-data key can be used to get the body of the webhook which triggered the current build. For example, you can access the [GitHub](/docs/pipelines/source-control/github) push webhook payload in a command step:

```yaml
steps:
  - command: |
      WEBHOOK="$(buildkite-agent meta-data get buildkite:webhook)"
      STARGAZERS="$(jq .repository.stargazers_count <<< "$WEBHOOK")"
      echo "The current repository has $STARGAZERS stargazers 💫"
```

This value will only be available for builds triggered by a webhook, and only as long as the full webhook body remains cached — typically for 7 days.

## Further documentation

See the [Buildkite agent build meta-data documentation](/docs/agent/v3/cli-meta-data) for a full list of options and details of Buildkite's meta-data support.
