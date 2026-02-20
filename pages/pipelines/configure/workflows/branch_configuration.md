# Branch configuration

You can use branch patterns to ensure pipelines are only built when necessary. This guide shows you how to set up branch patterns for whole pipelines and individual build steps.

In step-level and pipeline-level branch filtering, you can use `*` as a wildcard, and `!` for not, as shown in the [examples](#branch-pattern-examples). If you want a full range of regular expressions that operate on more than branch names, take a look at the [conditionals](/docs/pipelines/configure/conditionals) page.

## Pipeline-level branch filtering

By default, a pipeline triggers builds for all branches (`*` or blank). In your pipeline settings, you can set specific branch patterns for the entire pipeline. If a commit doesn't match the branch pattern, no build is created.

<%= image "pipeline-level.png", width: 2122/2, height: 1016/2, alt: "Pipeline-level branch filtering" %>

## Additional branch filtering for pull request builds

Builds created for pull requests ignore any pipeline-level branch filters. If you want to limit the branches that can build pull requests, add an additional branch filter in your pipeline's source control settings.

Find this filter under 'Build pull requests' if you have chosen the 'Trigger builds after pushing code' option.

<%= image "pullrequest-level.png", width: 2524/2, height: 574/2, alt: "Pull request-level branch filtering" %>

## Step-level branch filtering

As with pipeline-level branch filtering, you can set branch patterns on individual steps. Steps that have branch filters will only be added to builds on branches matching the pattern.

For example, this `pipeline.yml` file demonstrates the use of different branch filters on its steps:

```yaml
steps:
  - label: ":hammer: Build"
    command:
      - "npm install"
      - "tests.sh"
    branches: "main feature/* !feature/beta release/*"
  - block: "Release notes"
    prompt: "Please add notes for this release"
    fields:
      - text: "Notes"
        key: "notes"
    branches: "release/*"
  - label: "Deploy Preparation"
    command: "deploy-prep.sh"
    branches: "main"
  - wait
  - trigger: "app-deploy"
    label: "\:shipit\:"
    branches: "main"
```
{: codeblock-file="pipeline.yml"}

The `branches` attribute cannot be used at the same time as the `if` attribute. See more in [Conditionals in steps](/docs/pipelines/configure/conditionals#conditionals-in-steps).

> 📘
> Step-level branch filters will only affect the step that they are added to. Subsequent steps without branch filters will still be added to the pipeline.

## Branch pattern examples

When combining positive and negative patterns, any positive pattern must match, and every negative pattern must not match.

The following are examples of patterns, and the branches that they will match:

* `main` will match `main` only
* `'!production'` will match any branch that's not `production`
* `'main features/*'` will match `main` and any branch that starts with `features/`
* `'*-test'` will match any branch ending with `-test`, such as `rails-update-test`
* `'stages/* !stages/production'` will match any branch starting with `stages/` except `stages/production`, such as `stages/demo`
* `'v*.0'` will match any branch that begins with a `v` and ends with a `.0`, such as `v1.0`
* `'v* !v1.*'` will match any branch that begins with a `v` unless it also begins with `v1.`, such as `v2.3`, but not `v1.1`

If your branch pattern contains any special characters like `!` or `*`, then enclose the entire pattern in a pair of quotation marks (either `''` or `""`) to ensure the pattern is treated as a string, and mitigate any YAML parsing issues. For more advanced step filtering, see the [Using conditionals](/docs/pipelines/configure/conditionals) guide.

## Alternative methods

[Queues](/docs/agent/queues) are another way to control what work is done. You can use queues to determine which pipelines and steps run on particular agents.
