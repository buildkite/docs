# Link private storage

This page provides details on how to link your private AWS S3 storage to Buildkite Packages within your Buildkite organization. This process can only be conducted by [Buildkite organization administrators](/docs/packages/permissions#manage-teams-and-permissions-organization-level-permissions).

By default, Buildkite Packages provides its own storage to house any packages, container images and modules stored in registries. You can also link your own private AWS S3 storage to Buildkite Packages, which allows you to:

- Use Buildkite Package's management and metadata-handling features to manage packages, container images and modules stored in your registries.
- House these files within your own private AWS S3 storage, thereby allowing you to maintain full control, ownership and sovereignty over the packages, container images and modules stored within your Buildkite Packages registries.

