# Private storage link

This page provides an overview of Private Storage Links — linking your own cloud storage (S3 / GCS) to Buildkite Package Registries.

Buildkite Package Registries lets you store packages, container images, and modules in your own cloud storage instead of Buildkite storage. This capability is called a _Private Storage Link_ (PSL) and can only be configured by [Buildkite organization administrators](/docs/package-registries/security/permissions#manage-teams-and-permissions-organization-level-permissions).

By default, Buildkite Package Registries provide its own storage (known as Buildkite storage) to house any packages, container images and modules stored in source registries. You can also link your own private storage to Buildkite Package Registries, which allows you to:

- Manage Buildkite registry packages, container images and modules stored within your private storage. Private storage:

    * Located closer to your geographical location may provide faster registry access.
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


---

## Link your private storage to Buildkite Package Registries

The high-level flow to link a storage provider:

1. Provide bucket details.
1. Authorize Buildkite to access the bucket.
1. Run a diagnostic to confirm Buildkite can access/modify/sign objects in that bucket.
1. Activate the link.

Buildkite currently supports the following storage providers:

- [Configure Amazon S3 Private Storage Link →](./private_storage_link/s3)
- [Configure Google Cloud Storage (GCS) Private Storage Link →](./private_storage_link/gcs)

> More providers will be added over time. Follow the links above to configure the provider that matches your infrastructure.


## Set the default Buildkite Package Registries storage

By default, your Buildkite organization uses storage provided by Buildkite (known as **Buildkite-hosted storage**).

The _default storage_ is the storage used when a [new source registry is created](/docs/package-registries/manage-registries#create-a-source-registry).

Once you have [configured at least one other private storage link](#link-your-private-storage-to-buildkite-package-registries), you can change the default storage to one of the configured private storage configurations. To do this:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. In the **Packages** section, select **Private Storage Link** to open its page.

1. Select **Change** to switch from using **Buildkite-hosted storage** (or a previously configured private storage link such as **s3://…** or **gs://…**) to your new private storage link. If this setting is currently configured to use a previously configured private storage link, the default storage can also be reverted back to using **Buildkite-hosted storage**.

All [newly created source registries](/docs/package-registries/manage-registries#create-a-source-registry) will automatically use the default private storage location to house packages.
