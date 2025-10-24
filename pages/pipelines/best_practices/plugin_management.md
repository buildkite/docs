# Plugin management and standardization

Buildkite [plugins](https://buildkite.com/docs/pipelines/integrations/plugins) serve as reusable building blocks that help teams maintain consistency and reduce repetitive configurations across your pipelines. When your platform team maintains a set of approved plugins, you get access to ready-made, secure tools that make your pipeline configuration consistent throughout your Buildkite organization.

## Reusable functionality patterns through plugins

You can extract common pipeline functionality into plugins to reduce duplication and ensure consistency. You can [write](/docs/pipelines/integrations/plugins/writing) a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) when you need to implement organization-specific requirements or standardize complex workflows.

Common use cases for plugins include:

- Security and compliance integration - automatically integrate with security scanning tools, compliance frameworks, or audit logging systems.
- Deployment standardization - encapsulate deployment patterns, environment-specific configurations, and rollback procedures.
- Infrastructure automation - interact with internal APIs, infrastructure provisioning systems, or monitoring platforms.
- Quality gate enforcement - enforce code quality standards, testing requirements, or documentation completeness checks.
- Artifact management - standardize packaging and distribution processes across teams.
- Performance testing - implement consistent benchmarking and performance testing procedures.
- Container workflows - standardize container image building and security scanning.

## Buildkite plugins directory

You can find a large number of already existing plugins that cover many use cases in the [Buildkite plugins directory](/docs/pipelines/integrations/plugins/directory). The directory contains both Buildkite-maintained plugins and third-party plugins. You, too, can [get your plugin published](/docs/pipelines/integrations/plugins/writing#publish-to-the-buildkite-plugins-directory) in the Buildkite plugins directory.

## Private plugin distribution

For sensitive or proprietary functionality, use private Git repositories for plugins you would not want to make public. For example, this is what configuring a plugin that is based in your private repository would look like:

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

## Plugin source management

Managing where your plugins come from and how they're versioned is critical for security and stability. Buildkite supports three types of plugin sources:

- Buildkite-maintained plugins - use these for standard functionality like Docker, Docker Compose, and common testing frameworks.
- Approved third-party plugins - maintain an allowlist of vetted community plugins that meet your security and reliability standards.
- Private organizational plugins - host your custom plugins in private repositories using fully qualified Git URLs for sensitive or proprietary functionality.

Implement strict version management practices to ensure reliability and security:

- Always pin plugins to specific versions or commit SHA values to prevent unexpected changes: `docker#v3.3.0` or `my-plugin#287293c4`.
- Regularly audit and update plugin versions as part of your maintenance cycle.
- Use YAML anchors to centralize plugin configuration and ensure consistency across pipelines.
- Monitor plugin repositories for security vulnerabilities and updates.

## Plugin security

To maintain a secure plugin ecosystem, implement these essential practices in your Buildkite organization:

- Regularly audit plugin permissions and access patterns.
- Use separate Git repositories for different security domains.
- Implement code review processes for all plugin changes.
- Monitor plugin usage across your organization to identify potential security risks or optimization opportunities.

## Plugin access control

Administrators can control plugin usage through agent configuration:

- Use the [agent's plugin restrictions](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to allowlist approved plugins.
- Set the [`no-plugins`](/docs/agent/v3/configuration#no-plugins) option to disable plugins entirely on sensitive agents.
- Implement different plugin policies for different [clusters](/docs/pipelines/clusters) based on security requirements.
