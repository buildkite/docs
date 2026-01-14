# Usage limits

Usage limits outlines the usage quotas per product, based on the set limits and subscription tier.

> 📘 Overriding usage limits
> If you are on the Enterprise-tier subscription plan and need to override a service limit, reach out to your dedicated TAM or Buildkite Support to inquire if it is possible.

## Buildkite product limits by plan (subscription tier)

The Trial Plan, Developer Plan, and Personal Plan are considered to be “limited plans” with restricted features.
The Pro Plan has no specific restrictions in terms of features, but usage limits apply.
The Enterprise Plan is the most customizable plan with usage limits that can be potentially be expanded based on the use case.

### Plan-based limits (billing plans)

| Resource | Developer | Personal | Team | Business | Pro | Enterprise |
| --- | --- | --- | --- | --- | --- | --- |
| **Job Minutes** | 5,000-10,000/mo | - | 20,000 base | 40,000 base | 40,000 base | 100,000+ base |
| **Test Executions** | 100,000-175,000/mo | - | 250,000 base | 500,000 base | 500,000 base | 1,000,000+ base |
| **Users** | Unlimited | 1 | Per-user pricing | Per-user pricing | Per-user pricing | 30+ included |
| **Job Concurrency** | Unlimited | **3** | Unlimited | Unlimited | Unlimited | Unlimited |

### Plan-variable service quotas

| Quota | Personal Plan | Paid/Enterprise |
| --- | --- | --- |
| **Build Retention** | 90 days | 365 days |
| **Clusters per Org** | 1 (limited plans only) | Unlimited |
| **Invitations** | 20 (free) | 100 (paid), 2000 (managed/enterprise) |
| **Job Timeout** | **4 hours max** | Unlimited |
| **Test Engine Workflows per Suite** | 1 | 3 (Pro/Enterprise) |

### Hosted agents limits

The following limits apply to the [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted).

#### Concurrency limits

| Plan Type | Linux Concurrency | macOS Concurrency |
| --- | --- | --- |
| Personal | 3 | - |
| Trial | 10 | 3 |
| Paid | 20 | 5 |
| Staff | 1 | 1 |

#### Minutes limits (per month)

| Plan Type | Linux Minutes | macOS Minutes |
| --- | --- | --- |
| Personal | 550 | - |
| Trial | 2,000 | 3,000 |
| Paid | 900,000 | 250,000 |

### Model provider spend limits (in USD)

| Provider | Trial Period | Paying Customers | Maximum Override |
| --- | --- | --- | --- |
| **Anthropic** | $50 | $1,000 | $50,000 |
| **OpenAI** | $50 | $1,000 | $50,000 |

### Universal service quotas

These quotas apply to all plans by default but can be customized per organization.

#### Build and job limits

| Quota | Default | Maximum |
| --- | --- | --- |
| Jobs per Build | 4,000 | 70,000 |
| Jobs per Upload | 500 | - |
| Step Uploads per Build | 500 | - |
| Matrix Jobs per Step | 50 | - |

#### Artifact limits

| Quota | Default | Maximum |
| --- | --- | --- |
| Artifacts per Job | 5,000 | - |
| Single Artifact Size | 10 GB | - |
| Artifact Batch Size | 50 GB | - |
| Artifact Retention | 180 days | 180 days |

#### Log limits

| Quota | Default | Maximum |
| --- | --- | --- |
| Log Size per Job | 1 GB | 100 GB |
| Log Chunk Interval | 1 second | 60 seconds |

#### Organization limits

| Quota | Default | Maximum |
| --- | --- | --- |
| Teams per Org | 250 | - |
| Queues per Cluster | 50 | Unlimited |
| Stacks (Agent Templates) | 30 | - |

#### Trigger limits

| Quota | Default |
| --- | --- |
| Max Trigger Build Depth | 10 |
| Triggered Builds per Build | 250 |

#### Security limits

| Quota | Default |
| --- | --- |
| Max OIDC Lifetime | 2 hours |

### API rate limits

| API | Default (requests/min) |
| --- | --- |
| GraphQL API | 20,000 |
| REST API | 200 |
| Portal API | 200 |
| Test Splitting API | 10,000 |
| Artifact Create/Update | 600 |

### Integration service limits

| Service | Default per organization |
| --- | --- |
| Slack Services | 50 |
| Webhook Services | 15 |
| Event Log API Services | 15 |
| OpenTelemetry Tracing Services | 5 |
| Datadog Pipeline Visibility | 5 |
| AWS EventBridge Services | 1 |
| Linear Services | 1 |

### Hosted agents cache volume limits

| Volume type | Default size |
| --- | --- |
| Container Cache Volume | 50 GB |
| Git Mirror Volume | 5 GB |

### Service limits - enforcement status

When a service limit is reached, you might be notified and/or limitations might take effect. Here is what you should expect when you are reaching the limits.

#### Actively enforced billing limits

| Billing resource | Behavior |
| --- | --- |
| **Job Minutes** | Jobs stop dispatching when limit reached |
| **Test Executions** | Uploads rejected with 403 Forbidden |
| **Packages Storage** | Package uploads blocked |
| **Users (Personal Plan)** | Invitations blocked |
| **Job Concurrency (Personal)** | Jobs queued/limited |
| **Job Timeout (Limited Plans)** | Capped at 4 hours |
| **Clusters (Limited Plans)** | Limited to 1 cluster |

#### Billing limits - soft enforcement (warnings or notifications)

| Billing Resource | What Happens |
| --- | --- |
| **Job Minutes** | Warning emails will be sent to Organization Admins at 80%, 90%, 100% thresholds |
| **Test Executions** | Warning emails only |
| **Users** | Warning emails for approaching limits |

## Features without direct enforcement (UI-only gating)

These features are available based on plan but the code doesn’t actively block usage if feature is removed:

| Feature | Notes |
| --- | --- |
| Audit Logging | UI hidden but data still collected |
| Pipeline Templates | Can still use existing templates |
| Cluster Insights | Dashboard visibility only |

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

## Service quotas

Service quotas are put in place to ensure that Buildkite can provide a reliable service to all customers. These quotas are scoped to your organization, and can be increased by emailing Support at [support@buildkite.com](mailto:support@buildkite.com) and providing details about your use case.

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
        title: "Artifacts per job",
        description: "The maximum number of artifacts that can be uploaded to Buildkite per job.",
        default_value: "250,000 artifacts"
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
