# Security engineer checklist

This guide provides security engineers with a comprehensive map of the Buildkite ecosystem, focusing on security-first practices and implementations. It covers critical failure scenarios and proven mitigation strategies across key areas including secret management, supply chain security, artifact storage reliability, and platform hardening.

Use this as your reference for building a defensible, auditable, and resilient CI/CD foundation with Buildkite.

## Source code and version control integrity

**Risk:** Compromised credentials, unsigned commits, or unauthorized branches can provide attackers with direct access to your codebase and build infrastructure.

**Mitigations:**

- Implement the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for secure repository connections.
- Enforce [SCM signed commits](https://buildkite.com/resources/blog/securing-your-software-supply-chain-signed-git-commits-with-oidc-and-sigstore/) and configure [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) with [Buildkite conditionals](/docs/pipelines/configure/conditionals).
- Map Buildkite users to SCM identities and leverage [team-based permissions](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) to ensure only authorized team members can trigger builds.
- Deploy [programmatic team management](https://buildkite.com/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) and pre-merge hooks to verify commit authors have appropriate permissions before allowing build execution.

## Dependencies and package management

**Risk:** Malicious or typosquatted packages can execute arbitrary code during builds, while vulnerable libraries may persist in packaged images and production deployments.

**Mitigations:**

- Implement automated dependency and malware scanning on every merge using established tools such as [Sonatype](https://www.sonatype.com/) or [Trivy](https://trivy.dev/latest/). Leverage Buildkite's official security plugins to integrate with your existing security scanning infrastructure for source code, container testing, and vulnerability assessment.
- Deploy [pipeline templates](docs/pipelines/governance/templates) to standardize security testing across all pipelines, ensuring vulnerability scans are executed and results are properly reported as part of every build process in Buildkite Pipelines.

## Network and transport security

**Risk:** Traffic between agents, the Buildkite API, and artifact storage can be intercepted or tampered with, potentially exposing sensitive data or allowing malicious code injection.

**Mitigations:**

- Buildkite enforces TLS encryption by default for all platform communications, ensuring traffic to and from Buildkite services is encrypted in transit.
- For self-hosted agents, implement zero-trust network architecture with least-privilege outbound egress rules to minimize attack surface and prevent unauthorized external communications.
- Configure network monitoring and logging to detect anomalous traffic patterns or connection attempts from build agents. 

## Authentication and session security in the Buildkite UI, CLI, and API

**Risk:** Unauthorized access through compromised credentials or session hijacking can allow attackers to impersonate legitimate users across Buildkite's UI, CLI, and API. Over-privileged API keys compound this risk by providing broader access than necessary for specific use cases.

**Mitigations:**

- Enforce [Single Sign-On (SSO)](/docs/platform/sso) and [Two-Factor Authentication (2FA/MFA)](/docs/platform/team-management/enforce-2fa) for all web UI access to prevent credential-based attacks.
- Implement time-scoped API tokens with [automated rotation on a regular schedule](https://buildkite.com/docs/apis/managing-api-tokens#api-access-token-lifecycle-and-security) to limit exposure windows and reduce the impact of compromised tokens.
- Apply the principle of least privilege when scoping API keys, granting only the minimum permissions required for each specific function or integration.

## Secrets management

**Risk:** Secrets used within Buildkite environments may be exposed through environment variables, build logs, or compromised agents, potentially granting unauthorized access to sensitive systems and data.

**Mitigations:**

- Implement external secrets management by integrating with dedicated [secrets storage services](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service) such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [HashiCorp Vault](https://www.vaultproject.io/). Configure secrets to be injected at runtime rather than stored as static environment variables.
- Leverage [Buildkite scoped secrets](/docs/pipelines/security/secrets/buildkite-secrets) to limit secret access at both pipeline and step levels, ensuring secrets are only available where explicitly required. Note that Buildkite [automatically redacts secrets](/docs/pipelines/security/secrets/buildkite-secrets#redaction) in logs across the platform.
- Establish immediate incident response procedures for secret compromise, including automated revocation and rotation processes. Cluster maintainers can [revoke tokens](/docs/agent/v3/tokens#revoke-a-token) using the REST API for rapid containment.
- Monitor all secret access activities through [Audit Log](/docs/platform/audit-log) tracking to maintain visibility into when and how secrets are accessed within your CI/CD environment.
- Deploy additional scanning tools such as [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning) to detect accidentally committed secrets in source code repositories before they enter the build process.

## Buildkite Agent compromise

**Risk**

- Privilege escalation or lateral movement from the host running jobs.

**Remediations**

- **Clusters**: isolate high-trust workloads into their own agent pools.
- Choose *hosted agents* (Buildkite-managed) vs. *unhosted* (self-managed) based on data-sensitivity; ensure the one **you** control meets hardening baseline.
- Mitigation: run builds in ephemeral, isolated VMs/containers with the minimal OS, no inbound SSH, and network egress controls.
    - max [job time limits](/docs/pipelines/configure/build-timeouts#command-timeouts) - 
- OIDC-based auth for agents ⇄ cloud IAM. TODO links
- Ephemeral VMs/containers, no inbound SSH, strict egress. TODO links, explanations
- Expiry on agent tokens, signed pipelines. TODO link 1 & 2

## Artifact storage and integrity

**Risk:** Build artifacts can be tampered with or exfiltrated during storage and transit, potentially compromising the integrity of deployments or exposing sensitive build outputs.

**Mitigations:**

- Store artifacts in private, organization-controlled storage with auditable bucket policies rather than relying solely on Buildkite-hosted storage. Supported private storage options include:
  * [AWS S3 buckets](/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket) 
  * [Google Cloud Storage buckets](/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket)
  * [Azure Blob containers](/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container)
  * [JFrog Artifactory instances](/docs/agent/v3/cli-artifact#using-your-artifactory-instance)
- Implement artifact signing using [SLSA/in-toto provenance](/docs/package-registries/security/slsa-provenance) and establish verification processes before deployment to ensure artifact authenticity and detect tampering.

## Consistent pipeline-as-code approach

**Risk:** Inconsistent security implementations across teams and projects within your Buildkite organization can create configuration drift, resulting in security blind spots and gaps that may allow vulnerabilities to persist undetected.

**Mitigations:**

- Deploy standardized [pipeline templates](/docs/pipelines/governance/templates) across your entire Buildkite organization to ensure every pipeline inherits predetermined security configurations and maintains consistent baseline protections.
- Mandate comprehensive security scanning processes including container vulnerability scanning, static code analysis, and Software Bill of Materials (SBOM) generation for all builds. Consider implementing community-maintained [SBOM generation tools](https://github.com/cybeats/sbomgen) to track dependencies and supply chain components.
- Restrict plugin usage to [private](/docs/pipelines/integrations/plugins/using#plugin-sources) or [version-pinned](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) plugins to prevent supply chain attacks and ensure reproducible builds with known, vetted components.
- Utilize only [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/) from trusted sources to reduce the risk of malicious or vulnerable base images entering your build environment.

## Monitoring, anomaly detection, logging

**Risk:** Insufficient monitoring and logging capabilities can allow malicious activity to persist undetected, resulting in delayed incident response and prolonged exposure to security threats within your CI/CD environment.

**Mitigations:**

- Export or stream all Buildkite build data to your preferred monitoring and observability platform to maintain comprehensive visibility across your CI/CD pipeline activities.
- Integrate Buildkite audit logs with your Security Information and Event Management (SIEM) system to centralize security monitoring and enable correlation with other security events.
- Configure automated alerts for suspicious activities including logins from unusual IP addresses, anomalous secret access patterns, and unexpected spikes in build frequency that may indicate compromise or abuse.
- Enable detailed logging for all job executions, artifact access, and secret usage to ensure complete audit trails for security investigations and compliance requirements.

## Incident response and recovery

**Risk:** Security incidents involving leaked secrets, compromised credentials, or unauthorized access to build environments can expose sensitive data and compromise your entire CI/CD pipeline.

**Mitigations:**

- Contact Buildkite Support immediately upon discovering any security incident by emailing [support@buildkite.com](mailto:support@buildkite.com) or through your dedicated Premium Support channel. An internal security incident will be opened to coordinate response efforts.
- Buildkite's security team can [audit access logs](/docs/platform/audit-log) to identify which users and IP addresses accessed builds containing leaked information. When necessary, logs can be rehydrated for comprehensive forensic analysis to determine the full scope of exposure.
- Report incidents as quickly as possible to enable rapid response and containment. Early notification allows Buildkite to assist with immediate remediation steps and help prevent further exposure of sensitive data.

## Frequently asked questions

### What happens if you find that one of the packages you have has a vulnerability in it?

You can find out SBOM through either actively scanning their prod environments after deployment, or they are actively scanning their packages during the CI process, *before* deployment.

Through whichever process you found it out, you can use the relevant pipelines with the right version.

### Didn't find coverage of a security-related question here? 

Feel free to raise it on the [Buildkite Community Forum](https://forum.buildkite.community/) or reach out to the [Buildkite's Support Team]((mailto:support@buildkite.com)).
