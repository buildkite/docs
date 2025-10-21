# Plugin management and standardization

Platform teams can leverage Buildkite plugins to standardize tooling, enforce best practices, and reduce configuration duplication across pipelines. By creating and managing a curated set of plugins, platform teams can provide development teams with approved, secure, and well-maintained tools while maintaining control over the CI/CD environment.

## Private plugin development

You can [write](/docs/pipelines/integrations/plugins/writing) a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) when you need to implement organization-specific requirements or standardize complex workflows:

- **Security and compliance integration**: develop plugins that automatically integrate with your organization's security scanning tools, compliance frameworks, or audit logging systems.
- **Deployment standardization**: create plugins that encapsulate your organization's deployment patterns, environment-specific configurations, and rollback procedures.
- **Infrastructure automation**: build plugins that interact with your internal APIs, infrastructure provisioning systems, or monitoring platforms.
- **Quality gate enforcement**: Implement plugins that enforce code quality standards, testing requirements, or documentation completeness checks.

## Reusable functionality patterns through plugins

You can extract common pipeline functionality into plugins to reduce duplication and ensure consistency:

- Multi-environment deployment pipelines with approval gates.
- Artifact packaging and distribution processes.
- Performance testing and benchmarking procedures.
- Container image building and security scanning workflows.

## Plugin source management

Platform teams should establish clear governance around plugin sources and usage:

- **Buildkite-maintained plugins**: use these for standard functionality like Docker, Docker Compose, and common testing frameworks.
- **Approved third-party plugins**: maintain an allowlist of vetted community plugins that meet your security and reliability standards.
- **Private organizational plugins**: host your custom plugins in private repositories using fully qualified Git URLs for sensitive or proprietary functionality.

Implement strict version management practices to ensure reliability and security:

- Always pin plugins to specific versions or commit SHA values to prevent unexpected changes: `docker#v3.3.0` or `my-plugin#287293c4`.
- Regularly audit and update plugin versions as part of your maintenance cycle.
- Use YAML anchors to centralize plugin configuration and ensure consistency across pipelines.
- Monitor plugin repositories for security vulnerabilities and updates.

### Plugin orchestration

Design plugin workflows that work together seamlessly across pipeline steps:

- Use plugins that leverage Buildkite's meta-data store to share information between steps
- Create plugin chains that handle complex workflows like build → test → security scan → deploy
- Implement plugins that can conditionally execute based on previous step results or build metadata

## Plugin access control and security

Platform administrators can control plugin usage through agent configuration:

- Use the [agent's plugin restrictions](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to allowlist approved plugins.
- Set the [`no-plugins`](/docs/agent/v3/configuration#no-plugins) option to disable plugins entirely on sensitive agents.
- Implement different plugin policies for different agent clusters based on security requirements.

## Private plugin distribution

For sensitive or proprietary functionality, use private Git repositories:

```yml
steps:
  - command: deploy to production
    plugins:
      - ssh://git@github.com/your-org/deployment-plugin.git#v1.0.0:
          environment: production
          approval_required: true
      - file:///internal/monitoring-plugin.git#v2.0.0:
          alert_channels: ["#ops", "#security"]
```

## Plugin security

- Regularly audit plugin permissions and access patterns
- Use separate Git repositories for different security domains
- Implement code review processes for all plugin changes
- Monitor plugin usage across your organization to identify potential security risks or optimization opportunities

By establishing comprehensive plugin management practices, platform teams can provide development teams with powerful, standardized tools while maintaining security, compliance, and operational consistency across the entire CI/CD ecosystem.
