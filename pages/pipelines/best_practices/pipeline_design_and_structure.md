# Pipeline design and structure

This guide distills practical patterns for designing Buildkite pipelines that are maintainable and scalable as your codebase and teams grow.

## Keep pipelines focused and modular

- Start simple, then evolve:

    * Begin with [static pipelines](/docs/pipelines/create-your-own) for clarity and quick onboarding.
    * Move to [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) as your repositories and requirements grow to avoid YAML sprawl and enable conditional generation of steps at runtime.

- Separate concerns:

    * Keep build, test, security, packaging, and deploy concerns in distinct steps or groups.
    * Use small, composable scripts called by steps rather than embedding complex logic inline.

> 📘
> If you are coming to Buildkite Pipelines from a different CI/CD platform and would like to continue using matrix steps, know that [matrix steps](/docs/pipelines/configure/step-types/command-step#matrix-attributes) in Buildkite Pipelines don't work exactly the same way - not all steps in the matrix will always be executed. Instead, we recommend re-formatting your matrix steps as dynamic steps.

## Optimize monorepo builds using change scoping

- Use the agent's `if_changed` feature or the official [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) to selectively build and test affected components. Learn more in [Working with monorepos](/docs/pipelines/best-practices/working-with-monorepos).
- Use the `skip` condition to programmatically bypass individual steps, or use conditional logic in dynamic pipeline uploads to selectively generate only the necessary steps.

## Prioritize fast feedback loops

- Maximize [parallelism](/docs/pipelines/configure/workflows/controlling-concurrency#concurrency-and-parallelism) - split independent jobs and shards. Use parallelism for test sharding and cache warmers.
- Put quick, failure-prone checks first - for example, schema validations, `codegen`, linting, type checks, and the fastest unit tests. Use the `depends_on` attribute to run independent fast checks in parallel before slower dependent steps. Use the [fast-fail](/docs/pipelines/configure/step-types/command-step#fast-fail-running-jobs) feature to automatically cancel any remaining jobs as soon as any job in the build fails.
- Use [branch filters](/docs/pipelines/configure/workflows/branch-configuration#pipeline-level-branch-filtering) and `if` conditions for conditional execution - to skip unnecessary work in forks, release branches, draft PRs, and so on. Minimize [wait steps](/docs/pipelines/configure/step-types/wait-step) as they serialize execution - only use them when dependencies truly require it. Consider whether `depends_on` can replace `wait` for more granular parallelism in your pipelines.
- Use [annotations](/docs/agent/v3/cli/reference/annotate) for build summaries that help with debugging - for example, link to logs, JUnit pass/fail overviews, and flake reports.
- Customize error codes for auto-retries to disable auto-retries on legitimately failed builds.
- Use [auto-retry](/docs/pipelines/configure/step-types/command-step#retry-attributes-automatic-retry-attributes) strategically to identify _all_ kinds of flakiness - beyond just flaky tests (that can be identified using [Test Engine](/docs/test-engine)).

Example retry configuration:

```yaml
retry:
  automatic:
    - exit_status: -1  # agent lost
      limit: 2
    - exit_status: 255  # infrastructure issue
      limit: 1
```

### Structure YAML for clarity

- Use short, clear, human-readable labels with consistent prefixes and emoji for quick scanning.
- Group steps to collect related phases and present a clean top-level pipeline.
- Use descriptive `key` attributes on possible steps to enable clear dependency declarations with `depends_on` and make selective reruns easier.
- Leave comments for non-obvious logic and custom exit codes, explain tricky `if` conditions, environment dependencies, or ordering constraints. Design steps to be independently runnable where possible.

Here's an example group step for security tests that demonstrates clear labels and helpful comments:

```yaml
steps:
  - group: ":lock: Security Tests"
    key: "security-tests"
    steps:
      - label: ":microscope: Dependency Scan · Snyk"
        key: "dependency-scan"
        command: |
          snyk test --json-file-output=snyk-results.json
        artifact_paths:
          - "snyk-results.json"

      - label: ":package: Container Scan · Trivy"
        key: "container-scan"
        command: |
          trivy image --format json --output trivy-results.json myapp:latest
        artifact_paths:
          - "trivy-results.json"

      - label: ":key: Secret Scan · Gitleaks"
        key: "secret-scan"
        command: |
          gitleaks detect --report-path gitleaks-report.json
        artifact_paths:
          - "gitleaks-report.json"

  - wait: ~
    continue_on_failure: true   # allows the pipeline to continue even if security checks fail

  - label: ":bar_chart: Aggregate Security Results"
    depends_on:
      - "security-tests"
    command: |
      echo "All security tests completed. Review results above."
```

### Ownership and deployment

- Use [block steps](/docs/pipelines/configure/step-types/block-step) as explicit approvals between stages. Attach change summaries and release notes to the block.
- Consider splitting large pipelines into smaller, purpose-specific pipelines using [trigger steps](/docs/pipelines/configure/step-types/trigger-step). This enables independent ownership, versioning, and evolution of different deployment stages or environments.
- Define `CODEOWNERS` for pipeline files and generation code. Require reviews for changes to core templates.
- Version your [pipeline templates](/docs/pipelines/governance/templates) and [custom plugins](/docs/pipelines/integrations/plugins/writing). Roll them out with a changelog for tracking changes.
- Implement environment isolation - separate credentials and secrets per environment [using environment hooks](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks) or secret managers. Never reuse production credentials in CI. You can learn more about handling of credentials and other secrets in [Secrets management](/docs/pipelines/best-practices/secrets-management).
