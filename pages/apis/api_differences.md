# API differences between REST and GraphQL

Buildkite provides both a [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api). The APIs overlap for common operations but differ in authentication, query capabilities, and specialized operations.

The REST API supports granular access token scopes and specialized management endpoints. The GraphQL API supports nested queries, aggregate connection counts, and operations that aren't exposed through the REST API. Use both APIs when a workflow spans capabilities from each list.

The following lists cover public capabilities without an equivalent operation in the other API. Differences in field names and request or response shapes aren't included.

## Features only available in the REST API

- <%= pill "ACCESS TOKEN", "access-token" %> [Granular access permissions](/docs/apis/managing-api-tokens#token-scopes).
- <%= pill "ACCESS TOKEN", "access-token" %> [Display the information about the access token currently in use](/docs/apis/rest-api/access-token#get-the-current-token).
- <%= pill "ACCESS TOKEN", "access-token" %> [Revoke the current access token](/docs/apis/rest-api/access-token#revoke-the-current-token).
- <%= pill "AGENTS", "agents" %> Create [remote desktop sessions](/docs/apis/rest-api/jobs#create-a-remote-desktop-session) and [SSH sessions](/docs/apis/rest-api/jobs#create-an-ssh-session) for jobs running on Buildkite hosted agents.
- <%= pill "AGENTS", "agents" %> Manage [agent images](/docs/apis/rest-api/clusters/agent-images) and [cache volumes](/docs/apis/rest-api/clusters/cache-volumes), list [network ranges](/docs/apis/rest-api/clusters/network-ranges), and assign [cluster maintainers](/docs/apis/rest-api/clusters/maintainers).
- <%= pill "AGENTS", "agents" %> List, create, update, and delete [Buildkite secrets](/docs/apis/rest-api/clusters/secrets).
- <%= pill "JOBS", "jobs" %> Get the `group_key` field for jobs that belong to [group steps](/docs/apis/rest-api/builds#get-a-build).
- <%= pill "JOBS", "jobs" %> [Retrieve](/docs/apis/rest-api/jobs#get-a-jobs-log-output) and [delete](/docs/apis/rest-api/jobs#delete-a-jobs-log-output) job log output.
- <%= pill "JOBS", "jobs" %> [Reprioritize a job](/docs/apis/rest-api/jobs#reprioritize-a-job).
- <%= pill "META", "meta" %> [Get a list of IP addresses from which Buildkite sends webhooks](/docs/apis/rest-api/meta#get-meta-information).
- <%= pill "ORGANIZATIONS", "organizations" %> [List custom and built-in emojis](/docs/apis/rest-api/emojis).
- <%= pill "ORGANIZATIONS", "organizations" %> [Prevent non-administrators from creating API access tokens](/docs/apis/rest-api/organizations/api-settings#request-fields).
- <%= pill "ORGANIZATIONS", "organizations" %> Manage [organization-level pipeline settings](/docs/apis/rest-api/organizations/pipeline-settings), including hosted agent remote access, public pipeline creation, advanced queue metrics, and build exports.
- <%= pill "ORGANIZATIONS", "organizations" %> Create and manage [notification services](/docs/apis/rest-api/organizations/notification-services).
- <%= pill "ORGANIZATIONS", "organizations" %> Create and manage [Buildkite Package Registries](/docs/apis/rest-api/package-registries/registries), [packages](/docs/apis/rest-api/package-registries/packages), and [registry tokens](/docs/apis/rest-api/package-registries/registry-tokens).
- <%= pill "ORGANIZATIONS", "organizations" %> Use the Test Engine APIs to manage [test suites](/docs/apis/rest-api/test-engine/suites), [tests](/docs/apis/rest-api/test-engine/tests), [quarantine states](/docs/apis/rest-api/test-engine/quarantine), and [execution tags](/docs/apis/rest-api/test-engine/execution-tags), and inspect [test runs](/docs/apis/rest-api/test-engine/runs).
- <%= pill "ORGANIZATIONS", "organizations" %> [Enable team-based permissions](/docs/apis/rest-api/teams#enable-teams).
- <%= pill "PIPELINES", "pipelines" %> [Set source code provider settings](/docs/apis/rest-api/pipelines#provider-settings-properties) when creating or updating a pipeline.
- <%= pill "PIPELINES", "pipelines" %> Create and manage [pipeline triggers](/docs/apis/rest-api/pipeline-triggers), and inspect [trigger deliveries and their requests](/docs/apis/rest-api/pipeline-trigger-deliveries).

## Features only available in the GraphQL API

<!-- vale off -->

- <%= pill "AGENTS", "agents" %> List, create, and revoke [unclustered agent tokens](/docs/apis/graphql/cookbooks/agents#get-a-list-of-unclustered-agent-token-ids).
- <%= pill "BUILDS", "builds" %> [Update the next build number for an existing pipeline](/docs/apis/graphql/cookbooks/builds#increase-the-next-build-number).
- <%= pill "BUILDS", "builds" %> [Get build information directly by UUID](/docs/apis/graphql/cookbooks/builds#get-build-info-by-id).
- <%= pill "JOBS", "jobs" %> [Search jobs across an organization by queue, cluster, creation or finish date, or concurrency group](/docs/apis/graphql/schemas/object/organization).
- <%= pill "JOBS", "jobs" %> [List job events](/docs/apis/graphql/schemas/object/jobtypecommand).
- <%= pill "JOBS", "jobs" %> [Cancel a job](/docs/apis/graphql/schemas/mutation/jobtypecommandcancel).
- <%= pill "ORGANIZATIONS", "organizations" %> [Resend an organization invitation](/docs/apis/graphql/schemas/mutation/organizationinvitationresend).
- <%= pill "ORGANIZATIONS", "organizations" %> [Revoke a specific API access token's access to an organization](/docs/apis/graphql/schemas/mutation/organizationapiaccesstokenrevoke).
- <%= pill "ORGANIZATIONS", "organizations" %> [Set up and manage SSO](/docs/platform/sso/sso-setup-with-graphql).
- <%= pill "ORGANIZATIONS", "organizations" %> [Create and delete system banners](/docs/apis/graphql/cookbooks/organizations#create-and-delete-system-banners).
- <%= pill "ORGANIZATIONS", "organizations" %> [Enforce two-factor authentication for organization members](/docs/apis/graphql/cookbooks/organizations#enforce-two-factor-authentication-2fa-for-your-organization).
- <%= pill "ORGANIZATIONS", "organizations" %> Assign [Buildkite Package Registries to teams](/docs/apis/graphql/schemas/mutation/teamregistrycreate) and update or remove those assignments.
- <%= pill "PIPELINES", "pipelines" %> [Get the speed, reliability, and builds per week metrics shown on the pipeline dashboard](/docs/apis/graphql/cookbooks/pipelines#get-pipeline-metrics).
- <%= pill "PIPELINES", "pipelines" %> [Get the creation date of the most recent build in every pipeline in one request](/docs/apis/graphql/cookbooks/builds#get-the-creation-date-of-the-most-recent-build-in-every-pipeline).
- <%= pill "PIPELINES", "pipelines" %> [Count the number of builds on a branch without retrieving every build](/docs/apis/graphql/cookbooks/builds#count-the-number-of-builds-on-a-branch).
- <%= pill "PIPELINES", "pipelines" %> [Get pipeline information directly by UUID](/docs/apis/graphql/schemas/query/pipeline).
- <%= pill "PIPELINES", "pipelines" %> [Filter pipeline listings by archived state, cluster, creation date, favorite status, tags, or team, and control their sort order](/docs/apis/graphql/schemas/object/organization).
- <%= pill "PIPELINES", "pipelines" %> [Favorite or unfavorite a pipeline](/docs/apis/graphql/schemas/mutation/pipelinefavorite).
- <%= pill "PIPELINES", "pipelines" %> [Delete a source code provider webhook](/docs/apis/graphql/schemas/mutation/pipelinedeletewebhook) or [rotate a pipeline webhook URL](/docs/apis/graphql/schemas/mutation/pipelinerotatewebhookurl).
- <%= pill "PIPELINES", "pipelines" %> [Update a rule](/docs/apis/graphql/cookbooks/rules#edit-a-rule).

<!-- vale on -->

> 📘 Feature availability
> Some capabilities depend on the Buildkite product, plan, or preview features enabled for your organization.
