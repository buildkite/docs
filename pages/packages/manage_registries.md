# Manage registries

This page provides details on how to manage registries within your Buildkite organization.

## Create a registry

New registries can be created through the **Registries** page of the Buildkite interface.

To create a new registry:

1. Select **Packages** in the global navigation to access the **Registries** page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select **New registry**.
1. On the **New Registry** page, enter the mandatory **Name** for your registry. Since registry names cannot contain spaces, hyphens will automatically be specified when the space key is pressed.
1. Enter an optional **Description** for the registry. This description appears under the name of the registry item on the **Registries** page.
1. Select the required registry **Ecosystem** based on the [package ecosystem](/docs/packages#get-started) for this new registry.
1. If your Buildkite organization has the [teams feature](/docs/packages/permissions) enabled, select the relevant **Teams** to be granted access to the new registry.
1. Select **Create Registry**.

    The new registry's details page is displayed. Selecting **Packages** in the global navigation opens the **Registries** page, where your new registry will be listed.

### Manage packages in a registry

Once a [registry is created](#create-a-registry), packages can then be uploaded to it. Learn more about how to manage packages for your registry's relevant language and package ecosystem:

- [Alpine (apk)](/docs/packages/alpine)
- [Container (Docker)](/docs/packages/container) images
- [Debian/Ubuntu (deb)](/docs/packages/debian)
- Java ([Maven](/docs/packages/maven) or [Gradle leveraging the Maven Publish Plugin](/docs/packages/gradle))
- [JavaScript (npm)](/docs/packages/javascript)
- [Python (PyPI)](/docs/packages/python)
- [Red Hat (RPM)](/docs/packages/red-hat)
- [Ruby (RubyGems)](/docs/packages/ruby)
- [Terraform](/docs/packages/terraform) modules

## Update a registry

Registries can be updated using the package **Registries** page of the Buildkite interface, which lists all [previously created registries](#create-a-registry).

The following aspects of a registry can be updated:

- **Name**: be aware that changing this value will also change the URL, which in turn will break any existing installations that use this registry
- **Description**
- **Emoji**: to change the emoji of the registry from the default provided when the registry was [created](#create-a-registry). The emoji appears next to the registry's name
- **Color**: the background color for the emoji
- **Private**: the privacy settings for the registry—private or public
- **OIDC Policy**: the policy defining how OpenID Connect tokens can be used to push packages to the registry

The registry's ecosystem type cannot be changed once the registry is created.

To update a registry:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select the registry to update on this page.
1. Select **Edit** and update the following fields as required:
    * **Name** (being aware of the consequences described above)
    * **Description**, which appears under the name of the registry item on the **Registries** page, and on the registry's details page
    * **Emoji** and **Color**, which appears next to the registry's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji
    * **Private**, ensure this checkbox is selected to make or keep the registry private or cleared to make or keep the registry public
    * **OIDC Policy**, modify accordingly

1. Select **Update Registry** to save your changes.

    The registry's updates will appear on the **Registries** page, as well as the registry's details page.

<!--
## Configure a registry's OIDC policy
-->


## Delete a registry

Registries can be deleted using the package **Registries** page of the Buildkite interface, which lists all [previously created registries](#create-a-registry).

Deleting a registry permanently deletes all packages contained within it.

To delete a registry:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select the registry to delete on this page.
1. Select **Edit** > **Delete Registry**.
1. In the confirmation dialog, enter the name of the registry, exactly as it is presented, and select **Delete Registry**.

## Audit logging

All events conducted through Buildkite Packages are logged through the Buildkite organization's [**Audit Log** feature](/docs/pipelines/security/audit-log).
