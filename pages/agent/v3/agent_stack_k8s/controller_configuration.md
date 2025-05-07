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

<table>
  <thead>
    <tr>
      <th style="width:25%">Flag and value type if applicable</th>
      <th style="width:75%">Description</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        flag: "--agent-token-secret",
        type: "string",
        description: "The name of the Buildkite agent token secret.",
        default_value: "buildkite-agent-token"
      },
      {
        flag: "--buildkite-token",
        type: "string",
        description: "The Buildkite API token with GraphQL scopes."
      },
      {
        flag: "--cluster-uuid",
        type: "string",
        description: "The UUID of the Buildkite cluster. The agent token must be for the Buildkite cluster."
      },
      {
        flag: "-f, --config",
        type: "string",
        description: "The config file path."
      },
      {
        flag: "--debug",
        description: "Debug logs."
      },
      {
        flag: "--default-image-check-pull-policy",
        type: "string",
        description: "Sets a default PullPolicy for image-check init containers, used if an image pull policy is not set for the corresponding container in a podSpec or podSpecPatch."
      },
      {
        flag: "--default-image-pull-policy",
        type: "string",
        description: "Configures a default image pull policy for containers that do not specify a pull policy and non-init containers created by the stack itself.",
        default_value: "IfNotPresent"
      },
      {
        flag: "--empty-job-grace-period",
        type: "duration",
        description: "The duration after starting a Kubernetes job that the controller will wait before considering failing the job due to a missing pod (for example, when the podSpec specifies a missing service account).",
        default_value: "30s"
      },
      {
        flag: "--graphql-endpoint",
        type: "string",
        description: "The Buildkite GraphQL endpoint URL."
      },
      {
        flag: "--graphql-results-limit",
        type: "integer",
        description: "Sets the amount of results returned by GraphQL queries when retrieving jobs to be scheduled.",
        default_value: "100"
      },
      {
        flag: "-h, --help",
        description: "Displays help for the agent-stack-k8s."
      },
      {
        flag: "--image",
        type: "string",
        description: "The image to use for the Buildkite agent.",
        default_value: "ghcr.io/buildkite/agent:3.91.0"
      },
      {
        flag: "--image-pull-backoff-grace-period",
        type: "duration",
        description: "Duration after starting a pod that the controller will wait before considering cancelling a job due to ImagePullBackOff (e.g., when the podSpec specifies container images that cannot be pulled).",
        default_value: "30s"
      },
      {
        flag: "--job-cancel-checker-poll-interval",
        type: "duration",
        description: "Controls the interval between job state queries while a pod is still Pending.",
        default_value: "5s"
      },
      {
        flag: "--job-creation-concurrency",
        type: "integer",
        description: "Controls the interval between job state queries while a pod is still Pending.",
        default_value: "5"
      },
      {
        flag: " --job-ttl",
        type: "duration",
        description: "The time to retain Kubernetes jobs after completion.",
        default_value: "10m0s"
      },
      {
        flag: "--job-active-deadline-seconds",
        type: "integer",
        description: "The maximum number of seconds a Kubernetes job is allowed to run before terminating all pods and failing.",
        default_value: "21600"
      },
      {
        flag: "--k8s-client-rate-limiter-burst",
        type: "integer",
        description: "The burst value of the K8s client rate limiter.",
        default_value: "20"
      },
      {
        flag: "--k8s-client-rate-limiter-qps",
        type: "integer",
        description: "The QPS value of the K8s client rate limiter.",
        default_value: "10"
      },
      {
        flag: "--max-in-flight",
        type: "integer",
        description: "The maximum jobs in flight, where a value of 0 means no maximum.",
        default_value: "25"
      },
      {
        flag: "--namespace",
        type: "string",
        description: "The Kubernetes namespace to create resources in.",
        default_value: "default"
      },
      {
        flag: "--org",
        type: "string",
        description: "The Buildkite organization name to watch."
      },
      {
        flag: "--pagination-depth-limit",
        type: "integer",
        description: "Sets the maximum depth of pagination when retrieving Buildkite jobs to be scheduled. Increasing this value will increase the number of requests made to the Buildkite GraphQL API and number of jobs to be scheduled on the Kubernetes cluster.",
        default_value: "1"
      },
      {
        flag: "--poll-interval",
        type: "duration",
        description: "The time to wait between polling for new jobs (minimum <code>1s</code>). Note that increasing this causes jobs to be slower to start.",
        default_value: "1s"
      },
      {
        flag: "--profiler-address",
        type: "string",
        description: "The bind address to expose the pprof profiler (for example, <code>localhost:6060</code>)."
      },
      {
        flag: "--prohibit-kubernetes-plugin",
        description: "Causes the controller to prohibit the Kubernetes plugin specified within jobs (pipeline YAML). Enabling this causes jobs with a Kubernetes plugin to fail, preventing the pipeline YAML from having any influence over the podSpec."
      },
      {
        flag: "--prometheus-port",
        type: "uint16",
        description: "The bind port to expose Prometheus /metrics. Specifying 0 disables this feature."
      },
      {
        flag: "--stale-job-data-timeout",
        type: "duration",
        description: "Duration after querying jobs in Buildkite that the data is considered valid",
        default_value: "10s"
      },
      {
        flag: "--tags",
        type: "strings",
        description: "A comma-separated list of agent tags. The \"queue\" tag must be unique (for example, \"queue=kubernetes,os=linux\")",
        default_value: "[queue=kubernetes]"
      },
      {
        flag: "--enable-queue-pause",
        type: "bool",
        description: "Allow the controller to pause processing the jobs when the queue is paused on Buildkite.",
        default_value: "false"
      }
    ].select { |field| field[:flag] }.each do |field| %>
      <tr>
        <td>
          <p><code><%= field[:flag] %></code></p>
          <% if field[:type] %>
            <strong>&nbsp;&nbsp;Type:</strong> <code><%= field[:type] %></code>
          <% end %>
         </td>
        <td>
          <p><%= field[:description] %></p>
          <% if field[:default_value] %>
            <strong>Default:</strong> <code><%= field[:default_value] %></code>
          <% end %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

Use `agent-stack-k8s [command] --help` for more information about a command.

> 📘 Queue pausing
> With release `v0.24.0` of `agent-stack-k8s`, it is now possible to enable `--enable-queue-pause` in the config, allowing the controller to pause processing the jobs when `queue` is paused in Buildkite.
