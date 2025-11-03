# Private storage link

This page provides an overview of Buildkite Package Registries' _private storage link_ feature.

By default, Buildkite Package Registries provides its own storage (known as _Buildkite storage_) to house any packages, container images and modules stored in source registries. However, as a [Buildkite organization administrator](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions), you can also link your own private storage to Buildkite Package Registries (known as a _private storage link_) to house these files.

A private storage link allows you to:

- Manage Buildkite registry packages, container images and modules stored within your private storage, which has the following advantages:

    * Locating your private storage closer to your geographical location may provide faster registry access.
    * Mitigates network transmission costs.
    * Reduces latency when closer to your workloads.
    * Allows full control over bucket-level security and lifecycle policies.

- Use Buildkite Package Registries' management and metadata-handling features to manage these files in registries within your private storage. While packages are stored in your own private storage, Buildkite still handles the indexing and management of these packages.

- Maintain control, ownership and sovereignty over the packages, container images and modules stored within your source registries managed by Buildkite Package Registries.

Regardless of whether you choose to manage your packages in Buildkite storage or in your own storage through a private storage link:

- Both storage and bandwidth are metered in the same manner, with no differences in additional costs.
- Package management, indexing, and access are all routed through the Buildkite API.

The following diagram shows how your private storage link interfaces between the Buildkite Package Registries software-as-a-service (SaaS) control plane (which constitutes the Buildkite Platform), and your teams' infrastructure, operating in environments you can control.

<%= image "private-storage-link-overview.png", alt: "Shows how your private storage link fits between the SaaS platform and your own infrastructure" %>

Abbreviations:

- CDN—content delivery network
- API/CLI—is application programming interface/command line interface
- SSO & RBAC—single sign-on & role-based access control

## Link your private storage to Buildkite Package Registries

The following steps provide a high-level overview on how to link your private storage (offered through a cloud-based storage provider) to Package Registries:

1. Provide bucket details.
1. Authorize Buildkite to access the bucket.
1. Run a diagnostic to confirm Buildkite can access/modify/sign objects in that bucket.
1. Activate the link.

Learn more about how to configure Package Registries to use your private storage with the following supported cloud-based storage providers:

- [Amazon S3 storage](/docs/package-registries/registries/private-storage-link/amazon-s3)
- [Google Cloud Storage](/docs/package-registries/registries/private-storage-link/google-cloud-storage)

## Set the default Buildkite Package Registries storage

By default, your Buildkite organization uses storage provided by Buildkite (indicated as **Buildkite-hosted storage**).

The _default storage_ is the storage used when a [new source registry is created](/docs/package-registries/registries/manage#create-a-source-registry).

Once you have [configured at least one other private storage link](#link-your-private-storage-to-buildkite-package-registries), you can change the default storage to one of the configured private storage configurations. To do this:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage link such as **s3://…** or **gs://…**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the default storage can also be reverted back to using **Buildkite-hosted storage**.

All [newly created source registries](/docs/package-registries/registries/manage#create-a-source-registry) will automatically use the default private storage location to house packages. Note that composite registries do not allow specifying a storage location; therefore, packages pulled from [official public registries](/docs/package-registries/registries/manage#composite-registries) are always stored on Buildkite-hosted storage.
