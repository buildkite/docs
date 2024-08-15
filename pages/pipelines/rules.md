# Pipeline rules

Pipeline rules is a Buildkite feature used to manage and organize permissions between pipelines and other resources.

## Understanding pipeline rules

Rules express that an action is allowed between two known resources, such as a pipeline. A source and a target are provided, and an action is inferred from the rule. Rules allow you to break out of the defaults.

Pipeline rules encapsulate permissions between resources, enabling the following:

- Rules allow one resource (source) to perform an action on another resource (target)
- Rules override default permissions, such as team-based access or build creator permissions
- Each rule defines a one-to-one relationship between resources
- Define rules using a specific format: `target_type.action.source_type`
- Only admins can create and access rules as part of the organization settings

## Pipeline rules best practices

### How should I use rules?

Use rules to manage explicit permissions between pipelines and other resources. Rules are typically used in tandem with [clusters](/docs/clusters/overview) to increase security and control, where clusters set hard boundaries and rules provide exceptions.

The most common patterns for rule configurations are based on your organization's needs:

- Cross-cluster pipeline triggering
- Allowing specific pipelines to access certain secrets (not yet available)
- Granting test suites access to pipeline artifacts (not yet available)

You can create as many rules as you require.

### Example rule use

Imagine you use two clusters to separate environments necessary for building your application and deploying your application. Ordinarily no pipelines in those clusters would be able to trigger each other due to the boundaries of clusters. Creating a rule would allow you to maintain separation of environments and still support separate pipelines for building, testing and deploying.

Therefore, an example rule would be:

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
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Open Source",
    "source": "A place for safely running our open source builds",
    "target": "\:technologist\:",
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

- other fields here

### Using the GraphQL API

<!-- PR FOR CREATING GRAPHQL RULES https://github.com/buildkite/buildkite/pull/18259 -->

Rules can be filtered by sourceType, targetType, and action.

Only users with `manage_organization_rules` permissions are allowed to list rules.

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
