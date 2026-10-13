# Security

Use this section to secure your Buildkite organization, review its security controls, or respond to a suspected compromise. It brings together guidance for the Buildkite platform, [Buildkite Pipelines](/docs/pipelines), and [Buildkite Package Registries](/docs/package-registries), with links to configuration instructions in each product's documentation.

## Shared responsibility

Buildkite and your organization share responsibility for security:

- **Buildkite:** Secures the control plane that schedules builds and stores build data. For [Buildkite hosted agents](/docs/agent/buildkite-hosted), Buildkite also manages the underlying infrastructure and agent updates.
- **Your organization:** Controls user and token access, the code your builds run, and the credentials and systems those builds can access, regardless of where your agents run.
- **Your organization with self-hosted agents:** Also provisions, secures, and maintains the [agent infrastructure](/docs/agent/self-hosted/security), including agent updates and network boundaries.

The following diagram shows the systems that data flows through when a build runs, and who is responsible for securing each one. Where you store artifacts determines who manages the artifact store. Learn more about each step of this flow, and how Buildkite protects your data, in the [Pipelines security overview](/docs/pipelines/security#data-flow).

<%= image_tag vite_asset_path("images/pipelines/security/data-flow.png"), alt: "Diagram of the data flow between your source control system, Buildkite, the agent, your source code, and the artifact store when a build runs, with each system labeled as customer controlled, Buildkite managed, or dependent on your hosting model or storage choice", class: "no-decoration" %>

The controls your organization is responsible for are listed in [Security best practices](/docs/platform/security/best-practices). Apply at least the baseline controls in each area before connecting production systems.

## Where to start

Cover all of the following areas before you connect production systems. If you're reviewing or auditing an existing Buildkite organization, use them to find the controls to check:

- **Secure your organization setup:** Configure [authentication and access control](/docs/platform/security/best-practices#authentication-and-access-control), including SSO or 2FA, teams, permissions, and API access tokens. Then keep that configuration consistent with [governance and configuration management](/docs/platform/security/best-practices#governance-and-configuration-management).
- **Secure your agents, pipelines, secrets, and network:** Apply the controls for [Buildkite agent security](/docs/platform/security/best-practices#buildkite-agent-security), [pipeline and supply chain integrity](/docs/platform/security/best-practices#pipeline-and-supply-chain-integrity), [secrets management](/docs/platform/security/best-practices#secrets-management), and [network and data exposure](/docs/platform/security/best-practices#network-and-data-exposure).
- **Prepare your organization for incidents:** Set up [monitoring and detection](/docs/platform/security/best-practices#monitoring-and-detection), and complete [incident readiness](/docs/platform/security/best-practices#incident-readiness) by writing a runbook based on [Incident response](/docs/platform/security/incident-response) so that you can contain compromised access, rotate exposed secrets, investigate activity, and recover.

## Security areas

Security controls and documentation are grouped into the following areas, which are the same areas used in [Security best practices](/docs/platform/security/best-practices). Each area links to its controls, and to the documentation for the features those controls use.

<% SECURITY_AREAS['areas'].each do |area| -%>
### <%= area['name'] %>

<%= area['summary'] %> Review the controls for this area in [Security best practices](/docs/platform/security/best-practices#<%= area['anchor'] %>). Related documentation:

<% area['docs'].each do |doc| -%>
- <%= doc %>
<% end -%>

<% end -%>
