# Manage registries

This page provides details on how to manage registries within your Buildkite organization.

## Create a registry

New registries can be created through the _Repositories_ page of the Buildkite interface.

To create a new registry:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.

    **Note:** Any previously created registries are listed and can be accessed from this page.

1. Select _New repository_.
1. On the _New Repository_ page, enter the mandatory name for your registry. Since registry names cannot contain spaces, hyphens will automatically be specified when the space key is pressed.
1. Enter an optional _Description_ for the registry. This description appears under the name of the registry item on the _Repositories_ page.
1. Select the required _Repo Type_ based on the [package ecosystem](/docs/packages#buildkite-packages-supported-package-ecosystems) for this new registry.
1. Select _Create Repository_.

    The new registry's details page is displayed. Selecting _Packages_ in the global navigation opens the _Repositories_ page, where your new registry will be listed.

### Manage packages in a registry

Once a [registry is created](#create-a-registry), packages can then be uploaded to it. Learn more about how to manage packages for your registry's relevant package ecosystem:

- [deb (Debian and Ubuntu)](/docs/packages/debian)
- [Ruby](/docs/packages/ruby)
- Java ([Maven](/docs/packages/maven) or [Gradle leveraging the Maven Publish Plugin](/docs/packages/gradle))
- [Node.js (npm)](/docs/packages/nodejs)
- [Python (PyPI)](/docs/packages/python)
- [Terraform](/docs/packages/terraform)

## Update a registry

Package registries can be updated using the package _Repositories_ page of the Buildkite interface, which lists all [previously created registries](#create-a-registry).

The following aspects of a registry can be updated:

- _Name_: be aware that changing this value will also change the URL, which in turn will break any existing installations that use this registry
- _Description_
- _Emoji_: to change the emoji of the registry from its default provided when the registry was [created](#create-a-registry). The emoji appears next to the registry's name
- _Color_: the background color for the emoji
- _Private_: the privacy settings for the registry—private or public
- _OIDC Policy_: the policy defining how OpenID Connect tokens can be used to push packages to the registry

The registry's ecosystem type cannot be changed once the registry is created.

To update a registry:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select the registry to update on this page.
1. Select _Edit_ and update the following fields as required:
    * _Name_ (being aware of the consequences described above)
    * _Description_, which appears under the name of the registry item on the _Repositories_ page, and on the registry's details page
    * _Emoji_ and _Color_, which appears next to the registry's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji
    * _Private_, ensure this checkbox is selected to make or keep the registry private or cleared to make or keep the registry public
    * _OIDC Policy_, modify accordingly

1. Select _Update Repository_ to save your changes.

    The registry's updates will appear on the _Repositories_ page, as well as the registry's details page.

## Delete a registry

Package registries can be deleted using the package _Repositories_ page of the Buildkite interface, which lists all [previously created registries](#create-a-registry).

Deleting a registry permanently deletes all packages contained within it.

To delete a registry:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select the registry to delete on this page.
1. Select _Edit_ > _Delete Repository_.
1. In the confirmation dialog, enter the name of the registry, exactly as it is presented, and select _Delete Repository_.
