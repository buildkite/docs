# Limits

The page outlines and service limits based on the Buildkite's platform limits and usage limits based on your subscription tier. The available subscription tiers are:

- Personal (free plan with low usage limits)
- Trial (30 days of Pro Plan trial)
- Pro
- Enterprise

You can find out more about the available plans and what is included in them in [Pricing](https://buildkite.com/pricing/).

> 📘 Overriding the limits
> If you are on the Enterprise Plan, some of the organization-level limits might be increased. Reach out to your dedicated technical account manager or email the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com) and provide the details about your use case to find out if it is possible.

## Buildkite Pipelines limits

The following table lists Buildkite Pipelines' default service limits.

<table>
  <thead>
    <tr>
      <th style="width:25%">Service limit type</th>
      <th style="width:75%">Description and default limit</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        title: "Jobs per build",
        description: "The maximum number of jobs that can be created in a single pipeline build (including job retries).",
        default_value: "4,000 jobs"
      },
      {
        title: "Jobs created per pipeline upload",
        description: "The maximum number of jobs that can be created in a single pipeline upload.",
        default_value: "500 jobs"
      },
      {
        title: "Job timeout",
        description: "Time period after which a running job will time out.",
        default_value: "4 hours on the Personal plan. Unlimited for Pro and Enterprise"
      },
      {
        title: "Pipeline uploads per build",
        description: "The maximum number of pipeline uploads that can be performed in a single build.",
        default_value: "500 pipeline uploads"
      },
      {
        title: "Triggers per pipeline",
        description: "The maximum number of webhook triggers per pipeline.",
        default_value: "10"
      },
      {
        title: "Trigger build depth per pipeline",
        description: "The maximum depth of a chain of trigger builds.",
        default_value: "10 builds"
      },
      {
        title: "Triggered builds per build",
        description: "The maximum number of triggered builds per a single build.",
        default_value: "250 builds"
      },
      {
        title: "Build retention",
        description: "How long builds are stored with Buildkite after running.",
        default_value: "90 days on the Personal and Pro plans. 365 days for Enterprise"
      },
      {
        title: "Matrix jobs per step",
        description: "The maximum number of matrix jobs in a pipeline step.",
        default_value: "50 jobs"
      },
      {
        title: "Artifacts per job",
        description: "The maximum number of artifacts that can be uploaded to Buildkite per job.",
        default_value: "5000 artifacts"
      },
      {
        title: "Artifact file size",
        description: "The maximum size of an artifact that can be uploaded to Buildkite from an agent.",
        default_value: "10 GiB"
      },
      {
        title: "Artifact batch total file size",
        description: "The maximum cumulative size of artifacts that can be uploaded to Buildkite from an agent in a single job using the <code>buildkite-agent artifact upload</code> command.",
        default_value: "50 GiB"
      },
      {
        title: "Artifact retention",
        description: "The maximum time we'll store artifacts for, in days, before assuming it has been deleted by an S3 Lifecycle rule, which must be configured separately.",
        default_value: "180 days"
      },
      {
        title: "Log size per job",
        description: "The maximum file-size of a job's log (uploaded by an agent to Buildkite in chunks).",
        default_value: "1,024 MiB"
      },
      {
        title: "Log chunk interval",
        description: "The time interval between the log chunks",
        default_value: "1 second"
      },
      {
        title: "Number of clusters",
        description: "How many clusters can be created in a Buildkite organization.",
        default_value: "1 on the Personal plan. Unlimited on Pro and Enterprise"
      },
      {
        title: "Number of queues per cluster",
        description: "Default number of queues that can be created on a single cluster.",
        default_value: "50"
      },
      {
        title: "Number of stacks per organization",
        description: "Default number of stacks that can be created per organization.",
        default_value: "30"
      },
      {
        title: "Artifact Create/Update API calls",
        description: "The number of Create or Update requests for artifacts per minute per organization.",
        default_value: "600"
      },
      {
        title: "Anthropic spend",
        description: "Model provider spend limits for Anthropic, per month in USD.",
        default_value: "$50 on Trial plan, $1,000 on Pro and Enterprise"
      },
      {
        title: "OpenAI spend",
        description: "Model provider spend limits for OpenAI, per month in USD.",
        default_value: "$50 on Trial plan, $1,000 on Pro and Enterprise"
      }
    ].sort_by { |limit| limit[:title] }.each do |limit| %>
      <tr>
        <td>
          <strong><%= limit[:title] %></strong>
         </td>
        <td>
          <p><%= limit[:description] %></p>
          Default: <strong><%= limit[:default_value] %></strong>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### Hosted agents limits

The following limits apply to the [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted).

#### Concurrency limits

| Plan Type | Linux Concurrency | macOS Concurrency |
| --- | --- | --- |
| Personal | 3 | - |
| Trial | 10 | 3 |
| Pro | 20 | 5 |
| Enterprise| Custom | Custom |

#### Minutes limits (per month)

| Plan Type | Linux Minutes | macOS Minutes |
| --- | --- | --- |
| Personal | 550 | - |
| Trial | 2,000 | 3,000 |

#### Hosted agents cache volume limits

| Volume type | Limit |
| --- | --- |
| Container Cache Volume | 50 GB |
| Git Mirror Volume | 5 GB |

## Test Engine limits

