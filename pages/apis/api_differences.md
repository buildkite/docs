# API differences between REST and GraphQL

Buildkite provides both a [REST API](/docs/apis/rest-api) and [GraphQL API](/docs/apis/graphql-api), but there are some differences between the two. Some tasks can only be achieved using the GraphQL API or the REST API. For example, REST API is a good choice for Organization-level tasks and it also allows using granular access permissions, while GraphQL is more comprehensive and often can help you achieve things a single user would want to do in the Buildkite UI. We recommend using a mixture of both when required.


The strengths of the GraphQL API are in complex data queries, and the strengths of the REST API are in creating and modifying records.

On this page, we've collected the known limitation where some API features are only available with either REST or GraphQL.

## Features only available in the REST API

* <%= pill "ACCESS TOKEN", "access-token" %> [Granular access permissions](/docs/apis/managing-api-tokens#token-scopes).
* <%= pill "ACCESS TOKEN", "access-token" %> [Display the information about the access token currently in use](/docs/apis/rest-api/access-token#get-the-current-token).
* <%= pill "ACCESS TOKEN", "access-token" %> [Revoke the current access token](/docs/apis/rest-api/access-token#revoke-the-current-token).
* <%= pill "BUILDS", "builds" %> [Create annotations on a build](/docs/apis/rest-api/annotations).
* <%= pill "JOBS", "jobs" %> [Get an output of job logs](/docs/apis/rest-api/jobs#get-a-jobs-log-output).
* <%= pill "JOBS", "jobs" %> [Retry data for jobs](/docs/apis/rest-api/jobs#retry-a-job).
* <%= pill "META", "meta" %> [Get a list of IPs from which Buildkite sends webhooks](/docs/apis/rest-api/meta#get-meta-information).
* <%= pill "PIPELINES", "pipelines" %> [Set provider properties](/docs/apis/rest-api/pipelines#provider-settings-properties) `provider_settings` allow configuring how the pipeline is triggered based on the source code provider's events; available on pipeline for all the pipeline inputs on pipeline create.

## Features only available in the GraphQL API

* <%= pill "AGENTS", "agents" %> [Get a list of agent token IDs (agent tokens are currently only available via GraphQL)](/docs/apis/graphql/graphql-cookbook#agents-get-a-list-of-agent-token-ids).
* <%= pill "BUILDS", "builds" %> [Get all environment variables set on a build](/docs/apis/graphql/graphql-cookbook#builds-get-all-environment-variables-set-on-a-build).
* <%= pill "BUILDS", "builds" %> [Increase the next build number](/docs/apis/graphql/graphql-cookbook#builds-increase-the-next-build-number).
* <%= pill "BUILDS", "builds" %> [Get build info by ID] (/docs/apis/graphql/graphql-cookbook#builds-get-build-info-by-id).
* <%= pill "BUILDS", "builds" %> [Get detailed retry info for jobs in a build](/docs/apis/graphql/graphql-cookbook#builds-get-job-retry-info-for-a-build).
* <%= pill "JOBS", "jobs" %> [Get all jobs in a given queue for a given timeframe](/docs/apis/graphql/graphql-cookbook#jobs-get-all-jobs-in-a-given-queue-for-a-given-timeframe).
* <%= pill "JOBS", "jobs" %> [Get all jobs in a particular concurrency group](/docs/apis/graphql/graphql-cookbook#jobs-get-all-jobs-in-a-particular-concurrency-group).
* <%= pill "JOBS", "jobs" %> list job events.
* <%= pill "JOBS", "jobs" %> [Cancel a job](/docs/apis/graphql/schemas/mutation/jobtypecommandcancel).
* <%= pill "ORGANIZATIONS", "organizations" %> [Remove users from an organization](/docs/apis/graphql/graphql-cookbook#organizations-delete-an-organization-member).
* <%= pill "ORGANIZATIONS", "organizations" %> Manage teams - [add](/docs/apis/graphql/graphql-cookbook#teams-add-an-existing-organization-user-to-a-team) or [remove](/docs/apis/graphql/graphql-cookbook#teams-remove-a-team-member) a team member. Most of the team management features are only available for GraphQL. The REST API can only list teams and can create pipelines in teams.
* <%= pill "ORGANIZATIONS", "organizations" %> [Set up SSO](/docs/integrations/sso/sso-setup-with-graphql).
* <%= pill "ORGANIZATIONS", "organizations" %> [Remove pipeline edit access from existing teams](/docs/apis/graphql/graphql-cookbook#teams-set-teams-pipeline-edit-access-to-read-only-or-build-and-read).
* <%= pill "PIPELINES", "pipelines" %> [Get all the pipeline metrics from the dashboard from the API](/docs/apis/graphql/graphql-cookbook#pipelines-get-pipeline-metrics).
* <%= pill "PIPELINES", "pipelines" %> [Get the last build's creation date within every pipeline](/docs/apis/graphql/graphql-cookbook#builds-get-the-creation-date-of-the-most-recent-build-in-every-pipeline).
* <%= pill "PIPELINES", "pipelines" %> [Count the number of builds on a branch](/docs/apis/graphql/graphql-cookbook#builds-count-the-number-of-builds-on-a-branch).
* <%= pill "PIPELINES", "pipelines" %> [Get the creation date of the most recent build in every pipeline](/docs/apis/graphql/graphql-cookbook#builds-get-the-creation-date-of-the-most-recent-build-in-every-pipeline).
* <%= pill "PIPELINES", "pipelines" %> Filter results from pipeline listings.
* <%= pill "PIPELINES", "pipelines" %> Create and manage pipeline schedules.
* <%= pill "USERS", "users" %> [Invite a user into a specific team with a specific role and permissions set](/docs/apis/graphql/graphql-cookbook#organizations-create-a-user-add-them-to-a-team-and-set-user-permissions).

## Known missing API features

These are known requested features that are currently missing from both REST and GraphQL APIs:

* <%= pill "NOTIFICATION SERVICES", "notification-services" %> There is no API for managing notification services.
* <%= pill "USERS", "users" %> Display secondary user emails.

