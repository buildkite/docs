# Infrastructure as Code (IaC) in Buildkite Pipelines

These best practices help you manage Buildkite organizations, pipelines, agents, and security controls entirely as code using Terraform, GitOps principles, and least privilege access.

## Core principles

- **UI is read-only.** Use the dashboard for observability and approvals, never for configuration changes.
- **Code is the source of truth.** Store all Buildkite configuration in version control with PR reviews and automated validation.
- **Prefer OIDC over long-lived secrets.** Use federated identity for agent authentication to cloud providers; rotate API tokens regularly.
- **Enforce least privilege.** Apply minimal permissions at every layer: org roles, team access, queue rules, agent tokens, cloud IAM, secret scope.
- **Design for change.** Use dynamic pipelines, modular Terraform, and progressive rollout (canary queues, approval gates).

## GitOps workflow

- Propose changes via pull requests in a dedicated infrastructure repository
- Validate with automated checks: Terraform plan, YAML schema, policy rules (OPA/Sentinel)
- Require two approvals for production queues, team permissions, or security settings
- Merge triggers Terraform apply via Buildkite pipeline with service account identity
- Split Terraform state by blast radius: `org/`, `clusters/`, `pipelines/`
- Use remote state with locking (S3+DynamoDB, GCS, Terraform Cloud)
- Schedule drift detection jobs via GraphQL API to compare state

## Terraform provider

Use the [Buildkite Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) to manage teams, pipelines, clusters, queues, agent tokens, schedules, and templates.

```hcl
terraform {
  required_providers {
    buildkite = { source = "buildkite/buildkite", version = "~> 1.0" }
  }
}

resource "buildkite_cluster" "shared" {
  name = "shared-ci"
}

resource "buildkite_cluster_queue" "terraform" {
  cluster_id  = buildkite_cluster.shared.id
  key         = "terraform"
  description = "IaC workloads with restricted cloud access"
}

resource "buildkite_pipeline" "svc_a" {
  name       = "svc-a"
  repository = "git@github.com:org/svc-a.git"
  steps      = file(".buildkite/pipeline.yml")

  cancel_intermediate_builds = true
  skip_intermediate_builds   = true
}
```

## RBAC and access

- Use a dedicated service account for Terraform with scoped API token (org management, pipeline write, team management).
- Store tokens in secrets manager (AWS Secrets Manager, Vault); rotate quarterly.
- Define teams and membership in Terraform (`buildkite_team`, `buildkite_team_member`).
- Grant pipeline access per team (`buildkite_team_pipeline`) rather than org-wide.
- Restrict UI write access to platform team; most engineers get read-only.

## Secrets management

- Fetch secrets at runtime via agent hooks (`environment`, `pre-command`) from AWS Secrets Manager, GCP Secret Manager, or Vault.
- Use OIDC plugins: [AWS Assume Role](https://github.com/buildkite-plugins/aws-assume-role-buildkite-plugin), [GCP Workload Identity](https://github.com/buildkite-plugins/gcp-workload-identity-buildkite-plugin).
- Scope by environment and queue—CI builds never access production credentials.
- Use different IAM roles per queue; enable audit logging (CloudTrail, GCP Audit Logs).
- Redact logs for sensitive patterns; automate secret rotation with zero-downtime rollover.

## Agents, clusters, queues

- **Clusters** provide namespace isolation; separate by security zone (CI, prod deploy, compliance)
- **Queues** define targeting and boundaries; separate by trust level, workload type, architecture, environment:
    * `default`: General CI, ephemeral agents
    * `docker`: Containerized builds with DinD
    * `arm64`: ARM/macOS builds
    * `production-deploy`: Restricted, long-lived, audit-logged
- Prefer ephemeral agents (per-job lifecycle) for hermetic builds; autoscale on queue depth
- Maintain purpose-built base images (`builder`, `security-scanner`, `mobile`); rebuild weekly
- Use agent hooks for standardization: load credentials, validate requirements, clean up

## Dynamic pipelines

Generate pipeline YAML at runtime based on changed files, repository structure, or external state.

```bash
#!/bin/bash
# .buildkite/generate-pipeline.sh
buildkite-agent pipeline upload <<YAML
steps:
$(git diff --name-only HEAD~1 | grep "^services/" | cut -d/ -f2 | sort -u | while read svc; do
  echo "  - label: 'Build ${svc}'"
  echo "    command: 'make build SERVICE=${svc}'"
  echo "    agents: { queue: docker }"
done)
YAML
```

- Keep steps small and single-purpose; use explicit `depends_on`.
- Parallelize independent tasks; set `timeout_in_minutes`.
- Use `block` steps for approvals; attach metadata (test results, scan reports).
- Implement progressive rollout: canary queue → smoke tests → approval → production.

## Policy and compliance

- Validate YAML with `buildkite-agent pipeline upload --dry-run`.
- Enforce security policies via OPA: disallow shell injection, require approved images, prevent credential egress.
- Generate SBOMs (Syft, CycloneDX); sign artifacts (Sigstore, GPG).
- Stream audit logs to SIEM; monitor pipeline mods, token creation, permission changes.
- Run conformance checks: prod queues require approvals, agent tokens are scoped.

## Operational excellence

- Monitor queue saturation, wait times (p50/p95/p99), retry rates, failure rates.
- Right-size agents; use spot instances for non-critical workloads.
- Pre-bake dependencies; cache within trust boundaries (S3/GCS with expiry).
- Emit structured logs (JSON) with correlation IDs; use Buildkite annotations for summaries.
- Document runbooks for agent offline, queue saturation, secret rotation failures.

## Terraform safety

- Enable state locking; serialize applies per workspace.
- Require peer review for production changes; post plans as PR comments.
- Use `prevent_destroy` on critical resources.
- Tag state versions; maintain rollback playbooks.
- Test recovery procedures on a regular schedule that makes sense for your Buildkite organization (for example, quarterly).

## FAQ

**Q: How do I keep prod safe?**
Separate prod queues/credentials, require `block` approvals, enforce policy checks, use canary deployments, enable audit logging.

**Q: Do I need dynamic pipelines?**
Yes for conditional logic, change-based execution, and monorepos. Static YAML works for simple repos but plan to evolve.

**Q: Monorepo vs polyrepo?**
Monorepo: Single entry pipeline detects changes, builds affected services. Polyrepo: One pipeline per repo, shared Terraform modules for consistency.
