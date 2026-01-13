# Amazon ECR authentication

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) pre-configures the [`ecr` plugin](https://github.com/buildkite-plugins/ecr-buildkite-plugin) to run automatically as a local agent [hook](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins) through the `pre-command` hook. This provides automatic authentication to Amazon ECR before each job runs, with no configuration required in your pipeline YAML.

When using Agent Stack for Kubernetes, you need to add the `ecr` plugin to each pipeline [step](/docs/pipelines/configure/defining-steps) that needs ECR access and ensure AWS credentials are available to your jobs.

> 📘 Other Docker registries
> For Docker Hub, Google Container Registry, or other Docker registries, see [Docker registry authentication](/docs/agent/v3/self-hosted/agent-stack-k8s/migrate-from-elastic-ci-stack-for-aws/docker-login) instead. The `docker-login` plugin provides authentication for non-ECR registries.

## Migrating to Agent Stack for Kubernetes

When migrating to Agent Stack for Kubernetes, you need to explicitly configure the `ecr` plugin in your pipeline YAML for each step that needs ECR access. The plugin automatically handles `docker login` before each step using AWS credentials that are automatically refreshed.

### Provide AWS credentials to your Pods

The `ecr` plugin requires AWS credentials to be available in your job Pods. You can provide these credentials using IAM Roles for Service Accounts (recommended for EKS clusters), AWS credentials stored as Kubernetes Secrets, or the [`aws-assume-role-with-web-identity` plugin](https://buildkite.com/resources/plugins/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin/) with [Buildkite OIDC](/docs/pipelines/security/oidc) tokens.

To learn more about all available configuration options for the `ecr` plugin, see the plugin's [README](https://github.com/buildkite-plugins/ecr-buildkite-plugin#options).

#### Using IRSA

IAM Roles for Service Accounts (IRSA) is the recommended approach for EKS clusters. IRSA allows your Kubernetes Pods to assume AWS IAM roles automatically. AWS handles credential rotation, so you don't need to manage tokens manually. For more information, see the [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) on IAM Roles for Service Accounts.

To start using IRSA, first, create a Kubernetes [service account](https://kubernetes.io/docs/concepts/security/service-accounts/) with the IAM role annotation:

```yaml
# serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: buildkite-agent
  namespace: buildkite
  annotations:
    eks.amazonaws.com/role-arn: arn\:aws\:iam::123456789012:role/buildkite-agent-ecr-role
```

Then configure the controller to use this service account:

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

With the credentials configured at the controller level, the credentials are automatically available to all job containers. Add the `ecr` plugin to your pipeline steps:

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
              - image: my-custom-image:latest
```

> 📘 Container image requirements
> The `ecr` plugin requires both the AWS CLI and Docker to be available in your container. You'll need a custom image that includes both tools.

#### Using the AWS assume-role-with-web-identity plugin

The [AWS assume-role-with-web-identity plugin](https://github.com/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin) uses Buildkite OIDC tokens to assume an AWS IAM role without storing AWS credentials. You won't need to manage long-lived credentials in Kubernetes Secrets.

Before using this plugin, you must configure an OIDC identity provider in AWS with a provider URL of `https://agent.buildkite.com` and an audience of `sts.amazonaws.com`. See the plugin's [AWS configuration documentation](https://buildkite.com/resources/plugins/buildkite-plugins/aws-assume-role-with-web-identity-buildkite-plugin/) for detailed setup instructions.

Add the plugin before the `ecr` plugin in your pipeline:

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
      - aws-assume-role-with-web-identity#v1.4.0:
          role-arn: arn\:aws\:iam::123456789012:role/ecr-access-role
      - ecr#v2.11.0:
          region: us-east-1
      - kubernetes:
          podSpec:
            containers:
              - image: my-custom-image:latest
```

> 📘 Container image requirements
> Both the `aws-assume-role-with-web-identity` and `ecr` plugins require the AWS CLI to be available in your container, and the commands require Docker. You'll need a custom image that includes both the AWS CLI and Docker.

## Using imagePullSecrets for pulling container images

If you need Kubernetes to be able to authenticate when pulling private container images from ECR for your job Pods, configure authentication for the [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/). It is separate from the `ecr` plugin, which handles authentication for Docker commands that run inside your job containers.

Kubernetes provides two approaches for kubelet authentication to ECR. You can use the kubelet credential provider, which dynamically retrieves credentials without storing them in your cluster (recommended), or create a Docker registry secret with static credentials that expire after 12 hours.

### Using kubelet credential provider

The kubelet credential provider is the recommended approach. It dynamically retrieves ECR credentials without storing them as secrets in your cluster. This eliminates the 12-hour token expiry issue and reduces credential management overhead.

This approach requires Kubernetes 1.26 or later and cluster-level configuration access to install the credential provider plugin on all nodes. For setup instructions, see the [Kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-credential-provider/) on kubelet credential providers.

Configure the credential provider on your cluster nodes with a configuration file:

```yaml
# /etc/kubernetes/credentialproviders/config.yaml
apiVersion: kubelet.config.k8s.io/v1
kind: CredentialProviderConfig
providers:
  - name: ecr-credential-provider
    matchImages:
      - "*.dkr.ecr.*.amazonaws.com"
      - "*.dkr.ecr.*.amazonaws.com.cn"
      - "*.dkr.ecr-fips.*.amazonaws.com"
    defaultCacheDuration: "12h"
    apiVersion: credentialprovider.kubelet.k8s.io/v1
```

Once configured at the cluster level, the kubelet automatically authenticates to ECR when pulling images. No pipeline configuration changes are required.

### Using Docker registry secrets

If you cannot configure the kubelet credential provider, you can create a Kubernetes secret with ECR credentials:

```bash
kubectl create secret docker-registry ecr-credentials \
  --docker-server=123456789012.dkr.ecr.us-east-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$(aws ecr get-login-password --region us-east-1)" \
  -n buildkite
```

> 📘 Token expiry
> ECR tokens expire after 12 hours. You'll need to refresh this secret periodically using a Kubernetes CronJob that runs every few hours to fetch a new token and update the secret. For more information about CronJobs, see the [Kubernetes documentation on CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

#### Configure imagePullSecrets in your pipeline

When using Docker registry secrets, add the `imagePullSecrets` configuration to your pipeline using the Kubernetes plugin:

```yaml
# pipeline.yaml
steps:
  - label: "\:docker\: Run private ECR image"
    command: echo "Running from private ECR image"
    agents:
      queue: kubernetes
    plugins:
      - kubernetes:
          podSpec:
            imagePullSecrets:
              - name: ecr-credentials
            containers:
              - image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-private-image:latest
```

#### Configure imagePullSecrets at the controller level

When using Docker registry secrets, you can configure `imagePullSecrets` at the controller level to apply them to all jobs in your cluster:

```yaml
# values.yaml
config:
  pod-spec-patch:
    imagePullSecrets:
      - name: ecr-credentials
```

This configuration automatically adds the image pull secret to all job Pods without requiring per-pipeline configuration.
