# Patterns and anti-patterns

This page is a collection of patterns and anti-patterns for Buildkite Pipelines.

## Recommended patterns.

These are the recommended patterns.

### Wait steps for coordination

Ensure multiple parallel jobs complete before proceeding:

```yaml
steps:
  - label: ":hammer: Build"
    command: "make build"
    parallelism: 3
  - wait
  - label: ":rocket: Deploy"
    command: "make deploy"
```

### Graceful error handling

Use `soft_fail` where failures are acceptable, but document why:

```yaml
steps:
  - label: ":test_tube: Optional integration tests"
    command: "make integration-tests"
    soft_fail: true
  - label: ":white_check_mark: Required unit tests"
    command: "make unit-tests"
```

### Use block steps for approvals

Require human confirmation before production deployment:

```yaml
steps:
  - block: ":rocket: Deploy to production?"
    branches: "main"
    fields:
      - select: "Environment"
        key: "environment"
        options:
          - label: "Staging"
            value: "staging"
          - label: "Production"
            value: "production"
```

### Canary releases in CI/CD

Model partial deployments and staged rollouts directly in pipelines. See more in [Deployments](/docs/pipelines/deployments).

### Pipeline-as-code reviews

Require peer reviews for pipeline changes, just like application code.

### Chaos testing

Periodically inject failure scenarios (e.g., failing agents, flaky dependencies) to validate pipeline resilience.

### Silent failures

Never ignore failing steps without a clear follow-up.

## Anti-patterns to avoid

The following are the anti-patterns that should be avoided.

### Hard-coding environment values

Instead, inject via environment variables or pipeline metadata:

```yaml
# ❌ Bad
command: "deploy.sh https://api.myapp.com/prod"

# ✅ Good
command: "deploy.sh $API_ENDPOINT"
env:
  API_ENDPOINT: "https://api.myapp.com/prod"
```

### Overloaded single steps

Avoid cramming unrelated tasks into one step, for example:

```
# ❌ Bad - Mixing unrelated concerns
- label: "Build and security scan and deploy"
  command: |
    docker build -t myapp .
    trivy image myapp
    docker push myapp:latest
    kubectl apply -f k8s/deployment.yaml

# ✅ Good - Separate logical concerns
- label: ":docker: Build application"
  command: "docker build -t myapp ."

- label: ":shield: Security scan"
  command: "trivy image myapp"
  depends_on: "build"

- label: ":rocket: Deploy to production"
  command: |
    docker push myapp:latest
    kubectl apply -f k8s/deployment.yaml
  depends_on:
    - "build"
    - "security-scan"
```

The "bad" example crams together building, security scanning, and deployment which are three totally different concerns that you'd want to handle separately, potentially with different permissions, agents, and failure handling strategies.

Cramming more tasks into one step reduces the ability of the pipeline to scale and take advantage of multiple agents.
Splitting steps makes it logically easier to understand and also takes advantage of Buildkite's scalable agents.
Also makes it easier to troubleshoot when something breaks in the pipeline.
Maybe a note about how Buildkite artifacts could be used to "cache" common data between steps.

### Controlled parallelism and concurrency

Balance parallel execution for speed while managing resource consumption and costs:

**Step-level parallelism (`parallelism` attribute):**

* Set reasonable limits on the `parallelism` attribute for individual steps based on your agent capacity.
* Consider that each parallel job consumes an agent, so `parallelism: 50` requires 50 available agents.
* Monitor queue wait times when using high parallelism values to ensure adequate agent availability.

**Build-level concurrency:**

* While running jobs in parallel across different steps speeds up builds, be mindful of your total agent pool capacity.
* Buildkite has default limits on concurrent steps per build to prevent resource exhaustion.
* Design pipeline dependencies (`wait` steps) to balance speed with resource availability.

**Example of controlled parallelism:**
```yaml
steps:
  - label: "Unit Tests"
    command: npm test
    parallelism: 10  # Reasonable for most agent pools

  - wait

  - label: "Integration Tests"
    command: npm run test:integration
    parallelism: 5   # Lower parallelism for resource-intensive tests
```
