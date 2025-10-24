# Docker-in-Docker (DinD) container builds

[Docker-in-Docker (DinD)](https://hub.docker.com/_/docker) allows you to run a Docker daemon inside a container, enabling standard Docker commands like `docker build` and `docker run` within a [job](docs/pipelines/glossary#job). This approach is useful when you need full Docker CLI compatibility or want to build and test container images using familiar Docker workflows.

## How Docker-in-Docker works

Docker-in-Docker uses a sidecar container pattern where:

1. A Docker daemon (`docker:dind`) runs in a sidecar container with elevated privileges
2. Your job's main container communicates with this daemon through a shared Docker socket 

The Docker daemon in the sidecar handles all container operations, while your build commands run in the main container with access to the full Docker CLI.

## Using Docker-in-Docker as a sidecar container

The following pipeline example demonstrates how to build a container image using Docker-in-Docker with the Buildkite Kubernetes plugin's [`sidecars` feature](https://buildkite.com/docs/agent/v3/agent-stack-k8s/sidecars),and sharing the Docker socket using Volume mounts.

```yaml
steps:
  - label: "Testing the sidecar approach" 
    plugins:
      - kubernetes:
          sidecars:
          - image: docker:dind
            command: [dockerd-entrypoint.sh]
            env:
              - name: DOCKER_TLS_CERTDIR
                value: ""
            volumeMounts:
              - mountPath: /var/run/
                name: docker-sock
            securityContext:
              privileged: true 
          podSpec:
            containers:
              - image: alpine/docker-with-buildx:latest
                volumeMounts:
                  - mountPath: /var/run/
                    name: docker-sock
                command: 
                  - docker
                args:
                  - build
                  - ./dind
                  - -t
                  - myregistry.com/myimage:latest 
            volumes:
            - name: docker-sock
              emptyDir: {}            
```

### Understanding the components

This section describes the key components for configuring Docker-in-Docker with the sidecar pattern in Kubernetes. 

#### Configure the sidecar container

- **`image: docker:dind`**: The official Docker-in-Docker image containing the Docker daemon
- **`command: [dockerd-entrypoint.sh]`**: Starts the Docker daemon in the sidecar
- **`DOCKER_TLS_CERTDIR: ""`**: Disables TLS since sidecar containers uses local socket communication
- **`volumeMounts`**: Mounts `/var/run/` for the Docker socket
- **`privileged: true`**: Provides elevated permissions on the host. It is required for the Docker daemon to create containers 

#### Configure the main container for build commands

- **`image: docker:latest`**: Contains the Docker CLI tools (`docker`, `docker-compose`, etc.)
- **`volumeMounts`**: Shares the `/var/run/` volume with the sidecar to access the Docker socket
- **`command` and `args`**: Your Docker build commands 

#### Configure shared resources

- **`volumes`**: Defines the `docker-sock` volume for socket sharing, and set the `emptyDir` to default

## Security considerations

Running Docker-in-Docker requires privileged containers. It is recommended to use Docker-in-Docker in trusted environments. Consider alternatives like [BuildKit](/docs/agent/v3/agent-stack-k8s/buildkit-container-builds) for enhanced security.

## Common use cases

### Building and pushing images

```yaml
steps:
  - label: ":docker: Build and push to registry"
    agents:
      queue: kubernetes
    plugins:
      - kubernetes:
          sidecars:
            - image: docker:dind
              command: [dockerd-entrypoint.sh]
              env:
                - name: DOCKER_TLS_CERTDIR
                  value: ""
              volumeMounts:
                - mountPath: /var/run/
                  name: docker-sock
              securityContext:
                privileged: true
          podSpec:
            containers:
              - image: docker:latest
                volumeMounts:
                  - mountPath: /var/run/
                    name: docker-sock
                command:
                  - sh
                args:
                  - -c
                  - |
                    docker build -t myregistry.com/myimage:${BUILDKITE_BUILD_NUMBER} .
                    docker push myregistry.com/myimage:${BUILDKITE_BUILD_NUMBER}
            volumes:
              - name: docker-sock
                emptyDir: {}
```
 
## Troubleshooting

This section describes common issues with Docker-in-Docker and the ways to resolve them.

### Cannot connect to the Docker daemon

- Verify the `docker-sock` volume is mounted at `/var/run/` in both containers
- Ensure the Docker-in-Docker container gets started before the main container

### Permission denied while trying to connect to the Docker daemon socket

- Ensure the sidecar has `privileged: true` 
- Verify both containers are using the same volume mount path (`/var/run/`)
- Check that your cluster's security policies allow privileged containers