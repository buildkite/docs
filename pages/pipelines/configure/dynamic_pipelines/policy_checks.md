---
description: "Check dynamic pipeline uploads against Rego policies with Conftest, then use signed pipelines to verify jobs before execution."
---

# Policy checks for dynamic pipeline uploads

Use [Conftest](https://www.conftest.dev/) to check [dynamically generated steps](/docs/pipelines/configure/dynamic-pipelines) before adding them to a build. This example uses a policy written in Rego, the policy language of [Open Policy Agent (OPA)](https://www.openpolicyagent.org/docs), to reject uploads that explicitly target a restricted [queue](/docs/agent/queues).

Buildkite Pipelines doesn't run OPA as part of an upload. In this setup, an upload script runs Conftest and calls the [pipeline upload command](/docs/agent/cli/reference/pipeline#uploading-pipelines) only if the check passes. You can pair the check with [signed pipelines](/docs/agent/self-hosted/security/signed-pipelines) on self-hosted agents to reject unsigned or invalidly signed jobs before execution.

## Check the generated pipeline before upload

To try the example locally, install Conftest and the [Buildkite agent](/docs/agent/self-hosted/install). No Buildkite credentials or signing keys are needed for the dry run.

### Define a policy

In a new directory, save this Rego policy. It rejects an explicit `agents.queue: restricted` anywhere in the pipeline, including within a group.

```rego
package main

deny contains message if {
    walk(input, [_, node])
    node.agents.queue == "restricted"
    message := "Pipeline upload must not target the restricted queue"
}
```
{: codeblock-file="pipeline.rego"}

### Check the pipeline in the upload script

Save the following script alongside the policy. It reads one JSON pipeline from standard input and saves it to a temporary file. If the policy is missing or Conftest exits with an error, the script stops before calling the agent. The upload uses the same file and disables interpolation so the agent doesn't substitute variables after the check.

```bash
#!/usr/bin/env bash
set -euo pipefail

policy="$(dirname "$0")/pipeline.rego"
if [[ ! -s "$policy" ]]; then
  printf 'Missing or empty policy: %s\n' "$policy" >&2
  exit 1
fi

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT
pipeline="$work_dir/pipeline.json"

cat > "$pipeline"
conftest test --policy "$policy" "$pipeline" >&2
buildkite-agent pipeline upload --no-interpolation "$pipeline"
```
{: codeblock-file="upload-checked-pipeline"}

### Preview the result locally

Save this example as your generator output:

```json
{
  "steps": [
    {
      "label": "Run checks",
      "command": "echo 'Running checks'",
      "agents": { "queue": "default" }
    }
  ]
}
```
{: codeblock-file="generated.json"}

Make the script executable and preview the allowed pipeline without uploading it. Use placeholder values for the agent token and job ID so the example also works with agent versions that require these settings in dry-run mode:

```bash
chmod +x upload-checked-pipeline
BUILDKITE_AGENT_ACCESS_TOKEN=unused BUILDKITE_JOB_ID=unused \
  BUILDKITE_PIPELINE_UPLOAD_DRY_RUN=true ./upload-checked-pipeline < generated.json
```

Conftest reports a passing check, and the agent prints the parsed pipeline. Change the queue in `generated.json` from `default` to `restricted` and rerun the command. Conftest reports `Pipeline upload must not target the restricted queue`. The script exits with a nonzero status without calling the agent.

## Sign checked uploads and verify jobs

Run the checked upload from a bootstrap step on a trusted self-hosted agent. For example, if a platform-managed generator writes JSON to standard output, configure the step to pass the output to the upload script only after the generator succeeds:

```yaml
steps:
  - label: "Check and upload generated steps"
    command: |
      pipeline=$(/opt/buildkite/policy/generate-pipeline) &&
        printf '%s\n' "$$pipeline" | /opt/buildkite/policy/upload-checked-pipeline
```

The `$$` [escapes interpolation during the bootstrap upload](/docs/agent/cli/reference/pipeline#environment-variable-substitution), so the shell expands `$pipeline` when the job runs.

Replace the example paths with the locations of your generator and upload script. Keep the script, policy, and Conftest in platform-managed locations that build jobs can't modify, such as a custom agent image. An agent-level [environment hook](/docs/agent/hooks#job-lifecycle-hooks) can make Conftest available on `PATH`. The hook prepares the job environment. The upload script runs the policy check once the generated pipeline is available.

To verify signatures on your execution agents:

1. Configure [pipeline signing](/docs/agent/self-hosted/security/signed-pipelines#enabling-signed-pipelines-on-your-agents) on the trusted upload agent. The agent signs command steps when the script calls `pipeline upload` after a successful check. Keep signing credentials away from execution agents and jobs that can run untrusted code, including untrusted generators. If a generator runs untrusted code, run it separately and pass only the generated pipeline data to the trusted upload agent.
1. Configure the execution agents with the verification key and `verification-failure-behavior=block`. If an unsigned job reaches one of these agents, or if a job's signature is invalid, the agent rejects it before running the command. The agent verifies the signature, not the Rego policy.
1. [Sign the bootstrap step](/docs/agent/self-hosted/security/signed-pipelines#self-managed-key-creation-step-3-sign-all-steps) too if the upload agent verifies incoming jobs. Keep direct access to the signing key restricted to trusted code. An upload script or a `PATH` setting alone doesn't enforce policy if other code can also sign steps.

> 🚧 Scope of the queue check
> This example checks only explicit queue values in the generated document. The policy doesn't resolve default routing, evaluate matrix substitutions, or authorize access to a queue. Queue targeting isn't covered by [pipeline signatures](/docs/agent/self-hosted/security/signed-pipelines#pipeline-signatures). Use [separate clusters](/docs/pipelines/security/clusters) to isolate privileged agents from pipelines that shouldn't use them.
