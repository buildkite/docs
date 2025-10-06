# Buildah container builds

[Buildah](https://buildah.io/) provides a lightweight, daemonless approach to building [Open Container Initiative (OCI)](https://opencontainers.org/)-compliant container images, making it a suitable choice for Agent Stack for Kubernetes in cases where running a Docker daemon within build containers might not be desired or possible.

## Buildah daemonless builds

Buildah operates without a need for a persistent daemon, unlike Docker. Buildah can build containers from Dockerfiles or Containerfiles (the OCI standard format) or through its native command-line interface. This approach provides better security isolation and works well within Kubernetes environments.

## Using Buildah with Agent Stack for Kubernetes

Agent Stack for Kubernetes supports multiple Buildah configurations, each providing different security trade-offs. Choose the approach that best matches your environment's security policies:

- **Privileged**: maximum compatibility, requires privileged containers, or
- **Rootless**: enhanced security, runs as non-root user.

### Privileged Buildah

**Recommended**: When you need maximum compatibility and your cluster allows privileged containers.

**Security impact**: Container has root access to host kernel features. Use only in trusted environments.

**How it works**: Buildah runs as root with `privileged: true`, giving access to all kernel capabilities needed for container operations.

```yaml
steps:
  - label: ":package: Buildah privileged container build"
    agents:
      queue: kubernetes
    command: |
      buildah bud \
        --format docker \
        --file Dockerfile \
        --tag myimage:${BUILDKITE_BUILD_NUMBER} \
        .
    plugins:
      - kubernetes:
          podSpec:
            volumes:
              - name: buildah-storage
                emptyDir: {}
            containers:
              - name: main
                image: quay.io/buildah/stable:latest
                env:
                  - name: BUILDAH_ISOLATION
                    value: "chroot"
                volumeMounts:
                  - name: buildah-storage
                    mountPath: "/var/lib/containers"
                securityContext:
                  privileged: true
```

### Rootless Buildah

**Recommended**: When you want secure container builds without privileged access (recommended for most environments).

**Security impact**: Runs as a [non-root user](https://docs.docker.com/engine/security/rootless/) (`UID 1000`), significantly reducing attack surface compared to the privileged mode.

**How it works**: Buildah uses user namespaces and rootless container runtime. Buildah runs as a regular user but can still build containers through user namespace mapping.

```yaml
steps:
  - label: ":package: Buildah rootless container build"
    agents:
      queue: kubernetes
    command: |
      buildah bud \
        --format docker \
        --file Dockerfile \
        --tag myimage:${BUILDKITE_BUILD_NUMBER} \
        .
    plugins:
      - kubernetes:
          podSpec:
            volumes:
              - name: buildah-storage
                emptyDir: {}
            containers:
              - name: main
                image: quay.io/buildah/stable:latest
                env:
                  - name: BUILDAH_ISOLATION
                    value: "chroot"
                volumeMounts:
                  - name: buildah-storage
                    mountPath: "/home/build/.local/share/containers"
                securityContext:
                  runAsNonRoot: true
                  runAsUser: 1000
                  runAsGroup: 1000
```

## Configuration comparison

The following table highlights the key differences between privileged and rootless Buildah container configurations in Kubernetes environments.

| Feature                 | Privileged                      | Rootless                        |
| ----------------------- | ------------------------------- | ------------------------------- |
| Container image         | `quay.io/buildah/stable:latest` | `quay.io/buildah/stable:latest` |
| Runs as user            | root (0)                        | user (1000)                     |
| Privileged access       | Yes (`privileged: true`)        | No                              |
| Storage driver          | overlay (default)               | overlay (default)               |
| Storage path            | `/var/lib/containers`           | `/home/build/.local/share/containers` |
| Kubernetes version      | Any                             | Any                             |

## Understanding the components

This section covers the key components and configuration options for running Buildah in Kubernetes, including container images, security contexts, storage drivers and paths, and build isolation modes.

### Container images

The official Buildah image that runs in both privileged and rootless modes and supports both configurations is `quay.io/buildah/stable:latest`.

### Security contexts

- **Privileged**: container runs as root with `privileged: true`, bypassing most Kubernetes security controls.
- **Rootless**: container runs as `user 1000`  using user namespace mapping. Host kernel sees regular user, container sees root.

### Storage driver

Buildah uses container storage backends:

- **`overlay`**: fast and efficient, used by default in both privileged and rootless modes. Modern Buildah images support overlay in rootless environments without requiring `/dev/fuse` or additional configuration.
- **`vfs`**: fallback option that works in all environments but slower, especially with bigger images. Can be specified with `--storage-driver vfs` if overlay encounters issues.

### Storage paths

The storage location depends on who owns the Buildah process:

- **Root user (privileged)**: uses system location `/var/lib/containers`.
- **Regular user (rootless)**: uses user home directory `/home/build/.local/share/containers`.

### Build isolation

The recommended isolation mode for the Buildah container environments is `BUILDAH_ISOLATION=chroot`. It provides good isolation without requiring additional privileges, unlike other isolation modes that may need extra capabilities.

## Customizing the build

You can customize you Buildah builds by modifying the `buildah bud` command options using the approaches outlined below.

### Using build arguments

```bash
buildah bud \
  --format docker \
  --file Dockerfile \
  --build-arg NODE_ENV=production \
  --build-arg VERSION=$BUILDKITE_BUILD_NUMBER \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

### Targeting specific build stages

```bash
buildah bud \
  --format docker \
  --file Dockerfile \
  --target production \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

### Building and pushing to registry

```bash
# Build the image
buildah bud \
  --format docker \
  --file Dockerfile \
  --tag myregistry.com/myimage:${BUILDKITE_BUILD_NUMBER} \
  .

# Push to registry
buildah push \
  --creds ${REGISTRY_USER}:${REGISTRY_PASSWORD} \
  myregistry.com/myimage:${BUILDKITE_BUILD_NUMBER}
```

### Exporting as a tar file

```bash
# Build the image
buildah bud \
  --format docker \
  --file Dockerfile \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .

# Export to tar
buildah push \
  myimage:${BUILDKITE_BUILD_NUMBER} \
  docker-archive:image.tar
```

### Using alternative storage driver

If you encounter issues with the default overlay driver, you can use `vfs` as a fallback:

```bash
buildah bud \
  --storage-driver vfs \
  --format docker \
  --file Dockerfile \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

## Troubleshooting

This section describes common issues for Buildah and the ways of solving these issues.

### Permission denied errors

- **Privileged**: ensure `securityContext.privileged: true` is configured.
- **Rootless**: verify `runAsUser: 1000` and `runAsGroup: 1000` are set.
- Verify storage mount at `/var/lib/containers` (for privileged) or `/home/build/.local/share/containers` (for rootless).

### Storage driver errors

- The default overlay driver should work in both privileged and rootless modes.
- If overlay fails, try `--storage-driver vfs` as a fallback (this is a slower but more compatible approach).
- Check that the storage volume has sufficient space.

### Registry authentication failures

- Use `buildah login` before pushing: `buildah login --username $USER --password $PASS registry.com` or pass credentials directly with `--creds` flag.
- Ensure registry credentials are available as environment variables or secrets.

### Image format compatibility issues

- Use `--format docker` for Docker registry compatibility.
- Use `--format oci` for strict OCI compliance.
- Default format varies by Buildah version.

## Debugging builds

You can increase Buildah output verbosity with debug flags:

```bash
buildah --log-level=debug bud \
  --format docker \
  --file Dockerfile \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

## Inspecting the built image

Use the following Buildah commands to inspect the built image:

```bash
# List images
buildah images

# Inspect image details
buildah inspect myimage:${BUILDKITE_BUILD_NUMBER}

# List containers
buildah containers
```
