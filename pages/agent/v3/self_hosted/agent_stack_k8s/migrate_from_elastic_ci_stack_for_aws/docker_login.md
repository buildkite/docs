# Docker registry authentication

The [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) pre-configures the [`docker-login` plugin](https://github.com/buildkite-plugins/docker-login-buildkite-plugin) to run automatically as a local [agent hook](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins) through the `pre-command` hook. This provides automatic authentication to Docker registries before each job runs, with no configuration required in your pipeline YAML.

The Agent Stack for Kubernetes requires explicit configuration in your pipeline YAML. The `docker-login` plugin must be added to each [pipeline step](/docs/pipelines/configure/defining-steps) that needs registry access, and credentials must be managed as Kubernetes Secrets.

> 📘 Amazon ECR registries
> For Amazon ECR registries, see [Amazon ECR authentication](/docs/agent/v3/self-hosted/agent-stack-k8s/migrate-from-elastic-ci-stack-for-aws/ecr) instead. The `ecr` plugin provides a better experience for ECR by automatically handling authentication and credential refresh.

## Migrating to Agent Stack for Kubernetes

Learn more about all available configuration options for the `docker-login` plugin, in the plugin's [Configurations section of its README](https://github.com/buildkite-plugins/docker-login-buildkite-plugin#configurations).

### Store credentials as a generic secret

Create a Kubernetes Secret containing your Docker registry password:

```bash
kubectl create secret generic docker-login-credentials \
  --from-literal=DOCKER_LOGIN_PASSWORD='your-password-here' \
  -n buildkite
```

### Configure the plugin in your pipeline

Add the `docker-login` plugin to each step that requires Docker registry access:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build and push"
    commands: |
      docker build -t myimage:latest .
      docker push myimage:latest
    agents:
      queue: kubernetes
    plugins:
      - docker-login#v3.0.0:
          username: myusername
          password-env: DOCKER_LOGIN_PASSWORD
          server: docker.io  # optional, defaults to Docker Hub
      - kubernetes:
          podSpec:
            containers:
              - image: docker:latest
                env:
                  - name: DOCKER_LOGIN_PASSWORD
                    valueFrom:
                      secretKeyRef:
                        name: docker-login-credentials
                        key: DOCKER_LOGIN_PASSWORD
```

### Using controller configuration for all jobs

If all jobs in your cluster need to authenticate to the same Docker registry, you can configure the credentials at the controller level instead of per-pipeline:

```yaml
# values.yaml
config:
  default-command-params:
    envFrom:
      - secretRef:
          name: docker-login-credentials
```

You'll still need to add the `docker-login` plugin to your pipeline steps, but the credentials will be automatically available to all containers.

## Using imagePullSecrets for pulling container images

If you need Kubernetes to authenticate when pulling private container images for your job pods, use `imagePullSecrets`. This is a Kubernetes-native feature separate from the `docker-login` plugin. For more information about `imagePullSecrets`, see the [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/).

### Create a Docker registry secret

Use the `kubectl create secret docker-registry` command to create a Kubernetes secret specifically for pulling images:

```bash
kubectl create secret docker-registry my-registry-credentials \
  --docker-server=docker.io \
  --docker-username=myusername \
  --docker-password=mypassword \
  --docker-email=my@email.com \
  -n buildkite
```

### Configure imagePullSecrets in your pipeline

Add the `imagePullSecrets` configuration to your pipeline using the Kubernetes plugin:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Run private image"
    command: echo "Running from private image"
    agents:
      queue: kubernetes
    plugins:
      - kubernetes:
          podSpec:
            imagePullSecrets:
              - name: my-registry-credentials
            containers:
              - image: myusername/my-private-image:latest
```

### Configure imagePullSecrets at the controller level

To use the same registry credentials for all jobs in your cluster, configure `imagePullSecrets` in your controller values file:

```yaml
# values.yaml
config:
  pod-spec-patch:
    imagePullSecrets:
      - name: my-registry-credentials
```

This automatically adds the image pull secret to all job pods without requiring per-pipeline configuration.
