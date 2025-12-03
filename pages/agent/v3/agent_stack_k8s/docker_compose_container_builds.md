---
toc_include_h3: false
---

# Docker Compose builds

The [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) helps you build and run multi-container Docker applications. You can build and push container images using the Docker Compose plugin on agents that are auto-scaled by the Buildkite Agent Stack for Kubernetes.

## Special considerations regarding Agent Stack for Kubernetes

When running the [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) within the Buildkite Agent Stack for Kubernetes, consider the following requirements and best practices for successful container builds.

### Docker daemon access

The Docker Compose plugin requires access to a Docker daemon and you can choose one of two primary approaches:

- Mounting the host Docker socket
- [Docker-in-Docker (DinD)](https://hub.docker.com/_/docker)

Let's look into both approaches in more detail.

#### Mounting the host Docker socket

Mount `/var/run/docker.sock` from the host into your pod.

In this approach, you need to remember that the host's Docker daemon will be shared with all pods that mount it.

Since all pods share the same Docker daemon, there's no resource isolation between them. If one pod's build exhausts or corrupts the daemon, all the other pods will be impacted. You're also limited to a single daemon configuration across all pods.

This approach grants containers near-root-level access to the host, meaning any process with socket access can control the host Docker daemon. This poses container breakout risks if running untrusted workloads.

> 🚧 Warning!
> Only use this approach with trusted repositories, run your agents on dedicated nodes, and scope access according to your Kubernetes security policies.

#### Docker-in-Docker (DinD)

Run a Docker daemon inside your pod using a DinD sidecar container. DinD can add complexity and resource overhead but it avoids sharing the host daemon.

In this approach, you need to use a dedicated sidecar container for each build. Only set `DOCKER_TLS_CERTDIR=""` to disable TLS if the network scope is local to the pod. Avoid exposing host ports to restrict network access. Set resource limits to prevent excess consumption.

Running a separate Docker daemon in each pod slows down build performance and increases resource usage. Operations and debugging can be more complex since you need to configure and maintain multiple daemons. You will need to handle network configuration for daemon communication within each pod.

> 🚧 Warning!
> The isolation in this approach is better than in the previous approach but still requires setting `privileged: true` or specific security capabilities. This increases the kernel attack surface inside your pod and misconfiguration can leave the Docker API exposed without proper authentication, creating a security risk.

### Using Docker-in-Docker with pod-spec-patch

To add a DinD sidecar container for the Buildkite Agent Stack for Kubernetes, use `pod-spec-patch` in the controller's configuration. This approach provides better isolation and security compared to mounting the host Docker socket. The configuration uses Kubernetes native sidecars (available in Kubernetes version 1.28+) by setting `restartPolicy: Always` on an initContainer, which starts before your build containers and continues running throughout the pod's lifecycle.

You can configure the Docker daemon to be accessible using TCP socket or Unix socket, depending on your needs.

#### TCP socket configuration

Configure the DinD sidecar to listen on a TCP socket, which allows the build containers to connect over the network:

```yaml
# values.yaml
config:
  pod-spec-patch:
    initContainers:
      - name: docker-daemon
        image: docker:dind
        restartPolicy: Always
        securityContext:
          privileged: true
        args:
          - "--host=tcp://127.0.0.1:2375"
        env:
          - name: DOCKER_TLS_CERTDIR
            value: ""
        volumeMounts:
          - name: docker-storage
            mountPath: /var/lib/docker
        startupProbe:
          tcpSocket:
            port: 2375
          initialDelaySeconds: 5
          periodSeconds: 2
          timeoutSeconds: 1
          successThreshold: 1
          failureThreshold: 30
    volumes:
      - name: docker-storage
        emptyDir: {}
```

The `startupProbe` ensures the Docker daemon is listening on port `2375` before the build containers start. This prevents the build steps from attempting to connect to the Docker daemon before it's ready.

Configure your pipeline steps to connect using TCP by setting the `DOCKER_HOST` environment variable:

```yaml
steps:
  - label: "\:docker\: Build with DinD"
    plugins:
      - docker-compose#v5.12.1:
          build: app
          push: app
    env:
      DOCKER_HOST: tcp://127.0.0.1:2375
```

This configuration exposes the Docker daemon on `127.0.0.1:2375` without TLS for use by your build step. The TCP socket (`tcp://127.0.0.1:2375`) is unencrypted, which is acceptable for local communication inside a single pod, but must not be exposed externally. For TLS-enabled communication (commonly port `2376`), provide certificates instead of disabling `DOCKER_TLS_CERTDIR`.

#### Unix socket configuration

Alternatively, configure the DinD sidecar to use a Unix socket shared using a volume mount:

```yaml
# values.yaml
config:
  pod-spec-patch:
    initContainers:
      - name: docker-daemon
        image: docker:dind
        restartPolicy: Always
        securityContext:
          privileged: true
        args:
          - "--host=unix:///var/run/docker.sock"
        env:
          - name: DOCKER_TLS_CERTDIR
            value: ""
        volumeMounts:
          - name: docker-storage
            mountPath: /var/lib/docker
          - name: docker-socket
            mountPath: /var/run
    volumeMounts:
      - name: docker-socket
        mountPath: /var/run
    volumes:
      - name: docker-storage
        emptyDir: {}
      - name: docker-socket
        emptyDir: {}
```

Configure your pipeline steps to connect using the Unix socket. While `/var/run/docker.sock` is the default location and `DOCKER_HOST` is optional, setting it explicitly makes the configuration clearer:

```yaml
steps:
  - label: "\:docker\: Build with DinD"
    plugins:
      - docker-compose#v5.12.1:
          build: app
          push: app
    env:
      DOCKER_HOST: unix:///var/run/docker.sock
```

The Unix socket approach provides better security since the socket is only accessible within the pod and doesn't expose any network ports. However, the TCP socket approach is simpler to configure and debug.

### Build context and volume mounts

In Kubernetes, the build context is typically the checked-out repository in the pod's filesystem. By default, the [Docker Compose plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/) uses the current working directory as the build context. If your `docker-compose.yml` references files outside this directory, you need to configure explicit volume mounts in your Kubernetes pod specification.

For build caching or sharing artifacts across builds, mount persistent volumes or use Kubernetes persistent volume claims. Note that ephemeral pod storage is lost when the pod terminates. To learn more about caching, see [Caching best practices](/docs/pipelines/best-practices/caching).

### Registry authentication

Set up proper authentication for pushing to container registries:

- Use the `docker-login` plugin for standard Docker registries
- Use the `ecr` plugin for AWS ECR
- Use the `gcp-workload-identity-federation` plugin for Google Artifact Registry

When pushing services, ensure the `image:` field is set in `docker-compose.yml` to specify the full registry path.

### Resource allocation

Building container images can be resource-intensive, especially for large applications or when building multiple services. Configure your Kubernetes agent pod resources accordingly:

- Allocate sufficient memory for the build process, Docker daemon, and any running services
- Provide adequate CPU resources to avoid slow builds
- Ensure sufficient ephemeral storage for Docker layers, build artifacts, and intermediate files
- Account for DinD sidecar resource usage if using Docker-in-Docker

If the resource requests and limits are not specified, Kubernetes may schedule your pods on nodes with insufficient resources. This causes builds to fail with Out of Memory (OOM) errors or cluster termination. Monitor resource usage during builds using `kubectl top pod` and adjust limits as needed.

## Configuration approaches with the Docker Compose plugin

The Docker Compose plugin supports different workflow patterns for building and pushing container images, each suited to specific use cases in Kubernetes environments.

### Push to Buildkite Package Registries

Push a built image directly to Buildkite Package Registries:

```yaml
steps:
  - label: "\:docker\: Build and push to Buildkite Package Registries"
    plugins:
      - docker-login#v3.0.0:
          server: packages.buildkite.com/{org.slug}/{registry.slug}
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:packages.buildkite.com/{org.slug}/{registry.slug}/image-name:${BUILDKITE_BUILD_NUMBER}
```

### Basic Docker Compose build

Build services defined in your `docker-compose.yml` file:

```yaml
steps:
  - label: "Build with Docker Compose"
    plugins:
      - docker-compose#v5.12.1:
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

### Building and pushing with the Docker Compose plugin

Build and push images in a single step:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: build
    plugins:
      - docker-compose#v5.12.1:
          build: app
          push: app
```

If you're using a private repository, add authentication:

```yaml
steps:
  - label: "\:docker\: Build and push"
    agents:
      queue: build
    plugins:
      - docker-login#v3.0.0:
          server: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.12.1:
          build: app
          push: app
```

## Customizing the build

Customize your Docker Compose builds by using the Docker Compose plugin's configuration options to control build behavior, manage credentials, and optimize performance.

### Using build arguments

Pass build arguments to customize image builds at runtime. Build arguments allow you to add parameters to Dockerfiles without directly embedding values in the file.

```yaml
steps:
  - label: "\:docker\: Build with arguments"
    plugins:
      - docker-compose#v5.12.1:
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
      - docker-compose#v5.12.1:
          build: frontend
          push: frontend
```

### Using BuildKit features with cache optimization

[BuildKit](https://docs.docker.com/build/buildkit/) provides advanced build features including build cache optimization. BuildKit's inline cache stores cache metadata in the image itself, enabling cache reuse across different build agents. Here is an example configuration for building with BuildKit cache:

```yaml
steps:
  - label: "\:docker\: Build with BuildKit cache"
    plugins:
      - docker-login#v3.0.0:
          server: your-registry.example.com
          username: "${REGISTRY_USERNAME}"
          password-env: "REGISTRY_PASSWORD"
      - docker-compose#v5.12.1:
          build: app
          cache-from:
            - app:your-registry.example.com/app:cache
          buildkit: true
          buildkit-inline-cache: true
          push:
            - app:your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
            - app:your-registry.example.com/app:cache
```

### Using multiple compose files

Combine multiple compose files to create layered configurations. This pattern works well for separating base configuration from environment-specific overrides:

```yaml
steps:
  - label: "\:docker\: Build with compose file overlay"
    plugins:
      - docker-compose#v5.12.1:
          config:
            - docker-compose.yml
            - docker-compose.production.yml
          build: app
          push: app
```

### Custom image tagging on push

You can push the same image with multiple tags to support different deployment strategies. This is useful for maintaining both immutable version tags and mutable environment tags:

```yaml
steps:
  - label: "\:docker\: Push with multiple tags"
    plugins:
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
            - app:your-registry.example.com/app:${BUILDKITE_COMMIT}
            - app:your-registry.example.com/app:latest
            - app:your-registry.example.com/app:${BUILDKITE_BRANCH}
```

### Using SSH agent for private repositories

Enable SSH agent forwarding to access private Git repositories or packages during the build. Use this when Dockerfiles need to clone private dependencies:

```yaml
steps:
  - label: "\:docker\: Build with SSH access"
    plugins:
      - docker-compose#v5.12.1:
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

For [AWS Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/):

```yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    plugins:
      - ecr#v2.10.0:
          login: true
          account-ids: "123456789012"
          region: us-west-2
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:123456789012.dkr.ecr.us-west-2.amazonaws.com/app:${BUILDKITE_BUILD_NUMBER}
```

For [Google Artifact Registry (GAR)](https://docs.cloud.google.com/artifact-registry/docs):

```yaml
steps:
  - label: "\:docker\: Build and push to GAR"
    plugins:
      - gcp-workload-identity-federation#v1.5.0:
          project-id: your-project
          service-account: your-service-account@your-project.iam.gserviceaccount.com
      - docker-compose#v5.12.1:
          build: app
          push:
            - app:us-central1-docker.pkg.dev/your-project/your-repository/app:${BUILDKITE_BUILD_NUMBER}
```

## Troubleshooting

This section can help you to identify and solve the issues that most commonly arise when using Docker Compose container builds with Buildkite Pipelines.

### Network connectivity

Network policies, firewall rules, or DNS configuration issues can restrict Kubernetes networking. As a result, builds may fail with errors like "could not resolve host," "connection timeout," or "unable to pull image" when trying to pull base images from Docker Hub or push to your private registry.

To resolve these issues, verify that your Kubernetes pods have network access to Docker Hub and your registry. Check your cluster's network policies, firewall rules, and DNS configuration.

### Resource constraints

Docker builds may fail with errors like "signal: killed," "build container exited with code 137," or builds that hang indefinitely and timeout. These usually signal insufficient memory or CPU resources allocated to your Kubernetes pods, causing the Linux kernel to kill processes (Out of Memory or OOM).

To resolve these issues, check your pod's resource requests and limits. Use `kubectl describe pod` to view the current resource allocation and `kubectl top pod` to monitor actual usage. Increase the memory and CPU limits in your agent configuration if builds consistently fail due to resource constraints.

### Build cache not working

Docker builds rebuild all layers even when source files haven't changed. This happens when build cache is not preserved between builds or when cache keys don't match.

To enable build caching with BuildKit:

```yaml
plugins:
  - docker-compose#v5.12.1:
      build: app
      cache-from:
        - app:your-registry.example.com/app:cache
      buildkit: true
      buildkit-inline-cache: true
      push:
        - app:your-registry.example.com/app:${BUILDKITE_BUILD_NUMBER}
        - app:your-registry.example.com/app:cache
```

Ensure that the cache image exists in your registry before running the first build, or accept that the initial build will be slower. Subsequent builds will use the cached layers.

### Environment variables not available during build

Environment variables from your Buildkite pipeline aren't accessible inside your Dockerfile during the build process. Docker builds are isolated and don't automatically inherit environment variables.

To pass environment variables to the build, use build arguments:

```yaml
plugins:
  - docker-compose#v5.12.1:
      build: app
      args:
        - API_URL=${API_URL}
        - BUILD_NUMBER=${BUILDKITE_BUILD_NUMBER}
```

Then reference the passed environment variables in your Dockerfile:

```dockerfile
ARG API_URL
ARG BUILD_NUMBER
RUN echo "Building version ${BUILD_NUMBER}"
```

Note that the `args` option in the Docker Compose plugin passes variables at build time, while the `environment` option passes variables at runtime (for running containers, not building images).

### Image push failures

Pushing images to registries fails with authentication errors or timeout errors.

For authentication failures, ensure credentials are properly configured. Use the [`docker-login` plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-login-buildkite-plugin/) before the [`docker-compose` plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-compose-buildkite-plugin/):

```yaml
plugins:
  - docker-login#v3.0.0:
      server: your-registry.example.com
      username: "${REGISTRY_USERNAME}"
      password-env: "REGISTRY_PASSWORD"
  - docker-compose#v5.12.1:
      build: app
      push: app
```

For cloud-provider registries, use the appropriate authentication plugins:

```yaml
plugins:
  - ecr#v2.10.0:  # For AWS ECR
      login: true
      account-ids: "123456789012"
      region: us-west-2
  - docker-compose#v5.12.1:
      build: app
      push: app
```

And for Google Artifact Registry:

```yaml
plugins:
  - gcp-workload-identity-federation#v1.5.0:
      project-id: your-project
      service-account: your-service-account@your-project.iam.gserviceaccount.com
  - docker-compose#v5.12.1:
      build: app
      push: app
```

For timeout or network failures, enable push retries:

```yaml
plugins:
  - docker-compose#v5.12.1:
      build: app
      push: app
      push-retries: 3
```

## Debugging builds

When builds fail or behave unexpectedly, you need to enable verbose output and disable caching to diagnose the issue.

### Enable verbose output

Use the `verbose` option in the Docker Compose plugin to see detailed output from Docker Compose operations:

```yaml
steps:
  - label: "\:docker\: Debug build"
    plugins:
      - docker-compose#v5.12.1:
          build: app
          verbose: true
```

This shows all Docker Compose commands being executed and their full output, helping identify where failures occur.

### Disable build cache

Disable caching to ensure builds run from scratch, which can reveal caching-related issues:

```yaml
steps:
  - label: "\:docker\: Build without cache"
    plugins:
      - docker-compose#v5.12.1:
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
docker compose config

# Build without the Docker Compose plugin
docker compose build

# Check what images were created
docker images
```

This helps identify issues with the compose configuration itself, separate from pipeline or Kubernetes concerns.
