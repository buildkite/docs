- `ruleId` (required) can be obtained:

    * From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite.

    * By running a [List rules](/docs/apis/graphql/cookbooks/rules#list-rules) GraphQL API query and obtaining this value from the `id` in the response associated with the rule type, source and target of the rule you wish to find (specified by the `type`, `source` and `target` values in the response). For example:

    ```graphql
    query getRules {
      organization(slug: "organization-slug") {
        rules(first: 10) {
          edges {
            node {
              id
              type
              source {
                ... on Pipeline
                  slug
              }
              target {
                ... on Pipeline
                  slug
              }
            }
          }
        }
      }
    }
    ```
