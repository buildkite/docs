# Security engineer checklist

This guide serves as a an essential security-first map of the Buildkite ecosystem for security engineers. 

Here you will find the failure scenarios and best-practice mitigations for a wide range of topics like leaked secrets, supply-chain tampering, flaky artifact storage, security hardening options, and more.

Think of it as your quick-glance index for turning Buildkite into a defensible, auditable, and resilient CI/CD foundation.

## Source code and version control integrity

**Risk**

- Stolen credentials, unsigned commits, or rogue branches give attackers a foothold in your codebase.

**Remediations**

- Use the [Buildlkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github). TODO provide a brief description of the app.
- Require SCM signed commits / branch-protection checks with buildkite conditionals(TODO NEED LINK).
- Link the Buildkite users in your Buildkite organization to SCM identities as with the help of the [team-based permissions](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) only team members can trigger builds.
- Use [pragrammatic team management](https://buildkite.com/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) and pre-merge hooks to verify that the (TODO author - author of what?) author is on the allowed team.

## Dependencies and package management

**Risk**

- Typosquatted or malicious packages execute during the build; vulnerable libs remain in images.

**Remediations**

- Automated dependency/malware scanning on every merge (e.g., Sonatype TODO - where to link to?, Trivy). You can use our security plugins to integrate with the security scanning you tools you integrate with for source code, container testing.
- Use Buildkite [pipeline templates](https://buildkite.com/docs/pipelines/governance/templates) to ensure security tests run and get reported to as part of every pipeline that runs in Buildkite Pipelines.

## Network and transport security

**Risk**

- Interception of tampering with the traffic between agents, Buildkite API, and artifact storage. 

**Remediations**

- At Buildkite, TLS encryption is used. All the traffic incoming and going out of Buildkite is “encrypted in transit”.
- TODO explicitly write out this for all kinds of cloud-based agents?
- For self-hosted agents, zero-trust and least-privilege outbound egress rules are recommended. 


## Authentication and session security in the Buildkite UI, CLI, and API

**Risk**

- A malicious attacker/impersonator logs into the Buildkite UI or CLI on behalf of a user. As a result, the API keys are over-scoped.

**Remediations**

- Enforce [Single Sign On (SSO)](/docs/platform/sso) and [MFA/2FA](/docs/platform/team-management/enforce-2fa) for the web UI.
- Short-lived, scoped API tokens; rotate automatically/programmatically. (TODO - embed the link https://buildkite.com/docs/agent/v3/tokens#agent-token-lifetime)
- For REST: role-based tokens (TODO - link); for GraphQL: field-level whitelists (“portals”). TODO - portals link, maybe more links


## Secrets management

**Risk**

- The secrets you are using with Buildkite might leak via environemnt variables, in the logs, or a throigh a compromised agent.

**Remediations**

Note - secrets are automatically redacted in logs

- Inject secrets at runtime from a vault/SSM; mask in logs. TODO Links
- Use Buildkite *scoped secrets* (per-pipeline, per-step). TODO Links
- Rotate & revoke on incident; track secret-read events in audit logs. TODO Links
- Use scoped secrets. TODO Links
- GitHub Secret Scanning program - https://docs.github.com/en/code-security/secret-scanning/introduction/about-secret-scanning

## Build agent compromise

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

## Artifact storage & integrity

**Risk**

- The output of the Buildkite builds could be tampered with or exfiltrated.

**Remediations**

- Store artifacts in your own bucket in AWS https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket, GCP https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket, Azure https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container or Artifactory  https://buildkite.com/docs/agent/v3/cli-artifact#using-your-artifactory-instance with bucket-policies you audit, or accept visibility in Buildkite-hosted storage.
- Sign artifacts (SLSA/in-toto provenance TODO - clarify) and verify before deploy. https://buildkite.com/docs/package-registries/security/slsa-provenance


## Pipeline consistency - pipeline-as-code approach

**Risk**

- Each project/team/etc. applies security controls differently. As a result, this consistency drift leads to blind spots.

**Remediations**

- Central *templates* that every pipeline inherits. TODO add links
- Mandatory steps: container scanning, code scanning, SBOM generation. TODO add links
- Signed/version-pinned plugins and Docker images. TODO add links

## Monitoring, anomaly detection & logging


TODO - potentially break these into 2 section

**Risk**

- Suspicious behaviour goes unseen; delayed incident response.

**Remediations**

- Get all builds in Buildkite exported to - todo WHERE
- Stream Buildkite audit logs to your SIEM. TODO add links
- Alerts on unusual IP addresses, secret access, or build-frequency spikes. TODO add links
- Enable comprehensive job, artifact, and secret access logs. TODO add links


## Incident response and recovery

**Risk**

- You found out that you have/had a security incident and your secrets leaked etc.

**Remediations**

- We (Buildkite Support Team, etc - TODO clarify) will help you on each step when you find security leaks in your system. 
- Upon discovering a security incident involving Buildkite products, immediately contact [support@buildkite.com](mailto:support@buildkite.com) or reach out to us from your support channel if you are using Premium Support. An internal security incident will be raised on our side and we will help you remediate it. 
- We will be able to look at which user/ip has accessed builds with the leaked information. If necessary, we will rehydrate the logs and do a comprehensive log audit. It is really important that you let us know as soon as you find out so that we can quickly help you remediate it.

## FAQ

**Question**
_What happens if you find that one of the packages you have has a vulnerability in it?_

**Answer**

You can find out SBOM through either actively scanning their prod environments after deployment, or they are actively scanning their packages during the CI process, *before* deployment.

Through whichever process you found it out, you can use the relevant pipelines with the right version.


> Note
> Didn't find coverage of a security-related question here? 
> Feel free to raise it on the Buildkite Forum or reach out to the Buildkite's Support.


===== 
AI-genearted content 
TODO - review again for useful parts

## Agent Security

### Agent Configuration
- [ ] Review [agent expiry dates](/docs/agent/v3/tokens) and ensure rotation policies are in place
- [ ] Verify agents are running with minimal required privileges
- [ ] Confirm [agent security configuration](/docs/agent/v3/securing) follows organizational standards
- [ ] Validate agent tokens are properly scoped and rotated regularly
- [ ] Review agent queue configurations and access controls

### Agent Environment
- [ ] Ensure agents run in secure, isolated environments
- [ ] Verify agent software is kept up-to-date with latest security patches
- [ ] Confirm agent hosts have proper network security controls
- [ ] Review agent logging and monitoring configurations

## Token Security

### Token Management
- [ ] Audit all active API tokens and their permissions
- [ ] Implement token rotation policies and procedures
- [ ] Review token scoping to ensure minimal necessary permissions
- [ ] Validate token storage and distribution mechanisms
- [ ] Monitor token usage patterns for anomalies

### Access Controls
- [ ] Review user access permissions and roles
- [ ] Validate team permissions align with organizational requirements
- [ ] Ensure proper separation of duties for sensitive operations
- [ ] Confirm pipeline permissions are appropriately scoped

## Security Scans and Testing

### Automated Security Testing
- [ ] Implement security scanning in CI/CD pipelines
- [ ] Configure dependency vulnerability scanning
- [ ] Set up static application security testing (SAST)
- [ ] Enable dynamic application security testing (DAST) where applicable
- [ ] Review and tune security scan configurations for accuracy

### Manual Security Reviews
- [ ] Conduct regular security code reviews
- [ ] Perform pipeline security assessments
- [ ] Review third-party integrations and plugins
- [ ] Assess secrets management practices
- [ ] Validate security incident response procedures

## Cluster and Rules Security

### Cluster Configuration
- [ ] Review cluster security configurations
- [ ] Validate cluster access controls and permissions
- [ ] Ensure cluster isolation and network security
- [ ] Confirm cluster monitoring and logging

### Pipeline Rules
- [ ] Review and validate pipeline rules for security compliance
- [ ] Ensure rules are properly scoped and enforced
- [ ] Monitor rule violations and exceptions
- [ ] Maintain documentation of rule rationale and updates

## Secrets Management

### Secret Configuration
- [ ] Review [secrets management practices](/docs/pipelines/security/secrets/managing)
- [ ] Validate [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) configuration
- [ ] Assess [risk considerations](/docs/pipelines/security/secrets/risk-considerations) for current setup
- [ ] Ensure secrets are not exposed in logs or artifacts
- [ ] Verify proper secret rotation procedures

### Secret Access
- [ ] Review who has access to secrets and secret management systems
- [ ] Validate secret scoping and access controls
- [ ] Monitor secret usage and access patterns
- [ ] Ensure proper secret backup and recovery procedures

## Infrastructure Security

### Environment Security
- [ ] Review build environment security configurations
- [ ] Validate network security controls and segmentation
- [ ] Ensure proper logging and monitoring coverage
- [ ] Confirm backup and disaster recovery procedures

### Compliance and Auditing
- [ ] Conduct regular security audits and assessments
- [ ] Ensure compliance with organizational security policies
- [ ] Maintain security documentation and procedures
- [ ] Review and update security incident response plans

## OIDC and Authentication

### OIDC Configuration
- [ ] Review [OIDC setup](/docs/pipelines/security/oidc) and configuration
- [ ] Validate [OIDC with AWS](/docs/pipelines/security/oidc/aws) integration if applicable
- [ ] Ensure proper token validation and audience configuration
- [ ] Monitor OIDC token usage and authentication flows

### Authentication Security
- [ ] Review multi-factor authentication requirements
- [ ] Validate single sign-on (SSO) configuration
- [ ] Ensure proper session management and timeout policies
- [ ] Monitor authentication logs for anomalies

## Monitoring and Incident Response

### Security Monitoring
- [ ] Implement security event monitoring and alerting
- [ ] Review security logs regularly for suspicious activity
- [ ] Maintain security metrics and reporting
- [ ] Ensure proper log retention and analysis capabilities

### Incident Response
- [ ] Test incident response procedures regularly
- [ ] Maintain up-to-date contact information for security team
- [ ] Ensure proper escalation procedures are documented
- [ ] Review and update incident response playbooks

## Documentation and Training

### Security Documentation
- [ ] Maintain current security procedures and policies
- [ ] Document security configurations and rationale
- [ ] Ensure security knowledge is properly documented and shared
- [ ] Regular review and update of security documentation

### Team Training
- [ ] Provide security awareness training to development teams
- [ ] Ensure security best practices are communicated and followed
- [ ] Conduct regular security training and updates
- [ ] Maintain security contact information and escalation procedures
