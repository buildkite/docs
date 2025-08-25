# Manage registries

This page provides details on how to manage registries within your Buildkite organization.

Buildkite Package Registries allows you to create two types of registries: [_source_](#create-a-source-registry) and [_composite_](#composite-registries).

## Create a source registry

A _source_ registry is a basic type of registry used for publishing and installing packages. A source registry stores package files, which are either hosted by Buildkite or in your own [private storage](#update-a-source-registry-configure-registry-storage).

New source registries can be created through the **Registries** page of the Buildkite / Package Registries interface.

To create a new source registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select **New registry** > **Source Registry**.
1. On the **New Registry** page, enter the mandatory **Name** for your registry.
1. Enter an optional **Description** for the registry. This description appears under the name of the registry item on the **Registries** page.
1. Select the required registry **Ecosystem** based on the [package ecosystem](#manage-packages-in-a-source-registry) for this new registry.
1. If your Buildkite organization has the [teams feature](/docs/package-registries/security/permissions) enabled, select the relevant **Teams** to be granted access to the new registry.
1. Select **Create Registry**.

    The new registry's details page is displayed. Selecting **Package Registries** in the global navigation opens the **Registries** page, where your new registry will be listed.

## Manage packages in a source registry

Once a [source registry has been created](#create-a-source-registry), packages can then be uploaded to it. Learn more about how to manage packages for your registry's relevant language and package ecosystem:

<%= render_markdown partial: 'package_registries/supported_package_ecosystems' %>

## Update a source registry

Source registries can be updated using the **Registries** page of the Buildkite / Package Registries interface, which lists all previously created [source](#create-a-source-registry) and [composite](#composite-registries-create-a-composite-registry) registries.

The following aspects of a source registry can be updated:

<%= render_markdown partial: 'package_registries/registries/updatable_registry_components_1' %>

- **Registry Management**: the privacy settings for the registry—private (the initial default state for all newly created registries) or public.
- **OIDC Policy**: one or more [policies defining which OpenID Connect (OIDC) tokens](/docs/package-registries/security/oidc), from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another third-party system, can be used to either publish/upload packages to the registry, or download/install packages from the registry.

<%= render_markdown partial: 'package_registries/registries/updatable_registry_components_2' %>

- **Storage**: choose your [registry storage](#update-a-source-registry-configure-registry-storage), selecting from **Buildkite-hosted storage** (the initially default storage system) or [your own private AWS S3 bucket](/docs/package-registries/registries/private-storage-link) to store packages for this registry.

A source registry's ecosystem type cannot be changed once the [registry is created](#create-a-source-registry).

To update a source registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

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

1. If [_private storage_](/docs/package-registries/registries/private-storage-link) has been configured and linked to your Buildkite organization, the storage location for the registry can be changed. Learn more about this in [Configure registry storage](#update-a-source-registry-configure-registry-storage).

### Configure registry storage

When a [new source registry is created](#create-a-source-registry), it automatically uses the [default Buildkite Package Registries storage](/docs/package-registries/registries/private-storage-link#set-the-default-buildkite-package-registries-storage) location. However, your new source registry's default storage location can be overridden to use another configured storage location. Learn more about configuring private storage in [Private storage links](/docs/package-registries/registries/private-storage-link).

To configure/change your source registry's current storage:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the source registry whose storage requires configuring.

1. Select **Settings** > **Storage** to access the source registry's **Storage** page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage link such as **s3://…** or **gs://…**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the storage location can also be reverted back to using **Buildkite-hosted storage**.

> 📘
> All subsequent packages published to this source registry will be stored in your newly configured storage location. Bear in mind that all existing packages in this registry will remain in their original storage location.

## Composite registries

> 📘
> The _composite registries_ feature is currently in _customer preview_. To enquire about accessing this feature for your Buildkite organization, please contact support@buildkite.com.

A _composite_ registry is a Buildkite registry type that consists of one or more [source registries](#create-a-source-registry) that belong to a specific [package ecosystem](/docs/package-registries/ecosystems), can include the ecosystem's official (public) registry, and combines them all into a single virtual registry. These source and the official public registries are referred to as _upstreams_ (or _upstream registries_) of the composite registry.

Composite registries allow you to centrally manage packages so that they can be downloaded and installed from a single configurable URL using an [API access token](https://buildkite.com/user/api-access-tokens) (with the **Read Packages** REST API scope), [registry token](#configure-registry-tokens), or temporary token available through the composite registry's **Setup & Usage** page. This means that your projects only need to be configured with a single composite registry URL (one for each [package ecosystem](/docs/package-registries/ecosystems)), to download and install the packages they need. Each upstream providing these packages can be configured separately through the composite registry itself.

A composite registry is always private. However, while its [source registry](#create-a-source-registry) _upstreams_ can either be private or publicly accessible, the composite registry's permissions _always override_ those of its source registry upstreams. Some private source registries may not be accessible to certain users within your Buildkite organization, due to [team](/docs/package-registries/security/permissions#manage-teams-and-permissions-team-level-permissions)- or [registry](/docs/package-registries/security/permissions#manage-teams-and-permissions-registry-level-permissions)-level permissions applied to these registries, or both. Regardless of these permissions, if such private source registries and those with user-restricted access are configured as _upstreams_ of a composite registry, then these source registries' packages can still be downloaded and installed by _any_ user with access to this composite registry, through the composite registry's URL. Therefore, when configuring a composite registry's upstreams, be aware of the security implications around this user access.

> 📘
> Currently, the composite registries feature only supports the Java, JavaScript and Python [package ecosystems](/docs/package-registries/ecosystems).

### Create a composite registry

New composite registries can be created through the **Registries** page of the Buildkite / Package Registries interface.

To create a new composite registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select **New registry** > **Composite Registry**.
1. On the **New Composite Registry** page, enter the mandatory **Name** for your registry.
1. Enter an optional **Description** for the registry. This description appears under the name of the registry item on the **Registries** page.
1. Select the required registry **Ecosystem** based on the [package ecosystem](#manage-packages-in-a-source-registry) for this new registry.
1. To allow your composite registry to download packages from your chosen package ecosystem's official public registry, select **Add official registry?** Doing this allows packages from one of the following official public registries to be downloaded and installed through your composite registry's URL, based on your composite registry's package ecosystem:
    * Java (Maven) (`https://repo.maven.apache.org/maven2/`)
    * JavaScript (`https://registry.npmjs.org/`)
    * Python (`https://pypi.org/simple/`)

1. If your Buildkite organization has the [teams feature](/docs/package-registries/security/permissions) enabled, select the relevant **Teams** to be granted access to the new registry.
1. Select **Create Registry**.

    The new registry's details page is displayed. Selecting **Package Registries** in the global navigation opens the **Registries** page, where your new registry will be listed.

### Edit a composite registry's upstreams

When a [composite registry is created](#composite-registries-create-a-composite-registry), it has no configured [source registries](#create-a-source-registry) as upstreams. The only registry that may be configured is one of the official public registries, based on your composite registry's [package ecosystem](#manage-packages-in-a-source-registry):

- Java (Maven) (`https://repo.maven.apache.org/maven2/`)
- JavaScript (`https://registry.npmjs.org/`)
- Python (`https://pypi.org/simple/`)

Package Registries allows you to configure any of your Buildkite organization's currently available source registries that match your composite registry's package ecosystem, as upstreams. When viewing a composite registry, you can edit these upstreams by [adding them to or removing them from your composite registry](#add-or-remove-source-registries), as well as [enabling or disabling the official public registry](#enable-or-disable-the-official-registry) for your composite registry's package ecosystem.

<a id="add-or-remove-source-registries"></a>

#### Add or remove source registries

To add source registries to or remove them from your composite registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the composite registry whose upstreams are to be added or removed.

1. Ensure the **Upstreams** tab is selected and select the **Edit upstreams** button.

    A list of all [source registries](#create-a-source-registry) available in your Buildkite organization matching your composite registry's [package ecosystem](#manage-packages-in-a-source-registry), appears in a side panel. Any source registries already configured as upstreams in the composite registry are associated with a **Remove** button.

1. To add one or more upstreams, select their **Add** button in the side panel.

1. To remove one or more upstreams, select their **Remove** button in the side panel.

1. Once done, select the **X** in the side panel to close it.

<a id="enable-or-disable-the-official-registry"></a>

#### Enable or disable the official registry

To enable or disable access to the official public registry through your composite registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

1. Select the composite registry whose official public registry is to be enabled or disabled.

1. Ensure the **Upstreams** tab is selected, and in the **Official registries** section, select **Enable** to enable access to the official public registry for the composite registry's [package ecosystem](#manage-packages-in-a-source-registry), or **Disable** to disable access to this official public registry.

### Update a composite registry

Composite registries can be updated using the **Registries** page of the Buildkite / Package Registries interface, which lists all previously created [source](#create-a-source-registry) and [composite](#composite-registries-create-a-composite-registry) registries.

The following aspects of a composite registry can be updated:

<%= render_markdown partial: 'package_registries/registries/updatable_registry_components_1' %>

- **OIDC Policy**: one or more [policies defining which OpenID Connect (OIDC) tokens](/docs/package-registries/security/oidc), from the [Buildkite Agent](/docs/agent/v3/cli-oidc) or another third-party system, can be used to download/install packages from the registry.

<%= render_markdown partial: 'package_registries/registries/updatable_registry_components_2' %>

A composite registry's ecosystem type cannot be changed once the [registry is created](#composite-registries-create-a-composite-registry).

To update a composite registry:

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

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

1. Select **Package Registries** in the global navigation to access the [**Registries**](https://buildkite.com/organizations/~/packages) page.

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

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select the registry to delete on this page.
1. Select **Settings** to open the **General (Settings)** page.
1. Under **Registry Management**, select **Delete Registry**.
1. In the confirmation dialog, enter the name of the registry, exactly as it is presented, and select **Delete Registry**.

## Audit logging

All events performed through Buildkite Package Registries are logged through the Buildkite organization's [**Audit Log** feature](/docs/platform/audit-log).
