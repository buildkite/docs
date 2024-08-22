# Pipeline rules

Pipeline rules is a Buildkite feature used to manage and organize permissions between pipelines and other resources.

Rules express that an action is allowed between a source resource (e.g. a pipeline) and a target resource (e.g. another pipeline). Rules allow you to break out of the defaults provided by Buildkite such as cluster boundaries.

## Pipeline rules best practices

### How should I use rules?

Use rules to manage permissions between pipelines and other resources. Rules are typically used in tandem with [clusters](/docs/clusters/overview) to increase security and control, where clusters set hard boundaries and rules provide exceptions.

### Available rules

#### `pipeline.trigger_build.pipeline` 

Cross-cluster pipeline triggering (eg. allow a pipeline in one cluster to trigger a pipeline in another cluster).

Value fields:

- `triggering_pipeline_uuid` The UUID of the pipeline that is allowed to trigger another pipeline.
- `triggered_pipeline_uuid` The UUID of the pipeline that is allowed to be triggered by the `triggering_pipeline_uuid` pipeline.

### `pipeline.artifacts_read.pipeline` Allowing jobs in a pipeline to access artifacts from builds in other pipelines.

Value fields:

- `source_pipeline_uuid` The UUID of the pipeline that is allowed to access artifacts from another pipeline.
- `target_pipeline_uuid` The UUID of the pipeline that is allowed to have its artifacts accessed by jobs in the `source_pipeline_uuid` pipeline.

### Example rule use

Imagine you use two clusters to separate the environments necessary for building and deploying your application: a CI cluster and a CD cluster. Ordinarily, pipelines in these separate clusters are not able to trigger each other due to the isolation of clusters.

Creating a `pipeline.trigger_build.pipeline` rule would allow triggering a pipeline in the CD cluster from a pipeline in the CD cluster. This would allow maintaining the separation of the CI and CD agents and still support triggering the deployment pipeline from the build pipeline.

An example of a rule that allows a pipeline in the CI cluster to trigger a pipeline in the CD cluster:

```json
{
  "rule": "pipeline.trigger_build.pipeline",
  "value": {
    "triggering_pipeline_uuid": "{uuid-of-build-pipeline}",
    "triggered_pipeline_uuid": "{uuid-of-deploy-pipeline}"
  }
}
```

## Create a rule

Admins can create new rules on the **Rules** page in the **Organization settings**, as well as through the REST API's or GraphQL API's create-a-rule feature.

### Using the Buildkite interface

To create a new cluster using the Buildkite interface:

1. Select **Settings** in the global navigation to access the **Organization settings** page.
2. Select the **Rules** page in the Pipelines section.
3. Select **New rule**.
4. Under **Rule name**, select the type of rule you want to create, such as `pipeline.trigger_build.pipeline`.
5. Fill out the UUIDs of the pipelines you wish to create a target for. Access the UUIDs of your pipelines on their **Settings** page under the **GraphQL API integration** section.
6. Select **Submit**.

### Using the REST API

To [create a new rule](/docs/apis/rest-api/clusters#clusters-create-a-cluster) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/rules" \
  -H "Content-Type: application/json" \
  -d '{
    "rule": "pipeline.trigger_build.pipeline",
    "value": {
      "triggering_pipeline_uuid": "{uuid-of-build-pipeline}",
      "triggered_pipeline_uuid": "{uuid-of-deploy-pipeline}"
    }
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

## Using a GraphQL API

To [create a new rule](/docs/apis/graphql-api/rules#rules-create-a-rule) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

- organizationId: The organization GraphQL ID. You can find this in the URL of the organization settings page.

- name (required): The name of the rule you want to create. For example, `pipeline.trigger_build.pipeline`.

- value (required): The value of the rule you want to create. This must be a JSON encoded object with fields matching the format of the rule you are creating.


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

<!-- PR FOR CREATING GRAPHQL RULES https://github.com/buildkite/buildkite/pull/18259 -->

Rules can be filtered by sourceType, targetType, and action.

Example query

```
query RulesQuery {
  organization(slug: "compute-local") {
    name
    rules(first: 3, targetType: PIPELINE) {
      edges {
        node {
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
  }
}
```