---
keywords: docs, tutorials, 2fa
---

# Enforce two-factor authentication (2FA)

Two-factor authentication can be enforced for the whole organization to ensure
that all users who access the organization have two-factor authentication enabled.

## Before enforcing two-factor authentication

Before you enforce two-factor authentication for your organization, consider
that users without 2FA enabled will immediately lose access to the organization
and subsequent pipelines.

Users can set up two-factor authentication by following this [tutorial].

## Steps to enforce two-factor authentication

To enforce two-factor authentication:

- You must be logged in as an Administrator
- Visit the Organization's [security settings]
- Check **Enforce two-factor authentication**
- Click **Update Access Control**

## Programmatically enforcing two-factor authentication

Please review the GraphQL [cookbook] for instructions on how to enable
enforced 2fa via the GraphQL API.

[cookbook]: </docs/apis/graphql/cookbooks/organizations#enforce-two-factor-authentication-2fa-for-your-organization>
[security settings]: <https://buildkite.com/organizations/~/security>
[tutorial]: </docs/tutorials/2fa>
