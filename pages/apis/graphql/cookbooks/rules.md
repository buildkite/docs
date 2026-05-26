# Rules

A collection of common tasks with rules using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

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
> Organization members are able to obtain rule data using the above `rules` query above, as long as the user has at least **Read Only** access to both the source _and_ target pipelines. Learn more about this in [Pipeline-level permissions](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions).
> A user typically gains **Read Only** permission to access pipelines if the user is associated with one or more [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions) that the source and target pipelines (with at least the **Read Only** permission) are also associated with.
> Learn more about associating pipelines with teams in [Team-level permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

## Filter rules by pipeline

The `rules` query supports filtering by source or target pipeline using the pipeline's GraphQL ID (`sourceId` and `targetId` arguments). These filters are composable — you can combine them with each other and with the `sourceType`, `targetType`, and `action` filters to narrow results further.

To obtain a pipeline's GraphQL ID, run a pipelines query and use the `id` field from the response.

### Filter by target pipeline

Get all rules where a specific pipeline is the target:

```graphql
query getRulesByTarget($slug: ID!, $targetId: ID!) {
  organization(slug: $slug) {
    rules(first: 10, targetId: $targetId) {
      edges {
        node {
          id
          type
          action
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
        }
      }
    }
  }
}
```

### Filter by source pipeline

Get all rules where a specific pipeline is the source:

```graphql
query getRulesBySource($slug: ID!, $sourceId: ID!) {
  organization(slug: $slug) {
    rules(first: 10, sourceId: $sourceId) {
      edges {
        node {
          id
          type
          action
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
        }
      }
    }
  }
}
```

### Combine multiple filters

Filters are additive. Each additional argument narrows the result set. For example, get all `TRIGGER_BUILD` rules targeting a specific pipeline:

```graphql
query getRulesByTargetAndAction($slug: ID!, $targetId: ID!) {
  organization(slug: $slug) {
    rules(first: 10, targetId: $targetId, action: TRIGGER_BUILD) {
      edges {
        node {
          id
          action
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
        }
      }
    }
  }
}
```

## Get a rule

Get the details of a specific rule by using its `id` using a `node` query. The `id` of a rule can can be obtained:

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
> Organization members are able to obtain rule data using the above `node` query above, as long as the user has at least **Read Only** access to both the source _and_ target pipelines. Learn more about this in [Pipeline-level permissions](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions).
> A user typically gains **Read Only** permission to access pipelines if the user is associated with one or more [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions) that the source and target pipelines (with at least the **Read Only** permission) are also associated with.
> Learn more about associating pipelines with teams in [Team-level permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

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
