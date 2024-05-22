# Access control for users and teams

Customers on the Buildkite [Pro and Enterprise](https://buildkite.com/pricing) plans can manage permissions using [**Teams**](#manage-teams-and-permissions). Enterprise customers can set fine-grained user permissions for their organization with the [Member Permissions](#member-permissions) page.

## Manage teams and permissions

To manage teams across the Buildkite Packages application, a _Buildkite organization administrator_ first needs to enable this feature across their organization. Learn more about how to do this in the [Manage teams and permissions section of Pipelines documentation](/docs/team-management/permissions#manage-teams-and-permissions).

Once the **Teams** feature is enabled, you can see the teams that you're a member of from the **User** page, which:

- As a Buildkite organization administrator, you can access by selecting **Settings** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

- As any other user, you can access by selecting **Teams** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

In the [Team section](https://buildkite.com/organizations/~/teams), you can add new teams or edit existing ones.

By clicking on a team, you can view the member-, pipeline-, test suite-, package registry- and team-specific settings.

### Organization-level permissions

Learn more about what a _Buildkite organization administrator_ can do in the [Organization-level permissions section of the Pipelines documentation](/docs/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).

### Team-level permissions

Learn more about what _team members_ are and what _team maintainers_ can do in the [Team-level permissions section of the Pipelines documentation](/docs/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

### Package registry-level permissions

When the [teams feature is enabled](#manage-teams-and-permissions), any user can create a new package registry, as long as this user is a member of at least one team within the Buildkite organization.

When you create a new test suite in Buildkite:

- You are automatically granted the **Full Access** permission to this test suite.
- Any members of teams you provide access to this test suite are also granted the **Full Access** permission.

**Full Access** on a test suite allows you to:

- View test runs.
- Edit test suite settings, which includes the ability to delete the test suite.
- Provide access to other users, by adding the test suite to other teams that you are a [team maintainer](#manage-teams-and-permissions-team-level-permissions) on.

Any user with **Full Access** permissions to a test suite can change its permissions to **Read Only**, which allows you to view test runs only, but _not_ edit the test suite's settings.

A user who is a member of at least one team with **Full Access** permissions to a test suite can change the permissions on this test suite. However, once this user loses this **Full Access** through their last team with access to this test suite, the user then loses the ability to change the test suite's permissions.

Another user with **Full Access** to this test suite or a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions) is required to change the test suite's permissions back to **Full Access** again.

## Member permissions

Enterprise customers can control user permissions for selected suite actions. These permissions can be used both with or without Teams enabled.

User-level permissions are managed by organization administrators, and can be found in the Organization Settings under Member Permissions.

From the Member Permissions page, organization admins can toggle whether or not users can:

- Create suites
- Delete suites

If your organization has teams enabled, the suite creation permissions are managed at a team level. Suite creation permission controls can be found on the Teams Settings page. Without teams enabled, the suite creation permission control can be found on the Member Permissions page.
