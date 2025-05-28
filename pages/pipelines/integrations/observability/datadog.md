# Setting up Datadog tracing on a Buildkite pipeline

[Datadog](https://www.datadoghq.com/) is a comprehensive monitoring and analytics platform that provides real-time visibility into your entire technology stack. It combines infrastructure monitoring, application performance monitoring (APM), and log management into a unified solution, allowing you to track the health and performance of your systems while identifying and troubleshooting issues across your entire deployment pipeline.

Datadog users can send the information about their Buildkite pipelines to Datadog’s Continuous Integration Visibility (Datadog CI Visibility). This way, any organization using both Datadog and Buildkite can enable get insights into their pipeline’s performance over time.

You can set up Datadog integration with Buildkite to gain actionable insights into your CI/CD processes, monitor build performance metrics, and ensure optimal resource utilization throughout your development workflow. 

> 📘
> If you are looking for the information on using Datadog APM tracing with Buildkite agent, you can find it [here](https://www.datadoghq.com/product/apm/). 

## Configuring the integration in Datadog

To set up the Datadog integration for Buildkite:

1. In your Buildkite organization, go to *Settings* > *Notification Services* and click the *Add* button next to Datadog Pipeline Visibility icon.
1. Fill in the following information:
- Description: A description to help identify this integration in the future, for example "Datadog CI Visibility".
- API key: Your Datadog API Key. You can generate it in [your Datadog account settings](https://app.datadoghq.com/account/settings#api).
- The Datadog site to send notifications to: `datadoghq.com`.
- Datadog tags: your custom tags in Datadog. You can use one tag per line in `key:value` format.
- Pipelines: you can select the subset of pipelines you want to trace in Datadog. Select All Pipelines, Only Some pipelines, Pipelines in Teams, or Pipelines in Clusters.
- Branch filtering: select the branches which will trigger a notification. You can leave this field empty to trace all branches or select the subset of branches you would like to trace.
1. Click *Add Datadog Pipeline Visibility Notification* button to save the integration.

[screenshot placeholder]

> 📘
> For the latest compatiblity information on Datadog's side regarding this integration, please check the [Datadog documentation](https://docs.datadoghq.com/continuous_integration/pipelines/buildkite/#compatibility).

## Advanced configuration

The following configurations provide additional customization options to enhance the integration between Buildkite and Datadog CI Visibility feature. These settings allow you to fine-tune how pipeline data is collected and reported, ensuring you get the most valuable insights from your CI/CD metrics.

### Setting custom tags

Here is an example of how tags can be set and used in a yaml pipeline configuration:

```yaml #TODO - replace with our own example
steps:
  - command: buildkite-agent meta-data set "dd_tags.team" "backend"
  - command: go version | buildkite-agent meta-data set "dd_tags.go.version"
    label: Go version
  - commands: go test ./...
    label: Run tests
```

The following tags are shown in the root span as well as the relevant job span in Datadog:

- `team: backend`
- `go.version: go version go1.17 darwin/amd64` (output depends on the runner)

[potential screenshot placeholder]

Any metadata with a key starting with `dd-measures`. and containing a numerical value will be set as a metric tag that can be used to create numerical measures. 
For creation of these tags, you can use `buildkite-agent meta-data set` command.

For example, you can measure the [different example command] in a pipeline with this command:

```
steps:
  - commands:
```

The resulting pipeline will have the tags shown below in the pipeline span:
[example output]


### Correlating infrastructure metrics to jobs

It is possible to correlate jobs with the infrastructure that is running them. For this feature to work, you will need to install the [Datadog Agent](https://docs.datadoghq.com/agent/) in the hosts that are running your Buildkite agents.

## Viewing pipelines in Datadog

You can use the following filters to customize your search query in the [Datadog CI Visibility Explorer](https://docs.datadoghq.com/continuous_integration/explorer).

## Visualizing pipeline data in Datadog

The CI Pipeline List and Executions pages in Datadog populate with data after the pipelines finish.

[screenshot placeholder]

The CI Pipeline List page shows data for only the default branch of each repository. For more information, see Search and Manage CI Pipelines.

[screenshot placeholder]

## Additional resources

For the most recent version of Datadog documentation regarding the CI Visibility integration with Buildkite, see Datadog's documentation on [setting up tracing on a Buildkite Pipeline](https://docs.datadoghq.com/continuous_integration/pipelines/buildkite/).

For overall best CI/CD practices involving the use of Datadog's APM tracing and CI Visibility integration recommended by Buildkite, check out [this blog post](https://buildkite.com/resources/blog/ci-cd-best-practices/).
