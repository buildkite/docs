# Migrating to Buildkite Packages

Migrating from another package repository provider to Buildkite Packages should be a simple process. This section provides a comprehensive guide to help you export your packages from an old repository provider and import them to Buildkite Packages.

## Prerequisites

The following are prerequisites in migrating from another package repository:

1. Packages from your old repository should have been downloaded locally.
1. Ensure Buildkite Packages is enabled in your organization.
1. [Create the package registry](/docs/packages/manage-registries#create-a-registry) that matches the old repository ecosystem.
1. Create an API [access token](https://buildkite.com/user/api-access-tokens)  with the right [scopes](/docs/apis/managing-api-tokens#token-scopes) to manage your packages.

To get started, choose the guide that corresponds to the repository provider you are migrating from:

- [Migrate from JFrog Artifactory](/docs/packages/migration/from_jfrog_artifactory)

If you need further assistance or have any questions, please don’t hesitate to reach out to our [support](https://buildkite.com/support). We’re here to help you in this transition.
