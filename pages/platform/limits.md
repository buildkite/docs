# Limits

This page outlines product and platform usage limits based on the Buildkite platform's service limits and your subscription tier. The available subscription tiers are:

- Personal plan
- Trial plan
- Pro plan
- Enterprise plan

You can find out more about the available plans and what is included in them in [Pricing](https://buildkite.com/pricing/).

> 📘 Overriding the limits
> If you are on the Enterprise plan, some of the organization-level limits might be increased for your organization. Reach out to your dedicated Technical Account Manager or email the Buildkite Support Team at [support@buildkite.com](mailto:support@buildkite.com) and provide the details about your use case to find out if increasing the limits it is possible.

## Platform and organization-level limits

Platform and organization-level limits are applied to all Buildkite products and are put in place to ensure that Buildkite can provide a reliable service to all customers. These limits are scoped to your organization.

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
        title: "Organizations per day",
        description: "The maximum number of organizations a user can create per day.",
        default_value: "4 organizations"
      },
      {
        title: "Organizations per user",
        description: "The maximum total number of organizations a user can create.",
        default_value: "20 organizations"
      },
      {
        title: "Unverified emails per user",
        description: "The maximum number of unverified emails per user.",
        default_value: "5 emails"
      },
      {
        title: "Invitations per organization",
        description: "The maximum number of pending invitations for an organization.",
        default_value: "20 invitations"
      },
      {
        title: "Teams per organization",
        description: "The maximum number of teams that an organization can have.",
        default_value: "250 teams"
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
        title: "GraphQL query complexity",
        description: "The maximum complexity score for GraphQL queries.",
        default_value: "50,000"
      },
      {
        title: "GraphQL query depth",
        description: "The maximum nesting depth for GraphQL queries.",
        default_value: "15 levels"
      },
      {
        title: "Audit search terms",
        description: "The maximum number of search terms for audit logs.",
        default_value: "3 terms"
      },
      {
        title: "IP addresses per token",
        description: "The maximum number of IP allowlist entries per token.",
        default_value: "24 addresses"
      },
      {
        title: "Maximum OIDC lifetime",
        description: "The default maximum lifetime for OIDC.",
        default_value: "2 hours"
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

## Buildkite Pipelines limits

The following table lists the default service limits for [Buildkite Pipelines](/docs/pipelines).

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
        description: "The time period after which a running job will time out.",
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
        title: "Concurrency key length",
        description: "The maximum length for concurrency group keys.",
        default_value: "200 characters"
      },
      {
        title: "Build retention",
        description: "How long builds are stored in Buildkite after running.",
        default_value: "90 days on the Personal and Pro plans. 365 days for Enterprise"
      },
      {
        title: "Teams per block step",
        description: "The maximum number of allowed teams for manual unlock steps.",
        default_value: "100 teams"
      },
      {
        title: "Matrix jobs per step",
        description: "The maximum number of matrix jobs in a pipeline step.",
        default_value: "50 jobs"
      },
      {
        title: "Annotation replacements",
        description: "The maximum number of image or link replacements per annotation.",
        default_value: "10 replacements"
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
        title: "Multipart upload artifacts",
        description: "The maximum number of artifacts per upload batch.",
        default_value: "30 artifacts"
      },
      {
        title: "Artifact retention",
        description: "The maximum time we'll store artifacts for, in days.",
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
        description: "The default number of queues that can be created on a single cluster.",
        default_value: "50"
      },
      {
        title: "Portal secrets",
        description: "The maximum number of secrets per portal.",
        default_value: "2 secrets"
      },
      {
        title: "Number of stacks per organization",
        description: "The default number of stacks that can be created per organization.",
        default_value: "30"
      },
      {
        title: "Cache size for hosted agents",
        description: "The maximum cache size for hosted agents.",
        default_value: "128 GB"
      },
      {
        title: "Artifact Create/Update API calls",
        description: "The number of Create or Update requests for artifacts per minute per organization.",
        default_value: "600"
      },
      {
        title: "Slack services per organization",
        description: "The maximum number of Slack services that can be added to an organization.",
        default_value: "50 services"
      },
      {
        title: "Webhook services per organization",
        description: "The maximum number of Webhook services that can be added to an organization.",
        default_value: "15 services"
      },
      {
        title: "Event Log API services per organization",
        description: "The maximum number of Event Log API services that can be added to an organization.",
        default_value: "15 services"
      },
      {
        title: "OpenTelemetry Tracing services per organization",
        description: "The maximum number of OpenTelemetry Tracing services that can be added to an organization.",
        default_value: "5 services"
      },
      {
        title: "Datadog Pipeline Visibility services per organization",
        description: "The maximum number of Datadog Pipeline Visibility services that can be added to an organization.",
        default_value: "5 services"
      },
      {
        title: "AWS EventBridge services per organization",
        description: "The maximum number of AWS EventBridge services that can be added to an organization.",
        default_value: "1 service"
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

The following limits apply to the [Buildkite hosted agents](/docs/agent/v3/buildkite-hosted) used in Buildkite Pipelines.

| Limit type | Trial | Personal | Pro | Enterprise |
| --- | --- | --- | --- | --- |
| **Linux concurrency** | 10| 3 | 20 | Custom |
| **macOS concurrency** | 3 | - | 5 | Custom |
| **Linux minutes, per month** | 2,000 | 550 | usage-based | usage-based |
| **macOS minutes, per month** | 3,000 | not available | usage-based | usage-based |
| **Container cache volume** |  50 GB |  50 GB |  50 GB |  50 GB |
| **Git mirror volume** |  5 GB |  5 GB |  5 GB |  5 GB |

## Test Engine limits

The following table lists the default service limits for [Test Engine](/docs/test-engine).

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
      {
        title: "Linear services per organization",
        description: "The maximum number of Linear integrations that can be added to an organization.",
        default_value: "1 service"
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

## Package Registries limits

The following table lists the default service limits for [Package Registries](/docs/package-registries). The limits in Package Registries are based on the [subscription tier](https://buildkite.com/pricing/):

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
        description: "Allocated storage volume. Hard limit.",
        default_value: "1 GB per month"
      },
      {
        title: "Pro plan",
        description: "Allocated storage volume. Usage-based limit.",
        default_value: "20 GB per month"
      },
      {
        title: "Enterprise plan",
        description: "Allocated storage volume. Usage-based limit.",
        default_value: "Custom, with volume discount"
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
