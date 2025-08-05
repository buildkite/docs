# Deployment visibility with Backstage

[Backstage](https://backstage.io/) is an open source framework for building unified developer portals that provide unified visibility into your infrastructure tools, services, and documentation. You can integrate Buildkite with Backstage using the [Buildkite plugin for Backstage](https://github.com/buildkite/backstage-plugin) to monitor pipeline status and manage builds from a single interface.

## Overview

The Buildkite plugin for Backstage provides:

- **Centralized pipeline monitoring** - view Buildkite pipeline status alongside your [Backstage Service Catalog](https://backstage.io/docs/features/software-catalog/).
- **Real-time build tracking** - monitor build progress with automatic status updates.
- **Build management** - trigger rebuilds directly from Backstage.
- **Detailed build information** - access build logs, timing, and commit context.

<%= image "buildkite_in_backstage_ui.png", width: 1450/2, height: 960/2, alt: "A Buildkite pipeline in Backstage UI" %>

## Setting up deployment visibility

To use Backstage for deployment visibility with Buildkite, you'll need to:

1. [Install and configure the Buildkite plugin for Backstage](/docs/pipelines/integrations/other/backstage).
1. Annotate your deployment components in the Backstage catalog.
1. Configure your deployment pipelines for optimal visibility.

### Annotating deployment components

Add the Buildkite annotation to your component's `catalog-info.yaml` for deployment-specific visibility:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-production-service
  annotations:
    buildkite.com/pipeline-slug: my-org/production-deployment-pipeline
  tags:
    - production
    - deployment
spec:
  type: service
  owner: platform-team
  lifecycle: production
```

### Organizing deployment pipelines

To maximize deployment visibility in Backstage:

1. **Use consistent naming conventions** for deployment pipelines (e.g., `service-name-env-deploy`).
1. **Tag deployment builds** with environment information using build metadata.
1. **Set up deployment-specific badges** to quickly identify deployment status.

## Deployment dashboard features

When properly configured, the Backstage integration provides environment overview, deployment metrics, and build artifact tracking.

<%= image "deployments_in_backstge_ui.png", width: 1346/2, height: 582/2, alt: "Deployment overview dashboard with Buildkite Pipelines' build activity in Backstage UI" %>

### Environment overview

View all deployments across different environments:

- Production deployments
- Staging deployments
- Development deployments

### Deployment metrics

Track key deployment indicators:

- Deployment frequency
- Lead time for changes
- Deployment success rate
- Time to restore service

### Build artifact tracking

Monitor deployment artifacts:

- Docker images
- Build packages
- Configuration files
- Release notes

## Best practices for deployment visibility

The following are some tips for optimizing your workflow in Buildkite Pipelines and Backstage for the best integration results.

### Structure your pipelines

Structure your Buildkite pipelines with clear naming conventions:

```
my-service-ci          # Continuous integration
my-service-deploy-dev  # Development deployment
my-service-deploy-prod # Production deployment
```

### Use deployment-specific metadata

Add metadata context to your deployment builds:

```yaml
steps:
  - label: ":rocket: Deploy to Production"
    command: deploy.sh
    metadata:
      environment: "production"
      version: "$BUILDKITE_TAG"
      deployed_by: "$BUILDKITE_BUILD_CREATOR"
```

### Implement deployment gates

Use Buildkite's [block steps](/docs/pipelines/configure/step-types/block-step) to create approval gates visible in Backstage:

```yaml
steps:
  - block: ":hand: Deployment Approval"
    prompt: "Deploy to production?"
    fields:
      - text: "Release notes"
        key: "release-notes"
        required: true
```

### Track deployment events

Configure your pipelines to emit deployment events that Backstage can consume:

```bash
# In your deployment script
buildkite-agent annotate "Deployed version ${VERSION} to ${ENVIRONMENT}" \
  --style "success" \
  --context "deployment-${ENVIRONMENT}"
```

## Monitoring and alerting

Use Backstage's deployment visibility to:

1. **Set up deployment alerts** - configure notifications for failed deployments.
2. **Create deployment reports** - generate regular deployment performance reports.
3. **Track deployment SLOs** - monitor service level objectives for deployments.

## Troubleshooting deployment visibility

This section covers some common issues and the proposed mitigations for integration between Buildkite Pipelines and Backstage using the [Buildkite plugin](/docs/pipelines/integrations/other/backstage) for Backstage.

### Deployments not appearing

If your Buildkite deployments aren't appearing in Backstage:

- Verify the pipeline annotation matches your deployment pipeline.
- Check that the Buildkite API token has sufficient permissions.
- Ensure deployment builds are properly tagged.

### Incomplete deployment information

To improve deployment data quality:

- Add comprehensive build metadata.
- Use consistent environment naming.
- Include version information in all deployment builds.
