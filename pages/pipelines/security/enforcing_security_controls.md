# Enforcing security controls

This is a practical guide for security engineers that provides a list of common risks and proven prevention and mitigation strategies across key areas of the Buildkite ecosystem. The guide covers secrets management, supply chain security, artifact storage reliability, and platform hardening.

Use this as your reference for building a defensible, auditable, and resilient CI/CD foundation with Buildkite.

## Authentication and session security in the Buildkite UI, CLI, and API

**Risk:** Unauthorized access through credential compromise, user impersonation, session hijacking, overprivileged API keys.

**Controls:**

- Enforce [Single Sign-On (SSO)](/docs/platform/sso) and [Two-Factor Authentication (2FA/MFA)](/docs/platform/team-management/enforce-2fa) for all UI access.
- Use time-scoped API tokens with [automated rotation](/docs/apis/managing-api-tokens#api-access-token-lifecycle-and-security).
- Apply least privilege principle when [scoping API keys](/docs/apis/managing-api-tokens#token-scopes).
- [Restrict API tokens to specific IP ranges](/docs/apis/managing-api-tokens#limiting-api-access-by-ip-address) where possible.

## Source code security and version control integrity

**Risk:** Compromised repository access, unsigned commits, unauthorized branch access.

**Controls:**

- Use the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for secure repository connections.
- Enforce [SCM signed commits](https://buildkite.com/resources/blog/securing-your-software-supply-chain-signed-git-commits-with-oidc-and-sigstore/) and [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) with [Buildkite conditionals](/docs/pipelines/configure/conditionals).
- Map Buildkite users to SCM identities with [team-based permissions](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) to ensure only authorized team members can trigger builds.
- Deploy [programmatic team management](/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) and pre-merge hooks to verify commit authors have appropriate permissions before allowing build execution.
- [Disable trigger on fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) for public pipelines and repositories to ensure open source contributors are unable to substantially alter your pipeline to extract secrets. 

## Dependencies and package management

**Risk:** Malicious packages or typosquatted packages that can execute arbitrary code during builds, vulnerable dependencies that persist in packaged images and production deployments.

**Controls:**

- Integrate with a container scanning tool to keep track of Software Bill of Materials (SBOM) of your packages. You can check out the following list of community-maintained [SBOM generation tools](https://github.com/cybeats/sbomgen).
- Use Buildkite's official [Security and compliance plugins](/docs/pipelines/integrations/security-and-compliance/plugins) (or [write your own plugin](/docs/pipelines/integrations/plugins/writing)) to integrate with your existing security scanning infrastructure for source code, container testing, and vulnerability assessment.
- Run automated dependency and malware scanning on every merge using established tools such as [GuardDog](https://github.com/DataDog/guarddog) or [Aqua Trivy](https://www.aquasec.com/products/trivy/).
- Deploy [pipeline templates](/docs/pipelines/governance/templates) to standardize security testing across all of your pipelines.

## Vulnerability management

**Risk:** Unpatched vulnerabilities in production within container images and application code, unknown and compromised dependency risks.

**Controls:**

- Integrate security scanning tools directly into pipelines as mandatory steps that block deployments when critical vulnerabilities are detected. Use [pipeline templates](/docs/pipelines/governance/templates), [plugins](/docs/pipelines/integrations/plugins), [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), and [agent hooks](/docs/agent/v3/hooks) to ensure security scans cannot be bypassed by modifying `pipeline.yml` files.
- Deploy continuous monitoring through automated SBOM generation and vulnerability scanning of production environments. Execute scanners on your agents using pipeline steps to continuously assess deployed components for newly discovered vulnerabilities.
- Track dependencies using [Buildkite Annotations](/docs/agent/v3/cli-annotate) to document exact package versions in each build. This creates an auditable record enabling targeted remediation when vulnerabilities are discovered.
- Establish automated response workflows that trigger notifications and remediation processes when critical CVEs are identified.
- Integrate with vulnerability databases and scanning tools like [Trivy](https://trivy.dev/latest/), [Snyk](https://snyk.io/), or cloud security services across your software supply chain.

## Secrets management

**Risk:** Exposed secrets in logs, environment variables, or compromised agents.

**Controls:**

- Use external secrets management by integrating with dedicated [secrets storage services](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service) such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [HashiCorp Vault](https://www.vaultproject.io/).
- Implement secrets management through [exporting secrets with environment hooks](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks) for agent-level secrets rather than injecting them at build runtime where applicable. Otherwise - configure your secrets to be injected at runtime rather than stored as static environment variables.
- Leverage [Buildkite scoped secrets](/docs/pipelines/security/secrets/buildkite-secrets) to ensure that secrets are only available where explicitly required. Note that Buildkite [automatically redacts secrets](/docs/pipelines/security/secrets/buildkite-secrets#redaction) in logs.
- Establish environment-specific cluster and queue segmentation of your builds to scope and restrict access to the secrets so that the builds in a queue can only access the secrets they require to run.
- Establish incident response procedures for secret compromise, including automated revocation and rotation processes. Note that cluster maintainers can [revoke tokens](/docs/agent/v3/tokens#revoke-a-token) using the REST API for rapid containment.
- Monitor secret access activities within your CI/CD environment through [Audit Log](/docs/platform/audit-log).
- Deploy additional scanning tools such as [git-secrets](https://github.com/awslabs/git-secrets) to prevent accidental committing of secrets to the source code repositories before they enter the build process.
- Consider using strict pipeline upload guards, such as [reject-secrets](/docs/agent/v3/cli-pipeline#reject-secrets) option for `buildkite-agent pipeline upload` commands.

## Buildkite Agent security

**Risk:** Buildkite Agent compromise leading to privilege escalation, lateral movement, data access, malicious code execution.

**Controls:**

- Isolate sensitive builds in dedicated [agent pools within Clusters](/docs/pipelines/clusters), ensuring that critical workloads cannot be affected by compromise of less secure environments.
- Set granular command authorization controls for what the `buildkite-agent` user is allowed to run, restricting executable operations to predefined security parameters.
- Deploy ephemeral build environments using isolated virtual machines or containers with minimal operating systems, disabled inbound SSH access, and strict network egress controls.
- Enable [pipeline signing](/docs/agent/v3/signed-pipelines) and verification mechanisms.
- Configure automated regular credential rotation or even set [automatic expiration date](/docs/agent/v3/securing#set-the-agent-token-expiration-date) on agent registration tokens to limit the window of opportunity for compromised tokens.
- Set appropriate [job time limits](/docs/pipelines/configure/build-timeouts#command-timeouts) to limit the potential duration of malicious code execution on compromised agents.
- Utilize [OIDC-based authentication for AWS](/docs/pipelines/security/oidc/aws) to establish secure, short-lived credential exchange between agents and cloud infrastructure, leveraging session tags to add strong unique claims.
- [Disable command evaluation](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-disable-command-evaluation) where appropriate and enforce script-only execution instead.
- Check out [Securing your Buildkite Agent](/docs/agent/v3/securing) documentation page which has many specific recommendations for making your virtual machine or Docker container running the `buildkite-agent` process more secure in the context of running your CI/CD pipelines.

> 📘 Additional information on better Buildkite Agent security
> For small teams with limited experience in hosting and hardening infrastructure, [hosted agents](/docs/pipelines/hosted-agents) provide a secure, managed solution that reduces operational overhead. However, organizations with stringent Governance, Risk, and Compliance (GRC) requirements that mandate enhanced security postures should deploy [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture) for their most sensitive workloads, as this approach offers greater control over the security configuration and compliance controls.

## API Access Token compromise

**Risk:** Compromised or overprivileged Buildkite API access tokens enabling unauthorized pipeline access, code execution, and data theft.

**Controls:**

- Create tokens with minimal [required scopes](/docs/apis/managing-api-tokens#token-scopes) only. Use [Portals](/docs/apis/portals) to limit GraphQL query scope. Review permissions regularly to match current needs.
- Establish [token rotation](/docs/apis/managing-api-tokens#api-access-token-lifecycle-and-security) with defined expiration periods. Automate rotation where possible to limit exposure windows.
- Bind tokens to specific IP addresses or network segments. Use Network Address Translation (NAT) with centralized egress routing for enhanced monitoring and rapid compromise detection.
- Deploy tokens within dedicated VPCs using [Buildkite’s Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/security#network-configuration) for network isolation.
- Monitor token usage patterns through [Audit Logs](/docs/platform/audit-log). Set up alerts on unusual patterns: unexpected locations, excessive API calls, unauthorized resource access.

## Network and transport security

**Risk:** Interception of traffic between agents, the Buildkite API, and artifact storage; data tampering, exposure, unauthorized external communications potentially allowing malicious code injection.

**Controls:**

While Buildkite enforces TLS encryption by default for all platform communications, ensuring traffic to and from Buildkite services is encrypted in transit, you can take these additional steps to further tighten network security:

- For [self-hosted agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture), implement zero-trust architecture with least-privilege egress rules.
- Monitor network traffic for anomalies or suspicious connection attempts from build agents.
- Consider taking your infrastructure fully into the cloud with the help of [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture) or by running your agents in [AWS](/docs/agent/v3/aws) or in [Google Cloud](/docs/agent/v3/gcloud).
- Harden your cloud infrastructure perimeter by using [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html) or [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html) for the AWS services, or [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access) for Google Cloud.

## Artifact storage and integrity

**Risk:** Artifact tampering, data exfiltration, compromised deployments.

**Controls:**

- Enforce encryption at rest and in transit when storing and transferring your build artifacts.
- Use cloud storage for storing your build artifacts, for instance - [Buildkite Package Registries](https://buildkite.com/platform/package-registries/). Other supported private cloud storage options include:
  * [AWS S3 buckets](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket)
  * [Google Cloud Storage buckets](/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket)
  * [Azure Blob containers](/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container)
- Implement artifact signing using [SLSA/in-toto provenance](/docs/package-registries/security/slsa-provenance) or [cosign](https://github.com/sigstore/cosign) and establish verification processes before deployment to document artifact provenance and detect tampering.
- Enforce [KMS signing](/docs/agent/v3/signed-pipelines#aws-kms-managed-key-setup) of the stored artifacts.

## Consistent pipeline-as-code approach

**Risk:** Inconsistent security implementations across teams and projects within your Buildkite organization, creating undetected security blind spots and gaps.

**Controls:**

- Adopt an [Infrastructure as Code (IaC)](https://aws.amazon.com/what-is/iac/) approach that restricts administrative access to pipeline configuration, treating the Buildkite interface as read-only for pipeline execution while maintaining all configuration changes through version-controlled code review processes.
- Implement change management controls with mandatory peer review for all pipeline creation, modification, and deletion operations, incorporating dependency scanning requirements. We recommend that you mandate the exclusive use of the [Buildkite Terraform provider](https://buildkite.com/resources/blog/manage-your-ci-cd-resources-as-code-with-terraform/) for all pipeline configuration management, implementing a mandatory two-reviewer approval process for infrastructure changes.

> 📘 Additional information on using Buildkite Terraform provider for better security
> Organizations operating without Terraform governance and peer review protocols are fundamentally compromising their security posture. The suggested approach is to create a service account that is not tied to any specific user identity using your identity provider, utilize Buildkite's RBAC capabilities to prohibit any changes in your pipelines, tokens, etc., and use this account's API key to perform any changes in Terraform using Buildkite Terraform provider by utilizing [GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops).

- Establish a "break glass" protocol that is tied to your SIEM alerts in case someone has to make manual modifications to Buildkite's systems outside of the automated workflow.
- Establish zero-tolerance policies for manual pipeline overrides, with any unauthorized modifications triggering immediate alerts within your Security Information and Event Management (SIEM) system to ensure rapid incident response and maintain configuration integrity.
- Deploy agent-level [lifecycle hooks](/docs/agent/v3/hooks#agent-lifecycle-hooks) as they cannot be bypassed or avoided through modifying a `pipeline.yml` or other developer-level code changes. You can also customize the hooks to scan your `pipeline.yml` files to validate their shape and contents and ensure that those files conform to your Buildkite organization's security requirements.
- Use ephemeral Buildkite agents (like the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s)) or tools like [Ansible](https://docs.ansible.com/) or [Puppet](https://www.puppet.com/blog/puppet-cicd) to force configuration changes on persistent hosts.
- Mandate comprehensive security scanning (including container vulnerability and static code analysis scanning) and SBOM generation for all builds.
- Restrict plugin usage to [private](/docs/pipelines/integrations/plugins/using#plugin-sources) or [version-pinned](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) plugins to prevent supply chain attacks and ensure reproducible builds with known, vetted components.
- Utilize only [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/).
- Scope pipelines to specific [agent queues](/docs/agent/v3/queues#setting-an-agents-queue) to maintain separation between environments and prevent unauthorized access across build processes.
- Use permission models to [target appropriate agents](/docs/pipelines/configure/defining-steps#targeting-specific-agents) for builds, ensuring sensitive workloads run only on designated, secured infrastructure.
- Consider using [pipeline templates](/docs/pipelines/governance/templates) to ensure every pipeline in your Buildkite organization inherits predetermined configurations and maintains consistent baseline protections.

## Monitoring, anomaly detection, logging

**Risk:** Insufficient monitoring and logging resulting in undetected malicious activity, delayed incident response, and prolonged exposure to security threats within your CI/CD environment.

**Controls:**

- Export or stream all Buildkite metrics to your preferred monitoring and observability platform to maintain visibility across your CI/CD pipeline activities (you might want to check out the [OpenTelemetry integration capabilities in Buildkite](/docs/pipelines/integrations/observability/opentelemetry)).
- Set up [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) to consume Buildkite's [Audit Log](/docs/platform/audit-log) and integrate that information with your Security Information and Event Management (SIEM) system.
- Monitor logs for anomalies (unusual IPs, secret access patterns, build frequency spikes) and configure automated alerts.

## Incident response and recovery

**Risk:** Security incidents involving leaked secrets, compromised credentials, or unauthorized access to build environments.

**Controls:**

- Contact Buildkite Support immediately upon discovering any security incident: [support@buildkite.com](mailto:support@buildkite.com). [Enterprise Premium Support](https://buildkite.com/pricing/#premium-support) customers can report an incident through their Premium Support channel. Early notification allows Buildkite to assist with immediate remediation steps.
- Buildkite's incident response team can [audit access logs](/docs/platform/audit-log) to identify which users and IP addresses accessed builds containing leaked information. For Enterprise tier organizations, older logs can be rehydrated for in-depth forensic analysis.

## Further questions

If you didn't find coverage of a security-related question that interests you here, feel free to raise it on the [Buildkite Community Forum](https://forum.buildkite.community/) or reach out to the [Buildkite's Support Team](mailto:support@buildkite.com).
