---
template: "landing_page"
---

# The Buildkite platform

Buildkite is an adaptable, composable, and scalable platform with everything platform teams need to build software delivery systems for their businesses—and rapidly deliver value to users.

The Buildkite platform documentation contains docs for _common_ features of Buildkite available across Buildkite [Pipelines](/docs/pipelines), [Test Engine](/docs/test-engine), and [Package Registries](/docs/package-registries). This area of the docs covers the following topics:

<table>
  <thead>
    <tr>
      <th>Topic</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        topic: "[Team management](/docs/platform/team-management)",
        description: "Guidelines on how to manage your users and teams across the Buildkite platform for Pipelines, Test Engine, and Package Registries."
      },
      {
        topic: "[Audit log](/docs/platform/audit-log)",
        description: "Details on how to access the audit log within Buildkite, and all the events that are logged by this feature."
      },
      {
        topic: "[Emojis](/docs/platform/emojis)",
        description: "Emojis that can be used in your pipelines, test suites, and platform, to help you distinguish them."
      },
      {
        topic: "[Buildkite CLI](/docs/platform/cli)",
        description: "Command line/terminal access to work with features across the Buildkite platform."
      },
      {
        topic: "[Terraform provider](/docs/platform/terraform-provider)",
        description: "Manage your Buildkite organization's resources using Terraform infrastructure-as-code workflows."
      },
      {
        topic: "[Single sign-on (SSO)](/docs/platform/sso)",
        description: "Guidelines on how to protect access to your Buildkite organization using a supported third-party SSO provider."
      },
      {
        topic: "[Security](/docs/platform/security/tokens)",
        description: "Security-related topics relevant to the entire Buildkite platform."
      },
      {
        topic: "[Integrations](/docs/platform/integrations/slack-workspace)",
        description: "Integrations with the Buildkite platform that function across multiple Buildkite products."
      },
      {
        topic: "[Accessibility](/docs/platform/accessibility)",
        description: "Accessibility features available across the Buildkite web application, including theme options, keyboard navigation, screen reader support, and reduced motion."
      },
      {
        topic: "[Limits](/docs/platform/limits)",
        description: "Default service quota values and how you can alter these if required."
      },
      {
        topic: "[Pricing and plans](/docs/platform/pricing-and-plans)",
        description: "An overview of the available Buildkite plans and links to detailed pricing information."
      },
      {
        topic: "[Service level agreement](/docs/platform/service-level-agreement)",
        description: "Details on Buildkite's availability commitments and a link to the status page."
      },
      {
        topic: "[Legal and policies](/docs/platform/legal-and-policies)",
        description: "Terms of service and other legal documents that govern the use of the Buildkite platform."
      }
    ].each do |row| %>
      <tr>
        <td><%= render_markdown(text: row[:topic]) %></td>
        <td><%= render_markdown(text: row[:description]) %></td>
      </tr>
    <% end %>
  </tbody>
</table>
