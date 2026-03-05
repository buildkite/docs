# Pod templates

From v0.32.2 of agent-stack-k8s, the `kubernetes` plugin allows you to specify a `podTemplate`. The `podTemplate` attribute specifies the name of a [`PodTemplate` resource](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-template-v1/) in the same namespace as the stack controller. Pod templates function similarly to [`podSpec`](podspec), but hide the details of a `podSpec` from the pipeline definition.

Stack operators (who can create Kubernetes resources) can set up a shared library of templates. This allows updating pod specs separately from both the stack controller (as with `pod-spec-patch`) and all the pipelines using them, and avoids storing unnecessary platform details within each pipeline definition.

## How to use

1. Ensure you are using agent-stack-k8s v0.32.2 or later.
1. Create `PodTemplate` resources in the same namespace as the stack controller.
1. Refer to `PodTemplate` resources by name using the `podTemplate` key of the `kubernetes` plugin.

## Notes

`podTemplate` operates similarly to `podSpec`. It provides the initial spec of a pod that is then adjusted by the stack controller. If a `podSpec` is provided, `podTemplate` is ignored. To adjust a `podTemplate` within a step, use `podSpecPatch`.

 Other options that change the initial spec include:

* Step attributes such as `image` and `command`
* The resource class tag
* Checkout parameters, such as `skip`
* `pod-spec-patch` controller configuration and `podSpecPatch` plugin attribute

In addition to `spec` (a `PodSpec`), a `PodTemplate` can also specify metadata within the template. This metadata is ignored by the stack controller - only `spec` is used.

## Example

This example manifest defines a `PodTemplate` called `go-with-cache` in the `buildkite` namespace, that

* sets the container image to `golang:latest`,
* configures Go to use a [caching tool](https://github.com/bradfitz/go-tool-cache),
* attaches a persistent volume claim,
* sets a security context to change the user and group.

```yaml
apiVersion: v1
kind: PodTemplate
metadata:
  name: go-with-cache
  namespace: buildkite # Note: must be the same namespace as agent-stack-k8s
template:
  spec:
    containers:
      - name: container-0
        image: golang:latest
        env:
          - name: GOCACHEPROG
            value: "/tools/go-cacher -cache-server=http://gocached.default.svc.cluster.local:31364"
        volumeMounts:
          - name: tools
            mountPath: /tools
            readOnly: true
    volumes:
      - name: tools
        persistentVolumeClaim:
          claimName: tools-shared
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1001
```

Once a `PodTemplate` has been created in the cluster, it can be referred to from the `kubernetes` plugin. Here is a pipeline definition that uses the `go-with-cache` template (defined above) multiple times:

```yaml
steps:
  - label: "Go Build"
    command: go build -o /tmp/out .
    plugins:
      - kubernetes:
          podTemplate: go-with-cache

  - label: "Go Test"
    command: go test ./...
    plugins:
      - kubernetes:
          podTemplate: go-with-cache

  - label: "Go Vet"
    command: go vet
    plugins:
    - kubernetes:
        podTemplate: go-with-cache
```

The equivalent pipeline using only `podSpec` is quite lengthy, with repetitive, deeply-nested configurations containing platform details that are largely irrelevant to the pipeline steps (such as volume configuration):

```yaml
steps:
- label: "Go Build"
  command: go build -o /tmp/out .
  plugins:
    - kubernetes:
        podSpec:
          containers:
            - name: container-0
              image: golang:latest
              env:
                - name: GOCACHEPROG
                  value: "/tools/go-cacher -cache-server=http://gocached.default.svc.cluster.local:31364"
              volumeMounts:
                - name: tools
                  mountPath: /tools
                  readOnly: true
          volumes:
            - name: tools
              persistentVolumeClaim:
                claimName: tools-shared
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            runAsGroup: 1001

- label: "Go Test"
  command: go test ./...
  plugins:
    - kubernetes:
        podSpec:
          containers:
            - name: container-0
              image: golang:latest
              env:
                - name: GOCACHEPROG
                  value: "/tools/go-cacher -cache-server=http://gocached.default.svc.cluster.local:31364"
              volumeMounts:
                - name: tools
                  mountPath: /tools
                  readOnly: true
          volumes:
            - name: tools
              persistentVolumeClaim:
                claimName: tools-shared
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            runAsGroup: 1001

- label: "Go Vet"
  command: go vet
  plugins:
  - kubernetes:
        podSpec:
          containers:
            - name: container-0
              image: golang:latest
              env:
                - name: GOCACHEPROG
                  value: "/tools/go-cacher -cache-server=http://gocached.default.svc.cluster.local:31364"
              volumeMounts:
                - name: tools
                  mountPath: /tools
                  readOnly: true
          volumes:
            - name: tools
              persistentVolumeClaim:
                claimName: tools-shared
          securityContext:
            runAsNonRoot: true
            runAsUser: 1000
            runAsGroup: 1001
```

While other techniques can be used to shorten this example (such as YAML anchors/aliases or the controller `pod-spec-patch` configuration), they are less flexible than using `podTemplate`, and changes to the pod spec would require either updating the pipeline or the controller configuration.
