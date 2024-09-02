# Rules overview

Rules allow you to customize permissions between Buildkite resources.

Rules express that an action (for example, triggering a build) is allowed between a source resource (for example, a pipeline) and a target resource (for example, another pipeline).

Rules are used to grant or restrict access between resources that would normally be determined by the default permissions.

## Rule types

### pipeline.trigger_build.pipeline

This rule type:

- Allows one pipeline to trigger another.
- Is useful where you want to allow a pipeline to trigger a build in another cluster, or if you want to allow a public pipeline to trigger a private one.

**Note:** This rule type overrides the usual [trigger step permissions checks](/docs/pipelines/trigger-step#permissions) on users and teams.

Rule format:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "source_pipeline_uuid": "{triggering-pipeline-uuid}",
    "target_pipeline_uuid": "{triggered-pipeline-uuid}"
  }
}
```

where:

- `source_pipeline_uuid` is the UUID of the pipeline that's allowed to trigger another pipeline.
- `target_pipeline_uuid` is the UUID of the pipeline that can be triggered by the `source_pipeline_uuid` pipeline.

Learn more about how to create rules in [Manage rules](/docs/pipelines/rules/manage).

#### Example use case: cross-cluster pipeline triggering

Clusters may be used to separate the environments necessary for building and deploying an application. For example, a continuous integration (CI) pipeline has been set up in cluster A and likewise, a continuous deployment (CD) pipeline in cluster B. Ordinarily, pipelines in separate clusters are not able to trigger builds between each other due to the strict isolation of clusters.

However, a `pipeline.trigger_build.pipeline` rule would allow a trigger step in the CI pipeline of cluster A to target the CD pipeline in cluster B. Such rules would allow deployment to be triggered upon a successful CI build, while still maintaining the separation between the CI and CD agents in their respective clusters.

### pipeline.artifacts_read.pipeline

This rule type allows a source pipeline in one cluster to read artifacts from a target pipeline in another cluster.

Rule format:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "source_pipeline_uuid": "{uuid-of-source-pipeline}",
    "target_pipeline_uuid": "{uuid-of-target-pipeline}"
  }
}
```

where:

- `source_pipeline_uuid` is the UUID of the pipeline that's allowed to read artifacts from another pipeline.
- `target_pipeline_uuid` is the UUID of the pipeline whose artifacts can be read by jobs in the `source_pipeline_uuid` pipeline.

#### Example use case: sharing assets between clusters

Artifacts are not accessible between pipelines across different clusters. For example, a deployment pipeline in cluster B cannot ordinarily access artifacts uploaded by a CI pipeline in cluster A.

However, a `pipeline.artifacts_read.pipeline` rule can be used to override this restriction. For example, frontend assets uploaded as artifacts by the CI pipeline would now be accessible to the deployment pipeline via the `buildkite-agent artifact download --build xxx` command.
