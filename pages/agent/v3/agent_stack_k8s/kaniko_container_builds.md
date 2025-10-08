# Kaniko - Build Images in Kubernetes

[Kaniko](https://github.com/GoogleContainerTools/kaniko/tree/main#kaniko---build-images-in-kubernetes) is a tool for building container images from a Dockerfile, inside a container or Kubernetes cluster. Kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in user space. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

You are supposed to run Kaniko as an image: `gcr.io/kaniko-project/executor`. The Kaniko executor image is responsible for building an image from a Dockerfile and pushing it to a registry. Within the executor image,  the filesystem of the base image (the `FROM` image in the Dockerfile) is extracted. Next, the commands in the Dockerfile are executed, taking snapshots of the filesystem in user space after running each commands. After each command, a layer of changed files is appended to the base image (if one exists) and the image metadata is updated.

## Using Kaniko with Agent Stack for Kubernetes

This section explains how to use Kaniko executor to perform the following:

1. Build image and push to Buildkite Artifacts
1. Build image and push to Google Artifact Registry
1. Build image and push to Elastic Container Registry

### Build image and push to Buildkite Artifacts

```yaml
agents:
  queue: kubernetes
steps:
  - label: ":kaniko: Build image and push to artifacts"
    plugins:
      - kubernetes:
          podSpecPatch:
            containers:
              - image: gcr.io/kaniko-project/executor:debug
                name: container-0
                extraVolumeMounts:
                  - name: workspace
                    mountPath: /workspace
                command: ["/kaniko/executor"]
                args:
                  - "/kaniko/executor"
                  - "--dockerfile=/workspace/build/buildkite/src/Dockerfile"
                  - "--no-push"
                  - "--tarPath"
                  - "/workspace/image.tar"
    artifact_paths:
      - "/workspace/image.tar"
```

>
> Note that `debug` tag is used for the `executor` image, as the `latest` tag does not have `shell` in it, and with `agent-stack-k8s`, shell will be needed. To use the `latest` tag, generate a custom image of Kaniko executor with `shell` included.

### Build image and push to Google Artifact Registry

This section covers using Kaniko executor for building Docker images and pushing them to [Google Artifact Registry](https://cloud.google.com/artifact-registry/docs/overview). In order to push images to Google Artifact Registry, you need to have a Kubernetes secret that will have the token that provides the required permissions. For detailed steps on what permissions are necessary and how to create the secret, refer to the [secret creation documentation](https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#kubernetes-secret).

Once the secret is created, mount the secret into the container then export the secret as part of env `GOOGLE_APPLICATION_CREDENTIALS` into the executor.

```yaml
agents:
  queue: kubernetes
steps:
  - label: ":kaniko: Build image and push to Google artifact registry"
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

### Build image and push to Elastic Container Registry

This section covers pushing an image to Elastic Container Registry. Similarly to the previous section, you will need to set up [ECR credentials](https://github.com/chainguard-dev/kaniko?tab=readme-ov-file#pushing-to-amazon-ecr).

The example below also shows how to expose the secret by exporting them to the Kaniko executor.

```yaml
agents:
  queue: kubernetes
steps:
  - label: ":kaniko: Build image and push to Google artifact registry"
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
