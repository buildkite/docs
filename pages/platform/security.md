# Security overview

Securing your Buildkite organization means controlling who can change your builds, what code your agents run, and which credentials and systems that code can access. This section helps you plan those protections, configure them, and check that they work.

Buildkite secures its services. Your organization configures access and protects its workloads. The [shared responsibilities](#shared-responsibility) below explain how that division changes between Buildkite hosted and self-hosted agents.

If you suspect an active compromise, go directly to [Incident response](/docs/platform/security/incident-response).

<a id="where-to-start"></a>
<a id="start-with-what-you-need-to-protect"></a>

## Find your starting point

- **Plan your controls:** [Choose controls for your risk profile](/docs/platform/security/risk-profiles) to prioritize protections based on the code, data, and systems each workload can reach.
- **Configure a new pipeline:** Follow [Secure your first production pipeline](/docs/platform/security/first-production-pipeline) for a starting configuration with a verification check after each step.
- **Review an existing setup:** Work through the [Security checklist](/docs/platform/security/checklist), starting with baseline controls across eight security areas. It includes separate hosted and self-hosted agent controls.
- **Make controls mandatory:** Use [Enforcing security controls](/docs/platform/security/enforcing-security-controls) to place restrictions outside repository-controlled pipeline definitions and test that they cannot be bypassed.
- **Manage credentials:** Use [Token security](/docs/platform/security/tokens) to identify token types, limit their access, and plan expiry and revocation. Use [Secrets management](/docs/pipelines/security/secrets/managing) to provide credentials to builds.
- **Prepare for an incident:** Use [Incident response](/docs/platform/security/incident-response) to assign responders, prepare a runbook, and rehearse recovery.

## Shared responsibility

Buildkite secures the control plane that schedules builds and stores build data. Your organization controls user and token access, source repositories, pipeline definitions, plugins, and the credentials and systems your builds can access. These responsibilities apply to both hosting models.

### Buildkite hosted agents

Buildkite manages the underlying infrastructure, job isolation, and installation and updates of the Buildkite agent. On Linux, Buildkite supplies the agent through the hosted agents Docker layer. Your organization selects and maintains its [agent images](/docs/agent/buildkite-hosted/linux#agent-images), including installed packages, dependencies, and security updates in custom images.

For [macOS hosted agents](/docs/agent/buildkite-hosted/macos), Buildkite maintains the base images and their updates. Your organization chooses the macOS and Xcode versions in each queue's **Base image** settings and reviews those selections as updates become available. Software you add during a job remains your responsibility.

Your organization also configures queue access, secrets, network access to your services, and whether to enable interactive access to jobs. A managed agent doesn't make untrusted build code safe to run with production credentials.

### Self-hosted agents

Your organization provisions, secures, and maintains the [agent infrastructure](/docs/agent/self-hosted/security), including operating systems, images, installed tools, agent updates, network boundaries, and agent tokens. You can enforce agent-controller settings and hooks that aren't available on Buildkite hosted agents.

<a id="infrastructure"></a>
<a id="data-encryption"></a>
<a id="user-logins"></a>
<a id="software-dependencies"></a>
<a id="code-review-and-testing-process"></a>
<a id="development-and-qa-environments"></a>
<a id="penetration-testing"></a>

For Buildkite infrastructure security, encryption, security testing, and assurance reports, see [Security at Buildkite](https://buildkite.com/about/security/).

## Data flow

<%= image_tag vite_asset_path("images/pipelines/security/data-flow.png"), alt: "Build data flows between customer-controlled source control and source code, the Buildkite-managed control plane, agents whose responsibility depends on hosting, and an artifact store whose responsibility depends on storage choice", class: "no-decoration" %>

The diagram shows the systems involved in a typical build:

1. Buildkite Pipelines receives a webhook from your source control system when code changes.
1. An agent, hosted by Buildkite or by your organization, receives and accepts a job.
1. The agent checks out source code and runs the job with the access you've configured.
1. The agent sends job logs to Buildkite and uploads artifacts to Buildkite-managed storage or your configured artifact store.
1. The agent reports the result, and Buildkite Pipelines posts a status update to your source control system.

Your choice of agent hosting and artifact storage determines which infrastructure you manage. Use the [Security checklist](/docs/platform/security/checklist) to review controls at each point in this flow.
