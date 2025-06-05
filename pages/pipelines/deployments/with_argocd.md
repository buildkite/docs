# Deploying with Argo CD

[Argo CD](https://argoproj.github.io/cd/) is a continuous delivery tool specifically designed for Kubernetes. It focuses on deploying applications to Kubernetes clusters using GitOps principles, where the desired state of your applications is declaratively defined in Git repositories and automatically synchronized to your clusters.

Buildkite and Argo CD complement each other in modern CI/CD workflows. Buildkite takes care of the CI tasks like building, testing, and packaging applications, while Argo CD specializes in continuous deployment using GitOps methodology.

An example workflow for Buildkite plus Argo CD would look as follows:

1. Buildkite receives a code commit and triggers a build. 
1. The build process in Buildkite might include steps like packaging, testing, and creating Kubernetes manifests. 
1. Buildkite pushes the generated manifests to a GitOps repo, which is monitored by Argo CD. 
1. Argo CD detects the changes in the GitOps repo and automatically deploys the application to the target Kubernetes cluster. 

This approach allows for a clear separation of concerns: Buildkite handles the build and test processes, while Argo CD handles the deployment to Kubernetes. This simplifies the overall CI/CD pipeline and makes it easier to manage deployments. 


## Using Argo CD with Buildkite

Deployment to Kubernetes with Argo CD with the help of Buildkite consists of the following stages:

Step 1: You trigger the deployments to ArgoCD. For example:

```yaml
...
- label ":rocket: Trigger Argo CD Sync (Optional)"
    command: |
      echo "Triggering Argo CD application sync..."
      argocd app sync myapp --auth-token ${ARGOCD_TOKEN} --server ${ARGOCD_SERVER}
    env:
      ARGOCD_TOKEN: ${ARGOCD_AUTH_TOKEN}
      ARGOCD_SERVER: "argocd.myorg.com"
    if: build.branch == "main"
```

You can also use webhook-based synchronization approach. For example:

```yaml
- label ":hook: Webhook-Based Sync"
  command: |
    echo "Triggering Argo CD via webhook..."
    
    WEBHOOK_RESPONSE=$(curl -s -X POST "${ARGOCD_WEBHOOK_URL}" \
      -H "Content-Type: application/json" \
      -H "X-Webhook-Token: ${ARGOCD_WEBHOOK_TOKEN}" \
      -d '{
        "repository": {
          "url": "'${GITOPS_REPO}'"
        },
        "ref": "refs/heads/main",
        "commits": [{
          "id": "'${BUILDKITE_COMMIT}'",
          "message": "Deploy via Buildkite build '${BUILDKITE_BUILD_NUMBER}'"
        }]
      }')
    
    echo "Webhook response: ${WEBHOOK_RESPONSE}"
  env:
    ARGOCD_WEBHOOK_URL: "${ARGOCD_SERVER}/api/webhook"
    ARGOCD_WEBHOOK_TOKEN: ${WEBHOOK_SECRET}
...
```

Step 2: In your Buildkite pipeline configuration, add a [block step](/docs/pipelines/configure/step-types/block-step) that waits for the deployment to happen in Argo CD.

[example]

Step 3: Argo CD will then unblock the step through the API and add the deployment link in Argo CD's UI as well as in the Buildkite's build [annotations](/docs/agent/v3/cli-annotate).

[example]
