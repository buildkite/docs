# Deploying to Kubernetes

This tutorial demonstrates deploying to Kubernetes using Buildkite best
practices.

The tutorial uses one pipeline for tests and another for deploys.
The test pipeline runs tests and push a Docker image to a registry. The deploy
pipelines uses the `DOCKER_IMAGE` environment variable to create a [Kubernetes
deployment][k8s_deployment] using `kubectl`. Then, you'll see how to link them
together to automate deploys from `main` branch.

First up, you need to add a step to your existing test pipeline that pushes a
Docker image. Also check your agents have `kubectl` access to your target
cluster. Refer to the notes at the end of tutorial for tips on setting this
up.

<%= image "final_test_pipeline.png", width: 1440/2, height: 430/2, alt: 'Final Test Pipeline' %>

## Create the deploy pipeline

This section covers creating a new Buildkite pipeline that loads steps from
`.buildkite/pipeline.deploy.yml`. We'll use a [trigger
steps](/docs/pipelines/configure/step-types/trigger-step) later on to connect
the test and deploy pipelines.

The first step will be a pipeline upload using our new deploy pipeline YAML
file. Create a new pipeline. Enter `buildkite-agent pipeline upload
.buildkite/pipeline.deploy.yml` in the commands to run field.

<%= image "new_pipeline.png", width: 1440/2, height: 820/2, alt: 'Creating a New Pipeline'  %>

Now create `.buildkite/pipeline.deploy.yml` with a single step. We'll write the
deploy script in the next step.

```yml
steps:
  - label: "\:rocket\: Push to \:kubernetes\:"
    command: script/buildkite/deploy
    concurrency: 1
    concurrency_group: deploy/tutorial
```
{: codeblock-file="pipeline.yml"}

Set `concurrency` and `concurrency_group` when updating mutable state. These
settings ensure only one step runs at a time.

## Writing the deploy script

The next step is writing a deploy script that generates a [Kubernetes deployment
manifest][k8s_deployment] from the `DOCKER_IMAGE` environment variable.

Let's start with manifest file. This sample file creates a Deployment with
three replicas (horizontal scale in Kubernetes lingo) each listening port
`3000`. Change the `containerPort` to fit your application.

> 📘
> The <a href="https://kubernetes.io/docs/concepts/workloads/controllers/deployment/">official deployment documentation</a> covers much more than what fits in this tutorial. Refer back to these docs for information on setting CPU and memory, controlling networking, deployment update strategies, and how to expose your application to the internet.

Let's call this file `k8s/deployment.yml`.

```yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tutorial
  labels:
    app: tutorial
spec:
  # TODO: replace with a value that fits your application
  replicas: 3
  selector:
    matchLabels:
      app: tutorial
  template:
    metadata:
      labels:
        app: tutorial
    spec:
      containers:
        - name: app
          image: "${DOCKER_IMAGE}"
          ports:
            # TODO: replace with the correct port for your application
            - containerPort: 3000
```
{: codeblock-file="k8s/deployment.yml"}

