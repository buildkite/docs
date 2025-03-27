# Dynamic pipelines

When your source code projects are built with Buildkite Pipelines, you can write scripts in the same language as your source code, or any other suitable one, which generate new Buildkite pipeline steps (in either YAML or JSON format) that you can then upload to the same pipeline using the [pipeline upload step](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file). These additional _dynamically generated_ pipeline steps are run on the same Buildkite Agent, as part of the same pipeline build, and will appear as their own steps in your pipeline builds. This provides you with the flexibility to structure your pipelines however you require.

For example, the following code snippet is an executable shell script that generates a list of parallel test steps based upon the `test/*` directory within your repository:

```
#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -eu

# begin the pipeline.yml file
echo "steps:"

# add a new command step to run the tests in each test directory
for test_dir in test/*/; do
  echo "  - command: \"run_tests "${test_dir}"\""
done
```
{: codeblock-file="pipeline.sh"}

To use this script, save it to the `.buildkite/` directory inside your repository (that is, `.buildkite/pipeline.sh`), ensure the script file is executable, and then update your pipeline upload step to use the new script:

```bash
.buildkite/pipeline.sh | buildkite-agent pipeline upload
```

When the pipeline's build commences, this step executes the script and pipes the output to the `buildkite-agent pipeline upload` command. The upload command then inserts the steps from the script into the build immediately after this upload step.

> 📘 Step ordering
> Since the pipeline upload command inserts the additional dynamically-generated steps from the script immediately after the upload step, these additional steps appear in reverse order (when multiple steps from the command are uploaded). To avoid your dynamically-generated steps appearing in reverse order, upload the steps in reverse order—that is, the step you want to run first goes last. That way, the steps will be in the expected order when inserted.

In the following `pipeline.yml` example, when the build runs, it will execute the `.buildkite/pipeline.sh` script, then the test steps from the script will be added to the build _before_ the wait step and command step. After the test steps have run, the wait and command step will run.

```yml
steps:
  - command: .buildkite/pipeline.sh | buildkite-agent pipeline upload
    label: "\:pipeline\: Upload"
  - wait
  - command: "other-script.sh"
    label: "Run other operations"
```
{: codeblock-file="pipeline.yml"}

## Dynamic pipeline templates

If you need the ability to use pipelines from a central catalog, or enforce certain configuration rules, you can either use dynamic pipelines and the [`pipeline upload`](/docs/agent/v3/cli-pipeline#uploading-pipelines) command to make this happen or [write custom plugins](/docs/pipelines/integrations/plugins) and share them across your organization.

To use dynamic pipelines and the pipeline upload command, you'd make a pipeline that looks something like this:

```yml
steps:
  - command: enforce-rules.sh | buildkite-agent pipeline upload
    label: "\:pipeline\: Upload"
```

Each team defines their steps in `team-steps.yml`. Your templating logic is in `enforce-rules.sh`, which can be written in any language that can pass YAML to the pipeline upload.

In `enforce-rules.sh` you can add steps to the YAML, require certain versions of dependencies or plugins, or implement any other logic you can program. Depending on your use case, you might want to get `enforce-rules.sh` from an external catalog instead of committing it to the team repository.

See how [Hasura.io](https://hasura.io) used [dynamic templates and pipelines](https://hasura.io/blog/what-we-learnt-by-migrating-from-circleci-to-buildkite/#dynamic-pipelines) to replace their YAML configuration with Go and some shell scripts.

## The Buildkite SDK

The [Buildkite SDK](https://github.com/buildkite/buildkite-sdk) is a multi-language software development kit (SDK) that generates pipeline templates in native languages. These pipeline template files are designed to generate steps (in YAML or JSON format) when they are executed as part of your pipeline build. You can customize these files with your own logic, thereby generating custom steps that can be uploaded to Buildkite to execute as part of your pipeline builds.

Currently, the Buildkite SDK supports the following languages:

- Node.js

  * JavaScript
  * TypeScript

- Python
- Go
- Ruby

