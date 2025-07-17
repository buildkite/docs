# Security Engineer

Add intro what is this about

## 1. Source-code & version-control integrity

**Risk**

- Stolen credentials, unsigned commits, or rogue branches give attackers a foothold in your codebase.

**Remediations**

- We recommend you use github app integration [link](https://buildkite.com/docs/pipelines/source-control/github#connecting-buildkite-and-github)
- Require GPG-signed commits / branch-protection checks with buildkite conditionals.
- Link Buildkite users to SCM identities; only team members can trigger builds (Buildkite “team-based permissions”). [link](https://buildkite.com/docs/platform/team-management/permissions#manage-teams-and-permissions-frequently-asked-questions)
- Pre-merge hooks to verify author is in the allowed team. [LINK](https://buildkite.com/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams)

---

## 2. Dependency & package management

**Risk**

- Typosquatted or malicious packages execute during the build; vulnerable libs remain in images.

**Remediations**

- Automated dependency/malware scanning on every merge (e.g., Sonatype, Trivy). You can use our security plugins to integrate with the security scanning you tools you integrate with for source code, container testing.
- Use buildkite templates to ensure security tests run and get reported to as part of every pipeline that runs in buildkite

---

## 3. Network & transport security

**Risk**

- Traffic between agents, Buildkite API, and artifact storage can be intercepted or modified.

**Remediations**

- TLS everywhere (“encrypted in transit”).
- Zero-trust / least-privilege outbound egress rules on self hosted agents.

---

## 4. Authentication & session security (UI / CLI / API)

**Risk**

- Someone logs into the Buildkite UI or CLI on behalf of a user; API keys are over-scoped.

**Remediations**

- Enforce SSO + MFA for the web UI.
- Short-lived, scoped API tokens; rotate automatically.
- For REST: role-based tokens; for GraphQL: field-level whitelists (“portals”).

---

## 5. Secrets management

**Risk**

- Secrets leak via env-vars, logs, or a compromised agent.

**Remediations**

- Inject secrets at runtime from a vault/SSM; mask in logs.
- Use Buildkite *scoped secrets* (per-pipeline, per-step).
- Rotate & revoke on incident; track secret-read events in audit logs.
- Use scoped secrets
- secrets are automatically redacted in logs
- github secret scanning program

---

## 6. Build agent compromise

**Risk**

- Privilege escalation or lateral movement from the host running jobs.

**Remediations**

- **Clusters**: isolate high-trust workloads into their own agent pools.
- Choose *hosted agents* (Buildkite-managed) vs. *unhosted* (self-managed) based on data-sensitivity; ensure the one **you** control meets hardening baseline.
- Mitigation: run builds in ephemeral, isolated VMs/containers with the minimal OS, no inbound SSH, and network egress controls.
    - max job time limits - [https://buildkite.com/docs/pipelines/configure/build-timeouts#command-timeouts](https://buildkite.com/docs/pipelines/configure/build-timeouts#command-timeouts)
- OIDC-based auth for agents ⇄ cloud IAM.
- Ephemeral VMs/containers, no inbound SSH, strict egress.
- Expiry on agent tokens, signed pipelines.

---

## 7. Artifact storage & integrity

**Risk**

- Build outputs are tampered with or exfiltrated.

**Remediations**

- Store artifacts in your own bucket in AWS [https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket](https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-aws-s3-bucket), GCP [https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket](https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-google-cloud-bucket), Azure [https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container](https://buildkite.com/docs/agent/v3/cli-artifact#using-your-private-azure-blob-container) or Artifactory  [https://buildkite.com/docs/agent/v3/cli-artifact#using-your-artifactory-instance](https://buildkite.com/docs/agent/v3/cli-artifact#using-your-artifactory-instance) with bucket-policies you audit, or accept visibility in Buildkite-hosted storage.
- Sign artifacts (SLSA/in-toto provenance) and verify before deploy. [https://buildkite.com/docs/package-registries/security/slsa-provenance](https://buildkite.com/docs/package-registries/security/slsa-provenance)

---

## 8. Pipeline-as-code consistency

**Risk**

- Each project applies security controls differently; drift leads to blind spots.

**Remediations**

- Central *templates* that every pipeline inherits.
- Mandatory steps: container scanning, code scanning, SBOM generation.
- Signed/version-pinned plugins and Docker images.

---

## 9. Monitoring, anomaly detection & logging

**Risk**

- Suspicious behaviour goes unseen; delayed incident response.

**Remediations**

- Get all builds in buildkite exported to
- Stream Buildkite audit logs to your SIEM.
- Alerts on unusual IP addresses, secret access, or build-frequency spikes.
- Enable comprehensive job, artifact, and secret access logs.

---

## 10. Incident response & recovery

**Risk**

- You have a security incident and find that your secrets were leaked etc.

**Remediations**

- We help you out every step on the way when you find security leaks in your system. Contact [support@buildkite.com](mailto:support@buildkite.com) or reach out to us from your support channel if you are using premium support. We raise an internal security incident and help you remediate it. We look at who has accessed builds with the leaked information, rehydrate logs if needed and do a comprehensive audit of the logs. It is really important that you let us know as soon as you find out so that we can quickly help you remediate it.

---

**FAQ**

**What happens if you find that one of the packages you have has a vulnerability in it?**

You can find out SBOM through either actively scanning their prod environments after deployment, or they are actively scanning their packages during the CI process, *before* deployment.

Through whichever process you found it out, you can use the relevant pipelines with the right version.