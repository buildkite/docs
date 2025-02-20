# Rules

A collection of common tasks with rules using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the **Docs** panel.

## List rules

Get the first 10 rules and their information for an organization.

```graphql
query getRules {
  organization(slug: "organization-slug") {
    rules(first: 10) {
      edges {
        node {
          id
          type
          targetType
          sourceType
          source {
            ... on Pipeline {
              slug
            }
          }
          target {
            ... on Pipeline {
              slug
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

> 📘 Rule access for organization members
> Organization members are able to obtain rule data using the above `rules` query so long as both the source **and** target pipelines are associated to a [team](/docs/platform/team-management/permissions#manage-teams-and-permissions) (or seperate teams) that the member is a part of. Both source and target pipelines will need to have, at minumum, the **Read Only** permission as part of the teams that the member is associated with.


## Get a rule

Get the details of a specific rule by using its `id` via a `node` query. The `id` of a rule can can be obtained:

- From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite. Then, expand the existing rule and copy its **GraphQL ID** value.
- By running a [List rules GraphQL API query](/docs/apis/graphql/cookbooks/rules#list-rules) to obtain the rule's `id` in the response.

```graphql
query getRule {
  node(id: "rule-id") {
    id
    type
    targetType
    sourceType
    source {
      ... on Pipeline {
        slug
      }
    }
    target {
      ... on Pipeline {
        slug
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
```

> 📘 Rule access for organization members
> Organization members are able to obtain rule data using the above `node` query so long as both the source **and** target pipelines are associated to a [team](/docs/platform/team-management/permissions#manage-teams-and-permissions) (or seperate teams) that the member is a part of. Both source and target pipelines will need to have, at minumum, the **Read Only** permission as part of the teams that the member is associated with.

## Create a rule

Create a rule. The value of the `value` field must be a JSON-encoded string.

```graphql
mutation {
  ruleCreate(input: {
    organizationId: "organization-id",
    type: "pipeline.trigger_build.pipeline",
    description: "An short description for your rule",
    value: "{\"source_pipeline\":\"pipeline-uuid-or-slug\",\"target_pipeline\":\"pipeline-uuid-or-slug\",\"conditions\":[\"condition-1\",\"condition-2\"]}"
  }) {
    rule {
      id
      type
      description
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

## Edit a rule

Edit a rule. The value of the `value` field must be a JSON-encoded string.

```graphql
mutation {
  ruleUpdate(input: {
    organizationId: "organization-id",
    id: "rule-id",
    description: "An optional, new short description for your rule",
    value: "{\"source_pipeline\":\"pipeline-uuid-or-slug\",\"target_pipeline\":\"pipeline-uuid-or-slug\",\"conditions\":[\"condition-1\",\"condition-2\"]}"
  }) {
    rule {
      id
      type
      description
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
