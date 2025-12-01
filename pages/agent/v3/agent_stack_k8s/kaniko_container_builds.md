# Kaniko container builds

[Kaniko](https://github.com/GoogleContainerTools/kaniko/tree/main#kaniko---build-images-in-kubernetes) is a tool for building container images from a Dockerfile, inside a container or Kubernetes cluster. Kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in user space. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

Run Kaniko as an image: `gcr.io/kaniko-project/executor`. The Kaniko executor image is responsible for building an image from a Dockerfile and pushing it to a registry. Within the executor image, the filesystem of the base image (the `FROM` image in the Dockerfile) is extracted. Next, the commands in the Dockerfile are executed, taking snapshots of the filesystem in user space after running each command. After each command, a layer of changed files is appended to the base image (if one exists) and the image metadata is updated.

## Using Kaniko with Agent Stack for Kubernetes

This section explains how to use the Kaniko executor to perform the following:

1. Build an image and push to Buildkite Package Registries
1. Build an image and push to Google Artifact Registry
1. Build an image and push to Elastic Container Registry

### Kaniko image availability

Google has deprecated support for the Kaniko project and no longer publishes new images to `gcr.io/kaniko-project/`. However, [Chainguard has forked the project](https://github.com/chainguard-dev/kaniko) and continues to provide support and create new releases. There are several options available for running Kaniko in Docker. Refer to the [Kaniko image availability options](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/kaniko_container_builds#running-kaniko-in-docker-kaniko-image-availability).

### Build an image and push to Buildkite Package Registries

This section covers using the Kaniko executor for building container images and pushing them to [Buildkite Package Registries](/docs/package_registries). To push images to Buildkite Package Registries, you need to first set up the following:

1. One-time package registry setup and OIDC policy
1. Create an agent hook to get OIDC token and set up Docker config
1. Mount the agent hook and buildkite-agent binary to the container

#### One-time package registry setup and OIDC policy

Follow the steps in [One-time package registry setup](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/kaniko-container-builds#one-time-package-registry-setup) to set up Buildkite Package Registry and the necessary OIDC policy.

#### Create an agent hook to get OIDC token and set up Docker config

For the Kaniko executor container to be able to push the image it built to Buildkite Package Registry, it needs to get an OIDC token using `buildkite-agent get oidc-token` and set up Docker config. To achieve this, an agent hook is needed and below is the config map for the agent hook

```yaml
#!/bin/sh
set -euo pipefail

echo "--- Generating OIDC token for Kaniko inside container"

# Use buildkite-agent binary (mounted in the container at /workspace/buildkite-agent)
OIDC_TOKEN="$(/workspace/buildkite-agent oidc request-token --audience "https://packages.buildkite.com/{BUILDKITE_ORG_SLUG}/{PACKAGE_REGISTRY_SLUG}" --lifetime 300)"

mkdir -p /kaniko/.docker
cat >/kaniko/.docker/config.json <<EOF
{
  "auths": {
    "packages.buildkite.com/{BUILDKITE_ORG_SLUG}/{PACKAGE_REGISTRY_SLUG}": { "username": "buildkite", "password": "${OIDC_TOKEN}" }
  }
}
EOF

echo "--- Docker config written to /kaniko/.docker/config.json"
```
#### Mount the agent hook and buildkite-agent binary to container

In this section, we will look at how to mount the agent hook created above, along with buildkite-agent binary to be able to push the image to Buildkite package registry. Here is the pipeline config:

```yaml
agents:
  queue: kubernetes

steps:
  - label: "Build image via Kaniko (OIDC)"
    env:
      PACKAGE_REGISTRY_NAME: "my-container-registry"
    plugins:
      - kubernetes:
          podSpecPatch:
            volumes:
              - name: agent-hooks
                configMap:
                  name: buildkite-agent-hooks
                  defaultMode: 493

              - name: kaniko-docker-config
                emptyDir: {}

            containers:
              - name: container-0
                image: gcr.io/kaniko-project/executor:debug
                env:
                - name: BUILDKITE_HOOKS_PATH
                  value: /buildkite/hooks
                # Mount hooks from ConfigMap
                volumeMounts:
                  - name: agent-hooks
                    mountPath: /buildkite/hooks

                  - name: kaniko-docker-config
                    mountPath: /kaniko/.docker

                # Mount workspace so buildkite-agent binary is accessible
                extraVolumeMounts:
                  - name: workspace
                    mountPath: /workspace

                command: ["/busybox/sh"]
                args:
                  - "-c"
                  - |
                    echo "--- Running Kaniko"
                    /kaniko/executor \
                       --dockerfile=/workspace/build/buildkite/src/Dockerfile \
                       --destination=packages.buildkite.com/${BUILDKITE_ORGANIZATION_SLUG}/${PACKAGE_REGISTRY_NAME}/kaniko-test:latest
```

> 📘 Using the debug tag
> The `debug` tag is used for the `executor` image, as the `latest` tag doesn't have a shell in it, and with `agent-stack-k8s`, a shell is needed. To use the `latest` tag, generate a custom image of the Kaniko executor with a shell included.

### Build an image and push to Google Artifact Registry

This section covers using the Kaniko executor for building container images and pushing them to [Google Artifact Registry](https://cloud.google.com/artifact-registry/docs/overview). To push images to Google Artifact Registry, you need a Kubernetes secret containing the token that provides the required permissions. For detailed steps on what permissions are necessary and how to create the secret, refer to the [secret creation documentation](https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#kubernetes-secret).

Once the secret is created, mount the secret into the container, then export the secret as the environment variable `GOOGLE_APPLICATION_CREDENTIALS` into the executor.

```yaml
agents:
  queue: kubernetes
steps:
  - label: "\:kaniko\: Build image and push to Google Artifact Registry"
    plugins:
      - kubernetes:
          podSpecPatch:
            containers:
              - image: gcr.io/kaniko-project/executor:debug
                name: container-0
                extraVolumeMounts:
                  - name: workspace
                    mountPath: /workspace
                volumeMounts:
                  - name: kaniko-secret
                    mountPath: /secret
                command: ["/busybox/sh"]
                args:
                  - "-c"
                  - |
                    export GOOGLE_APPLICATION_CREDENTIALS=/secret/kaniko-secret.json
                    /kaniko/executor \
                      --dockerfile=/workspace/build/buildkite/src/Dockerfile \
                      --destination=us-central1-docker.pkg.dev/gcp-project-id/testrepository/kaniko-test:latest
            volumes:
              - name: kaniko-secret
                secret:
                  secretName: kaniko-secret
```

### Build an image and push to Elastic Container Registry

This section covers pushing an image to Elastic Container Registry. Similar to the previous section, you will need to set up [ECR credentials](https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#pushing-to-amazon-ecr).

The example below also shows how to expose the secret by exporting it to the Kaniko executor.

```yaml
agents:
  queue: kubernetes
steps:
  - label: "\:kaniko\: Build image and push to Elastic Container Registry"
    plugins:
      - kubernetes:
          podSpecPatch:
            containers:
              - image: gcr.io/kaniko-project/executor:debug
                name: container-0
                extraVolumeMounts:
                  - name: workspace
                    mountPath: /workspace
                volumeMounts:
                  - name: aws-creds
                    mountPath: /root/.aws
                command: ["/busybox/sh"]
                args:
                  - "-c"
                  - |
                    export AWS_SHARED_CREDENTIALS_FILE=/root/.aws/credentials
                    export AWS_REGION=us-west-2
                    /kaniko/executor \
                      --dockerfile=/workspace/build/buildkite/src/Dockerfile \
                      --destination=123456789012.dkr.ecr.us-west-2.amazonaws.com/my-repo:latest
            volumes:
              - name: aws-creds
                secret:
                  secretName: aws-ecr-credentials
```
