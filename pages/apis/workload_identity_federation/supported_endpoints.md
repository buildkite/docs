# Supported APIs and scopes

Workload identity federation supports a subset of the REST API. This page describes what a workload identity's API access tokens can do in each product area, which scopes and resource access control it, and what stays unsupported. For endpoint paths, request parameters, and responses, use the linked API references.

## How scopes and resource access work together

A token can call a REST API operation when it has the operation's scope and, for most operations, access to the resource through the workload identity's **Resource Access** setting. Listing operations return only the resources that the token can reach. Requests for individual resources outside its access return `404 Not Found`, even for public pipelines.

Product area | Scopes | Controlled by
------------ | ------ | -------------
[Pipelines and builds](#pipelines-and-builds) | `read_pipelines`, `write_pipelines`, `read_builds`, `write_builds`, `retry_builds`, `read_job_env`, `read_job_errors`, `read_build_logs`, `read_artifacts` | Pipeline access
[Pipeline templates](#pipelines-and-builds-pipeline-templates) | `read_pipeline_templates`, `write_pipeline_templates` | **All** pipeline access
[Rules](#pipelines-and-builds-rules) | `read_rules`, `write_rules` | Pipeline access to both pipelines in the rule
[Agents](#agents-and-clusters) | `read_agents`, `write_agents` | Cluster access
[Clusters](#agents-and-clusters) | `read_clusters`, `write_clusters` | Cluster access
[Teams](#teams) | `read_teams`, `write_teams` | Team access, and pipeline access for pipeline assignments
[Organization administration](#organization-administration) | `read_organizations`, `write_organizations`, `read_organization_settings`, `write_organization_settings`, `read_notification_services`, `write_notification_services`, `read_audit_events`, `read_organization_invitations`, `read_api_request_logs`, `read_organization_repository_connections`, `read_portals` | Scope only, across the whole organization
[Token and user](#organization-administration-token-and-user) | `read_user`, or no scope | The workload identity itself
{: class="responsive-table"}

Choose the scopes in **Grantable Scopes**, then select a subset in **Default Scopes** or request a subset during token exchange. Learn more in [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity).

A token acts as the workload identity's own user, not as an organization administrator or as the person who created the workload identity. Audit events for its changes name the workload identity.

## Pipelines and builds

With pipeline access, a token can work with those pipelines in Buildkite Pipelines, and their builds, jobs, job logs, artifacts, annotations, and step uploads. It can also manage the pipelines' [schedules](/docs/apis/rest-api/pipeline-schedules) and [triggers](/docs/apis/rest-api/pipeline-triggers) with `write_pipelines`. Learn more in the [Pipelines](/docs/apis/rest-api/pipelines), [Builds](/docs/apis/rest-api/builds), [Jobs](/docs/apis/rest-api/jobs), and [Artifacts](/docs/apis/rest-api/artifacts) API references.

The following limits apply:

- **Creating pipelines:** Requires **All** pipeline access and `write_pipelines`. A token can't assign teams when it creates a pipeline.
- **Retrying and rebuilding:** Retries accept either `write_builds` or `retry_builds`. A token can't rebuild merge queue builds.
- **Unblocking jobs:** A token unblocks jobs as the workload identity's user. It can't unblock jobs on behalf of another user, or unblock jobs that are restricted to specific teams.
- **Reprioritizing jobs:** A token can't reprioritize jobs in clusters that restrict job priority changes.
- **Logs and artifacts:** A token can read job logs and artifacts, but can't delete them.
- **Hosted agent sessions:** SSH and remote desktop sessions require session access to be enabled for the organization and an eligible job.
- **Schedules:** A schedule keeps running after the workload identity that created it is disabled or deleted, or loses access to the pipeline. Disable or delete the schedule separately when you no longer need it.

### Pipeline templates

A token can read and manage [pipeline templates](/docs/pipelines/governance/templates) with `read_pipeline_templates` and `write_pipeline_templates`, but only with **All** pipeline access, because editing a template changes every pipeline that uses it. With **All** pipeline access, a token can also see templates that are marked as unavailable, and assign them when it creates a pipeline. It can't assign an unavailable template when it updates a pipeline.

### Rules

A token can read and manage [rules](/docs/apis/rest-api/rules) with `read_rules` and `write_rules`. It only sees and changes rules whose source and target pipelines are both within its pipeline access, and new or updated rules can only reference those pipelines. With **All** pipeline access, a token can manage every rule in the organization.

## Agents and clusters

With cluster access, a token can work with those clusters and the agents that connect to them. Unclustered agents are never included. A cluster grant covers every queue in the cluster, and you can't grant access to individual queues.

Agents use their own scopes. With `read_agents`, a token can read agents and queue metrics in its clusters, and with `write_agents`, it can pause, resume, and stop those agents. An agent's current job is only visible when the token can also reach the job's pipeline, and job details, such as the command, also require `read_builds`. Learn more in the [Agents API](/docs/apis/rest-api/agents) reference.

With `read_clusters` and `write_clusters`, a token can manage its clusters and their queues, agent tokens, maintainers, cache registries, agent images, network ranges, and cache volumes. Learn more in the [Clusters API](/docs/apis/rest-api/clusters) reference.

The following limits apply:

- **Creating clusters:** Requires **All** cluster access and `write_clusters`.
- **Buildkite hosted queues:** Unless your organization is on a paid plan, personal plan, or trial, it needs a credit card on file before a token can create a hosted queue.
- **Cache registries:** A token can't delete cache registries.
- **Cluster maintainers:** A token can add users and teams as maintainers without team access. Workload identities can't be maintainers themselves.

### Access that outlives the token

Some cluster operations hand out access that doesn't depend on the token or the workload identity's **Resource Access** setting:

- **Agent tokens:** An agent token that a workload creates stays valid after the workload's API access token expires, the cluster grant is removed, or the workload identity is disabled. Agents that connect with it can run jobs from any pipeline that uses the cluster, regardless of the workload identity's pipeline access.
- **Cluster maintainers:** Users and teams that a workload adds as maintainers keep their access until someone removes them.

Revoke agent tokens and remove maintainers separately when you no longer need them. Only grant `write_clusters` to workloads that you trust to manage who and what can access the cluster.

## Teams

With team access and `read_teams`, a token can read those teams, their members, and their pipeline assignments. With `write_teams`, it can update and delete those teams, and add, update, and remove their pipeline assignments. Teams must be enabled for your Buildkite organization. Learn more in the [Teams API](/docs/apis/rest-api/teams) reference.

The following limits apply:

- **Creating teams:** Requires **All** team access, `write_teams`, and teams permissions enabled for the organization. A new team has no members.
- **Pipeline assignments:** Reading or changing a team's pipeline assignment, including removing it, requires access to both the team and the pipeline. **All** team access doesn't add access to any pipelines.
- **Deleting teams:** Requires only team access and `write_teams`. Deleting a team removes the team's access to pipelines, clusters, test suites, and secrets, including ones outside the token's access.
- **Unsupported team changes:** A token can't add, update, or remove team members, enable teams, or let a team's members manage pipeline templates. Team test suites and team registries aren't supported.

## Organization administration

Organization administration scopes give access across your whole Buildkite organization. **Resource Access** doesn't limit them, so a token can read or change data about pipelines, teams, and clusters that it can't otherwise reach. The workload identity's user doesn't need to be an organization administrator. Grant these scopes only when the workload needs that access.

Scopes | What a token can do
------ | -------------------
`read_organizations`, `write_organizations` | Read the [organization](/docs/apis/rest-api/organizations), its [usage](/docs/apis/rest-api/organizations/usage), and its [rate limits](/docs/apis/rest-api/rate-limits). Read [members](/docs/apis/rest-api/organizations/members), update their roles and SSO mode, and remove them. Listing and getting members requires teams to be enabled, and the organization must keep at least one administrator.
`read_organization_settings`, `write_organization_settings` | Read and change organization settings, such as [API settings](/docs/apis/rest-api/organizations/api-settings), [pipeline settings](/docs/apis/rest-api/organizations/pipeline-settings), and the [organization banner](/docs/apis/rest-api/organizations/banner). Plan requirements still apply. Security settings, such as two-factor authentication requirements, are read-only.
`read_notification_services`, `write_notification_services` | Read and manage [notification services](/docs/apis/rest-api/organizations/notification-services). A notification service can cover pipelines, teams, and clusters outside the token's access, including ones created later. Reads include provider settings, such as webhook tokens.
`read_audit_events` | Read every event in the [audit log](/docs/apis/rest-api/organizations/audit-events). Requires a plan that includes audit logging.
`read_organization_invitations` | Read [invitations](/docs/apis/rest-api/organizations/invitations), including invitee emails, roles, and assigned teams. A token can't create or revoke invitations.
`read_api_request_logs` | Create, read, and download API request log exports. An export covers every API request in the organization, including the IP addresses, paths, and user agents of other users and tokens.
`read_organization_repository_connections` | Read [repository connections](/docs/apis/rest-api/organizations/repository-connections) and the [repositories](/docs/apis/rest-api/repository-connections) that they can access.
`read_portals` | Read [portals](/docs/apis/rest-api/portals). A token can't create, update, or delete portals, because creating a portal issues a separate portal token.
{: class="responsive-table"}

### Token and user

Without any additional scope, a token can inspect or revoke itself with the [Access token API](/docs/apis/rest-api/access-token). With `read_user`, the [User API](/docs/apis/rest-api/user) returns the workload identity's own user.

## Unsupported APIs and scopes

GraphQL, Buildkite Test Engine, and Buildkite Package Registries aren't supported. Neither are secrets or workload identity management. Their scopes aren't available to workload identities.

The `write_portals` and `write_organization_invitations` scopes aren't available either, because portals and invitations grant access that outlasts the token.

The `write_build_logs` and `write_artifacts` scopes can be configured on a workload identity, but don't currently enable log or artifact deletion. An available scope doesn't guarantee access to every operation that accepts it.
