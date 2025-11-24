---
toc_include_h3: false
---

# Buildah container builds

Buildah operates without a need for a persistent daemon, unlike Docker. Buildah can build containers from Dockerfiles or Containerfiles (the OCI standard format) or through its native command-line interface. This guide shows you how to use Buildah with the [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) to build and push container images.

## Key differences from Docker

> 📘 Important
> Buildah does not use the Docker daemon, which means images built with Buildah are managed separately from Docker images. When using the Docker plugin to run Buildah, the images built by Buildah won't be visible to Docker commands running outside the Buildah container.

This separation means:
- `docker images` won't show Buildah-built images
- Images must be pushed to a registry to be shared between Buildah and Docker environments
- Buildah stores its images in its own storage backend

## Using Buildah with Elastic CI Stack for AWS

To use Buildah with the Elastic CI Stack, you'll run Buildah inside a container using the [Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin).

### Building and pushing to Buildkite Package Registries

The following example shows how to build a container image and push it to [Buildkite Package Registries](https://buildkite.com/docs/packages) using OIDC authentication:

```yaml
env:
  PACKAGE_REGISTRY_NAME: "my-docker-registry"
  BUILDAH_ISOLATION: "chroot"

steps:
  - label: ":whale: Build and Push with Buildah"
    plugins:
      - docker#v5.13.0:
          image: "quay.io/buildah/stable:latest"
          privileged: true
          userns: "host"
          mount-buildkite-agent: true
    command: |
      buildah bud \
        --format docker \
        --file Dockerfile \
        --tag packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/myapp:${BUILDKITE_BUILD_NUMBER} \
        .

      # Verify the image was built
      buildah images

      # Authenticate using OIDC and push to registry
      buildkite-agent oidc request-token \
        --audience "https://packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}" \
        --lifetime 300 | \
      buildah login \
        --authfile ./bk-oidc-auth.json \
        "packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}" \
        --username buildkite \
        --password-stdin

      buildah push \
        --authfile ./bk-oidc-auth.json \
        packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/myapp:${BUILDKITE_BUILD_NUMBER}
```

### Configuration breakdown

#### Environment variables

- `PACKAGE_REGISTRY_NAME`: The name of your Buildkite Package Registry
- `BUILDAH_ISOLATION: "chroot"`: Sets the isolation mode for Buildah. The `chroot` mode provides good isolation without requiring additional privileges.

#### Docker plugin configuration

- `image: "quay.io/buildah/stable:latest"`: Uses the official Buildah container image
- `privileged: true`: Grants extended privileges to the container, required for Buildah to create and manage container images
- `userns: "host"`: Uses the host's user namespace, necessary for Buildah to function correctly in this configuration
- `mount-buildkite-agent: true`: Mounts the Buildkite agent binary into the container, enabling the use of `buildkite-agent oidc request-token`

#### Buildah commands

- `buildah bud`: Builds an image from a Dockerfile
  - `--format docker`: Produces a Docker-compatible image format
  - `--file Dockerfile`: Specifies the path to the Dockerfile
  - `--tag`: Tags the resulting image
- `buildah images`: Lists built images (useful for verification)
- `buildah login`: Authenticates with a container registry
  - `--authfile`: Specifies where to store authentication credentials
  - `--username` and `--password-stdin`: Provide credentials for authentication
- `buildah push`: Pushes the image to a registry
  - `--authfile`: Uses the authentication file created during login

## Understanding the components

This section covers the key components and configuration options for running Buildah with the Elastic CI Stack for AWS.

### Container images

The official Buildah image that runs in privileged mode is `quay.io/buildah/stable:latest`.

### Security contexts

The configuration shown uses privileged mode where the container runs as root with `privileged: true`, bypassing most security controls. 

### Storage driver

Buildah uses container storage backends:

- **overlay**: Fast and efficient, used by default. Modern Buildah images support overlay without requiring `/dev/fuse` or additional configuration.
- **vfs**: Fallback option that works in all environments but slower, especially with bigger images. Can be specified with `--storage-driver vfs` if overlay encounters issues.

### Storage paths

When running in the container as root (privileged), Buildah uses the system location `/var/lib/containers`.

### Build isolation

The recommended isolation mode for Buildah container environments is `BUILDAH_ISOLATION=chroot`. It provides good isolation without requiring additional privileges.

## Customizing the build

### Using build arguments

You can pass build arguments to your Dockerfile:

```yaml
command: |
  buildah bud \
    --format docker \
    --build-arg VERSION=${BUILDKITE_BUILD_NUMBER} \
    --build-arg COMMIT=${BUILDKITE_COMMIT} \
    --file Dockerfile \
    --tag packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/myapp:${BUILDKITE_BUILD_NUMBER} \
    .
```

### Targeting specific build stages

For multi-stage Dockerfiles, you can target a specific stage:

```yaml
command: |
  buildah bud \
    --format docker \
    --target production \
    --file Dockerfile \
    --tag packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/myapp:${BUILDKITE_BUILD_NUMBER} \
    .
```

### Using alternative storage driver

If you encounter issues with the default overlay driver, you can use `vfs` as a fallback:

```yaml
command: |
  buildah bud \
    --storage-driver vfs \
    --format docker \
    --file Dockerfile \
    --tag packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/myapp:${BUILDKITE_BUILD_NUMBER} \
    .
```

## Troubleshooting

This section describes common issues for Buildah and the ways of solving these issues.

### Permission denied errors

- Ensure `privileged: true` is configured in the Docker plugin
- Verify the `userns: "host"` setting is present
- Confirm the `BUILDAH_ISOLATION` environment variable is set to `"chroot"`

### Storage driver errors

- The default overlay driver should work in privileged mode
- If overlay fails, try `--storage-driver vfs` as a fallback (this is a slower but more compatible approach)
- Check that the storage volume has sufficient space

### Registry authentication failures

- Ensure the `mount-buildkite-agent: true` setting is configured so `buildkite-agent oidc request-token` is available
- Verify that the OIDC token audience matches your Package Registry URL exactly
- Check that the authentication file is being passed correctly to the `buildah push` command

### Image not found after build

Remember that Buildah images are separate from Docker images. If you need to use the image in subsequent steps:

- Push the image to a registry and pull it in later steps
- Use the same Buildah container for all operations on that image
