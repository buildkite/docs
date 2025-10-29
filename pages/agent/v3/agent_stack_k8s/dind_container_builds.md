# Docker-in-Docker (DinD) container builds

[Docker-in-Docker (DinD)](https://hub.docker.com/_/docker) allows you to run a Docker daemon inside a container, enabling standard Docker commands like `docker build` and `docker run` within a [job](/docs/pipelines/glossary#job). This approach is useful when you need full Docker CLI compatibility or want to build and test container images using familiar Docker workflows.

## How Docker-in-Docker works

Docker-in-Docker enables container builds by running a Docker daemon inside a sidecar container alongside your main job container. The sidecar container runs the Docker daemon (`docker:dind`) with elevated privileges, while your main container connects to this daemon through a shared Docker socket.

This setup allows your Buildkite jobs to execute standard Docker operations (like `docker build` and `docker push`) from within the main container, while the actual container management is handled by the daemon in the sidecar.

## Using Docker-in-Docker as a sidecar container

The following pipeline example demonstrates how to build a container image using Docker-in-Docker with the Buildkite Kubernetes plugin's [`sidecars` feature](https://buildkite.com/docs/agent/v3/agent-stack-k8s/sidecars), and sharing the Docker socket using Volume mounts.

```yaml
  - label: "Testing the sidecar approach"
    env:
      DOCKER_HOST: tcp://localhost:2375
    image: alpine/docker-with-buildx:latest
    command: docker build ./dind -t myregistry.com/myimage:latest
    plugins:
      - kubernetes:
          sidecars:
          - image: docker:dind
            command: [dockerd-entrypoint.sh]
            securityContext:
              privileged: true
            env:
              - name: DOCKER_TLS_CERTDIR
                value: ""
```

### Understanding the components

This section describes the key components for configuring Docker-in-Docker with the sidecar pattern in Kubernetes.

#### Configure the sidecar container

- **`image: docker:dind`**: The official Docker-in-Docker image containing the Docker daemon
- **`command: [dockerd-entrypoint.sh]`**: Starts the Docker daemon in the sidecar
- **`DOCKER_TLS_CERTDIR: ""`**: Disables TLS since sidecar containers use local socket communication
- **`privileged: true`**: Provides elevated permissions on the host. This is required for the Docker daemon to create containers

#### Configure the main container for build in the command step

- **`image:`**: Specify the image that contains the Docker CLI tools (`docker`, `docker-compose`, etc.)
- **`command`**: Your Docker build commands

## Security considerations

Running Docker-in-Docker requires privileged containers. It is recommended to use Docker-in-Docker in trusted environments. Consider alternatives like [BuildKit](/docs/agent/v3/agent-stack-k8s/buildkit-container-builds) for enhanced security.

## Troubleshooting

This section describes common issues with Docker-in-Docker and the ways to resolve them.

### Cannot connect to the Docker daemon

- Ensure that the DOCKER_HOST environment variable is set correctly
- Check if there is a race condition in connecting to the Docker daemon between the main container and the sidecar container

### Permission denied while trying to connect to the Docker daemon socket

- Ensure the sidecar has `privileged: true` 
- Check that your cluster's security policies allow privileged containers
