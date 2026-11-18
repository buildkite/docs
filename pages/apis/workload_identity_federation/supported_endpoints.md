# Supported APIs and scopes

Workload identity federation supports a subset of the REST API. Use the API references below for endpoint paths, request parameters, and responses. This page lists the supported scopes and workload identity limitations.

## Supported APIs

A token needs both the operation's scope and access to its resource through the workload identity's **Resource Access** setting. Pipeline grants control pipeline access, team grants control team access, and cluster grants control access to agents in those clusters. Listing operations return only accessible resources. Requests for individual resources outside that access return `404 Not Found`, even for public pipelines.

API reference | Supported scopes | Workload identity limitations
------------- | ---------------- | -----------------------------
[Pipelines API](/docs/apis/rest-api/pipelines) | `read_pipelines`, `write_pipelines` | Creating pipelines requires **All** pipeline access and `write_pipelines`. Can't assign teams when creating a pipeline.
[Pipeline schedules API](/docs/apis/rest-api/pipeline-schedules) | `read_pipelines` | Read-only. Can't create, update, or delete schedules.
[Pipeline triggers API](/docs/apis/rest-api/pipeline-triggers) | `read_pipelines`, `write_pipelines` | Can read, update, and delete existing triggers, but can't create triggers.
[Pipeline trigger deliveries API](/docs/apis/rest-api/pipeline-trigger-deliveries) | `read_pipelines` | Read-only.
[Builds API](/docs/apis/rest-api/builds) | `read_builds`, `write_builds`, `retry_builds` | Can't rebuild merge queue builds. Retry operations accept either `write_builds` or `retry_builds`.
[Jobs API](/docs/apis/rest-api/jobs) | `read_builds`, `write_builds`, `retry_builds`, `read_job_env` | Can't unblock jobs restricted to specific teams or reprioritize jobs in clusters that restrict job priority changes. Job retries accept either `write_builds` or `retry_builds`.
[Job logs](/docs/apis/rest-api/jobs#get-a-jobs-log-output) | `read_build_logs` | Read-only. Can't delete job logs.
[Hosted agent sessions](/docs/apis/rest-api/jobs#create-an-ssh-session) | `write_builds` | SSH and remote desktop sessions require session access to be enabled for the organization and an eligible job.
[Annotations API](/docs/apis/rest-api/annotations) | `read_builds`, `write_builds` | Can read, create, and delete build and job annotations in accessible pipelines.
[Step uploads API](/docs/apis/rest-api/step-uploads) | `read_builds` | Read-only.
[Artifacts API](/docs/apis/rest-api/artifacts) | `read_artifacts` | Can list, get, and download artifacts, but can't delete them.
[Teams API](/docs/apis/rest-api/teams) | `read_teams`, `write_teams` | Can list and get granted teams. Creating teams requires **All** team access, `write_teams`, and teams permissions enabled for the organization. Can't update or delete teams, or enable teams.
[Team members API](/docs/apis/rest-api/teams/members) | `read_teams` | Can list and get members of granted teams. Can't add, update, or remove team members.
[Team pipelines API](/docs/apis/rest-api/teams/pipelines) | `read_teams` | Can list and get assignments only when both the team and pipeline are granted. Can't add, update, or remove assignments.
[Agents API](/docs/apis/rest-api/agents) | `read_agents`, `write_agents` | Can list and get agents and queue metrics in granted clusters, and pause, resume, or stop those agents. Unclustered agents are never included. See [Agent access limitations](#agent-access-limitations).
[Organizations API](/docs/apis/rest-api/organizations), [Organization usage API](/docs/apis/rest-api/organizations/usage), and [Rate limits](/docs/apis/rest-api/rate-limits) | `read_organizations` | Own organization only. Not restricted by pipeline access.
[Organization members API](/docs/apis/rest-api/organizations/members) | `read_organizations`, `write_organizations` | Own organization only. Can read members, update roles and SSO mode, and remove members. Listing and getting members require teams to be enabled. The organization must retain at least one administrator.
[Access token API](/docs/apis/rest-api/access-token) | No additional scope | Can inspect or revoke the token used for the request.
{: class="responsive-table"}

Organization scopes grant organization-wide access regardless of **Resource Access**. Grant them only when the workload needs that access.

Choose the required scopes in **Grantable Scopes**, then select a subset in **Default Scopes** or request a subset during token exchange. See [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity).

## Agent access limitations

Agent read operations require `read_agents`. Pausing, resuming, and stopping agents require `write_agents`. A cluster grant doesn't enable the cluster, queue, or agent token APIs, which require the unavailable `read_clusters` or `write_clusters` scopes.

An agent's current job is only visible when its pipeline is also granted. Job details, such as the command, also require `read_builds`.

## Unsupported APIs and scopes

GraphQL, Buildkite Test Engine, and Buildkite Package Registries aren't supported. Neither are cluster, queue, or agent token management, secrets, pipeline templates, rules, organization settings, or workload identity management. Their scopes aren't available to workload identities.

The `write_build_logs` and `write_artifacts` scopes can be configured on a workload identity, but don't currently enable log or artifact deletion. An available scope doesn't guarantee access to every operation that accepts it.
