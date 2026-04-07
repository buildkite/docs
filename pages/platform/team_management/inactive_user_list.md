# Inactive user list

Buildkite organization administrators can audit inactive users within their organization using the inactive user list. An _inactive user_ is an organization member who has not interacted with Buildkite within a selected time period. This helps administrators identify and remove users who no longer need access.

The inactive user list is available to Buildkite organizations on the [Enterprise plan](https://buildkite.com/pricing), as it requires the [Audit Logging](/docs/platform/audit-log) feature.

## View inactive users

To view inactive users in your organization:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the sidebar, select **Audit** > **Inactive User List** to access your organization's inactive user list.

1. Select a time period to filter the list. Available periods are **30 days**, **90 days** (the default), and **120 days**. For example, selecting **30 days** shows organization members who have not been active in the last 30 days.

Each entry displays the member's name, email address, and the date they were last active.

> 📘 Last seen data
> The inactive user list relies on each member's _last seen_ timestamp. Members who have never logged in appear in the list with a placeholder date of **30 July 2020**, indicating that no activity has been recorded for that user.

## Export inactive users to CSV

You can export the current filtered list of inactive users to a CSV file by selecting the **Export to CSV** button at the top of the page.

## Remove inactive users

After identifying inactive users, you can remove them from your organization to maintain a clean membership list. Removing a user from the organization does not delete their user account, and builds created by the user will not be deleted.

To remove inactive users:

1. From the **Inactive User List** page, select the checkbox next to each user you want to remove. You can select multiple users.

1. Select **Remove selected users**.

1. Confirm the removal when prompted.

You can also remove users programmatically using the [GraphQL API](/docs/apis/graphql/cookbooks/organizations#delete-an-organization-member).

## Query inactive users with the GraphQL API

You can query inactive organization members programmatically using the [GraphQL API](/docs/apis/graphql-api). Use the `inactiveSince` argument on the `members` field to filter for members who have not been active since a specific date.

```graphql
query getInactiveOrgMembers {
  organization(slug: "organization-slug") {
    members(first: 100, inactiveSince: "2025-01-01T00:00:00Z") {
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

The `inactiveSince` value is an ISO 8601 encoded UTC date string. The query returns all members whose `lastSeenAt` is either `null` (never seen) or before the specified date, along with the total `count` of matching members.

For more GraphQL recipes related to organization member management, see the [Organizations cookbook](/docs/apis/graphql/cookbooks/organizations).
