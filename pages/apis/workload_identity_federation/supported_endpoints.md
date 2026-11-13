# Supported APIs and scopes

Workload identity federation supports a subset of the REST API for Buildkite Pipelines and organization access. Use the API references below for endpoint paths, request parameters, and responses. This page lists the supported scopes and workload identity limitations.

## Supported APIs

A token needs both the operation's scope and access to its pipeline through the workload identity's **Resource Access** setting. Listing operations return only accessible resources. Requests for individual resources outside that access return `404 Not Found`, even for public pipelines.

API reference | Supported scopes | Workload identity limitations
------------- | ---------------- | -----------------------------
[Pipelines API](/docs/apis/rest-api/pipelines) | `read_pipelines`, `write_pipelines` | Can't create pipelines, even with **All** pipeline access.
[Pipeline schedules API](/docs/apis/rest-api/pipeline-schedules) | `read_pipelines` | Read-only. Can't create, update, or delete schedules.
[Pipeline triggers API](/docs/apis/rest-api/pipeline-triggers) | `read_pipelines`, `write_pipelines` | Can read, update, and delete existing triggers, but can't create triggers.
[Pipeline trigger deliveries API](/docs/apis/rest-api/pipeline-trigger-deliveries) | `read_pipelines` | Read-only.
[Builds API](/docs/apis/rest-api/builds) | `read_builds`, `write_builds`, `retry_builds` | Can't rebuild merge queue builds. Retry operations accept either `write_builds` or `retry_builds`.
[Jobs API](/docs/apis/rest-api/jobs) | `read_builds`, `write_builds`, `retry_builds`, `read_job_env` | Can't unblock jobs restricted to specific teams. Job retries accept either `write_builds` or `retry_builds`.
[Job logs](/docs/apis/rest-api/jobs#get-a-jobs-log-output) | `read_build_logs` | Read-only. Can't delete job logs.
[Hosted agent sessions](/docs/apis/rest-api/jobs#create-an-ssh-session) | `write_builds` | SSH and remote desktop sessions require session access to be enabled for the organization and an eligible job.
[Annotations API](/docs/apis/rest-api/annotations) | `read_builds`, `write_builds` | Can read, create, and delete build and job annotations in accessible pipelines.
[Step uploads API](/docs/apis/rest-api/step-uploads) | `read_builds` | Read-only.
[Artifacts API](/docs/apis/rest-api/artifacts) | `read_artifacts` | Can list, get, and download artifacts, but can't delete them.
[Organizations API](/docs/apis/rest-api/organizations), [Organization usage API](/docs/apis/rest-api/organizations/usage), and [Rate limits](/docs/apis/rest-api/rate-limits) | `read_organizations` | Own organization only. Not restricted by pipeline access.
[Organization members API](/docs/apis/rest-api/organizations/members) | `read_organizations`, `write_organizations` | Own organization only. Can read members, update roles and SSO mode, and remove members. Listing and getting members require teams to be enabled. The organization must retain at least one administrator.
[Access token API](/docs/apis/rest-api/access-token) | No additional scope | Can inspect or revoke the token used for the request.
{: class="responsive-table"}

Organization scopes grant organization-wide access regardless of **Resource Access**. Grant them only when the workload needs that access.

Choose the required scopes in **Grantable Scopes**, then select a subset in **Default Scopes** or request a subset during token exchange. See [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity).

## Unsupported APIs and scopes

GraphQL, Buildkite Test Engine, and Buildkite Package Registries aren't supported. Neither are agent and cluster management, teams, secrets, pipeline templates, rules, organization settings, or workload identity management. Their scopes aren't available to workload identities.

The `write_build_logs` and `write_artifacts` scopes can be configured on a workload identity, but don't currently enable log or artifact deletion. An available scope doesn't guarantee access to every operation that accepts it.
