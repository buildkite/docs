---
toc_include_h3: false
---

# Docker Compose builds

The [Docker Compose plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) helps you build and run multi-container Docker applications. This guide shows how to build and push container images using the Docker Compose plugin on agents that are auto-scaled by the Buildkite Agent Stack for Kubernetes.

## Basic Docker Compose build

Build services defined in your `docker-compose.yml` file:

```yaml
steps:
  - label: "Build with Docker Compose"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          config: docker-compose.yml
```

Sample `docker-compose.yml` file:

```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: your-registry.example.com/your-team/app:bk-${BUILDKITE_BUILD_NUMBER}
```

## Building and pushing with the Docker Compose plugin

Build and push images in a single step:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: build
    plugins:
      - docker-compose#v5.11.0:
          build: "app"
          push:
            - "app"
```

If you're using a private repository, add authentication:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: build
    plugins:
      - docker-login#v3.1.0:
          registry: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.11.0:
          build: "app"
          push:
            - "app"
```

## Configuration approaches

The Docker Compose plugin supports different workflow patterns for building and pushing container images, each suited to specific use cases in Kubernetes environments.

### Build-only workflow

Pre-build images in an early pipeline step to avoid redundant builds when distributing work across multiple agents. Built images are stored and can be referenced by subsequent pipeline steps on different agents.

```yaml
steps:
  - label: "\:docker\: Build images"
    agents:
      queue: build
    plugins:
      - docker-compose#v5.11.0:
          build:
            - app
            - worker
          image-repository: your-registry.example.com/your-team

  - wait

  - label: "\:package\: Use built images"
    agents:
      queue: deploy
    command: |
      # Built images are available on subsequent steps
      docker images
```

### Build-and-push workflow

Build and push images in a single step for complete CI/CD workflows. This is the most common pattern for deploying container images to registries.

```yaml
steps:
  - label: "\:docker\: Build and push to registry"
    agents:
      queue: build
    plugins:
      - docker-login#v3.1.0:
          registry: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.11.0:
          build: app
          image-repository: your-registry.example.com/your-team
          push:
            - app:your-registry.example.com/your-team/app:${BUILDKITE_BUILD_NUMBER}
            - app:your-registry.example.com/your-team/app:latest
```

### Multi-service builds

Build multiple services from a single `docker-compose.yml` file. This approach works well for microservices architectures where multiple related services are built together.

```yaml
steps:
  - label: "\:docker\: Build microservices"
    agents:
      queue: build
    plugins:
      - docker-compose#v5.11.0:
          build:
            - frontend
            - backend
            - api
          push:
            - frontend
            - backend
            - api
```

## Customizing the build

Customize your Docker Compose builds by using the plugin's configuration options to control build behavior, manage credentials, and optimize performance.

### Using build arguments

Pass build arguments to customize image builds at runtime. Build arguments let you parameterize Dockerfiles without embedding values directly in the file.

```yaml
steps:
  - label: "\:docker\: Build with arguments"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          args:
            - NODE_ENV=production
            - BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER}
            - API_URL=${API_URL}
```

### Building specific services

When your `docker-compose.yml` defines multiple services, build only the services you need rather than building everything.

```yaml
steps:
  - label: "\:docker\: Build frontend only"
    plugins:
      - docker-compose#v5.11.0:
          build:
            - frontend
          push:
            - frontend
```

### Using BuildKit features with cache optimization

Enable BuildKit to use advanced build features including build cache optimization. BuildKit's inline cache stores cache metadata in the image itself, enabling cache reuse across different build agents.

```yaml
steps:
  - label: "\:docker\: Build with BuildKit cache"
    plugins:
      - docker-login#v3.1.0:
          registry: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.11.0:
          build: app
          image-repository: your-registry.example.com/your-team
          cache-from:
            - app:your-registry.example.com/your-team/app:cache
          build-kit: true
          buildkit-inline-cache: true
          push:
            - app:your-registry.example.com/your-team/app:${BUILDKITE_BUILD_NUMBER}
            - app:your-registry.example.com/your-team/app:cache
```

### Using multiple compose files

Combine multiple compose files to create layered configurations. This pattern works well for separating base configuration from environment-specific overrides.

```yaml
steps:
  - label: "\:docker\: Build with compose file overlay"
    plugins:
      - docker-compose#v5.11.0:
          config:
            - docker-compose.yml
            - docker-compose.production.yml
          build: app
          push: app
```

### Custom image tagging on push

Push the same image with multiple tags to support different deployment strategies. This is useful for maintaining both immutable version tags and mutable environment tags.

