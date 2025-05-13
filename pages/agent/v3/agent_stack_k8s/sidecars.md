---
toc: false
---

# Sidecars

You can add sidecar containers to your job by specifying them under the `sidecars` key of the `kubernetes` plugin. These containers are started at the same time as the job's `command` containers. However, there is no guarantee that your `sidecar` containers will have started before the commands in your job's `command` containers are executed. Therefore, using retries or a tool like [wait-for-it](https://github.com/vishnubob/wait-for-it) is recommended to avoid failed dependencies in the event that the `sidecar` container is still in the process of getting started.

> 📘 Sidecar container differences
> The `sidecar` containers configured by the Agent Stack for Kubernetes controller differ from [sidecar containers](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/) defined by Kubernetes. True Kubernetes sidecar containers run as init containers, whereas `sidecar` containers defined by the controller run as application containers in the Pod alongside the job's `command` containers.

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

For example, you can use sidecar containers to run asynchronous commands against files or directories or both under the `/workspace` directory outside of the `command` containers:

```
steps:
  - label: ":k8s: Write file to extraVolumeMount on sidecar containers"
    agents:
      queue: "kubernetes"
    plugins:
      - kubernetes:
          sidecars:
            - image: alpine:latest
              command: ["sh"]
              args:
                - "-c"
                - |-
                  touch /workspace/pass-the-parcel
                  ls -lah /workspace/pass-the-parcel
          podSpec:
            containers:
              - image: alpine:latest
                command:
                  - |-
                    COUNT=0
                    until [[ $$((COUNT++)) == 15 ]]; do
                      [[ -f "/workspace/pass-the-parcel" ]] && break
                      echo "⚠️   Waiting for my package to be to be downloaded..."
                      sleep 1
                    done

                    if ! [[ -f "/workspace/pass-the-parcel" ]]; then
                      echo "⛔ My package has not been downloaded!"
                      exit 1
                    fi

                    echo "✅ My package has been downloaded!"
                    rm -f "/workspace/pass-the-parcel"
```
