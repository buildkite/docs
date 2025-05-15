# Setting up Datadog tracing on a Buildkite pipeline

[Datadog](https://www.datadoghq.com/) is a comprehensive monitoring and analytics platform that provides real-time visibility into your entire technology stack. It combines infrastructure monitoring, application performance monitoring (APM), and log management into a unified solution, allowing you to track the health and performance of your systems while identifying and troubleshooting issues across your entire deployment pipeline.

You can set up Datadog integration with Buildkite to gain actionable insights into your CI/CD processes, monitor build performance metrics, and ensure optimal resource utilization throughout your development workflow. 


> 
> If you are looking for the information on using Datadog APM tracing with Buildkite agent, you can find this information [here](https://www.datadoghq.com/product/apm/).

## Compatibility 

For the latest compatiblity information, please check the [Datadog documentation](Compatibility).

## Configuring the integration in Datadog

To set up the Datadog integration for Buildkite:

1. Go to Settings > Notification Services in Buildkite and click the Add button next to Datadog Pipeline Visibility.
1. Fill in the form with the following information:
- Description: A description to help identify the integration in the future, such as Datadog CI Visibility integration.
- API key: Your Datadog API Key.
- Datadog site: datadoghq.com
- Pipelines: Select all pipelines or the subset of pipelines you want to trace.
- Branch filtering: Leave empty to trace all branches or select the subset of branches you want to trace.
1. Click Add Datadog Pipeline Visibility Notification to save the integration.

## Advanced configuration

The following configurations provide additional customization options to enhance the integration between Buildkite and Datadog. These settings allow you to fine-tune how pipeline data is collected and reported, ensuring you get the most valuable insights from your CI/CD metrics.

Here is an example of how tags can be set and used in a yaml pipeline configuration:

```yaml
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


### Setting custom tags

Custom tags can be added to Buildkite traces by using the buildkite-agent meta-data set command. Any metadata tags with a key starting with dd_tags. are added to the job and pipeline spans. These tags can be used to create string facets to search and organize the pipelines.

### Correlating infrastructure metrics to jobs

With Buildkite agents, it's possible to correlate jobs with the infrastructure that is running them. For this feature to work, you will need to install the [Datadog Agent](https://docs.datadoghq.com/agent/) in the hosts that are running your Buildkite agents.

## Viewing pipelines in Datadog

You can use the following filters to customize your search query in the [Datadog CI Visibility Explorer](https://docs.datadoghq.com/continuous_integration/explorer).

## Visualizing pipeline data in Datadog

The CI Pipeline List and Executions pages populate with data after the pipelines finish.

The CI Pipeline List page shows data for only the default branch of each repository. For more information, see Search and Manage CI Pipelines.

## Additional resources


For the most recent version for Datadog, see https://docs.datadoghq.com/continuous_integration/pipelines/buildkite/

- Explore Pipeline Execution Results and Performance https://docs.datadoghq.com/continuous_integration/pipelines
- Troubleshooting CI Visibility https://docs.datadoghq.com/continuous_integration/troubleshooting/
- Extend Pipeline Visibility by adding custom tags and measures https://docs.datadoghq.com/continuous_integration/pipelines/custom_tags_and_measures/ 