Note manifest includes `${DOCKER_IMAGE}`. There is no environment variable
substitution in YAML or `kubectl` itself. This is where our custom deploy script
comes in. Our deploy script will use `envsubst` ("environment substitute";
[docs](https://linux.die.net/man/1/envsubst)) as a minimal templating solution.
The resulting output may be piped directly into `kubectl`.

The full script has three parts:

1. Check `$DOCKER_IMAGE` is set
1. Generate a complete manifest with `envsubst` and apply with `kubectl`
1. Wait for Kubernetes to complete the deploy.

This fits neatly into a Bash script. Here's the complete `script/buildkite/deploy`:

```bash
#!/usr/bin/env bash

set -euo pipefail

if [ -z "${DOCKER_IMAGE:-}" ]; then
  echo "\:boom\: \$DOCKER_IMAGE missing" 1>&2
  exit 1
fi

manifest="$(mktemp)"

echo '--- \:kubernetes\: Shipping'

envsubst < k8s/deployment.yml > "${manifest}"
kubectl apply -f "${manifest}"

echo '--- \:zzz\: Waiting for deployment'
kubectl wait --for condition=available --timeout=300s -f "${manifest}"
```

You can test your pipeline now that everything is in place. All you need is your
Docker image.

## Test the pipeline

Open the deployment pipeline and click "New Build". Click "Options" and set the
`DOCKER_IMAGE` environment variable.

<%= image "manual_deployment.png", width: 1382/2, height: 1542/2, alt: "New Manual Build" %>

Assuming your agents have the required access to run `kubectl` against your cluster, then success! :tada:

<%= image "manual_deployment_success.png", width: 1440/2, height: 750/2, alt: "Manual Build Success" %>

## Continuous deployment

We'll use a [trigger steps](/docs/pipelines/configure/step-types/trigger-step)
to connect the test and deploy pipelines. This effectively creates a continuous
deployment pipeline.

First, add a wait step at the end of your existing `.buildkite/pipeline.yml`
otherwise deploys will trigger at the wrong time, and even for failed builds!

```yml
  # Add a wait step to only deploy after all steps complete
  - wait

  # More steps to follow
```
{: codeblock-file="pipeline.yml"}

Next add a `trigger` step:

```yml
  - label: ':rocket: Deploy'
    # TODO: replace with your deploy pipeline's name
    trigger: kubernetes-tutorial-deploy
    # Only trigger on main build
    build:
      message: "${BUILDKITE_MESSAGE}"
      commit: "${BUILDKITE_COMMIT}"
      branch: "${BUILDKITE_BRANCH}"
      env:
        # TODO: replace with your Docker image name
        DOCKER_IMAGE: "asia.gcr.io/buildkite-kubernetes-tutorial/app:${BUILDKITE_BUILD_NUMBER}"
    branches: main
```
{: codeblock-file="pipeline.yml"}

This `trigger` step creates a build with the same message, commit, and branch.
`buildkite-agent pipeline-upload` interpolates environment variables so the
correct values are replaced when the pipeline starts. The `env` setting passes
along the `DOCKER_IMAGE` environment variable.

Lastly, the `branches` options indicates to only build on `main`. This
prevents deploying unexpected topic branches.

It's magic time. Push some code. :tada: Continuous deployment! If something
goes wrong, then verify your `kubectl` and Kubernetes versions are compatible.
You can check with `kubectl version`. If your agents cannot connect to the
cluster, then check the kubectl access section for setup advice.

<%= image "final_test_pipeline.png", width: 1440/2, height: 430/2, alt: 'Final Test Pipeline' %>

## Next steps

Congratulations! :tada: You've setup a continuous deployment pipeline to
Kubernetes. Practically speaking there are some things to do next.

- Try a [block step](/docs/pipelines/configure/step-types/block-step) before the
  trigger to enforce manual deploys.
- Use [GitHub's Deployment API](https://buildkite.com/blog/github-deployments)
  to trigger deployments from external tooling (for example, ChatOps)
- Expose the application to the internet with [Kubernetes
  Service](https://kubernetes.io/docs/concepts/services-networking/service/).
- Replace the `envsubst` implementation with something like [kustomize](https://kustomize.io/)

## Configuring kubectl access

Configuring `kubectl` access depends on your infrastructure. Here's an overview
for common scenarios.

If you're on GCP using agents on GCE and a GKE cluster:

1. Grant GCE agents GKE access with a [service account](https://cloud.google.com/compute/docs/access/service-accounts)
1. Install `gcloud` agent instances
1. Use `gcloud container clusters get-credentials` to get `kubectl` access

If you're on AWS using agents on EC2 and an EKS cluster:

1. Grant agent access to EKS API calls with an instance profile
1. [Register the Buildkite agent IAM role with EKS](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
1. [Install kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) on agents
1. [Install IAM authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) on agents
1. Install the AWS CLI
1. Use `aws update-kubeconfig` to get [kubectl access](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)

[pipelines]: /docs/pipelines
[k8s_deployment]: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
