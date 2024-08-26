# Manage rules

## Create a rule

Organization admins can create new rules using the [**Rules** page in **Organization settings**](#create-a-rule-using-the-buildkite-ui), as well as via the Buildkite [REST API](#create-a-rule-using-the-rest-api) and [GraphQL API](#create-a-rule-using-the-graphql-api).

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

<%= render_markdown partial: 'apis/descriptions/rest_pipeline_uuid' %>

## Using the GraphQL API

To [create a new rule](/docs/apis/graphql/schemas/mutation/rulecreate) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

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

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/rest_pipeline_uuid' %>

## Delete a rule

Organization admins can delete rules using the [**Rules** page in **Organization settings**](#delete-a-rule-using-the-buildkite-ui), as well as via the Buildkite [REST API](#delete-a-rule-using-the-rest-api) and [GraphQL API](#delete-a-rule-using-the-graphql-api).

### Using the Buildkite UI

To delete a rule using the Buildkite UI:

1. Select **Settings** in the global navigation to access the **Organization settings** page.
2. Select **Rules** in the Pipelines section.
3. Select the rule you wish to delete.
4. Select **Delete**

### Using the REST API

To [delete a rule](/docs/apis/rest-api/rules#rules-delete-a-rule) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/rules/{uuid}"
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

<%= render_markdown partial: 'apis/descriptions/rest_rule_uuid' %>

## Using the GraphQL API

To [delete a rule](/docs/apis/graphql/schemas/mutation/ruledelete) using the [GraphQL API](/docs/apis/graphql-api), run the following example mutation:

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

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

<%= render_markdown partial: 'apis/descriptions/graphql_rule_id' %>
