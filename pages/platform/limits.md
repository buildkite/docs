# Limits

Buildkite service quotas limit resource usage across your organization. Limits vary by plan and during the All Access Trial.

This page lists default limits. To check your organization's current limits, see [Viewing your organization's service quotas](#viewing-your-organizations-service-quotas). For available plans and their features, see [Pricing](https://buildkite.com/pricing/).

The [**Usage** page](https://buildkite.com/organizations/~/usage) is available on every Buildkite plan and shows a breakdown of usage metrics across the Buildkite platform and all products for your Buildkite organization.

## Viewing your organization's service quotas

Buildkite organization administrators can view the service quotas that apply to their organization on the **Service Quotas** page in **Organization Settings**.

To access your organization's service quotas:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Quotas** to open the **Service Quotas** page.

    <%= image "service-quotas.png", width: 1162, height: 654, alt: "The Service Quotas page in Organization Settings, showing quota limits grouped by product area with name, description, and limit value for each quota" %>

    The **Service Quotas** page displays your organization's current limits grouped by product area. Each quota shows the limit that applies to your organization, which may differ from the defaults listed on this page.

    A **Custom** badge next to a quota indicates that your organization has a limit that differs from the default for your plan. An **Exceeded in last 24h** badge indicates that your organization reached this limit within the past 24 hours.

> 📘 Adjusting limits
> Some organization-level limits can be increased on request depending on your plan. Contact Buildkite support at support@buildkite.com with details about your use case, or contact your Technical Account Manager if you have one.

## Platform and organization-level limits

These limits apply across Buildkite products.

Service limit type | Description | Default limit
--- | --- | ---
Organizations per day | The maximum number of organizations a user can create per day. | 4 organizations
Organizations per user | The maximum total number of organizations a user can create. | 20 organizations
Unverified emails per user | The maximum number of unverified emails per user. | 5 emails
Invitations per organization | The maximum number of pending invitations for an organization. | 20 invitations
Teams per organization | The maximum number of teams that an organization can have. | 250 teams
REST API rate limit per organization | The number of requests an organization can make to Organization endpoints on the REST API, per minute. | 200 requests per minute
GraphQL API rate limit per organization | The total [actual complexity points](/docs/apis/graphql/graphql-resource-limits#rate-limits-organization-level-time-based-rate-limit) an organization can consume on the GraphQL API within a 5-minute window. | 20,000 complexity points per 5 minutes
Portal API rate limit per organization | The number of requests an organization can make to Organization endpoints on the Portal API, per minute. | 200 requests per minute
REST API rate limit per user | The default number of [per-user](/docs/apis/rest-api/rate-limits#per-user-rate-limits) requests a single user can make to the REST API, per minute. This limit applies in addition to the organization-wide REST API rate limit. | 50 requests per minute
GraphQL API rate limit per user | The default [per-user](/docs/apis/graphql/graphql-resource-limits#rate-limits-per-user-rate-limit) complexity points a single user can consume on the GraphQL API within a 5-minute window. This limit applies in addition to the organization-wide GraphQL API rate limit. | 5,000 complexity points per 5 minutes
Remote MCP server rate limit per user | The number of REST API requests a user can make through the [remote Buildkite MCP server](/docs/apis/mcp-server/remote/rate-limits), per minute. This limit is separate from the organization-wide REST API rate limit. | 50 requests per minute
GraphQL query complexity | The maximum complexity score for GraphQL queries. | 50,000
GraphQL query depth | The maximum nesting depth for GraphQL queries. | 15 levels
Audit search terms | The maximum number of search terms for audit logs. | 3 terms
IP addresses per token | The maximum number of IP allowlist entries per token. | 24 addresses
Maximum OIDC lifetime | The default maximum lifetime for OIDC. | 2 hours
{: class="responsive-table"}

## Pipelines limits

The following table lists the default service limits for [Buildkite Pipelines](/docs/pipelines).

Service limit type | Description | Default limit
--- | --- | ---
Jobs per build | The maximum number of jobs that can be created in a single pipeline build (including job retries). | 4,000 jobs
Jobs created per pipeline upload | The maximum number of jobs that can be created in a single pipeline upload. | 500 jobs
Job timeout | The maximum time before a running job will time out. | 4 hours on the Free plan. Unlimited on Pro and Enterprise plans
Pipeline uploads per build | The maximum number of pipeline uploads that can be performed in a single build. | 500 pipeline uploads
Triggers per pipeline | The maximum number of webhook triggers per pipeline. | 10
Trigger build depth per pipeline | The maximum depth of a chain of trigger builds. | 10 builds
Concurrency key length | The maximum length for concurrency group keys. | 200 characters
Build retention | The time period builds are stored in Buildkite Pipelines after running. | 30 days on the Free plan, 90 days on the Pro plan, and 365 days on the Enterprise plan
Teams per block step | The maximum number of allowed teams for manual unlock steps. | 100 teams
Matrix jobs per step | The maximum number of matrix jobs in a pipeline step. | 50 jobs
Annotation replacements | The maximum number of image or link replacements per annotation. | 10 replacements
Artifacts per job | The maximum number of artifacts that can be uploaded to Buildkite Pipelines per job. | 5000 artifacts
Artifact file size | The maximum size of an artifact that can be uploaded to Buildkite Pipelines from an agent. | 10 GiB
Artifact batch total file size | The maximum cumulative size of artifacts that can be uploaded to Buildkite Pipelines from an agent in a single job using the `buildkite-agent artifact upload` command. | 50 GiB
Multipart upload artifacts | The maximum number of artifacts per upload batch. | 30 artifacts
Artifact retention | The maximum number of days artifacts are stored. See [Artifacts billing](/docs/platform/artifact-storage-and-transfer-billing#artifact-retention) for how retention relates to storage usage. | 30 days on the Free, Personal, and Pro plans, 90 days on the Enterprise plan and during trials, and 180 days on earlier paid plans, such as Pro and Enterprise plans from before 2026
Log size per job | The maximum file size of a job's log. | 1,024 MiB
Number of clusters | The maximum number of clusters that can be created in a Buildkite organization. | 1 on the Free plan, unlimited on Pro and Enterprise plans
Number of queues per cluster | The default number of queues that can be created on a single cluster. | 50
Portal secrets | The maximum number of secrets per portal. | 2 secrets
Number of stacks per organization | The default number of stacks that can be created per organization. | 30
Cache size for hosted agents | The maximum cache size for hosted agents. | 128 GB
Artifact Create/Update API calls | The number of Create or Update requests for artifacts per minute per organization. | 600
Slack services per organization | The maximum number of Slack services that can be added to an organization. | 50 services
Webhook services per organization | The maximum number of Webhook services that can be added to an organization. | 15 services
Event Log API services per organization | The maximum number of Event Log API services that can be added to an organization. | 15 services
OpenTelemetry Tracing services per organization | The maximum number of OpenTelemetry Tracing services that can be added to an organization. | 5 services
Datadog Pipeline Visibility services per organization | The maximum number of Datadog Pipeline Visibility services that can be added to an organization. | 5 services
AWS EventBridge services per organization | The maximum number of AWS EventBridge services that can be added to an organization. | 1 service
Anthropic spend | Model provider spend limits for Anthropic, per month in USD. | $50 during the All Access Trial, $1,000 on Pro and Enterprise
OpenAI spend | Model provider spend limits for OpenAI, per month in USD. | $50 during the All Access Trial, $1,000 on Pro and Enterprise
{: class="responsive-table"}

### Hosted agents limits

[Buildkite hosted agent](/docs/agent/buildkite-hosted) concurrency limits the combined vCPU capacity of machines allocated to your organization. Each machine runs one job and uses the vCPU capacity specified by its [instance shape](/docs/agent/queues/managing#create-a-buildkite-hosted-queue). Machines count toward concurrency from boot until release.

| Limit type | All Access Trial | Free | Pro | Enterprise |
| --- | --- | --- | --- | --- |
| **Linux AMD64 vCPU concurrency** | 24 vCPU | 20 vCPU | 256 vCPU | Custom |
| **Linux ARM64 vCPU concurrency** | 24 vCPU | Not available | 64 vCPU | Custom |
| **M4 Mac vCPU concurrency** | 12 vCPU | Not available | 48 vCPU | Custom |
| **Windows vCPU concurrency** | 24 vCPU | Not available | 64 vCPU | Custom |
| **Linux AMD64 vCPU minutes per month** | 4,000 included | Up to 2,000 | 4,000 included | Volume discounts |
| **Linux ARM64 vCPU minutes per month** | 4,000 included | Not available | Pay as you go | Volume discounts |
| **M4 Mac vCPU minutes per month** | 3,000 included | Not available | Pay as you go | Volume discounts |
| **Windows vCPU minutes per month** | 4,000 included | Not available | Pay as you go | Volume discounts |
{: class="responsive-table"}

> 📘 Adjusting hosted agents limits
> All Access Trial and Enterprise hosted agents limits can be increased on request. Contact Buildkite support at support@buildkite.com with details about your use case, or contact your Technical Account Manager if you have one.

To calculate the maximum number of concurrent jobs using one instance shape, divide your vCPU concurrency limit by the shape's vCPU count. For example:

- The Free plan's 20-vCPU Linux AMD64 limit supports up to 10 Small machines at two vCPU each.
- The Pro plan's 256-vCPU Linux AMD64 limit supports up to 128 Small machines, 64 Medium machines at four vCPU each, or 32 Large machines at eight vCPU each.

For a mix of shapes, the combined vCPU capacity must stay within the limit. Jobs that would exceed it remain queued until capacity becomes available.

The following default storage quotas apply to [hosted agent cache volumes](/docs/agent/buildkite-hosted/cache-volumes):

| Storage quota | Default |
| --- | --- |
| **Container cache volume** | 50 GB |
| **Git mirror volume** | 5 GB |

vCPU minute allowances and usage pricing are separate from concurrency limits. See [Pricing](https://buildkite.com/pricing/) for current usage rates, available [Linux](/docs/agent/buildkite-hosted/linux#sizes), [macOS](/docs/agent/buildkite-hosted/macos#sizes), and [Windows](/docs/agent/buildkite-hosted/windows#sizes) shapes, and hosted agent features included with each plan.

## Test Engine limits

The following table lists the default service limits for [Test Engine](/docs/pipelines/configure/tests).

Service limit type | Description | Default limit
--- | --- | ---
Test Engine workflows per suite | The maximum number of Test Engine workflows per suite. | Not available on the Free plan, 1 workflow on the Pro plan, 3 workflows on the Enterprise plan
Test Engine workflow events per minute | The maximum number of Test Engine workflow events per minute. | 500 events
Test Splitting API rate limit | The number of requests that can be made to the Test Splitting API. | 10,000 requests per minute
Test ownership file size | The maximum size for CODEOWNERS files. | 1 MB
Linear services per organization | The maximum number of Linear integrations that can be added to an organization. | 1 service
{: class="responsive-table"}

## Package Registries limits

The following table lists the default service limits for [Buildkite Package Registries](/docs/package-registries). The limits in Package Registries are based on the [subscription tier](https://buildkite.com/pricing/):

Plan | Description | Default limit
--- | --- | ---
Free plan | Allocated storage and bandwidth volume (combined). | 1 GB per month (hard limit)
Pro plan | Allocated storage and bandwidth volume (combined). | 20 GB included per organization per month, then usage-based billing
Enterprise plan | Allocated storage and bandwidth volume (combined). | Custom allocation with volume pricing
{: class="responsive-table"}
