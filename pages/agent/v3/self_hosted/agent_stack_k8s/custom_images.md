# Custom images

The [Agent Stack for Kubernetes controller](/docs/agent/v3/self-hosted/agent-stack-k8s) creates Pods with several containers, each with different purposes and image requirements. You can customize the images used for command containers to match your build environment needs.

## Container types and image requirements

When the controller creates a Pod to run a Buildkite job, it includes the following containers:

Container | Purpose | Image requirements
--------- | ------- | ------------------
`copy-agent` (init) | Copies `buildkite-agent` and `tini-static` binaries into `/workspace` | Uses the controller's default image. Cannot be customized.
`agent` | Runs `buildkite-agent start` and coordinates the job lifecycle | Uses the controller's default image. Cannot be customized.
`checkout` | Clones the repository and runs plugin checkout phases | Requires `git` and `buildkite-agent-entrypoint`. Custom images must be built from `buildkite/agent`.
`container-N` | Executes job commands | Requires a POSIX shell at `/bin/sh`. The `buildkite-agent` binary is available from `/workspace`.
`sidecar-N` | User-defined sidecar containers | No specific requirements from the controller.
{: class="responsive-table"}

The `copy-agent` init container copies the `buildkite-agent` binary and `tini-static` into `/workspace`, making them available to all command containers regardless of the base image. This means command containers don't need these binaries pre-installed.

## Specifying custom images

You can specify custom images for command containers using one of the three methods outlined below.

### Using the image attribute

In version 0.30.0 and later of the controller, use the `image` attribute directly in your pipeline step:

```yaml
steps:
  - label: "Run tests"
    agents:
      queue: kubernetes
    image: node:20-alpine
    commands:
      - npm install
      - npm test
```

This is the simplest approach for specifying a custom image for a single step.

### Using podSpecPatch

For more control over container configuration, use `podSpecPatch` in the `kubernetes` plugin:

```yaml
steps:
  - label: "Run tests"
    agents:
      queue: kubernetes
    commands:
      - npm install
      - npm test
    plugins:
      - kubernetes:
          podSpecPatch:
            containers:
              - name: container-0
                image: node:24-alpine
```

The container name must match the name assigned by the controller. The first command container is always `container-0`.

### Using controller configuration

To set a default image for all jobs processed by a controller, configure `pod-spec-patch` in the controller's `values.yaml`:

```yaml
config:
  pod-spec-patch:
    containers:
      - name: container-0
        image: your-registry.example.com/custom-build-image:latest
```

This applies to all jobs unless overridden at the pipeline level.

## Building custom images

When building custom images for command containers, consider the following requirements and recommendations.

### Minimum requirements

Command containers require a POSIX-compatible shell available at `/bin/sh`. The controller uses this shell to execute commands, so images like `scratch` or `distroless` won't work without modification.

The `buildkite-agent` binary is automatically available from `/workspace/buildkite-agent` after the `copy-agent` init container runs.

### Recommended additions

Depending on your build requirements, you may want to include:

- `bash` if your commands or plugins require Bash-specific features
- `git` if you need to run Git commands during the build (separate from checkout)
- `curl` or `wget` for downloading artifacts or dependencies
- Build tools specific to your language or framework

### Using the Buildkite Agent image as a base

You can use `buildkite/agent` as a base image for custom images that need agent tooling pre-installed:

```dockerfile
FROM buildkite/agent:3

# Install additional dependencies
RUN apk add --no-cache nodejs npm

# Add custom tooling
COPY scripts/build-tools.sh /usr/local/bin/
```

### Building from scratch

For minimal images, start from `alpine` or a language-specific base image:

```dockerfile
FROM alpine:3.23

# Install any required build tools
RUN apk add --no-cache \
    bash \
    curl \
    git
```

## Customizing the checkout container

The checkout container clones your repository before commands run. You can customize it to add tools like [Git LFS](https://git-lfs.com/) or configure environment variables.

### Controller-level configuration

To use a custom checkout image for all jobs processed by a controller, configure `pod-spec-patch` in the controller's `values.yaml`:

```yaml
config:
  pod-spec-patch:
    containers:
      - name: checkout
        image: your-registry.example.com/custom-checkout:latest
        env:
          - name: GIT_TERMINAL_PROMPT
            value: "0"
```

### Pipeline-level configuration

To customize the checkout container for a specific step, use `podSpecPatch` in the `kubernetes` plugin:

```yaml
steps:
  - label: "Build"
    agents:
      queue: kubernetes
    commands:
      - make build
    plugins:
      - kubernetes:
          podSpecPatch:
            containers:
              - name: checkout
                image: your-registry.example.com/custom-checkout:latest
                env:
                  - name: GIT_TERMINAL_PROMPT
                    value: "0"
```

If you don't need repository checkout, skip it using the `checkout.skip` option:

```yaml
steps:
  - label: "Build from artifact"
    agents:
      queue: kubernetes
    commands:
      - buildkite-agent artifact download "source.tar.gz" .
      - tar -xzf source.tar.gz
      - make build
    plugins:
      - kubernetes:
          checkout:
            skip: true
```

## Image pull configuration

When using private registries, configure image pull secrets in the controller or at the pipeline level.

### Controller-level configuration

Add image pull secrets to the controller's `values.yaml`:

```yaml
config:
  pod-spec-patch:
    imagePullSecrets:
      - name: my-registry-secret
```

### Pipeline-level configuration

Add image pull secrets for a specific step using `podSpecPatch`:

```yaml
steps:
  - label: "Build"
    agents:
      queue: kubernetes
    image: your-registry.example.com/private-image:latest
    commands:
      - make build
    plugins:
      - kubernetes:
          podSpecPatch:
            imagePullSecrets:
              - name: my-registry-secret
```

## Troubleshooting

This section covers some common issues you might run into when using custom images and how to solve these issues.

### Command fails with "sh: not found"

The image doesn't have a shell at `/bin/sh`. Use an image with a shell installed, or modify your Dockerfile to include one.

### Agent binary not found

If commands can't find `buildkite-agent`, check that:

- The `/workspace` volume is mounted correctly
- The `copy-agent` init container completed successfully
- Your command uses the correct path (`/workspace/buildkite-agent` or just `buildkite-agent` if PATH is configured)

### Plugins fail to run

Some plugins require specific binaries. For example:

- Docker-related plugins need the Docker CLI
- AWS plugins may need the AWS CLI
- Plugins using Bash features need `bash`

Check the plugin's documentation for the requirements.
