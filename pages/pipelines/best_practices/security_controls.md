# Enforcing security controls

This guide helps security engineers identify common risks and implement proven prevention and mitigation strategies across key areas of the Buildkite ecosystem. The guide covers secrets management, supply chain security, artifact storage reliability, and platform hardening.

Use this guide as a reference for building a defensible, auditable, and resilient CI/CD foundation with Buildkite.

## Authentication and session security in the Buildkite interface, APIs and CLI

**Risk:** Unauthorized access through credential compromise, user impersonation, session hijacking, overprivileged API keys.

**Controls:**

- Enforce either [Single sign-on (SSO)](/docs/platform/sso) or [Two-factor authentication (2FA/MFA)](/docs/platform/team-management/enforce-2fa) for all access to the Buildkite interface.
- Use time-scoped API tokens with [automated rotation](/docs/apis/managing-api-tokens#api-token-security-rotation).
- Apply least privilege principle when [scoping API keys](/docs/apis/managing-api-tokens#token-scopes).
- [Restrict API tokens to specific IP ranges](/docs/apis/managing-api-tokens#limiting-api-access-by-ip-address) where possible.

## Source code security and version control integrity

**Risk:** Compromised repository access, unsigned commits, unauthorized branch access.

**Controls:**

- Use the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for secure repository connections.
- Enforce [SCM signed commits](https://buildkite.com/resources/blog/securing-your-software-supply-chain-signed-git-commits-with-oidc-and-sigstore/) and branch protection rules on [GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) and [GitLab](https://docs.gitlab.com/user/project/repository/branches/protected/) with Buildkite Pipelines [conditionals](/docs/pipelines/configure/conditionals).
- Map Buildkite users to SCM identities with [team-based permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions). Use [agent hooks](/docs/agent/v3/hooks) to ensure only authorized team members can trigger builds. You can also see a [live example](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) to discover how agent hooks operate in builds.
- Utilize [programmatic team management](/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) alongside pre-merge hooks to verify that commit authors have appropriate permissions before allowing build execution.
- [Disable triggering builds on forks](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for public pipelines and repositories to ensure open source contributors are unable to substantially alter a pipeline to extract secrets.

## Dependencies and package management

**Risk:** Malicious or [typosquatted](https://en.wikipedia.org/wiki/Typosquatting) packages that can execute arbitrary code during builds, vulnerable dependencies that persist in packaged images and production deployments.

**Controls:**

- Integrate with a container scanning tool to keep track of a [software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_supply_chain) for your packages. For example, see the following list of community-maintained [SBOM generation tools](https://github.com/cybeats/sbomgen?tab=readme-ov-file#list-of-sbom-generation-tools).
- Use Buildkite's official [security and compliance plugins](/docs/pipelines/integrations/security-and-compliance/plugins) (or [write your own plugin](/docs/pipelines/integrations/plugins/writing)) to integrate with your existing security scanning infrastructure for source code, container testing, and vulnerability assessment.
- Run automated dependency and malware scanning on every merge using established tools such as [GuardDog](https://github.com/DataDog/guarddog), [Snyk](https://snyk.io/), [Aqua Trivy](https://www.aquasec.com/products/trivy/) (also available as a [Trivy Buildkite plugin](https://buildkite.com/resources/plugins/equinixmetal-buildkite/trivy-buildkite-plugin/)), or cloud security services across your software supply chain.
- Use [pipeline templates](/docs/pipelines/governance/templates) (a Buildkite [Enterprise](https://buildkite.com/pricing/) plan-only feature), [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), and [agent hooks](/docs/agent/v3/hooks) to ensure security scans cannot be bypassed by modifying `pipeline.yml` files. Use [pipeline templates](/docs/pipelines/governance/templates) to standardize security testing across all the pipelines in a Buildkite organization.
- Track dependencies using [Buildkite Annotations](/docs/agent/v3/cli-annotate) to document exact package versions in each build. This creates an auditable record enabling targeted remediation when vulnerabilities are discovered.
- Establish automated response workflows that trigger [notifications](/docs/pipelines/configure/notifications) and remediation processes when [critical CVEs](https://www.cve.org/) are identified.

## Secrets management

**Risk:** Exposed secrets in logs, environment variables, or compromised agents.

**Controls:**

- Leverage [Buildkite's secrets plugins](/docs/pipelines/integrations/secrets/plugins) for secrets management and the [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) feature to ensure that secrets are only available where explicitly required. Note that Buildkite [automatically redacts secrets](/docs/pipelines/security/secrets/buildkite-secrets#redaction) in logs.
- Integrate external secrets management using dedicated [secrets storage services](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service) such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [HashiCorp Vault](https://www.vaultproject.io).
- [Export secrets with environment hooks](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks) for agent-level secrets, rather than injecting them at build runtime. If you absolutely have to inject your secrets at runtime, avoid storing them as static environment variables.
- Establish environment-specific [cluster](/docs/pipelines/clusters/manage-clusters) and [queue](/docs/agent/v3/targeting/queues/managing) segmentation of your builds to restrict access so that builds in a queue can only access the secrets they require to run.
- Monitor how secrets are accessed within your CI/CD environment by reviewing the [Audit Log](/docs/platform/audit-log).
- Use additional secret scanning tools such as [git-secrets](https://github.com/awslabs/git-secrets) to prevent accidental commits of secrets to repositories before they enter the build process.
- Consider using strict pipeline upload guards, such as the [reject-secrets](/docs/agent/v3/cli-pipeline#reject-secrets) option for `buildkite-agent pipeline upload` commands.
- Have incident response procedures for secret compromise, including automated revocation and rotation processes. Note that cluster maintainers can [revoke tokens](/docs/agent/v3/self-hosted/tokens#revoke-a-token) using the REST API for rapid containment.

## Buildkite Agent security

**Risk:** Buildkite Agent compromise leading to privilege escalation, lateral movement, data access, malicious code execution.

**Controls:**

- Set [granular command authorization controls](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller) for what the `buildkite-agent` user is allowed to run, restricting executable operations to predefined security parameters.
- Configure automated regular credential rotation, such as setting automatic [expiration dates](/docs/agent/v3/self-hosted/tokens#agent-token-lifetime) on your agent tokens to limit their window of opportunity to be compromised.
- [Upgrade your Buildkite Agents](/docs/agent/v3/installation#upgrade-agents) on a regular basis.
- Deploy ephemeral build environments using isolated virtual machines or containers. Ensure that your deployment environment is secure by installing minimal operating systems, disabling inbound SSH access, and enforcing strict network egress controls.
- Isolate pipelines with sensitive builds to run on dedicated agent pools within their own [cluster](/docs/pipelines/clusters). This way, you're ensuring that critical workloads cannot be affected by compromise of less secure environments—for example, open-source repositories with unverified code.
- Enable [pipeline signing](/docs/agent/v3/signed-pipelines) and verification mechanisms.
- Set appropriate [job time limits](/docs/pipelines/configure/build-timeouts#command-timeouts) to limit the potential duration of malicious code execution on compromised agents.
- Utilize [OIDC-based authentication](/docs/pipelines/security/oidc) to establish secure, short-lived credential exchange between agents and cloud infrastructure, leveraging session tags to add strong unique claims.
- [Disable command evaluation](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-disable-command-evaluation) where appropriate and enforce script-only execution instead.
- Consider using the [`--no-plugins` buildkite-agent start option](/docs/agent/v3/cli-start#no-plugins) to prevent the agent from loading any plugins.
- Learn more about making your virtual machine or container running the `buildkite-agent` process more secure in [Securing your Buildkite Agent](/docs/agent/v3/securing).

> 📘 On better Buildkite Agent security
> For small teams with limited experience in hosting and hardening infrastructure, [Buildkite hosted agents](/docs/pipelines/hosted-agents) provide a secure, fully managed solution that reduces operational overhead. However, organizations with stringent governance, risk, and compliance (GRC) requirements that mandate enhanced security postures, should deploy [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture) for their most sensitive workloads, as this approach offers greater control over security configurations and compliance controls.

## API access token compromise

**Risk:** Compromised or overprivileged Buildkite API access tokens enabling unauthorized pipeline access, code execution, and data theft.

**Controls:**

- Create API access tokens with only the minimal [required scopes](/docs/apis/managing-api-tokens#token-scopes). Use [portals](/docs/apis/portals) to limit GraphQL query scope. Review permissions regularly to match current needs.
- Establish [rotation of access tokens](/docs/apis/managing-api-tokens#api-token-security-rotation) with defined expiration periods. Automate rotation where possible to limit exposure windows.
- Bind access tokens to [specific IP addresses or network segments](/docs/apis/managing-api-tokens#limiting-api-access-by-ip-address). Use network address translation (NAT) with centralized egress routing for enhanced monitoring and rapid compromise detection.
- Deploy access tokens within dedicated virtual private clouds (VPCs) using [Buildkite’s Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#network-configuration) for network isolation.
- Monitor access token usage patterns through the [Audit Log](/docs/platform/audit-log). Set up alerts on unusual patterns: unexpected locations, excessive API calls, unauthorized resource access.
- When using the [Buildkite Model Context Protocol (MCP) server](/docs/apis/mcp-server), preference using the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server) as this MCP server type issues short-lived OAuth access tokens, compared to the local MCP server, which requires you to configure an API access token that can pose a security risk if leaked.

## Network and transport security

**Risk:** Interception of traffic between agents, the Buildkite API, and artifact storage, as well as data tampering, exposure, and unauthorized external communications potentially allowing malicious code injection.

**Controls:**

Buildkite enforces TLS encryption by default for all platform communications, ensuring traffic to and from Buildkite services is encrypted in transit. To further tighten your network security, you can take these additional steps:

- For [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), implement a [zero trust architecture (ZTA)](https://www.ibm.com/think/topics/zero-trust) with least-privilege egress rules.
- Monitor network traffic for anomalies or suspicious connection attempts from build agents.
- Consider taking your infrastructure fully into the cloud with the help of [Buildkite hosted agents](/docs/pipelines/hosted-agents) or by running your agents in [AWS](/docs/agent/v3/aws) or in [Google Cloud](/docs/agent/v3/self-hosted/gcp).
- Harden your cloud infrastructure perimeter using [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html) or [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html) for the AWS services, or [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) for Google Cloud.

## Artifact storage and integrity

**Risk:** Artifact tampering, data exfiltration, compromised deployments.

**Controls:**

- Enforce encryption at rest and in transit when storing and transferring build artifacts.
- Use cloud storage for storing build artifacts. You can use [Buildkite Package Registries](/docs/package-registries/) or other supported private cloud storage options:
  * [AWS S3 buckets](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket)
  * [Google Cloud Storage buckets](/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket)
  * [Azure Blob containers](/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container)
- Implement artifact signing using Buildkite's [SLSA provenance](/docs/package-registries/security/slsa-provenance) feature, or alternatively using [in-toto](https://in-toto.io/) or [cosign](https://github.com/sigstore/cosign), and establish verification processes before deployment to document artifact provenance and detect tampering.
- Enforce [KMS signing](/docs/agent/v3/signed-pipelines#aws-kms-managed-key-setup) of your pipelines.

## Consistent pipeline-as-code approach

**Risk:** Inconsistent security implementations across teams and projects within your Buildkite organization, creating undetected security blind spots and gaps.

**Controls:**

- Adopt an [infrastructure-as-code (IaC)](https://aws.amazon.com/what-is/iac/) approach and mandate the exclusive use of the [Buildkite Terraform provider](https://buildkite.com/resources/blog/manage-your-ci-cd-resources-as-code-with-terraform/) for all pipeline configuration management, implementing a mandatory two-reviewer approval process for infrastructure changes.

    **Note:** Organizations without proper governance and peer review protocols may have gaps in their security posture. The suggested approach is to create a service account for Terraform that is not tied to any specific user identity using your identity provider. Use this account's API key to make changes (in the pipelines, tokens, etc.) in Terraform through the Buildkite Terraform provider, while enforcing Buildkite's role-based access control capabilities and [GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops) workflows.

- Restrict pipeline configuration access to [Buildkite organization administrators](/docs/pipelines/security/permissions#manage-teams-and-permissions-organization-level-permissions) only by [making your pipelines **Read Only** to your teams](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions).
- Set zero-tolerance policies for manual pipeline overrides, with any unauthorized modifications triggering immediate alerts within your [security information and event management (SIEM)](https://en.wikipedia.org/wiki/Security_information_and_event_management) system to ensure rapid incident response and maintain configuration integrity.
- Establish a "break glass" protocol that is tied to SIEM alerts in case someone has to make manual modifications to Buildkite's systems outside of the automated IaC workflow.
- Deploy agent-level [lifecycle hooks](/docs/agent/v3/hooks#agent-lifecycle-hooks) as these cannot be bypassed or avoided through a `pipeline.yml` modification or other developer-level code change. You can also customize the hooks to scan your `pipeline.yml` files to validate their structure and contents, and ensure that those files conform to your Buildkite organization's security requirements.
- Use [ephemeral Buildkite Agents](/docs/pipelines/glossary#ephemeral-agent) (like the Buildkite [Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s)) or tools such as [Ansible](https://docs.ansible.com/) or [Puppet](https://www.puppet.com/blog/puppet-cicd) to force configuration changes on persistent hosts.
- Mandate comprehensive security scanning (including container vulnerability and static code analysis scanning) and [SBOM](https://en.wikipedia.org/wiki/Software_supply_chain) generation for all builds. For instance, use [pipeline templates](/docs/pipelines/governance/templates) to ensure every pipeline in your Buildkite organization inherits predetermined configurations and maintains consistent baseline protections.
- Restrict plugin usage to [private](/docs/pipelines/integrations/plugins/using#plugin-sources) or [version-pinned](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) plugins to prevent supply chain attacks and ensure reproducible builds with known, vetted components.
- Use only [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/).
- Scope pipelines to specific [agent queues](/docs/agent/v3/targeting/queues#setting-an-agents-queue) to maintain separation between environments and prevent unauthorized access across build processes.
- Use permission models to [target appropriate agents](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for builds, ensuring sensitive workloads run only on designated, secured infrastructure.

## Monitoring, anomaly detection, logging

**Risk:** Insufficient monitoring and logging resulting in undetected malicious activity, delayed incident response, and prolonged exposure to security threats within a CI/CD environment.

**Controls:**

- Export or stream all of your Buildkite Pipelines metrics to your preferred monitoring and observability platform to maintain visibility across CI/CD pipeline activities. Learn more about Buildkite Pipelines' observability platform integrations from the **Observability** section of the [Integrations](/docs/pipelines/integrations) page (for example, see the [OpenTelemetry integration capabilities in Buildkite](/docs/pipelines/integrations/observability/opentelemetry)).
- Set up [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) to consume Buildkite's [Audit Log](/docs/platform/audit-log) and integrate that information with your [SIEM](https://en.wikipedia.org/wiki/Security_information_and_event_management) system.
- Monitor logs for anomalies (unusual IPs, secret access patterns, build frequency spikes) and configure automated alerts.

## Incident response and recovery

**Risk:** Security incidents involving leaked secrets, compromised credentials, or unauthorized access to build environments.

**Controls:**

- Contact support@buildkite.com immediately upon discovering any security incident. [Enterprise Premium Support](https://buildkite.com/pricing/#premium-support) customers can report an incident through their priority support channel. Early notification allows Buildkite to assist with immediate remediation steps.
- Buildkite's incident response team can [audit access logs](/docs/platform/audit-log) to identify which users and IP addresses accessed builds containing leaked information. For [Enterprise](https://buildkite.com/pricing/) plan customers, older logs can be rehydrated for in-depth forensic analysis.

## Further questions

If you didn't find coverage of a security-related question that interests you here, feel free to contact support@buildkite.com.
