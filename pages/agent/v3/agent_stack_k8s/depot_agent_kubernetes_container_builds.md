---
toc_include_h3: false
---

# Container builds with Depot

[Depot](https://depot.dev/) provides remote builders that accelerate Docker builds by running them on dedicated build infrastructure. You can use Depot to build container images on agents that are auto-scaled by the [Buildkite Agent Stack for Kubernetes](/docs/agent/v3/agent-stack-k8s), offloading build workloads from your Kubernetes cluster to Depot's optimized build infrastructure.

> 🚧 Warning!
> The Depot installation method uses `curl | sh`, which executes scripts directly. Review the installation script before using it in production environments. Consider downloading and verifying the script separately, or installing [Depot CLI](https://github.com/depot/cli) in your base agent image for better security control.

## Special considerations regarding Agent Stack for Kubernetes

When using Depot with the Buildkite Agent Stack for Kubernetes, consider the following requirements and best practices for successful container builds.

### Depot project configuration

Depot requires a project ID to route builds to the correct infrastructure. You can configure your Depot project in a number of different ways by using either:

1. Environment variable `DEPOT_PROJECT_ID`.
1. Configuration file `depot.json` in your repository.
1. Command-line flag `--project` in `depot` commands.

#### Environment variable approach (recommended for Kubernetes)

Set `DEPOT_PROJECT_ID` in your Kubernetes pod specification. This approach is recommended for Kubernetes environments as it's easier to manage via secrets and doesn't require repository changes:

```yaml
# values.yaml
config:
  pod-spec-patch:
    env:
      - name: DEPOT_PROJECT_ID
        value: "your-project-id"
```

#### Configuration file (depot.json) approach

Use `depot init` to create a `depot.json` file in your repository. You'll need to authenticate with Depot first to select from your available projects:

```bash
# Authenticate with Depot
depot login

# Initialize the project configuration
depot init
```

The `depot init` command creates a `depot.json` file in the current directory with the following format:

```json
{
  "id": "your-project-id"
}
```

This file is automatically detected by the Depot CLI when present in your repository root. The `depot.json` file should be committed to your repository.

#### Command-line flag approach

You can specify the project ID using the `--project` flag when using `depot` commands directly:

```yaml
steps:
  - label: "\:docker\: Build with depot command"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot build --project=your-project-id -t my-image .
```

Note that when you are using `depot configure-docker`, the project ID should be specified via `DEPOT_PROJECT_ID` environment variable or `depot.json` file, as this configures standard `docker build` commands to use Depot.

For Kubernetes environments, using the environment variable approach is recommended as it provides the most flexibility and doesn't require repository changes.

### Depot CLI installation

Depot integrates with Docker via a CLI plugin. The [Depot CLI](https://github.com/depot/cli) must be installed in your build containers to enable remote builds. You can install it in your base agent image or as part of your build steps.

Install the Depot CLI in your agent image:

```dockerfile
FROM buildkite/agent:latest

# Install Depot CLI
# Note: Review the installation script before using in production
RUN curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
```

Alternatively, you can install it at runtime in your build steps:

```yaml
steps:
  - label: "Install Depot and build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
```

### Authentication

Depot requires authentication to access your projects. Depot supports [OIDC trust relationships with Buildkite](/docs/pipelines/security/oidc), which is the recommended authentication method as it provides ephemeral tokens without managing static credentials.

#### OIDC trust relationships (recommended)

Configure an OIDC trust relationship between Buildkite and Depot to use ephemeral tokens automatically. This eliminates the need to manage static tokens and improves security.

To do it, you need to set up the OIDC trust relationship in your Depot project settings, then configure your Buildkite pipeline to use it:

```yaml
# values.yaml
config:
  pod-spec-patch:
    env:
      - name: DEPOT_PROJECT_ID
        value: "your-project-id"
      # OIDC authentication is handled automatically by Depot CLI
      # No DEPOT_TOKEN needed when using OIDC trust relationships
```

The Depot CLI automatically detects Buildkite's OIDC credentials and uses them for authentication when an OIDC trust relationship is configured.

#### Static token authentication (alternative)

For environments where OIDC is not available, you can use static project tokens. Store your Depot token as a Kubernetes secret and mount it as an environment variable in your build pods.

Create a Kubernetes secret for your Depot token:

```bash
kubectl create secret generic depot-token \
  --from-literal=token=<your-depot-token> \
  --namespace buildkite
```

Configure the Agent Stack to use the Depot token:

```yaml
# values.yaml
config:
  pod-spec-patch:
    env:
      - name: DEPOT_TOKEN
        valueFrom:
          secretKeyRef:
            name: depot-token
            key: token
      - name: DEPOT_PROJECT_ID
        value: "your-project-id"
```

> 🚧 Warning!
> Static tokens persist until rotated. OIDC trust relationships provide ephemeral tokens that automatically expire, reducing the risk of credential exposure. Use OIDC whenever possible.

### Build context and file access

Depot builds require access to your build context, which is typically the checked-out repository in the pod's filesystem. Ensure your build context is accessible and includes all necessary files for the build.

For large build contexts, Depot efficiently handles context uploads and can optimize transfers. However, consider using `.dockerignore` files to exclude unnecessary files from the build context, which Depot respects when uploading the build context.

### Resource allocation

Since builds run on Depot's infrastructure, your Kubernetes pods don't need to allocate resources for Docker daemons or build processes. This allows you to use smaller, more cost-effective pods that primarily handle:

- Repository checkout
- Build orchestration
- Artifact handling
- Post-build steps

## Configuration approaches with Depot

Depot supports various workflow patterns for building container images, each suited to specific use cases in Kubernetes environments.

> 📘
> The examples below include `DEPOT_TOKEN` in the environment variables. If you're using OIDC trust relationships (recommended), you can omit `DEPOT_TOKEN` as authentication is handled automatically. Only include `DEPOT_TOKEN` when using static token authentication.

### Basic Docker build with Depot

You can build images using Depot's remote builders with standard `docker build` commands. Configure Depot before building:

```yaml
steps:
  - label: "\:docker\: Build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

A sample Dockerfile would look like this:

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

CMD ["node", "server.js"]
```

### Building and pushing with Depot

Build and push images using Depot's remote builders:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
      docker push your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

If you're using a private repository, authenticate before pushing:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      echo "${REGISTRY_PASSWORD}" | docker login your-registry.example.com -u "${REGISTRY_USERNAME}" --password-stdin
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
      docker push your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
      REGISTRY_USERNAME: "${REGISTRY_USERNAME}"
      REGISTRY_PASSWORD: "${REGISTRY_PASSWORD}"
```

### Using Depot with Docker Buildx

Depot integrates with Docker Buildx for advanced build features, including multi-platform builds:

```yaml
steps:
  - label: "\:docker\: Multi-platform build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} \
        --push \
        .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

### Using Depot with Docker Compose

Depot works seamlessly with Docker Compose builds. Configure Depot before running compose builds:

```yaml
steps:
  - label: "\:docker\: Build with Depot and Docker Compose"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker compose build
      docker compose push
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Alternatively, you can use Depot's `bake` command for parallel Compose builds:

```yaml
steps:
  - label: "\:docker\: Build with Depot bake"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot bake --load -f ./docker-compose.yml
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

## Customizing builds with Depot

You can customize your Depot builds by using Depot-specific features and configuration options.

### Using build arguments

Pass build arguments to customize image builds at build time:

```yaml
steps:
  - label: "\:docker\: Build with arguments using Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build \
        --build-arg NODE_ENV=production \
        --build-arg BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER} \
        --build-arg API_URL=${API_URL} \
        -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} \
        .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

### Multi-platform builds

Build for multiple architectures using Depot's multi-platform support:

```yaml
steps:
  - label: "\:docker\: Multi-platform build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} \
        -t your-registry.example.com/app:latest \
        --push \
        .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

### Using Depot cache

Depot provides automatic caching for faster builds. Depot manages cache automatically using its own infrastructure, but you can also configure registry-based cache for additional control:

```yaml
steps:
  - label: "\:docker\: Build with Depot and registry cache"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker buildx build \
        --cache-from type=registry,ref=your-registry.example.com/app:cache \
        --cache-to type=registry,ref=your-registry.example.com/app:cache,mode=max \
        -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} \
        --push \
        .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Depot provides native caching that works automatically when you use `depot configure-docker` — so no additional configuration is required. Depot manages cache layers on its infrastructure, which persist across builds within the same project. The registry cache example above is optional and provides additional cache persistence across different build environments or projects.

## Troubleshooting

This section can help you to identify and solve the issues that might arise when using Depot with Buildkite Pipelines on Kubernetes.

### Depot authentication failures

Builds fail with authentication errors when Depot cannot access your project.

#### Missing or invalid authentication credentials or project ID

For OIDC trust relationships (recommended), ensure the trust relationship is configured in your Depot project settings and that `DEPOT_PROJECT_ID` is set in your pipeline:

```yaml
config:
  pod-spec-patch:
    env:
      - name: DEPOT_PROJECT_ID
        value: "your-project-id"
      # OIDC authentication handled automatically, no DEPOT_TOKEN needed
```

For static token authentication, ensure your Depot token and project ID are correctly configured:

```yaml
config:
  pod-spec-patch:
    env:
      - name: DEPOT_TOKEN
        valueFrom:
          secretKeyRef:
            name: depot-token
            key: token
      - name: DEPOT_PROJECT_ID
        value: "your-project-id"
```

Verify authentication by checking your Depot dashboard. For OIDC, ensure the trust relationship is active. For static tokens, verify the token has access to the specified project.

### Depot CLI not found

Builds fail with "depot: command not found" errors.

#### Depot CLI is not installed in the build container.

You need to install Depot CLI before using it:

```yaml
steps:
  - label: "Install Depot CLI"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

Alternatively, include Depot CLI installation in your base agent image.

### Build context upload failures

Builds fail when uploading build context to Depot.

#### Network issues or build context too large.

To troubleshoot this issue:

- Check network connectivity from your Kubernetes pods to Depot
- Verify firewall rules allow outbound HTTPS traffic to `depot.dev`
- Use `.dockerignore` files to reduce build context size
- Check Depot service status

### Docker not configured for Depot

Builds run locally instead of on Depot infrastructure.

#### Depot Docker plugin not configured

Run `depot configure-docker` before building:

```yaml
steps:
  - label: "Configure and build"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

You can confirm builds are using Depot by looking for `[depot]` prefixed log lines in the build output.

### Registry push failures

Pushing images to registries fails after Depot builds.

#### Authentication or network issues when pushing from Depot infrastructure.

Ensure registry credentials are properly configured. For private registries, authenticate before pushing:

```yaml
steps:
  - label: "\:docker\: Build and push with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      echo "${REGISTRY_PASSWORD}" | docker login your-registry.example.com -u "${REGISTRY_USERNAME}" --password-stdin
      docker build -t your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER} .
      docker push your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
      REGISTRY_USERNAME: "${REGISTRY_USERNAME}"
      REGISTRY_PASSWORD: "${REGISTRY_PASSWORD}"
```

Note that Depot builds run on Depot infrastructure, so registry authentication must be configured to work from remote builders.

## Debugging builds

When builds fail or behave unexpectedly with Depot, use these debugging approaches to diagnose issues.

### Enable verbose output

Use Docker's build output to see detailed build information. Depot builds will show `[depot]` prefixed log lines indicating Depot is handling the build:

```yaml
steps:
  - label: "\:docker\: Debug build with Depot"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      docker build --progress=plain -t my-image .
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

The `--progress=plain` flag shows detailed build output, and you can verify Depot is being used by looking for `[depot]` prefixed lines in the build logs.

### Check Depot build logs

View build logs in the Depot dashboard to see detailed information about build execution, including:

- Build context upload progress
- Layer build steps
- Cache hit/miss information
- Error details

Access your Depot dashboard to view build history and logs for troubleshooting.

### Verify Depot configuration

Test Depot configuration before running builds:

```yaml
steps:
  - label: "Verify Depot setup"
    command: |
      curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh
      depot configure-docker
      depot projects list
    env:
      DEPOT_PROJECT_ID: "${DEPOT_PROJECT_ID}"
      DEPOT_TOKEN: "${DEPOT_TOKEN}"
```

This verifies authentication and project access before attempting builds.

### Test builds locally

Test your Dockerfile and build configuration locally before running on Kubernetes:

```bash
# Install Depot CLI locally
curl -L https://depot.dev/install-cli.sh | DEPOT_INSTALL_DIR=/usr/local/bin sh

# Configure Depot
depot configure-docker

# Test build
docker build -t my-image .

# Verify build uses Depot (look for [depot] in output)
```

This helps identify issues with build configuration before running in Kubernetes environments.
