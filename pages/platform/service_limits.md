# Service limits

The page outlines and service limits based on the Buildkite's platform limits and usage limits based on your subscription tier. The available subscription tiers are:

- Personal (free plan with low usage limits)
- Trial (30 days of Pro Plan trial)
- Pro
- Enterprise

You can find out more about the available plans and what is included in them in [Pricing](https://buildkite.com/pricing/).

## Service quotas

Service quotas are put in place to ensure that Buildkite can provide a reliable service to all customers. These quotas are scoped to your organization.

> 📘 Overriding service quotas
> If you are on the Enterprise Plan, service quotas might be increased. Reach out to your dedicated TAM or email the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com) and provide the details about your use case to find out if it is possible.

The following table lists Buildkite's default service quota values.

<table>
  <thead>
    <tr>
      <th style="width:25%">Service quota type</th>
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
        title: "Webhook services per organization",
        description: "The maximum number of Webhook services that can be added to an organization.",
        default_value: "15 services"
      },
      {
        title: "Artifact retention",
        description: "The maximum time we'll store artifacts for, in days, before assuming it has been deleted by an S3 Lifecycle rule, which must be configured separately.",
        default_value: "180 days"
      },
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
        title: "Pipeline uploads per build",
        description: "The maximum number of pipeline uploads that can be performed in a single build.",
        default_value: "500 pipeline uploads"
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
        title: "Log size per job",
        description: "The maximum file-size of a job's log (uploaded by an agent to Buildkite in chunks).",
        default_value: "1,024 MiB"
      },
      {
        title: "Log chunk interval",
        description: "The time interval between the log chunks",
        default_value: "1 second"
      }
    ].sort_by { |quota| quota[:title] }.each do |quota| %>
      <tr>
        <td>
          <strong><%= quota[:title] %></strong>
         </td>
        <td>
          <p><%= quota[:description] %></p>
          Default: <strong><%= quota[:default_value] %></strong>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

## Organization-level limits

The following usage limits apply on the Buildkite organization level, regardless of the Buildkite products that you are using.

| Quota | Maximum |
| --- | --- |
| Number of queues per Cluster | 50 |
| Stacks | 30 |
| Max OIDC Lifetime | 2 hours |

## Plan-variable service quotas

Product | Quota | Personal Plan | Pro | Enterprise |
Pipelines | --- | --- | --- | --- |
Pipelines | **Build retention** | 90 days | 90 | 365 days |
Pipelines | **Clusters per Org** | 1 (limited plans only) | Unlimited | Unlimited |
Pipelines | **Job timeout** | 4 hours | Unlimited | Unlimited |
Test Engine | **Test Engine Workflows per Suite** | 1 | 3 | 3 |

## Hosted agents limits

The following limits apply to the [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted).

### Concurrency limits

| Plan Type | Linux Concurrency | macOS Concurrency |
| --- | --- | --- |
| Personal | 3 | - |
| Trial | 10 | 3 |
| Pro | 20 | 5 |
| Enterprise| Custom | Custom |

### Minutes limits (per month)

| Plan Type | Linux Minutes | macOS Minutes |
| --- | --- | --- |
| Personal | 550 | - |
| Trial | 2,000 | 3,000 |

### Hosted agents cache volume limits

| Volume type | Limit |
| --- | --- |
| Container Cache Volume | 50 GB |
| Git Mirror Volume | 5 GB |

## Model provider spend limits

| Provider | Trial Period | Pro/Enterprise |
| --- | --- | --- |
| **Anthropic** | $50 | $1,000 |
| **OpenAI** | $50 | $1,000 |

Note that the prices are provided in USD.

## Universal service quotas

These quotas apply to all plans by default but can be customized per organization.

## API rate limits

| API | Default (requests/min) |
| --- | --- |
| GraphQL API | 20,000 |
| REST API | 200 |
| Portal API | 200 |
| Test Splitting API | 10,000 |
| Artifact Create/Update | 600 |

## Integration service limits

| Service | Default per organization |
| --- | --- |
| Slack Services | 50 |
| Webhook Services | 15 |
| Event Log API Services | 15 |
| OpenTelemetry Tracing Services | 5 |
| Datadog Pipeline Visibility | 5 |
| AWS EventBridge Services | 1 |
| Linear Services | 1 |

## Hard-coded limits not tied to billing

The following limits are limits tied to rational use of the Buildkite platform and are not tied to the billing plan.

| Limit | Value | Description |
| --- | --- | --- |
| Max Organizations per User | 20 | User can create max 20 organizations total |
| Max Organizations per Day | 4 | User can create max 4 organizations per day |
| Max Triggers per Pipeline | 10 | Webhook triggers per pipeline |
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
| Test Ownership File Size | 1 MB | CODEOWNERS file max |
| Multipart Max Artifacts | 30 | Per upload batch |
| Multipart Max Parts | 10 | Per artifact |
| Asset Upload Max Files | 10 | Files per upload |
| Asset Upload Max Size | 10 MB | Per file |
