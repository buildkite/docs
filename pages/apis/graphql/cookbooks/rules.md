# Rules

A collection of common tasks with rules using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the **Docs** panel.

## List rules

Get the first 10 rules and their information for an organization:

```graphql
  query getRules {
    organization(slug: "organization-slug") {
      rules(first: 10) {
        edges {
          node {
            id
            name
            targetType
            sourceType
            source {
              ... on Pipeline
                slug
            }
            target {
              ... on Pipeline
                slug
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

## Create a rule

Create a rule:

```graphql
mutation {
  ruleCreate(input: {
    organizationId: "organization-id",
    name: "pipeline.trigger_build.pipeline",
    value: "{\"triggering_pipeline_uuid\":\"{uuid-of-source-pipeline}\",\"triggered_pipeline_uuid\":\"{uuid-of-target-pipeline}\"}"
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

## Delete a rule

Delete a rule:

```graphql
mutation {
  ruleDelete(input: {
    organizationId: "organization-id",
    id: "rule-id"
  }) {
    deletedRuleId
  }
}
```



