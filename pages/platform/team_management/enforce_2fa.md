---
keywords: docs, tutorials, 2fa
---

# Enforce two-factor authentication (2FA)

Two-factor authentication can be enforced for the whole organization to ensure that all users who access the organization have two-factor authentication enabled.

## Before enforcing two-factor authentication

Before you enforce two-factor authentication (2FA) for your organization, consider that users without 2FA enabled will immediately lose access to the organization and the subsequent pipelines in that organization.

Users can set up 2FA by following the [2FA tutorial].

## Steps to enforce two-factor authentication

To enforce 2FA:

1. Ensure you are logged in as a [Buildkite organization administrator](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).
1. Access your Buildkite organization's **Settings** (in the global navigation) > [**Security** page](https://buildkite.com/organizations/~/security).
1. Select the **Enforce Two-factor authentication** checkbox.
1. Select **Update Access Control**.

## Programmatically enforcing two-factor authentication

Please review the GraphQL [cookbook] for instructions on how to enable
enforced 2FA via the GraphQL API.

[cookbook]: </docs/apis/graphql/cookbooks/organizations#enforce-two-factor-authentication-2fa-for-your-organization>
[2FA tutorial]: </docs/platform/tutorials/2fa>

## API access tokens

Enforcing 2FA does not invalidate existing [API access tokens][access-tokens]. Existing tokens will
continue to work, but users must enable 2FA before they can update existing tokens or create new ones.

[access-tokens]: </docs/apis/managing-api-tokens>
