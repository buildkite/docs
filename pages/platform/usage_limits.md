# Usage limits

Usage limits outlines the usage quotas per product, based on the set limits and subscription tier.

Limits can only be overridden for Enterprise-tier users, in case that is possible.

> 📘 Overriding usage limits
> If you are on the Enterprise-tier subscription plan and need to override a service limit, reach out to your dedicated TAM or Buildkite Support to inquiry whether it is possible.

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
