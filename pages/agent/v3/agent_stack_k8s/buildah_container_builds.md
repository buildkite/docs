# Buildah container builds

Buildah provides a lightweight, daemonless approach to building OCI-compliant container images, making it ideal for Agent Stack for Kubernetes where running a Docker daemon within build containers might not be desired or possible.

## Buildah daemonless builds

Buildah operates without requiring a persistent daemon, unlike Docker. It can build containers from Dockerfiles or Containerfiles (the OCI standard format) or through its native command-line interface. This approach provides better security isolation and works well within Kubernetes environments.

## Using Buildah with Agent Stack for Kubernetes

Agent Stack for Kubernetes supports multiple Buildah configurations, each providing different security trade-offs. Choose the approach that best matches your environment's security policies:

- **Privileged**: Maximum compatibility, requires privileged containers
- **Rootless**: Enhanced security, runs as non-root user

### Privileged Buildah

Use when: You need maximum compatibility and your cluster allows privileged containers.

Security impact: Container has root access to host kernel features. Use only in trusted environments.

How it works: Runs as root with `privileged: true`, giving access to all kernel capabilities needed for container operations.

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

Use when: You want secure container builds without privileged access (recommended for most environments).

Security impact: Runs as non-root user (1000), significantly reducing attack surface compared to privileged mode.

How it works: Uses user namespaces and rootless container runtime. Buildah runs as regular user but can still build containers through user namespace mapping.

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

| Feature                 | Privileged                      | Rootless                        |
| ----------------------- | ------------------------------- | ------------------------------- |
| Container image         | `quay.io/buildah/stable:latest` | `quay.io/buildah/stable:latest` |
| Runs as user            | root (0)                        | user (1000)                     |
| Privileged access       | Yes (`privileged: true`)        | No                              |
| Storage driver          | overlay (default)               | overlay (default)               |
| Storage path            | `/var/lib/containers`           | `/home/build/.local/share/containers` |
| Kubernetes version      | Any                             | Any                             |

## Understanding the components

### Container images

`quay.io/buildah/stable:latest`: Official Buildah image that runs in both privileged and rootless modes. The same image supports both configurations.

### Security contexts

- Privileged: Container runs as root with `privileged: true`, bypassing most Kubernetes security controls
- Rootless: Container runs as user 1000 using user namespace mapping. Host kernel sees regular user, container sees root

### Storage driver

Buildah uses container storage backends:

- overlay: Fast and efficient, used by default in both privileged and rootless modes. Modern Buildah images support overlay in rootless environments without requiring `/dev/fuse` or additional configuration
- vfs: Fallback option that works in all environments but slower, especially with bigger images. Can be specified with `--storage-driver vfs` if overlay encounters issues

### Storage paths

The storage location depends on who owns the Buildah process:

- Root user (privileged): Uses system location `/var/lib/containers`
- Regular user (rootless): Uses user home directory `/home/build/.local/share/containers`

### Build isolation

`BUILDAH_ISOLATION=chroot` is the recommended isolation mode for container environments. It provides good isolation without requiring additional privileges, unlike other isolation modes that may need extra capabilities.

## Buildah features

Buildah provides several features that make it well-suited for CI/CD environments:

- Daemonless operation: No persistent daemon required
- OCI-compliant: Produces standard OCI images
- Dockerfile and Containerfile support: Can build from Dockerfiles or Containerfiles using `buildah bud`
- Native commands: Alternative scripting interface with `buildah from`, `buildah copy`, etc.
- Multiple output formats: Support for Docker and OCI image formats
- Layer caching: Efficient caching for faster builds
- No root required: Can run entirely rootless with appropriate configuration

## Customizing the build

Customize Buildah builds by modifying the `buildah bud` command options:

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

### Exporting as tar file

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

If you encounter issues with the default overlay driver, you can use vfs as a fallback:

```bash
buildah bud \
  --storage-driver vfs \
  --format docker \
  --file Dockerfile \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

## Troubleshooting

### Common issues

Permission denied errors:

- Privileged: Ensure `securityContext.privileged: true` is configured
- Rootless: Verify `runAsUser: 1000` and `runAsGroup: 1000` are set
- Verify storage mount at `/var/lib/containers` (privileged) or `/home/build/.local/share/containers` (rootless)

Storage driver errors:

- The default overlay driver should work in both privileged and rootless modes
- If overlay fails, try `--storage-driver vfs` as a fallback (slower but more compatible)
- Check that storage volume has sufficient space

Registry authentication failures:

- Use `buildah login` before pushing: `buildah login --username $USER --password $PASS registry.com`
- Or pass credentials directly with `--creds` flag
- Ensure registry credentials are available as environment variables or secrets

Image format compatibility issues:

- Use `--format docker` for Docker registry compatibility
- Use `--format oci` for strict OCI compliance
- Default format varies by Buildah version

### Debugging builds

Increase Buildah output verbosity with debug flags:

```bash
buildah --log-level=debug bud \
  --format docker \
  --file Dockerfile \
  --tag myimage:${BUILDKITE_BUILD_NUMBER} \
  .
```

### Inspecting built images

Use Buildah commands to inspect the built image:

```bash
# List images
buildah images

# Inspect image details
buildah inspect myimage:${BUILDKITE_BUILD_NUMBER}

# List containers
buildah containers
```
