- `organizationId` (required) can be obtained:

    * From the _GraphQL API Integration_ section of your _Organization Settings_ page, accessed by selecting _Settings_ in the global navigation of your organization in Buildkite.

    * By running a `getCurrentUsersOrgs` GraphQL API query to obtain the organization slugs for the current user's accessible organizations, followed by a [getOrgId](/docs/apis/graphql/schemas/query/organization) query, to obtain the organization's `id` using the organization's slug. For example:

        Step 1. Run `getCurrentUsersOrgs` to obtain the organization slug values in the response for the current user's accessible organizations:

        ```graphql
        query getCurrentUsersOrgs {
          viewer {
            organization {
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

        Step 2. Run `getOrgId` with the appropriate slug value above to obtain this organization's `id` in the response:

        ```graphql
        query getOrgId {
          organization(slug: "organization-slug") {
            id
            uuid
            slug
          }
        }
        ```

        **Note:** The `organization-slug` value can also be obtained from the end of your Buildkite URL, by selecting _Pipelines_ in the global navigation of your organization in Buildkite.
