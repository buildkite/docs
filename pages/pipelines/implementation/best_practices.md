# Best practices

(This is a work in progress!)


This guide covers best practices for managing Buildkite Pipelines, focusing on how platform and infrastructure teams can maintain centralized control while providing development teams with the flexibility they need.

> 📘
> If you're looking for in-depth information on best practices for security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Implementation recommendations

- Assess current state: audit existing pipelines, agents, and usage patterns.
- Define policies: establish resource limits, security requirements, and cost targets.
- Create templates: build standard pipeline templates for common use cases.
- Implement gradually: roll out controls incrementally to avoid disrupting existing workflows.

### Common pitfalls to avoid

- Over-restricting initially: start permissive and tighten controls based on actual usage.
- Ignoring developer feedback: platform controls should enable, not hinder, development teams.
- No monitoring: implement observability from day one to understand the impact of your controls.

