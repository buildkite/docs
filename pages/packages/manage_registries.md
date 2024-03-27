# Manage package repositories

This page provides details on how to manage package repositories within your Buildkite organization.

## Create a repository

New repositories can be created using the package _Repositories_ page of the Buildkite interface.

To create a new package repository:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.

    **Note:** Any previously created repositories are listed and can be accessed from this page.

1. Select _New repository_.
1. On the _New Repository_ page, enter the mandatory name for your repository. Since repository names cannot contain spaces, hyphens will automatically be specified when the space key is pressed.
1. Enter an optional _Description_ for the repository. This description appears under the name of the repository item on the _Repositories_ page.
1. Select the required _Repo Type_ based on the [package ecosystem](/docs/packages#buildkite-packages-supported-package-ecosystems) for this new repository.
1. Select whether or not this repository should be _Private_. Leaving this checkbox clear will make the repository public.
1. Select _Create Repository_.

    The new package repository's details page is displayed. Selecting _Packages_ in the global navigation opens the _Repositories_ page, where your new package repository will be listed.

### Manage packages in a repository

Once a [package repository is created](#create-a-repository), packages can then be uploaded to it. Learn more about how to manage packages for your repository's relevant package ecosystem:

- [deb (Debian and Ubuntu)](/docs/packages/debian)
- Java ([Maven](/docs/packages/maven) or [Gradle leveraging Maven](/docs/packages/gradle))
- [Python (PyPI)](/docs/packages/python)
- [Ruby](/docs/packages/ruby)
- [Terraform](/docs/packages/terraform)

## Update a repository

Package repositories can be updated using the package _Repositories_ page of the Buildkite interface, which lists all [previously created repositories](#create-a-repository).

The following aspects of a package repository can be updated:

- _Name_: be aware that changing this value will also change the URL, which in turn will break any existing installations that use this package repository
- _Description_
- _Emoji_: to change the emoji of the package repository from its default provided when the repository was [created](#create-a-repository). The emoji appears next to the repository's name
- _Color_: the background color for the emoji
- _Private_: the privacy settings for the package repository—private or public
- _OIDC Policy_: the policy defining how OpenID Connect tokens can be used to push packages to the repository

The package repository's ecosystem type cannot be changed once the repository is created.

To update a package repository:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select the repository to update on this page.
1. Select _Edit_ and update the following fields as required:
    * _Name_ (being aware of the consequences described above)
    * _Description_, which appears under the name of the repository item on the _Repositories_ page, and on the repository's details page
    * _Emoji_ and _Color_, which appears next to the repository's name and the color (in hex code syntax, for example, `#FFE0F1`) provides the background color for this emoji
    * _Private_, ensure this checkbox is selected to make or keep the package repository private or cleared to make or keep the repository public
    * _OIDC Policy_, modify accordingly

1. Select _Update Repository_ to save your changes.

    The package repository's updates will appear on the _Repositories_ page, as well as the repository's details page.

## Delete a repository

Package repositories can be deleted using the package _Repositories_ page of the Buildkite interface, which lists all [previously created repositories](#create-a-repository).

Deleting a package repository permanently deletes all packages contained within it.

To delete a package repository:

1. Select _Packages_ in the global navigation to access the _Repositories_ page.
1. Select the repository to delete on this page.
1. Select _Edit_ > _Delete Repository_.
1. In the confirmation dialog, enter the name of the package repository, exactly as it is presented, and select _Delete Repository_.
