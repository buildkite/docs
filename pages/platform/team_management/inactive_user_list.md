# Inactive user list

Buildkite organization administrators can identify inactive users within their organization. An _inactive user_ is an organization member who has not interacted with Buildkite since a specified date. This helps administrators audit their organization's membership and remove users who no longer need access.

The inactive user list is available to all Buildkite organizations on any plan.

## View inactive users

To view inactive users in your organization:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Users** to access your organization's [**Users**](https://buildkite.com/organizations/~/users) page.

1. Use the **Inactive since** filter to specify a date. The list updates to show only organization members who have not been active since that date.

Each user entry displays their name, email address, and the date they were last seen.

## Remove inactive users

After identifying inactive users, you can remove them from your organization to maintain a clean membership list. Removing a user from the organization does not delete their Buildkite user account.

To remove an inactive user:

1. From the **Users** page, select the user you want to remove.

1. Select **Remove** to remove the user from your organization.

You can also remove users programmatically using the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#delete-an-organization-member).

## Query inactive users with the GraphQL API

You can query inactive organization members programmatically using the [GraphQL API](/docs/apis/graphql-api). Use the `inactiveSince` argument on the `members` field to filter for members who have not been active since a specific date.

```graphql
query getInactiveOrgMembers {
  organization(slug: "organization-slug") {
    members(first: 100, inactiveSince: "2025-01-01") {
      count
      edges {
        node {
          id
          lastSeenAt
          user {
            name
            email
          }
        }
      }
    }
  }
}
```

The `inactiveSince` value is a date in `YYYY-MM-DD` format. The query returns all members whose `lastSeenAt` date is before the specified date, along with the total `count` of matching members.

For more GraphQL recipes related to organization member management, see the [Organizations cookbook](/docs/apis/graphql/cookbooks/organizations).
