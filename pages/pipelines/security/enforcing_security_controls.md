# Enforcing security controls

This guide provides security engineers with a list of common risks and proven mitigation strategies across key areas of the Buildkite ecosystem including secret management, supply chain security, artifact storage reliability, and platform hardening.

Use this as your reference for building a defensible, auditable, and resilient CI/CD foundation with Buildkite.

## Authentication and session security in the Buildkite UI, CLI, and API

**Risk:** Unauthorized access through compromised credentials or session hijacking can allow attackers to impersonate legitimate users across Buildkite's UI, CLI, and API. Over-privileged API keys compound this risk by providing broader access than necessary for specific use cases.

**Remediations:**

- Enforce [Single Sign-On (SSO)](/docs/platform/sso) and [Two-Factor Authentication (2FA/MFA)](/docs/platform/team-management/enforce-2fa) for all web UI access to prevent credential-based attacks.
- Implement time-scoped API tokens with [automated rotation on a regular schedule](/docs/apis/managing-api-tokens#api-access-token-lifecycle-and-security) to limit exposure windows and reduce the impact of compromised tokens.
- Apply the principle of least privilege when scoping API keys, granting only the minimum permissions required for each specific function or integration.
- Implement IP-based access controls for API tokens. Link tokens to designated IP addresses or network ranges where practical.

## Source code and version control integrity

**Risk:** Compromised credentials, unsigned commits, or unauthorized branches can provide attackers with direct access to your codebase and build infrastructure.

**Remediations:**

- Implement the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for secure repository connections.
- Enforce [SCM signed commits](https://buildkite.com/resources/blog/securing-your-software-supply-chain-signed-git-commits-with-oidc-and-sigstore/) and configure [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) with [Buildkite conditionals](/docs/pipelines/configure/conditionals).
- Map Buildkite users to SCM identities and leverage [team-based permissions](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) to ensure only authorized team members can trigger builds.
- Deploy [programmatic team management](/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) and pre-merge hooks to verify commit authors have appropriate permissions before allowing build execution.

## Dependencies and package management

**Risk:** Malicious or typosquatted (named in such as way as to take advantage of common misspelling) packages can execute arbitrary code during builds, while vulnerable libraries may persist in packaged images and production deployments.

**Remediations:**

- Use [Buildkite Package Registries](/docs/package-registries) to secure your supply chain and avoid the bottlenecks of poorly managed and insecure dependencies.
- Implement automated dependency and malware scanning on every merge using established tools such as [GuardDog](https://github.com/DataDog/guarddog) or [Aqua Trivy](https://www.aquasec.com/products/trivy/). Leverage Buildkite's official [security and compliance plugins](/docs/pipelines/integrations/security-and-compliance/plugins) to integrate with your existing security scanning infrastructure for source code, container testing, and vulnerability assessment. You can also [write your own plugin](/docs/pipelines/integrations/plugins/writing) to integrate with the security scanning tool of your choice.
- Consider using [pipeline templates](/docs/pipelines/governance/templates) to standardize security testing across all pipelines, ensuring vulnerability scans are executed and results are properly reported as part of every build of every Buildkite Pipeline.


## Vulnerability monitoring and mitigation

**Risk:** Vulnerable packages and dependencies within container images and application code can expose your production environments to known exploits, potentially leading to data breaches, service disruption, or unauthorized system access through unpatched security flaws.

**Remediations:**

- Implement vulnerability scanning during the CI/CD process by integrating security scanning tools directly into your pipelines before deployment occurs. Configure scanning as mandatory pipeline steps that block deployments when critical vulnerabilities are detected. Buildkite Pipelines' features such as [pipeline templates](/docs/pipelines/governance/templates), [plugins](/docs/pipelines/integrations/plugins), [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), and Buildkite Agent [hooks](/docs/agent/v3/hooks) can all be used (independently or combined) to ensure that required security scans cannot be skipped by editing the pipeline.yml on a branch.
- Deploy continuous monitoring of production environments through automated SBOM (Software Bill of Materials) generation and analysis. Use pipeline steps to execute vulnerability scanners on your agents, ensuring all deployed components are continuously assessed for newly discovered vulnerabilities.
- Maintain detailed dependency tracking using [Buildkite Annotations](/docs/agent/v3/cli-annotate) to document exact package versions and dependencies included in each build. This creates an auditable record of all components that enables targeted remediation when vulnerabilities are discovered.
- Establish automated vulnerability response workflows that trigger immediate notifications and remediation processes when critical CVEs are identified in deployed components. Configure pipeline templates to standardize vulnerability scanning across all projects within your organization.
- Integrate with established vulnerability databases and scanning tools such as [Trivy](https://trivy.dev/latest/), [Snyk](https://snyk.io/), or cloud-native security services to ensure complete coverage of known vulnerabilities across your entire software supply chain.

## Secrets management

**Risk:** Secrets used within Buildkite environments may be exposed through environment variables, build logs, or compromised agents, potentially granting unauthorized access to sensitive systems and data.

**Remediations:**

- Implement external secrets management by integrating with dedicated [secrets storage services](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service) such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [HashiCorp Vault](https://www.vaultproject.io/). Configure secrets to be injected at runtime rather than stored as static environment variables.
- Leverage [Buildkite scoped secrets](/docs/pipelines/security/secrets/buildkite-secrets) to ensure that secrets are only available where explicitly required. Note that Buildkite [automatically redacts secrets](/docs/pipelines/security/secrets/buildkite-secrets#redaction) in logs across the platform.
- Implement secrets management though [exporting secrets with environment hooks](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks).
- Establish environment-specific cluster and queue segmentation of your builds or deploys to scope and restrict access to the secrets in such a way that the builds in a queue can only access those secrets they require to run.
- Establish immediate incident response procedures for secret compromise, including automated revocation and rotation processes. Cluster maintainers can [revoke tokens](/docs/agent/v3/tokens#revoke-a-token) using the REST API for rapid containment.
- Monitor all secret access activities through [Audit Log](/docs/platform/audit-log) tracking to maintain visibility into when and how secrets are accessed within your CI/CD environment.
- Deploy additional scanning tools such as [git-secrets](https://github.com/awslabs/git-secrets) to prevent accidental committing of secrets to the source code repositories before they enter the build process.
- Consider strict pipeline upload guards, such as [reject-secrets](/docs/agent/v3/cli-pipeline#reject-secrets) option to your `buildkite-agent pipeline upload` commands.
- Be aware that Buildkite automatically redacts many secrets from job logs, and you can also use [environment hooks](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks) for agent-level secrets rather than injecting them at build runtime where applicable.

## Buildkite Agent compromise

**Risk:** Compromised Buildkite Agents can enable attackers to perform privilege escalation, lateral movement within your infrastructure, access sensitive data, or execute malicious code with the permissions granted to the agent's host system.

**Remediations:**

- Implement workload isolation by segregating high-trust and sensitive builds into dedicated [agent pools within Clusters](/docs/pipelines/clusters), ensuring that critical workloads cannot be affected by compromise of less secure environments.
- Set granular command authorization controls for what the `buildkite-agent` user is allowed to run, restricting executable operations to predefined security parameters. For instance, you can configure `buildkite-agent secret get` access to only authorized secrets for the designated host environment, preventing unauthorized secret retrieval. This security framework mitigates risks associated with compromised hosts and user accounts, blocking malicious activities such as unauthorized pipeline uploads and privilege escalation attempts.
- Deploy ephemeral build environments using isolated virtual machines or containers with minimal operating systems, disabled inbound SSH access, and strict network egress controls to limit the blast radius of potential compromises.
- Evaluate your infrastructure management capabilities and compliance requirements when selecting between agent deployment models. For small teams with limited experience in hosting and hardening infrastructure, [hosted agents](/docs/pipelines/hosted-agents) provide a secure, managed solution that reduces operational overhead. However, organizations with stringent Governance, Risk, and Compliance (GRC) requirements that mandate enhanced security postures should deploy [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture) for their most sensitive workloads, as this approach offers greater control over the security configuration and compliance controls. Contact Buildkite Support by [email](mailto:support@buildkite.com) or through your dedicated Premium Support channel to discuss agent machine hardening strategies and security best practices tailored to your specific compliance framework.
- Implement [pipeline signing](/docs/agent/v3/signed-pipelines) and verification mechanisms to ensure only authorized pipeline configurations can be executed by agents, preventing injection of malicious build steps.
- Configure automated regular credential rotation. Additionally, you can set [automatic expiration date](/docs/agent/v3/securing#set-the-agent-token-expiration-date) on agent registration tokens to limit the window of opportunity for compromised tokens.
- Set appropriate [job time limits](/docs/pipelines/configure/build-timeouts#command-timeouts) to prevent runaway processes and limit the duration that malicious code can execute on compromised agents.
- Utilize [OIDC-based authentication for AWS](/docs/pipelines/security/oidc/aws) to establish secure, short-lived credential exchange between agents and cloud infrastructure, leveraging session tags to add strong unique claims for ensuring that only the expected agents are able to access your cloud infrastructure.
- Consider [disabling command evaluation](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-disable-command-evaluation) and enforcing script-only execution instead.

> Additional information for better Buildkite Agent security
> Please see [Securing your Buildkite Agent](/docs/agent/v3/securing) documentation page which has many specific recommendations for making your virtual machine or Docker container running the `buildkite-agent` process more secure in the context of running your CI/CD pipelines.

## API Access Token compromise

**Risk:** Compromised or overprivileged Buildkite tokens can provide unauthorized access to pipelines, builds, and sensitive data, enabling attackers to execute malicious code, steal secrets, or manipulate CI/CD processes across your organization.

**Remediations:**

- Follow the principle of least privilege by creating tokens with only the [required scopes](/docs/apis/managing-api-tokens#token-scopes) and permissions needed for each use case. Regularly review token permissions to ensure they match current operational needs. For GraphQL, use [Portals](/docs/apis/portals) to scope queries to specific operations.
- Establish [token rotation](/docs/apis/managing-api-tokens#api-access-token-lifecycle-and-security) policies with defined expiration periods for all API tokens and agent registration tokens. Automate rotation processes where possible to reduce the risk of long-lived credential exposure.
- Implement network-based token access controls by binding authentication tokens to specific IP addresses and network segments. Deploy Network Address Translation (NAT) in conjunction with Internet Gateways to establish a centralized egress architecture, routing all requests through a singular IP endpoint to enhance monitoring capabilities and facilitate rapid compromise detection.
- Monitor token usage patterns through [Audit Log](/docs/platform/audit-log) and implement alerting for unusual access patterns, including usage from unexpected locations, excessive API calls, or access to unauthorized resources.

## Network and transport security

**Risk:** Traffic between agents, the Buildkite API, and artifact storage can be intercepted or tampered with, potentially exposing sensitive data or allowing malicious code injection.

**Remediations:**

While Buildkite enforces TLS encryption by default for all platform communications, ensuring traffic to and from Buildkite services is encrypted in transit, you can take these additional steps to further tighten network security:

- For [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), implement zero-trust network architecture with least-privilege outbound egress rules to minimize attack surface and prevent unauthorized external communications.
- Configure network monitoring and logging to detect anomalous traffic patterns or connection attempts from build agents.
- Consider taking your infrastructure fully into the cloud with the help of [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) or by running your agents in [AWS](/docs/agent/v3/aws) or in [Google Cloud](/docs/agent/v3/gcloud). Additionally, you can further harden the perimeter by using [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html) or [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html) for the AWS services, or [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) for Google Cloud.

## Artifact storage and integrity

**Risk:** Build artifacts can be tampered with or exfiltrated during storage and transit, potentially compromising the integrity of deployments or exposing sensitive build outputs.

**Remediations:**

- Enforce encryption at rest and in transit when storing and transferring build artifacts with the help of cloud services with auditable storage policies. You can use [Buildkite Package Registries](https://buildkite.com/platform/package-registries/); other supported private cloud storage options include:
  * [AWS S3 buckets](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket)
  * [Google Cloud Storage buckets](/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket)
  * [Azure Blob containers](/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container)
- Implement artifact signing using [SLSA/in-toto provenance](/docs/package-registries/security/slsa-provenance) or [cosign](https://github.com/sigstore/cosign) and establish verification processes before deployment to ensure artifact authenticity and detect tampering.
- Enforce [KMS signing](/docs/agent/v3/signed-pipelines#aws-kms-managed-key-setup) of the stored artifacts.

## Consistent pipeline-as-code approach

**Risk:** Inconsistent security implementations across teams and projects within your Buildkite organization can create configuration drift, resulting in security blind spots and gaps that may allow vulnerabilities to persist undetected.

**Remediations:**

- Mandate the exclusive use of the [Buildkite Terraform provider](https://buildkite.com/resources/blog/manage-your-ci-cd-resources-as-code-with-terraform/) for all pipeline configuration management, implementing a mandatory two-reviewer approval process for infrastructure changes. Organizations operating without Terraform governance and peer review protocols are fundamentally compromising their security posture. The suggested approach is to create a service account that is not tied to any specific user identity uding your identity provider, utilize Buildkite's RBAC capabilities to prohibit any changes in your pipelines, tokens, etc., and use this account's API key to perform any changes in Terraform using Buildkite Terraform provider by utilizing [GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops). Establish a "break glass" protocol that is tied to your SIEM alerts in case someone has to make manual modifications to Buildkite's systems outside of the automated workflow.


 Establish zero-tolerance policies for manual pipeline overrides, with any unauthorized modifications triggering immediate alerts within your Security Information and Event Management (SIEM) system to ensure rapid incident response and maintain configuration integrity.
- Implement change management controls with mandatory peer review for all pipeline creation, modification, and deletion operations, incorporating dependency scanning requirements. Adopt an [Infrastructure as Code (IaC)](https://aws.amazon.com/what-is/iac/) approach that restricts administrative access to pipeline configuration, treating the Buildkite interface as read-only for pipeline execution while maintaining all configuration changes through version-controlled code review processes.
- Deploy agent-level [lifecycle hooks](/docs/agent/v3/hooks#agent-lifecycle-hooks) as they cannot be bypassed or avoided through modifying a `pipeline.yml` or other developer-level code changes. Since you're controlling the execution environment, agent-level lifecycle hooks enable you to ensure your policies are enforced and can't be circumvented. You can also customize the hooks to scan your `pipeline.yml` files to validate their shape and contents and ensure that those files conform to your Buildkite organization's security requirements.
- Use ephemeral Buildkite agents (for instance, the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s)) or tools like [Ansible](https://docs.ansible.com/) or Puppet to force configuration changes on the hosts if they are persistent.
- Mandate comprehensive security scanning processes including container vulnerability scanning, static code analysis, and Software Bill of Materials (SBOM) generation for all builds. Consider implementing community-maintained [SBOM generation tools](https://github.com/cybeats/sbomgen) to track dependencies and supply chain components.
- Restrict plugin usage to [private](/docs/pipelines/integrations/plugins/using#plugin-sources) or [version-pinned](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) plugins to prevent supply chain attacks and ensure reproducible builds with known, vetted components.
- Utilize only [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/) from trusted sources to reduce the risk of malicious or vulnerable base images entering your build environment.
- Scope pipelines to specific [agent queues](/docs/agent/v3/queues#setting-an-agents-queue) to maintain separation between environments and prevent unauthorized access across build processes.
- Use permission models to [target appropriate agents](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for builds, ensuring sensitive workloads run only on designated, secured infrastructure.
- Consider using [pipeline templates](/docs/pipelines/governance/templates) across your entire Buildkite organization to ensure every pipeline inherits predetermined configurations and maintains consistent baseline protections.

## Monitoring, anomaly detection, logging

**Risk:** Insufficient monitoring and logging capabilities can allow malicious activity to persist undetected, resulting in delayed incident response and prolonged exposure to security threats within your CI/CD environment.

**Remediations:**

- Export or stream all Buildkite metrics to your preferred monitoring and observability platform to maintain visibility across your CI/CD pipeline activities. Consider using [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry) and [OpenTelemetry tracing capabilities in Buildkite Agent](/docs/pipelines/integrations/observability/opentelemetry#opentelemetry-tracing-from-buildkite-agent).
- Integrate Buildkite's audit log with your Security Information and Event Management (SIEM) system to centralize security monitoring and enable correlation with other security events.
- Enable detailed logging for all job executions, artifact access, and secret usage to ensure complete audit trails for security investigations and compliance requirements.
- Monitor audit logs for anomalies or spikes in sensitive and suspicious activities (including logins from unusual IP addresses, anomalous secret access patterns, and unexpected spikes in build frequency, etc.) and configure automated alerts for detection of such activities.

## Incident response and recovery

**Risk:** Security incidents involving leaked secrets, compromised credentials, or unauthorized access to build environments can expose sensitive data and compromise your entire CI/CD pipeline.

**Remediations:**

- Contact Buildkite Support immediately upon discovering any security incident by emailing [support@buildkite.com](mailto:support@buildkite.com). [Enterprise Premium Support](https://buildkite.com/pricing/#premium-support) customers can report an incident through their dedicated Premium Support channel. Early notification allows Buildkite to assist with immediate remediation steps and help prevent further exposure of sensitive data. An internal security incident will be opened by Buildkite to coordinate response efforts.
- Buildkite's incident response team can [audit access logs](/docs/platform/audit-log) to identify which users and IP addresses accessed builds containing leaked information. For Enterprise tier organizations, older logs can be rehydrated for in-depth forensic analysis to determine the full scope of exposure.

> Didn't find coverage of a security-related question here?
> Feel free to raise it on the [Buildkite Community Forum](https://forum.buildkite.community/) or reach out to the [Buildkite's Support Team](mailto:support@buildkite.com).
