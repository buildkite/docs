# BuildKit container builds

[BuildKit](https://docs.docker.com/build/buildkit/) is a Docker builder that provides advanced features for building container images in a daemonless environment, making it a good fit for Agent Stack for Kubernetes when running a Docker daemon within build containers may not be desired or possible.

## BuildKit daemonless builds

The BuildKit daemon can be run in [rootless mode](https://github.com/moby/buildkit/blob/b9322799388c6c0d598cb70236d22081c5db3c4b/docs/rootless.md) or embedded directly into your build process without requiring a persistent daemon. These deployment options provide better security isolation and work well within Kubernetes environments.

## Using BuildKit with Agent Stack for Kubernetes

Agent Stack for Kubernetes supports multiple BuildKit configurations, each providing different security trade-offs. Choose the approach that best matches your environment's security policies and container runtime restrictions:

- **Privileged**: maximum compatibility, requires [privileged containers](https://docs.docker.com/enterprise/security/hardened-desktop/enhanced-container-isolation/#secured-privileged-containers).
- **Rootless (Non-Privileged)**: enhanced security, runs as non-root user.
- **Rootless (Strict)**: maximum security isolation with additional sandbox disabled.

### Privileged BuildKit

**Recommended**: When you need maximum compatibility and your cluster allows privileged containers.

**Security impact**: Container has root access to host kernel features. Use only in trusted environments.

**How it works**: Runs as root with `privileged: true`, giving access to all kernel capabilities needed for container operations.

```yaml
steps:
  - label: "\:docker\: BuildKit daemonless container build"
    retry:
      manual:
        permit_on_passed: true
    agents:
      queue: kubernetes
    command: |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --opt filename=Dockerfile \
        --progress=plain
    plugins:
      - kubernetes:
          podSpec:
            volumes:
              - name: buildkit-cache
                emptyDir: {}
              - name: tmp-space
                emptyDir: {}
            containers:
              - name: main
                image: moby/buildkit:latest
                env:
                  - name: BUILDKITD_FLAGS
                    value: ""
                volumeMounts:
                  - name: buildkit-cache
                    mountPath: "/var/lib/buildkit"
                  - name: tmp-space
                    mountPath: "/tmp"
                securityContext:
                  privileged: true
```

### Rootless BuildKit (non-privileged)

**Recommended**: When your Kubernetes cluster blocks privileged containers but allows `runAsNonRoot`.

**Security impact**: Runs as [non-root user](https://docs.docker.com/engine/security/rootless/) (`UID 1000`), significantly reducing attack surface.

**How it works**: Uses user namespaces and rootless container runtime. BuildKit runs as regular user but can still build containers through user namespace mapping.

```yaml
steps:
  - label: "\:docker\: BuildKit non-privileged container build"
    retry:
      manual:
        permit_on_passed: true
    agents:
      queue: kubernetes
    command: |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --opt filename=Dockerfile \
        --progress=plain
    plugins:
      - kubernetes:
          podSpec:
            volumes:
              - name: buildkit-cache
                emptyDir: {}
              - name: tmp-space
                emptyDir: {}
            containers:
              - name: main
                image: moby/buildkit:rootless
                env:
                  - name: BUILDKITD_FLAGS
                    value: ""
                volumeMounts:
                  - name: buildkit-cache
                    mountPath: "/home/user/.local/share/buildkit"
                  - name: tmp-space
                    mountPath: "/tmp"
                securityContext:
                  runAsNonRoot: true
                  runAsUser: 1000
                  runAsGroup: 1000
```

### Rootless BuildKit (strict security)

Uses `--oci-worker-no-process-sandbox` to work around Kubernetes limitations with PID namespaces. This mode is required when Kubernetes doesn't support `systempaths=unconfined`.

```yaml
steps:
  - label: "\:docker\: BuildKit rootless daemonless build"
    retry:
      manual:
        permit_on_passed: true
    agents:
      queue: kubernetes
    command: |
      BUILDKITD_FLAGS="--oci-worker-no-process-sandbox" \
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --opt filename=Dockerfile \
        --progress=plain
    plugins:
      - kubernetes:
          podSpec:
            volumes:
              - name: buildkit-cache
                emptyDir: {}
              - name: tmp-space
                emptyDir: {}
            containers:
              - name: main
                image: moby/buildkit:rootless
                volumeMounts:
                  - name: buildkit-cache
                    mountPath: "/home/user/.local/share/buildkit"
                  - name: tmp-space
                    mountPath: "/tmp"
                securityContext:
                  runAsNonRoot: true
                  runAsUser: 1000
                  runAsGroup: 1000
                  seccompProfile:
                    type: Unconfined
                  appArmorProfile:
                    type: Unconfined
```

## Configuration comparison

The following table highlights the key differences between privileged and rootless BuildKit container configurations in Kubernetes environments.

| Feature                      | Privileged               | Rootless (Non-Privileged)       | Rootless (Strict)                 |
| ---------------------------- | ------------------------ | ------------------------------- | --------------------------------- |
| **Container image**          | `moby/buildkit:latest`   | `moby/buildkit:rootless` | `moby/buildkit:rootless`   |
| **Runs as user**             | root (0)                 | user (1000)                     | user (1000)                       |
| **Privileged access**        | Yes (`privileged: true`) | No                              | No                                |
| **BuildKit process sandbox** | Enabled                  | Enabled                         | Disabled\*                        |
| **Kernel security profiles** | Default                  | Default                         | Unconfined                        |
| **Kubernetes version**       | Any                      | Any                             | ≥1.19 (seccomp), ≥1.30 (AppArmor) |

\*Process sandbox disabled due to Kubernetes limitations - reduces security within BuildKit container.

>📘
>`Unconfined` profiles are required for rootless container operations.

## Understanding the components

This section covers the key components and configuration options for running BuildKit in Kubernetes, including image variants, security contexts, cache storage locations, and the trade-offs of rootless mode.

### Container images

- **`moby/buildkit:latest`**: full-featured image designed to run as root with privileged access.
- **`moby/buildkit:rootless`**: specially built image that can run as a regular user through rootless container approach.

### Security contexts

- **Privileged**: container runs as root with `privileged: true`, bypassing most Kubernetes security controls.
- **Rootless**: container runs as `user 1000` using user namespace mapping. Host kernel sees a regular user, container sees root.
- **Security profiles**: [seccomp](https://docs.docker.com/engine/security/seccomp/) and [AppArmor](https://docs.docker.com/engine/security/apparmor/) profiles restrict system calls and operations.

### Cache storage paths

The cache location depends on who owns the BuildKit process:

- **Root user** (privileged): uses system location `/var/lib/buildkit`.
- **Regular user** (rootless): uses user home directory `/home/user/.local/share/buildkit`.

### Rootless mode caveats

The `--oci-worker-no-process-sandbox` flag disables BuildKit's internal process isolation:

- Build steps can kill or ptrace other processes in the BuildKit container.
- Processes that don't exit cleanly cannot be force-terminated.
- Required in Kubernetes because `systempaths=unconfined` is not supported.

This reduces security compared to rootless mode without the flag, but is necessary for Kubernetes compatibility.

## Customizing the build

Customize BuildKit builds by modifying the `buildctl-daemonless.sh` command options:

### Targeting specific build stages

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --opt filename=Dockerfile \
  --opt target=production \
  --progress=plain
```

### Using build arguments

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --opt filename=Dockerfile \
  --opt build-arg:NODE_ENV=production \
  --opt build-arg:VERSION=$BUILDKITE_BUILD_NUMBER \
  --progress=plain
```

### Exporting to registry

Export the built images to a container registry:

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --output type=image,name=myregistry.com/myimage:$BUILDKITE_BUILD_NUMBER,push=true
```

### Exporting as tar file

Export the built images as tar files:

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --output type=tar,dest=image.tar
```

## Troubleshooting

This section describes common issues for BuildKit and the ways of solving these issues.

### Permission denied errors

- **Privileged**: ensure `securityContext.privileged: true` is configured.
- **Non-privileged/Rootless**: verify `runAsUser: 1000` and `runAsGroup: 1000` are set.
- **Rootless**: check that `seccompProfile` and `appArmorProfile` are set to `Unconfined`.

### Cache mount issues

- **Privileged**: verify cache mount at `/var/lib/buildkit`.
- **Rootless (both modes)**: verify cache mount at `/home/user/.local/share/buildkit`.

### BuildKit tools not found

Use appropriate image:

- **Privileged** builds: `moby/buildkit:latest`.
- **Non-privileged/Rootless** builds: `moby/buildkit:rootless`.

### Rootless build failures

Ensure `BUILDKITD_FLAGS="--oci-worker-no-process-sandbox"` is set to "rootless (strict)" mode.

### Pod initialization issues

For rootless builds, verify Kubernetes version supports the required security profiles (≥1.19 for seccomp, ≥1.30 for AppArmor).

### Build processes not terminating

Known limitation with `--oci-worker-no-process-sandbox` - BuildKit cannot force-kill processes that don't exit cleanly.

### Debugging builds

Increase BuildKit output verbosity by using `--progress=plain` and adding debug flags:

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --progress=plain \
  --debug
```
