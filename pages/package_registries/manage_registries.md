# Manage registries

This page provides details on how to manage registries within your Buildkite organization.

Buildkite Package Registries allows you to create two types of registries: [_source_](#create-a-source-registry) and [_composite_](#composite-registries).

## Create a source registry

A _source_ registry is a registry that houses package files itself.

New source registries can be created through the **Registries** page of the Buildkite / Package Registries interface.

To create a new source registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select **New registry** > **Source Registry**.
1. On the **New Registry** page, enter the mandatory **Name** for your registry.
1. Enter an optional **Description** for the registry. This description appears under the name of the registry item on the **Registries** page.
1. Select the required registry **Ecosystem** based on the [package ecosystem](#create-a-source-registry-manage-packages-in-a-registry) for this new registry.
1. If your Buildkite organization has the [teams feature](/docs/package-registries/security/permissions) enabled, select the relevant **Teams** to be granted access to the new registry.
1. Select **Create Registry**.

    The new registry's details page is displayed. Selecting **Packages** in the global navigation opens the **Registries** page, where your new registry will be listed.

### Manage packages in a registry

Once a [source registry is created](#create-a-source-registry), packages can then be uploaded to it. Learn more about how to manage packages for your registry's relevant language and package ecosystem:

<%= render_markdown partial: 'package_registries/supported_package_ecosystems' %>

## Update a source registry

Source registries can be updated using the **Registries** page of the Buildkite / Package Registries interface, which lists all previously created [source](#create-a-source-registry) and [composite](#composite-registries-create-a-composite-registry) registries.

The following aspects of a source registry can be updated:

<%= render_markdown partial: 'package_registries/updatable_registry_components_1' %>

- **Registry Management**: the privacy settings for the registry—private (the initial default state for all newly created registries) or public.

<%= render_markdown partial: 'package_registries/updatable_registry_components_2' %>

- **Storage**: choose your [registry storage](#update-a-source-registry-configure-registry-storage), selecting from **Buildkite-hosted storage** (the initially default storage system) or [your own private AWS S3 bucket](/docs/package-registries/private-storage) to store packages for this registry.

A source registry's ecosystem type cannot be changed once the [registry is created](#create-a-source-registry).

To update a source registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the source registry to update on this page.

1. Select **Settings** and on the **General (Settings)** page, update the following fields as required:
    * **Name**: being aware of the consequences described above
    * **Description**: appears under the name of the registry item on the **Registries** page, and on the registry's details page
    * **Emoji** and **Color**: the emoji appears next to the registry's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji
    * **Registry Management** > **Make registry public** or **Make registry private**: select either of these buttons to make the registry public or revert it back to its private state—the existing wording on this button indicates the current state, and if the registry is public, the word **Public** is indicated explicitly next to the registry's name in the Buildkite interface.

1. Select **Update Registry** to save your changes.

    The registry's updates will appear on the **Registries** page, as well as the registry's details page.

1. If the registry's _OIDC policy_ needs to be configured, learn more about this in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

1. If the registry is _private_ and _registry tokens_ (an alternative to API access tokens) need to be configured, learn more about this in [Configure registry tokens](#configure-registry-tokens).

1. If [_private storage_](/docs/package-registries/private-storage) has been configured and linked to your Buildkite organization, the storage location for the registry can be changed. Learn more about this in [Configure registry storage](#update-a-source-registry-configure-registry-storage).

### Configure registry storage

When a [new source registry is created](#create-a-source-registry), it automatically uses the [default Buildkite Package Registries storage](/docs/package-registries/private-storage#set-the-default-buildkite-package-registries-storage) location. However, your new source registry's default storage location can be overridden to use another configured storage location. Learn more about configuring private storage in [Private storage links](/docs/package-registries/private-storage).

To configure/change your source registry's current storage:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the source registry whose storage requires configuring.

1. Select **Settings** > **Storage** to access the source registry's **Storage** page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage beginning with **s3://...**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the storage location can also be reverted back to using **Buildkite-hosted storage**.

> 📘
> All subsequent packages published to this source registry will be stored in your newly configured storage location. Bear in mind that all existing packages in this registry will remain in their original storage location.

## Composite registries

A _composite_ registry is Buildkite registry type that consists of one or more [source registries](#create-a-source-registry) belonging to a specific [package ecosystem](/docs/package-registries/ecosystems). This allows packages from a single composite registry to be:

- Downloaded from one or more source registries of a specific package ecosystem, including the package ecosystem's official (public) registry.

- Downloaded and installed from a single configurable URL using an [API access token](https://buildkite.com/user/api-access-tokens) (with the **Read Packages** REST API scope), [registry token](#configure-registry-tokens), or temporary token available through the composite registry's **Setup & Usage** page.

Composite registries allow your projects to be configured with just a single composite registry URL (one for each [package ecosystem](/docs/package-registries/ecosystems)), through which your packages can be downloaded and installed. The actual Buildkite source registries that provide these packages, including those from the ecosystem's official public registry, can each be configured separately as an _upstream_ through the composite registry itself.

A composite registry is a private, and its configured source registries, known as _upstreams_ or _upstream registries_, can either be private or publicly accessible. Furthermore, some private source registries may not be accessible to certain users within your Buildkite organization, due to [team](/docs/package-registries/security/permissions#manage-teams-and-permissions-team-level-permissions)- or [registry](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions)-level permissions applied to these registries, or both. Regardless of these permissions, if such private source registries and those with user-restricted access are configured as _upstreams_ of a composite registry, then these source registries' packages can still be downloaded and installed by _any_ user with access to this composite registry, through the composite registry's URL.

### Create a composite registry

New composite registries can be created through the **Registries** page of the Package Registries interface.

To create a new composite registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select **New registry** > **Composite Registry**.
1. On the **New Composite Registry** page, enter the mandatory **Name** for your registry.
1. Enter an optional **Description** for the registry. This description appears under the name of the registry item on the **Registries** page.
1. Select the required registry **Ecosystem** based on the [package ecosystem](#create-a-source-registry-manage-packages-in-a-registry) for this new registry. Currently, only Java, JavaScript and Python package ecosystems are supported.
1. To allow your composite registry to download packages from your chosen package ecosystem's official public registry, select **Add official registry?** Doing this allows packages from one of the following official registries to be downloaded and installed through your composite registry's URL, based on your composite registry's package ecosystem:
    * Java (https://repo.maven.apache.org/maven2/)
    * JavaScript (`https://registry.npmjs.org/`)
    * Python (`https://pypi.org/simple/`)

1. If your Buildkite organization has the [teams feature](/docs/package-registries/security/permissions) enabled, select the relevant **Teams** to be granted access to the new registry.
1. Select **Create Registry**.

    The new registry's details page is displayed. Selecting **Packages** in the global navigation opens the **Registries** page, where your new registry will be listed.

### Edit a composite registry's upstreams



### Update a composite registry

Composite registries can be updated using the **Registries** page of the Buildkite / Package Registries interface, which lists all previously created [source](#create-a-source-registry) and [composite](#composite-registries-create-a-composite-registry) registries.

The following aspects of a composite registry can be updated:

<%= render_markdown partial: 'package_registries/updatable_registry_components_1' %>

<%= render_markdown partial: 'package_registries/updatable_registry_components_2' %>

A composite registry's ecosystem type cannot be changed once the [registry is created](#composite-registries-create-a-composite-registry).

To update a composite registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the composite registry to update on this page.

1. Select **Settings** and on the **General (Settings)** page, update the following fields as required:
    * **Name**: being aware of the consequences described above
    * **Description**: appears under the name of the registry item on the **Registries** page, and on the registry's details page
    * **Emoji** and **Color**: the emoji appears next to the registry's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji

1. Select **Update Registry** to save your changes.

    The registry's updates will appear on the **Registries** page, as well as the registry's details page.

1. If the registry's _OIDC policy_ needs to be configured, learn more about this in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

1. If _registry tokens_ (an alternative to API access tokens) need to be configured, learn more about this in [Configure registry tokens](#configure-registry-tokens).

## Configure registry tokens

_Registry tokens_ are long-lived _read only_ tokens configurable for a [private source registry](#update-a-source-registry) or [composite registry](#composite-registries-update-a-composite-registry), which allow you download and install packages from that registry, acting as an alternative to (and without having to use) a user account-based [API access token](https://buildkite.com/user/api-access-tokens) with the **Read Packages** REST API scope.

To configure registry tokens for a private source or composite registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the private source or composite registry whose registry tokens require configuring.

1. Select **Settings** > **Tokens** to access the registry's **Tokens** page, where you can:
    * Create a new registry token. To do this:
        1. Select **Create Registry Token**.
        1. Enter a **Description** for this new token.
        1. Select **Create**.
    * Select the copy, view, **Edit description** or **Delete token** button associated with any existing token on this page, to perform that action on the token.

Unlike other tokens generated elsewhere in Buildkite, registry tokens can continue to be viewed and copied in their entirety on multiple occasions after their creation. This registry tokens feature (the **Tokens** page) is not accessible while a registry is public. However, any registry tokens that were created before a registry is made public, will become accessible again when the registry is made private.

## Delete a registry

Any type of registry can be deleted using the **Registries** page of the Buildkite / Package Registries interface, which lists all previously created [source](#create-a-source-registry) and [composite](#composite-registries) registries.

Deleting:

- A source registry permanently deletes all packages contained within it.
- A composite registry will prevent any projects configured with it from downloading and installing packages from this registry.

To delete a registry:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select the registry to delete on this page.
1. Select **Settings** to open the **General (Settings)** page.
1. Under **Registry Management**, select **Delete Registry**.
1. In the confirmation dialog, enter the name of the registry, exactly as it is presented, and select **Delete Registry**.

## Audit logging

All events performed through Buildkite Package Registries are logged through the Buildkite organization's [**Audit Log** feature](/docs/platform/audit-log).
