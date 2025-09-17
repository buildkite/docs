# BuildKit container builds

BuildKit provides advanced features for building container images in a daemonless environment, making it ideal for Agent Stack for Kubernetes where running a Docker daemon within build containers may not be desired or possible.

## BuildKit daemonless builds

The BuildKit daemon can be run in [rootless mode](https://github.com/moby/buildkit/blob/b9322799388c6c0d598cb70236d22081c5db3c4b/docs/rootless.md) or embedded directly into your build process without requiring a persistent daemon. This approach provides better security isolation and works well within Kubernetes environments.

## Using BuildKit with Agent Stack for Kubernetes

The following example demonstrates how to use BuildKit's daemonless mode to build container images in Buildkite pipelines:

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
        --opt target=test-lint \
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
                image: moby/buildkit:master
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

## Key components explained

### BuildKit image

The example uses the `moby/buildkit:master` image which includes both `buildctl` (the BuildKit client) and `buildctl-daemonless.sh` (a helper script for daemonless builds).

### Security context

The `securityContext.privileged: true` setting is required for BuildKit to function properly when building container images, as it needs access to kernel features for container operations.

### Volume mounts

- **buildkit-cache**: Persistent storage for BuildKit's build cache, improving performance on subsequent runs
- **tmp-space**: Temporary space for build operations

### Environment variables

The `BUILDKITD_FLAGS` environment variable passes additional flags to the BuildKit daemon at startup.

## BuildKit features

BuildKit provides several advanced features that make it well-suited for CI/CD environments:

- **Daemonless operation**: No persistent daemon required
- **Efficient caching**: Layer caching and cache mounts
- **Multi-stage builds**: Advanced Dockerfile features
- **Concurrent builds**: Parallel processing of build steps
- **Multiple output formats**: Support for various image formats and registries
- **Secrets management**: Secure handling of build-time secrets

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

Export built images to a container registry:

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --output type=image,name=myregistry.com/myimage:$BUILDKITE_BUILD_NUMBER,push=true
```

### Exporting as tar file

Export built images as tar files:

```bash
buildctl-daemonless.sh build \
  --frontend dockerfile.v0 \
  --local context=. \
  --local dockerfile=. \
  --output type=tar,dest=image.tar
```

## Troubleshooting

### Common issues

**Permission denied errors**: Ensure `securityContext.privileged: true` is configured in the PodSpec.

**Cache mount issues**: Verify volume mounts for cache and temporary space are properly configured.

**BuildKit tools not found**: Use an image that includes BuildKit tools, such as `moby/buildkit:master`.

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
