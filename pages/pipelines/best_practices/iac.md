# Infrastructure as Code (IaC) in Buildkite Pipelines

This page provides recommendations on managing your Buildkite organizations, pipelines, agents, and security controls entirely as code using Terraform, GitOps, and least privilege access principles.

## Core principles

- Treat the interface as read-only - use the [dashboard](/docs/pipelines/dashboard-walkthrough) for observability and approvals, never for configuration changes.
- Store all configurations in version control with PR reviews and automated validation.
- Use [OIDC](/docs/pipelines/security/oidc) over long-lived secrets - authenticate agents to cloud providers with federated identities and rotate API tokens regularly.
- Apply minimal required permissions at every layer ranging from the organization roles, team access to queue rules, agent tokens, cloud IAM, secret scope.
- Consider managing roles and team access with an IaC-supporting [SSO provider](/docs/platform/sso#supported-providers).
- Design for change and scalability. Use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), modular Terraform, and progressive rollouts with canary queues and approval gates.

## GitOps workflow

- Propose changes exclusively using pull requests in a dedicated repository.
- Apply automated checks for validation of your Terraform plan, YAML schema, policy rules (for example, [Open Policy Agent (OPA)](https://www.openpolicyagent.org/) and/or [Sentinel](https://developer.hashicorp.com/sentinel)).
- Require multiple approvals for production queues, team permissions, or security settings. Consider using [block steps](/docs/pipelines/configure/step-types/block-step) to manage permission levels across your organization (for example, create [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions) with or without deploy permissions).
- Trigger `terraform apply` through a Buildkite pipeline with machine user identity on merge.
- Split Terraform state by blast radius: `org/`, `clusters/`, `pipelines/`.
- Use remote state with locking (for example, S3 + DynamoDB, GCS, Terraform Cloud).
- Schedule drift detection jobs via [GraphQL API](/docs/apis/graphql-api).

## Terraform provider

Use the [Buildkite Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) to manage teams, pipelines, clusters, queues, agent tokens, schedules, and templates. If something is created outside Terraform, treat it as drift and import it into the state.

The following example shows basic provider configuration and creates a cluster, queue, and pipeline:

```hcl
terraform {
  required_providers {
    buildkite = { source = "buildkite/buildkite", version = "~> 1.0" }
  }
}

provider "buildkite" {
  organization = "buildkite"

  # Use the `BUILDKITE_API_TOKEN` environment variable so the token is not committed
  # api_token = ""
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

## Role-based access control (RBAC)

- Create a dedicated service account for Terraform with scoped API tokens (for example, tokens scoped to pipeline write permissions or team management).
- Store tokens in secrets manager (for example, [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs), and so on) and rotate quarterly or on a schedule that suits your security posture.
- Define teams and membership in Terraform (`buildkite_team`, `buildkite_team_member`).
- Grant pipeline access per team (`buildkite_team_pipeline`), not org-wide.
- Restrict UI write access to Platform teams while providing most other engineers with read-only access.

## Secrets management

- Fetch secrets at runtime via [agent hooks](/docs/agent/v3/self-hosted/hooks) (`environment`, `pre-command`) from AWS Secrets Manager, GCP Secret Manager, or Vault.
- Use OIDC plugins: [AWS Assume Role plugin](https://buildkite.com/resources/plugins/cultureamp/aws-assume-role-buildkite-plugin/) or [GCP Workload Identity Federation Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin/).
- Scope secrets by environment and queue. Never give CI builds access to production credentials.
- Use different IAM roles per queue and enable audit logging (using AWS CloudTrail or GCP Audit Logs).
- Redact sensitive patterns in logs and automate secret rotation with zero-downtime rollover.

## Agents, clusters, queues

- Separate clusters by security zones (CI, prod deploy, compliance) and queues - by trust level, workload type, architecture, and environment. For example:

    * `default` - general CI with ephemeral agents
    * `docker` - containerized builds with DinD
    * `arm64` - ARM/macOS builds
    * `production-deploy` - restricted, long-lived, audit-logged

- Prefer ephemeral agents for hermetic builds, and autoscale on queue depth. Maintain purpose-built base images (`builder`, `security-scanner`, `mobile`) and rebuild often (for example, weekly).
- Use [agent hooks](/docs/agent/v3/self-hosted/hooks) to load credentials, validate requirements, and clean up.

## Dynamic pipelines

- Generate pipeline YAML at runtime based on changed files, repository structure, or external state. For example:

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

- Keep steps small and single-purpose with explicit `depends_on`.
- Parallelize independent tasks, set timeouts, and use `block` steps for approvals.
- Implement progressive rollouts: canary queue → smoke tests → approval → production.

Learn more about [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

## Terraform safety

- Enable state locking and serialize applies per workspace.
- Require peer review for production changes.
- Use `prevent_destroy` on critical resources.
- Tag state versions, maintain rollback playbooks, and test recovery procedures on a regular basis.

## Policy and compliance

- Validate YAML with `buildkite-agent pipeline upload --dry-run`.
- Enforce security policies: disallow shell injection, require approved images, prevent credential egress.
- Generate SBOMs and sign artifacts (for example, using [Sigstore](https://www.sigstore.dev/), [GPG](https://www.gnupg.org/download/), [OpenSSL](https://www.openssl.org/)).
- Stream audit logs to SIEM and monitor pipeline modifications, token creation, and permission changes.

## Operational excellence

- Monitor queue saturation, wait times (p50/p95/p99), retry rates, and failure rates. You can use [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry) to collect these metrics. Learn more about [Monitoring and observability best practices](/docs/pipelines/best-practices/monitoring-and-observability).
- Right-size agents and use spot instances for non-critical workloads.
- Pre-bake [dependencies](/docs/pipelines/configure/dependencies) and cache within trust boundaries (for example, use S3/GCS with expiry).
- Emit structured logs (JSON) with correlation IDs and use [Buildkite annotations](/docs/agent/v3/cli-annotate) for summaries.
- Document runbooks for common failure scenarios.

## Frequently asked questions (FAQ)

### How do I keep the production environment safe?

Define production queues and permissions in Terraform, separate production queues and credentials, require [block step-based approvals](/docs/pipelines/configure/step-types/block-step#permissions), enforce policy checks, use canary deployments, and enable [audit logging](/docs/platform/audit-log).

### When should I choose monorepo vs multiple repositories?

In the [monorepo approach](/docs/pipelines/best-practices/working-with-monorepos), a single entry pipeline detects changes and builds affected services. In the approach that uses multiple repositories, one pipeline per repository has shared Terraform modules for consistency. Choose according to your operational needs.

### When do I need to use dynamic pipelines?

Use [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) when you need conditional logic, change-based execution, or monorepo fan-out. Static YAML managed via Terraform is often enough for small, simple repositories.
