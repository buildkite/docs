# Controller configuration

This section covers the available commands for: 
- `agent-stack-k8s [flags]`
- `agent-stack-k8s [command]`

## Available commands

| Command     | Description                                                       |
|-------------|-------------------------------------------------------------------|
| `completion`| Generate the autocompletion script for the specified shell        |
| `help`      | Help about any command                                            |
| `lint`      | A tool for linting Buildkite pipelines                            |
| `version`   | Prints the version                                                |

## Flags

Options:
- Flag: --agent-token-secret string
  Description: name of the Buildkite agent token secret (default "buildkite-agent-token")
- Flag: --buildkite-token string
  Description: Buildkite API token with GraphQL scopes
- Flag: --cluster-uuid string
  Description: UUID of the Buildkite Cluster. The agent token must be for the Buildkite
    Cluster.
- Flag: -f, --config string
  Description: config file path
- Flag: --debug
  Description: debug logs
- Flag: --default-image-check-pull-policy string
  Description: Sets a default PullPolicy for image-check init containers, used if
    an image pull policy is not set for the corresponding container in a podSpec or
    podSpecPatch
- Flag: --default-image-pull-policy string
  Description: Configures a default image pull policy for containers that do not specify
    a pull policy and non-init containers created by the stack itself (default "IfNotPresent")
- Flag: --empty-job-grace-period duration
  Description: Duration after starting a Kubernetes job that the controller will wait
    before considering failing the job due to a missing pod (e.g., when the podSpec
    specifies a missing service account) (default 30s)
- Flag: --graphql-endpoint string
  Description: Buildkite GraphQL endpoint URL
- Flag: --graphql-results-limit int
  Description: Sets the amount of results returned by GraphQL queries when retrieving
    Jobs to be Scheduled (default 100)
- Flag: -h, --help
  Description: help for agent-stack-k8s
- Flag: --image string
  Description: The image to use for the Buildkite agent (default "ghcr.io/buildkite/agent:3.91.0")
- Flag: --image-pull-backoff-grace-period duration
  Description: Duration after starting a pod that the controller will wait before
    considering cancelling a job due to ImagePullBackOff (e.g., when the podSpec specifies
    container images that cannot be pulled) (default 30s)
- Flag: --job-cancel-checker-poll-interval duration
  Description: Controls the interval between job state queries while a pod is still
    Pending (default 5s)
- Flag: --job-creation-concurrency int
  Description: Number of concurrent goroutines to run for converting Buildkite jobs
    into Kubernetes jobs (default 5)
- Flag: --job-ttl duration
  Description: time to retain kubernetes jobs after completion (default 10m0s)
- Flag: --job-active-deadline-seconds int
  Description: maximum number of seconds a kubernetes job is allowed to run before
    terminating all pods and failing (default 21600)
- Flag: --k8s-client-rate-limiter-burst int
  Description: The burst value of the K8s client rate limiter. (default 20)
- Flag: --k8s-client-rate-limiter-qps int
  Description: The QPS value of the K8s client rate limiter. (default 10)
- Flag: --max-in-flight int
  Description: max jobs in flight, 0 means no max (default 25)
- Flag: --namespace string
  Description: kubernetes namespace to create resources in (default "default")
- Flag: --org string
  Description: Buildkite organization name to watch
- Flag: --pagination-depth-limit int
  Description: Sets the maximum depth of pagination when retrieving Buildkite Jobs
    to be Scheduled. Increasing this value will increase the number of requests made
    to the Buildkite GraphQL API and number of Jobs to be scheduled on the Kubernetes
    Cluster. (default 1)
- Flag: --poll-interval duration
  Description: time to wait between polling for new jobs (minimum 1s); note that increasing
    this causes jobs to be slower to start (default 1s)
- Flag: --profiler-address string
  Description: Bind address to expose the pprof profiler (e.g., localhost:6060)
- Flag: --prohibit-kubernetes-plugin
  Description: Causes the controller to prohibit the kubernetes plugin specified within
    jobs (pipeline YAML) - enabling this causes jobs with a kubernetes plugin to fail,
    preventing the pipeline YAML from having any influence over the podSpec
- Flag: --prometheus-port uint16
  Description: Bind port to expose Prometheus /metrics; 0 disables it
- Flag: --stale-job-data-timeout duration
  Description: Duration after querying jobs in Buildkite that the data is considered
    valid (default 10s)
- Flag: --tags strings
  Description: A comma-separated list of agent tags. The "queue" tag must be unique
    (e.g., "queue=kubernetes,os=linux") (default [queue=kubernetes])
- Flag: --enable-queue-pause bool
  Description: Allow the controller to pause processing the jobs when the queue is
    paused on Buildkite. (default false)
```

Use `agent-stack-k8s [command] --help` for more information about a command.


> 📘 Queue pausing
> With release `v0.24.0` of `agent-stack-k8s`, it is now possible to enable `--enable-queue-pause` in the config, allowing the controller to pause processing the jobs when `queue` is paused in Buildkite.