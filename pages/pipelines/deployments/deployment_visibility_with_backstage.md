---
toc: false
---

# Deployment visibility with Backstage

[Backstage](https://backstage.io/) provides a unified developer portal that can give you comprehensive visibility into your Buildkite deployments. By integrating Buildkite with Backstage, you can track deployment statuses, monitor deployment pipelines, and manage your entire deployment lifecycle from a single interface.

## Overview

The Buildkite Backstage plugin enhances your deployment visibility by:

- **Centralizing deployment information** - View all your deployment pipelines alongside your service catalog
- **Providing real-time status updates** - Monitor deployment progress without switching between tools
- **Enabling deployment history tracking** - Access historical deployment data and trends
- **Facilitating deployment management** - Trigger and manage deployments directly from Backstage

## Setting up deployment visibility

To use Backstage for deployment visibility with Buildkite, you'll need to:

1. [Install and configure the Buildkite Backstage plugin](/docs/pipelines/integrations/other/backstage)
2. Annotate your deployment-related components in Backstage
3. Configure your deployment pipelines for optimal visibility

### Annotating deployment components

For deployment-specific visibility, annotate your services in the Backstage catalog with your deployment pipeline information:

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

1. **Use consistent naming conventions** for deployment pipelines (e.g., `service-name-env-deploy`)
2. **Tag deployment builds** with environment information using build metadata
3. **Set up deployment-specific badges** to quickly identify deployment status

## Deployment dashboard features

When properly configured, the Backstage integration provides:

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

### 1. Structure your pipelines

Organize your Buildkite pipelines to clearly distinguish between:
- Build pipelines
- Test pipelines
- Deployment pipelines

Example pipeline naming:
```
my-service-build
my-service-test
my-service-deploy-staging
my-service-deploy-production
```

### 2. Use deployment-specific metadata

Add metadata to your deployment builds:

```yaml
steps:
  - label: ":rocket: Deploy to Production"
    command: deploy.sh
    metadata:
      environment: "production"
      version: "$BUILDKITE_TAG"
      deployed_by: "$BUILDKITE_BUILD_CREATOR"
```

### 3. Implement deployment gates

Use Buildkite's block steps to create approval gates visible in Backstage:

```yaml
steps:
  - block: ":hand: Deployment Approval"
    prompt: "Deploy to production?"
    fields:
      - text: "Release notes"
        key: "release-notes"
        required: true
```

### 4. Track deployment events

Configure your pipelines to emit deployment events that Backstage can consume:

```bash
# In your deployment script
buildkite-agent annotate "Deployed version ${VERSION} to ${ENVIRONMENT}" \
  --style "success" \
  --context "deployment-${ENVIRONMENT}"
```

## Integrating with other tools

Backstage can aggregate deployment information from multiple sources:

### Kubernetes deployments

If deploying to Kubernetes, consider using Backstage's Kubernetes plugin alongside Buildkite for complete visibility:

```yaml
metadata:
  annotations:
    buildkite.com/pipeline-slug: my-org/k8s-deployment-pipeline
    backstage.io/kubernetes-id: my-service
    backstage.io/kubernetes-namespace: production
```

### ArgoCD integration

For GitOps deployments, combine Buildkite build information with ArgoCD deployment status in Backstage.

## Monitoring and alerting

Use Backstage's deployment visibility to:

1. **Set up deployment alerts** - Configure notifications for failed deployments
2. **Create deployment reports** - Generate regular deployment performance reports
3. **Track deployment SLOs** - Monitor service level objectives for deployments

## Troubleshooting deployment visibility

### Deployments not appearing

If your deployments aren't visible in Backstage:
- Verify the pipeline annotation matches your deployment pipeline
- Check that the Buildkite API token has sufficient permissions
- Ensure deployment builds are properly tagged

### Incomplete deployment information

To improve deployment data quality:
- Add comprehensive build metadata
- Use consistent environment naming
- Include version information in all deployment builds

## Further reading

- [Buildkite Backstage integration](/docs/pipelines/integrations/other/backstage)
- [Buildkite deployments overview](/docs/pipelines/deployments)
- [Backstage Service Catalog](https://backstage.io/docs/features/software-catalog/)