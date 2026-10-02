# Job acquisition tokens

A _job acquisition token_ (JAT) is a short-lived registration credential for a stack-managed [ephemeral agent](/docs/pipelines/glossary#ephemeral-agent). Each JAT allows the agent to register with Buildkite and acquire one reserved job. JAT values use the `bkjat_` prefix.

Use job acquisition tokens for ephemeral agents instead of exposing a long-lived [agent token](/docs/agent/self-hosted/tokens) to each job workload. The stack controller retains the agent token for accessing the [Stacks API](/docs/apis/agent-api/stacks). Each agent workload receives a JAT for its assigned job.

The [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s) uses job acquisition tokens by default. No configuration is required to enable them. Custom stack implementations can use the process described on this page.

## How job acquisition tokens work

The registration process for an ephemeral agent uses the following credentials:

- The stack controller uses an agent token to register the stack, list and reserve jobs, and request job acquisition tokens.
- The ephemeral agent uses a JAT to register and acquire its reserved job.

The complete process is:

1. The stack controller uses the Stacks API to find and [reserve a job](/docs/apis/agent-api/stacks#reserve-jobs).
1. The controller waits until execution capacity is available for the job.
1. Immediately before starting the agent workload, the controller [requests a JAT](/docs/apis/agent-api/stacks#issue-job-acquisition-tokens) for the reserved job.
1. The controller starts the ephemeral agent with the JAT as `BUILDKITE_AGENT_TOKEN` and the job UUID as `BUILDKITE_AGENT_ACQUIRE_JOB`.
1. The agent presents the JAT when registering. Buildkite validates the JAT and returns a [session token](/docs/agent/self-hosted/tokens#additional-agent-tokens-session-tokens) restricted to the associated job.
1. The agent acquires the job and receives a [job token](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens). After the job finishes, the agent disconnects.

## Start an agent with a job acquisition token

After reserving a job and obtaining execution capacity, request a JAT from the Stacks API. The request uses the stack controller's agent token:

```bash
curl -H "Authorization: Token $BUILDKITE_AGENT_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://agent.buildkite.com/v3/stacks/my-custom-stack/job-acquisition-tokens" \
  -d '{
    "job_uuids": [
      "01234567-89ab-cdef-0123-456789abcdef"
    ],
    "token_lifetime_seconds": 3600
  }'
```

The optional `token_lifetime_seconds` field accepts an integer from 1 to 3,600 seconds. This example requests the maximum lifetime of one hour. Omitting the field uses the default lifetime of 900 seconds, or 15 minutes. The token expires earlier if the job reservation expires first.

The endpoint supports batch requests and can return a partial success. Match each token to its job using `job_uuid`, and don't start a workload for any job listed in `not_issued`. See [Issue job acquisition tokens](/docs/apis/agent-api/stacks#issue-job-acquisition-tokens) for the complete request and response formats.

Pass the JAT and its corresponding job UUID to the ephemeral agent:

```bash
export BUILDKITE_AGENT_TOKEN='bkjat_<opaque-token>'
export BUILDKITE_AGENT_ACQUIRE_JOB='01234567-89ab-cdef-0123-456789abcdef'
exec buildkite-agent start
```

The `BUILDKITE_AGENT_ACQUIRE_JOB` environment variable starts the agent in [single-job acquisition mode](/docs/agent/cli/reference/start#run-a-single-job). The agent can acquire only the job associated with the JAT.

## Lifetime and security

By default, a JAT expires 15 minutes after issuance. A stack can request a lifetime of up to one hour, but the token expires earlier if its job reservation expires first. Request the token only after execution capacity is available and immediately before starting the workload.

During agent registration, Buildkite checks that the agent token used to issue the JAT is still active and belongs to the expected organization and cluster. Any expiration or allowed IP address restrictions on the agent token also apply. The JAT doesn't contain the agent token value.

Treat job acquisition tokens as bearer credentials:

- Don't log these tokens or include them in persistent workload definitions.
- Inject the JAT only into the container running the Buildkite agent. Don't expose the token to checkout, command, or sidecar containers.
- If JAT issuance fails, don't fall back to passing the agent token to the workload.

For network errors, `429 Too Many Requests` responses, and `5xx` responses, use bounded retries with jitter. Honor the `Retry-After` header when present. Don't retry other `4xx` responses without changing the request or credential.
