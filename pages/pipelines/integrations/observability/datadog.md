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
> For the latest compatibility information on Datadog's side regarding this integration, please check the [Datadog documentation](https://docs.datadoghq.com/continuous_integration/pipelines/buildkite/#compatibility).

## Advanced configuration

The following configurations provide additional customization options to enhance the integration between Buildkite and Datadog CI Visibility feature. These settings allow you to fine-tune how pipeline data is collected and reported, ensuring you get the most valuable insights from your CI/CD metrics.

### Setting custom tags

For creation of custom tags for filtering the Datadog results, you can use `buildkite-agent meta-data set` command. Here is an example of how tags can be set through a YAML pipeline configuration:

```yaml
steps:
- key: dd_key_test_01
  label: step_01
  command: buildkite-agent meta-data set "dd_tags.key" dd_key_test_01
...
```

After setting a tag as described above and running a build on a pipeline, you'll be able to filter the Datadog output results by using a tag.

[potential screenshot placeholder]

Any metadata with a key that starts with `dd-measures` and contains a numerical value will be set as a metric tag that can be used to create numerical measures. For example:

```yaml
...
 - key: "dd-measures-01"
    label: "step_02"
    command: "buildkite-agent meta-data set "dd_tags.key" dd-measures-01"
...
```

### Correlating infrastructure metrics to jobs

It is possible to correlate jobs with the infrastructure that is running them. For this feature to work, you will need to install the [Datadog Agent](https://docs.datadoghq.com/agent/) in the hosts that are running your Buildkite agents.

## Viewing pipelines in Datadog

You can use the following filters to customize your search query in the [Datadog CI Visibility Explorer](https://docs.datadoghq.com/continuous_integration/explorer).

## Visualizing pipeline data in Datadog

After the pipelines finish, in the Datadog interface, you can navigate to the [CI Pipeline List](https://app.datadoghq.com/ci/pipelines) and [Executions](https://app.datadoghq.com/ci/pipeline-executions) pages to see the Datadog populated with data. 

Note that the [CI Pipeline List](https://app.datadoghq.com/ci/pipelines) page in Datadog displays data for only the default branch of each repository. 

[screenshot placeholder]

## Additional resources

For the most recent version of Datadog documentation regarding the CI Visibility integration with Buildkite, see Datadog's documentation on [setting up tracing on a Buildkite Pipeline](https://docs.datadoghq.com/continuous_integration/pipelines/buildkite/).

For overall best CI/CD practices involving the use of Datadog's APM tracing and CI Visibility integration recommended by Buildkite, check out [this blog post](https://buildkite.com/resources/blog/ci-cd-best-practices/).