```yaml
steps:
  - label: "\:docker\: Push with multiple tags"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          push:
            - app:your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
            - app:your-registry.example.com/app:${BUILDKITE_COMMIT}
            - app:your-registry.example.com/app:latest
            - app:your-registry.example.com/app:${BUILDKITE_BRANCH}
```

### Using SSH agent for private repositories

Enable SSH agent forwarding to access private Git repositories or packages during the build. This is essential when Dockerfiles need to clone private dependencies.

```yaml
steps:
  - label: "\:docker\: Build with SSH access"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          ssh: true
```

Your Dockerfile needs to use BuildKit's SSH mount feature:

```dockerfile
# syntax=docker/dockerfile:1
FROM node:18

# Install dependencies from private repository
RUN --mount=type=ssh git clone git@github.com:yourorg/private-lib.git
```

### Propagating cloud credentials

Automatically pass cloud provider credentials to containers for pushing images to cloud-hosted registries.

For AWS Elastic Container Registry (ECR):

```yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          image-repository: 123456789.dkr.ecr.us-west-2.amazonaws.com
          propagate-aws-auth-tokens: true
          push:
            - app:123456789.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BUILD_NUMBER}
```

For Google Container Registry (GCR):

```yaml
steps:
  - label: "\:docker\: Build and push to GCR"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          image-repository: gcr.io/your-project
          propagate-gcp-auth-tokens: true
          push:
            - app:gcr.io/your-project/app:${BUILDKITE_BUILD_NUMBER}
```

## Special considerations for Kubernetes

When running these plugins within the Buildkite Agent Stack for Kubernetes, consider the following requirements and best practices for successful container builds.

### Docker daemon access

The Docker Compose plugin requires access to a Docker daemon. In Kubernetes, you have two main approaches:

_Mounting the host Docker socket_: Mount `/var/run/docker.sock` from the host into your pod. This is simpler but shares the host's Docker daemon with all pods. Ensure your Kubernetes cluster security policies allow socket mounting.

_Docker-in-Docker (DinD)_: Run a Docker daemon inside your pod using a DinD sidecar container. This provides better isolation but requires `privileged: true` or specific security capabilities. DinD adds complexity and resource overhead but avoids sharing the host daemon.

### Permission handling with the propagate-uid-gid option

When mounting the Docker socket or using shared volumes, you may encounter permission mismatches between the container user and file ownership. The plugin's `propagate-uid-gid` option runs the Docker Compose commands with the same user ID and group ID as the agent, preventing permission errors on mounted volumes.

```yaml
plugins:
  - docker#v5.8.0:
      propagate-uid-gid: true
  - docker-compose#v5.11.0:
      build: app
      push: app
```

Use this option when you see "permission denied" errors related to file access in build contexts or when writing artifacts to mounted volumes.

### Build context and volume mounts

In Kubernetes, the build context is typically the checked-out repository in the pod's filesystem. By default, the plugin uses the current working directory as the build context. If your `docker-compose.yml` references files outside this directory, use the `mount-checkout` option or configure explicit volume mounts.

For build caching or sharing artifacts across builds, mount persistent volumes or use Kubernetes persistent volume claims. Note that ephemeral pod storage is lost when the pod terminates.

### Registry authentication

Set up proper authentication for pushing to container registries. Use the `docker-login` plugin for standard Docker registries or use `propagate-aws-auth-tokens` or `propagate-gcp-auth-tokens` for cloud-provider registries. For services you push, ensure `image:` is set in `docker-compose.yml` to specify the full registry path.

### Resource allocation

Building container images can be resource-intensive, especially for large applications or when building multiple services. Configure your Kubernetes agent pod resources accordingly:

- Allocate sufficient memory for the build process and any running services
- Provide adequate CPU resources to avoid slow builds
- Ensure sufficient ephemeral storage for Docker layers and build artifacts

Monitor resource usage during builds and adjust pod resource requests and limits as needed.

## Troubleshooting

### Permission issues

Docker commands may fail with "permission denied" errors when trying to access the Docker socket (`/var/run/docker.sock`). This happens when there's a mismatch between the container user's permissions and the socket owner (typically root or the docker group).

If you encounter permission problems with the Docker socket, ensure your Kubernetes pod has the right permissions or consider using `propagate-uid-gid: true` with the Docker plugin:

```yaml
plugins:
  - docker#v5.8.0:
      propagate-uid-gid: true
  - docker-compose#v5.11.0:
      build: ["app"]
      push: ["app"]
```

You can also use Docker-in-Docker (DinD) instead of mounting the host socket. This runs the Docker daemon inside your pod, avoiding socket permission issues entirely, but this approach adds complexity and resource overhead.

### Network connectivity

Builds may fail with errors like "could not resolve host," "connection timeout," or "unable to pull image" when trying to pull base images from Docker Hub or push to your private registry. Network policies, firewall rules, or DNS configuration issues can restrict Kubernetes networking.

