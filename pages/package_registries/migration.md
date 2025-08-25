# Migrating to Buildkite Package Registries

This section of the documentation provides a comprehensive guidance to help you export your packages, images and other files from an existing registry or repository provider, and import them to Buildkite Package Registries.

## Before you start

Ensure the following are ready or have been done before commencing the migration process:

- The packages, images or other relevant files from your existing registry or repository provider are ready to be exported and downloaded locally.
- A new Buildkite registry whose package ecosystem matches your existing registry or repository provider. Learn more about this process in [Create a registry](/docs/package-registries/registries/manage#create-a-source-registry).
- An [API access token](https://buildkite.com/user/api-access-tokens) with the appropriate [package and registry scopes](/docs/apis/managing-api-tokens#token-scopes) to manage your packages.

## Begin migrating

To get started, choose the guide that corresponds to the registry or repository provider you are migrating from:

- [Export from JFrog Artifactory](/docs/package-registries/migration/from_jfrog_artifactory)
- [Export from Cloudsmith](/docs/package-registries/migration/from-cloudsmith)

Once you have downloaded your exported packages, you can then [import them into Buildkite Package Registries](/docs/package-registries/migration/import-to-package-registries).

If you need further assistance or have any questions, please don't hesitate to reach out to support at support@buildkite.com for help.
