# Rules overview

Rules allow you to customize permissions between Buildkite resources.

Rules express that an action (e.g. triggering a build) is allowed between a source resource (e.g. a pipeline) and a target resource (e.g. another pipeline).

Rules are used to grant or restrict access between resources that would normally be determined by the default permissions.

## Available rule types

### `pipeline.trigger_build.pipeline`

Allows one pipeline to trigger another. This is useful where you want to allow a pipeline to trigger a build in another cluster, or if you want to allow a public pipeline to trigger a private one.

Note that this rule type overrides the usual [trigger step permissions checks](docs/pipelines/trigger-step#permissions) on users and teams.

Rule document:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "source_pipeline_uuid": "{triggering-pipeline-uuid}",
    "target_pipeline_uuid": "{triggered-pipeline-uuid}"
  }
}
```

Value fields:

- `source_pipeline_uuid` The UUID of the pipeline that is allowed to trigger another pipeline.
- `target_pipeline_uuid` The UUID of the pipeline that is allowed to be triggered by the `source_pipeline_uuid` pipeline.

#### Example use case: cross-cluster pipeline triggering

Clusters may be used to separate the environments necessary for building and deploying an application. For example, a CI pipeline in cluster A and a CD pipeline cluster B. Ordinarily, pipelines in separate clusters like this are not able to trigger builds for each other due to the strict isolation of clusters.

A `pipeline.trigger_build.pipeline` rule would allow a trigger step in the CI pipeline in cluster A to target the CD pipeline in cluster B. This would allow deploys to be triggered upon a successful CI build, while still maintaining the separation of the CI and CD agents in their respective clusters.

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

#### Example use case: sharing assets between clusters

By default, artifacts cannot be accessed by pipelines in separate clusters. For example, a deploy pipeline in cluster B cannot ordinarily access artifacts uploaded by a CI pipeline in cluster A. A `pipeline.artifacts_read.pipeline` rule can be used to override this. For example, frontend assets uploaded as artifacts by the CI pipeline would now be accessible to the deploy pipeline via the `buildkite-agent artifact download --build xxx` command.
