# User, team, and registry permissions

Customers on the Buildkite [Pro and Enterprise](https://buildkite.com/pricing) plans can manage registry permissions using the [_teams_ feature](#manage-teams-and-permissions). This feature allows you to apply access permissions and functionality controls for one or more groups of users (that is, _teams_) on each registry throughout your organization.

Enterprise customers can configure registry permissions for all users across their Buildkite organization through the **Security** page. Learn more about this feature in [Manage organization security for registries](#manage-organization-security-for-registries).

## Manage teams and permissions

To manage teams across the Buildkite Package Registries application, a _Buildkite organization administrator_ first needs to enable this feature across their organization. Learn more about how to do this in the [Manage teams and permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions).

Once the _teams_ feature is enabled, you can see the teams that you're a member of from the **Users** page, which:

- As a Buildkite organization administrator, you can access by selecting **Settings** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

- As any other user, you can access by selecting **Teams** in the global navigation > [**Users**](https://buildkite.com/organizations/~/users/).

### Organization-level permissions

Learn more about what a _Buildkite organization administrator_ can do in the [Organization-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions).

As an organization administrator, you can access the [**Organization Settings** page](https://buildkite.com/organizations/~/settings) by selecting **Settings** in the global navigation, where you can do the following:

- Add new teams or edit existing ones in the [**Team** section](https://buildkite.com/organizations/~/teams).

    * After selecting a team, you can view and administer the member-, [pipeline-](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions), [test suite-](/docs/test-engine/permissions#manage-teams-and-permissions-test-suite-level-permissions), [registry-](#manage-teams-and-permissions-registry-level-permissions) and [team-](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions)level settings for that team.

- [Enable Buildkite Package Registries](#enabling-buildkite-packages) for your Buildkite organization.

- Configure [private storage](/docs/package-registries/registries/private-storage-link) for your registries in Buildkite Package Registries.

<h4 id="enabling-buildkite-packages">Enabling Buildkite Package Registries</h4>

Customers on legacy Buildkite plans may need to enable Package Registries to gain access to this product.

To do this:

1. As a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions), access the [**Organization Settings** page](https://buildkite.com/organizations/~/settings) by selecting **Settings** in the global navigation.

1. In the **Packages** section, select **Enable** to open the **Enable Packages** page.

1. Select the **Enable Buildkite Packages** button, then **Enable Buildkite Packages** in the **Ready to enable Buildkite Packages** confirmation dialog.

> 📘
> Once Buildkite Package Registries is enabled, the **Enable** link on the **Organization Settings** page changes to **Enabled** and Buildkite Package Registries can only be disabled by contacting support at support@buildkite.com.

### Team-level permissions

Learn more about what _team members_ are and what _team maintainers_ can do in the [Team-level permissions in the Platform documentation](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

### Registry-level permissions

When the [teams feature is enabled](#manage-teams-and-permissions), any user can create a new registry, as long as this user is a member of at least one team within the Buildkite organization, and this team has the **Create registries** [team member permission](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions).

When you create a new registry in Buildkite:

- You are automatically granted the **Read & Write** permission to this registry.
- Any members of teams to which you provide access to registry are also granted the **Read & Write** permission.

The **Full Access** permission on a registry allows you to:

- View and download packages, images, or modules from the registry.
- Publish packages, images, or modules to the registry.
- Edit the registry's settings.
- Delete the registry.
- Provide access to other users, by adding the registry to other teams that you are a [team maintainer](#manage-teams-and-permissions-team-level-permissions) on.

Any user with **Full Access** permissions to a registry can change its permission to either:

- **Read & Write**, which allows you to publish packages, images, or modules to the registry, as well as view and download these items from the registry, but _not_:
    * Edit the registry's settings.
    * Delete the registry.
    * Provide access to other users.
- **Read Only**, which allows you to view and download packages, images, or modules from the registry only, but _not_:
    * Publish such items to the registry.
    * Edit the registry's settings.
    * Delete the registry.
    * Provide access to other users.

A user who is a member of at least one team with **Full Access** permissions to a registry can change the permissions on this registry. However, once this user loses this **Full Access** through their last team with access to this registry, the user then loses the ability to change the registry's permissions.

Another user with **Full Access** to this registry or a [Buildkite organization administrator](#manage-teams-and-permissions-organization-level-permissions) is required to change the registry's permissions back to **Full Access** again.

## Manage organization security for registries

Enterprise customers can configure registry action permissions for all users across their Buildkite organization. These features can be used either with or without the [teams feature enabled](#manage-teams-and-permissions).

These user-level permissions and security features are managed by _Buildkite organization administrators_. To access this feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select [**Security** > **Packages** tab](https://buildkite.com/organizations/~/security/packages) to access your organization's security for **Packages** page.

From this page, you can configure the following permissions for all users across your Buildkite organization:

- **Create registries**—if the [teams feature](#manage-teams-and-permissions) is enabled, then this permission is controlled at a [team-level](#manage-teams-and-permissions-team-level-permissions) and therefore, this option will be unavailable on this page.
- **Delete registries**
- **Delete packages**

## Manage an agent's access to registries

To configure the rules by which a Buildkite Agent can access a registry, you'll need to configure the [OpenID Connect (OIDC) policy](/docs/package-registries/security/oidc) within the registry to allow the Buildkite Agent to generate an OIDC token (using the [`buildkite-agent oidc request-token`](/docs/agent/v3/cli-oidc#request-oidc-token) command), which the agent can use to authenticate to this registry.

