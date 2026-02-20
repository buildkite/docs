---
toc_include_h3: false
---

# Building Docker images

[Kaniko](https://github.com/GoogleContainerTools/kaniko) builds container images from a Dockerfile without requiring a Docker daemon, making it ideal for CI/CD environments that lack or don't need privileged access. This guide shows you how to use Kaniko with [Buildkite Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic_ci_stack) to build and push images directly to [Buildkite Package Registries](/docs/package_registries).

Unlike traditional Docker builds, Kaniko runs as a container and executes each command in your Dockerfile in the user space. This approach eliminates the need for using [Docker-in-Docker](https://www.docker.com/resources/docker-in-docker-containerized-ci-workflows-dockercon-2023/) or privileged mode while maintaining full compatibility with the standard Dockerfiles. You can authenticate using short-lived [OpenID Connect (OIDC)](https://openid.net/developers/how-connect-works/) tokens (see the [example](#running-kaniko-in-docker-example-pipeline) below), leverage registry-based caching to speed up the builds, and push to any [Open Container Initiative (OCI)](https://opencontainers.org/)-compliant container registry.

> 📘 On Kaniko support
> Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases.

## One-time package registry setup

Create a [Buildkite Package Registry](/docs/package-registries) for container images through the Buildkite web interface:

1. Navigate to your Buildkite organization and select **Package Registries** from the global navigation.
1. Click **New registry**.
1. Provide a name (for example, `my-container-registry`) and an optional description for your registry.
1. Select **OCI Image (Docker)** as the ecosystem type.
1. Assign appropriate team access permissions (select teams that need access to the registry).
1. Click **Create Registry**.
1. Configure an OIDC policy to allow your agents to push images. To do it, select **Settings** > **OIDC Policy** and add the following policy that allows agents to authenticate using OIDC tokens. You'll need to replace `<your-org-slug>` and `<your-pipeline-slug>` in the policy with your Buildkite organization and pipeline slugs.

    ```yaml
    - iss: https://agent.buildkite.com
      scopes:
        - read_packages
        - write_packages
      claims:
        organization_slug: <your-org-slug>
        pipeline_slug: <your-pipeline-slug>
        build_branch: main
    ```

Note that the `build_branch` claim restricts image pushes to the specified branch. See [OIDC in Buildkite Package Registries](/docs/package_registries/security/oidc) for more configuration options.

For more information regarding registries, see [Manage registries](/docs/package_registries/registries/manage).

> 📘 Registry compatibility
> While the example uses [Buildkite Package Registries](/docs/package-registries), Kaniko can work with any OCI-compliant container registry. To use a different registry (for example, Docker Hub, Amazon ECR, Google Container Registry, Azure Container Registry, and so on), adjust the authentication method and the destination URL accordingly.

## Push using Kaniko

Commit your changes. The step in your pipeline configuration will:

- Build the Docker image using [Kaniko](https://github.com/GoogleContainerTools/kaniko) (no Docker daemon required).
- Push the image directly to the [Buildkite Package Registries](/docs/package_registries) using a short-lived OIDC token retrieved by the Buildkite Agent.

> 📘 SSH repository requirements
> If your Git repository uses SSH, make sure your [S3 secrets bucket for Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) contains a `private_ssh_key` at the correct prefix (or switch to HTTPS + `git-credentials`).

## Running Kaniko in Docker

Kaniko runs inside a Docker container on the Elastic CI Stack for AWS agent, so no Docker-in-Docker, privileged mode, or Docker daemon are required for the build.

### Kaniko image availability

Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases. So there are several options you can choose from to run Kaniko in Docker.

#### Option 1: Google's final published images

You can use Google's final published Kaniko images from June 2025 (publicly available):

- `gcr.io/kaniko-project/executor:v1.24.0`
- `gcr.io/kaniko-project/executor:v1.24.0-debug`

#### Option 2: Chainguard-maintained images

Chainguard builds and publishes images for Kaniko, but requires a subscription to their services for access to the images:

- `cgr.dev/chainguard/kaniko:latest`
- `cgr.dev/chainguard/kaniko:latest-debug`

> 📘 Image directory reference
> See [Chainguard's image directory](https://images.chainguard.dev/directory/image/kaniko/versions) for the versions and access details.

#### Option 3: Build your own images with the Chainguard fork

If you need to use a specific Kaniko version, a custom configuration, or want to host Kaniko images in your own container registry, you can also build your own images by running the following commands:

```bash
# Build the latest Kaniko image from the Chainguard fork
git clone https://github.com/chainguard-dev/kaniko.git
cd kaniko
docker build --target kaniko-executor -t your-registry/kaniko:latest --file deploy/Dockerfile .
docker push your-registry/kaniko:latest

# Build the debug image
docker build --target kaniko-debug -t your-registry/kaniko:debug --file deploy/Dockerfile .
docker push your-registry/kaniko:debug
```

These commands clone the Chainguard Kaniko fork, build both the standard executor and debug images, and push them to your container registry.

Note that you will need to update the image references in your pipeline to use your own registry.

### Example pipeline

Here's a complete example of using Kaniko for building and pushing a container image to Buildkite Package Registries.

#### Project hierarchy

The example pipeline uses the following project structure to organize the Kaniko build configuration. The `.buildkite` directory contains the pipeline definition and build scripts, while application files remain in the project root.

```text
project-root/
├── .buildkite/
│   ├── pipeline.yml
│   └── steps/
│       └── kaniko.sh
├── Dockerfile
├── package.json
└── app.js
```

#### Pipeline configuration

This step defines a pipeline that builds and pushes a Docker image using Kaniko. It sets the package registry name as an environment variable and runs the Kaniko build script.

```yaml
steps:
  - label: ":whale: Build and push with Kaniko"
    env:
      PACKAGE_REGISTRY_NAME: "my-container-registry"
    commands:
      - bash .buildkite/steps/kaniko.sh
```
{: codeblock-file=".buildkite/pipeline.yml"}

#### Kaniko build script

This script builds and pushes a Docker image using Kaniko. It generates an image tag from the commit hash and build number, requests an OIDC token for authentication, creates a Docker config file with the token, runs Kaniko to build the image, and then pulls and runs the built image to verify that it works.

```bash
#!/bin/bash
set -euo pipefail

TAG="$(echo "${BUILDKITE_COMMIT:-local}" | cut -c1-12)-${BUILDKITE_BUILD_NUMBER:-0}"
IMG="packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/hello-kaniko:${TAG}"

# Use debug image if KANIKO_DEBUG is set
if [[ "${KANIKO_DEBUG:-false}" =~ (true|on|1) ]]; then
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0-debug}"
else
  KANIKO="${KANIKO_IMAGE:-gcr.io/kaniko-project/executor:v1.24.0}"
fi

ORG="${BUILDKITE_ORGANIZATION_SLUG}"
REG="${PACKAGE_REGISTRY_NAME}"
REG_URL="packages.buildkite.com/${ORG}/${REG}"

echo "~~~ Configure OIDC token"

# 1) Request a short-lived OIDC token (aud must be the registry URL)
OIDC_TOKEN="$(buildkite-agent oidc request-token \
  --audience "https://packages.buildkite.com/${ORG}/${REG}" \
  --lifetime 300)"

# 2) Write Kaniko's Docker config with the OIDC token
#    Username must be "buildkite" for OIDC auth.
cat > config.json <<JSON
{
  "auths": {
    "${REG_URL}": {
      "username": "buildkite",
      "password": "${OIDC_TOKEN}"
    }
  }
}
JSON

echo "~~~ Building image using kaniko: ${IMG}"

# 3) Run Kaniko and push directly
docker run --rm \
  -v "$PWD":/workspace \
  -v "$PWD/config.json":/kaniko/.docker/config.json:ro \
  "${KANIKO}" \
  --dockerfile=/workspace/Dockerfile \
  --context=dir:///workspace \
  --destination="${IMG}" \
  --verbosity=info \
  --log-timestamp \
  --cache=true \
  --cache-repo="packages.buildkite.com/${ORG}/${REG}/hello-kaniko-cache"

# 4) Pull and run image built by Kaniko using the same OIDC token
echo "~~~ \:docker\: Pulling image: ${IMG}"
DOCKER_CONFIG="$PWD" docker pull "${IMG}"
echo "~~~ \:docker\: Running image: ${IMG}"
DOCKER_CONFIG="$PWD" docker run --rm "${IMG}"
```
{: codeblock-file=".buildkite/steps/kaniko.sh"}

#### Dockerfile

This Dockerfile creates a Node.js application image. It uses the Node.js 20 Alpine base image, sets the working directory, copies package files and installs dependencies, copies the application code, and sets the command to run the application.

```dockerfile
FROM public.ecr.aws/docker/library/node:20-alpine
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev || npm i --omit=dev
COPY app.js ./
CMD ["node","app.js"]
```
{: codeblock-file="Dockerfile"}

#### Package configuration

This package.json file defines the Node.js project metadata, including with the package name, version, and a start script that runs the application.

```json
{
  "name": "hello-kaniko",
  "version": "1.0.0",
  "private": true,
  "license": "MIT",
  "description": "Hello world app to demo Kaniko on Buildkite Elastic CI Stack for AWS",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  }
}
```
{: codeblock-file="package.json"}

#### Application code

This JavaScript file contains a simple application that prints a message to the console when executed.

```javascript
// app.js
console.log("Hello from Kaniko on Buildkite Elastic CI Stack for AWS!");
```
{: codeblock-file="app.js"}

> 📘 Docker login is not required
> You don't need `docker login` for this step as it requests a short-lived OIDC token and passes it to Kaniko using a Docker config file.

### Using the published images

After the pipeline completes successfully, your Docker image will be available in your Buildkite Package Registry.

#### Pull and run the image

Once your image is built and pushed to the Package Registry, you can pull and run it using standard Docker commands:

```bash
# Pull the image from your Package Registry
docker pull packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1

# Run the image
docker run --rm packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1
```

#### Push to other registries

If you need to push the image to registries other than the Buildkite Package Registries (for example, Docker Hub, AWS ECR, and so on), use the following commands:

```bash
# Tag for your target registry
docker tag packages.buildkite.com/acme-inc/my-container-registry/hello-kaniko:abc123-1 your-registry.example.com/hello-kaniko:abc123-1

# Push to your registry
docker push your-registry.example.com/hello-kaniko:abc123-1
```

### Verifying signed Kaniko images

To ensure the authenticity and integrity of Kaniko images, you can [verify their cryptographic signatures using Cosign](https://docs.sigstore.dev/cosign/verifying/verify/) before using those images in your builds.

#### Verifying Google's deprecated images

If you're using Google's final published images (`gcr.io/kaniko-project/executor:v1.24.0`), you can verify their signatures by running the following script. This script creates Google's public key file and uses Cosign to verify that the Kaniko image signature is authentic and hasn't been tampered with.

```bash
# Verify the Google Kaniko image signature with cosign (public key)
cat > cosign.pub <<'EOF'
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE9aAfAcgAxIFMTstJUv8l/AMqnSKw
P+vLu3NnnBDHCfREQpV/AJuiZ1UtgGpFpHlJLCNPmFkzQTnfyN5idzNl6Q==
-----END PUBLIC KEY-----
EOF

KANIKO_IMG="gcr.io/kaniko-project/executor:v1.24.0"
echo "Verifying signature of ${KANIKO_IMG} ..."
if docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify --key cosign.pub "${KANIKO_IMG}"; then
  echo "Signature verified OK for ${KANIKO_IMG}"
else
  echo "Signature verification FAILED for ${KANIKO_IMG}"
fi
```

Note that this verification uses Google's official public key and only applies to the deprecated images.

#### Signing and verifying custom-built images

If you build your own Kaniko images from the Chainguard fork, you can also sign them for enhanced security. This process involves generating a key pair, signing your images, and verifying them before use.

Generate a key pair and store in Buildkite secrets by running the following command:

```bash
# Generate signing key pair
cosign generate-key-pair
```

Then [create the secrets](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) using the Buildkite web interface:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select your cluster.
1. Select **Secrets** to access the **Secrets** page, then select **New Secret**.
1. Create a secret with key `kaniko-signing-private-key` and the contents of `cosign.key` as the value.
1. Create another secret with key `kaniko-signing-public-key` and the contents of `cosign.pub` as the value.
1. Sign your custom image after building:

    ```bash
    # Pull the private key from Buildkite secrets
    buildkite-agent secret get "kaniko-signing-private-key" > cosign.key

    # Sign your custom image and push signature to registry
    docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
      sign --key cosign.key your-registry/kaniko:latest
    ```

1. Verify your custom Kaniko image before using the following commands. These commands retrieve the public signing key from Buildkite secrets and use Cosign to verify that your custom Kaniko image's signature is valid and the image hasn't been modified.

    ```bash
    # Pull the public key from Buildkite secrets
    buildkite-agent secret get "kaniko-signing-public-key" > cosign.pub

    # Verify your custom image
    docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
      verify --key cosign.pub your-registry/kaniko:latest
    ```

#### Keyless signing with OIDC

For an alternative, more modern approach to signing, you can use keyless signing with OIDC instead of managing key pairs. This method uses [sigstore.dev](https://sigstore.dev/) as a third-party service for handling the signing process.

> 🚧 Important
> Keyless signing requires authenticating with an OAuth provider (like Google, GitHub, or Microsoft) through [sigstore.dev](https://sigstore.dev/). This means your OAuth identity will be used to create a temporary signing certificate stored in the sigstore's public transparency log. Consider your organization's security policies before using this approach.

To implement keyless signing, run the following commands. These commands use Cosign to sign and verify images without managing key pairs. The signing process authenticates with sigstore.dev using OIDC, and verification requires specifying the certificate identity and issuer that were used during signing.

```bash
# Keyless signing (requires OIDC authentication with sigstore.dev)
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  sign your-registry/kaniko:latest

# Keyless verification (requires certificate identity and issuer)
docker run --rm -v "$PWD:/work" -w /work cgr.dev/chainguard/cosign \
  verify \
  --certificate-identity="your-email@example.com" \
  --certificate-oidc-issuer="https://accounts.google.com" \
  your-registry/kaniko:latest
```

This approach ensures your custom-built Kaniko images are authentic and haven't been tampered with. For more details on Cosign signing and verification, see the [Chainguard Cosign documentation](https://edu.chainguard.dev/open-source/sigstore/cosign/how-to-sign-a-container-with-cosign/).

### Debugging with Kaniko debug image

When troubleshooting build issues, you can use the [Kaniko debug image](https://github.com/chainguard-dev/kaniko#debug-image) which includes additional debugging tools. The debug image contains utilities like `busybox` and `sh` for interactive debugging.

> 🚧 Prerequisites for interactive debugging
> To run interactive debugging commands on your [Elastic CI Stack for AWS EC2](/docs/agent/self-hosted/aws/elastic-ci-stack) instances, you must have configured the `KeyName` CloudFormation stack parameter during stack deployment. This allows you to SSH into the instances as the `ec2-user` to run local Docker commands.

For interactive debugging, you can run the debug image directly on your EC2 instance:

```bash
docker run -it --entrypoint=/busybox/sh gcr.io/kaniko-project/executor:v1.24.0-debug
```

> 📘 Interactive debugging limitations
> Interactive debugging only works when running Docker commands directly on the EC2 instance with the `-it` flags, not when it is executed through pipeline environment. Pipeline builds run non-interactively and cannot provide shell access.

To enable debug mode in your pipeline, set the `KANIKO_DEBUG` environment variable.

```yaml
steps:
  - label: ":whale: Build and Push with Kaniko Debug"
    env:
      KANIKO_DEBUG: "true"  # Use debug image (accepts: true, on, 1)
      PACKAGE_REGISTRY_NAME: "my-container-registry"
    commands:
      - bash .buildkite/steps/kaniko.sh
```

When `KANIKO_DEBUG` is set to `true`, `on`, or `1`, the pipeline will use the Kaniko debug image instead of the standard image. The debug image includes additional utilities like `busybox`, `sh`, and other debugging tools that can help with troubleshooting build issues, even though interactive shell access is not available in pipeline environments.

The debug image provides several debugging options:

- Verbose logging - add `--verbosity=debug` flag to the Kaniko command for detailed build logs.
- No-push mode - add `--no-push` flag to build without pushing to registry.
- Interactive shell access - run the debug image with `--entrypoint=/busybox/sh` and `-it` flags (only works when running Docker commands directly on the EC2 instance, not through pipeline builds).

## Troubleshooting common Kaniko issues

This section covers some common issues as well as their resolutions and prevention methods for using Kaniko with Buildkite Pipelines.

### "Invalid 'aud' claim" error

- Cause: OIDC policy is not configured correctly.
- Solution: Check your Package Registry's OIDC configuration in Buildkite (ensure it's configured for the correct ecosystem).

### 401/403 on push

- Cause: OIDC audience mismatch.
- Solution: Check that the audience exactly matches `https://packages.buildkite.com/${ORG}/${REG}` and your registry's OIDC settings allow that audience.

### Image push fails

- Cause: Authentication or registry configuration issues.
- Solution: Check your Package Registry configuration and OIDC policy.
