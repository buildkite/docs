# Standardized retry policies

Consistent retry policies should be implemented  across all pipelines to handle transient failures gracefully while avoiding unnecessary resource consumption. Well-designed retry strategies distinguish between different types of failures and apply appropriate retry logic based on the likelihood of success upon retry.

## Automatic retry configurations

### Exit code-based retry policies

Define specific retry behaviors for different failure categories using Buildkite's automatic retry functionality:

```yaml
steps:
  - label: "Test Suite"
    command: run_tests.sh
    retry:
      automatic:
        - exit_status: 1      # Test failures - may pass on retry
          limit: 2
        - exit_status: 255    # Infrastructure issues - likely transient
          limit: 3
        - exit_status: 130    # SIGINT/timeout - resource contention
          limit: 1
        - exit_status: 137    # SIGKILL/OOM - memory issues
          limit: 1
```

### Conditional retry strategies

Implement more sophisticated retry logic that considers build context and failure patterns:

```yaml
steps:
  - label: "Integration Tests"
    command: integration_test_runner.sh
    retry:
      automatic:
        # Network-related failures - aggressive retry
        - exit_status: 2
          limit: 5
        # Database connection issues - moderate retry
        - exit_status: 3
          limit: 3
        # Authentication failures - single retry only
        - exit_status: 4
          limit: 1
      manual:
        # Allow manual retry for complex failures
        allowed: true
        permit_on_passed: false
        reason: "Manual investigation required"
```

### Environment-specific retry policies

Tailor retry behavior based on the deployment environment and criticality:

```yaml
# Production deployment - conservative retries
- label: "Deploy to Production"
  command: deploy_production.sh
  retry:
    automatic:
      - exit_status: 255    # Infrastructure only
        limit: 2
  if: build.branch == "main"

# Development environment - aggressive retries
- label: "Deploy to Development"
  command: deploy_development.sh
  retry:
    automatic:
      - exit_status: "*"    # Any failure
        limit: 3
  if: build.branch =~ /^feature\//
```

## Platform-wide retry standards

### Centralized retry policies

Use pipeline templates to enforce consistent retry behavior across the organization:

```yaml
# In your pipeline template
common_retry_policies: &retry_policies
  retry:
    automatic:
      - exit_status: 1      # Test failures
        limit: 2
      - exit_status: 2      # Build failures
        limit: 1
      - exit_status: 255    # Infrastructure
        limit: 3
    manual:
      allowed: true
      permit_on_passed: false

steps:
  - label: "Unit Tests"
    command: npm test
    <<: *retry_policies
  - label: "Integration Tests"
    command: npm run test:integration
    <<: *retry_policies
```

### Workload-specific retry patterns

Define different retry strategies for different types of workloads:

```yaml
# High-availability service retries
high_availability_retry: &ha_retry
  retry:
    automatic:
      - exit_status: "*"
        limit: 5

# Security scanning retries (conservative)
security_scan_retry: &security_retry
  retry:
    automatic:
      - exit_status: 255    # Infrastructure only
        limit: 2
    manual:
      allowed: false        # No manual retries for security

# Performance testing retries (resource-aware)
performance_test_retry: &perf_retry
  retry:
    automatic:
      - exit_status: 137    # OOM errors
        limit: 1
      - exit_status: 124    # Timeouts
        limit: 2
```

## Custom exit codes and failure classification

Implement standardized exit codes across your organization to enable intelligent retry policies, better error reporting, and automated incident response. Well-defined exit codes help platform teams understand failure patterns and optimize pipeline reliability.

### Exit code standardization

Establish consistent exit code meanings across all build scripts and tools. For example:

```bash
#!/bin/bash
# Standard exit codes for organizational use

# Success
readonly EXIT_SUCCESS=0

# Test and build failures (retryable)
readonly EXIT_TEST_FAILURE=1
readonly EXIT_BUILD_FAILURE=2
readonly EXIT_LINT_FAILURE=3

# Infrastructure failures (highly retryable)
readonly EXIT_NETWORK_ERROR=10
readonly EXIT_DEPENDENCY_UNAVAILABLE=11
readonly EXIT_RESOURCE_EXHAUSTION=12

# Configuration failures (not retryable)
readonly EXIT_CONFIG_ERROR=20
readonly EXIT_AUTHENTICATION_FAILURE=21
readonly EXIT_PERMISSION_DENIED=22

# Security failures (critical, not retryable)
readonly EXIT_SECURITY_VIOLATION=30
readonly EXIT_VULNERABILITY_DETECTED=31
readonly EXIT_COMPLIANCE_FAILURE=32

# System failures (infrastructure retryable)
readonly EXIT_TIMEOUT=124
readonly EXIT_SIGKILL=137
readonly EXIT_SIGTERM=143
readonly EXIT_INFRASTRUCTURE=255

# Example usage in a test script
run_security_scan() {
    if ! security_scanner --config security.yaml; then
        echo "Security vulnerabilities detected"
        exit $EXIT_VULNERABILITY_DETECTED
    fi
}

run_unit_tests() {
    if ! npm test; then
        echo "Unit tests failed"
        exit $EXIT_TEST_FAILURE
    fi
}
```
