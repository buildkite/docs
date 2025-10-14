# Docker-in-Docker (DinD) container builds

[Docker-in-Docker (DinD)](https://hub.docker.com/_/docker) allows you to run a Docker daemon inside a container, enabling standard Docker commands like `docker build` and `docker run` within a [job](docs/pipelines/glossary#job). This approach is useful when you need full Docker CLI compatibility or want to build and test container images using familiar Docker workflows.

## How Docker-in-Docker works

Docker-in-Docker uses a sidecar container pattern where:

1. A Docker daemon (`docker:dind`) runs in a sidecar container with elevated privileges
2. Your job's main container communicates with this daemon through a shared Docker socket
3. Both containers share a volume mounted at `/var/run/` for socket communication

The Docker daemon in the sidecar handles all container operations, while your build commands run in the main container with access to the full Docker CLI.

## Using Docker-in-Docker with Agent Stack for Kubernetes

The following pipeline example demonstrates how to build a container image using Docker-in-Docker with the Buildkite Kubernetes plugin's [`sidecars` feature](https://buildkite.com/docs/agent/v3/agent-stack-k8s/sidecars).  

```yaml
steps:
- label: "Testing the sidecar approach"
  agents:
    queue: kubetest
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
            allowPrivilegeEscalation: true
        mirrorVolumeMounts: true  
        gitEnvFrom:
          - secretRef: { name: cicd-user-git-ssh-keys }
        podSpec:
          containers:
            - image: alpine/docker-with-buildx:latest
              volumeMounts:
                - mountPath: /var/run/
                  name: docker-sock
              command: [docker]
              args: ["build", "./dind", "-t sometag/bar"]
              resources:
                limits:
                  cpu: "100m"
                  memory: "128Mi"
          volumes:
          - name: docker-sock
            emptyDir: {}
```

### Understanding the components

This section describes the key components for configuring Docker-in-Docker with the sidecar pattern in Kubernetes. 

#### Configure the sidecar container

- **`image: docker:dind`**: The official Docker-in-Docker image containing the Docker daemon
- **`command: [dockerd-entrypoint.sh]`**: Starts the Docker daemon in the sidecar
- **`DOCKER_TLS_CERTDIR: ""`**: Disables TLS for simplified local socket communication
- **`volumeMounts`**: Mounts `/var/run/` for the Docker socket
- **`privileged: true`**: Required for the Docker daemon to create containers
- **`allowPrivilegeEscalation: true`**: Allows the daemon to escalate privileges as needed

#### Configure the main container for build commands

- **`image: docker:latest`**: Contains the Docker CLI tools (`docker`, `docker-compose`, etc.)
- **`volumeMounts`**: Shares the `/var/run/` volume with the sidecar to access the Docker socket
- **`command` and `args`**: Your Docker build commands
- **`resources`**: CPU and memory limits for the build process

#### Configure shared resources

- **`mirrorVolumeMounts: true`**: Ensures volume mounts are available to both containers. It is critical that the indentation must be at the same level as `sidecars`. 
- **`gitEnvFrom`**: Provides Git credentials for checking out your repository
- **`volumes`**: Defines the `docker-sock` volume for socket sharing, and set the `emptyDir` to default

## Security considerations

Running Docker-in-Docker requires privileged containers, which has important security implications:

- **Privileged access**: The sidecar container runs with `privileged: true`, giving it elevated permissions on the host
- **Attack surface**: Privileged containers have access to host kernel features and can potentially escape container isolation
- **Cluster policies**: Some Kubernetes clusters restrict or prohibit privileged containers through [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

**Recommendation**: Only use Docker-in-Docker in trusted environments and consider alternatives like [BuildKit](/docs/agent/v3/agent-stack-k8s/buildkit-container-builds) for enhanced security.

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
                allowPrivilegeEscalation: true
          mirrorVolumeMounts: true
          gitEnvFrom:
            - secretRef: { name: cicd-user-git-ssh-keys }
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

### Multi-stage builds with caching

```yaml
steps:
  - label: ":docker: Multi-stage build with cache"
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
                - mountPath: /var/lib/docker
                  name: docker-cache
              securityContext:
                privileged: true
                allowPrivilegeEscalation: true
          mirrorVolumeMounts: true
          gitEnvFrom:
            - secretRef: { name: cicd-user-git-ssh-keys }
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
                    docker build \
                      --target production \
                      --build-arg NODE_ENV=production \
                      --cache-from myregistry.com/myimage:latest \
                      -t myregistry.com/myimage:${BUILDKITE_BUILD_NUMBER} \
                      .
            volumes:
              - name: docker-sock
                emptyDir: {}
              - name: docker-cache
                emptyDir: {}
```

### Running Docker Compose

```yaml
steps:
  - label: ":docker: Docker Compose build"
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
                allowPrivilegeEscalation: true
          mirrorVolumeMounts: true
          gitEnvFrom:
            - secretRef: { name: cicd-user-git-ssh-keys }
          podSpec:
            containers:
              - image: docker/compose:latest
                volumeMounts:
                  - mountPath: /var/run/
                    name: docker-sock
                command:
                  - docker-compose
                args:
                  - -f
                  - docker-compose.yml
                  - build
            volumes:
              - name: docker-sock
                emptyDir: {}
```

## Troubleshooting

This section describes common issues with Docker-in-Docker and the ways to resolve them.

### Cannot connect to the Docker daemon

- Verify the `docker-sock` volume is mounted at `/var/run/` in both containers
- Check that `mirrorVolumeMounts: true` is set in the Kubernetes plugin configuration
- Ensure the sidecar container is running: `kubectl get pods` to check pod status
- Add a wait or retry mechanism to allow the Docker daemon time to start:
  ```yaml
  command:
    - sh
  args:
    - -c
    - |
      until docker info; do
        echo "Waiting for Docker daemon..."
        sleep 1
      done
      docker build -t myimage:latest .
  ```

### Permission denied while trying to connect to the Docker daemon socket

- Ensure the sidecar has `privileged: true` and `allowPrivilegeEscalation: true`
- Verify both containers are using the same volume mount path (`/var/run/`)
- Check that your cluster's security policies allow privileged containers

### Docker daemon fails to start

- Check sidecar logs: `kubectl logs <pod-name> -c sidecar-0`
- Verify the cluster allows privileged containers
- Ensure sufficient resources are allocated to the sidecar container:
  ```yaml
  sidecars:
    - image: docker:dind
      # ... other config ...
      resources:
        limits:
          cpu: "1000m"
          memory: "2Gi"
  ```

### Resolving TLS certificate verification errors

- Ensure `DOCKER_TLS_CERTDIR` is set to an empty string (`""`) in the sidecar environment
- If TLS is required, properly configure certificates for both client and daemon