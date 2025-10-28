# Plugin management and standardization

Buildkite [plugins](https://buildkite.com/docs/pipelines/integrations/plugins) serve as reusable building blocks that help maintain consistency and reduce repetitiveness across pipeline configurations in a Buildkite organization.

## Common use cases

You can extract common pipeline functionality into plugins by [writing](/docs/pipelines/integrations/plugins/writing) a plugin. Common use cases include:

- Security and compliance integration - automatically integrate with security scanning tools, compliance frameworks, or audit logging systems.
- Deployment standardization - encapsulate deployment patterns, environment-specific configurations, and rollback procedures.
- Infrastructure automation - interact with internal APIs, infrastructure provisioning systems, or monitoring platforms.
- Quality gate enforcement - enforce code quality standards, testing requirements, or documentation completeness checks.
- Artifact management - standardize packaging and distribution processes across teams.
- Performance testing - implement consistent benchmarking and performance testing procedures.
- Container workflows - standardize container image building and security scanning.

## Plugin sources

Buildkite supports three types of plugin sources, each suited to different security and distribution requirements:

- Buildkite-maintained plugins that are available in the [Buildkite plugins directory](/docs/pipelines/integrations/plugins/directory) and provide standard functionality like Docker, Docker Compose, common testing frameworks, and so on.
- Third-party plugins from the community that are also available in the plugins directory. You can [get your own plugin published](/docs/pipelines/integrations/plugins/writing#publish-to-the-buildkite-plugins-directory) there as well. Maintain an allowlist of vetted community plugins that meet your security and reliability standards.
- Private organizational plugins can be created and hosted in private repositories for sensitive or proprietary functionality. Write a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) when you need to implement organization-specific requirements or standardize complex workflows. Use full Git URLs to reference these plugins for example:

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

## Version management

Implement strict version management practices to ensure plugin reliability and security:

- Always pin plugins to specific versions or commit SHA values to prevent unexpected changes, for example: `docker#v3.3.0` or `my-plugin#287293c4`.
- Regularly audit and update plugin versions as part of your maintenance cycle.
- Use [YAML anchors](/docs/pipelines/integrations/plugins/using#using-yaml-anchors-with-plugins) to centralize plugin configuration and ensure consistency across pipelines.
- Monitor plugin repositories for security vulnerabilities and updates.

## Security and access control

To maintain a secure plugin ecosystem, implement these practices:

- Use the [agent's plugin restrictions](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to allowlist approved plugins.
- Set the [`no-plugins`](/docs/agent/v3/configuration#no-plugins) option to disable plugins entirely on sensitive agents.
- Implement different plugin policies for different [clusters](/docs/pipelines/clusters) based on security requirements.
- Use separate Git repositories for different security domains.
- Implement code review processes for all plugin changes.
- Regularly audit plugin permissions, access patterns, and usage across your organization to identify potential security risks or optimization opportunities.
