# Deploying with Argo CD

[Argo CD](https://argoproj.github.io/cd/):

- Is a continuous delivery tool specifically designed for Kubernetes.
- Focuses on deploying applications to Kubernetes clusters using GitOps principles, where the desired state of your applications is declaratively defined in Git repositories and automatically synchronized to your Kubernetes clusters.

Buildkite Pipelines and Argo CD complement each other in modern CI/CD workflows, where you can allow Pipelines to handle the CI tasks, such as building, testing, and packaging applications, and allow Argo CD to specialize in handling continuous deployment.

The following example workflow outlines how Buildkite would work with Argo CD:

1. Buildkite Pipelines receives a code commit and triggers a build.
1. The build process in Pipelines might include steps to package, test, and create Kubernetes manifests.
1. Buildkite Pipelines pushes the generated manifests to a GitOps repository, which is monitored by Argo CD.
1. Argo CD detects the changes in the GitOps repo and automatically deploys the application to the target Kubernetes cluster.

This approach allows for a clear separation of concerns—Pipelines handles the build and test processes, while Argo CD handles the deployment to Kubernetes. This simplifies the overall CI/CD pipeline and makes it easier to manage deployments.

## Using Argo CD with Buildkite Pipelines

There are various ways Argo CD could be used with Buildkite Pipelines. The most common ones include:

- The Buildkite agent pushes Kubernetes manifests to a GitOps repository and then waits for the GitOps engine to [reconcile](http://argo-cd.readthedocs.io/en/stable/operator-manual/reconcile/) the change to a target Kubernetes cluster.
- Buildkite Pipelines triggers Argo CD to deploy to Kubernetes.
- Buildkite Pipelines triggers Argo CD via Argo API to either [sync an application](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Sync), or [roll back a synchronization](https://cd.apps.argoproj.io/swagger-ui#tag/ApplicationService/operation/ApplicationService_Rollback), and monitors the deployment until completion.

## Deploying to Kubernetes with Argo CD triggered by Buildkite Pipelines

You can trigger the deployments to Argo CD through a command defined in your Buildkite pipeline definition. For example:

```yaml
...
- key: "deploy-to-dev"
  label: "Trigger Argo CD sync"
  command: |
    echo "Triggering Argo CD application sync..."
    argocd app sync myapp --auth-token ${MYARGOCD_TOKEN} --server ${MYARGOCD_SERVER}
  env:
      MYARGOCD_TOKEN: ${MYARGOCD_AUTH_TOKEN}
      MYARGOCD_SERVER: "argocd.example.com"
  if: build.branch == "main"
```

You can insert a [block step](/docs/pipelines/configure/step-types/block-step) before triggering Argo CD for deployment to make sure a condition for deployment is met. For example:

```yaml
...
  - if: build.branch == "main"
    key: "block-step-condition-for-deploy"
    block: "Deploy this to Dev?"
  - key: "deploy-to-dev"
    label: "Buildkite Agent to Argo CD CLI Manifest for Dev"
    command: |
      echo "--- :rocket: Deploying to Dev via Argo CD"
      argocd app sync my-app-dev --server $MYARGOCD_SERVER --auth-token $MYARGOCD_TOKEN
    env:
      MYARGOCD_TOKEN: ${MYARGOCD_AUTH_TOKEN}
      MYARGOCD_SERVER: "argocd.example.com"
...
```

> 🚧
> Bear in mind that these examples are aimed at providing you with a basic understanding of how to use Argo CD with Buildkite. For production-ready implementations, as discussed in [Risk considerations](/docs/pipelines/security/secrets/risk-considerations), it is _strongly recommended_ that you avoid using your secrets in plaintext pipeline files. Instead, you can use a [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets)-based approach.

## Using annotations to link to Argo CD

With the help of Buildkite's build [annotations](/docs/agent/v3/cli-annotate), you can include a deployment link to the Argo CD interface after the build has finished running to review the deployment status. For example:

```yaml
steps:
  - label: "Deploy"
    command: |
      buildkite-agent annotate "🚀 [View Deployment in Argo CD](https://argocd.myorg.com/applications/default/myapp)" --style info --context "deployment"
```