To resolve these issues, verify that your Kubernetes pods have network access to Docker Hub and your registry. Check your cluster's network policies, firewall rules, and DNS configuration.

### Resource constraints

Docker builds may fail with errors like "signal: killed," "build container exited with code 137," or builds that hang indefinitely and timeout. These usually signal insufficient memory or CPU resources allocated to your Kubernetes pods, causing the Linux kernel to kill processes (Out of Memory or OOM).

To resolve these issues, check your pod's resource requests and limits. Use `kubectl describe pod` to view the current resource allocation and `kubectl top pod` to monitor actual usage. Increase the memory and CPU limits in your agent configuration if builds consistently fail due to resource constraints.

### Build cache not working

Docker builds rebuild all layers even when source files haven't changed. This happens when build cache is not preserved between builds or when cache keys don't match.

To enable build caching with BuildKit:

```yaml
plugins:
  - docker-compose#v5.11.0:
      build: app
      cache-from:
        - app:your-registry.example.com/app:cache
      build-kit: true
      buildkit-inline-cache: true
      push:
        - app:your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
        - app:your-registry.example.com/app:cache
```

Ensure the cache image exists in your registry before the first build, or accept that the initial build will be slower. Subsequent builds will use the cached layers.

### Environment variables not available during build

Environment variables from your Buildkite pipeline aren't accessible inside your Dockerfile during the build process. Docker builds are isolated and don't automatically inherit environment variables.

To pass environment variables to the build, use build arguments:

```yaml
plugins:
  - docker-compose#v5.11.0:
      build: app
      args:
        - API_URL=${API_URL}
        - BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER}
```

Then reference them in your Dockerfile:

```dockerfile
ARG API_URL
ARG BUILD_NUMBER
RUN echo "Building version ${BUILD_NUMBER}"
```

Note that `args` passes variables at build time, while the `environment` option passes variables at runtime (for running containers, not building images).

### Volume mount permission issues

Files created by Docker builds or containers may have incorrect ownership, causing "permission denied" errors when the pipeline tries to access them.

This occurs because Docker typically runs as root inside containers, creating files owned by root, while the Buildkite agent may run as a different user.

Enable `propagate-uid-gid` to match container and host user IDs:

```yaml
plugins:
  - docker#v5.8.0:
      propagate-uid-gid: true
  - docker-compose#v5.11.0:
      build: app
```

Alternatively, explicitly set user ownership in your Dockerfile:

```dockerfile
RUN chown -R 1000:1000 /app/output
```

### Image push failures

Pushing images to registries fails with authentication errors or timeout errors.

For authentication failures, ensure credentials are properly configured. Use the `docker-login` plugin before the `docker-compose` plugin:

```yaml
plugins:
  - docker-login#v3.1.0:
      registry: your-registry.example.com
      username: "${REGISTRY_USERNAME}"
      password-env: "REGISTRY_PASSWORD"
  - docker-compose#v5.11.0:
      build: app
      push: app
```

For cloud-provider registries, use the appropriate credential propagation:

```yaml
plugins:
  - docker-compose#v5.11.0:
      build: app
      propagate-aws-auth-tokens: true  # For AWS ECR
      # or propagate-gcp-auth-tokens: true  # For Google GCR
      push: app
```

For timeout or network failures, enable push retries:

```yaml
plugins:
  - docker-compose#v5.11.0:
      build: app
      push: app
      push-retries: 3
```

## Debugging builds

When builds fail or behave unexpectedly, enable verbose output and disable caching to diagnose the issue.

### Enable verbose output

Use the `verbose` option to see detailed output from Docker Compose operations:

```yaml
steps:
  - label: ":docker: Debug build"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          verbose: true
```

This shows all Docker Compose commands being executed and their full output, helping identify where failures occur.

### Disable build cache

Disable caching to ensure builds run from scratch, which can reveal caching-related issues:

```yaml
steps:
  - label: ":docker: Build without cache"
    plugins:
      - docker-compose#v5.11.0:
          build: app
          no-cache: true
```

### Inspect build logs in Kubernetes

For builds running in Kubernetes, access pod logs to see detailed build output:

```bash
# List pods for your build
kubectl get pods -l buildkite.com/job-id=<job-id>

# View logs from the build pod
kubectl logs <pod-name>

# Follow logs in real-time
kubectl logs -f <pod-name>
```

### Test docker-compose locally

Test your `docker-compose.yml` configuration locally before running in the pipeline:

```bash
# Validate compose file syntax
docker-compose config

# Build without the plugin
docker-compose build

# Check what images were created
docker images
```

This helps identify issues with the compose configuration itself, separate from pipeline or Kubernetes concerns.
