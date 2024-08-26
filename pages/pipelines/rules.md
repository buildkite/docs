# Rules

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


## Create a rule

Organization admins can create new rules on the **Rules** page in **Organization settings**, as well as via the Buildkite REST API and GraphQL API.

### Using the Buildkite UI

To create a new rule using the Buildkite UI:

1. Select **Settings** in the global navigation to access the **Organization settings** page.
2. Select **Rules** in the Pipelines section.
3. Select **New Rule**.
4. Under **Rule Name**, select the type of rule you want to create, such as `pipeline.trigger_build.pipeline`.
5. Under **Rule Document**, populate the relevant data. For example, if you're creating a `pipeline.trigger_build.pipeline` rule, you'll need to provide a `triggering_pipeline_uuid` and a `triggered_pipeline_uuid`. You can find the UUIDs of your pipelines on their **Settings** page under the **GraphQL API integration** section.
6. Select **Submit**.

### Using the REST API

To [create a new rule](/docs/apis/rest-api/rules#rules-create-a-rule) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/rules" \
  -H "Content-Type: application/json" \
  -d '{
    "rule": "pipeline.trigger_build.pipeline",
    "value": {
      "triggering_pipeline_uuid": "{uuid-of-triggering-pipeline}",
      "triggered_pipeline_uuid": "{uuid-of-triggered-pipeline}"
    }
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

## Using the GraphQL API

To [create a new rule](/docs/apis/graphql-api/rules#rules-create-a-rule) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

```graphql
mutation {
  ruleCreate(input: {
    organizationId: "organization-id",
    name: "pipeline.trigger_build.pipeline",
    value: "{\"triggering_pipeline_uuid\":\"{uuid-of-build-pipeline}\",\"triggered_pipeline_uuid\":\"{uuid-of-deploy-pipeline}\"}"
  }) {
     rule {
      id
      name
      targetType
      sourceType
      source {
          ... on Pipeline {
            uuid
          }
        }
      target {
        ... on Pipeline {
          uuid
        }
      }
      effect
      action
      createdBy {
        id
        name
      }
    }
  }
}
```

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>
