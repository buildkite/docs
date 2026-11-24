# Working with Buildkite agents

A job running on a Buildkite agent can use [workload identity federation](/docs/apis/workload-identity-federation) to exchange its [OIDC token](/docs/agent/cli/reference/oidc) for a short-lived Buildkite API access token. The job doesn't need a stored API access token.

## Create the workload identity

Create a workload identity as described in [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity), and select **Buildkite Agents** as its **Provider**. The preset fills in the following settings:

- **OIDC issuer:** `https://agent.buildkite.com`.
- **OIDC subject:** `organization:acme-inc\:pipeline\:<pipeline-slug>:ref:refs/heads/main:commit:*:step:*`, with your Buildkite organization's slug in place of `acme-inc`. Replace `<pipeline-slug>` with your pipeline's slug. This subject matches every job in builds of the pipeline's `main` branch.
- **Claims:** An `organization_id` claim with your Buildkite organization's UUID. Keep it. Buildkite agents in every Buildkite organization share the same issuer, so Buildkite requires an `organization_id` or `organization_slug` claim.

## Exchange the token in a job

A job requests an OIDC token with the [`buildkite-agent oidc request-token`](/docs/agent/cli/reference/oidc) command, using the workload identity's **OIDC audience**, then exchanges it for an API access token:

```yaml
steps:
  - label: "Call the Buildkite API"
    env:
      BUILDKITE_CLIENT_ID: "YOUR_CLIENT_ID"
      BUILDKITE_AUDIENCE: "YOUR_OIDC_AUDIENCE"
    command: |
      OIDC_TOKEN="$$(buildkite-agent oidc request-token --audience "$$BUILDKITE_AUDIENCE")"

      BUILDKITE_API_TOKEN="$$(curl -sSf https://buildkite.com/oauth/token \
        -d "grant_type=client_credentials" \
        -d "client_id=$$BUILDKITE_CLIENT_ID" \
        -d "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
        -d "client_assertion=$$OIDC_TOKEN" | jq -r .access_token)"

      curl -sSf -H "Authorization: Bearer $$BUILDKITE_API_TOKEN" \
        https://api.buildkite.com/v2/access-token
```
{: codeblock-file="pipeline.yml"}

Replace `YOUR_CLIENT_ID` and `YOUR_OIDC_AUDIENCE` with the workload identity's **Client ID** and **OIDC audience**. The last command calls the [current token API](/docs/apis/rest-api/access-token#get-the-current-token), which needs no scope.

Run `buildkite-agent oidc request-token` again before each exchange, including retries, because a workload identity accepts each OIDC token only once. Learn more in [Get a new OIDC token for each exchange](/docs/apis/workload-identity-federation#exchange-an-oidc-token-get-a-new-oidc-token-for-each-exchange).

The API access token expires no later than the OIDC token, which lasts five minutes by default. If a job calls the API for longer, either set `--lifetime` to how long the job needs the API access token, up to 3600 seconds, or request and exchange a new OIDC token before the API access token expires. Learn more in [Token lifetime](/docs/apis/workload-identity-federation#exchange-an-oidc-token-token-lifetime).

## Limit which jobs can exchange tokens

Write [claim conditions](/docs/apis/workload-identity-federation#write-claim-conditions) on claims in the job's OIDC token. These claims are the most useful. The [OIDC token claims reference](/docs/agent/cli/reference/oidc#claims) lists every claim.

Claim | Value | Use it to
----- | ----- | ---------
`organization_id` | UUID of the Buildkite organization | Accept only jobs from your Buildkite organization. Required in **Claims**, unless you use `organization_slug`.
`pipeline_id` | UUID of the pipeline | Accept jobs from specific pipelines.
`build_branch` | Branch of the build, for example, `main` | Accept builds of specific branches.
`build_tag` | Tag of the build, only when it has one | Accept only tagged builds, such as releases.
`step_key` | `key` of the step, or `null` | Accept only specific steps, such as a deploy step.
`build_source` | `ui`, `api`, `webhook`, `trigger_job`, or `schedule` | Accept only builds created in specific ways.
`runner_environment` | `buildkite-hosted` or `self-hosted` | Accept only jobs on Buildkite hosted agents, or only on your own agents.
{: class="responsive-table"}

For example, this claim condition only accepts the `deploy` step of one pipeline, in builds of its `main` branch:

```text
claims.pipeline_id == "00000000-0000-4000-8000-000000000002"
  && claims.build_branch == "main"
  && claims.step_key == "deploy"
```

Prefer IDs to slugs, such as `pipeline_slug`. Renaming a pipeline or organization changes its slug, and someone else can then use the old slug.

Claims such as `cluster_id`, `queue_id`, and `queue_key` are only in the token when the job requests them with [`--claim`](/docs/agent/cli/reference/oidc#claims-optional-claims). For example, to accept only jobs on the `deploy` queue, request the `queue_key` claim:

```bash
buildkite-agent oidc request-token --audience "$BUILDKITE_AUDIENCE" --claim queue_key
```

Then check it in the claim condition:

```text
claims.queue_key == "deploy"
```
