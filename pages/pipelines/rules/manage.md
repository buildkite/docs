# Manage rules

This page provides details on how to manage [rules](/docs/pipelines/rules) within your Buildkite organization.

## Create a rule

New rules can be created by [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) using the [**Rules** page](#create-a-rule-using-the-buildkite-interface), as well as Buildkite's [REST API](#create-a-rule-using-the-rest-api) or [GraphQL API](#create-a-rule-using-the-graphql-api).

### Using the Buildkite interface

To create a new rule using the Buildkite interface:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Pipelines** section, select **Rules** > **New Rule** to open its page.

1. For **Rule Type**, select the [type of rule](/docs/pipelines/rules#rule-types) to be created, that is, either **pipeline.trigger_build.pipeline** or **pipeline.artifacts_read.pipeline**.

1. Specify a short **Description** for the rule.

1. In the **Rule Document** field:
    * Specify the relevant values (either a pipeline UUID or a pipeline slug) for both the `source_pipeline` and `target_pipeline` pipelines, of your [**pipeline.trigger_build.pipeline**](/docs/pipelines/rules#rule-types-pipeline-dot-trigger-build-dot-pipeline) or [**pipeline.artifacts_read.pipeline**](/docs/pipelines/rules#rule-types-pipeline-dot-artifacts-read-dot-pipeline) rule. You can find the UUID values for these pipelines on the pipelines' respective **Settings** page under the **GraphQL API integration** section.
    * Specify any optional conditions that must be met for the source pipeline to [trigger](/docs/pipelines/rules#conditions-trigger) or [access artifacts built by](/docs/pipelines/rules#conditions-artifacts) its target pipeline.

1. Select **Create Rule**.

    The rule is created and presented on the **Rules** page, with a brief description of the rule type and the relationship between both pipelines.

### Using the REST API

To [create a new rule](/docs/apis/rest-api/rules#rules-create-a-rule) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/rules" \
  -H "Content-Type: application/json" \
  -d '{
    "rule": "pipeline.trigger_build.pipeline",
    "description": "A short description for your rule",
    "value": {
      "source_pipeline": "{pipeline-uuid-or-slug}",
      "target_pipeline": "{pipeline-uuid-or-slug}",
      "conditions": ["{condition-1}", "{condition-2}"]
    }
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

- `rule` is the [type of rule](/docs/pipelines/rules#rule-types) to be created, that is, either `pipeline.trigger_build.pipeline` or `pipeline.artifacts_read.pipeline`.

- `description` (optional) is a short description for the rule.

- `source_pipeline` and `target_pipeline` accept either a pipeline slug or UUID.

    Pipeline UUID values for `source_pipeline` and `target_pipeline` can be obtained:

      * From the **Pipeline Settings** page of the appropriate pipeline. To do this:
        1. Select **Pipelines** (in the global navigation) > the specific pipeline > **Settings**.
        1. Once on the **Pipeline Settings** page, copy the `UUID` value from the **GraphQL API Integration** section

      * By running the [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines) REST API query to obtain this value from `id` in the response from the specific pipeline. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \
          -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/pipelines"
        ```

- `conditions` (optional) is an array of conditions that must be met for the source pipeline to [trigger](/docs/pipelines/rules#conditions-trigger) or [access artifacts built by](/docs/pipelines/rules#conditions-artifacts) its target pipeline. Some example values could include:

    * `source.build.creator.teams includes 'core'`
    * `source.build.branch == 'main'`

### Using the GraphQL API

To [create a new rule](/docs/apis/graphql/cookbooks/rules#create-a-rule) using the [GraphQL API](/docs/apis/graphql-api), use the `ruleCreate` mutation based on the following example, where the contents of the `value` field must be a JSON-encoded string:

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

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

- `type` is the [type of rule](/docs/pipelines/rules#rule-types) to be created, that is, either `pipeline.trigger_build.pipeline` or `pipeline.artifacts_read.pipeline`.

- `description` (optional) is a short description for the rule.

- `source_pipeline` and `target_pipeline` accept either a pipeline slug or UUID.

    Pipeline UUID values for `source_pipeline` and `target_pipeline` can be obtained:

      * From the **Pipeline Settings** page of the appropriate pipeline. To do this:
        1. Select **Pipelines** (in the global navigation) > the specific pipeline > **Settings**.
        1. Once on the **Pipeline Settings** page, copy the `UUID` value from the **GraphQL API Integration** section

      * By running the `getCurrentUsersOrgs` GraphQL API query to obtain the organization slugs for the current user's accessible organizations, then [getOrgPipelines](/docs/apis/graphql/schemas/query/organization) query to obtain the pipeline's `uuid` in the response. For example:

        Step 1. Run `getCurrentUsersOrgs` to obtain the organization slug values in the response for the current user's accessible organizations:

        ```graphql
        query getCurrentUsersOrgs {
          viewer {
            organizations {
              edges {
                node {
                  name
                  slug
                }
              }
            }
          }
        }
        ```

        Step 2. Run `getOrgPipelines` with the appropriate slug value above to obtain this organization's `uuid` in the response:

        ```graphql
        query getOrgPipelines {
          organization(slug: "organization-slug") {
            pipelines(first: 100) {
              edges {
                node {
                  id
                  uuid
                  name
                }
              }
            }
          }
        }
        ```

- `conditions` (optional) is an array of conditions that must be met for the source pipeline to [trigger](/docs/pipelines/rules#conditions-trigger) or [access artifacts built by](/docs/pipelines/rules#conditions-artifacts) its target pipeline. Some example values could include:

    * `source.build.creator.teams includes 'core'`
    * `source.build.branch == 'main'`

## Edit a rule

Rules can be edited by [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) using the [**Rules** page](#edit-a-rule-using-the-buildkite-interface), as well as Buildkite's [GraphQL API](#edit-a-rule-using-the-graphql-api).

When editing a rule, you can modify its **Description** and **Rule Document** details, where the latter is contained within the `value` field of API requests, although a rule's type is fixed once it is [created](#create-a-rule) and its value cannot be modified.

### Using the Buildkite interface

To edit an existing rule using the Buildkite interface:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Pipelines** section, select **Rules** to access its page.

1. Expand the existing rule to be edited.

1. Select the **Edit** button to open the rule's **Edit Rule** page.

1. If required, modify the rule's short **Description**, or clear this field to remove this value.

1. In the **Rule Document** field:
    * Modify the relevant values (either a pipeline UUID or a pipeline slug) for both the `source_pipeline` and `target_pipeline` pipelines, of your [**pipeline.trigger_build.pipeline**](/docs/pipelines/rules#rule-types-pipeline-dot-trigger-build-dot-pipeline) or [**pipeline.artifacts_read.pipeline**](/docs/pipelines/rules#rule-types-pipeline-dot-artifacts-read-dot-pipeline) rule. You can find the UUID values for these pipelines on the pipelines' respective **Settings** page under the **GraphQL API integration** section.
    * Modify any optional `conditions` that must be met for the source pipeline to [trigger](/docs/pipelines/rules#conditions-trigger) or [access artifacts built by](/docs/pipelines/rules#conditions-artifacts) its target pipeline. To remove a condition, remove its specific value from the array, or to remove all conditions, remove the entire `conditions` array.

1. Select **Save Rule**.

    The rule is updated and you are returned to the **Rules** page. The rule's **Description** and other details can be accessed when the rule is expanded.

### Using the GraphQL API

To [edit an existing rule](/docs/apis/graphql/cookbooks/rules#edit-a-rule) using the [GraphQL API](/docs/apis/graphql-api), use the `ruleUpdate` mutation based on the following example, where the contents of the `value` field must be a JSON-encoded string:

```graphql
mutation {
  ruleUpdate(input: {
    organizationId: "organization-id",
    id: "rule-id",
    description: "A optional, new short description for your rule",
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

where:

<%= render_markdown partial: 'apis/descriptions/graphql_organization_id' %>

- `id` is the rule ID value of the existing rule to be edited. This value can be obtained:

    * From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite. Then, expand the existing rule and copy its **GraphQL ID** value.

    * By running a [List rules](/docs/apis/graphql/cookbooks/rules#list-rules) GraphQL API query to obtain the rule's `id` in the response. For example:

        ```graphql
        query getRules {
          organization(slug: "organization-slug") {
            rules(first: 10) {
              edges {
                node {
                  id
                  type
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

- `description` (optional) is a short description for the rule. Omitting this value will remove this value from the rule.

- `source_pipeline` and `target_pipeline` accept either a pipeline slug or UUID.

    Pipeline UUID values for `source_pipeline` and `target_pipeline` can be obtained:

      * From the **Pipeline Settings** page of the appropriate pipeline. To do this:
          1. Select **Pipelines** (in the global navigation) > the specific pipeline > **Settings**.
          1. Once on the **Pipeline Settings** page, copy the `UUID` value from the **GraphQL API Integration** section

      * By running the `getCurrentUsersOrgs` GraphQL API query to obtain the organization slugs for the current user's accessible organizations, then [getOrgPipelines](/docs/apis/graphql/schemas/query/organization) query to obtain the pipeline's `uuid` in the response. For example:

          Step 1. Run `getCurrentUsersOrgs` to obtain the organization slug values in the response for the current user's accessible organizations:

          ```graphql
          query getCurrentUsersOrgs {
            viewer {
              organizations {
                edges {
                  node {
                    name
                    slug
                  }
                }
              }
            }
          }
          ```

          Step 2. Run `getOrgPipelines` with the appropriate slug value above to obtain this organization's `uuid` in the response:

          ```graphql
          query getOrgPipelines {
            organization(slug: "organization-slug") {
              pipelines(first: 100) {
                edges {
                  node {
                    id
                    uuid
                    name
                  }
                }
              }
            }
          }
          ```

- `conditions` (optional) is an array of conditions that must be met for the source pipeline to [trigger](/docs/pipelines/rules#conditions-trigger) or [access artifacts built by](/docs/pipelines/rules#conditions-artifacts) its target pipeline. Some example values could include:

    * `source.build.creator.teams includes 'core'`
    * `source.build.branch == 'main'`

    **Note:** To remove a condition, remove its specific value from this array, or to remove all conditions, remove the entire `conditions` array.

## Delete a rule

Rules can be deleted by [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions) using the [**Rules** page](#delete-a-rule-using-the-buildkite-interface), as well as Buildkite's [REST API](#delete-a-rule-using-the-rest-api) or [GraphQL API](#delete-a-rule-using-the-graphql-api).

### Using the Buildkite interface

To delete an existing rule using the Buildkite interface:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Pipelines** section, select **Rules** to access its page.

1. Expand the existing rule to be deleted.

1. Select the **Delete** button to delete this rule.

    **Note:** Exercise caution at this point as this action happens immediately without any warning message appearing after selecting this button.

### Using the REST API

To [delete an existing rule](/docs/apis/rest-api/rules#rules-delete-a-rule) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/rules/{rule.uuid}"
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

- `{rule.uuid}` can be obtained:

    * From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite.

    * By running a [List rules](/docs/apis/rest-api/rules#rules-list-rules) REST API query to obtain the rule's `uuid` in the response. For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \
          -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/rules"
        ```

        **Important:** For the rule identified by its `uuid` in the response, ensure the pipeline UUIDs of the source (`source_uuid`) and target (`target_uuid`), as well as the rule type (`type`) match those of this rule to be deleted.

### Using the GraphQL API

To [delete an existing rule](/docs/apis/graphql/cookbooks/rules#delete-a-rule) using the [GraphQL API](/docs/apis/graphql-api), use the `ruleDelete` mutation, based on the following example:

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

- `id` is the rule ID value of the existing rule to be deleted. This value can be obtained:

    * From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite. Then, expand the existing rule and copy its **GraphQL ID** value.

    * By running a [List rules](/docs/apis/graphql/cookbooks/rules#list-rules) GraphQL API query to obtain the rule's `id` in the response. For example:

        ```graphql
        query getRules {
          organization(slug: "organization-slug") {
            rules(first: 10) {
              edges {
                node {
                  id
                  type
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

        **Important:** For the rule identified by its `uuid` in the response, ensure the pipeline UUIDs of the source (`source_uuid`) and target (`target_uuid`), as well as the rule type (`type`) match those of this rule to be deleted.