<table>
  <thead>
    <tr>
      <th style="width:25%">Service limit type</th>
      <th style="width:75%">Description and default limit</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        title: "Test Engine workflows per suite (Personal)",
        description: "The maximum number of Test Engine workflows per suite on the Personal plan.",
        default_value: "1 workflow"
      },
      {
        title: "Test Engine workflows per suite (Pro)",
        description: "The maximum number of Test Engine workflows per suite on the Pro plan.",
        default_value: "3 workflows"
      },
      {
        title: "Test Engine workflows per suite (Enterprise)",
        description: "The maximum number of Test Engine workflows per suite on the Enterprise plan.",
        default_value: "3 workflows"
      },
      {
        title: "Test Splitting API rate limit",
        description: "The number of requests that can be made to the Test Splitting API, per minute.",
        default_value: "10,000 requests/min"
      },
      {
        title: "Test ownership file size",
        description: "The maximum size for CODEOWNERS files.",
        default_value: "1 MB"
      },
    ].sort_by { |limit| limit[:title] }.each do |limit| %>
      <tr>
        <td>
          <strong><%= limit[:title] %></strong>
         </td>
        <td>
          <p><%= limit[:description] %></p>
          Default: <strong><%= limit[:default_value] %></strong>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>






## Package Registries limits

The limits in Package Registries apply based on the subscription tier:

<table>
  <thead>
    <tr>
      <th style="width:25%">Service limit type</th>
      <th style="width:75%">Description and default limit</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        title: "Personal plan",
        description: "Allocated storage volume. Hard limit",
        default_value: "1 GB"
      },
      {
        title: "Free (legacy) plan",
        description: "Allocated storage volume. Hard limit",
        default_value: "2 GB"
      },
      {
        title: "Pro plan",
        description: "Allocated storage volume. Usage-based limit",
        default_value: "20 GB"
      },
      {
        title: "Enterprise plan",
        description: "Allocated storage volume. Usage-based limit",
        default_value: "20 GB"
      },
      {
        title: "Managed Enterprise Annual",
        description: "Allocated storage volume. Usage-based limit",
        default_value: "240 GB"
      },
    ].sort_by { |limit| limit[:title] }.each do |limit| %>
      <tr>
        <td>
          <strong><%= limit[:title] %></strong>
         </td>
        <td>
          <p><%= limit[:description] %></p>
          Default: <strong><%= limit[:default_value] %></strong>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Platform and organization-level limits

Organization-level limits are put in place to ensure that Buildkite can provide a reliable service to all customers. These limits are scoped to your organization.

The following table lists the default values for Buildkite's organization-level limits.

<table>
  <thead>
    <tr>
      <th style="width:25%">Service limit type</th>
      <th style="width:75%">Description and default limit</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        title: "Invitations per organization",
        description: "The maximum number of pending invitations for an organization.",
        default_value: "20 invitations"
      },
      {
        title: "REST API rate limit per organization",
        description: "The number of requests an organization can make to Organization endpoints on the REST API, per minute.",
        default_value: "200 requests/min"
      },
      {
        title: "GraphQL API rate limit per organization",
        description: "The number of requests an organization can make to Organization endpoints on the GraphQL API, per minute.",
        default_value: "20,000 requests/min"
      },
      {
        title: "Portal API rate limit per organization",
        description: "The number of requests an organization can make to Organization endpoints on the Portal API, per minute.",
        default_value: "200 requests/min"
      },
      {
        title: "Slack services per organization",
        description: "The maximum number of Slack services that can be added to an organization.",
        default_value: "50 services"
      },
      {
        title: "Teams per organization",
        description: "The maximum number of teams that an organization can have.",
        default_value: "250 teams"
      },
      {
        title: "Maximum OIDC lifetime",
        description: "The default maximum lifetime for OIDC.",
        default_value: "2 hours"
      },
      {
        title: "Webhook services per organization",
        description: "The maximum number of Webhook services that can be added to an organization.",
        default_value: "15 services"
      },
    ].sort_by { |limit| limit[:title] }.each do |limit| %>
      <tr>
        <td>
          <strong><%= limit[:title] %></strong>
         </td>
        <td>
          <p><%= limit[:description] %></p>
          Default: <strong><%= limit[:default_value] %></strong>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Integration service limits

Integration service limits apply to all of the Buildkite products.

| Service | Default per organization |
| --- | --- |
| Event Log API Services | 15 |
| OpenTelemetry Tracing Services | 5 |
| Datadog Pipeline Visibility | 5 |
| AWS EventBridge Services | 1 |
| Linear Services | 1 |

## Hard-coded limits not tied to billing

| Limit | Value | Description |
| --- | --- | --- |
| Max Organizations per User | 20 | User can create max 20 organizations total |
| Max Organizations per Day | 4 | User can create max 4 organizations per day |
| Max Unverified Emails | 5 | Unverified emails per user |
| Max Portal Secrets | 2 | Secrets per portal |
| Max IP Addresses per Token | 24 | IP allowlist entries |
| Max Allowed Teams per Step | 100 | Teams for manual unlock steps |
| Max Cache Size | 128 GB | Cache size for hosted agents |
| Max GraphQL Query Depth | 15 | Query nesting depth |
| Max GraphQL Complexity | 50,000 | Query complexity score |
| Max Annotation Replacements | 10 | Image/link replacements |
| Max Concurrency Key Length | 200 | Concurrency group key length |
| Max Audit Search Terms | 3 | Search term limit |
| Multipart Max Artifacts | 30 | Per upload batch |
| Multipart Max Parts | 10 | Per artifact |
| Asset Upload Max Files | 10 | Files per upload |
| Asset Upload Max Size | 10 MB | Per file |
