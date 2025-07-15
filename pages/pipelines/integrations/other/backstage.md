---
toc: false
---

# Backstage

[Backstage](https://backstage.io/) is an open platform for building developer portals that creates, manages, and explores software from a unified front end. The Buildkite plugin for Backstage integrates your Buildkite CI/CD pipelines directly into your Backstage service catalog, providing real-time build monitoring and management capabilities.

## Features

The Buildkite Backstage plugin provides:

- **Real-time build status monitoring** - View the current status of your builds directly in Backstage
- **Comprehensive build log tracking** - Access detailed build logs without leaving Backstage
- **Advanced filtering and search capabilities** - Quickly find specific builds using powerful filters
- **Interactive build management** - Trigger rebuilds and manage builds from within Backstage
- **Customization options** - Configure the plugin to match your team's workflow

## Prerequisites

Before installing the Buildkite Backstage plugin, ensure you have:

- A Buildkite account with at least one pipeline
- A Backstage instance (version 1.0 or later)
- A Buildkite API token with the following permissions:
  - `read_pipelines`
  - `read_builds`
  - `read_user`
  - `write_builds`

## Installation

### Step 1: Install the plugin

Add the Buildkite plugin to your Backstage app:

```bash
yarn workspace app add @buildkite/backstage-plugin-buildkite
```

### Step 2: Configure the Buildkite API

Add the Buildkite API configuration to your `app-config.yaml`:

```yaml
proxy:
  endpoints:
    '/buildkite/api':
      target: https://api.buildkite.com
      headers:
        Authorization: Bearer ${BUILDKITE_API_TOKEN}
```

Make sure to set the `BUILDKITE_API_TOKEN` environment variable with your Buildkite API token.

### Step 3: Register the plugin

1. Register the plugin in `packages/app/src/plugins.ts`:

```typescript
export { buildkitePlugin } from '@buildkite/backstage-plugin-buildkite';
```

2. Add the API factory in `packages/app/src/apis.ts`:

```typescript
import {
  createApiFactory,
  discoveryApiRef,
  fetchApiRef,
} from '@backstage/core-plugin-api';
import {
  buildkiteApiRef,
  BuildkiteClient,
} from '@buildkite/backstage-plugin-buildkite';

export const apis: AnyApiFactory[] = [
  // ... other API factories
  createApiFactory({
    api: buildkiteApiRef,
    deps: { discoveryApi: discoveryApiRef, fetchApi: fetchApiRef },
    factory: ({ discoveryApi, fetchApi }) =>
      new BuildkiteClient({ discoveryApi, fetchApi }),
  }),
];
```

3. Configure routes in `packages/app/src/App.tsx`:

```typescript
import { BuildkitePage } from '@buildkite/backstage-plugin-buildkite';

// In your routes
<Route path="/buildkite" element={<BuildkitePage />} />
```

4. Add to the Entity Page in `packages/app/src/components/catalog/EntityPage.tsx`:

```typescript
import {
  EntityBuildkiteContent,
  isBuildkiteAvailable,
} from '@buildkite/backstage-plugin-buildkite';

// Add to the CI/CD tab
const cicdContent = (
  <EntitySwitch>
    <EntitySwitch.Case if={isBuildkiteAvailable}>
      <EntityBuildkiteContent />
    </EntitySwitch.Case>
    {/* ... other CI/CD cases */}
  </EntitySwitch>
);
```

## Configuration

To link a component in your Backstage catalog to a Buildkite pipeline, add the following annotation to the component's `catalog-info.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    buildkite.com/pipeline-slug: organization-slug/pipeline-slug
spec:
  type: service
  owner: my-team
  lifecycle: production
```

The `pipeline-slug` should be in the format `organization-slug/pipeline-slug`, where:
- `organization-slug` is your Buildkite organization's slug
- `pipeline-slug` is the specific pipeline's slug

## Usage

Once configured, you can:

1. View build status directly on the component's overview page
2. Navigate to the CI/CD tab to see detailed build information
3. Filter builds by status, branch, or other criteria
4. Click on individual builds to view logs and artifacts
5. Trigger new builds directly from Backstage

## Troubleshooting

### API token issues

If you're experiencing authentication errors, verify that:
- Your API token has all required permissions
- The token is correctly set in your environment variables
- The proxy configuration in `app-config.yaml` is correct

### Pipeline not showing

If your pipeline isn't appearing in Backstage:
- Check that the annotation format is correct: `organization-slug/pipeline-slug`
- Verify the pipeline slug matches exactly what's shown in your Buildkite URL
- Ensure the component has been properly registered in your Backstage catalog

## Further reading

- [Buildkite Backstage Plugin GitHub Repository](https://github.com/buildkite/backstage-plugin)
- [Backstage Documentation](https://backstage.io/docs/overview/what-is-backstage)
- [Buildkite API Documentation](/docs/apis/rest_api)