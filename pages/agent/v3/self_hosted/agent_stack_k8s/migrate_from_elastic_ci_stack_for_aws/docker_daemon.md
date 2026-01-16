# Docker daemon access

The [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) includes Docker pre-installed in the instance images. Jobs can execute Docker commands directly using the local Docker daemon at `/var/run/docker.sock` without additional configuration.

When migrating to [Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s), Docker is not available by default. Kubernetes does not provide a Docker daemon on cluster nodes, so you need to configure Docker access explicitly for jobs that require Docker commands like `docker build` or `docker push`.

This guide covers two approaches for providing Docker daemon access in Kubernetes and helps you choose the right approach for your migration scenario.

## Docker access approaches in Kubernetes

When migrating to Kubernetes, you can run a Docker daemon using Docker-in-Docker (DinD) as either a sidecar container for each job [Pod](https://kubernetes.io/docs/concepts/workloads/pods/) or as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) across cluster nodes.

Each approach has different characteristics that affect your migration planning:

| Consideration | Sidecar Container | DaemonSet |
|--------------|-------------------|-----------|
| Setup complexity | Low (configured per-pipeline or at controller level) | Medium (requires cluster-level DaemonSet configuration) |
| Resource usage | Higher (new daemon per job) | Lower (shared daemon across jobs on the same node) |
| Isolation | High (dedicated daemon per job) | Lower (shared daemon on each node) |
| Startup time | Slower (daemon starts with each job) | Faster (daemon already running) |
| Cluster impact | Minimal (only affects job Pods) | Moderate (runs on all or selected nodes) |
| Build cache | Ephemeral (lost after job completes) | Persistent (shared across jobs on the same node) |

## Using a Docker daemon sidecar container

The sidecar approach runs a dedicated Docker daemon container alongside your main job container in the same Pod. This provides complete isolation between jobs, as each job gets its own daemon that is destroyed when the job completes.

The [official Docker image](https://hub.docker.com/_/docker) provides a Docker-in-Docker (DinD) variant that runs the Docker daemon. Your main container connects to this daemon over TCP using the `DOCKER_HOST` environment variable.

### Implementation

Add the Docker daemon sidecar to your pipeline using the `kubernetes` plugin:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build with DinD sidecar"
    command: |
      docker build -t myimage:latest .
      docker push myregistry.com/myimage:latest
    env:
      DOCKER_HOST: tcp://localhost:2375
    agents:
      queue: kubernetes
    image: docker:cli
    plugins:
      - kubernetes:
          sidecars:
            - image: docker:dind
              command: ["dockerd-entrypoint.sh"]
              securityContext:
                privileged: true
              env:
                - name: DOCKER_TLS_CERTDIR
                  value: ""
```

#### Understanding the configuration

The sidecar configuration requires several key components:

- `DOCKER_HOST` tells the Docker CLI to connect to the daemon at `tcp://localhost:2375`
- The `docker:dind` image provides the Docker daemon in the sidecar container
- `privileged: true` grants the sidecar elevated privileges needed to run the daemon and create containers
- `DOCKER_TLS_CERTDIR` set to an empty string disables TLS authentication between containers in the same Pod

#### Controller-level configuration

You can also configure the Docker daemon sidecar at the controller level to apply it to all jobs without modifying individual pipelines:

```yaml
# values.yaml
config:
  pod-spec-patch:
    containers:
      - name: container-0
        env:
          - name: DOCKER_HOST
            value: tcp://localhost:2375
    initContainers:
      - name: dind-sidecar
        image: docker:dind
        command: ["dockerd-entrypoint.sh"]
        restartPolicy: Always
        securityContext:
          privileged: true
        env:
          - name: DOCKER_TLS_CERTDIR
            value: ""
```

With this controller-level configuration, all jobs processed by the controller automatically have access to Docker without per-pipeline configuration changes.

### Using a Unix socket instead of TCP

Instead of connecting over TCP, you can configure the daemon to use a Unix socket in a shared volume. This approach provides better security as the socket is not exposed over the network. Use the following configuration:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build with Unix socket"
    command: |
      docker build -t myimage:latest .
      docker push myregistry.com/myimage:latest
    env:
      DOCKER_HOST: unix:///var/run/docker.sock
    agents:
      queue: kubernetes
    image: docker:cli
    plugins:
      - kubernetes:
          podSpec:
            containers:
              - image: docker:cli
                volumeMounts:
                  - name: docker-socket
                    mountPath: /var/run
            volumes:
              - name: docker-socket
                emptyDir: {}  # Shared volume between containers
          sidecars:
            - image: docker:dind
              command: ["dockerd-entrypoint.sh"]
              securityContext:
                privileged: true
              volumeMounts:
                - name: docker-socket
                  mountPath: /var/run
              env:
                - name: DOCKER_TLS_CERTDIR
                  value: ""
```

This configuration creates a shared [emptyDir](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume between the main container and the sidecar, allowing both to access the same Unix socket at `/var/run/docker.sock`.

#### Controller-level configuration with Unix socket

You can configure the Unix socket approach at the controller level:

```yaml
# values.yaml
config:
  pod-spec-patch:
    containers:
      - name: container-0
        env:
          - name: DOCKER_HOST
            value: unix:///var/run/docker.sock
        volumeMounts:
          - name: docker-socket
            mountPath: /var/run
    initContainers:
      - name: dind-sidecar
        image: docker:dind
        command: ["dockerd-entrypoint.sh"]
        restartPolicy: Always
        securityContext:
          privileged: true
        volumeMounts:
          - name: docker-socket
            mountPath: /var/run
        env:
          - name: DOCKER_TLS_CERTDIR
            value: ""
    volumes:
      - name: docker-socket
        emptyDir: {}
```

### Considerations for the sidecar approach

The sidecar approach maximizes job isolation by running a dedicated Docker daemon for each job. This increases startup time and resource usage per job. Build caches and images are ephemeral and are discarded when jobs complete. Each daemon requires privileged container permissions.

This approach works well when strong isolation between jobs is required or when you want to minimize cluster-level configuration changes during migration.

For more details about configuring Docker-in-Docker with sidecars, see [Docker-in-Docker container builds](/docs/agent/v3/self-hosted/agent-stack-k8s/dind-container-builds).

## Using a Docker daemon DaemonSet

The DaemonSet approach runs a single Docker daemon on each cluster node, similar to how Docker runs in [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack). Multiple jobs on the same node share the same daemon, which provides better resource efficiency and persistent build caches.

### Implementation

Create a DaemonSet that runs the Docker daemon on each node. This example uses the `buildkite` namespace, but you can use any namespace where your Buildkite jobs run:

```yaml
# docker-dind-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: docker-dind
  namespace: buildkite  # Use the namespace where your jobs run
spec:
  selector:
    matchLabels:
      app: docker-dind
  template:
    metadata:
      labels:
        app: docker-dind
    spec:
      containers:
        - name: dind
          image: docker:dind
          command: ["dockerd-entrypoint.sh"]
          securityContext:
            privileged: true
          env:
            - name: DOCKER_TLS_CERTDIR
              value: ""
            - name: DOCKER_HOST
              value: tcp://0.0.0.0:2375
          ports:
            - containerPort: 2375
              protocol: TCP
          volumeMounts:
            - name: docker-storage
              mountPath: /var/lib/docker
      volumes:
        - name: docker-storage
          emptyDir: {}
```

Apply the DaemonSet to your cluster:

```bash
kubectl apply -f docker-dind-daemonset.yaml
```

Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to expose the Docker daemon to job Pods:

```yaml
# docker-dind-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: docker-dind
  namespace: buildkite  # Must match the DaemonSet namespace
spec:
  selector:
    app: docker-dind
  ports:
    - protocol: TCP
      port: 2375
      targetPort: 2375
  type: ClusterIP
```

Apply the Service:

```bash
kubectl apply -f docker-dind-service.yaml
```

Configure jobs to connect to the DaemonSet daemon. The Service DNS name follows the Kubernetes format `<service-name>.<namespace>.svc.cluster.local`:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build with DaemonSet"
    command: |
      docker build -t myimage:latest .
      docker push myregistry.com/myimage:latest
    env:
      DOCKER_HOST: tcp://docker-dind.buildkite.svc.cluster.local:2375  # docker-dind service in buildkite namespace
    agents:
      queue: kubernetes
    image: docker:cli
```

#### Controller-level configuration

Configure the Docker daemon connection at the controller level. Update the Service DNS name if you used a different namespace or service name:

```yaml
# values.yaml
config:
  pod-spec-patch:
    containers:
      - name: container-0
        env:
          - name: DOCKER_HOST
            value: tcp://docker-dind.buildkite.svc.cluster.local:2375
```

### Persistent storage for build caches

To preserve build caches and images across daemon restarts, configure persistent storage for the DaemonSet:

```yaml
# docker-dind-daemonset.yaml (storage section)
spec:
  template:
    spec:
      containers:
        - name: dind
          # ... other configuration ...
          volumeMounts:
            - name: docker-storage
              mountPath: /var/lib/docker
      volumes:
        - name: docker-storage
          hostPath:
            path: /var/lib/docker-dind
            type: DirectoryOrCreate
```

> 📘 Build cache storage
> When using [hostPath](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) for persistent storage, each node maintains its own separate Docker cache. Jobs scheduled on different nodes will not share cached layers.

### Considerations for the DaemonSet approach

The DaemonSet approach shares a single Docker daemon across all jobs on each node, providing optimized resource efficiency. Jobs have lower isolation since they share the daemon. Deploying DaemonSets requires cluster-level permissions. Persistent caches can improve performance but need storage management. Daemons run continuously, consuming resources even when idle, and network configuration is more complex than the sidecar approach.

This approach works well when you need to optimize resource usage across many concurrent builds or want to maintain persistent build caches similar to the Elastic CI Stack for AWS.

## Alternatives to running a Docker daemon

If your use case allows, consider alternatives that do not require privileged containers:

- [BuildKit](/docs/agent/v3/self-hosted/agent-stack-k8s/buildkit-container-builds) provides enhanced security and performance for building container images.
- [Kaniko](/docs/agent/v3/self-hosted/agent-stack-k8s/kaniko-container-builds) builds container images without requiring privileged access.
- [Buildah](/docs/agent/v3/self-hosted/agent-stack-k8s/buildah-container-builds) builds OCI-compliant images without a daemon.

These alternatives provide better security posture in Kubernetes environments where privileged containers are restricted or discouraged.

## Security considerations

Both approaches require privileged containers to run the Docker daemon. Privileged containers have elevated access to the host system and can pose security risks if compromised.

Consider these security practices when running a Docker daemon:

- Limit privileged container usage to trusted workloads and environments
- Use [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) to restrict daemon access to authorized Pods only
- Implement [resource limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) to prevent resource exhaustion
- Regularly update Docker images to include security patches
- Consider alternatives like BuildKit or Kaniko for better security

For production environments, evaluate whether the Docker CLI compatibility requirement justifies the security implications of privileged containers.

## Related resources

- [Docker-in-Docker container builds](/docs/agent/v3/self-hosted/agent-stack-k8s/dind-container-builds)
- [BuildKit container builds](/docs/agent/v3/self-hosted/agent-stack-k8s/buildkit-container-builds)
- [Kaniko container builds](/docs/agent/v3/self-hosted/agent-stack-k8s/kaniko-container-builds)
- [Buildah container builds](/docs/agent/v3/self-hosted/agent-stack-k8s/buildah-container-builds)
- [Sidecars in Agent Stack for Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s/sidecars)
- [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws)
