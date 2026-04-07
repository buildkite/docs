# Inactive user list

Buildkite organization administrators can audit inactive users within their organization using the inactive user list. An _inactive user_ is an organization member who has not interacted with Buildkite within a selected time period. This helps administrators identify and remove users who no longer need access.

The inactive user list is available to all Buildkite organizations on any [plan](https://buildkite.com/pricing).

## View inactive users

To view inactive users in your organization:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Audit** > **User Activity Audit** to access your organization's [**User Activity Audit**](https://buildkite.com/organizations/~/user-activity-audit) page.

1. Select a time period to filter the list. For example, selecting **30 days** shows organization members who have not been active in the last 30 days.

Each entry displays the member's name, email address, and the date they were last seen.

> 📘 Last seen data
> The inactive user list relies on each member's _last seen_ timestamp. Members who have never logged in may appear in the list with no last seen date.

## Remove inactive users

After identifying inactive users, you can remove them from your organization to maintain a clean membership list. Removing a user from the organization does not delete their Buildkite user account.

To remove an inactive user:

1. From the **User Activity Audit** page, select the user you want to remove.

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
