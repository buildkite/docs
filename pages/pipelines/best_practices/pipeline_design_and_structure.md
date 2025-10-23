# Pipeline design and structure

## Keep pipelines focused and modular

Start with [static pipelines](/docs/pipelines/create-your-own) and gradually move to [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) as the latter scale better than static YAML as repositories and requirements grow.

## Use monorepos for change scoping

* Run only what changed. Use the agent's `if_changed` feature or the official [Monorepo diff plugin](https://buildkite.com/resources/plugins/buildkite-plugins/monorepo-diff-buildkite-plugin/) to selectively build and test affected components.
* Three common patterns:
    + One orchestrator pipeline that triggers static component pipelines based on diffs.
    + [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) that inject only the steps needed for the change set.
    + [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) where the injected parts can be build in any language you prefer.

## Prioritize fast feedback loops

* Parallelize where possible: run independent tests in parallel to reduce overall build duration.
* Fail fast: place the fastest, most failure-prone steps early in the pipeline.
* Use conditional steps: skip unnecessary work by using branch filters and step conditions.
* Smart test selection: use test impact analysis or path-based logic to run only the relevant subset of tests.
* Use auto-retry to identify _all_ kinds of flakiness - beyond just flaky tests (that can be identified using Test Engine).

## Structure YAML for clarity

* Descriptive step names: step labels should be human-readable and clear at a glance.
* Organize with groups: use group steps to keep complex pipelines navigable. You can also use emojis for visual cues as quick scanning is easier with consistent iconography. For example, here is how you might want to organize all of the security testing in a single group step in your pipeline configuration, using emoji as an additional visual aid:

```yaml
steps:
  - group: ":lock: Security Tests"
    key: "security-tests"
    steps:
      - label: ":microscope: Dependency Scan - Snyk"
        key: "dependency-scan"
        command: |
          snyk test --json-file-output=snyk-results.json
        artifact_paths:
          - "snyk-results.json"

      - label: ":package: Container Scan - Trivy"
        key: "container-scan"
        command: |
          trivy image --format json --output trivy-results.json myapp:latest
        artifact_paths:
          - "trivy-results.json"

      - label: ":key: Secret Scanning - Gitleaks"
        key: "secret-scan"
        command: |
          gitleaks detect --report-path gitleaks-report.json
        artifact_paths:
          - "gitleaks-report.json"

      - label: ":spider_web: DAST - OWASP ZAP"
        key: "dast-zap"
        command: |
          zap-baseline.py -t https://staging.myapp.com -J zap-report.json
        artifact_paths:
          - "zap-report.json"

  - wait: ~
    continue_on_failure: true

  - label: ":bar_chart: Aggregate Security Results"
    command: |
      echo "All security tests completed. Review results above."
```

* Comment complex logic: document non-obvious conditions or dependencies inline.

## Standardize with reusable modules

* Centralized templates: maintain organization-wide pipeline templates and plugins to enforce consistency across teams.
* Shared libraries: package common scripts or Docker images so individual teams don’t reinvent solutions.
* Queue tracking: document how different types of queues could be used and when they should be upgraded.
* Custom plugins: you can turn your regularly reused pieces of code for common use cases into [your own Buildkite plugin](/docs/pipelines/integrations/plugins/writing). Writing your own plugins will help you with standardization.

## Annotations and errors

* Use annotations for debugging.
* Contact Support.
* Customize error codes for auto-retries to disable auto-retries on legitimately failed builds.
* Matrix steps issues: if you are coming from a different CI/CD platform and would like to continue using matrix steps, know that matrix steps in Buildkite are not an exact match as most of the time, not all the steps in the matrix will be executed in Buildkite. Instead, we recommend re-formatting your matrix steps as dynamic steps.
