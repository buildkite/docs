# Manage registries

This page provides details on how to manage registries within your Buildkite organization.

Package Registries allows you to create two types of registries: [source](#create-a-source-registry) and [composite](#create-a-composite-registry).

## Create a source registry

A _source registry_ is a registry that houses package files itself.

New source registries can be created through the **Registries** page of the Buildkite interface.

To create a new registry:

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

Once a [registry is created](#create-a-source-registry), packages can then be uploaded to it. Learn more about how to manage packages for your registry's relevant language and package ecosystem:

<%= render_markdown partial: 'package_registries/supported_package_ecosystems' %>

## Update a source registry

Registries can be updated using the package **Registries** page of the Buildkite interface, which lists all [previously created registries](#create-a-source-registry).

The following aspects of a registry can be updated:

- **Name**: be aware that changing this value will also change the URL, which in turn will break any existing installations that use this registry.
- **Description**
- **Emoji**: to change the emoji of the registry from the default provided when the registry was [created](#create-a-source-registry). The emoji appears next to the registry's name.
- **Color**: the background color for the emoji
- **Registry Management**: the privacy settings for the registry—private (the initial default state for all newly created registries) or public.
- **OIDC Policy**: one or more [policies defining which OpenID Connect (OIDC) tokens](/docs/package-registries/security/oidc), from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another third-party system, can be used to publish/upload packages to the registry.
- **Tokens** (private registries only): one or more [registry tokens](#update-a-source-registry-configure-registry-tokens), which are an alternative to API access tokens.
- **Storage**: choose your [registry storage](#update-a-source-registry-configure-registry-storage), selecting from **Buildkite-hosted storage** (the initially default storage system) or [your own private AWS S3 bucket](/docs/package-registries/private-storage) to store packages for this registry.

The registry's ecosystem type cannot be changed once the registry is created.

To update a registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the registry to update on this page.

1. Select **Settings** and on the **General (Settings)** page, update the following fields as required:
    * **Name**: being aware of the consequences described above
    * **Description**: appears under the name of the registry item on the **Registries** page, and on the registry's details page
    * **Emoji** and **Color**: the emoji appears next to the registry's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji
    * **Registry Management** > **Make registry public** or **Make registry private**: select either of these buttons to make the registry public or revert it back to its private state—the existing wording on this button indicates the current state, and if the registry is public, the word **Public** is indicated explicitly next to the registry's name in the Buildkite interface

1. Select **Update Registry** to save your changes.

    The registry's updates will appear on the **Registries** page, as well as the registry's details page.

1. If the registry's _OIDC policy_ needs to be configured, learn more about this in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

1. If the registry is _private_ and _registry tokens_ (an alternative to API access tokens) need to be configured, learn more about this in [Configure registry tokens](#update-a-source-registry-configure-registry-tokens).

1. If [_private storage_](/docs/package-registries/private-storage) has been configured and linked to your Buildkite organization, the storage location for the registry can be changed. Learn more about this in [Configure registry storage](#update-a-source-registry-configure-registry-storage).

### Configure registry tokens

_Registry tokens_ are long-lived _read only_ tokens configurable for a private registry, which allow you download and install packages from that registry, acting as an alternative to (and without having to use) a user account-based [API access token](https://buildkite.com/user/api-access-tokens) with the **Read Packages** REST API scope.

To configure registry tokens for a private registry:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the private registry whose registry tokens require configuring.

1. Select **Settings** > **Tokens** to access the registry's **Tokens** page, where you can:
    * Create a new registry token. To do this:
        1. Select **Create Registry Token**.
        1. Enter a **Description** for this new token.
        1. Select **Create**.
    * Select the copy, view, **Edit description** or **Delete token** button associated with any existing token on this page, to perform that action on the token.

Unlike other tokens generated elsewhere in Buildkite, registry tokens can continue to be viewed and copied in their entirety on multiple occasions after their creation. This registry tokens feature (the **Tokens** page) is not accessible while a registry is public. However, any registry tokens that were created before a registry is made public, will become accessible again when the registry is made private.

### Configure registry storage

When a new registry is [created](#create-a-source-registry), it automatically uses the [default Buildkite Package Registries storage](/docs/package-registries/private-storage#set-the-default-buildkite-package-registries-storage) location. However, your new registry's default storage location can be overridden to use another configured storage location. Learn more about configuring private storage in [Private storage links](/docs/package-registries/private-storage).

To configure/change your registry's current storage:

1. Select **Packages** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the registry whose storage requires configuring.

1. Select **Settings** > **Storage** to access the registry's **Storage** page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage beginning with **s3://...**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the storage location can also be reverted back to using **Buildkite-hosted storage**.

> 📘
> All subsequent packages published to this registry will be stored in your newly configured storage location. Bear in mind that all existing packages in this registry will remain in their original storage location.

## Delete a source registry

Registries can be deleted using the package **Registries** page of the Buildkite interface, which lists all [previously created registries](#create-a-source-registry).

Deleting a registry permanently deletes all packages contained within it.

To delete a registry:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select the registry to delete on this page.
1. Select **Settings** to open the **General (Settings)** page.
1. Under **Registry Management**, select **Delete Registry**.
1. In the confirmation dialog, enter the name of the registry, exactly as it is presented, and select **Delete Registry**.

## Create a composite registry

A _composite registry_ is one whose packages can be:

- Downloaded from one or more [Buildkite source registries](#create-a-source-registry) belonging to a specific [package ecosystem](/docs/package-registries/ecosystems), as well as this package ecosystem's official (public) registry.

- Downloaded and installed from a single configurable URL using an [API access token](https://buildkite.com/user/api-access-tokens) (with the **Read Packages** REST API scope), [registry token](#update-a-source-registry-configure-registry-tokens), or temporary token available through the composite registry's **Setup & Usage** page.

These features can make composite registries easier to work with, since your project only requires the configuration of single composite registry URL to download and install packages from, and the actual Buildkite source registries that provide these packages, including those from the ecosystem's official public registry, can be configured as an _upstream_ through the composite registry itself.

A composite registry is typically configured with one or more Buildkite source registries belonging to a specific ecosystem. These source registries, known as _upstreams_ or _upstream registries_, can be either private or publicly accessible. Furthermore, some private source registries may not be accessible to specific users within your Buildkite organization, based on [team](/docs/package-registries/security/permissions#manage-teams-and-permissions-team-level-permissions)- and [registry](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions)-level permissions. Regardless, of these permissions, if such private source registries and those with user-restricted access are configured as _upstreams_ of a composite registry, then these source registries' packages can still be downloaded and installed by _any_ user with access to this composite registry, through the composite registry's URL.

Currently, Buildkite supports the following Official repositories:

- Java (https://repo.maven.apache.org/maven2/)
- JavaScript (https://registry.npmjs.org/)
- Python (https://pypi.org/simple/)

## Audit logging

All events performed through Buildkite Package Registries are logged through the Buildkite organization's [**Audit Log** feature](/docs/platform/audit-log).
