---
toc: false
---

# Sidecars

You can add sidecar containers to your job by specifying them under the `sidecars` key of the `kubernetes` plugin. These containers are started at the same time as the job's `command` containers. However, there is no guarantee that your `sidecar` containers will have started before the commands in your job's `command` containers are executed. Therefore, using retries or a tool like [wait-for-it](https://github.com/vishnubob/wait-for-it) is recommended to avoid failed dependencies in the event that the `sidecar` container is still in the process of getting started.

> 📘 Sidecar container differences prior to 0.35
> Prior to 0.35.0, the `sidecar` containers configured by the Agent Stack for Kubernetes controller differ from [sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/) defined by Kubernetes. True Kubernetes sidecar containers run as init containers, whereas `sidecar` containers defined by the controller run as application containers in the Pod alongside the job's `command` containers.

The following pipeline example shows how to use an `nginx` container as a sidecar container and run `curl` from the job's `command` container to interact with the `nginx` container:

```
steps:
  - label: ":k8s: Use nginx sidecar"
    agents:
      queue: "kubernetes"
    plugins:
      - kubernetes:
          sidecars:
            - image: nginx:latest
          podSpec:
            containers:
              - image: curlimages/curl:latest
                name: curl
                command:
                  - curl --retry 10 --retry-all-errors localhost:80
```

