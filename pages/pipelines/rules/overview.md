# Rules overview

Rules allow you to manage permissions between Buildkite resources.

Rules express that an action is allowed between a source resource (e.g. a pipeline) and a target resource (e.g. another pipeline).

Rules are typically used in tandem with [clusters](/docs/clusters/overview) to increase security and control, where clusters set hard boundaries and rules provide exceptions.

## Available rule types

### `pipeline.trigger_build.pipeline`

Allows a pipeline in one cluster to trigger a pipeline in another cluster.

Rule document:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "triggering_pipeline_uuid": "{triggering-pipeline-uuid}",
    "triggered_pipeline_uuid": "{triggered-pipeline-uuid}"
  }
}
```

Value fields:

- `triggering_pipeline_uuid` The UUID of the pipeline that is allowed to trigger another pipeline.
- `triggered_pipeline_uuid` The UUID of the pipeline that is allowed to be triggered by the `triggering_pipeline_uuid` pipeline.

#### Example use case

Imagine you use two clusters to separate the environments necessary for building and deploying your application: a CI cluster and a CD cluster. Ordinarily, pipelines in these separate clusters are not able to trigger each other due to the isolation of clusters.

A `pipeline.trigger_build.pipeline` rule would allow a pipeline in the CI cluster to trigger a build for a pipeline in the CD cluster, while maintaining the separation of the CI and CD agents in their respective clusters.

### `pipeline.artifacts_read.pipeline`

Allows a source pipeline in one cluster to read artifacts from a target pipeline in another cluster.

Rule document:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "source_pipeline_uuid": "{uuid-of-source-pipeline}",
    "target_pipeline_uuid": "{uuid-of-target-pipeline}"
  }
}
```

Value fields:

- `source_pipeline_uuid` The UUID of the pipeline that is allowed to read artifacts from another pipeline.
- `target_pipeline_uuid` The UUID of the pipeline that is allowed to have its artifacts read by jobs in the `source_pipeline_uuid` pipeline.
