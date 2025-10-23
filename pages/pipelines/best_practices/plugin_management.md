# Plugin management and standardization

Buildkite [plugins](https://buildkite.com/docs/pipelines/integrations/plugins) serve as reusable building blocks that help teams maintain consistency and reduce repetitive configuration across your pipelines. When your platform team maintains a set of approved plugins, you get access to ready-made, secure tools that make your pipeline configuration consistent throughout your Buildkite organization.

## Reusable functionality patterns through plugins

You can extract common pipeline functionality into plugins to reduce duplication and ensure consistency. You can [write](/docs/pipelines/integrations/plugins/writing) a [private plugin](/docs/pipelines/integrations/plugins/using#plugin-sources) when you need to implement organization-specific requirements or standardize complex workflows.

The following cases are good candidates for being turned into reusable plugins:

- Artifact packaging and distribution processes.
- Performance testing and benchmarking procedures.
- Container image building and security scanning workflows.

You can use plugins for:

- Security and compliance integration: develop plugins that automatically integrate with your organization's security scanning tools, compliance frameworks, or audit logging systems.
- Deployment standardization: create plugins that encapsulate your organization's deployment patterns, environment-specific configurations, and rollback procedures.
- Infrastructure automation: build plugins that interact with your internal APIs, infrastructure provisioning systems, or monitoring platforms.
- Quality gate enforcement: implement plugins that enforce code quality standards, testing requirements, or documentation completeness checks.

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

## Plugin access control

Administrators can control plugin usage through agent configuration:

- Use the [agent's plugin restrictions](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to allowlist approved plugins.
- Set the [`no-plugins`](/docs/agent/v3/configuration#no-plugins) option to disable plugins entirely on sensitive agents.
- Implement different plugin policies for different [clusters](/docs/pipelines/clusters) based on security requirements.

## Buildkite plugins directory

You can find a large number of already existing plugins that cover many use cases in the [Buildkite plugins directory](/docs/pipelines/integrations/plugins/directory). The directory contains both Buildkite-maintained plugins and third-party plugins. You, too, can [get your plugin published](/docs/pipelines/integrations/plugins/writing#publish-to-the-buildkite-plugins-directory) in the Buildkite plugins directory.
