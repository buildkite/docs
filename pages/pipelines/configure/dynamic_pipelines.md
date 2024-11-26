## Dynamic pipelines

Because the pipeline upload step runs on your agent machine, you can generate pipelines dynamically using scripts from your source code. This provides you with the flexibility to structure your pipelines however you require.

The following example generates a list of parallel test steps based upon the `test/*` directory within your repository:

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

To use this script, you'd save it to `.buildkite/pipeline.sh` inside your repository, ensure it is executable, and then update your pipeline upload step to use the new script:

```bash
.buildkite/pipeline.sh | buildkite-agent pipeline upload
```

When the build runs, it executes the script and pipes the output to the `pipeline upload` command. The upload command then inserts the steps from the script into the build immediately after the upload step.

>📘 Step ordering
> Since the upload command inserts steps immediately after the upload step, they appear in reverse order when you upload multiple steps in one command. To avoid the steps appearing in reverse order, we suggest you upload the steps in reverse order (the step you want to run first goes last). That way, they'll be in the expected order when inserted.


In the below `pipeline.yml` example, when the build runs it will execute the `.buildkite/pipeline.sh` script, then the test steps from the script will be added to the build before the wait step and command step. After the test steps have run, the wait and command step will run.

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
