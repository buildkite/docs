# Docker registry authentication

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) pre-configures the `docker-login` and `ecr` plugins to run automatically as local agent hooks through the `pre-command` hook. This provides automatic authentication to Docker registries and Amazon ECR before each job runs, with no configuration required in your pipeline YAML.

The Agent Stack for Kubernetes requires explicit configuration in your pipeline YAML. Authentication plugins must be added to each step that needs registry access, and credentials must be managed as Kubernetes Secrets. Use the `ecr` plugin with AWS credentials for Amazon ECR registries, or the `docker-login` plugin with stored credentials for other Docker registries.

## Migrating to Agent Stack for Kubernetes

The Agent Stack for Kubernetes provides multiple approaches for Docker registry authentication:

- Use the `ecr` plugin for Amazon ECR registries if your build steps need to run Docker commands like `docker build`, `docker push`, or `docker pull`
- Use the `docker-login` plugin for other Docker registries if your build steps need to run Docker commands
- Use `imagePullSecrets` if you need Kubernetes to authenticate when pulling private container images for your job pods

Many users need multiple approaches depending on their registry types and use cases.

### Using the docker-login plugin for Docker commands

For complete details on all available configuration options for the `docker-login` plugin, see the plugin's [README](https://github.com/buildkite-plugins/docker-login-buildkite-plugin#configurations).

### Store credentials as a generic secret

Create a Kubernetes Secret containing your Docker registry password:

```bash
kubectl create secret generic docker-login-credentials \
  --from-literal=DOCKER_LOGIN_PASSWORD='your-password-here' \
  -n buildkite
```

> 📘 Amazon ECR registries
> For Amazon ECR registries, we recommend using the [`ecr` plugin](#using-the-ecr-plugin-for-amazon-ecr) instead of the `docker-login` plugin. The `ecr` plugin automatically handles authentication and credential refresh, eliminating the need to manually manage tokens that expire every 12 hours.

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

### Using the ecr plugin for Amazon ECR

For Amazon ECR registries, the `ecr` plugin provides a better experience than manually managing credentials. The plugin automatically handles `docker login` before each step and works with AWS credentials that are automatically refreshed, eliminating the 12-hour token expiry issue.

#### Provide AWS credentials to your pods

The `ecr` plugin requires AWS credentials to be available in your job pods. You can provide these credentials using IAM Roles for Service Accounts (IRSA) or by storing them as Kubernetes Secrets.

#### Using IAM Roles for Service Accounts (IRSA)

IAM Roles for Service Accounts (IRSA) allows your Kubernetes pods to assume AWS IAM roles automatically. AWS handles credential rotation, so you don't need to manage tokens manually. For more information, see the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) on IAM Roles for Service Accounts.

Configure your service account with the appropriate IAM role annotation in your controller values:

```yaml
# values.yaml
config:
  pod-spec-patch:
    serviceAccountName: buildkite-agent
```

#### Using AWS credentials as Kubernetes Secrets

Alternatively, you can store AWS credentials as a Kubernetes Secret:

```bash
kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID='your-access-key' \
  --from-literal=AWS_SECRET_ACCESS_KEY='your-secret-key' \
  -n buildkite
```

Then configure the controller to mount these credentials:

```yaml
# values.yaml
config:
  default-command-params:
    envFrom:
      - secretRef:
          name: aws-credentials
```

#### Configure the ecr plugin in your pipeline

Add the `ecr` plugin to steps that need to interact with ECR registries:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    commands: |
      docker build -t myimage:latest .
      docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/myimage:latest
    agents:
      queue: kubernetes
    plugins:
      - ecr#v2.11.0:
          region: us-east-1
      - kubernetes:
          podSpec:
            containers:
              - image: docker:latest
```

For ECR registries in different AWS accounts, specify the account IDs:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Build and push to ECR"
    commands: |
      docker build -t myimage:latest .
      docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/myimage:latest
    agents:
      queue: kubernetes
    plugins:
      - ecr#v2.11.0:
          account-ids: "123456789012"
          region: us-east-1
      - kubernetes:
          podSpec:
            containers:
              - image: docker:latest
```

For complete details on all available configuration options, see the `ecr` plugin [README](https://github.com/buildkite-plugins/ecr-buildkite-plugin#options).

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

For Amazon ECR:

```bash
kubectl create secret docker-registry ecr-credentials \
  --docker-server=123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region us-east-1)" \
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
