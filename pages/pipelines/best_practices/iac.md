# Infrastructure as Code (IaC) in Buildkite Pipelines

These best practices help you manage Buildkite organizations, pipelines, agents, and security controls entirely as code. They emphasize Terraform, GitOps, least privilege, and auditable automation.

## Principles

- Treat the UI as read-only for configuration. Use it for visibility and manual approvals, not state.
- Make code the single source of truth. Store configuration in version control with reviews, tests, and changelogs.
- Prefer short‑lived credentials and federated identity (OIDC) over long‑lived secrets.
- Enforce least privilege everywhere: Buildkite org, queues, agents, cloud access, and secret scope.
- Design for change: dynamic pipelines, modular IaC, and progressive rollout controls.

## Source of truth and workflow

- GitOps flow

    * Propose changes via PRs
    * Automated checks validate schema and policy
    * Require at least two approvals for sensitive resources
    * Merge triggers Terraform plan/apply via a service identity

- State management
    * Use remote state with locking and versioning
    * Split state by blast radius: organization, clusters/queues, project/pipeline tiers
- Drift control
    * Limit who has UI write access; periodically detect and reconcile drift
    * Export and compare Buildkite resources on a schedule (read-only jobs)

## Terraform with Buildkite

- Use the Buildkite Terraform provider to manage:
    * Organizations, teams, permissions
    * Pipelines and settings
    * Clusters, queues, and agent tokens
    * Webhooks, secrets providers, and related config
- Standards
    * Pin provider versions and module versions
    * Use environment-specific workspaces or separate stacks
    * Keep reusable modules for common patterns: standard pipeline defaults, queue definitions, token lifecycles, RBAC mappings
- Example structure

```
infra/
  org/
    [main.tf](http://main.tf)         # teams, roles, org settings
  clusters/
    shared/         # multi-tenant cluster and baseline queues
    prod/
    staging/
  pipelines/
    services/
      svc-a/
      svc-b/
    libraries/
      templates/    # shared pipeline modules
```

## Identities, RBAC, and access

- Identities
    * Use a non-person service account for Terraform applies
    * Rotate that account’s API key regularly or move to OIDC once applicable
- RBAC mapping
    * Keep team membership and roles in code
    * Principle of least privilege for maintainers and operators
- UI access
    * Prefer read-only access for most engineers; write access limited to platform maintainers

## Secrets and configuration

- Prefer external secret managers (AWS/GCP/Azure) fetched at runtime via hooks or plugins
- Keep secrets out of repositories and annotations; redact logs where possible
- Scope secrets by environment and queue; never reuse production credentials in CI contexts
- Rotate secrets regularly and monitor use

## Agents, clusters, and queues

- Boundaries
    * Use queues as explicit trust and resource boundaries
    * Separate by OS, architecture, GPU/CPU/memory class, and sensitivity
- Lifecycle
    * Prefer ephemeral agents for hermetic builds
    * Maintain minimal, cached base images per purpose (e.g., security, builders, mobile)
    * Keep a small number of always-on agents for fast bootstrap; autoscale the rest
- Hooks
    * Use agent hooks for guardrails and standardization (env setup, mount policies, log conventions)

## Pipelines as code

- Default to dynamic pipelines for scalability and conditional logic
- Keep pipeline logic with the repository; use shared libraries for cross-repo patterns
- Use small, composable steps with explicit dependencies; avoid monolithic steps
- Promote with control gates
    * Use block steps for human approvals
    * Attach change summaries and release notes
    * Require artifact, scan, or policy attestations before deploy

## Policy and compliance

- Policy-as-code
    * Validate pipeline definitions prior to upload
    * Disallow unsafe patterns (unscoped shell, credential egress, self-modifying pipelines)
- Attestations and auditability
    * Generate SBOMs and provenance for release artifacts
    * Preserve logs, artifacts, and approvals with retention policies
- Continuous compliance
    * Scheduled conformance checks for RBAC, queues, and pipeline settings

## Terraform/IaC run safety

- Concurrency controls
    * Serialize applies per environment or workspace
    * Use state locking to prevent collisions
- Approvals
    * Require review for changes touching security, team membership, or production queues
- Backouts
    * Keep roll-forward and rollback playbooks
    * Tag releases and pin module versions for quick reversion

### Example: Minimal Terraform for a Pipeline and Queue

```hcl
terraform {
  required_providers {
    buildkite = {
      source  = "buildkite/buildkite"
      version = "~> 1.0"
    }
  }
}

provider "buildkite" {
  api_token = var.buildkite_api_token
}

resource "buildkite_team" "platform" {
  name        = "Platform"
  privacy     = "secret"
  description = "CI/CD platform maintainers"
}

resource "buildkite_pipeline" "svc_a" {
  name            = "svc-a"
  repository      = "[git@github.com](mailto:git@github.com):org/svc-a.git"
  steps           = file("pipelines/svc-a.yml")
  default_branch  = "main"
}

resource "buildkite_cluster" "shared" {
  name        = "shared-cluster"
  description = "Shared compute for CI"
}

resource "buildkite_queue" "tf_queue" {
  cluster_id  = buildkite_[cluster.shared.id](http://cluster.shared.id)
  key         = "terraform"
  description = "IaC workloads with restricted credentials"
}
```

### Operational excellence

- Observe
    * Track queue saturation, wait times, retries, and flake rates
    * Emit machine-parseable logs and summarize key signals via annotations
- Cost and performance
    * Right-size steps and parallelism; pre-bake heavy dependencies
    * Cache safely within trust boundaries; prefer reproducible caches
- Runbooks
    * Document escalation paths for agents, queues, secrets, and pipeline failures

### FAQ

- How do I keep prod safe? Separate prod queues and credentials, require approval gates, and enforce policy checks pre-deploy
- Do I need dynamic pipelines? Yes for conditional and large-scale pipelines; static YAML can be fine for simple repos, but plan to evolve
- What about multi-repo or monorepo? Both work; ensure change-scoped pipelines and consistent shared libraries
