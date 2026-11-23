# Supported APIs and scopes

A workload identity's API access tokens can use a subset of the Buildkite REST API. This page summarizes what tokens can do in each product area and the limits to plan for. For endpoint details, see the linked API references.

## How access works

A token can call an API when it has the API's scope and, for most APIs, access to the resource through the workload identity's **Resource Access** setting. Lists only include resources that the token can reach, and other resources return `404 Not Found`. A token acts as the workload identity itself, not as an organization administrator or the person who created the workload identity.

Product area | Resource access | Scopes
------------ | --------------- | ------
[Pipelines and builds](#pipelines-and-builds) | Pipelines | `read_pipelines`, `write_pipelines`, `read_builds`, `write_builds`, `retry_builds`, `read_job_env`, `read_job_errors`, `read_build_logs`, `read_artifacts`, `read_pipeline_templates`, `write_pipeline_templates`, `read_rules`, `write_rules`
[Agents and clusters](#agents-and-clusters) | Clusters | `read_agents`, `write_agents`, `read_clusters`, `write_clusters`
[Teams](#teams) | Teams | `read_teams`, `write_teams`
[Test Engine](#test-engine) | Test suites | `read_suites`, `write_suites`, `read_test_plan`, `write_test_plan`, `read_test_pool`
[Organization administration](#organization-administration) | Not limited | `read_organizations`, `write_organizations`, `read_organization_settings`, `write_organization_settings`, `read_notification_services`, `write_notification_services`, `read_audit_events`, `read_organization_invitations`, `read_api_request_logs`, `read_organization_repository_connections`, `read_portals`
{: class="responsive-table"}

Choose the scopes in **Grantable Scopes**, as described in [Create a workload identity](/docs/apis/workload-identity-federation#create-a-workload-identity).

## Pipelines and builds

With pipeline access, a token can work with those pipelines in Buildkite Pipelines: manage the pipelines, their schedules, triggers, and rules, create and manage builds and jobs, and read job logs and artifacts. Learn more in the [Pipelines](/docs/apis/rest-api/pipelines), [Builds](/docs/apis/rest-api/builds), and [Jobs](/docs/apis/rest-api/jobs) API references.

Creating pipelines and managing [pipeline templates](/docs/pipelines/governance/templates) require **All** pipeline access, because they affect pipelines outside any selection. A token can't unblock jobs on behalf of another person, or unblock jobs that are restricted to specific teams.

## Agents and clusters

With cluster access, a token can manage those clusters and their queues, agent tokens, and maintainers, and read, pause, and stop the agents that connect to them. Learn more in the [Clusters](/docs/apis/rest-api/clusters) and [Agents](/docs/apis/rest-api/agents) API references.

Creating clusters requires **All** cluster access. A cluster grant covers every queue in the cluster, and never includes unclustered agents.

## Teams

With team access, a token can read and manage those teams and their pipeline assignments. Changing a team's pipeline assignment also requires access to the pipeline. Creating teams requires **All** team access. A token can't add or remove team members. Learn more in the [Teams API](/docs/apis/rest-api/teams) reference.

## Test Engine

With test suite access, a token can work with those suites in Buildkite Test Engine: read their runs, tests, and test plans, and with `write_suites`, update and delete the suites, manage their workflows, and change test states, such as muting or skipping tests. With `write_test_plan`, a token can also create test plans. Learn more in the [Suites API](/docs/apis/rest-api/test-engine/suites) reference.

Reads that start from a build or pipeline, such as a build's tests or test pools, also require access to that pipeline. A token can't create test suites, assign them to teams, or see a suite's API token or webhook endpoints.

## Organization administration

Organization administration scopes reach across your whole Buildkite organization, and **Resource Access** doesn't limit them. They let a token manage members and organization settings, manage notification services, and read the audit log, invitations, API request logs, repository connections, and portals. A token with these scopes can read or change data about pipelines, teams, and clusters that it can't otherwise reach, so grant them only when the workload needs that access.

A token can't change security settings, invite people, or create portals.

## Access that outlives the token

Some changes that a token makes stay in place after the token expires or the workload identity is disabled:

- Agent tokens that it creates keep working, and their agents can run jobs from any pipeline that uses the cluster.
- Users and teams that it adds as cluster maintainers keep their access.
- Schedules that it creates keep running builds.
- Workflows that it adds to a test suite keep sending notifications.

Remove these separately when you no longer need them, and grant `write_clusters`, `write_pipelines`, and `write_suites` only to workloads that you trust.

## Unsupported APIs and scopes

GraphQL, Buildkite Package Registries, secrets, and workload identity management aren't supported. The `write_build_logs` and `write_artifacts` scopes can be configured, but don't enable log or artifact deletion.
