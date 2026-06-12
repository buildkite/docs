# User, team, pipeline, and test suite permissions

The [_teams_ feature](#manage-teams-and-permissions) allows you to apply access permissions and functionality controls for one or more groups of users (that is, _teams_) on each pipeline and test suite throughout your organization.

Enterprise plan customers can configure pipeline and test suite permissions for all users across their Buildkite organization through the **Security** page. Learn more about these features in [Manage organization security for pipelines](#manage-organization-security-for-pipelines) and [Manage organization security for test suites](#manage-organization-security-for-test-suites).

## Manage teams and permissions

To manage teams across the Buildkite Pipelines application, a _Buildkite organization administrator_ first needs to enable this feature across their organization. Learn more about how to do this in the [Manage teams and permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions).

Once the _teams_ feature is enabled, you can see the teams that you're a member of from the **Users** page, which:

- As a Buildkite organization administrator, you can access by selecting **Settings** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

- As any other user, you can access by selecting **Teams** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

### Organization-level permissions

Learn more about what a _Buildkite organization administrator_ can do in the [Organization-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).

As an organization administrator, you can access the [**Organization Settings** page](https://buildkite.com/organizations/~/settings) by selecting **Settings** in the global navigation, where you can do the following:

- Add new teams or edit existing ones in the [**Team** section](https://buildkite.com/organizations/~/teams).

- After selecting a team, you can view and administer the member-, [pipeline-](#manage-teams-and-permissions-pipeline-level-permissions), [test suite-](#manage-teams-and-permissions-test-suite-level-permissions), [registry-](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions), and [team-](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions)level settings for that team.

**Note:** Registry-level settings are only available once [Buildkite Package Registries has been enabled](/docs/package-registries/security/permissions#enabling-buildkite-packages).

### Team-level permissions

Learn more about what _team members_ are and what _team maintainers_ can do in the [Team-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

### Pipeline-level permissions

When the [teams feature is enabled](#manage-teams-and-permissions), any user can create a new pipeline, as long as this user is a member of at least one team within the Buildkite organization, and this team has the **Create pipelines** [team member permission](#manage-teams-and-permissions-team-level-permissions).

When you create a new pipeline in Buildkite:

- You are automatically granted the **Full Access** (`MANAGE_BUILD_AND_READ`) permission to this pipeline.
- Any members of teams to which you provide access to this pipeline are also granted the **Full Access** permission.

**Full Access** on a pipeline allows you to:

- View and create builds or rebuilds.
- Edit pipeline settings, which includes the ability to change the pipeline's visibility.
- Archive the pipeline or delete the pipeline.
- Provide access to other users, by adding the pipeline to other teams that you are a [team maintainer](#manage-teams-and-permissions-team-level-permissions) on.

Any user with the **Full Access** permission on a pipeline can change its permission to either:

- **Build & Read** (`BUILD_AND_READ`), which allows you to view and create builds or rebuilds, but _not_:
    * Edit the pipeline settings.
    * Archive or delete the pipeline.
    * Provide access to other users.
- **Read Only** (`READ_ONLY`), which allows you to view builds only, but _not_:
    * Create builds or issue rebuilds.
    * Edit the pipeline settings.
    * Archive or delete the pipeline.
    * Provide access to other users.

A user who is a member of at least one team with **Full Access** permission to a pipeline can change the permission on this pipeline. However, once this user loses **Full Access** through their last team with this permission on this pipeline, the user then loses the ability to change the pipeline's permissions in any team they are a member of.

Another user with **Full Access** to this pipeline or a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions) is required to change the pipeline's permission back to **Full Access** again.

### Test suite-level permissions

When the [teams feature is enabled](#manage-teams-and-permissions), any user can create a new test suite, as long as this user is a member of at least one team within the Buildkite organization, and this team has the **Create test suites** [team member permission](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

When you create a new test suite in Buildkite:

- You are automatically granted the **Full Access** permission to this test suite.
- Any members of teams to which you provide access to this test suite are also granted the **Full Access** permission.

**Full Access** on a test suite allows you to:

- View test data.
- Edit the test suite's settings.
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

## Manage organization security for pipelines

Buildkite customers on the [Enterprise plan](https://buildkite.com/pricing/) can configure pipeline action permissions and related security features for all users across their Buildkite organization. These features can be used either with or without the [teams feature enabled](#manage-teams-and-permissions).

These user-level permissions and security features are managed by _Buildkite organization administrators_. To access this feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select [**Security** > **Pipelines** tab](https://buildkite.com/organizations/~/security/pipelines) to access your organization's security for pipelines page.

From this page, you can configure the following permissions for all users across your Buildkite organization:

- **Create Pipelines**—if the [teams feature](#manage-teams-and-permissions) is enabled, then this permission is controlled at a [team-level](#manage-teams-and-permissions-team-level-permissions) and therefore, this option will be unavailable on this page.
- **Delete pipelines**
- **Change Pipeline Visibility**—Make private pipelines publicly available.
- **Change Notification Services**—Allows notification services to be created, edited, and deleted.
- **Manage Agent Registration Tokens**—Allows [agent tokens](/docs/agent/self-hosted/tokens) to be created, edited, and deleted.
- **Stop Agents**—Allows users to disconnect agents from Buildkite.

## Manage organization security for test suites

Buildkite customers on the [Enterprise plan](https://buildkite.com/pricing/) can configure test suite action permissions for all users across their Buildkite organization. These features can be used either with or without the [teams feature enabled](#manage-teams-and-permissions).

These user-level permissions and security features are managed by _Buildkite organization administrators_. To access this feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select [**Security** > **Test Suites** tab](https://buildkite.com/organizations/~/security/test-analytics) to access the security settings for Test Suites in your Buildkite organization.

From this page, you can configure the following permissions for all users across your Buildkite organization:

- **Create test suites**—if the [teams feature](#manage-teams-and-permissions) is enabled, then this permission is controlled at a [team-level](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions) and therefore, this option will be unavailable on this page.
- **Delete test suites**
- **Change test suite visibility**—Make test suites publicly available.
