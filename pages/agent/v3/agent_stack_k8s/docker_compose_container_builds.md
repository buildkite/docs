---
toc_include_h3: false
---

# Docker Compose builds

The [Buildkite Docker Compose plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin) helps you build and run multi-container Docker applications. This guide shows how to build and push container images using the Docker Compose plugin on agents that are auto-scaled by the Buildkite Agent Stack for Kubernetes.

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

Sample docker-compose.yml file:

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
  - label: ":docker: Build and push"
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
  - label: ":docker: Build and push"
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

## Special considerations for Kubernetes

When running these plugins within the Buildkite Agent Stack for Kubernetes:

- Ensure your Kubernetes pods have access to the Docker socket or provide Docker-in-Docker capabilities.
- Set up proper authentication for pushing to container registries. Use the `docker-login` plugin or a registry-specific plugin. For services you push, ensure `image:` is set in `docker-compose.yml`.
- Building container images can be resource-intensive, so configure your Kubernetes agent resources accordingly.

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
