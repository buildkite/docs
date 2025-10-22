# User, team, and test suite permissions

Customers on the Buildkite [Pro and Enterprise](https://buildkite.com/pricing) plans can manage test suite permissions using the [_teams_ feature](#manage-teams-and-permissions). This feature allows you to apply access permissions and functionality controls for one or more groups of users (that is, _teams_) on each test suite throughout your organization.

Enterprise plan customers can configure test suite permissions and security features for all users across their Buildkite organization through the **Security** page. Learn more about this feature in [Manage organization security for test suites](#manage-organization-security-for-test-suites).

## Manage teams and permissions

To manage teams across the Buildkite Test Engine application, a _Buildkite organization administrator_ first needs to enable this feature across their organization. Learn more about how to do this in the [Manage teams and permissions section of Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions).

Once the _teams_ feature is enabled, you can see the teams that you're a member of from the **User** page, which:

- As a Buildkite organization administrator, you can access by selecting **Settings** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

    <%= image "user-section-teams-list.png", alt: "Screenshot of the User section, showing a list of Teams an User is a member of" %>

- As any other user, you can access by selecting **Teams** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

### Organization-level permissions

Learn more about what a _Buildkite organization administrator_ can do in the [Organization-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).

As an organization administrator, you can access the [**Organization Settings** page](https://buildkite.com/organizations/~/settings) by selecting **Settings** in the global navigation, where you can do the following:

- Add new teams or edit existing ones in the [**Team** section](https://buildkite.com/organizations/~/teams).

    <%= image "team-section-list.png", alt: "Screenshot of the Team section, showing a list of Teams" %>

- After selecting a team, you can view and administer the member-, [pipeline-](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions), [test suite-](#manage-teams-and-permissions-test-suite-level-permissions), [registry-](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions) and [team-](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions)level settings for that team.

    <%= image "team-section-test-suites-list.png", alt: "Screenshot of the Team section, showing a list of Test Suites the team has access to" %>

    **Note:** Registry-level settings are only available once [Buildkite Package Registries has been enabled](/docs/package-registries/security/permissions#enabling-buildkite-packages).

### Team-level permissions

Learn more about what _team members_ are and what _team maintainers_ can do in the [Team-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

### Test suite-level permissions

When the [teams feature is enabled](#manage-teams-and-permissions), any user can create a new test suite, as long as this user is a member of at least one team within the Buildkite organization, and this team has the **Create test suites** [team member permission](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

When you create a new test suite in Buildkite:

- You are automatically granted the **Full Access** permission to this test suite.
- Any members of teams to which you provide access to this test suite are also granted the **Full Access** permission.

**Full Access** on a test suite allows you to:

- View test data.
- Edit test suite's settings.
- Delete the test suite.
- Provide access to other users, by adding the test suite to other teams that you are a [team maintainer](#manage-teams-and-permissions-team-level-permissions) on.
- Configure test splitting.
- Create and edit workflows.

Any user with **Full Access** permission to a test suite can change its permission to **Read Only**, which allows you to view test runs only, but _not_:

- Edit the test suite's settings.
- Delete the test suite.
- Create and edit workflows.
- Provide access to other users.

A user who is a member of at least one team with **Full Access** permission to a test suite can change the permissions on this test suite. However, once this user loses this **Full Access** through their last team with this permission on this test suite, the user then loses the ability to change the test suite's permission in any team they are a member of.

Another user with **Full Access** to this test suite or a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions) is required to change the test suite's permission back to **Full Access** again.

## Manage organization security for test suites

Enterprise plan customers can configure test suite action permissions for all users across their Buildkite organization. These features can be used either with or without the [teams feature enabled](#manage-teams-and-permissions).

These user-level permissions and security features are managed by _Buildkite organization administrators_. To access this feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select [**Security** > **Test Engine** tab](https://buildkite.com/organizations/~/security/test-analytics) to access your organization's security for Test Engine page.

From this page, you can configure the following permissions for all users across your Buildkite organization:

- **Create test suites**—if the [teams feature](#manage-teams-and-permissions) is enabled, then this permission is controlled at a [team-level](#manage-teams-and-permissions-team-level-permissions) and therefore, this option will be unavailable on this page.
- **Delete test suites**
- **Change test suite visibility**—Make test suites publicly available.
